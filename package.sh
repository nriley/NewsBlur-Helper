#!/bin/zsh -e

set -x -v

PACKAGEDIR="$PWD"
ARCHIVEDIR="$PWD"/Archives
EXPORTDIR=$(mktemp -d)
RELEASEDIR="$PWD"/Releases
PRODUCT=$(print *.xcodeproj(:r))

# gather information
VERSION=$(agvtool mvers -terse1)
BUILD=$(agvtool vers -terse)
DMG="$RELEASEDIR/$PRODUCT $VERSION.dmg"
VOL="$PRODUCT $VERSION"
ARCHIVE="$ARCHIVEDIR/$PRODUCT $VERSION ($BUILD).xcarchive"
EXPORT="$EXPORTDIR/$VOL"

# archive and export
mkdir -p $ARCHIVEDIR
rm -rf $ARCHIVE
xcodebuild -scheme $PRODUCT -archivePath $ARCHIVE archive
xcodebuild -archivePath $ARCHIVE -exportArchive -exportPath $EXPORT -exportOptionsPlist exportOptions.plist

# ensure code signature and Developer ID are valid
codesign --verify --verbose=4 "$EXPORT"/*.app
# also capture the identity in order to sign the disk image
IDENTITY=$(spctl -vv --assess "$EXPORT"/*.app 2>&1 | grep 'origin=' | sed -e 's/^origin=//')

# remove export metadata we don't want in the disk image
rm -f $EXPORT/*.plist $EXPORT/Packaging.log

# create disk image
mkdir -p $RELEASEDIR
rm -f $DMG
hdiutil create $DMG -megabytes 20 -ov -layout NONE -fs 'HFS+' -volname $VOL
MOUNT=$(hdiutil attach $DMG)
DISK=$(echo $MOUNT | sed -ne ' s|^/dev/\([^ ]*\).*$|\1|p')
MOUNTPOINT=$(echo $MOUNT | sed -ne 's|^.*\(/Volumes/.*\)$|\1|p')
ditto -rsrc "$EXPORT" "$MOUNTPOINT"
chmod -R a+rX,u+w "$MOUNTPOINT"
hdiutil detach $DISK
hdiutil resize -sectors min $DMG
ZDMG="${DMG:r}z.dmg"
hdiutil convert $DMG -format UDBZ -o $ZDMG
mv $ZDMG $DMG
hdiutil internet-enable $DMG

# sign the disk image
codesign --sign $IDENTITY $DMG

# verify disk image signature
spctl -vv --assess --type open --context context:primary-signature $DMG

# update appcast
$PACKAGEDIR/Sparkle/bin/generate_appcast $PACKAGEDIR/dsa_priv.pem $RELEASEDIR
APPCAST=$RELEASEDIR/appcast.xml

# clean up
rm -rf "$EXPORTDIR"
rm -rf $RELEASEDIR/.tmp

# update Web presence (temporary)
WEBDIR=web/temp/newsblur-helper
WEBDMG=$WEBDIR/${DMG:t}
WEBAPPCAST=$WEBDIR/${APPCAST:t}
scp $DMG osric:${WEBDMG:q}.new
scp $APPCAST osric:${WEBAPPCAST:q}.new
ssh osric chmod -R go+rX $WEBDIR
ssh osric mv ${WEBDMG:q}{.new,}
ssh osric mv ${WEBAPPCAST:q}{.new,}

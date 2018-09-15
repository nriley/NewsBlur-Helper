NewsBlur Helper
===============

This macOS app performs two tasks:

Opening stories in a new tab in Safari
--------------------------------------

Safari 10 and later no longer support the method the [NewsBlur](https://www.newsblur.com/) Web app uses to open stories in tabs.  This app includes a Safari app extension which gives NewsBlur the ability to do so again.

After copying the app to your Applications folder, reload the NewsBlur tab if it's open, or just quit and reopen Safari.  You should then be able to use the 'o' or 'v' keys to open stories in new tabs.

Previously, similar functionality was provided by the [NewsBlur Open in New Tab Safari extension](https://github.com/nriley/OpenInNewTab), which is no longer supported as of Safari 12.

Please note that currently the Safari app extension may launch on every Safari page load, which is somewhat inefficient; this will be fixed before 1.0.

Handling `feed:` URLs
---------------------
The `feed` URL scheme allows a feed to be opened in your preferred feed reader, such as NewsBlur.  When you launch NewsBlur Helper, it will offer to register itself to pass `feed` URLs to NewsBlur.  If you don’t want NewsBlur to handle `feed` URLs, check the checkbox and NewsBlur Helper will never ask again. 

Previously, this functionality was provided by the "NewsBlur Safari Helper" app.

If you have the NewsBlur Web app installed on your own server
-------------------------------------------------------------
If you do not access NewsBlur at newsblur.com, you can specify the domain of your own server in NewsBlur Helper’s Preferences.  The extension will only work on this domain, and `feed` URLs will redirect to this domain.  You will need to reload/reopen the site after changing this domain.

Problems? Please [create an issue](https://github.com/nriley/NewsBlur-Helper/issues).

Enjoy!

Nicholas Riley

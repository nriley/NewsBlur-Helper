//
//  AppDelegate.swift
//  NewsBlur Helper
//
//  Created by Nicholas Riley on 7/16/2018.
//  Copyright © 2018 NewsBlur. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    static let feedURLScheme: String = "feed"

    var wasAskedToOpenURLs: Bool = false

    func checkIfDefaultFeedApp() {
        let defaults = Defaults()
        if !defaults.askToSetFeedApp {
            return
        }

        guard let mainBundleIdentifier: String = Bundle.main.bundleIdentifier else {
            presentAlert("Can't get NewsBlur Helper’s bundle identifier.")
            return
        }

        if
            let defaultFeedAppURL: URL = (LSCopyDefaultApplicationURLForURL(
                URL(string: "\(AppDelegate.feedURLScheme)://")! as CFURL, LSRolesMask.viewer, nil)?.takeRetainedValue() as URL?),
            let defaultFeedAppBundleIdentifier: String = Bundle(url: defaultFeedAppURL)?.bundleIdentifier,
            mainBundleIdentifier == defaultFeedAppBundleIdentifier {
            return // nothing to do
        }

        // At least in 10.13.6, may need to force activation on first launch (Gatekeeper focus stealing, I think)
        if !NSApp.isActive {
            NSApp.activate(ignoringOtherApps: true)
        }

        let alert: NSAlert = NSAlert()
        alert.messageText = "NewsBlur Helper is not your default feed reader."
        alert.informativeText = "Do you want to set NewsBlur Helper as your default feed reader?\n\nIf you do so, feeds will open NewsBlur in your default web browser."
        alert.showsSuppressionButton = true
        alert.addButton(withTitle: "Don’t Set")
        alert.addButton(withTitle: "Set")

        if alert.runModal() == NSApplication.ModalResponse.alertSecondButtonReturn {
            // requires disabling sandboxing: https://stackoverflow.com/questions/26241689/
            let err: OSStatus = LSSetDefaultHandlerForURLScheme(
                AppDelegate.feedURLScheme as CFString, mainBundleIdentifier as CFString)
            if err != noErr {
                NSAlert(error: NSError(domain: NSOSStatusErrorDomain, code: Int(err))).runModal()
                return
            }
        }

        if alert.suppressionButton!.state == NSControl.StateValue.on {
            defaults.askToSetFeedApp = false
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // At least in 10.13.6, need to delay NSAlert display because the app ends up
        // in the background on first launch otherwise (Gatekeeper focus stealing, I think)
        // and trying to force activation from applicationDidFinishLaunching doesn't work

        DispatchQueue.main.async {
            self.checkIfDefaultFeedApp()

            if self.wasAskedToOpenURLs {
                NSApp.terminate(nil)
            } else if !NSApp.isActive && !NSApp.isHidden {
                // Work around Gatekeeper focus stealing if we don't need to display a NSAlert
                // (attempt to avoid stealing focus ourselves if we're hidden, since this could
                // conceivably be triggered at other times)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }

    func presentAlert(_ description: String) {
        NSAlert(error: NSError(domain: Bundle.main.bundleIdentifier ?? "", code: 0,
                               userInfo: [NSLocalizedDescriptionKey: description])).runModal()
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        wasAskedToOpenURLs = true
        guard let addURLPrefix = URL(string: "https://\(Defaults().newsBlurDomain!)/?url=")
            else {
                presentAlert("Can't get NewsBlur URL for domain \(Defaults().newsBlurDomain ?? "(null)").")
                return
        }
        for url in urls {
            if url.scheme != AppDelegate.feedURLScheme {
                continue
            }
            guard var urlComponents: URLComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                presentAlert("Invalid URL: ”\(url.absoluteString)ʺ.")
                continue
            }
            if urlComponents.host != nil {
                urlComponents.scheme = "http"
            } else {
                guard let nestedURL: URL = URL(string: urlComponents.path) else {
                    presentAlert("Invalid URL in feed URL: ”\(urlComponents.path)ʺ.")
                    continue
                }
                guard let nestedURLComponents = URLComponents(url: nestedURL, resolvingAgainstBaseURL: false) else {
                    presentAlert("Invalid URL in feed URL: ”\(urlComponents.path)ʺ.")
                    continue
                }
                if !["http", "https"].contains(nestedURLComponents.scheme) {
                    presentAlert("Invalid scheme in feed URL (http, https are supported): ”\(urlComponents.path)ʺ.")
                    continue
                }
                urlComponents = nestedURLComponents
            }
            let httpURL = urlComponents.url!

            guard let encodedFeedURL: String = httpURL.absoluteString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
                presentAlert("Can't generate a valid NewsBlur add URL for “\(httpURL.absoluteString)”.")
                return
            }
            guard let addURL = URL(string: "\(addURLPrefix)\(encodedFeedURL)") else {
                presentAlert("Can't generate a valid URL to tell NewsBlur to add the feed “\(url.absoluteString)”.")
                return
            }
            NSWorkspace.shared.open(addURL)
        }
    }

    @IBAction func openNewsBlurForum(_ sender: NSMenuItem) {
        NSWorkspace.shared.open(URL(string: "https://forum.newsblur.com/")!)
    }
}


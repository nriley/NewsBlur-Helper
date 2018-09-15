//
//  SafariExtensionHandler.swift
//  NewsBlur Safari Extension
//
//  Created by Nicholas Riley on 7/16/2018.
//  Copyright © 2018 NewsBlur. All rights reserved.
//

import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {

    let defaults: Defaults = Defaults()

    func updateSettings(in page: SFSafariPage) {
        page.dispatchMessageToScript(withName: "updateSettings", userInfo: [
            Defaults.Key.newsBlurDomain: defaults.newsBlurDomain ?? "newsblur.com"])
    }

    func openInNewTab(_ url: URL, inBackground background: Bool, from page: SFSafariPage) {
        NSLog("Trying to open page in new tab: \(url) in background: \(background)")
        SFSafariApplication.getActiveWindow { (activeWindow) in
            guard let activeWindow = activeWindow else {
                NSLog("Unable to get active Safari window")
                return
            }
            // activeWindow.getActiveTab(completionHandler: { (activeTab) in
            // XXX no way to access other tabs in window - regression from Safari extension API
            activeWindow.openTab(with: url, makeActiveIfPossible: !background, completionHandler: { (newTab) in
                guard let newTab = newTab else {
                    NSLog("Unable to open URL \(url) in new tab of window \(activeWindow)")
                    return
                }
                NSLog("Opened page in new tab for window \(activeWindow): \(url) - \(newTab)")
            })
        }
    }

    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        page.getPropertiesWithCompletionHandler { properties in
            NSLog("The extension received a message (\(messageName)) from a script injected into (\(String(describing: properties?.url))) with userInfo (\(userInfo ?? [:]))")
            if messageName == "getSettings" {
                self.updateSettings(in: page)
            } else if messageName == "openInNewTab" {
                guard
                    let message = userInfo,
                    let href = message["href"] as? String,
                    let url = URL(string: href),
                    let background = message["background"] as? Bool else {
                        NSLog("Invalid openInNewTab message format: \(String(describing: userInfo))")
                        return
                }
                self.openInNewTab(url, inBackground: background, from: page)
            } else {
                NSLog("Don't know how to handle message '\(messageName)'")
            }
        }
    }

}

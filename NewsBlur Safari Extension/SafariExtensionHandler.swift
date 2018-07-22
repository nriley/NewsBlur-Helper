//
//  SafariExtensionHandler.swift
//  NewsBlur Safari Extension
//
//  Created by Nicholas Riley on 7/16/2018.
//  Copyright © 2018 NewsBlur. All rights reserved.
//

import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {

    func updateSettings(in page: SFSafariPage) {
        // XXX just newsblur.com for now
        page.dispatchMessageToScript(withName: "updateSettings", userInfo: ["newsBlurDomain": "newsblur.com"])
    }

    func openInNewTab(_ url: URL, inBackground background: Bool, from page: SFSafariPage) {
        NSLog("Trying to open page in new tab: \(url) in background: \(background)")
        SFSafariApplication.getActiveWindow { (activeWindow) in
            activeWindow?.getActiveTab(completionHandler: { (activeTab) in
                // XXX what we really want is the last tab opened for tab...
                activeWindow?.openTab(with: url, makeActiveIfPossible: !background, completionHandler: { (newTab) in
                    NSLog("Opened page in new tab: \(url)")
                })
            })
        }
    }

    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        // This method will be called when a content script provided by your extension calls safari.extension.dispatchMessage("message").
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

    override func toolbarItemClicked(in window: SFSafariWindow) {
        // This method will be called when your toolbar item is clicked.
        NSLog("The extension's toolbar item was clicked")
    }

    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        // This is called when Safari's state changed in some way that would require the extension's toolbar item to be validated again.
        validationHandler(true, "")
    }

    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }

}

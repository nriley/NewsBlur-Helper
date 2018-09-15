//
//  SafariExtensionViewController.swift
//  NewsBlur Safari Extension
//
//  Created by Nicholas Riley on 7/16/2018.
//  Copyright © 2018 NewsBlur. All rights reserved.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {
    
    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        shared.preferredContentSize = NSSize(width: 320, height: 240)
        return shared
    }()

}

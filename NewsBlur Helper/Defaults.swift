//
//  Defaults.swift
//  NewsBlur Helper
//
//  Created by Nicholas Riley on 7/28/2018.
//  Copyright © 2018 NewsBlur. All rights reserved.
//

import Cocoa

class Defaults : NSObject {
    enum Key {
        static let newsBlurDomain: String = "newsBlurDomain"
        static let askToSetFeedApp: String = "askToSetFeedApp"
    }

    lazy var suite: UserDefaults? = {
        guard let defaultsWithSuite: UserDefaults = UserDefaults(suiteName: "group.com.newsblur.NewsBlur-Helper")
            else {
                NSLog("Unable to create shared UserDefaults; setting NewsBlur domain will not work")
                return nil
        }
        defaultsWithSuite.register(defaults: [
            Key.newsBlurDomain: "newsblur.com"
            ])
        return defaultsWithSuite
    }()

    @IBOutlet lazy var controller: NSUserDefaultsController? = {
        NSUserDefaultsController(defaults: suite!,
                                 initialValues: nil)
    }()

    var newsBlurDomain: String? {
        get {
            return suite?.string(forKey: Key.newsBlurDomain)
        }
    }

    lazy var standard: UserDefaults = {
        let standard = UserDefaults.standard
        standard.register(defaults: [
            Key.askToSetFeedApp: true
            ])
        return standard
    }()

    var askToSetFeedApp: Bool {
        get {
            return standard.bool(forKey: Key.askToSetFeedApp)
        }
        set {
            standard.set(newValue, forKey: Key.askToSetFeedApp)
        }
    }
}

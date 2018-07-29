//
//  DomainNameFormatter.swift
//  NewsBlur Helper
//
//  Created by Nicholas Riley on 7/29/2018.
//  Copyright © 2018 NewsBlur. All rights reserved.
//

import Foundation

class DomainNameFormatter: Formatter {
    override func string(for obj: Any?) -> String? {
        return obj as? String
    }

    private static let validCharacterSet = CharacterSet.urlHostAllowed
    private static let dotCharacterSet = CharacterSet(charactersIn: ".")

    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {

        // first strip characters that don't belong in a domain name
        var domainNameString = string.lowercased()
        domainNameString = String(domainNameString.unicodeScalars.filter(
            { DomainNameFormatter.validCharacterSet.contains($0) }))

        // then any leading or trailing dots
        domainNameString = domainNameString.trimmingCharacters(in: DomainNameFormatter.dotCharacterSet)
        obj?.pointee = domainNameString as NSString

        return true
    }
}

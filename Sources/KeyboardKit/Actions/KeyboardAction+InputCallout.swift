//
//  KeyboardAction+InputCallout.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-09-30.
//  Copyright © 2021-2024 Daniel Saidi. All rights reserved.
//

import Foundation

public extension KeyboardAction {
    
    /// The input callout text to present for the action.
    var inputCalloutText: String? {
        switch self {
        case .character(let char): char
        case .emoji(let emoji): emoji.char
        case .controlCombination(let asciiValue): "⌃\(UnicodeScalar(asciiValue))".uppercased()
        case .metaCombination(let asciiValue): "❖\(UnicodeScalar(asciiValue))".uppercased()
        default: nil
        }
    }
}

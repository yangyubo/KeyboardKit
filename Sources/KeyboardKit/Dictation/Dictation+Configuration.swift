//
//  Dictation+Configuration.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2023-03-27.
//  Copyright © 2023-2024 Daniel Saidi. All rights reserved.
//

import Foundation

public extension Dictation {
    
    /// This type can configure a ``DictationService``.
    ///
    /// > Note: These two configurations types will probably
    /// be merged in KeyboardKit 9.0.
    struct Configuration: Codable, Equatable {
        
        /// Create a dictation configuration.
        ///
        /// - Parameters:
        ///   - localeId: The locale to use for dictation, by the `.current` locale.
        public init(
            localeId: String = Locale.current.identifier
        ) {
            self.localeId = localeId
        }
        
        /// The locale to use for dictation.
        public let localeId: String
    }
}

public extension Dictation.Configuration {

    /// Get a standard configuration for the current locale.
    static var standard: Dictation.Configuration {
        .init()
    }
}

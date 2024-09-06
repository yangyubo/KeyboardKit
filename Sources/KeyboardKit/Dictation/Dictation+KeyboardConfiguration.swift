//
//  Dictation+KeyboardConfiguration.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2023-03-27.
//  Copyright © 2023-2024 Daniel Saidi. All rights reserved.
//

import Foundation

public extension Dictation {
    
    /// This type can configure a ``KeyboardDictationService``
    /// by describing how to perform keyboard dictation.
    ///
    /// > Note: These two configurations types will probably
    /// be merged in KeyboardKit 9.0. 
    struct KeyboardConfiguration: Codable, Equatable {
        
        /// Create a keyboard dictation configuration.
        ///
        /// - Parameters:
        ///   - appGroupId: The app group to use to sync data between the keyboard and the app.
        ///   - appDeepLink: The deep link to use to open the app and start the dictation.
        public init(
            appGroupId: String,
            appDeepLink: String
        ) {
            self.appGroupId = appGroupId
            self.appDeepLink = appDeepLink
        }
        
        /// The app group to use to sync data.
        public let appGroupId: String
        
        /// The deep link to use to open the app.
        public let appDeepLink: String
    }
}

public extension Dictation.KeyboardConfiguration {

    /// Whether or not the ``appDeepLink`` matches the url.
    func matchesDeepLink(_ url: URL) -> Bool {
        url.absoluteString == appDeepLink
    }
}

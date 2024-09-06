//
//  KeyboardApp.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2024-04-01.
//  Copyright © 2024 Daniel Saidi. All rights reserved.
//

import Foundation
import SwiftUI

/// This type can be used to define important app properties,
/// and is also a namespace for KeyboardKit Pro app features.
///
/// You can create a static app value and add it to both the
/// main app target and its keyboard extension target, to be
/// able to easily refer to it from both targets:
///
/// ```swift
/// extension KeyboardApp {
///     static var keyboardKitDemo: Self {
///         .init(
///             name: "KeyboardKit",
///             licenseKey: "abc123",
///             bundleId: "com.keyboardkit.demo",
///             appGroupId: "group.com.keyboardkit.demo",
///             locales: [.english, .swedish, .persian],
///             deepLinks: .init(app: "keyboardkit://")
///         )
///     }
/// }
/// ```
///
/// The app value can also resolve other properties that you
/// may need, such as a ``dictationConfiguration``.
///
/// > Important: The ``locales`` collection is only meant to
/// describe which locales you *want* to use in your app. It
/// will be capped to the number of locales your KeyboardKit
/// Pro license includes.
public struct KeyboardApp {

    /// Create a custom keyboard app value.
    ///
    /// - Parameters:
    ///   - name: The name of the app.
    ///   - licenseKey: Your license key, if any.
    ///   - bundleId: The app's bundle identifier.
    ///   - keyboardExtensionBundleId: The app's keyboard bundle identifier, by default the bundle ID with a `.keyboard` suffix.
    ///   - appGroupId: The app's App Group identifier, if any.
    ///   - locales: The locales to use in the app, by default `.all`.
    ///   - deepLinks: App-specific deep links, if any.
    public init(
        name: String,
        licenseKey: String = "",
        bundleId: String,
        keyboardExtensionBundleId: String? = nil,
        appGroupId: String? = nil,
        locales: [KeyboardLocale] = .all,
        deepLinks: DeepLinks? = nil
    ) {
        self.name = name
        self.bundleId = bundleId
        self.keyboardExtensionBundleId = keyboardExtensionBundleId ?? "\(bundleId).keyboard"
        self.appGroupId = appGroupId
        self.locales = locales
        self.licenseKey = licenseKey
        self.deepLinks = deepLinks
        if let appGroupId, let dictationLink = deepLinks?.dictation {
            dictationConfiguration = .init(
                appGroupId: appGroupId,
                appDeepLink: dictationLink
            )
        } else {
            dictationConfiguration = nil
        }
    }

    @available(*, deprecated, message: "Use the deepLinks initializer instead.")
    public init(
        name: String,
        licenseKey: String = "",
        bundleId: String,
        keyboardExtensionBundleId: String? = nil,
        appGroupId: String? = nil,
        locales: [KeyboardLocale] = .all,
        dictationDeepLink: String
    ) {
        self.init(
            name: name,
            licenseKey: licenseKey,
            bundleId: bundleId,
            keyboardExtensionBundleId: keyboardExtensionBundleId,
            appGroupId: appGroupId,
            locales: locales,
            deepLinks: .init(app: "", dictation: dictationDeepLink)
        )
    }

    /// This type can define app-specific deep links.
    public struct DeepLinks {

        /// Create a custom keyboard deep links value.
        ///
        /// If you do not provide a value for a certain link,
        /// a default link will be used to guide your design.
        ///
        /// - Parameters:
        ///   - app: A deep link for opening the app, e.g. `x://`.
        ///   - dictation: A deep link for opening the app and starting dictation, by default `x://dictation`.
        ///   - keyboardSettings: A deep link for opening the app's keyboard settings screen, by default `x://keyboardSettings`.
        ///   - languageSettings: A deep link for opening the app's language settings screen, by default `x://languageSettings`.
        ///   - themeSettings: A deep link for opening the app's theme settings screen, by default `x://themeSettings`.
        public init(
            app: String,
            dictation: String? = nil,
            keyboardSettings: String? = nil,
            languageSettings: String? = nil,
            themeSettings: String? = nil
        ) {
            self.app = app
            self.dictation = dictation ?? "\(app)/dictation"
            self.keyboardSettings = keyboardSettings ?? "\(app)/keyboardSettings"
            self.languageSettings = languageSettings ?? "\(app)/languageSettings"
            self.themeSettings = themeSettings ?? "\(app)/themeSettings"
        }

        public let app: String
        public let dictation: String
        public let keyboardSettings: String
        public let languageSettings: String
        public let themeSettings: String
    }

    /// The name of the app.
    public let name: String

    /// Your license key, if any.
    public let licenseKey: String

    /// The app's bundle identifier.
    public let bundleId: String

    /// The app's bundle identifier.
    public let keyboardExtensionBundleId: String

    /// The app's App Group identifier, if any.
    public let appGroupId: String?

    /// The locales to use in the app.
    public let locales: [KeyboardLocale]

    /// App-specific deep links, if any.
    public let deepLinks: DeepLinks?

    /// The app's dictation configuration, if any.
    public let dictationConfiguration: Dictation.KeyboardConfiguration?
}

public extension KeyboardApp {

    /// The keyboard extension bundle ID wildcard, which can
    /// be used to see if the keyboard extension is enabled.
    var keyboardExtensionBundleIdWildcard: String {
        "\(bundleId).*"
    }
}

private extension KeyboardApp {

    static var keyboardKitDemo: Self {
        .init(
            name: "KeyboardKit",
            licenseKey: "abc123",
            bundleId: "com.keyboardkit.demo",
            keyboardExtensionBundleId: "com.keyboardkit.demo.keyboard",
            appGroupId: "group.com.keyboardkit.demo",
            locales: [.english, .swedish, .persian],
            deepLinks: .init(app: "keyboardkit://")
        )
    }
}

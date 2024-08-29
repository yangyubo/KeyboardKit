//
//  KeyboardThemeContext.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2024-08-29.
//  Copyright © 2024 Daniel Saidi. All rights reserved.
//

import SwiftUI

/// This class has observable states and persistent settings
/// for keyboard-specific themes.
///
public class KeyboardThemeContext: ObservableObject {

    /// Create a keyboard theme context instance.
    public init() {}


    // MARK: - Settings

    /// The settings key prefix to use for this namespace.
    public static var settingsPrefix: String {
        KeyboardSettings.storeKeyPrefix(for: "themes")
    }

    /// The currently applied theme, if any.
    ///
    /// Stored in ``Foundation/UserDefaults/keyboardSettings``.
    @AppStorage("\(settingsPrefix)currentTheme", store: .keyboardSettings)
    public var theme: Keyboard.StorageValue<KeyboardTheme?> = .init(value: nil)
}

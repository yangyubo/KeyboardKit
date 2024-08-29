//
//  KeyboardSettings.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2024-03-30.
//  Copyright © 2024 Daniel Saidi. All rights reserved.
//

import SwiftUI

/// This class can be used to setup a custom value store for
/// all settings types in the library.
///
/// The static ``store`` is used to persist settings. It has
/// a ``Foundation/UserDefaults/keyboardSettings`` shorthand.
///
/// Use ``setupStore(_:keyPrefix:)`` to setup a custom store,
/// or ``setupStore(withAppGroup:keyPrefix:)`` to use an App
/// Group to sync settings between the app and its keyboards.
///
/// > Important: `@AppStorage` properties will use the store
/// that's available when a property is first accessed. Make
/// sure to run ``setupStore(_:keyPrefix:)`` BEFORE your app
/// or keyboard extension accesses these settings properties.
public class KeyboardSettings: ObservableObject, LegacySettings {

    // MARK: - Deprecated: Settings are moved to the context.

    /// DEPRECATED - Settings are moved to the context.
    static let prefix = KeyboardSettings.storeKeyPrefix(for: "keyboard")

    /// DEPRECATED - Settings are moved to the context.
    @AppStorage("\(prefix)isAutocapitalizationEnabled", store: .keyboardSettings)
    public var isAutocapitalizationEnabled = true {
        didSet { triggerChange() }
    }

    @Published
    var lastChanged = Date()
}

extension KeyboardSettings {

    func syncToContextIfNeeded(
        _ context: KeyboardContext
    ) {
        guard shouldSyncToContext else { return }
        context.sync(with: self)
        updateLastSynced()
    }
}

public extension KeyboardSettings {

    /// The store that will be used by library settings.
    static var store: UserDefaults = .standard

    /// The key prefix that will be used by library settings.
    static var storeKeyPrefix = "com.keyboardkit.settings."

    /// Whether or not the ``store`` is App Group synced.
    static private(set) var storeIsAppGroupSynced = false

    @available(*, deprecated, message: "Setting an optional store is no longer allowed.")
    static func setupStore(
        _ store: UserDefaults?,
        keyPrefix: String? = nil
    ) {
        setupStore(store ?? .standard, keyPrefix: keyPrefix)
    }

    /// Set up a custom settings store.
    ///
    /// - Parameters:
    ///   - store: The store to use.
    ///   - keyPrefix: The prefix to use for all store keys.
    ///   - isAppGroupSynced: Whether the store syncs with an App Group.
    static func setupStore(
        _ store: UserDefaults,
        keyPrefix: String? = nil,
        isAppGroupSynced: Bool = false
    ) {
        Self.store = store
        Self.storeKeyPrefix = keyPrefix ?? Self.storeKeyPrefix
        Self.storeIsAppGroupSynced = isAppGroupSynced
    }

    /// Set up a custom settings store for a ``KeyboardApp``,
    /// including App Group syncing in the app specifies one.
    static func setupStore(
        for app: KeyboardApp,
        keyPrefix: String? = nil
    ) {
        if let appGroup = app.appGroupId {
            setupStore(forAppGroup: appGroup, keyPrefix: keyPrefix)
        } else {
            setupStore(.keyboardSettings, keyPrefix: keyPrefix, isAppGroupSynced: false)
        }
    }

    /// Set up a custom keyboard settings store that uses an
    /// App Group to sync settings between multiple targets.
    static func setupStore(
        forAppGroup group: String,
        keyPrefix prefix: String? = nil
    ) {
        guard let store = UserDefaults(suiteName: group) else { return }
        setupStore(store, keyPrefix: prefix, isAppGroupSynced: true)
    }

    @available(*, deprecated, renamed: "setupStore(forAppGroupId:keyPrefix:)")
    static func setupStore(
        withAppGroup group: String,
        keyPrefix prefix: String? = nil
    ) {
        setupStore(forAppGroup: group, keyPrefix: prefix)
    }

    /// Get the store key prefix for a certain namespace.
    static func storeKeyPrefix(
        for namespace: String
    ) -> String {
        "\(Self.storeKeyPrefix)\(namespace)."
    }
}

public extension UserDefaults {

    /// This static instance can be used to persist keyboard
    /// related settings.
    ///
    /// See ``KeyboardSettings`` for more information on how
    /// to register a custom store.
    static var keyboardSettings: UserDefaults {
        get { KeyboardSettings.store }

        @available(*, deprecated, message: "Use KeyboardSettings.setupStore(...) instead")
        set { KeyboardSettings.store = newValue }
    }
}

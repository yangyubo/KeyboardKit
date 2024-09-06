//
//  VersionBridging.swift
//  KeyboardPro
//
//  Created by Daniel Saidi on 2024-09-06.
//  Copyright © 2024 Daniel Saidi. All rights reserved.
//
//  This file adds temporary typealiases for things that are
//  coming to the next version of KeyboardKit Pro, but which
//  aren't yet changed in the version that the keyboard uses.

import KeyboardKitPro

extension KeyboardStyle {
    typealias StandardService = KeyboardStyle.StandardProvider
    typealias ThemeBasedService = KeyboardStyle.ThemeBasedProvider
}
typealias KeyboarsStyleService = KeyboardStyleProvider
extension Keyboard.Services {
    var styleService: KeyboarsStyleService {
        get { styleProvider }
        set { styleProvider = newValue }
    }
}

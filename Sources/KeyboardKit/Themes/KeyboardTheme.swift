//
//  KeyboardTheme.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2023-03-18.
//  Copyright © 2023-2024 Daniel Saidi. All rights reserved.
//

import SwiftUI

/// This struct defines a keyboard-specific theme, which can
/// be used to define a bunch of styles at once.
///
/// A theme can be copied, tweaked, styled, etc. This struct
/// implements `Codable` and can as such be easily persisted.
///
/// KeyboardKit Pro unlocks many themes and style variations,
/// as well as a theme-based style service. You can use base
/// themes as they are or use them as templates for new ones.
///
/// See <doc:Themes-Article> for more information.
public struct KeyboardTheme: KeyboardThemeCopyable, Codable, Equatable, Identifiable {

    /// This enum defines various button types.
    public enum ButtonType: String, Codable {

        /// Input buttons are the light ones that enter text.
        case input

        /// System buttons are darker and trigger actions.
        case system

        /// Primary buttons are the prominent return buttons.
        case primary
    }

    /// The unique theme ID.
    public var id: UUID

    /// The name of the theme.
    public var name: String

    /// The name of a collection to which the theme belongs.
    public var collectionName: String

    /// The name of the author, if any.
    public var author: Author?

    /// The background style to apply, if any.
    public var backgroundStyle: Keyboard.Background?

    /// The foreground color to apply, if any.
    public var foregroundColor: Color?

    /// The button styles to apply to certain button types.
    public var buttonStyles: [ButtonType: Keyboard.ButtonStyle]

    /// The style to apply to autocomplete toolbars, if any.
    public var autocompleteToolbarStyle: Autocomplete.ToolbarStyle?

    /// The style to apply to action callouts, if any.
    public var actionCalloutStyle: Callouts.ActionCalloutStyle?

    /// The style to apply to input callout, if any.
    public var inputCalloutStyle: Callouts.InputCalloutStyle?
}

public extension KeyboardTheme {

    /// This struct defines a theme author.
    struct Author: Codable, Equatable {

        /// Create a theme author value.
        public init(
            name: String,
            about: String? = nil,
            url: String? = nil
        ) {
            self.name = name
            self.about = about
            self.url = url
        }

        /// The name of the author.
        public var name: String

        /// Some information about the author, if any.
        public var about: String?

        /// The URL to the author website/socials, if any.
        public var url: String?
    }
}

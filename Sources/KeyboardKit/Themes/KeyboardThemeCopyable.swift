//
//  KeyboardThemeCopyable.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2023-04-26.
//  Copyright © 2023-2024 Daniel Saidi. All rights reserved.
//

import Foundation

/// This protocol is implemented by pro theme components, to
/// make it possible to create mutable copies.
public protocol KeyboardThemeCopyable: Identifiable where ID == UUID {

    /// The unique theme component ID.
    var id: ID { get set }

    /// The name of the theme component.
    var name: String { get set }
}

public extension KeyboardThemeCopyable {

    /// Create a copy of this theme component.
    ///
    /// If you don't provide an ID, the new value will get a
    /// random generated, unique ID.
    ///
    /// - Parameters:
    ///   - newId: An optional, explicit ID.
    ///   - newName: An optional new name.
    func copy(
        newId id: UUID? = nil,
        newName: String? = nil
    ) -> Self {
        var copy = self
        copy.id = id ?? .init()
        copy.name = newName ?? copy.name
        return copy
    }
}

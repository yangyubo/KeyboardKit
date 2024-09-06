//
//  AutocompleteContextTests.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2024-08-26.
//  Copyright © 2024 Daniel Saidi. All rights reserved.
//

import KeyboardKit
import XCTest

final class AutocompleteContextTests: XCTestCase {

    let context = AutocompleteContext()

    func testCanGetNextCharacterProbabilityForStringsAndActions() {
        context.nextCharacterProbabilities = [
            "a": 0.1,
            "b": 0.2
        ]

        XCTAssertEqual(context.nextCharacterProbability(for: "a"), 0.1)
        XCTAssertEqual(context.nextCharacterProbability(for: "b"), 0.2)
        XCTAssertEqual(context.nextCharacterProbability(for: "c"), 0.0)
        XCTAssertEqual(context.nextCharacterProbability(for: .character("a")), 0.1)
        XCTAssertEqual(context.nextCharacterProbability(for: .backspace), 0)
    }
}

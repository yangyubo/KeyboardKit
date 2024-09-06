//
//  Keyboard+State.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2023-10-02.
//  Copyright © 2023-2024 Daniel Saidi. All rights reserved.
//

import SwiftUI

public extension Keyboard {

    /// This type specifies global keyboard state.
    ///
    /// This lets us decouple the input view controller from
    /// any views that require settings, services, and state
    /// from the controller.
    ///
    /// You can adjust any state value at any time to adjust
    /// the global behavior of the keyboard.
    class State {

        /// Create state instances.
        public init() {}

        /// The autocomplete context to use.
        public lazy var autocompleteContext = AutocompleteContext()
        
        /// The callout context to use.
        public lazy var calloutContext = CalloutContext(
            actionContext: .disabled,
            inputContext: .disabled)
        
        /// The dictation context to use.
        public lazy var dictationContext = DictationContext()
        
        /// The feedback context to use.
        public lazy var feedbackContext = FeedbackContext()

        /// The keyboard context to use.
        public lazy var keyboardContext = KeyboardContext()

        /// The keyboard theme context to use.
        public lazy var themeContext = KeyboardThemeContext()
    }
}

#if os(iOS) || os(tvOS) || os(visionOS)
public extension Keyboard.State {
    
    // Setup the state instance for the provided controller.
    func setup(for controller: KeyboardInputViewController) {
        let isPhone = UIDevice.current.userInterfaceIdiom == .phone
        let keyboardType = controller.textDocumentProxy.keyboardType
        let contextType = keyboardType?.keyboardType ?? .alphabetic(.auto)
        keyboardContext.sync(with: controller)
        keyboardContext.keyboardType = contextType
        calloutContext.inputContext.isEnabled = isPhone
    }
}
#endif

public extension View {
    
    // Inject all observable state into the view hierarchy.
    func keyboardState(_ state: Keyboard.State) -> some View {
        self.environmentObject(state.autocompleteContext)
            .environmentObject(state.calloutContext)
            .environmentObject(state.dictationContext)
            .environmentObject(state.feedbackContext)
            .environmentObject(state.keyboardContext)
    }
}

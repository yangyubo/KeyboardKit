//
//  KeyboardAction+StandardHandler.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2019-04-24.
//  Copyright © 2019-2024 Daniel Saidi. All rights reserved.
//

import Foundation

extension KeyboardAction {

    /// This class provides a standard way to handle actions
    /// that are triggered by the keyboard.
    ///
    /// KeyboardKit automatically creates an instance of the
    /// class when the keyboard is launched, then injects it
    /// into ``KeyboardInputViewController/services``.
    ///
    /// You can inherit this class to get base functionality,
    /// then override any open parts that you want to change.
    ///
    /// See <doc:Actions-Article> for more information.
    open class StandardHandler: NSObject, KeyboardActionHandler {

        // MARK: - Initialization

        #if os(iOS)
        /// Create a standard keyboard action handler for an
        /// input controller.
        ///
        /// - Parameters:
        ///   - controller: The keyboard input controller to use.
        public convenience init(
            controller: KeyboardInputViewController
        ) {
            let state = controller.state
            let services = controller.services
            self.init(
                controller: controller,
                keyboardContext: state.keyboardContext,
                keyboardBehavior: services.keyboardBehavior,
                autocompleteContext: state.autocompleteContext,
                autocompleteService: services.autocompleteService,
                feedbackContext: state.feedbackContext,
                feedbackService: services.feedbackService,
                spaceDragGestureHandler: services.spaceDragGestureHandler
            )
        }
        #endif

        /// Create a standard keyboard action handler with a
        /// separate set of services.
        ///
        /// - Parameters:
        ///   - controller: The keyboard controller to use, if any.
        ///   - keyboardContext: The keyboard context to use.
        ///   - keyboardBehavior: The keyboard behavior to use.
        ///   - autocompleteContext: The autocomplete context to use.
        ///   - autocompleteService: The autocomplete service to use.
        ///   - feedbackContext: The feedback context to use.
        ///   - feedbackService: The feedback service to use.
        ///   - spaceDragGestureHandler: The space gesture handler to use.
        public init(
            controller: KeyboardController?,
            keyboardContext: KeyboardContext,
            keyboardBehavior: KeyboardBehavior,
            autocompleteContext: AutocompleteContext,
            autocompleteService: AutocompleteService? = nil,
            feedbackContext: FeedbackContext,
            feedbackService: FeedbackService,
            spaceDragGestureHandler: Gestures.SpaceDragGestureHandler
        ) {
            weak var weakController = controller
            self.keyboardController = weakController
            self.keyboardContext = keyboardContext
            self.keyboardBehavior = keyboardBehavior
            self.autocompleteContext = autocompleteContext
            self.autocompleteService = autocompleteService
            self.feedbackContext = feedbackContext
            self.feedbackService = feedbackService
            self.spaceDragGestureHandler = spaceDragGestureHandler
        }


        // MARK: - Properties

        /// The controller to which this handler applies.
        public weak var keyboardController: KeyboardController?


        /// The autocomplete context to use.
        public var autocompleteContext: AutocompleteContext

        /// The autocomplete service to use.
        public var autocompleteService: AutocompleteService?

        /// The keyboard behavior to use.
        public var keyboardBehavior: KeyboardBehavior

        /// The keyboard context to use.
        public var keyboardContext: KeyboardContext

        /// The feedback context to use.
        public var feedbackContext: FeedbackContext

        /// The feedback service to use.
        public var feedbackService: FeedbackService

        /// The space drag gesture handler to use.
        public var spaceDragGestureHandler: Gestures.SpaceDragGestureHandler


        @available(*, deprecated, message: "This is no longer used.")
        public var emojiRegistrationAction: ((Emoji) -> Void)?


        private var spaceDragActivationLocation: CGPoint?



        // MARK: - KeyboardActionHandler

        /// Whether the handler can handle an action gesture.
        open func canHandle(
            _ gesture: Keyboard.Gesture,
            on action: KeyboardAction
        ) -> Bool {
            self.action(for: gesture, on: action) != nil
        }

        /// Handle a certain keyboard action.
        open func handle(
            _ action: KeyboardAction
        ) {
            action.standardAction?(keyboardController)
        }

        /// Handle a certain keyboard action gesture.
        open func handle(
            _ gesture: Keyboard.Gesture,
            on action: KeyboardAction
        ) {
            handle(gesture, on: action, replaced: false)
        }

        /// Handle a certain autocomplete suggestion.
        open func handle(
            _ suggestion: Autocomplete.Suggestion
        ) {
            if suggestion.isUnknown, autocompleteContext.isAutolearnEnabled {
                autocompleteService?.learn(suggestion)
            }
            keyboardContext.insertAutocompleteSuggestion(suggestion)
            handle(.release, on: .character(""))
        }

        /// Handle a certain action gesture, with replace logic.
        open func handle(
            _ gesture: Keyboard.Gesture,
            on action: KeyboardAction,
            replaced: Bool
        ) {
            if !replaced && tryHandleReplacementAction(before: gesture, on: action) { return }
            let gestureAction = self.action(for: gesture, on: action)
            triggerFeedback(for: gesture, on: action)
            tryUpdateSpaceDragState(for: gesture, on: action)
            guard let gestureAction else { return }
            tryRemoveAutocompleteInsertedSpace(before: gesture, on: action)
            tryApplyAutocorrectSuggestion(before: gesture, on: action)
            gestureAction(keyboardController)
            tryReinsertAutocompleteRemovedSpace(after: gesture, on: action)
            tryEndSentence(after: gesture, on: action)
            tryChangeKeyboardType(after: gesture, on: action)
            tryPerformAutocomplete(after: gesture, on: action)
            tryRegisterEmoji(after: gesture, on: action)
        }

        /// Handle a certain keyboard action drag gesture.
        open func handleDrag(
            on action: KeyboardAction,
            from startLocation: CGPoint,
            to currentLocation: CGPoint
        ) {
            tryHandleSpaceDrag(
                on: action,
                from: startLocation,
                to: currentLocation
            )
        }



        // MARK: - Feedback

        /// The feedback to use for a certain action gesture.
        open func audioFeedback(
            for gesture: Keyboard.Gesture,
            on action: KeyboardAction
        ) -> Feedback.Audio? {
            let config = feedbackContext.audioConfiguration
            let custom = config.customFeedback(for: gesture, on: action)
            if let custom = custom { return custom }
            if action == .space && gesture == .longPress { return nil }
            if action == .backspace && gesture == .press { return config.delete }
            if action == .backspace && gesture == .repeatPress { return config.delete }
            if action.isInputAction && gesture == .press { return config.input }
            if action.isSystemAction && gesture == .press { return config.system }
            return nil
        }

        /// The feedback to use for a certain action gesture.
        open func hapticFeedback(
            for gesture: Keyboard.Gesture,
            on action: KeyboardAction
        ) -> Feedback.Haptic? {
            let config = feedbackContext.hapticConfiguration
            return config.feedback(for: gesture, on: action)
        }

        /// Whether to trigger feedback for an action.
        open func shouldTriggerFeedback(
            for gesture: Keyboard.Gesture,
            on action: KeyboardAction
        ) -> Bool {
            return true
        }

        /// Whether to trigger audio feedback for an action.
        open func shouldTriggerAudioFeedback(
            for gesture: Keyboard.Gesture,
            on action: KeyboardAction
        ) -> Bool {
            return true
        }

        /// Whether to trigger haptic feedback for an action.
        open func shouldTriggerHapticFeedback(
            for gesture: Keyboard.Gesture,
            on action: KeyboardAction
        ) -> Bool {
            let hasRelease = self.action(for: .release, on: action) != nil
            if gesture == .press && hasRelease { return true }
            let hasAction = self.action(for: gesture, on: action) != nil
            if gesture != .release && hasAction { return true }
            let config = feedbackContext.hapticConfiguration
            return config.hasCustomFeedback(for: gesture, on: action)
        }

        /// Trigger a certain audio feedback.
        ///
        /// The service just uses the ``feedbackService`` to
        /// trigger the provided feedback.
        open func triggerAudioFeedback(_ feedback: Feedback.Audio) {
            feedbackService.triggerAudioFeedback(feedback)
        }

        /// Trigger a certain haptic feedback.
        ///
        /// The service just uses the ``feedbackService`` to
        /// trigger the provided feedback.
        open func triggerHapticFeedback(_ feedback: Feedback.Haptic) {
            feedbackService.triggerHapticFeedback(feedback)
        }

        /// Trigger feedback for a certain action gesture.
        open func triggerFeedback(
            for gesture: Keyboard.Gesture,
            on action: KeyboardAction
        ) {
            guard shouldTriggerFeedback(for: gesture, on: action) else { return }
            triggerAudioFeedback(for: gesture, on: action)
            triggerHapticFeedback(for: gesture, on: action)
        }

        /// Trigger feedback for a certain action gesture.
        open func triggerAudioFeedback(
            for gesture: Keyboard.Gesture,
            on action: KeyboardAction
        ) {
            if !shouldTriggerAudioFeedback(for: gesture, on: action) { return }
            guard let feedback = audioFeedback(for: gesture, on: action) else { return }
            triggerAudioFeedback(feedback)
        }

        /// Trigger feedback for a certain action gesture.
        open func triggerHapticFeedback(
            for gesture: Keyboard.Gesture,
            on action: KeyboardAction
        ) {
            if !shouldTriggerHapticFeedback(for: gesture, on: action) { return }
            guard let feedback = hapticFeedback(for: gesture, on: action) else { return }
            triggerHapticFeedback(feedback)
        }


        // MARK: - Open Functions

        /// The standard action to use for a gesture action.
        open func action(
            for gesture: Keyboard.Gesture,
            on action: KeyboardAction
        ) -> KeyboardAction.GestureAction? {
            let standard = action.standardAction(for: gesture)
            guard action == .space, gesture == .release else { return standard }
            let isSpaceDragActive = keyboardContext.isSpaceDragGestureActive
            return isSpaceDragActive ? nil : standard
        }

        /// An optional keyboard action gesture replacement.
        open func replacementAction(
            for gesture: Keyboard.Gesture,
            on action: KeyboardAction
        ) -> KeyboardAction? {
            guard gesture == .release else { return nil }

            // Apply proxy-based replacements, if any
            if case let .character(char) = action,
               let replacement = keyboardContext.preferredQuotationReplacement(
                whenInserting: char,
                for: keyboardContext.locale) {
                return .character(replacement)
            }

            // Apply Kurdish replacements, if any
            if keyboardContext.locale.identifier.hasPrefix("ckb") && action == .character("ھ") {
                return .character("ه")
            }

            return nil
        }


        /// Whether to apply autocorrect before an action.
        open func tryApplyAutocorrectSuggestion(
            before gesture: Keyboard.Gesture,
            on action: KeyboardAction
        ) {
            if isSpaceCursorDrag(action) { return }
            if keyboardContext.isCursorAtNewWord { return }
            guard gesture == .release else { return }
            guard action.shouldApplyAutocorrectSuggestion else { return }
            let suggestions = autocompleteContext.suggestions
            let autocorrect = suggestions.first { $0.isAutocorrect }
            guard let suggestion = autocorrect else { return }
            keyboardContext.insertAutocompleteSuggestion(suggestion, tryInsertSpace: false)
        }

        /// Try to change keyboard type after a gesture.
        open func tryChangeKeyboardType(
            after gesture: Keyboard.Gesture,
            on action: KeyboardAction
        ) {
            guard keyboardBehavior.shouldSwitchToPreferredKeyboardType(after: gesture, on: action) else { return }
            let newType = keyboardBehavior.preferredKeyboardType(after: gesture, on: action)
            keyboardContext.keyboardType = newType
        }

        /// Try to end the current sentence after a gesture.
        open func tryEndSentence(
            after gesture: Keyboard.Gesture,
            on action: KeyboardAction
        ) {
            guard keyboardBehavior.shouldEndSentence(after: gesture, on: action) else { return }
            let text = keyboardBehavior.endSentenceText
            keyboardController?.endSentence(withText: text)
        }

        /// Try to perform autocomplete after a gesture.
        open func tryPerformAutocomplete(
            after gesture: Keyboard.Gesture,
            on action: KeyboardAction
        ) {
            keyboardController?.performAutocomplete()
        }

        /// Try to register an emoji after a gesture.
        open func tryRegisterEmoji(
            after gesture: Keyboard.Gesture,
            on action: KeyboardAction
        ) {
            guard gesture == .release else { return }
            switch action {
            case .emoji(let emoji): EmojiCategory.addEmoji(emoji, to: .frequent, maxCount: 30)
            default: return
            }
        }

        /// Handle a replacement action before a gesture.
        ///
        /// The caller shouldn't handle the action when this
        /// function returns `true`.
        open func tryHandleReplacementAction(
            before gesture: Keyboard.Gesture,
            on action: KeyboardAction
        ) -> Bool {
            guard let action = replacementAction(for: gesture, on: action) else { return false }
            handle(.release, on: action, replaced: true)
            return true
        }

        /// Try to reinsert removed space after a gesture.
        ///
        /// This is used to handle autocomplete space insert.
        open func tryReinsertAutocompleteRemovedSpace(
            after gesture: Keyboard.Gesture,
            on action: KeyboardAction
        ) {
            guard gesture == .release else { return }
            guard action.shouldReinsertAutocompleteInsertedSpace else { return }
            keyboardContext.tryReinsertAutocompleteRemovedSpace()
        }

        /// Try to remove inserted space before a gesture.
        ///
        /// This is used to handle autocomplete space insert.
        open func tryRemoveAutocompleteInsertedSpace(
            before gesture: Keyboard.Gesture,
            on action: KeyboardAction
        ) {
            guard gesture == .release else { return }
            guard action.shouldRemoveAutocompleteInsertedSpace else { return }
            keyboardContext.tryRemoveAutocompleteInsertedSpace()
        }
    }
}

private extension KeyboardAction.StandardHandler {

    func isSpaceCursorDrag(_ action: KeyboardAction) -> Bool {
        guard action == .space else { return false }
        let handler = spaceDragGestureHandler
        return handler.currentDragTextPositionOffset != 0
    }

    func tryHandleSpaceDrag(
        on action: KeyboardAction,
        from startLocation: CGPoint,
        to currentLocation: CGPoint
    ) {
        guard action == .space else { return }
        guard keyboardContext.spaceLongPressBehavior == .moveInputCursor else { return }
        guard keyboardContext.isSpaceDragGestureActive else { return }
        let activationLocation = spaceDragActivationLocation ?? currentLocation
        spaceDragActivationLocation = activationLocation
        spaceDragGestureHandler.handleDragGesture(
            from: activationLocation,
            to: currentLocation
        )
    }

    func tryUpdateSpaceDragState(
        for gesture: Keyboard.Gesture,
        on action: KeyboardAction
    ) {
        guard action == .space else { return }
        switch gesture {
        case .press:
            setSpaceDragActive(false)
            spaceDragActivationLocation = nil
        case .longPress:
            setSpaceDragActive(true)
        case .release, .end:
            setSpaceDragActive(false)
        default: break
        }
    }

    func setSpaceDragActive(_ isActive: Bool) {
        keyboardContext.setIsSpaceDragGestureActive(
            isActive,
            animated: true
        )
    }
}

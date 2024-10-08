//
//  KeyboardViewController.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2018-03-13.
//  Copyright © 2018-2024 Daniel Saidi. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(visionOS)
import Combine
import SwiftUI
import UIKit

/// This is the main input controller in a KeyboardKit-based
/// keyboard extension.
///
/// When using KeyboardKit, let `KeyboardController` inherit
/// this class instead of `UIInputViewController`, to extend
/// it with KeyboardKit-specific functionality.
///
/// You can override any functions, modify any ``state`` and
/// replace any ``services`` to tweak your keyboard behavior.
/// You also get a lot of additional controller features.
///
/// > Warning: A very important thing that you MUST consider
/// when you use `setup` or `setupPro` with a `view` builder,
/// is that the `view` builder provides you with an `unowned`
/// controller reference, since referring to `self` from the
/// view builder can cause memory leaks. However, since this
/// reference is a ``KeyboardInputViewController``, you must
/// still use `self` when you have to refer to your specific
/// controller class. If you do, it is VERY important to add
/// `[weak self]` or `[unowned self]` to the builder. If you
/// don't, the `self` reference will cause a memory leak.
///
/// See <doc:Getting-Started-Article> and <doc:Essentials-Article>
/// for more information about how to use this class.
open class KeyboardInputViewController: UIInputViewController, KeyboardController, UrlOpener {


    // MARK: - View Controller Lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()
        setupContexts()
        setupInitialWidth()
        setupLocaleObservation()
        viewWillRegisterSharedController()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillSetupKeyboardView()
        viewWillSetupInitialKeyboardType()
        viewWillSyncWithContext()
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewWillHandleDictationResult()
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        state.keyboardContext.syncAfterLayout(with: self)
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        viewWillSyncWithContext()
        super.traitCollectionDidChange(previousTraitCollection)
    }


    // MARK: - Keyboard View Controller Lifecycle

    /// This function is called to handle a dictation result
    /// when returning from the main app.
    open func viewWillHandleDictationResult() {
        Task {
            do {
                try await services.dictationService.handleDictationResultInKeyboard()
            } catch {
                await updateLastDictationError(error)
            }
        }
    }

    /// DEPRECATED: This will be removed in KeyboardKit 9.0.
    open func viewWillRegisterSharedController() {
        KeyboardUrlOpenerInternal.controller = self         // TODO: Remove in KeyboardKit 9.0
        Keyboard.NextKeyboardController.shared = self       // TODO: Remove in KeyboardKit 9.0
    }

    /// This function is called when the controller is about
    /// to sync the initial keyboard type at launch.
    open func viewWillSetupInitialKeyboardType() {
        setupInitialKeyboardType()
    }

    /// This function is called when the controller is about
    /// to create or update the keyboard view.
    ///
    /// If this function is not overridden, it will create a
    /// ``KeyboardView`` by default.
    open func viewWillSetupKeyboardView() {
        setupKeyboardView { controller in
            KeyboardView(
                state: controller.state,
                services: controller.services,
                buttonContent: { $0.view },
                buttonView: { $0.view },
                emojiKeyboard: { $0.view },
                toolbar: { $0.view }
            )
        }
    }

    /// This function is called when the controller is about
    /// to sync with the ``Keyboard/KeyboardState`` contexts.
    open func viewWillSyncWithContext() {
        performKeyboardContextSync()
    }


    // MARK: - Setup

    /// Set up KeyboardKit for a ``KeyboardApp``.
    ///
    /// This will configure ``KeyboardSettings`` with an App
    /// Group-synced ``KeyboardSettings/store``, if the `app`
    /// is configured with an ``KeyboardApp/appGroupId``. It
    /// will also set up the controller ``state``.
    ///
    /// Call this in ``viewDidLoad()`` to make sure that the
    /// keyboard is properly configured as early as possible.
    open func setup(
        for app: KeyboardApp
    ) {
        KeyboardSettings.setupStore(for: app)
        state.setup(for: app)
    }

    // Used to let KeyboardKit Pro show license error alerts.
    var setupKeyboardViewIsEnabled = true

    /// Set up KeyboardKit with a custom keyboard view.
    ///
    /// Call this in ``viewWillSetupKeyboardView()`` to make
    /// the controller use the `view` as keyboard view.
    open func setupKeyboardView<Content: View>(
        _ view: @autoclosure @escaping () -> Content
    ) {
        guard setupKeyboardViewIsEnabled else { return }
        setup(withRootView: Keyboard.RootView(view))
    }

    /// Set up KeyboardKit with a custom keyboard view.
    ///
    /// Call this in ``viewWillSetupKeyboardView()`` to make
    /// the controller use the view as the keyboard view.
    ///
    /// See <doc:Getting-Started-Article> for more important
    /// information on how to use an weak or unowned self to
    /// avoid memory leaks when you must refer to a specific
    /// controller class.
    open func setupKeyboardView<Content: View>(
        _ view: @escaping (_ controller: KeyboardInputViewController) -> Content
    ) {
        setup(withRootView: Keyboard.RootView { [weak self] in
            guard let self else { return view(.preview) }
            unowned let controller = self
            return view(controller)
        })
    }


    // MARK: - Deprecated

    @available(*, deprecated, message: "Use the setupPro licenseError parameter instead.")
    public var setupProError: Error?

    @available(*, deprecated, renamed: "viewWillSetupKeyboardView()")
    open func viewWillSetupKeyboard() {
        viewWillSetupKeyboardView()
    }

    @available(*, deprecated, renamed: "setupKeyboardView(_:)")
    open func setup<Content: View>(
        with view: @autoclosure @escaping () -> Content
    ) {
        setup(withRootView: Keyboard.RootView(view))
    }

    @available(*, deprecated, renamed: "setupKeyboardView(_:)")
    open func setup<Content: View>(
        with view: @escaping (_ controller: KeyboardInputViewController) -> Content
    ) {
        setupKeyboardView(view)
    }


    // MARK: - Combine

    var cancellables = Set<AnyCancellable>()


    // MARK: - Proxy Properties
    
    /// The original text document proxy.
    open var originalTextDocumentProxy: UITextDocumentProxy {
        super.textDocumentProxy
    }

    /// The text document proxy that is currently active.
    open override var textDocumentProxy: UITextDocumentProxy {
        textInputProxy ?? originalTextDocumentProxy
    }

    /// A custom text input proxy that can be set to replace
    /// the ``textDocumentProxy``.
    public var textInputProxy: UITextDocumentProxy? {
        didSet { viewWillSyncWithContext() }
    }


    // MARK: - Keyboard Properties

    /// The default set of keyboard-specific services.
    public lazy var services: Keyboard.Services = {
        let instance = Keyboard.Services(state: state)
        instance.setup(for: self)
        return instance
    }()

    /// The default set of keyboard-specific settings.
    public lazy var settings: Keyboard.Settings = {
        let instance = Keyboard.Settings()
        return instance
    }()

    /// The default set of keyboard-specific state.
    public lazy var state: Keyboard.State = {
        let instance = Keyboard.State()
        instance.setup(for: self)
        return instance
    }()



    // MARK: - Text And Selection Change

    open override func selectionWillChange(_ textInput: UITextInput?) {
        super.selectionWillChange(textInput)
        resetAutocomplete()
    }

    open override func selectionDidChange(_ textInput: UITextInput?) {
        super.selectionDidChange(textInput)
        resetAutocomplete()
    }

    open override func textWillChange(_ textInput: UITextInput?) {
        super.textWillChange(textInput)
        state.keyboardContext.syncTextDocumentProxy(with: self)
        state.keyboardContext.syncTextInputProxy(with: self)
    }
    
    open override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        DispatchQueue.main.async { [weak self] in
            self?.textDidChangeAsync(textInput)
        }
    }
    
    /// This function will be called with an async delay, to
    /// give the text document proxy time to update itself.
    open func textDidChangeAsync(_ textInput: UITextInput?) {
        performAutocomplete()
        tryChangeToPreferredKeyboardTypeAfterTextDidChange()
    }


    // MARK: - KeyboardController
    
    open func adjustTextPosition(by offset: Int) {
        textDocumentProxy.adjustTextPosition(byCharacterOffset: offset)
    }

    open func deleteBackward() {
        textDocumentProxy.deleteBackward(range: services.keyboardBehavior.backspaceRange)
    }

    open func deleteBackward(times: Int) {
        textDocumentProxy.deleteBackward(times: times)
    }

    open func endSentence(withText text: String) {
        textDocumentProxy.endSentence(withText: text)
    }

    open func insertDiacritic(_ diacritic: Keyboard.Diacritic) {
        textDocumentProxy.insertDiacritic(diacritic)
    }

    open func insertText(_ text: String) {
        textDocumentProxy.insertText(text)
    }

    open func selectNextLocale() {
        state.keyboardContext.selectNextLocale()
    }

    open func setKeyboardType(_ type: Keyboard.KeyboardType) {
        state.keyboardContext.keyboardType = type
    }

    /// Try to open a URL from the keyboard extension.
    ///
    /// > Warning: This has stopped working in iOS 18. Until
    /// we make `openURL:options:completionHandler:` work, a
    /// workaround is using regular SwiftUI Links.
    open func openUrl(_ url: URL?) {
        openUrlDefault(url)
    }
    
    open func controlCombination(with scalar: UnicodeScalar) {}
    open func metaCombination(with scalar: UnicodeScalar) {}
    open func customKey(with keyCode: UIKeyboardHIDUsage, isSystemAction: Bool, label: String) {}


    // MARK: - Syncing

    /// Whether or not context syncing is enabled.
    ///
    /// By default, syncung is enabled while a text document
    /// proxy isn't reading full the document context.
    open var isContextSyncEnabled: Bool {
        !textDocumentProxy.isReadingFullDocumentContext
    }
    
    /// Perform a keyboard context sync.
    ///
    /// This is performed to keep the ``state`` in sync, and
    /// will abort if ``isContextSyncEnabled`` is `false`.
    open func performKeyboardContextSync() {
        guard isContextSyncEnabled else { return }
        state.keyboardContext.sync(with: self)
    }


    // MARK: - Autocomplete

    /// The text to use when performing autocomplete.
    ///
    /// ``UIKit/UITextDocumentProxy/currentWordPreCursorPart``
    /// is used by default. You can override the function to
    /// change which text to use.
    open var autocompleteText: String? {
        textDocumentProxy.currentWordPreCursorPart
    }

    /// Whether or not autocomple is enabled.
    ///
    /// This property will by default base its value on both
    /// ``AutocompleteContext/isAutocompleteEnabled`` and on
    /// ``KeyboardContext/prefersAutocomplete``, where these
    /// must both be true for this to be true.
    open var isAutocompleteEnabled: Bool {
        guard
            state.keyboardContext.prefersAutocomplete,
            state.autocompleteContext.isAutocompleteEnabled
        else { return false }
        return !textDocumentProxy.isReadingFullDocumentContext
    }

    /// Perform an autocomplete operation.
    open func performAutocomplete() {
        guard isAutocompleteEnabled else { return }
        let text = autocompleteText
        let context = state.autocompleteContext
        let service = services.autocompleteService
        Task {
            do {
                let suggestions = try await service.autocompleteSuggestions(for: autocompleteText ?? "")
                var nextCharacterPredictions: [Character: Double] = [:]
                if context.isNextCharacterPredictionEnabled {
                    nextCharacterPredictions = try await service.nextCharacterPredictions(
                        forText: text ?? "",
                        suggestions: suggestions
                    )
                }
                updateAutocompleteContext(
                    with: suggestions,
                    nextCharacterPredictions: nextCharacterPredictions
                )
            } catch {
                updateAutocompleteContext(with: error)
            }
        }
    }

    /// Reset the current autocomplete state.
    open func resetAutocomplete() {
        state.autocompleteContext.reset()
    }


    // MARK: - Dictation

    /// Perform a keyboard-initiated dictation operation.
    public func performDictation() {
        Task {
            do {
                let config = state.dictationContext.keyboardConfiguration
                try await services.dictationService
                    .startDictationFromKeyboard(with: config)
            } catch {
                await updateLastDictationError(error)
            }
        }
    }
}

// MARK: - Private Functions

private extension KeyboardInputViewController {

    func tryChangeToPreferredKeyboardTypeAfterTextDidChange() {
        let shouldSwitch = services.keyboardBehavior.shouldSwitchToPreferredKeyboardTypeAfterTextDidChange()
        guard shouldSwitch else { return }
        setKeyboardType(state.keyboardContext.preferredKeyboardType)
    }

    /// Update the autocomplete context with an error.
    func updateAutocompleteContext(with error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.state.autocompleteContext.lastError = error
        }
    }
    
    /// Update the autocomplete context with new suggestions.
    func updateAutocompleteContext(
        with result: [Autocomplete.Suggestion],
        nextCharacterPredictions: [Character: Double]
    ) {
        DispatchQueue.main.async { [weak self] in
            self?.state.autocompleteContext.nextCharacterPredictions = nextCharacterPredictions
            self?.state.autocompleteContext.suggestionsFromService = result
        }
    }
    
    /// Update the last received dictation error.
    func updateLastDictationError(_ error: Error) async {
        await MainActor.run {
            state.dictationContext.lastError = error
        }
    }
}
#endif

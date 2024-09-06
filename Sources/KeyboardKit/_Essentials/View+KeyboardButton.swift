//
//  View+Buttons.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2020-06-24.
//  Copyright © 2021-2024 Daniel Saidi. All rights reserved.
//

import SwiftUI

public extension View {

    /// Bind keyboard button styles and gestures to the view.
    /// 
    /// The `edgeInsets` init parameter can be used to apply
    /// intrinsic insets within the interactable button area.
    ///
    /// > Note: ``Keyboard/Button`` view should replace this
    /// modifier and use environment values to apply various
    /// styles and features. This will most probably be done
    /// in KeyboardKit 9.0.
    ///
    /// - Parameters:
    ///   - action: The keyboard action to trigger.
    ///   - isPressed: An external pressed binding, if any.
    ///   - scrollState: The scroll state to use, if any.
    ///   - style: The keyboard style to apply.
    ///   - actionHandler: The keyboard action handler to use.
    ///   - keyboardContext: The keyboard context to use.
    ///   - calloutContext: The callout context to affect, if any.
    ///   - edgeInsets: The edge insets to apply to the interactable area, if any.
    ///   - additionalTapArea: The additional tap area in point to add outside the button, causing it to pop above other buttons, by default `0`.
    ///   - releaseOutsideTolerance: The percentage of the button size that spans outside the button and still counts as a release, by default `1`.
    ///   - repeatTimer: The repeat timer to use, if any.
    func keyboardButton(
        for action: KeyboardAction,
        isPressed: Binding<Bool> = .constant(false),
        scrollState: GestureButtonScrollState? = nil,
        style: Keyboard.ButtonStyle,
        actionHandler: KeyboardActionHandler,
        keyboardContext: KeyboardContext,
        calloutContext: CalloutContext?,
        edgeInsets: EdgeInsets = .init(),
        additionalTapArea: Double = 0,
        releaseOutsideTolerance: Double = 1,
        repeatTimer: GestureButtonTimer? = nil
    ) -> some View {
        self
            .background(Keyboard.ButtonKey())
            .keyboardButtonStyle(style)
            .foregroundColor(style.foregroundColor)
            .font(style.font)
            .padding(edgeInsets)
            .additionalTapArea(
                additionalTapArea,
                for: action,
                actionHandler: actionHandler
            )
            .keyboardButtonGestures(
                for: action,
                isPressed: isPressed,
                scrollState: scrollState,
                actionHandler: actionHandler,
                calloutContext: calloutContext,
                releaseOutsideTolerance: releaseOutsideTolerance,
                repeatTimer: repeatTimer
            )
            .localeContextMenu(
                for: action,
                context: keyboardContext,
                actionHandler: actionHandler
            )
            .keyboardButtonAccessibility(for: action)
    }

    @_disfavoredOverload
    @available(*, deprecated, message: "Use isPressed and scrollState modifier instead")
    func keyboardButton(
        for action: KeyboardAction,
        style: Keyboard.ButtonStyle,
        actionHandler: KeyboardActionHandler,
        keyboardContext: KeyboardContext,
        calloutContext: CalloutContext?,
        edgeInsets: EdgeInsets = .init(),
        isPressed: Binding<Bool> = .constant(false),
        isInScrollView: Bool = false,
        releaseOutsideTolerance: Double = 1,
        repeatTimer: GestureButtonTimer? = nil
    ) -> some View {
        self.keyboardButton(
            for: action,
            isPressed: isPressed,
            scrollState: isInScrollView ? .init() : nil,
            style: style,
            actionHandler: actionHandler,
            keyboardContext: keyboardContext,
            calloutContext: calloutContext,
            edgeInsets: edgeInsets,
            releaseOutsideTolerance: releaseOutsideTolerance,
            repeatTimer: repeatTimer
        )
    }

    /// Apply keyboard accessibility for the provided action.
    @ViewBuilder
    func keyboardButtonAccessibility(
        for action: KeyboardAction
    ) -> some View {
        if let label = action.standardAccessibilityLabel {
            self.accessibilityElement()
                .accessibilityAddTraits(.isButton)
                .accessibilityLabel(label)
        } else {
            self.accessibilityHidden(true)
        }
    }
}

private extension View {

    @ViewBuilder
    func additionalTapArea(
        _ points: Double,
        for action: KeyboardAction,
        actionHandler: KeyboardActionHandler
    ) -> some View {
        if points > 0 {
            self.zIndex(points)
                .background(
                    Color.clearInteractable
                        .opacity(0.3)
                        .padding(-points)
                        .onTapGesture {
                            actionHandler.handle(.press, on: action)
                            actionHandler.handle(.release, on: action)
                        }
                )
        } else {
            self
        }
    }

    @ViewBuilder
    func localeContextMenu(
        for action: KeyboardAction,
        context: KeyboardContext,
        actionHandler: KeyboardActionHandler
    ) -> some View {
        if shouldApplyLocaleContextMenu(for: action, context: context) {
            self.keyboardLocaleContextMenu(for: context) {
                actionHandler.handle(.release, on: action)
            }
            .id(context.locale.identifier)
        } else {
            self
        }
    }
    
    func shouldApplyLocaleContextMenu(
        for action: KeyboardAction,
        context: KeyboardContext
    ) -> Bool {
        switch action {
        case .nextLocale: true
        case .space: context.spaceLongPressBehavior == .openLocaleContextMenu
        default: false
        }
    }
}

#Preview {
    
    struct Preview: View {
        
        @State
        var isPressed = false
        
        @State
        var context: KeyboardContext = {
            let context = KeyboardContext()
            context.locales = KeyboardLocale.allCases.map { $0.locale }
            context.localePresentationLocale = KeyboardLocale.swedish.locale
            context.spaceLongPressBehavior = .openLocaleContextMenu
            return context
        }()
        
        var body: some View {
            VStack {
                VStack(spacing: 20) {
                    button(for: Text("a"), style: .preview1)
                    button(
                        for: Text("A"),
                        style: .preview2,
                        insets: .init(top: 5, leading: 10, bottom: 15, trailing: 20)
                    )
                    button(
                        for: Text(context.locale.identifier),
                        action: .nextLocale,
                        style: .preview1
                    )
                    button(for: Image.keyboardGlobe, style: .preview1)
                }
                .padding()
                .background(Color.gray.opacity(0.5))
                .cornerRadius(20)
                
                Text("\(isPressed ? "Pressed": "Not Pressed")")
            }
        }
        
        func button<Content: View>(
            for content: Content,
            action: KeyboardAction = .backspace,
            style: Keyboard.ButtonStyle,
            insets: EdgeInsets = .init()
        ) -> some View {
            content
                .padding()
                .keyboardButton(
                    for: action,
                    isPressed: $isPressed,
                    style: style,
                    actionHandler: .preview,
                    keyboardContext: context,
                    calloutContext: .preview,
                    edgeInsets: insets
                )
        }
    }

    return Preview()
}

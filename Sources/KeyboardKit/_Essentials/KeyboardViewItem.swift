//
//  KeyboardViewItem.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2020-12-02.
//  Copyright © 2020-2024 Daniel Saidi. All rights reserved.
//

import SwiftUI

/// This view renders button item for a ``KeyboardView``.
///
/// The reason why the ``KeyboardView`` doesn't just use the
/// ``Keyboard/Button`` view, is that this view applies more
/// stuff to the content.
///
/// `TODO` KeyboardKit 9.0 should change ``KeyboardView`` to
/// not use this view, but rather uses a ``Keyboard/Button``,
/// which should then apply the proper styles, insets, etc.
public struct KeyboardViewItem<Content: View>: View {

    /// Create a keyboard view item.
    ///
    /// - Parameters:
    ///   - item: The layout item to use within the item.
    ///   - isNextProbability: The probability in percent (0-1) that this button is the next to be tapped, by default `0`.
    ///   - actionHandler: The button style to apply.
    ///   - styleService: The style service to use.
    ///   - keyboardContext: The keyboard context to which the item should apply.,
    ///   - calloutContext: The callout context to affect, if any.
    ///   - keyboardWidth: The total width of the keyboard.
    ///   - inputWidth: The input width within the keyboard.
    ///   - content: The content view to use within the item.
    init(
        item: KeyboardLayout.Item,
        isNextProbability: Double = 0,
        actionHandler: KeyboardActionHandler,
        styleService: KeyboardStyleService,
        keyboardContext: KeyboardContext,
        calloutContext: CalloutContext?,
        keyboardWidth: CGFloat,
        inputWidth: CGFloat,
        content: Content
    ) {
        self.item = item
        self.isNextProbability = isNextProbability
        self.actionHandler = actionHandler
        self.styleService = styleService
        self._keyboardContext = ObservedObject(wrappedValue: keyboardContext)
        self.calloutContext = calloutContext
        self.keyboardWidth = keyboardWidth
        self.inputWidth = inputWidth
        self.content = content
    }

    @available(*, deprecated, message: "Use the style service initializer instead.")
    init(
        item: KeyboardLayout.Item,
        actionHandler: KeyboardActionHandler,
        styleProvider: KeyboardStyleProvider,
        keyboardContext: KeyboardContext,
        calloutContext: CalloutContext?,
        keyboardWidth: CGFloat,
        inputWidth: CGFloat,
        content: Content
    ) {
        self.item = item
        self.isNextProbability = 0
        self.actionHandler = actionHandler
        self.styleService = styleProvider
        self._keyboardContext = ObservedObject(wrappedValue: keyboardContext)
        self.calloutContext = calloutContext
        self.keyboardWidth = keyboardWidth
        self.inputWidth = inputWidth
        self.content = content
    }

    private let item: KeyboardLayout.Item
    private let isNextProbability: Double
    private let actionHandler: KeyboardActionHandler
    private let styleService: KeyboardStyleService
    private let calloutContext: CalloutContext?
    private let keyboardWidth: CGFloat
    private let inputWidth: CGFloat
    private let content: Content
    
    @ObservedObject
    private var keyboardContext: KeyboardContext
    
    @State
    private var isPressed = false
    
    public var body: some View {
        ZStack(alignment: item.alignment) {
            Color.clearInteractable
            content
        }
        .opacity(contentOpacity)
        .animation(.default, value: keyboardContext.isSpaceDragGestureActive)
        .keyboardLayoutItemSize(
            for: item,
            rowWidth: keyboardWidth,
            inputWidth: inputWidth
        )
        .background(Color.clearInteractable)
        .keyboardButton(
            for: item.action,
            style: buttonStyle,
            actionHandler: actionHandler,
            keyboardContext: keyboardContext,
            calloutContext: calloutContext,
            edgeInsets: item.edgeInsets,
            isPressed: $isPressed,
            additionalTapArea: isNextProbability * 5
        )
    }

    private var contentOpacity: Double {
        keyboardContext.isSpaceDragGestureActive ? 0 : 1
    }
    
    private var buttonStyle: Keyboard.ButtonStyle {
        item.action.isSpacer ? .spacer : styleService.buttonStyle(for: item.action, isPressed: isPressed)
    }
}

private extension View {
    
    @ViewBuilder
    func additionalTapArea(_ points: Double) -> some View {
        if points > 0 {
            self.zIndex(points)
                .overlay(
                    Color.clearInteractable
                        .opacity(0.3)
                        .padding(-points)
                )
        } else {
            self
        }
    }
}

#Preview {
    
    KeyboardViewItem(
        item: .init(
            action: .backspace,
            size: .init(width: .points(100), height: 100),
            alignment: .bottomLeading,
            edgeInsets: .init(horizontal: 10, vertical: 10)
        ),
        actionHandler: .preview,
        styleService: .preview,
        keyboardContext: .preview,
        calloutContext: .preview,
        keyboardWidth: 100,
        inputWidth: 100,
        content: Text("HEJ")
    )
    .background(Color.yellow)
}

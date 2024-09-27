//
//  Callouts+ActionCallout.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-01-06.
//  Copyright © 2021-2024 Daniel Saidi. All rights reserved.
//

import SwiftUI

public extension Callouts {
    
    /// This callout can show secondary actions in a callout.
    ///
    /// In iOS, this callout is presented when a button with
    /// secondary actions is long pressed.
    struct ActionCallout: View {
        
        /// Create an action callout.
        ///
        /// - Parameters:
        ///   - calloutContext: The callout context to use.
        ///   - keyboardContext: The keyboard context to use.
        ///   - emojiStyle: The emoji style to apply to the view, by default the standard style for the provided context.
        public init(
            calloutContext: CalloutContext.ActionContext,
            keyboardContext: KeyboardContext,
            emojiStyle: EmojiStyle? = nil
        ) {
            self._calloutContext = ObservedObject(wrappedValue: calloutContext)
            self._keyboardContext = ObservedObject(wrappedValue: keyboardContext)
            self.initStyle = nil
            self.emojiStyle = emojiStyle ?? EmojiStyle.standard(for: keyboardContext)
        }
        
        public typealias Context = CalloutContext.ActionContext
        public typealias EmojiStyle = EmojiKeyboardStyle
        
        @ObservedObject
        private var calloutContext: Context
        
        @ObservedObject
        private var keyboardContext: KeyboardContext
        
        private let emojiStyle: EmojiStyle
        
        @Environment(\.actionCalloutStyle)
        private var envStyle
        
        public var body: some View {
            Button(action: calloutContext.reset) {
                VStack(alignment: calloutContext.alignment, spacing: 0) {
                    callout
                    buttonArea
                }
            }
            .buttonStyle(.plain)
            .font(style.font.font)
            .compositingGroup()
            .opacity(calloutContext.isActive ? 1 : 0)
            .keyboardCalloutShadow(style: calloutStyle)
            .position(x: positionX, y: positionY)
            .offset(y: style.verticalOffset)
        }
        
        // MARK: - Deprecated
        
        @available(*, deprecated, message: "Use .actionCalloutStyle to apply the style instead.")
        public init(
            calloutContext: CalloutContext.ActionContext,
            keyboardContext: KeyboardContext,
            style: Callouts.ActionCalloutStyle,
            emojiStyle: EmojiKeyboardStyle? = nil
        ) {
            self._calloutContext = ObservedObject(wrappedValue: calloutContext)
            self._keyboardContext = ObservedObject(wrappedValue: keyboardContext)
            self.initStyle = style
            self.emojiStyle = emojiStyle ?? EmojiKeyboardStyle.standard(for: keyboardContext)
        }
        
        private typealias Style = Callouts.ActionCalloutStyle
        private let initStyle: Style?
        private var style: Style { initStyle ?? envStyle }
    }
}


// MARK: - Private Properties

private extension Callouts.ActionCallout {
    
    var backgroundColor: Color { calloutStyle.backgroundColor }

    var buttonFrame: CGRect { isEmojiCallout ? buttonFrameForEmojis : buttonFrameForCharacters }
    
    var buttonFrameSize: CGSize { buttonFrame.size }
    
    var buttonFrameForCharacters: CGRect { calloutContext.buttonFrame.insetBy(dx: buttonInset.width, dy: buttonInset.height) }
    
    var buttonFrameForEmojis: CGRect { calloutContext.buttonFrame }
    
    var buttonInset: CGSize { calloutStyle.buttonInset }
    
    var calloutActions: [KeyboardAction] { calloutContext.actions }
    
    var calloutButtonSize: CGSize {
        let frameSize = buttonFrame.size
        let widthScale = (calloutActions.count == 1) ? 1.2 : 1
        let buttonSize = CGSize(width: frameSize.width * widthScale, height: frameSize.height)
        return buttonSize.limited(to: style.maxButtonSize)
    }
    
    var calloutStyle: Callouts.CalloutStyle { style.callout }
    
    var cornerRadius: CGFloat { calloutStyle.cornerRadius }
    
    var curveSize: CGSize { calloutStyle.curveSize }
    
    var isLeading: Bool { calloutContext.isLeading }
    
    var isTrailing: Bool { calloutContext.isTrailing }

    var buttonArea: some View {
        ButtonArea(frame: buttonFrame)
            .opacity(isPad ? 0 : 1)
            .calloutStyle(calloutStyle)
            .rotation3DEffect(isTrailing ? .degrees(180) : .zero, axis: (x: 0.0, y: 1.0, z: 0.0))
    }
    
    var callout: some View {
        HStack(spacing: 0) {
            ForEach(Array(calloutActions.enumerated()), id: \.offset) {
                calloutView(for: $0.element)
                    .frame(width: calloutButtonSize.width, height: calloutButtonSize.height)
                    .background(isSelected($0.offset) ? style.selectedBackgroundColor : .clear)
                    .foregroundColor(isSelected($0.offset) ? style.selectedForegroundColor : style.callout.textColor)
                    .cornerRadius(cornerRadius)
                    .padding(.vertical, style.verticalTextPadding)
            }
        }
        .padding(.horizontal, curveSize.width)
        .background(calloutBackground)
    }
    
    var calloutBackground: some View {
        CustomRoundedRectangle(
            topLeft: cornerRadius,
            topRight: cornerRadius,
            bottomLeft: cornerRadius,
            bottomRight: cornerRadius
        )
        .foregroundColor(backgroundColor)
    }

    @ViewBuilder
    func calloutView(for action: KeyboardAction) -> some View {
        switch action {
        case .character(let char): calloutView(for: char)
        case .emoji(let emoji): calloutView(for: emoji)
        case .controlCombination(let asciiValue): calloutView(for: action.inputCalloutText ?? "")
        case .metaCombination(let asciiValue): calloutView(for: action.inputCalloutText ?? "")
        default: EmptyView()
        }
    }

    func calloutView(for character: String) -> some View {
        Text(character)
    }

    func calloutView(for emoji: Emoji) -> some View {
        Text(emoji.char)
            .font(emojiStyle.itemFont)
            .scaleEffect(emojiStyle.itemScaleFactor)
            .frame(
                width: emojiStyle.itemSize,
                height: emojiStyle.itemSize,
                alignment: .center
            )
    }
    
    var positionX: CGFloat {
        let buttonWidth = calloutButtonSize.width
        let adjustment = (CGFloat(calloutActions.count) * buttonWidth)/2
        let widthDiff = buttonWidth - buttonFrameSize.width
        let signedAdjustment = isTrailing ? -adjustment + buttonWidth - widthDiff : adjustment
        return buttonFrame.origin.x + signedAdjustment
    }
    
    var positionY: CGFloat {
        buttonFrame.origin.y - style.verticalTextPadding
    }
}


// MARK: - Private Functions

private extension Callouts.ActionCallout {
    
    var isPad: Bool {
        keyboardContext.deviceType == .pad
    }

    var isEmojiCallout: Bool {
        calloutActions.first?.isEmojiAction ?? false
    }

    func isSelected(_ offset: Int) -> Bool {
        calloutContext.selectedIndex == offset
    }
}

private extension KeyboardAction {
    
    var input: String? {
        switch self {
        case .character(let char): char
        default: nil
        }
    }
}

#Preview {

    let actionContext1 = Callouts.ActionCallout.Context(
        service: .preview,
        tapAction: { _ in }
    )

    let actionContext2 = Callouts.ActionCallout.Context(
        service: .preview,
        tapAction: { _ in }
    )

    func previewGroup<ButtonView: View>(
        view: ButtonView,
        actionContext: CalloutContext.ActionContext,
        alignment: HorizontalAlignment
    ) -> some View {
        view.overlay(
            GeometryReader { geo in
                Color.clear.onAppear {
                    actionContext.updateInputs(
                        for: .character("a"),
                        in: geo,
                        alignment: alignment
                    )
                }
            }
        )
        .keyboardActionCalloutContainer(
            calloutContext: actionContext,
            keyboardContext: .preview
        )
    }
    
    return VStack(spacing: 100) {
        previewGroup(
            view: Color.red.frame(width: 40, height: 50),
            actionContext: actionContext1,
            alignment: .leading
        )
        previewGroup(
            view: Color.yellow.frame(width: 40, height: 50),
            actionContext: actionContext2,
            alignment: .trailing
        )
    }
    .actionCalloutStyle(.init(
        // callout: .preview2,
        selectedBackgroundColor: .purple
    ))
}

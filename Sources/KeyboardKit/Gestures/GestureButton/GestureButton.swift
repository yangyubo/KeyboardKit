//
//  GestureButton.swift
//  GestureButton
//
//  Created by Daniel Saidi on 2022-11-24.
//  Copyright © 2022-2024 Daniel Saidi. All rights reserved.
//

#if os(iOS) || os(macOS) || os(watchOS)
import SwiftUI

/// This button can be used to trigger gesture-based actions.
///
/// > Important: Make sure to use ``GestureButtonScrollState``
/// if the button is within a `ScrollView`, otherwise it may
/// block the scroll view gestures in iOS 17 and earlier and
/// trigger unwanted actions in iOS 18 and later.
public struct GestureButton<Label: View>: View {
    
    /// Create a gesture button.
    ///
    /// - Parameters:
    ///   - isPressed: A custom, optional binding to track pressed state, if any.
    ///   - scrollState: The scroll state to use, if any.
    ///   - pressAction: The action to trigger when the button is pressed, if any.
    ///   - cancelDelay: The time it takes for a cancelled press to cancel itself, by default `3.0` seconds.
    ///   - releaseInsideAction: The action to trigger when the button is released inside, if any.
    ///   - releaseOutsideAction: The action to trigger when the button is released outside of its bounds, if any.
    ///   - longPressDelay: The time it takes for a press to count as a long press, by default `0.5` seconds.
    ///   - longPressAction: The action to trigger when the button is long pressed, if any.
    ///   - doubleTapTimeout: The max time between two taps for them to count as a double tap, by default `0.2` seconds.
    ///   - doubleTapAction: The action to trigger when the button is double tapped, if any.
    ///   - repeatDelay: The time it takes for a press to start a repeating action, by default `0.5` seconds.
    ///   - repeatTimer: A custom repeat timer to use for the repeating action, if any.
    ///   - repeatAction: The action to repeat while the button is being pressed, if any.
    ///   - dragStartAction: The action to trigger when a drag gesture starts, if any.
    ///   - dragAction: The action to trigger when a drag gesture changes, if any.
    ///   - dragEndAction: The action to trigger when a drag gesture ends, if any.
    ///   - endAction: The action to trigger when a button gesture ends, if any.
    ///   - label: The button label.
    public init(
        isPressed: Binding<Bool>? = nil,
        scrollState: GestureButtonScrollState? = nil,
        pressAction: Action? = nil,
        cancelDelay: TimeInterval? = nil,
        releaseInsideAction: Action? = nil,
        releaseOutsideAction: Action? = nil,
        longPressDelay: TimeInterval? = nil,
        longPressAction: Action? = nil,
        doubleTapTimeout: TimeInterval? = nil,
        doubleTapAction: Action? = nil,
        repeatDelay: TimeInterval? = nil,
        repeatTimer: GestureButtonTimer? = nil,
        repeatAction: Action? = nil,
        dragStartAction: DragAction? = nil,
        dragAction: DragAction? = nil,
        dragEndAction: DragAction? = nil,
        endAction: Action? = nil,
        label: @escaping LabelBuilder
    ) {
        self.isPressedBinding = isPressed ?? .constant(false)
        self.pressAction = pressAction
        self.cancelDelay = cancelDelay ?? GestureButtonDefaults.cancelDelay
        self.releaseInsideAction = releaseInsideAction
        self.releaseOutsideAction = releaseOutsideAction
        self.longPressDelay = longPressDelay ?? GestureButtonDefaults.longPressDelay
        self.longPressAction = longPressAction
        self.doubleTapTimeout = doubleTapTimeout ?? GestureButtonDefaults.doubleTapTimeout
        self.doubleTapAction = doubleTapAction
        self.repeatTimer = repeatTimer ?? .init()
        self.repeatDelay = repeatDelay ?? GestureButtonDefaults.repeatDelay
        self.repeatAction = repeatAction
        self.dragStartAction = dragStartAction
        self.dragAction = dragAction
        self.dragEndAction = dragEndAction
        self.endAction = endAction
        
        self.isInScrollView = scrollState != nil
        self._scrollState = .init(wrappedValue: scrollState ?? .init())
        self.label = label
    }

    public typealias Action = () -> Void
    public typealias DragAction = (DragGesture.Value) -> Void
    public typealias LabelBuilder = (_ isPressed: Bool) -> Label
    
    private let pressAction: Action?
    private let cancelDelay: TimeInterval
    private let releaseInsideAction: Action?
    private let releaseOutsideAction: Action?
    private let longPressDelay: TimeInterval
    private let longPressAction: Action?
    private let doubleTapTimeout: TimeInterval
    private let doubleTapAction: Action?
    private let repeatTimer: GestureButtonTimer
    private let repeatDelay: TimeInterval
    private let repeatAction: Action?
    private let dragStartAction: DragAction?
    private let dragAction: DragAction?
    private let dragEndAction: DragAction?
    private let endAction: Action?

    @State
    var isPressed = false {
        didSet { isPressedBinding.wrappedValue = isPressed }
    }
    
    @State
    var gestureWasStarted = false
    
    @State
    var isPressedBinding: Binding<Bool>
    
    @State
    var isRemoved = false
    
    @State
    var lastGestureValue: DragGesture.Value?
    
    @State
    var longPressDate = Date()
    
    @State
    var releaseDate = Date()
    
    @State
    var repeatDate = Date()

    @ObservedObject
    private var scrollState: GestureButtonScrollState
    
    private let isInScrollView: Bool
    private let label: LabelBuilder
    
    public var body: some View {
        if #available(iOS 18.0, macOS 15.0, watchOS 11.0, *) {
            content
        } else if isInScrollView {
            /// The `simultaneousGesture` below doesn't work
            /// in iOS 17 and `ScrollViewGestureButton` does
            /// only work in iOS 17 and earlier.
            ScrollViewGestureButton(
                isPressed: $isPressed,
                pressAction: pressAction,
                releaseInsideAction: releaseInsideAction,
                releaseOutsideAction: releaseOutsideAction,
                longPressDelay: longPressDelay,
                longPressAction: longPressAction,
                doubleTapTimeout: doubleTapTimeout,
                doubleTapAction: doubleTapAction,
                repeatAction: repeatAction,
                dragStartAction: dragStartAction,
                dragAction: dragAction,
                dragEndAction: dragEndAction,
                endAction: endAction,
                label: label
            )
        } else {
            content
        }
    }
    
    var content: some View {
        label(isPressed)
            .overlay(gestureView)
            .onDisappear { isRemoved = true }
            .accessibilityAddTraits(.isButton)
    }
}

private extension GestureButton {
    
    func gesture(
        for geo: GeometryProxy
    ) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { handleDrag($0) }
            .onEnded { handleDragEnded($0, in: geo) }
    }
    
    var gestureView: some View {
        GeometryReader { geo in
            Color.clear
                .contentShape(Rectangle())
                .simultaneousGesture(gesture(for: geo))
        }
    }
    
    func handleDrag(
        _ value: DragGesture.Value
    ) {
        if scrollState.isScrolling { return }
        if isInScrollView {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                handleDragWithState(value)
            }
        } else {
            handleDragWithState(value)
        }
    }
    
    func handleDragWithState(
        _ value: DragGesture.Value
    ) {
        lastGestureValue = value
        if scrollState.isScrolling { return }
        tryHandleDrag(value)
        if gestureWasStarted { return }
        gestureWasStarted = true
        setScrollGestureDisabledState(true)
        tryHandlePress(value)
    }
    
    func handleDragEnded(_ value: DragGesture.Value, in geo: GeometryProxy) {
        guard gestureWasStarted else { return }
        if isInScrollView {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                handleDragEndedWithState(value, in: geo)
            }
        } else {
            handleDragEndedWithState(value, in: geo)
        }
    }
    
    func handleDragEndedWithState(
        _ value: DragGesture.Value,
        in geo: GeometryProxy
    ) {
        defer { resetGestureWasStarted() }
        guard gestureWasStarted else { return }
        setScrollGestureDisabledState(false)
        tryHandleRelease(value, in: geo)
    }
    
    func resetGestureWasStarted() {
        gestureWasStarted = false
    }
    
    func setScrollGestureDisabledState(_ new: Bool) {
        if scrollState.isScrollGestureDisabled == new { return }
        scrollState.isScrollGestureDisabled = new
    }
}

private extension GestureButton {

    /// We should always reset the state when a gesture ends.
    func reset() {
        isPressed = false
        longPressDate = Date()
        repeatDate = Date()
        tryStopRepeatTimer()
    }

    /// Try to handle any new drag gestures as a press event.
    func tryHandlePress(_ value: DragGesture.Value) {
        if isPressed { return }
        isPressed = true
        pressAction?()
        dragStartAction?(value)
        tryTriggerCancelAfterDelay()
        tryTriggerLongPressAfterDelay()
        tryTriggerRepeatAfterDelay()
    }

    /// Try to handle any new drag gestures as a press event.
    func tryHandleDrag(_ value: DragGesture.Value) {
        guard isPressed else { return }
        dragAction?(value)
    }

    /// Try to handle drag end gestures as a release event.
    ///
    /// This function will trigger several actions, based on
    /// how the gesture is ended. It will always trigger the
    /// drag end and end actions, then either of the release
    /// inside or outside actions.
    func tryHandleRelease(_ value: DragGesture.Value, in geo: GeometryProxy) {
        let shouldTrigger = self.isPressed
        reset()
        guard shouldTrigger else { return }
        releaseDate = tryTriggerDoubleTap() ? .distantPast : Date()
        dragEndAction?(value)
        if geo.contains(value.location) {
            releaseInsideAction?()
        } else {
            releaseOutsideAction?()
        }
        endAction?()
    }

    /// This function tries to fix an iOS bug, where buttons
    /// may not always receive a gesture end event. This can
    /// for instance happen when the button is near a scroll
    /// view and is accidentally touched when a user scrolls.
    /// The function checks if the original gesture is still
    /// the last gesture when the cancel delay triggers, and
    /// will if so cancel the gesture. Since this will cause
    /// completely still gestures to be seen as accidentally
    /// triggered, this function can yield incorrect results
    /// and should be replaced by a proper bug fix.
    func tryTriggerCancelAfterDelay() {
        let value = lastGestureValue
        let delay = cancelDelay
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard self.lastGestureValue?.location == value?.location else { return }
            self.reset()
            self.endAction?()
        }
    }

    /// This function tries to trigger the double tap action
    /// if the current date is within the double tap timeout
    /// since the last release.
    func tryTriggerDoubleTap() -> Bool {
        let interval = Date().timeIntervalSince(releaseDate)
        let isDoubleTap = interval < doubleTapTimeout
        if isDoubleTap { doubleTapAction?() }
        return isDoubleTap
    }

    /// This function tries to trigger the long press action
    /// after the specified long press delay.
    func tryTriggerLongPressAfterDelay() {
        guard let action = longPressAction else { return }
        let date = Date()
        longPressDate = date
        let delay = longPressDelay
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if self.isRemoved { return }
            guard self.longPressDate == date else { return }
            action()
        }
    }

    /// This function tries to start a repeat action trigger
    /// timer after repeat delay.
    func tryTriggerRepeatAfterDelay() {
        let date = Date()
        repeatDate = date
        let delay = repeatDelay
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if self.isRemoved { return }
            guard self.repeatDate == date else { return }
            self.tryStartRepeatTimer()
        }
    }

    /// Try to start the repeat timer.
    func tryStartRepeatTimer() {
        guard let action = repeatAction else { return }
        if repeatTimer.isActive { return }
        repeatTimer.start {
            action()
        }
    }

    /// Try to stop the repeat timer.
    func tryStopRepeatTimer() {
        guard repeatTimer.isActive else { return }
        repeatTimer.stop()
    }
}

#Preview {
    
    struct Preview: View {

        @StateObject var state = GestureButtonPreview.State()
        @StateObject var scrollState = GestureButtonScrollState()

        var body: some View {
            GestureButtonPreview.Content(state: state) {
                GestureButton(
                    isPressed: $state.isPressed,
                    scrollState: scrollState,
                    pressAction: { state.pressCount += 1 },
                    releaseInsideAction: { state.releaseInsideCount += 1 },
                    releaseOutsideAction: { state.releaseOutsideCount += 1 },
                    longPressDelay: 0.8,
                    longPressAction: { state.longPressCount += 1 },
                    doubleTapAction: { state.doubleTapCount += 1 },
                    repeatAction: { state.repeatCount += 1 },
                    dragStartAction: { state.dragStartValue = $0.location },
                    dragAction: { state.dragChangedValue = $0.location },
                    dragEndAction: { state.dragEndValue = $0.location },
                    endAction: { state.endCount += 1 },
                    label: { GestureButtonPreview.Item(isPressed: $0) }
                )
            }
        }
    }
    
    return Preview()
}
#endif

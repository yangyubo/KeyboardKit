//
//  Gestures+KeyboardButtonGestures.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-01-10.
//  Copyright © 2021-2024 Daniel Saidi. All rights reserved.
//

#if os(iOS) || os(macOS) || os(watchOS)
import SwiftUI

extension Gestures {
    
    /// This view applies keyboard gestures to any view.
    struct KeyboardButtonGestures<Content: View>: View {
        
        init(
            view: Content,
            action: KeyboardAction?,
            isPressed: Binding<Bool>,
            scrollState: GestureButtonScrollState? = nil,
            calloutContext: CalloutContext?,
            releaseOutsideTolerance: Double? = nil,
            doubleTapAction: KeyboardGestureAction?,
            longPressAction: KeyboardGestureAction?,
            pressAction: KeyboardGestureAction?,
            releaseAction: KeyboardGestureAction?,
            repeatTimer: GestureButtonTimer? = nil,
            repeatAction: KeyboardGestureAction?,
            dragAction: KeyboardDragGestureAction?,
            endAction: KeyboardGestureAction?
        ) {
            self.view = view
            self.action = action
            self.isPressed = isPressed
            self.scrollState = scrollState
            self.calloutContext = calloutContext
            self.releaseOutsideTolerance = releaseOutsideTolerance ?? 1.0
            self.doubleTapAction = doubleTapAction
            self.longPressAction = longPressAction
            self.pressAction = pressAction
            self.releaseAction = releaseAction
            self.repeatTimer = repeatTimer
            self.repeatAction = repeatAction
            self.dragAction = dragAction
            self.endAction = endAction
        }

        private let view: Content
        private let action: KeyboardAction?
        private let isPressed: Binding<Bool>
        private let scrollState: GestureButtonScrollState?
        private let calloutContext: CalloutContext?
        private let releaseOutsideTolerance: Double
        private let doubleTapAction: KeyboardGestureAction?
        private let longPressAction: KeyboardGestureAction?
        private let pressAction: KeyboardGestureAction?
        private let releaseAction: KeyboardGestureAction?
        private let repeatTimer: GestureButtonTimer?
        private let repeatAction: KeyboardGestureAction?
        private let dragAction: KeyboardDragGestureAction?
        private let endAction: KeyboardGestureAction?
        
        @State
        private var lastDragValue: DragGesture.Value?
        
        @State
        private var shouldApplyReleaseAction = true
        
        var body: some View {
            view.overlay(
                GeometryReader { geo in
                    button(for: geo)
                }
            )
        }
    }
}


// MARK: - Views

private extension Gestures.KeyboardButtonGestures {

    /// We must define the `GestureButton` here otherwise it
    /// will conflict with the deprecated one. This can then
    /// be removed in KeyboardKit 9.0.
    @ViewBuilder
    func button(for geo: GeometryProxy) -> some View {
        GestureButton(
            isPressed: isPressed,
            scrollState: scrollState,
            pressAction: { handlePress(in: geo) },
            releaseInsideAction: { handleReleaseInside(in: geo) },
            releaseOutsideAction: { handleReleaseOutside(in: geo) },
            longPressAction: { handleLongPress(in: geo) },
            doubleTapAction: { handleDoubleTap(in: geo) },
            repeatTimer: repeatTimer,
            repeatAction: { handleRepeat(in: geo) },
            dragAction: { handleDrag(in: geo, value: $0) },
            endAction: { handleGestureEnded(in: geo) },
            label: { _ in Color.clearInteractable }
        )
    }
}


// MARK: - Actions

private extension Gestures.KeyboardButtonGestures {

    func handleDoubleTap(in geo: GeometryProxy) {
        doubleTapAction?()
    }

    func handleDrag(in geo: GeometryProxy, value: DragGesture.Value) {
        lastDragValue = value
        calloutContext?.actionContext.updateSelection(with: value.translation)
        dragAction?(value.startLocation, value.location)
    }

    func handleGestureEnded(in geo: GeometryProxy) {
        endActionCallout()
        calloutContext?.inputContext.resetWithDelay()
        calloutContext?.actionContext.reset()
        resetGestureState()
        endAction?()
    }

    func handleLongPress(in geo: GeometryProxy) {
        tryBeginActionCallout(in: geo)
        longPressAction?()
    }

    func handlePress(in geo: GeometryProxy) {
        pressAction?()
        calloutContext?.inputContext.updateInput(for: action, in: geo)
    }

    func handleReleaseInside(in geo: GeometryProxy) {
        updateShouldApplyReleaseAction()
        guard shouldApplyReleaseAction else { return }
        releaseAction?()
    }

    func handleReleaseOutside(in geo: GeometryProxy) {
        guard shouldApplyReleaseOutsize(for: geo) else { return }
        handleReleaseInside(in: geo)
    }

    func handleRepeat(in geo: GeometryProxy) {
        repeatAction?()
    }

    func tryBeginActionCallout(in geo: GeometryProxy) {
        guard let context = calloutContext?.actionContext else { return }
        context.updateInputs(for: action, in: geo)
        guard context.isActive else { return }
        calloutContext?.inputContext.reset()
    }

    func endActionCallout() {
        calloutContext?.actionContext.endDragGesture()
    }

    func resetGestureState() {
        lastDragValue = nil
        shouldApplyReleaseAction = true
    }

    func shouldApplyReleaseOutsize(for geo: GeometryProxy) -> Bool {
        guard let dragValue = lastDragValue else { return false }
        let rect = CGRect.releaseOutsideToleranceArea(for: geo, tolerance: releaseOutsideTolerance)
        let isInsideRect = rect.contains(dragValue.location)
        return isInsideRect
    }

    func updateShouldApplyReleaseAction() {
        guard let context = calloutContext?.actionContext else { return }
        shouldApplyReleaseAction = shouldApplyReleaseAction && !context.hasSelectedAction
    }
}

extension CGRect {

    /// Return a rect with release outside tolerance padding.
    static func releaseOutsideToleranceArea(
        for geo: GeometryProxy,
        tolerance: Double
    ) -> CGRect {
        let size = geo.size
        let rect = CGRect(origin: .zero, size: geo.size)
            .insetBy(dx: -size.width * tolerance, dy: -size.height * tolerance)
        return rect
    }
}
#endif

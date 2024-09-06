//
//  DemoStyleService.swift
//  Keyboard
//
//  Created by Daniel Saidi on 2022-12-21.
//  Copyright © 2022-2024 Daniel Saidi. All rights reserved.
//

#if IS_KEYBOARDKIT
import KeyboardKit
#elseif IS_KEYBOARDKITPRO
import KeyboardKitPro
#endif

import SwiftUI

/// This service inherits the standard base class then makes
/// demo-specific adjustments to the standard style.
///
/// This service will only style the rocket button, to avoid
/// making too many confusing changes. You can play with the
/// code below to see how it affects the keyboard.
class DemoStyleService: KeyboardStyle.StandardService {
    
    override func buttonFontSize(
        for action: KeyboardAction
    ) -> CGFloat {
        let base = super.buttonFontSize(for: action)
        return action.fontScaleFactor * base
    }
    
    override func buttonStyle(
        for action: KeyboardAction,
        isPressed: Bool
    ) -> Keyboard.ButtonStyle {
        let action = action.replacementAction ?? action
        return super.buttonStyle(for: action, isPressed: isPressed)
    }
    
//     override func buttonImage(for action: KeyboardAction) -> Image? {
//         switch action {
//         case .primary: Image.keyboardBrightnessUp
//         default: super.buttonImage(for: action)
//         }
//     }

//     override func buttonText(for action: KeyboardAction) -> String? {
//         switch action {
//         case .primary: "⏎"
//         case .space: "SpACe"
//         default: super.buttonText(for: action)
//         }
//     }

//    override var actionCalloutStyle: Callouts.ActionCalloutStyle {
//        var style = super.actionCalloutStyle
//        style.callout.backgroundColor = .red
//        return style
//    }

//    override var inputCalloutStyle: Callouts.InputCalloutStyle {
//        var style = super.inputCalloutStyle
//        style.callout.backgroundColor = .blue
//        style.callout.textColor = .yellow
//        return style
//    }
}

private extension KeyboardAction {
    
    var isRocket: Bool {
        switch self {
        case .character(let char): char == "🚀"
        default: false
        }
    }
    
    var fontScaleFactor: Double {
        isRocket ? 1.8 : 1
    }
    
    var replacementAction: KeyboardAction? {
        isRocket ? .primary(.continue) : nil
    }
}

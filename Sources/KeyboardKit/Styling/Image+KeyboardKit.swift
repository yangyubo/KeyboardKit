//
//  Image+KeyboardKit.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2020-03-11.
//  Copyright © 2020-2024 Daniel Saidi. All rights reserved.
//

import SwiftUI

public extension Image {
    
    static var keyboardEmoji = asset("keyboardEmoji")
    static var keyboardKit = asset("keyboardKitIcon")
    
    static var keyboard = symbol("keyboard")
    static var keyboardArrowUp = symbol("arrow.up")
    static var keyboardArrowDown = symbol("arrow.down")
    static var keyboardArrowLeft = symbol("arrow.left")
    static var keyboardArrowRight = symbol("arrow.right")
    static var keyboardAudioFeedbackDisabled = symbol("speaker")
    static var keyboardAudioFeedbackEnabled = symbol("speaker.wave.3.fill")
    static var keyboardBackspace = symbol("delete.left")
    static var keyboardBackspaceRtl = symbol("delete.right")
    static var keyboardBrightnessDown = symbol("sun.min")
    static var keyboardBrightnessUp = symbol("sun.max")
    static var keyboardCommand = symbol("command")
    static var keyboardControl = symbol("control")
    static var keyboardDictation = symbol("mic")
    static var keyboardDismiss = symbol("keyboard.chevron.compact.down")
    static var keyboardEmail = symbol("envelope")
    static var keyboardEmojiSymbol = symbol("face.smiling")
    static var keyboardGlobe = symbol("globe")
    static var keyboardHapticFeedbackDisabled = symbol("hand.tap")
    static var keyboardHapticFeedbackEnabled = symbol("hand.tap.fill")
    static var keyboardImages = symbol("photo")
    static var keyboardNewline = symbol("arrow.turn.down.left")
    static var keyboardNewlineRtl = symbol("arrow.turn.down.right")
    static var keyboardOption = symbol("option")
    static var keyboardRedo = symbol("arrow.uturn.right")
    static var keyboardSearch = symbol("magnifyingglass")
    static var keyboardSettings = symbol("gearshape")
    static var keyboardShiftCapslocked = symbol("capslock.fill")
    static var keyboardShiftCapslockInactive = symbol("capslock")
    static var keyboardShiftLowercased = symbol("shift")
    static var keyboardShiftUppercased = symbol("shift.fill")
    static var keyboardSpeaker = symbol("speaker")
    static var keyboardSpeakerDown = symbol("speaker.wave.3")
    static var keyboardSpeakerUp = symbol("speaker.wave.1")
    static var keyboardTab = symbol("arrow.right.to.line")
    static var keyboardTabRtl = symbol("arrow.left.to.line")
    static var keyboardTheme = symbol("paintpalette")
    static var keyboardUndo = symbol("arrow.uturn.left")
    static var keyboardZeroWidthSpace = symbol("circle.dotted")
    
    static func keyboardAudioFeedback(enabled: Bool) -> Image {
        enabled ? keyboardAudioFeedbackEnabled : keyboardAudioFeedbackDisabled
    }

    static func keyboardBackspace(for locale: Locale) -> Image {
        locale.isLeftToRight ? .keyboardBackspace : .keyboardBackspaceRtl
    }

    static func keyboardBackspace(for locale: KeyboardLocale) -> Image {
        keyboardBackspace(for: locale.locale)
    }

    static func keyboardHapticFeedback(enabled: Bool) -> Image {
        enabled ? keyboardHapticFeedbackEnabled : keyboardHapticFeedbackDisabled
    }

    static func keyboardNewline(for locale: Locale) -> Image {
        locale.isLeftToRight ? .keyboardNewline : .keyboardNewlineRtl
    }

    static func keyboardNewline(for locale: KeyboardLocale) -> Image {
        keyboardNewline(for: locale.locale)
    }

    static func keyboardTab(for locale: Locale) -> Image {
        locale.isLeftToRight ? .keyboardTab : .keyboardTabRtl
    }

    static func keyboardTab(for locale: KeyboardLocale) -> Image {
        keyboardTab(for: locale.locale)
    }

    static func keyboardShift(_ casing: Keyboard.Case) -> Image {
        switch casing {
        case .auto: .keyboardShiftLowercased
        case .capsLocked: .keyboardShiftCapslocked
        case .lowercased: .keyboardShiftLowercased
        case .uppercased: .keyboardShiftUppercased
        }
    }
}

extension Image {

    static func asset(_ name: String) -> Image {
        Image(name, bundle: .keyboardKit)
    }

    static func symbol(_ name: String) -> Image {
        Image(systemName: name)
    }
}

#Preview {
    
    ScrollView(.vertical) {
        VStack(spacing: 40) {
            VStack {
                Image.keyboardKit
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
                Text("KeyboardKit Icons")
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(Color.keyboardBackground)
            .clipShape(.rect(cornerRadius: 5))
            .shadow(radius: 1, y: 1)

            LazyVGrid(columns: .preview, spacing: 20) {
                Image.keyboard
                Image.keyboardArrowUp
                Image.keyboardArrowDown
                Image.keyboardArrowLeft
                Image.keyboardArrowRight
                Image.keyboardAudioFeedback(enabled: true)
                Image.keyboardAudioFeedback(enabled: false)
                Image.keyboardBackspace(for: .english)
                Image.keyboardBackspace(for: .arabic)
                Image.keyboardBackspaceRtl
                Image.keyboardBrightnessDown
                Image.keyboardBrightnessUp
                Image.keyboardCommand
                Image.keyboardControl
                Image.keyboardDictation
                Image.keyboardDismiss
                Image.keyboardEmail
                Image.keyboardEmojiSymbol
                Image.keyboardGlobe
                Image.keyboardHapticFeedback(enabled: true)
                Image.keyboardHapticFeedback(enabled: false)
                Image.keyboardImages
                Image.keyboardNewline(for: .english)
                Image.keyboardNewline(for: .arabic)
                Image.keyboardOption
                Image.keyboardRedo
                Image.keyboardSearch
                Image.keyboardSettings
                Image.keyboardShiftCapslocked
                Image.keyboardShiftCapslockInactive
                Image.keyboardShiftLowercased
                Image.keyboardShiftUppercased
                Image.keyboardSpeaker
                Image.keyboardSpeakerDown
                Image.keyboardSpeakerUp
                Image.keyboardTab(for: .english)
                Image.keyboardTab(for: .arabic)
                Image.keyboardTheme
                Image.keyboardUndo
                Image.keyboardZeroWidthSpace
                Image.keyboardEmoji
            }
        }
        .padding()
        .font(.title.weight(.regular))
    }
}

private extension Array where Element == GridItem {

    static var preview: Self {
        [.init(.adaptive(minimum: 40, maximum: 50), spacing: 20)]
    }
}

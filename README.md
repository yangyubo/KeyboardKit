<p align="center">
    <img src ="Resources/Logo_GitHub.png" alt="KeyboardKit Logo" title="KeyboardKit" />
</p>

<p align="center">
    <img src="https://img.shields.io/github/v/release/KeyboardKit/KeyboardKit?color=%2300550&sort=semver" alt="Version" />
    <img src="https://img.shields.io/badge/swift-5.9-orange.svg" alt="Swift 5.9" />
    <img src="https://img.shields.io/badge/platform-SwiftUI-blue.svg" alt="Swift UI" title="Swift UI" />
    <img src="https://img.shields.io/github/license/KeyboardKit/KeyboardKit" alt="MIT License" />
    <a href="https://twitter.com/getkeyboardkit"><img src="https://img.shields.io/twitter/url?label=Twitter&style=social&url=https%3A%2F%2Ftwitter.com%2Fgetkeyboardkit" alt="Twitter: @@getkeyboardkit" title="Twitter: @getkeyboardkit" /></a>
    <a href="https://techhub.social/@keyboardkit"><img src="https://img.shields.io/mastodon/follow/109340839247880048?domain=https%3A%2F%2Ftechhub.social&style=social" alt="Mastodon: @keyboardkit@techhub.social" title="Mastodon: @keyboardkit@techhub.social" /></a>
</p>



## About KeyboardKit

KeyboardKit is a SwiftUI SDK that lets you create fully customizable [keyboard extensions][About] with a few lines of code.

KeyboardKit extends Apple's limited keyboard APIs, extends the input controller and proxy with more capabilities, and provides you with additional functionality, states and views, to let you build an outstanding, custom keyboards.

<p align="center">
    <img src ="Resources/Demo.gif" width=450 />
</p>

KeyboardKit is open-source and completely free. It can be extended with [KeyboardKit Pro][Pro] to unlock Pro features, like localized keyboards, autocomplete & autocorrect, AI support, an emoji keyboard, themes, dictation, and more.



## Installation

KeyboardKit can be installed with the Swift Package Manager:

```
https://github.com/KeyboardKit/KeyboardKit.git
```

After installing KeyboardKit, make sure to link it to all targets that need it.



## Getting Started

To use KeyboardKit in a keyboard extension, just import `KeyboardKit` and let your `KeyboardViewController` inherit ``KeyboardInputViewController`` instead of `UIInputViewController`:

```swift
import KeyboardKit

class KeyboardController: KeyboardInputViewController {}
```

This gives you access to lifecycle functions like `viewWillSetupKeyboardView`, observable state, services, etc.

The easiest way to set up KeyboardKit is to use create a `KeyboardApp` value to define information for your app:

```swift
extension KeyboardApp {

    static var keyboardKitDemo: Self {
        .init(
            name: "KeyboardKit",
            licenseKey: "keyboardkitpro-license-key",
            bundleId: "com.keyboardkit.demo",
            appGroupId: "group.com.keyboardkit.demo",
            deepLinks: .init(app: "kkdemo://")
        )
    }
}
```  

To set up your keyboard, just override `viewDidLoad` and call `setup(for:)` with your `KeyboardApp`:

```swift
class KeyboardViewController: KeyboardInputViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setup(for: .keyboardKitDemo)
    }
}
```

This will make `KeyboardSettings` sync data between the main app and its keyboard if an ``appGroupId`` is defined, register a KeyboardKit Pro license if a ``licenseKey`` is defined, set up dictation, deep links, etc.

To replace or customize the standard, English `KeyboardView`, just override `viewWillSetupKeyboardView` and call `setupKeyboardView` with the view you want to use:

```swift
class KeyboardViewController: KeyboardInputViewController {

    override func viewWillSetupKeyboardView() {
        super.viewWillSetupKeyboardView()
        setupKeyboardView { [weak self] controller in // <-- Use weak or unknowned self!
            KeyboardView(
                state: controller.state,
                services: controller.services,
                buttonContent: { $0.view },
                buttonView: { $0.view },
                emojiKeyboard: { $0.view },
                toolbar: { _ in MyCustomToolbar() }
            )
        }
    }
}
```

To set up the main app with the same configuration as the keyboard extension, just wrap the main content view in a `KeyboardAppView` and provide it with the same app information:

```swift
import SwiftUI
import KeyboardKit

@main
struct MyApp: App {

    var body: some Scene {
        WindowGroup {
            KeyboardAppView(for: .keyboardKitDemo) {
                ContentView()
            }
        }
    }
}
```

This will make `KeyboardSettings` sync data between the main app and its keyboard if an ``appGroupId`` is defined, register a KeyboardKit Pro license if a ``licenseKey`` is defined, set up dictation, deep links, etc.

For more information, please see the [getting started guide][Getting-Started].



## Localization

KeyboardKit supports [68 keyboard-specific locales][Localization]:

🇦🇱 🇦🇪 🇦🇲 🇧🇾 🇧🇬 🇦🇩 🏳️ 🇭🇷 🇨🇿 🇩🇰 <br />
🇳🇱 🇧🇪 🇺🇸 🇬🇧 🇺🇸 🇪🇪 🇫🇴 🇵🇭 🇫🇮 🇫🇷 <br />
🇨🇦 🇧🇪 🇨🇭 🇬🇪 🇩🇪 🇦🇹 🇨🇭 🇬🇷 🇺🇸 🇮🇱 <br />
🇭🇺 🇮🇸 🏳️ 🇮🇩 🇮🇪 🇮🇹 🇰🇿 🇹🇯 🇹🇯 🇹🇯 <br />
🇱🇻 🇱🇹 🇲🇰 🇲🇾 🇲🇹 🇲🇳 🏳️ 🇳🇴 🇳🇴 🇮🇷 <br />
🇵🇱 🇵🇹 🇧🇷 🇷🇴 🇷🇺 🇷🇸 🇷🇸 🇸🇰 🇸🇮 🇪🇸 <br />
🇦🇷 🇲🇽 🇰🇪 🇸🇪 🇹🇷 🇺🇦 🇺🇿 🏴󠁧󠁢󠁷󠁬󠁳󠁿 <br />

KeyboardKit only includes localized strings, while [KeyboardKit Pro][Pro] unlocks localized keyboards, layouts, callouts and behaviors for all supported locales.



## Features

KeyboardKit is packed with features to help you build amazing custom keyboards:

* ⌨️ [Essentials][Essentials] - Essential keyboard utilities, models, services & views.
* 💥 [Actions][Actions] - Trigger & handle keyboard-related actions.
* 📱 [App][App] - Define and set up your app, settings, etc.
* 💡 [Autocomplete][Autocomplete] - Perform autocomplete as the user types.
* 🗯 [Callouts][Callouts] - Show input & secondary action callouts.
* 🖥️ [Device][Device] - Identify device type, device capabilities, etc.
* 😀 [Emojis][Emojis] - Emojis, categories, versions, skin tones, etc.
* 🔉 [Feedback][Feedback] - Trigger audio & haptic feedback with ease.
* 👆 [Gestures][Gestures] - Handle a rich set of gestures on any key.
* 🏠 [Host][Host] - Identify the host application.
* 🔣 [Layout][Layout] - Define and customize dynamic keyboard layouts.
* 🌐 [Localization][Localization] - Localize your keyboard in **68+ locales**.
* 🗺️ [Navigation][Navigation] - Open urls and other apps from the keyboard.
* 👁 [Previews][Previews] - Extensive SwiftUI preview support.
* ➡️ [Proxy][Proxy] - Extend the text document proxy with more capabilities.
* ⚙️ [Settings][Settings] - Provide keyboard settings & link to System Settings.
* 🩺 [Status][Status] - Detect if a keyboard is enabled, has full access, etc.
* 🎨 [Styling][Styling] - Style your keyboard to great extent.



## 👑 Pro Features

[KeyboardKit Pro][Pro] extends KeyboardKit with Pro features:

* ⌨️ [Essentials][Essentials] - More essential tools, keyboard previews, etc.
* 🤖 [AI][AI] - Features that are needed for AI.
* 📱 [App][App] - App-specific screens & views.
* 💡 [Autocomplete][Autocomplete] - On-device & remote autocomplete.
* 🗯 [Callouts][Callouts] - Localized callouts for **68 locales**.
* 🎤 [Dictation][Dictation] - Trigger dictation from the keyboard.
* 😀 [Emojis][Emojis] - A powerful emoji keyboard.
* ⌨️ [External][External] - Detect if an external keyboard is connected. 
* 🏠 [Host][Host] - Identify and open specific host applications.
* 🔣 [Layout][Layout] - Localized layouts for **68 locales**.
* 🌐 [Localization][Localization] - Services & views for **68 locales**.
* 👁 [Previews][Previews] - Keyboard & theme previews for in-app use.
* ➡️ [Proxy][Proxy] - Let `UITextDocumentProxy` read the full document.
* 📝 [Text][Text-Input] - Let users type within the keyboard.
* 🍭 [Themes][Themes] - A theme engine with many pre-defined themes.



## Documentation

The [online documentation][Documentation] has more information, getting-started guides, articles, code examples, etc.

> [!NOTE]
> The documentation is updated for KeyboardKit 8.9. This also adjusts it for Xcode 16, which makes native type extension links fail to resolve for GitHub Actions, which currently uses Xcode 15.



## Demo App

The `Demo` folder has a demo app that shows how to set up the main keyboard app, show keyboard status, provide in-app settings, link to system settings, apply custom styles, etc. 

The app has two keyboards - a `Keyboard` that uses KeyboardKit and a `KeyboardPro` that uses KeyboardKit Pro. Note that you need to enable Full Access for some features to work, like haptic feedback.

> [!IMPORTANT]
> The demo isn't code signed, and can therefore not sync settings between the app and its keyboards. As such, the `KeyboardPro` keyboard has the same settings screens to provide in-keyboard settings.



## KeyboardKit App

If you want to try KeyboardKit without having to write any code or build the demo app from Xcode, the [KeyboardKit app][KeyboardKit-App] lets you try out many features by just downloading it from the App Store.



## Support This Project

KeyboardKit is open-source and completely free, but you can support the project by becoming a [GitHub Sponsor][Sponsors], upgrading to [KeyboardKit Pro][Pro] or [get in touch][Email] for freelance work, paid support etc.



## Contact

Feel free to reach out if you have questions or if you want to contribute in any way:

* Website: [keyboardkit.com][Website]
* Mastodon: [@keyboardkit@techhub.social][Mastodon]
* Twitter: [@getkeyboardkit][Twitter]
* E-mail: [info@keyboardkit.com][Email]



## License

KeyboardKit is available under the MIT license. See the [LICENSE][License] file for more info.



[Email]: mailto:info@keyboardkit.com
[Website]: https://keyboardkit.com
[Twitter]: http://twitter.com/getkeyboardkit
[Mastodon]: https://techhub.social/@keyboardkit
[Sponsors]: https://github.com/sponsors/danielsaidi

[About]: https://keyboardkit.com/about

[KeyboardKit]: https://github.com/KeyboardKit/KeyboardKit
[KeyboardKit-App]: https://keyboardkit.com/app
[Pro]: https://github.com/KeyboardKit/KeyboardKitPro
[Gumroad]: https://kankoda.gumroad.com
[License]: https://github.com/KeyboardKit/KeyboardKit/blob/master/LICENSE

[Documentation]: https://keyboardkit.github.io/KeyboardKit/
[Getting-Started]: https://keyboardkit.github.io/KeyboardKit/documentation/keyboardkit/getting-started-article
[Essentials]: https://keyboardkit.github.io/KeyboardKit/documentation/keyboardkit/essentials-article

[Actions]: https://keyboardkit.github.io/KeyboardKit/documentation/keyboardkit/actions-article
[AI]: https://keyboardkit.github.io/KeyboardKit/documentation/keyboardkit/ai-article
[App]: https://keyboardkit.github.io/KeyboardKit/documentation/keyboardkit/app-article
[Autocomplete]: https://keyboardkit.github.io/KeyboardKit/documentation/keyboardkit/autocomplete-article
[Buttons]: https://keyboardkit.github.io/KeyboardKit/documentation/keyboardkit/buttons-article
[Callouts]: https://keyboardkit.github.io/KeyboardKit/documentation/keyboardkit/callouts-article
[Device]: https://keyboardkit.github.io/KeyboardKit/documentation/keyboardkit/device-article
[Dictation]: https://keyboardkit.github.io/KeyboardKit/documentation/keyboardkit/dictation-article
[Emojis]: https://keyboardkit.github.io/KeyboardKit/documentation/keyboardkit/emojis-article
[External]: https://keyboardkit.github.io/KeyboardKit/documentation/keyboardkit/external-keyboards-article
[Feedback]: https://keyboardkit.github.io/KeyboardKit/documentation/keyboardkit/feedback-article
[Gestures]: https://keyboardkit.github.io/KeyboardKit/documentation/keyboardkit/gestures-article
[Host]: https://keyboardkit.github.io/KeyboardKit/documentation/keyboardkit/host-article
[Layout]: https://keyboardkit.github.io/KeyboardKit/documentation/keyboardkit/layout-article
[Localization]: https://keyboardkit.github.io/KeyboardKit/documentation/keyboardkit/localization-article
[Navigation]: https://keyboardkit.github.io/KeyboardKit/documentation/keyboardkit/navigation-article
[Previews]: https://keyboardkit.github.io/KeyboardKit/documentation/keyboardkit/previews-article
[Proxy]: https://keyboardkit.github.io/KeyboardKit/documentation/keyboardkit/proxy-article
[Settings]: https://keyboardkit.github.io/KeyboardKit/documentation/keyboardkit/settings-article
[Status]: https://keyboardkit.github.io/KeyboardKit/documentation/keyboardkit/status-article
[Styling]: https://keyboardkit.github.io/KeyboardKit/documentation/keyboardkit/styling-article
[Text-Input]: https://keyboardkit.github.io/KeyboardKit/documentation/keyboardkit/text-input-article
[Themes]: https://keyboardkit.github.io/KeyboardKit/documentation/keyboardkit/themes-article

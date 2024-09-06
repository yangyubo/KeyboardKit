# App

This article describes the KeyboardKit app-specific utilities.

@Metadata {

    @PageImage(
        purpose: card,
        source: "Page",
        alt: "Page icon"
    )

    @PageColor(blue)
}

KeyboardKit provides many utilities for the main app target, that simplify building a great keyboard app, like setting up settings that sync between the app and the keyboard, auto-registering your KeyboardKit Pro license, and much more.   

👑 [KeyboardKit Pro][Pro] unlocks app screens for the main app target. Information about Pro features can be found at the end of this article.



## Keyboard App Namespace

KeyboardKit has a ``KeyboardApp`` struct that is also a namespace for app-related types and views, like the ``KeyboardApp/HomeScreen``, ``KeyboardApp/SettingsScreen`` and ``KeyboardApp/LocaleScreen`` components that can be unlocked with KeyboardKit Pro.



## Keyboard App

The ``KeyboardApp`` type can be used to define important properties for your app, such as ``KeyboardApp/name``, ``KeyboardApp/licenseKey`` (for KeyboardKit Pro), ``KeyboardApp/bundleId`` (for keyboard status inspection), ``KeyboardApp/appGroupId`` (sync data between the app and keyboard), ``KeyboardApp/deepLinks-swift.property``, etc:

```swift
extension KeyboardApp {

    static var keyboardKitDemo: Self {
        .init(
            name: "KeyboardKit",
            licenseKey: "abc123",
            bundleId: "com.keyboardkit.demo",
            appDeepLink: "kkdemo://",
            appGroupId: "group.com.keyboardkit.demo",
            locales: [.english, .swedish, .persian]
        )
    }
}
```

The app will apply default values to things you don't provide. For instance, ``KeyboardApp/keyboardExtensionBundleId`` appends `/keyboard` to ``KeyboardApp/bundleId`` if you don't provide one. The app can also derive things like ``KeyboardApp/dictationConfiguration``.

> Important: The ``KeyboardApp``'s ``KeyboardApp/locales`` collection is only meant to describe which locales you *want* to use in your app and keyboard. It will be capped to the number of locales that your KeyboardKit Pro license includes.



### How to set up the keyboard extension with a keyboard app 

The ``KeyboardInputViewController`` has ``KeyboardApp``-based setup functions that will set up ``KeyboardSettings`` with an App Group, register your KeyboardKit Pro license key, etc.

```swift
class KeyboardController: UIInputViewController {

    func viewWillSetupKeyboard() {
        super.viewWillSetupKeyboard()
        setup(for: .keyboardKitDemo) {
            // Define your view here...
        }
    }
}
```

### How to set up the main app with a keyboard app

The main app can use a ``KeyboardAppView`` view as the root view of a keyboard app target, to set up everything it needs:

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            KeyboardAppView(for: .myApp) {
                ContentView()
            }
        }
    }
}
```

You keyboard and main app will set up anything that the keyboard app defines, which means that you don't have to configure things like App Group syncing, dictation, deep links, etc. Just define them in your ``KeyboardApp`` and KeyboardKit takes care of the rest.


## 👑 KeyboardKit Pro

[KeyboardKit Pro][Pro] unlocks screens in the ``KeyboardApp`` namespace, to let you quickly add keyboard-related features to your main app.

[Pro]: https://github.com/KeyboardKit/KeyboardKitPro

@TabNavigator {
    
    @Tab("HomeScreen") {
        The ``KeyboardApp``.``KeyboardApp/HomeScreen`` can be used as the home screen of a keyboard app. It shows an app icon header, a keyboard status section, settings links, and custom header and footer content. All links and options can be hidden, styled and localized to fit your needs. 
    
        ![KeyboardApp.HomeScreen](keyboardapp-homescreen)
    }
    
    @Tab("LocaleScreen") {
        The ``KeyboardApp``.``KeyboardApp/LocaleScreen`` can be used as the main language settings screen. It lists all added and available locales and lets users add and reorganize the locales that is used by the keyboard. It automatically syncs with the ``KeyboardContext``.
    
        ![KeyboardApp.SettingsScreen](keyboardapp-localescreen)
    }
    
    @Tab("SettingsScreen") {
        The ``KeyboardApp``.``KeyboardApp/SettingsScreen`` can be used as the main keyboard settings screen. It renders a bunch of settings to let users configure their keyboard configuration, and automatically syncs with all injected contexts.
    
        ![KeyboardApp.SettingsScreen](keyboardapp-settingsscreen)
    }
    
    @Tab("ThemeScreen") {
        The ``KeyboardApp``.``KeyboardApp/ThemeScreen`` can be used as the main theme picker screen. It renders a list of theme shelves and automatically sets the main ``KeyboardThemeContext/theme``, which can then be applied with a   ``KeyboardStyle/ThemeBasedService`` style service.
    
        ![KeyboardApp.SettingsScreen](keyboardapp-themescreen)
    }
}

Check out the type documentation in the KeyboardKit Pro documentation, or the demo app for some examples on how to use this view.

> Important: Note that for settings to sync between the main app and the keyboard extension, you must replace ``KeyboardSettings/store`` with an App Group-based store. You can use the ``KeyboardAppView`` to do this in the main app, and call  ``KeyboardSettings/setupStore(withAppGroup:keyPrefix:)`` when the keyboard launches.

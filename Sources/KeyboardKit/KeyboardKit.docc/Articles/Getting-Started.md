# Getting Started

This article describes how to get started with KeyboardKit.

@Metadata {

    @PageImage(
        purpose: card,
        source: "Page",
        alt: "Page icon"
    )

    @PageColor(blue)
}


This article describes how to get started with KeyboardKit and KeyboardKit Pro. Each section will first show you how to do something for KeyboardKit, then for KeyboardKit Pro.



## How to use KeyboardKit

Keyboard extensions can use KeyboardKit to create custom keyboards, while the main app can use it to check keyboard state, provide keyboard-specific settings, link to System Settings, etc.



## How to define your app's information

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

You can read more about this type and other app-specific screens and utilities in the <doc:App-Article> article.



## How to set up KeyboardKit in a keyboard extension

To set up KeyboardKit in a keyboard extension, import KeyboardKit and let the controller inherit ``KeyboardInputViewController``:

```swift
import KeyboardKit // or KeyboardKitPro

class KeyboardController: KeyboardInputViewController {}
```

This gives you access to lifecycle functions like ``KeyboardInputViewController/viewWillSetupKeyboard()``, observable ``KeyboardInputViewController/state``, keyboard ``KeyboardInputViewController/services``, and more, and will by default render a ``KeyboardView`` that looks and behaves a native iOS keyboard.

KeyboardKit and KeyboardKit Pro has slightly different ways to set up the keyboard extension, since KeyboardKit lets you do a lot more:

@TabNavigator {
    
    @Tab("KeyboardKit") {
        
        To customize or replace the ``KeyboardView``,  just override ``KeyboardInputViewController/viewWillSetupKeyboard()`` and call any setup function, for instance:

        ```swift
        class KeyboardViewController: KeyboardInputViewController {

            override func viewWillSetupKeyboard() {
                super.viewWillSetupKeyboard()
                setup(for: .myApp) { [weak self] controller in
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
    }
    
    @Tab("👑 KeyboardKit Pro") {
        
        To use KeyboardKit Pro with the default ``KeyboardView``, just call `setupPro` in `viewDidLoad` without specifying a view:

        ```swift
        import KeyboardKitPro

        class KeyboardViewController: KeyboardInputViewController {

            func viewDidLoad() {
                super.viewDidLoad()

                // With a KeyboardApp
                setupPro(
                    for: .myApp, // Your app-specific KeyboardApp value
                    licenseError: { error in } // Called if the license validation fails.
                    licenseConfiguration: { license in } // Called if the license validation succeeds.
                )

                // With raw properties
                setupPro(
                    withLicenseKey: "your-license-key",
                    locales: [...], // Define which locales to use (for Basic & Silver)  
                    licenseError: { error in } // Called if the license validation fails.
                    licenseConfiguration: { license in } // Called if the license validation succeeds.
                )
            }
        }
        ```

        To use a customized ``KeyboardView`` or a custom keyboard view, just call `setupPro` with a view in ``KeyboardInputViewController/viewWillSetupKeyboard()``.        
    }
}

> Tip: If you use a ``KeyboardApp`` setup function, KeyboardKit will set up App Group syncing, register your KeyboardKit Pro license, etc.

> Warning: A VERY important thing to consider, is that the view builders provide you with an UNOWNED controller reference, since referring to self can cause a memory leak. However, since it's a ``KeyboardInputViewController``, you must use `self` to refer to your specific controller. If so, you MUST use `[weak self]` or `[unowned self]`, otherwise the reference will cause a memory leak.

> 👑 KeyboardKit Pro: Since Basic, Silver, & monthly Gold licenses validate licenses over the Internet, your keyboard extension must enable Full Access to be able to make network requests. Yearly Gold and custom licenses are validated on-device, and don't need Full Access.


## How to set up KeyboardKit for an app

The main app target can use KeyboardKit to show and manage the keyboard's enabled and Full Access status, provide <doc:Settings-Article>, etc. It's a great place for app settings and configurations, since it has more space.

You can use a ``KeyboardAppView`` as root view to automatically set up App Group data syncing (read more in <doc:Settings-Article>), register your KeyboardKit Pro license key (if any) and set up other pro features, like <doc:Dictation>:

```swift
struct MyApp: App {

    var body: some Scene {
        WindowGroup {
            KeyboardAppView(for: .myApp)
        }
    }
}
```

Without a ``KeyboardAppView``, you must manually set up ``KeyboardSettings``, ``License/register(licenseKey:_:)`` a license key, etc. 




## How to set up KeyboardKit as a package dependency

To use KeyboardKit as a package dependency, just add it to the package's dependencies and link it to any targets that need it, just like you would do with any other package.

Since KeyboardKit Pro is a binary target, it requires some special configurations to be used as a package dependency. You don't have to link to KeyboardKit Pro from any target, but *must* update **runpath search paths** under **Build Settings**:

* For the main app, set it to **@executable_path/Frameworks**.
* For the keyboard, set it to **@executable_path/../../Frameworks**.

Failing to set the search paths will cause a runtime crash when you try to use KeyboardKit Pro.  



## How to use keyboard state & services

The main ``KeyboardInputViewController`` provides you with keyboard ``KeyboardInputViewController/state`` and ``KeyboardInputViewController/services``, to let you build great keyboards. 

### State

KeyboardKit injects observable state into the view hierarchy as environment objects, which lets you access the various types like this:

```swift
struct CustomKeyboard: View {

    @EnvironmentObject
    private var context: KeyboardContext

    var body: some View {
        ...
    }
}
```

The observable state types let you configure the keyboard and its features. They provide both observable and auto-persisted values.

### Services

Services are not injected into the view hierarchy, and must be passed around. KeyboardKit uses init injection for both state and services. Examples of services are the ``KeyboardActionHandler`` which handles ``KeyboardAction``s, ``FeedbackService``, etc.

You can replace any services with custom implementations. For instance, here we replace the standard ``KeyboardActionHandler``:

```swift
class KeyboardViewController: KeyboardInputViewController {

    override func viewDidLoad() {
        services.actionHandler = CustomActionHandler(
            inputViewController: self
        )
        super.viewDidLoad()
    }
}

class CustomActionHandler: StandardActionHandler {

    open override func handle(_ action: KeyboardAction) {
        if action == .space {
            print("Pressed space!")
        }
        super.handle(gesture, on: action) 
    }
}
```

Since services are lazy and resolved when they're used the first time, you should set up any service customizations as early as possible.



## Going further

You should now have a basic understanding of how to set up KeyboardKit and KeyboardKit Pro. For more information & examples, see the <doc:Essentials> article, as well as the other articles. Also, take a look at the demo app.



[KeyboardKit]: https://github.com/KeyboardKit/KeyboardKit
[KeyboardKitPro]: https://github.com/KeyboardKit/KeyboardKitPro

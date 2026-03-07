# AppleGrab

`AppleGrab` is a debug-only AppKit/UIKit inspection SDK for apps you build yourself.

It is designed for Codex workflows:

- install it as a Swift Package
- add one debug-only install call to your app window
- click `Inspect`
- click a view
- copy a Codex-ready prompt or export JSON

## Install

Add this package from GitHub in Xcode or from `Package.swift`:

```swift
.package(url: "https://github.com/jaymutzafi/Flutter-Grab.git", branch: "main")
```

Then depend on the `AppleGrab` product.

## AppKit usage

```swift
import AppKit
import AppleGrab

final class AppDelegate: NSObject, NSApplicationDelegate {
    var controller: AppleGrabController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            controller = AppleGrab.install(on: window)
        }
    }
}
```

## UIKit usage

```swift
import UIKit
import AppleGrab

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var grabController: AppleGrabController?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let window else { return }
        grabController = AppleGrab.install(on: window)
    }
}
```

## Tag important views

```swift
heroCardView.appleGrabTag = AppleGrabTag(
    name: "hero-card",
    description: "Primary dashboard card",
    tags: ["marketing", "homepage"]
)
```

## Notes

- This SDK is for your own debug builds, not arbitrary third-party apps.
- AppKit gets hover + click selection.
- UIKit gets tap selection.
- Clipboard-first is the primary Codex flow.

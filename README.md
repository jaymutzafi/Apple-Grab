# Apple Grab

`AppleGrab` is a debug-only inspection SDK for **macOS AppKit** apps and **iOS UIKit** apps you build yourself.

It is designed for Codex workflows:

- add it as a Swift Package
- install it in your app window
- see an obvious active banner
- enter inspect mode
- click a view
- copy a Codex-ready prompt or export JSON

The repo is now intentionally **Apple-only**. The earlier Flutter packages were moved into a local ignored archive and are not part of the GitHub-facing project anymore.

## What this repo contains

- [Package.swift](/Users/jaymutzafi/Library/Mobile%20Documents/com~apple~CloudDocs/Projects/Flutter%20Grab/Package.swift)
- [packages/apple_grab_sdk](/Users/jaymutzafi/Library/Mobile%20Documents/com~apple~CloudDocs/Projects/Flutter%20Grab/packages/apple_grab_sdk)
- [docs/codex_install_workflow.md](/Users/jaymutzafi/Library/Mobile%20Documents/com~apple~CloudDocs/Projects/Flutter%20Grab/docs/codex_install_workflow.md)

## Installation

The **repo root** is a Swift Package exposing the `AppleGrab` product.

That means you can install it from:

- GitHub URL
- a zip of this repo
- the local folder path to this repo

### Xcode

Use `File > Add Package Dependencies...` and provide either:

- `https://github.com/jaymutzafi/Apple-Grab.git`
- or a local path to this repo folder

Then add the `AppleGrab` product to your app target.

### Package.swift

```swift
.package(url: "https://github.com/jaymutzafi/Apple-Grab.git", branch: "main")
```

Then depend on:

```swift
.product(name: "AppleGrab", package: "AppleGrabKit")
```

If you install it from a local path instead:

```swift
.package(path: "/path/to/Apple-Grab")
```

## AppKit usage

```swift
import AppKit
import AppleGrab

final class AppDelegate: NSObject, NSApplicationDelegate {
    var appleGrab: AppleGrabController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            appleGrab = AppleGrab.install(on: window)
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
    var appleGrab: AppleGrabController?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let window else { return }
        appleGrab = AppleGrab.install(on: window)
    }
}
```

## What you get at runtime

- debug boot log
- yellow active banner
- built-in doctor panel
- inspect toggle
- AppKit hover + click selection
- UIKit tap selection
- clipboard-first Codex export
- optional JSON export if you set an export URL

## Tag important views

```swift
heroCardView.appleGrabTag = AppleGrabTag(
    name: "hero-card",
    description: "Primary dashboard card",
    tags: ["marketing", "homepage"]
)
```

## Codex workflow

If you want Codex to add this to another app for you, use the install workflow here:

- [docs/codex_install_workflow.md](/Users/jaymutzafi/Library/Mobile%20Documents/com~apple~CloudDocs/Projects/Flutter%20Grab/docs/codex_install_workflow.md)

The short version:

```text
Install AppleGrab into this app from:
SOURCE_HERE

Add it as a Swift Package dependency, wire it into the app lifecycle, and verify that the active banner and doctor surface work.
If direct package install is not appropriate for this project, vendor it into the repo and wire it locally.
```

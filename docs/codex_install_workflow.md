# Codex install workflow for AppleGrab

This document defines the simplest repeatable way to install `AppleGrab` into another project through Codex.

## Goal

You should be able to give Codex one of these:

- a GitHub URL
- a zip file
- a local folder path

and say “install AppleGrab into this app”, without needing to explain package wiring each time.

## Rule

For `AppleGrab`, Codex should:

1. try direct Swift Package installation from the source you gave it
2. wire the app lifecycle automatically
3. verify the banner and doctor surface

If direct installation is not appropriate for the target project, Codex should:

1. vendor a local copy into the target repo
2. wire the app to that local copy
3. verify the integration

## Accepted source formats

### GitHub URL

Example:

```text
https://github.com/jaymutzafi/Apple-Grab.git
```

Codex should add that repo as a Swift Package dependency and attach the `AppleGrab` product.

### Zip file

Example:

```text
/Users/you/Downloads/Apple-Grab-main.zip
```

Codex should unpack it, then add the unpacked repo root as a local Swift Package dependency.

### Local folder path

Example:

```text
/Users/jaymutzafi/Library/Mobile Documents/com~apple~CloudDocs/Projects/Flutter Grab
```

Codex should add the repo root as a local Swift Package dependency.

## Xcode project app

If the target app is an `.xcodeproj` app, Codex should:

- for a GitHub URL:
  - add the repo as a remote Swift package dependency
  - attach the `AppleGrab` product to the app target
- for a zip or folder path:
  - add it as a local Swift package dependency
  - attach the `AppleGrab` product to the app target
- if vendoring is requested:
  - copy it into `Packages/AppleGrab`
  - add that local Swift package dependency
  - attach the `AppleGrab` product to the app target

## Swift Package app

If the target app already uses `Package.swift`, Codex should:

- for a GitHub URL:

```swift
.package(url: "https://github.com/jaymutzafi/Apple-Grab.git", branch: "main")
```

- for a local folder path or unpacked zip:

```swift
.package(path: "/path/to/Apple-Grab")
```

- then add the target dependency:

```swift
.product(name: "AppleGrab", package: "AppleGrabKit")
```

## Code Codex should add

### AppKit

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

### UIKit

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

## What Codex should verify

- package dependency resolves
- app builds
- debug boot log appears
- active banner appears
- doctor panel confirms overlay is mounted
- inspect mode can be toggled

## Recommended user prompt

Use this exact style of request in another project:

```text
Install AppleGrab into this app from:
SOURCE_HERE

Add it as a Swift Package dependency, wire it into the app lifecycle, and verify that the active banner and doctor surface work.
If direct package install is not appropriate for this project, vendor it into the repo and wire it locally.
```

Examples:

```text
Install AppleGrab into this app from:
https://github.com/jaymutzafi/Apple-Grab.git

Add it as a Swift Package dependency, wire it into the app lifecycle, and verify that the active banner and doctor surface work.
If direct package install is not appropriate for this project, vendor it into the repo and wire it locally.
```

```text
Install AppleGrab into this app from:
/Users/jaymutzafi/Downloads/Apple-Grab-main.zip

Add it as a Swift Package dependency, wire it into the app lifecycle, and verify that the active banner and doctor surface work.
If direct package install is not appropriate for this project, vendor it into the repo and wire it locally.
```

```text
Install AppleGrab into this app from:
/Users/jaymutzafi/Library/Mobile Documents/com~apple~CloudDocs/Projects/Flutter Grab

Add it as a Swift Package dependency, wire it into the app lifecycle, and verify that the active banner and doctor surface work.
If direct package install is not appropriate for this project, vendor it into the repo and wire it locally.
```

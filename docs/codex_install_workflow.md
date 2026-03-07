# Codex install workflow

This document defines the simplest reliable way to install `flutter_grab` or `AppleGrab` into another project through Codex.

## Goal

You should be able to give Codex one of these:

- a GitHub URL
- a zip file
- a local folder path

and say “install this into the current project”, without needing to manually explain package wiring every time.

## Rule: direct if possible, vendor if needed

For `AppleGrab`, the repo root is now a valid Swift Package.

That means Codex should prefer:

1. direct package installation from the source you gave it
2. automatic app wiring
3. verification

If direct installation is not appropriate for the target project, then Codex should:

1. copy or unpack the source into the current project
2. wire the current project to that local copy
3. patch the app startup
4. verify the integration

This keeps the simple path simple, while still preserving a self-contained fallback.

## Accepted source formats

### 1. GitHub URL

Example:

```text
https://github.com/jaymutzafi/Flutter-Grab.git
```

For Apple apps, this now works directly because the repo root is a Swift Package exposing the `AppleGrab` product.

Codex can either:

- add the GitHub repo directly as a Swift Package dependency, or
- vendor the package into the current repo if you explicitly want a local copy.

### 2. Zip file

Example:

```text
/Users/you/Downloads/Flutter-Grab-main.zip
```

For Apple apps, Codex can unpack the zip and use the unpacked repo root directly as a local Swift Package.

If you want the target repo to own a local copy after installation, Codex should vendor it after unpacking.

### 3. Local folder path

Example:

```text
/Users/jaymutzafi/Library/Mobile Documents/com~apple~CloudDocs/Projects/Flutter Grab
```

For Apple apps, Codex can use that repo root directly as a local Swift Package.

If you want the target project to be self-contained after install, Codex should vendor it into the target repo instead of leaving it linked to the original folder.

## Where Codex should put it

### For AppleGrab

Preferred direct install source:

- the repo root GitHub URL
- the repo root zip
- the repo root folder path

Fallback vendored destination:

```text
Packages/AppleGrab
```

using the contents of:

```text
packages/apple_grab_sdk
```

### For flutter_grab

Vendor into:

```text
packages/flutter_grab
```

or another repo-local package folder appropriate for the target Flutter workspace.

## How Codex should wire it

### Swift Package app

If the target app already uses `Package.swift`, Codex should:

- for a GitHub URL:
  - add `.package(url: "https://github.com/jaymutzafi/Flutter-Grab.git", branch: "main")`
  - add `AppleGrab` as a dependency of the app target
- for a local folder path or unpacked zip:
  - add `.package(path: "/path/to/source")` if direct install is acceptable
- for a vendored install:
  - place `AppleGrab` at `Packages/AppleGrab`
  - add `.package(path: "Packages/AppleGrab")`
  - add `AppleGrab` as a dependency of the app target

### Xcode project app

If the target app is an `.xcodeproj` app, Codex should:

- for a GitHub URL:
  - add the repo as a remote Swift package dependency
  - attach the `AppleGrab` product to the app target
- for a local folder path or unpacked zip:
  - add it as a local Swift package dependency
  - attach the `AppleGrab` product to the app target
- for a vendored install:
  - place `AppleGrab` at `Packages/AppleGrab`
  - add that local Swift package dependency
  - attach the `AppleGrab` product to the app target

### Flutter app

For `flutter_grab`, Codex should:

- vendor the package inside the current repo
- use a local path dependency inside that repo
- wrap the app root with `FlutterGrab.wrap(...)`

## What code Codex should add

### AppKit

Codex should install `AppleGrab` after the main window exists:

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

Codex should install `AppleGrab` after the window exists:

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

### Flutter

Codex should wrap the root app:

```dart
runApp(
  FlutterGrab.wrap(
    child: const MyApp(),
  ),
);
```

## What Codex should verify

For AppleGrab:

- package dependency resolves
- app builds
- debug boot log appears
- active banner appears
- doctor surface confirms overlay is mounted

For flutter_grab:

- package resolves
- app runs in debug
- active banner appears
- doctor panel confirms overlay is mounted
- inspect mode toggles

## Recommended user prompt

Use this exact style of request in another project:

```text
Install AppleGrab into this app from this source:
SOURCE_HERE

If direct package installation works, use it.
If not, vendor it into this repo instead of linking to an external path.
Then wire it into the app lifecycle, verify it builds, and make sure the active banner and doctor surface work.
```

Examples:

```text
Install AppleGrab into this app from this source:
https://github.com/jaymutzafi/Flutter-Grab.git

Vendor it into this repo instead of linking to an external path.
Then wire it into the app lifecycle, verify it builds, and make sure the active banner and doctor surface work.
```

```text
Install AppleGrab into this app from this source:
/Users/jaymutzafi/Downloads/Flutter-Grab-main.zip

Vendor it into this repo instead of linking to an external path.
Then wire it into the app lifecycle, verify it builds, and make sure the active banner and doctor surface work.
```

```text
Install AppleGrab into this app from this source:
/Users/jaymutzafi/Library/Mobile Documents/com~apple~CloudDocs/Projects/Flutter Grab

Vendor it into this repo instead of linking to an external path.
Then wire it into the app lifecycle, verify it builds, and make sure the active banner and doctor surface work.
```

## Why this is the standard workflow

This approach avoids:

- pub.dev assumptions
- GitHub subdirectory package confusion
- cross-project sandbox visibility problems
- future breakage from moving the original source folder

After installation, the target project owns a local copy and Codex can work on it directly.

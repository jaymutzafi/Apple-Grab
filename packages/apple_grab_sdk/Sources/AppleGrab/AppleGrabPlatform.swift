import Foundation

#if canImport(AppKit)
import AppKit

public typealias AppleGrabPlatformWindow = NSWindow
public typealias AppleGrabPlatformView = NSView
public typealias AppleGrabPlatformViewController = NSViewController
public typealias AppleGrabPlatformColor = NSColor

enum AppleGrabPlatform {
    static let name = "macOS"
}

#elseif canImport(UIKit)
import UIKit

public typealias AppleGrabPlatformWindow = UIWindow
public typealias AppleGrabPlatformView = UIView
public typealias AppleGrabPlatformViewController = UIViewController
public typealias AppleGrabPlatformColor = UIColor

enum AppleGrabPlatform {
    static let name = "iOS"
}
#endif

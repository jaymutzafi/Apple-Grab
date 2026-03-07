import Foundation

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

@MainActor
enum AppleGrabApplicationContext {
    static func applicationName() -> String {
        if let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String,
           !bundleName.isEmpty {
            return bundleName
        }
        return ProcessInfo.processInfo.processName
    }

    static func windowTitle(for window: AppleGrabPlatformWindow) -> String? {
        #if canImport(AppKit)
        return window.title.isEmpty ? nil : window.title
        #elseif canImport(UIKit)
        return nil
        #endif
    }

    static func interfaceStyle(for view: AppleGrabPlatformView) -> String {
        #if canImport(AppKit)
        switch view.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) {
        case .darkAqua:
            return "dark"
        default:
            return "light"
        }
        #elseif canImport(UIKit)
        switch view.traitCollection.userInterfaceStyle {
        case .dark:
            return "dark"
        case .light:
            return "light"
        default:
            return "unspecified"
        }
        #endif
    }

    static func tintColorHex(for view: AppleGrabPlatformView) -> String? {
        #if canImport(AppKit)
        return nil
        #elseif canImport(UIKit)
        return AppleGrabColor.hexString(view.tintColor)
        #endif
    }
}

@MainActor
enum AppleGrabColor {
    static func hexString(_ color: AppleGrabPlatformColor) -> String? {
        #if canImport(AppKit)
        guard let srgb = color.usingColorSpace(.sRGB) else { return nil }
        let red = Int(round(srgb.redComponent * 255))
        let green = Int(round(srgb.greenComponent * 255))
        let blue = Int(round(srgb.blueComponent * 255))
        let alpha = Int(round(srgb.alphaComponent * 255))
        #elseif canImport(UIKit)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        guard color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
        let red = Int(round(red * 255))
        let green = Int(round(green * 255))
        let blue = Int(round(blue * 255))
        let alpha = Int(round(alpha * 255))
        #endif
        if alpha == 255 {
            return String(format: "#%02X%02X%02X", red, green, blue)
        }
        return String(format: "#%02X%02X%02X%02X", red, green, blue, alpha)
    }
}

@MainActor
enum AppleGrabPasteboard {
    static func write(_ value: String) {
        #if canImport(AppKit)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(value, forType: .string)
        #elseif canImport(UIKit)
        UIPasteboard.general.string = value
        #endif
    }
}

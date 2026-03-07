import CoreGraphics
import Foundation

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

@MainActor
enum AppleGrabViewIntrospection {
    static func typeName(for view: AppleGrabPlatformView) -> String {
        String(describing: type(of: view))
    }

    static func describe(view: AppleGrabPlatformView) -> String {
        #if canImport(AppKit)
        return view.identifier?.rawValue ?? typeName(for: view)
        #elseif canImport(UIKit)
        return view.accessibilityIdentifier ?? typeName(for: view)
        #endif
    }

    static func identifier(of view: AppleGrabPlatformView) -> String? {
        #if canImport(AppKit)
        return view.identifier?.rawValue
        #elseif canImport(UIKit)
        return view.accessibilityIdentifier
        #endif
    }

    static func frameInWindow(of view: AppleGrabPlatformView) -> CGRect {
        #if canImport(AppKit)
        guard let superview = view.superview else { return view.frame }
        return superview.convert(view.frame, to: nil)
        #elseif canImport(UIKit)
        return view.convert(view.bounds, to: nil)
        #endif
    }

    static func ancestorChain(
        for view: AppleGrabPlatformView,
        maxDepth: Int
    ) -> [AppleGrabPlatformView] {
        var result: [AppleGrabPlatformView] = []
        var current: AppleGrabPlatformView? = platformSuperview(of: view)
        while let resolved = current, result.count < maxDepth {
            result.insert(resolved, at: 0)
            current = platformSuperview(of: resolved)
        }
        return result
    }

    static func textContent(of view: AppleGrabPlatformView) -> [String] {
        var results: [String] = []
        collectText(from: view, into: &results)
        return Array(NSOrderedSet(array: results).compactMap { $0 as? String })
    }

    static func accessibilityInfo(for view: AppleGrabPlatformView) -> AppleGrabAccessibilityInfo {
        #if canImport(AppKit)
        return AppleGrabAccessibilityInfo(
            label: view.accessibilityLabel(),
            hint: view.accessibilityHelp(),
            value: view.accessibilityValue() as? String
        )
        #elseif canImport(UIKit)
        return AppleGrabAccessibilityInfo(
            label: view.accessibilityLabel,
            hint: view.accessibilityHint,
            value: view.accessibilityValue
        )
        #endif
    }

    static func owningControllerName(for view: AppleGrabPlatformView) -> String? {
        #if canImport(AppKit)
        var responder: NSResponder? = view
        while let current = responder {
            if let controller = current as? NSViewController {
                return String(describing: type(of: controller))
            }
            responder = current.nextResponder
        }
        return nil
        #elseif canImport(UIKit)
        var responder: UIResponder? = view
        while let current = responder {
            if let controller = current as? UIViewController {
                return String(describing: type(of: controller))
            }
            responder = current.next
        }
        return nil
        #endif
    }

    private static func collectText(from view: AppleGrabPlatformView, into results: inout [String]) {
        #if canImport(AppKit)
        switch view {
        case let label as NSTextField:
            append(label.stringValue, into: &results)
        case let button as NSButton:
            append(button.title, into: &results)
        case let textView as NSTextView:
            append(textView.string, into: &results)
        default:
            break
        }
        #elseif canImport(UIKit)
        switch view {
        case let label as UILabel:
            append(label.text, into: &results)
        case let button as UIButton:
            append(button.currentTitle, into: &results)
        case let textField as UITextField:
            append(textField.text, into: &results)
        case let textView as UITextView:
            append(textView.text, into: &results)
        default:
            break
        }
        #endif

        for subview in platformSubviews(of: view) {
            collectText(from: subview, into: &results)
        }
    }

    private static func append(_ value: String?, into results: inout [String]) {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !trimmed.isEmpty {
            results.append(trimmed)
        }
    }

    private static func platformSubviews(of view: AppleGrabPlatformView) -> [AppleGrabPlatformView] {
        #if canImport(AppKit)
        return view.subviews
        #elseif canImport(UIKit)
        return view.subviews
        #endif
    }

    private static func platformSuperview(of view: AppleGrabPlatformView) -> AppleGrabPlatformView? {
        #if canImport(AppKit)
        return view.superview
        #elseif canImport(UIKit)
        return view.superview
        #endif
    }
}

import CoreGraphics
import Foundation

public struct AppleGrabRect: Codable, Sendable, Equatable {
    public var x: Double
    public var y: Double
    public var width: Double
    public var height: Double

    public init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    init(_ rect: CGRect) {
        self.init(
            x: rect.origin.x,
            y: rect.origin.y,
            width: rect.size.width,
            height: rect.size.height
        )
    }

    public var displayString: String {
        "x=\(AppleGrabFormat.double(x)), y=\(AppleGrabFormat.double(y)), w=\(AppleGrabFormat.double(width)), h=\(AppleGrabFormat.double(height))"
    }
}

public struct AppleGrabViewSummary: Codable, Sendable, Equatable {
    public var typeName: String
    public var identifier: String?
    public var tagName: String?

    public init(typeName: String, identifier: String? = nil, tagName: String? = nil) {
        self.typeName = typeName
        self.identifier = identifier
        self.tagName = tagName
    }
}

public struct AppleGrabAccessibilityInfo: Codable, Sendable, Equatable {
    public var label: String?
    public var hint: String?
    public var value: String?

    public init(label: String? = nil, hint: String? = nil, value: String? = nil) {
        self.label = label
        self.hint = hint
        self.value = value
    }
}

public struct AppleGrabSelection: Codable, Sendable, Equatable {
    public var viewType: String
    public var viewDescription: String
    public var frameInWindow: AppleGrabRect
    public var text: [String]
    public var identifier: String?
    public var owningController: String?
    public var accessibility: AppleGrabAccessibilityInfo

    public init(
        viewType: String,
        viewDescription: String,
        frameInWindow: AppleGrabRect,
        text: [String] = [],
        identifier: String? = nil,
        owningController: String? = nil,
        accessibility: AppleGrabAccessibilityInfo = .init()
    ) {
        self.viewType = viewType
        self.viewDescription = viewDescription
        self.frameInWindow = frameInWindow
        self.text = text
        self.identifier = identifier
        self.owningController = owningController
        self.accessibility = accessibility
    }
}

public struct AppleGrabAppearance: Codable, Sendable, Equatable {
    public var interfaceStyle: String
    public var tintColorHex: String?

    public init(interfaceStyle: String, tintColorHex: String? = nil) {
        self.interfaceStyle = interfaceStyle
        self.tintColorHex = tintColorHex
    }
}

public struct AppleGrabArtifacts: Codable, Sendable, Equatable {
    public var exportPath: String?
    public var clipboardEnabled: Bool

    public init(exportPath: String?, clipboardEnabled: Bool) {
        self.exportPath = exportPath
        self.clipboardEnabled = clipboardEnabled
    }
}

public struct AppleGrabCapture: Codable, Sendable, Equatable {
    public var schemaVersion: Int
    public var capturedAt: Date
    public var platform: String
    public var appName: String
    public var windowTitle: String?
    public var selection: AppleGrabSelection
    public var ancestors: [AppleGrabViewSummary]
    public var tags: [AppleGrabTag]
    public var appearance: AppleGrabAppearance
    public var artifacts: AppleGrabArtifacts

    public init(
        schemaVersion: Int = 1,
        capturedAt: Date = Date(),
        platform: String,
        appName: String,
        windowTitle: String? = nil,
        selection: AppleGrabSelection,
        ancestors: [AppleGrabViewSummary],
        tags: [AppleGrabTag],
        appearance: AppleGrabAppearance,
        artifacts: AppleGrabArtifacts
    ) {
        self.schemaVersion = schemaVersion
        self.capturedAt = capturedAt
        self.platform = platform
        self.appName = appName
        self.windowTitle = windowTitle
        self.selection = selection
        self.ancestors = ancestors
        self.tags = tags
        self.appearance = appearance
        self.artifacts = artifacts
    }

    public var codexPrompt: String {
        var lines: [String] = [
            "Apple Grab Capture",
            "Platform: \(platform)",
            "App: \(appName)",
        ]

        if let windowTitle, !windowTitle.isEmpty {
            lines.append("Window: \(windowTitle)")
        }

        lines += [
            "",
            "Selected view",
            "- Type: \(selection.viewType)",
            "- Description: \(selection.viewDescription)",
            "- Bounds: \(selection.frameInWindow.displayString)",
        ]

        if let identifier = selection.identifier, !identifier.isEmpty {
            lines.append("- Identifier: \(identifier)")
        }

        if let controller = selection.owningController, !controller.isEmpty {
            lines.append("- Controller: \(controller)")
        }

        if !selection.text.isEmpty {
            lines.append("- Text:")
            lines.append(contentsOf: selection.text.map { "  - \($0)" })
        }

        if let label = selection.accessibility.label, !label.isEmpty {
            lines.append("- Accessibility label: \(label)")
        }

        if !tags.isEmpty {
            lines += [
                "",
                "Explicit tags",
            ]
            lines.append(contentsOf: tags.map { "- \($0.name)" })
        }

        if !ancestors.isEmpty {
            lines += [
                "",
                "Ancestor chain",
            ]
            lines.append(contentsOf: ancestors.map {
                if let tagName = $0.tagName {
                    return "- \($0.typeName) [tag:\(tagName)]"
                }
                return "- \($0.typeName)"
            })
        }

        lines += [
            "",
            "Appearance",
            "- Interface style: \(appearance.interfaceStyle)",
        ]

        if let tintColorHex = appearance.tintColorHex {
            lines.append("- Tint color: \(tintColorHex)")
        }

        lines += [
            "",
            "Use this native UI context to reason about or implement a view change. Preserve the current structure and hierarchy unless the task explicitly changes them.",
        ]

        return lines.joined(separator: "\n")
    }

    public func prettyJSON() throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(self)
        return String(decoding: data, as: UTF8.self)
    }
}

enum AppleGrabFormat {
    static func double(_ value: Double) -> String {
        String(format: "%.1f", value)
    }
}

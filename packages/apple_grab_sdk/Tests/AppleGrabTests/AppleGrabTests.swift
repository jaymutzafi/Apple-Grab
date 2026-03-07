import XCTest
@testable import AppleGrab

final class AppleGrabTests: XCTestCase {
    @MainActor
    func testCodexPromptIncludesKeySections() throws {
        let capture = AppleGrabCapture(
            platform: "macOS",
            appName: "DemoApp",
            windowTitle: "Main",
            selection: AppleGrabSelection(
                viewType: "NSButton",
                viewDescription: "PrimaryButton",
                frameInWindow: AppleGrabRect(x: 10, y: 20, width: 120, height: 44),
                text: ["Continue"],
                identifier: "continue-button",
                owningController: "MainViewController",
                accessibility: AppleGrabAccessibilityInfo(label: "Continue")
            ),
            ancestors: [
                AppleGrabViewSummary(typeName: "NSStackView"),
                AppleGrabViewSummary(typeName: "NSView", tagName: "hero-card"),
            ],
            tags: [
                AppleGrabTag(name: "hero-card", description: "Primary CTA container"),
            ],
            appearance: AppleGrabAppearance(interfaceStyle: "light", tintColorHex: "#0F62FE"),
            artifacts: AppleGrabArtifacts(exportPath: "/tmp/latest_capture.json", clipboardEnabled: true)
        )

        let prompt = capture.codexPrompt

        XCTAssertTrue(prompt.contains("Apple Grab Capture"))
        XCTAssertTrue(prompt.contains("Selected view"))
        XCTAssertTrue(prompt.contains("Explicit tags"))
        XCTAssertTrue(prompt.contains("Ancestor chain"))
        XCTAssertTrue(prompt.contains("Appearance"))
    }

    @MainActor
    func testConfigEquality() {
        let lhs = AppleGrabConfig(enableBootLog: true, exportURL: URL(fileURLWithPath: "/tmp/file.json"))
        let rhs = AppleGrabConfig(enableBootLog: true, exportURL: URL(fileURLWithPath: "/tmp/file.json"))

        XCTAssertEqual(lhs, rhs)
    }
}

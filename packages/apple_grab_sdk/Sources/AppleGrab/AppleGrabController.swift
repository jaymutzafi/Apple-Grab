import Foundation

@MainActor
public final class AppleGrabController: NSObject {
    public private(set) var latestCapture: AppleGrabCapture?
    public private(set) var inspectMode = false
    public private(set) var doctorVisible = false

    public let config: AppleGrabConfig

    weak var window: AppleGrabPlatformWindow?
    var coordinator: AppleGrabOverlayCoordinator?

    init(window: AppleGrabPlatformWindow, config: AppleGrabConfig) {
        self.window = window
        self.config = config
    }

    public var isInstalled: Bool {
        coordinator?.isMounted == true
    }

    public func doctorStatus() -> AppleGrabDoctorStatus {
        AppleGrabDoctorStatus(
            platform: AppleGrabPlatform.name,
            overlayMounted: isInstalled,
            inspectMode: inspectMode,
            doctorVisible: doctorVisible,
            latestCaptureAvailable: latestCapture != nil
        )
    }

    public func toggleInspectMode() {
        setInspectMode(!inspectMode)
    }

    public func setInspectMode(_ enabled: Bool) {
        inspectMode = enabled
        coordinator?.setInspectMode(enabled)
    }

    public func toggleDoctorPanel() {
        doctorVisible.toggle()
        coordinator?.setDoctorVisible(doctorVisible)
    }

    public func capture(view: AppleGrabPlatformView) {
        guard let capture = buildCapture(from: view) else { return }
        latestCapture = capture
        coordinator?.refreshDoctor()
    }

    @discardableResult
    public func copyLatestCaptureToPasteboard() -> Bool {
        guard config.enableClipboardExport, let latestCapture else { return false }
        AppleGrabPasteboard.write(latestCapture.codexPrompt)
        return true
    }

    @discardableResult
    public func exportLatestCapture() throws -> URL? {
        guard let latestCapture, let exportURL = config.exportURL else { return nil }
        let directory = exportURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let textURL = exportURL.deletingPathExtension().appendingPathExtension("txt")
        try latestCapture.prettyJSON().write(to: exportURL, atomically: true, encoding: .utf8)
        try latestCapture.codexPrompt.write(to: textURL, atomically: true, encoding: .utf8)
        return exportURL
    }

    func buildCapture(from view: AppleGrabPlatformView) -> AppleGrabCapture? {
        guard let window else { return nil }

        let ancestors = AppleGrabViewIntrospection.ancestorChain(
            for: view,
            maxDepth: config.maxAncestorDepth
        )
        let tags = ancestors.compactMap { $0.appleGrabTag }
        let selection = AppleGrabSelection(
            viewType: AppleGrabViewIntrospection.typeName(for: view),
            viewDescription: AppleGrabViewIntrospection.describe(view: view),
            frameInWindow: AppleGrabRect(AppleGrabViewIntrospection.frameInWindow(of: view)),
            text: AppleGrabViewIntrospection.textContent(of: view),
            identifier: AppleGrabViewIntrospection.identifier(of: view),
            owningController: AppleGrabViewIntrospection.owningControllerName(for: view),
            accessibility: AppleGrabViewIntrospection.accessibilityInfo(for: view)
        )

        return AppleGrabCapture(
            platform: AppleGrabPlatform.name,
            appName: config.applicationName ?? AppleGrabApplicationContext.applicationName(),
            windowTitle: AppleGrabApplicationContext.windowTitle(for: window),
            selection: selection,
            ancestors: ancestors.map {
                AppleGrabViewSummary(
                    typeName: AppleGrabViewIntrospection.typeName(for: $0),
                    identifier: AppleGrabViewIntrospection.identifier(of: $0),
                    tagName: $0.appleGrabTag?.name
                )
            },
            tags: tags,
            appearance: AppleGrabAppearance(
                interfaceStyle: AppleGrabApplicationContext.interfaceStyle(for: view),
                tintColorHex: AppleGrabApplicationContext.tintColorHex(for: view)
            ),
            artifacts: AppleGrabArtifacts(
                exportPath: config.exportURL?.path,
                clipboardEnabled: config.enableClipboardExport
            )
        )
    }
}

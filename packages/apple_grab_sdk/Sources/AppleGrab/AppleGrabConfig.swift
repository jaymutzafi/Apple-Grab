import Foundation

public struct AppleGrabConfig: Sendable, Equatable {
    public var enableBootLog: Bool
    public var enableActiveBanner: Bool
    public var enableDoctorPanel: Bool
    public var enableClipboardExport: Bool
    public var exportURL: URL?
    public var maxAncestorDepth: Int
    public var applicationName: String?

    public init(
        enableBootLog: Bool = true,
        enableActiveBanner: Bool = true,
        enableDoctorPanel: Bool = true,
        enableClipboardExport: Bool = true,
        exportURL: URL? = nil,
        maxAncestorDepth: Int = 50,
        applicationName: String? = nil
    ) {
        self.enableBootLog = enableBootLog
        self.enableActiveBanner = enableActiveBanner
        self.enableDoctorPanel = enableDoctorPanel
        self.enableClipboardExport = enableClipboardExport
        self.exportURL = exportURL
        self.maxAncestorDepth = maxAncestorDepth
        self.applicationName = applicationName
    }
}

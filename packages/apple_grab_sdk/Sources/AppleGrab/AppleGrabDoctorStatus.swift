import Foundation

public struct AppleGrabDoctorStatus: Sendable, Equatable {
    public var platform: String
    public var overlayMounted: Bool
    public var inspectMode: Bool
    public var doctorVisible: Bool
    public var latestCaptureAvailable: Bool

    public init(
        platform: String,
        overlayMounted: Bool,
        inspectMode: Bool,
        doctorVisible: Bool,
        latestCaptureAvailable: Bool
    ) {
        self.platform = platform
        self.overlayMounted = overlayMounted
        self.inspectMode = inspectMode
        self.doctorVisible = doctorVisible
        self.latestCaptureAvailable = latestCaptureAvailable
    }
}

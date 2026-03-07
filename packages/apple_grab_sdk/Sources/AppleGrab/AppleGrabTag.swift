import Foundation
import ObjectiveC

public struct AppleGrabTag: Codable, Sendable, Equatable {
    public var name: String
    public var description: String?
    public var tags: [String]
    public var notes: String?
    public var metadata: [String: String]

    public init(
        name: String,
        description: String? = nil,
        tags: [String] = [],
        notes: String? = nil,
        metadata: [String: String] = [:]
    ) {
        self.name = name
        self.description = description
        self.tags = tags
        self.notes = notes
        self.metadata = metadata
    }
}

@MainActor
private enum AppleGrabAssociatedObjectKey {
    nonisolated(unsafe) static var tagKey: UInt8 = 0
}

@MainActor
public extension AppleGrabPlatformView {
    var appleGrabTag: AppleGrabTag? {
        get {
            objc_getAssociatedObject(self, &AppleGrabAssociatedObjectKey.tagKey) as? AppleGrabTag
        }
        set {
            objc_setAssociatedObject(
                self,
                &AppleGrabAssociatedObjectKey.tagKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}

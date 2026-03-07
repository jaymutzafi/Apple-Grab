import Foundation

public enum AppleGrab {
    @discardableResult
    @MainActor
    public static func install(
        on window: AppleGrabPlatformWindow,
        config: AppleGrabConfig = .init()
    ) -> AppleGrabController {
        let controller = AppleGrabController(window: window, config: config)
        #if DEBUG
        let coordinator = AppleGrabOverlayCoordinator(window: window, controller: controller)
        controller.coordinator = coordinator
        coordinator.install()
        if config.enableBootLog {
            AppleGrabLogger.log(
                "[AppleGrab] active. Use the banner to toggle Inspect or open Doctor."
            )
        }
        #endif
        return controller
    }
}

enum AppleGrabLogger {
    @MainActor
    static func log(_ message: String) {
        #if DEBUG
        print(message)
        #endif
    }
}

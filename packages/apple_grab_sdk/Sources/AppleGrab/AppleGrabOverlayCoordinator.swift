import Foundation

#if canImport(AppKit)
import AppKit

@MainActor
final class AppleGrabOverlayCoordinator: NSObject {
    private weak var window: NSWindow?
    private unowned let controller: AppleGrabController
    private let overlayView: AppKitOverlayView
    private let bannerView: AppKitBannerView
    private let doctorView: AppKitDoctorView

    init(window: NSWindow, controller: AppleGrabController) {
        self.window = window
        self.controller = controller
        self.overlayView = AppKitOverlayView()
        self.bannerView = AppKitBannerView()
        self.doctorView = AppKitDoctorView()
        super.init()
        self.overlayView.coordinator = self
        self.bannerView.coordinator = self
        self.doctorView.coordinator = self
    }

    var isMounted: Bool { overlayView.superview != nil }

    func install() {
        guard let contentView = window?.contentView, !isMounted else { return }

        overlayView.frame = contentView.bounds
        overlayView.autoresizingMask = [.width, .height]
        contentView.addSubview(overlayView)

        if controller.config.enableActiveBanner {
            overlayView.addSubview(bannerView)
            bannerView.frame = CGRect(x: 16, y: contentView.bounds.height - 64, width: 290, height: 44)
            bannerView.autoresizingMask = [.maxXMargin, .minYMargin]
        }

        overlayView.addSubview(doctorView)
        doctorView.frame = CGRect(x: 16, y: contentView.bounds.height - 240, width: 320, height: 150)
        doctorView.autoresizingMask = [.maxXMargin, .minYMargin]
        doctorView.isHidden = true
        refreshDoctor()
    }

    func setInspectMode(_ enabled: Bool) {
        overlayView.inspectMode = enabled
        bannerView.setInspectMode(enabled)
    }

    func setDoctorVisible(_ visible: Bool) {
        doctorView.isHidden = !visible
        refreshDoctor()
    }

    func refreshDoctor() {
        doctorView.update(status: controller.doctorStatus())
    }

    func toggleInspectMode() {
        controller.toggleInspectMode()
    }

    func toggleDoctorPanel() {
        controller.toggleDoctorPanel()
    }

    func copyCapture() {
        _ = controller.copyLatestCaptureToPasteboard()
        refreshDoctor()
    }

    func exportCapture() {
        _ = try? controller.exportLatestCapture()
        refreshDoctor()
    }

    func updateHover(at pointInWindow: NSPoint) {
        guard controller.inspectMode else { return }
        let target = targetView(at: pointInWindow)
        overlayView.highlightRect = target.map { AppleGrabViewIntrospection.frameInWindow(of: $0) }
    }

    func select(at pointInWindow: NSPoint) {
        guard controller.inspectMode, let target = targetView(at: pointInWindow) else { return }
        controller.capture(view: target)
        overlayView.highlightRect = AppleGrabViewIntrospection.frameInWindow(of: target)
        refreshDoctor()
    }

    private func targetView(at pointInWindow: NSPoint) -> NSView? {
        guard let root = window?.contentView else { return nil }
        let pointInRoot = root.convert(pointInWindow, from: nil)
        return deepestView(in: root, point: pointInRoot)
    }

    private func deepestView(in view: NSView, point: NSPoint) -> NSView? {
        if view === overlayView || view.isHidden || view.alphaValue < 0.01 {
            return nil
        }
        for subview in view.subviews.reversed() {
            let converted = subview.convert(point, from: view)
            if let hit = deepestView(in: subview, point: converted) {
                return hit
            }
        }
        return view.bounds.contains(point) ? view : nil
    }
}

private final class AppKitOverlayView: NSView {
    weak var coordinator: AppleGrabOverlayCoordinator?
    var inspectMode = false
    var highlightRect: CGRect? {
        didSet { needsDisplay = true }
    }

    private var trackingAreaRef: NSTrackingArea?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let trackingAreaRef {
            removeTrackingArea(trackingAreaRef)
        }
        let options: NSTrackingArea.Options = [.activeAlways, .mouseMoved, .inVisibleRect]
        let trackingArea = NSTrackingArea(rect: bounds, options: options, owner: self, userInfo: nil)
        addTrackingArea(trackingArea)
        trackingAreaRef = trackingArea
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        for subview in subviews.reversed() {
            let converted = subview.convert(point, from: self)
            if let hit = subview.hitTest(converted) {
                return hit
            }
        }
        return inspectMode ? self : nil
    }

    override func mouseMoved(with event: NSEvent) {
        coordinator?.updateHover(at: event.locationInWindow)
    }

    override func mouseDown(with event: NSEvent) {
        coordinator?.select(at: event.locationInWindow)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard let highlightRect else { return }
        NSColor.systemOrange.withAlphaComponent(0.18).setFill()
        NSColor.systemOrange.setStroke()
        let path = NSBezierPath(rect: highlightRect)
        path.fill()
        path.lineWidth = 2
        path.stroke()
    }
}

private final class AppKitBannerView: NSView {
    weak var coordinator: AppleGrabOverlayCoordinator?
    private let titleLabel = NSTextField(labelWithString: "Apple Grab active")
    private let inspectButton = NSButton(title: "Inspect", target: nil, action: nil)
    private let doctorButton = NSButton(title: "Doctor", target: nil, action: nil)

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = NSColor.systemYellow.cgColor
        layer?.cornerRadius = 14

        titleLabel.font = .boldSystemFont(ofSize: 13)
        inspectButton.bezelStyle = .rounded
        doctorButton.bezelStyle = .rounded

        inspectButton.target = self
        inspectButton.action = #selector(toggleInspect)
        doctorButton.target = self
        doctorButton.action = #selector(toggleDoctor)

        let stack = NSStackView(views: [titleLabel, inspectButton, doctorButton])
        stack.orientation = .horizontal
        stack.alignment = .centerY
        stack.spacing = 8
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setInspectMode(_ enabled: Bool) {
        inspectButton.title = enabled ? "Stop" : "Inspect"
    }

    @objc private func toggleInspect() {
        coordinator?.toggleInspectMode()
    }

    @objc private func toggleDoctor() {
        coordinator?.toggleDoctorPanel()
    }
}

private final class AppKitDoctorView: NSView {
    weak var coordinator: AppleGrabOverlayCoordinator?
    private let statusLabel = NSTextField(labelWithString: "")
    private let copyButton = NSButton(title: "Copy", target: nil, action: nil)
    private let exportButton = NSButton(title: "Export", target: nil, action: nil)

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        layer?.cornerRadius = 16
        layer?.borderWidth = 1
        layer?.borderColor = NSColor.separatorColor.cgColor

        statusLabel.lineBreakMode = .byWordWrapping
        copyButton.target = self
        copyButton.action = #selector(copyCapture)
        exportButton.target = self
        exportButton.action = #selector(exportCapture)

        let buttonRow = NSStackView(views: [copyButton, exportButton])
        buttonRow.orientation = .horizontal
        buttonRow.spacing = 8

        let stack = NSStackView(views: [NSTextField(labelWithString: "Doctor"), statusLabel, buttonRow])
        stack.orientation = .vertical
        stack.spacing = 10
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(status: AppleGrabDoctorStatus) {
        statusLabel.stringValue =
            "Overlay mounted: \(status.overlayMounted ? "yes" : "no")\n" +
            "Inspect mode: \(status.inspectMode ? "on" : "off")\n" +
            "Latest capture: \(status.latestCaptureAvailable ? "available" : "none")"
    }

    @objc private func copyCapture() {
        coordinator?.copyCapture()
    }

    @objc private func exportCapture() {
        coordinator?.exportCapture()
    }
}

#elseif canImport(UIKit)
import UIKit

@MainActor
final class AppleGrabOverlayCoordinator: NSObject {
    private weak var window: UIWindow?
    private unowned let controller: AppleGrabController
    private let overlayView: UIKitOverlayView
    private let bannerView: UIKitBannerView
    private let doctorView: UIKitDoctorView

    init(window: UIWindow, controller: AppleGrabController) {
        self.window = window
        self.controller = controller
        self.overlayView = UIKitOverlayView()
        self.bannerView = UIKitBannerView()
        self.doctorView = UIKitDoctorView()
        super.init()
        self.overlayView.coordinator = self
        self.bannerView.coordinator = self
        self.doctorView.coordinator = self
    }

    var isMounted: Bool { overlayView.superview != nil }

    func install() {
        guard let window, !isMounted else { return }

        overlayView.frame = window.bounds
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        window.addSubview(overlayView)

        if controller.config.enableActiveBanner {
            overlayView.addSubview(bannerView)
            bannerView.frame = CGRect(x: 16, y: 56, width: 280, height: 48)
            bannerView.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
        }

        overlayView.addSubview(doctorView)
        doctorView.frame = CGRect(x: 16, y: 112, width: 320, height: 152)
        doctorView.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
        doctorView.isHidden = true
        refreshDoctor()
    }

    func setInspectMode(_ enabled: Bool) {
        overlayView.inspectMode = enabled
        bannerView.setInspectMode(enabled)
    }

    func setDoctorVisible(_ visible: Bool) {
        doctorView.isHidden = !visible
        refreshDoctor()
    }

    func refreshDoctor() {
        doctorView.update(status: controller.doctorStatus())
    }

    func toggleInspectMode() {
        controller.toggleInspectMode()
    }

    func toggleDoctorPanel() {
        controller.toggleDoctorPanel()
    }

    func copyCapture() {
        _ = controller.copyLatestCaptureToPasteboard()
        refreshDoctor()
    }

    func exportCapture() {
        try? controller.exportLatestCapture()
        refreshDoctor()
    }

    func select(at pointInWindow: CGPoint) {
        guard controller.inspectMode, let target = targetView(at: pointInWindow) else { return }
        controller.capture(view: target)
        overlayView.highlightRect = AppleGrabViewIntrospection.frameInWindow(of: target)
        refreshDoctor()
    }

    private func targetView(at pointInWindow: CGPoint) -> UIView? {
        guard let window else { return nil }
        return deepestView(in: window, point: pointInWindow)
    }

    private func deepestView(in view: UIView, point: CGPoint) -> UIView? {
        if view === overlayView || view.isHidden || view.alpha < 0.01 {
            return nil
        }
        for subview in view.subviews.reversed() {
            let converted = subview.convert(point, from: view)
            if let hit = deepestView(in: subview, point: converted) {
                return hit
            }
        }
        return view.bounds.contains(point) ? view : nil
    }
}

private final class UIKitOverlayView: UIView {
    weak var coordinator: AppleGrabOverlayCoordinator?
    var inspectMode = false
    var highlightRect: CGRect? {
        didSet { setNeedsDisplay() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for subview in subviews.reversed() {
            let converted = subview.convert(point, from: self)
            if let hit = subview.hitTest(converted, with: event) {
                return hit
            }
        }
        return inspectMode ? self : nil
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: window) else { return }
        coordinator?.select(at: point)
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let highlightRect, let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(UIColor.systemOrange.withAlphaComponent(0.18).cgColor)
        context.fill(highlightRect)
        context.setStrokeColor(UIColor.systemOrange.cgColor)
        context.setLineWidth(2)
        context.stroke(highlightRect)
    }
}

private final class UIKitBannerView: UIView {
    weak var coordinator: AppleGrabOverlayCoordinator?
    private let titleLabel = UILabel()
    private let inspectButton = UIButton(type: .system)
    private let doctorButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemYellow
        layer.cornerRadius = 14

        titleLabel.text = "Apple Grab active"
        titleLabel.font = .boldSystemFont(ofSize: 14)

        inspectButton.setTitle("Inspect", for: .normal)
        doctorButton.setTitle("Doctor", for: .normal)
        inspectButton.addTarget(self, action: #selector(toggleInspect), for: .touchUpInside)
        doctorButton.addTarget(self, action: #selector(toggleDoctor), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [titleLabel, inspectButton, doctorButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setInspectMode(_ enabled: Bool) {
        inspectButton.setTitle(enabled ? "Stop" : "Inspect", for: .normal)
    }

    @objc private func toggleInspect() {
        coordinator?.toggleInspectMode()
    }

    @objc private func toggleDoctor() {
        coordinator?.toggleDoctorPanel()
    }
}

private final class UIKitDoctorView: UIView {
    weak var coordinator: AppleGrabOverlayCoordinator?
    private let statusLabel = UILabel()
    private let copyButton = UIButton(type: .system)
    private let exportButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = UIColor.separator.cgColor

        let titleLabel = UILabel()
        titleLabel.text = "Doctor"
        titleLabel.font = .boldSystemFont(ofSize: 16)

        statusLabel.numberOfLines = 0
        copyButton.setTitle("Copy", for: .normal)
        exportButton.setTitle("Export", for: .normal)
        copyButton.addTarget(self, action: #selector(copyCapture), for: .touchUpInside)
        exportButton.addTarget(self, action: #selector(exportCapture), for: .touchUpInside)

        let buttonRow = UIStackView(arrangedSubviews: [copyButton, exportButton])
        buttonRow.axis = .horizontal
        buttonRow.spacing = 8

        let stack = UIStackView(arrangedSubviews: [titleLabel, statusLabel, buttonRow])
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(status: AppleGrabDoctorStatus) {
        statusLabel.text =
            "Overlay mounted: \(status.overlayMounted ? "yes" : "no")\n" +
            "Inspect mode: \(status.inspectMode ? "on" : "off")\n" +
            "Latest capture: \(status.latestCaptureAvailable ? "available" : "none")"
    }

    @objc private func copyCapture() {
        coordinator?.copyCapture()
    }

    @objc private func exportCapture() {
        coordinator?.exportCapture()
    }
}
#endif

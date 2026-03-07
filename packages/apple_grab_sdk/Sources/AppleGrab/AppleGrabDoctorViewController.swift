import Foundation

#if canImport(AppKit)
import AppKit

@MainActor
public final class AppleGrabDoctorViewController: NSViewController {
    private let controller: AppleGrabController

    public init(controller: AppleGrabController) {
        self.controller = controller
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        let status = controller.doctorStatus()
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.spacing = 8
        stack.edgeInsets = NSEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        stack.addArrangedSubview(label("Apple Grab doctor", bold: true))
        stack.addArrangedSubview(label("Platform: \(status.platform)"))
        stack.addArrangedSubview(label("Overlay mounted: \(status.overlayMounted ? "yes" : "no")"))
        stack.addArrangedSubview(label("Inspect mode: \(status.inspectMode ? "on" : "off")"))
        stack.addArrangedSubview(label("Latest capture: \(status.latestCaptureAvailable ? "available" : "none")"))

        let container = NSView()
        container.wantsLayer = true
        container.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        container.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
        self.view = container
    }

    private func label(_ text: String, bold: Bool = false) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        if bold {
            label.font = .boldSystemFont(ofSize: NSFont.systemFontSize)
        }
        return label
    }
}

#elseif canImport(UIKit)
import UIKit

@MainActor
public final class AppleGrabDoctorViewController: UIViewController {
    private let controller: AppleGrabController

    public init(controller: AppleGrabController) {
        self.controller = controller
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        let status = controller.doctorStatus()
        view.backgroundColor = .systemBackground
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(label("Apple Grab doctor", bold: true))
        stack.addArrangedSubview(label("Platform: \(status.platform)"))
        stack.addArrangedSubview(label("Overlay mounted: \(status.overlayMounted ? "yes" : "no")"))
        stack.addArrangedSubview(label("Inspect mode: \(status.inspectMode ? "on" : "off")"))
        stack.addArrangedSubview(label("Latest capture: \(status.latestCaptureAvailable ? "available" : "none")"))
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
        ])
    }

    private func label(_ text: String, bold: Bool = false) -> UILabel {
        let label = UILabel()
        label.text = text
        if bold {
            label.font = .boldSystemFont(ofSize: UIFont.systemFontSize)
        }
        return label
    }
}
#endif

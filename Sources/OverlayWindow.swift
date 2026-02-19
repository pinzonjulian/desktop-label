import Cocoa

class OverlayWindow: NSWindow {
    private let label = NSTextField(labelWithString: "")
    private let pill = NSView()
    private var config: Config

    init(config: Config) {
        self.config = config
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 40),
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )

        // Window behavior: floating, click-through, no shadow, on all spaces
        level = .statusBar
        isOpaque = false
        backgroundColor = .clear
        ignoresMouseEvents = true
        collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        hasShadow = false

        setupViews()
        applyConfig(config)
    }

    private func setupViews() {
        let container = NSView(frame: contentRect(forFrameRect: frame))
        container.wantsLayer = true

        // Pill background
        pill.wantsLayer = true
        pill.layer?.cornerRadius = 6
        pill.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(pill)

        // Label
        label.font = .monospacedSystemFont(ofSize: CGFloat(config.fontSize), weight: .medium)
        label.alignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        pill.addSubview(label)

        contentView = container

        NSLayoutConstraint.activate([
            pill.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            pill.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            label.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -12),
            label.topAnchor.constraint(equalTo: pill.topAnchor, constant: 6),
            label.bottomAnchor.constraint(equalTo: pill.bottomAnchor, constant: -6),
        ])
    }

    func applyConfig(_ config: Config) {
        self.config = config
        alphaValue = CGFloat(config.opacity)
        pill.layer?.backgroundColor = NSColor.fromHex(config.backgroundColor).cgColor
        label.textColor = NSColor.fromHex(config.textColor)
        label.font = .monospacedSystemFont(ofSize: CGFloat(config.fontSize), weight: .medium)
    }

    func update(label text: String, spaceIndex: Int) {
        label.stringValue = text
        label.sizeToFit()

        // Resize window to fit content
        let pillWidth = label.fittingSize.width + 24
        let pillHeight = label.fittingSize.height + 12
        let windowSize = NSSize(width: pillWidth + 20, height: pillHeight + 20)

        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        let origin: NSPoint

        switch config.position {
        case "top-right":
            origin = NSPoint(
                x: screenFrame.maxX - windowSize.width - 10,
                y: screenFrame.maxY - windowSize.height - 10
            )
        case "bottom-left":
            origin = NSPoint(
                x: screenFrame.minX + 10,
                y: screenFrame.minY + 10
            )
        case "bottom-right":
            origin = NSPoint(
                x: screenFrame.maxX - windowSize.width - 10,
                y: screenFrame.minY + 10
            )
        default: // top-left
            origin = NSPoint(
                x: screenFrame.minX + 10,
                y: screenFrame.maxY - windowSize.height - 10
            )
        }

        setFrame(NSRect(origin: origin, size: windowSize), display: true)
    }
}

extension NSColor {
    static func fromHex(_ hex: String) -> NSColor {
        let cleaned = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        guard cleaned.count == 6,
              let value = UInt64(cleaned, radix: 16) else {
            return .white
        }
        return NSColor(
            red: CGFloat((value >> 16) & 0xFF) / 255.0,
            green: CGFloat((value >> 8) & 0xFF) / 255.0,
            blue: CGFloat(value & 0xFF) / 255.0,
            alpha: 1.0
        )
    }
}

import Cocoa
import SwiftUI

class AboutWindowController {
    private var window: NSWindow?

    func show() {
        if let window = window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let aboutView = AboutView()
        let hostingController = NSHostingController(rootView: aboutView)
        let window = NSWindow(contentViewController: hostingController)
        window.title = "About Desktop Label"
        window.styleMask = [.titled, .closable]
        hostingController.sizingOptions = .preferredContentSize
        window.center()
        window.isReleasedWhenClosed = false
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        self.window = window
    }
}

struct AboutView: View {
    private let repoURL = "https://github.com/pinzonjulian/desktop-label"
    private let threadURL = "https://ampcode.com/threads/T-019c73ba-8aa6-75d6-8de8-cc3538fe7eb2"

    var body: some View {
        VStack(spacing: 16) {
            Text("🏷")
                .font(.system(size: 48))

            Text("Desktop Label")
                .font(.title)
                .fontWeight(.bold)

            Text("A floating overlay that labels\nyour macOS Spaces.")
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(.secondary)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                LinkRow(label: "GitHub", displayText: "pinzonjulian/desktop-label", url: repoURL)
                LinkRow(label: "Amp Thread", displayText: "View original thread", url: threadURL)
            }
        }
        .padding(24)
        .frame(width: 340)
    }
}

struct LinkRow: View {
    let label: String
    let displayText: String
    let url: String

    var body: some View {
        HStack {
            Text(label)
                .frame(width: 80, alignment: .trailing)
                .foregroundColor(.secondary)
            Link(displayText, destination: URL(string: url)!)
        }
    }
}

import Cocoa
import SwiftUI

class SettingsWindowController {
    private var window: NSWindow?

    func show() {
        if let window = window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let settingsView = SettingsView {
            self.window?.close()
            // Notify app to reload
            NotificationCenter.default.post(name: .configDidChange, object: nil)
        }

        let hostingController = NSHostingController(rootView: settingsView)
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Desktop Label Settings"
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.setContentSize(NSSize(width: 480, height: 500))
        window.center()
        window.isReleasedWhenClosed = false
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        self.window = window
    }
}

extension Notification.Name {
    static let configDidChange = Notification.Name("configDidChange")
}

// MARK: - SwiftUI Views

struct SpaceEntry: Identifiable {
    let id = UUID()
    var number: String
    var label: String
}

struct SettingsView: View {
    @State private var spaces: [SpaceEntry] = []
    @State private var fontSize: Double = 14
    @State private var opacity: Double = 0.75
    @State private var position: String = "top-left"
    @State private var backgroundColor: String = "#000000"
    @State private var textColor: String = "#FFFFFF"
    var onSave: () -> Void

    private let positions = ["top-left", "top-right", "bottom-left", "bottom-right"]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Spaces section
            GroupBox("Spaces") {
                VStack(spacing: 8) {
                    ForEach($spaces) { $entry in
                        HStack(spacing: 8) {
                            Text("Space")
                                .foregroundColor(.secondary)
                            TextField("#", text: $entry.number)
                                .frame(width: 40)
                                .textFieldStyle(.roundedBorder)
                            TextField("Project name", text: $entry.label)
                                .textFieldStyle(.roundedBorder)
                            Button(role: .destructive) {
                                spaces.removeAll { $0.id == entry.id }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Button {
                        let next = (spaces.compactMap { Int($0.number) }.max() ?? 0) + 1
                        spaces.append(SpaceEntry(number: String(next), label: ""))
                    } label: {
                        Label("Add Space", systemImage: "plus.circle.fill")
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.accentColor)
                }
                .padding(8)
            }

            // Appearance section
            GroupBox("Appearance") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Position")
                        Spacer()
                        Picker("", selection: $position) {
                            ForEach(positions, id: \.self) { pos in
                                Text(pos.replacingOccurrences(of: "-", with: " ").capitalized)
                                    .tag(pos)
                            }
                        }
                        .frame(width: 180)
                    }

                    HStack {
                        Text("Font Size")
                        Spacer()
                        Slider(value: $fontSize, in: 10...32, step: 1)
                            .frame(width: 150)
                        Text("\(Int(fontSize))pt")
                            .frame(width: 40, alignment: .trailing)
                            .monospacedDigit()
                    }

                    HStack {
                        Text("Opacity")
                        Spacer()
                        Slider(value: $opacity, in: 0.1...1.0, step: 0.05)
                            .frame(width: 150)
                        Text("\(Int(opacity * 100))%")
                            .frame(width: 40, alignment: .trailing)
                            .monospacedDigit()
                    }

                    HStack {
                        Text("Background")
                        Spacer()
                        TextField("#000000", text: $backgroundColor)
                            .frame(width: 90)
                            .textFieldStyle(.roundedBorder)
                            .monospaced()
                        ColorPreview(hex: backgroundColor)
                    }

                    HStack {
                        Text("Text Color")
                        Spacer()
                        TextField("#FFFFFF", text: $textColor)
                            .frame(width: 90)
                            .textFieldStyle(.roundedBorder)
                            .monospaced()
                        ColorPreview(hex: textColor)
                    }
                }
                .padding(8)
            }

            Spacer()

            // Save
            HStack {
                Text("~/.config/desktop-label/config.json")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Button("Save") {
                    save()
                }
                .keyboardShortcut(.return, modifiers: .command)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .onAppear { loadConfig() }
    }

    private func loadConfig() {
        let config = Config.load()
        fontSize = config.fontSize
        opacity = config.opacity
        position = config.position
        backgroundColor = config.backgroundColor
        textColor = config.textColor
        spaces = config.spaces
            .sorted { Int($0.key) ?? 0 < Int($1.key) ?? 0 }
            .map { SpaceEntry(number: $0.key, label: $0.value) }
    }

    private func save() {
        var spacesDict: [String: String] = [:]
        for entry in spaces where !entry.number.isEmpty && !entry.label.isEmpty {
            spacesDict[entry.number] = entry.label
        }

        let config = Config(
            spaces: spacesDict,
            fontSize: fontSize,
            opacity: opacity,
            position: position,
            backgroundColor: backgroundColor,
            textColor: textColor
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        if let data = try? encoder.encode(config) {
            try? data.write(to: Config.configFile)
        }

        onSave()
    }
}

struct ColorPreview: View {
    let hex: String

    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(color)
            .frame(width: 24, height: 24)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(.secondary.opacity(0.3), lineWidth: 1)
            )
    }

    private var color: Color {
        let cleaned = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        guard cleaned.count == 6, let value = UInt64(cleaned, radix: 16) else {
            return .white
        }
        return Color(
            red: Double((value >> 16) & 0xFF) / 255.0,
            green: Double((value >> 8) & 0xFF) / 255.0,
            blue: Double(value & 0xFF) / 255.0
        )
    }
}

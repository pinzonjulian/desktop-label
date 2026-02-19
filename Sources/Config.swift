import Foundation

struct Config: Codable {
    var spaces: [String: String]       // "1" -> "amp-core", "2" -> "web-app"
    var wallpapers: [String: String]?  // "1" -> "/path/to/image.jpg"
    var fontSize: Double
    var opacity: Double
    var position: String               // "top-left", "top-right", "bottom-left", "bottom-right"
    var backgroundColor: String        // hex color
    var textColor: String              // hex color

    static let configDir = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".config/desktop-label")
    static let configFile = configDir.appendingPathComponent("config.json")

    static let `default` = Config(
        spaces: [
            "1": "Desktop 1",
            "2": "Desktop 2",
            "3": "Desktop 3",
        ],
        wallpapers: nil,
        fontSize: 14,
        opacity: 0.75,
        position: "top-left",
        backgroundColor: "#000000",
        textColor: "#FFFFFF"
    )

    static func load() -> Config {
        if FileManager.default.fileExists(atPath: configFile.path) {
            do {
                let data = try Data(contentsOf: configFile)
                return try JSONDecoder().decode(Config.self, from: data)
            } catch {
                print("⚠️  Failed to parse config: \(error). Using defaults.")
                return .default
            }
        } else {
            // Create default config file
            try? FileManager.default.createDirectory(at: configDir, withIntermediateDirectories: true)
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            if let data = try? encoder.encode(Config.default) {
                try? data.write(to: configFile)
                print("📝 Created default config at \(configFile.path)")
            }
            return .default
        }
    }

    func labelForSpace(_ index: Int) -> String {
        spaces[String(index)] ?? "Desktop \(index)"
    }

    func wallpaperForSpace(_ index: Int) -> URL? {
        guard let path = wallpapers?[String(index)], !path.isEmpty else { return nil }
        let expanded = NSString(string: path).expandingTildeInPath
        let url = URL(fileURLWithPath: expanded)
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }
}

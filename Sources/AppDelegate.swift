import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var overlayWindow: OverlayWindow!
    var statusItem: NSStatusItem!
    var spaceDetector: SpaceDetector!
    var config: Config!
    var settingsController: SettingsWindowController!

    func applicationDidFinishLaunching(_ notification: Notification) {
        config = Config.load()
        spaceDetector = SpaceDetector()

        overlayWindow = OverlayWindow(config: config)
        updateLabel()
        overlayWindow.orderFrontRegardless()

        settingsController = SettingsWindowController()
        setupMenuBar()

        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(spaceChanged),
            name: NSWorkspace.activeSpaceDidChangeNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadConfig),
            name: .configDidChange,
            object: nil
        )
    }

    @objc func spaceChanged(_ notification: Notification) {
        updateLabel()
    }

    func updateLabel() {
        let spaceIndex = spaceDetector.currentSpaceIndex()
        let label = config.labelForSpace(spaceIndex)
        overlayWindow.update(label: label, spaceIndex: spaceIndex)
    }

    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "🏷"

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Settings…", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: "Reload Config", action: #selector(reloadConfig), keyEquivalent: "r"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu
    }

    @objc func openSettings() {
        settingsController.show()
    }

    @objc func reloadConfig() {
        config = Config.load()
        overlayWindow.applyConfig(config)
        updateLabel()
    }

    @objc func quit() {
        NSApp.terminate(nil)
    }
}

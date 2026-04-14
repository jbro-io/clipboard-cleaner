import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var feedbackTimer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Clipboard Cleaner")
            button.target = self
            button.action = #selector(handleClick(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    @objc private func handleClick(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }

        if event.type == .rightMouseUp {
            showMenu()
        } else {
            cleanClipboard()
        }
    }

    private func showMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    private func cleanClipboard() {
        let pasteboard = NSPasteboard.general

        guard let text = pasteboard.string(forType: .string) else { return }

        let cleaned = cleanText(text)

        pasteboard.clearContents()
        pasteboard.setString(cleaned, forType: .string)

        showFeedback()
    }

    private func cleanText(_ text: String) -> String {
        TextCleaner.clean(text)
    }

    private func showFeedback() {
        feedbackTimer?.invalidate()

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "checkmark.circle.fill", accessibilityDescription: "Cleaned")
            button.contentTintColor = .systemGreen
        }

        feedbackTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            if let button = self?.statusItem.button {
                button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Clipboard Cleaner")
                button.contentTintColor = nil
            }
        }
    }
}

@main
enum Main {
    static func main() {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }
}

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
        // 1. Normalize line endings
        let normalized = text.replacingOccurrences(of: "\r\n", with: "\n")

        // 2. Split on paragraph breaks (2+ consecutive newlines)
        let paragraphs = splitParagraphs(normalized)

        // 3. Within each paragraph, join wrapped lines
        let cleaned = paragraphs.map { paragraph -> String in
            let joined = paragraph.replacingOccurrences(
                of: "\\n[ \\t]*",
                with: " ",
                options: .regularExpression
            )
            // 4. Trim extra whitespace
            return joined.trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "  +", with: " ", options: .regularExpression)
        }.filter { !$0.isEmpty }

        // 5. Rejoin paragraphs
        return cleaned.joined(separator: "\n\n")
    }

    private func splitParagraphs(_ text: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: "(?:\\n\\s*){2,}", options: []) else {
            return [text]
        }
        let range = NSRange(text.startIndex..., in: text)
        var parts: [String] = []
        var lastEnd = text.startIndex

        regex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
            guard let matchRange = match.flatMap({ Range($0.range, in: text) }) else { return }
            parts.append(String(text[lastEnd..<matchRange.lowerBound]))
            lastEnd = matchRange.upperBound
        }
        parts.append(String(text[lastEnd...]))
        return parts
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

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = AppDelegate()
app.delegate = delegate
app.run()

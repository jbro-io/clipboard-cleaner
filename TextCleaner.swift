import Foundation

enum TextCleaner {
    static func clean(_ text: String) -> String {
        // 1. Normalize line endings
        let normalized = text.replacingOccurrences(of: "\r\n", with: "\n")

        // 2. Strip block-quote markers (▎) from line beginnings
        let stripped = normalized.split(separator: "\n", omittingEmptySubsequences: false).map { line in
            let s = String(line)
            if let range = s.range(of: "^\\s*▎\\s?", options: .regularExpression) {
                return String(s[range.upperBound...])
            }
            return s
        }.joined(separator: "\n")

        // 3. Split on paragraph breaks (2+ consecutive newlines)
        let paragraphs = splitParagraphs(stripped)

        // 4. Within each paragraph, join wrapped lines
        let cleaned = paragraphs.map { paragraph -> String in
            let joined = paragraph.replacingOccurrences(
                of: "\\n[ \\t]*",
                with: " ",
                options: .regularExpression
            )
            // 5. Trim extra whitespace
            return joined.trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "  +", with: " ", options: .regularExpression)
        }.filter { !$0.isEmpty }

        // 6. Rejoin paragraphs
        return cleaned.joined(separator: "\n\n")
    }

    private static func splitParagraphs(_ text: String) -> [String] {
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
}

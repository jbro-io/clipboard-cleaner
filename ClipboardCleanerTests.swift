import Foundation

@main
enum TestRunner {
    static var passed = 0
    static var failed = 0

    static func check(_ name: String, _ actual: String, _ expected: String) {
        if actual == expected {
            passed += 1
            print("  ✓ \(name)")
        } else {
            failed += 1
            print("  ✗ \(name)")
            print("    expected: \(expected.debugDescription)")
            print("    actual:   \(actual.debugDescription)")
        }
    }

    static func main() {
        // --- Block-quote marker stripping ---

        print("Block-quote markers:")

        check("strips ▎ prefix from wrapped lines",
            TextCleaner.clean(
                " ▎ Seeing intermittent 500s on the books app — queries are getting cancelled with 40001: canceling statement due to conflict with\n" +
                "  ▎ recovery. The read replica appears to be disconnected. Error detail: \"User query may not have access to page data due to replica\n" +
                "  ▎ disconnect.\" Should resolve once the replica reconnects, but flagging in case anyone else is hitting this."
            ),
            "Seeing intermittent 500s on the books app — queries are getting cancelled with 40001: canceling statement due to conflict with recovery. The read replica appears to be disconnected. Error detail: \"User query may not have access to page data due to replica disconnect.\" Should resolve once the replica reconnects, but flagging in case anyone else is hitting this."
        )

        check("strips ▎ from single line",
            TextCleaner.clean(" ▎ Hello world"),
            "Hello world"
        )

        check("strips ▎ with varying leading whitespace",
            TextCleaner.clean("▎ Line one\n   ▎ Line two\n ▎ Line three"),
            "Line one Line two Line three"
        )

        check("preserves paragraphs between ▎ blocks",
            TextCleaner.clean(" ▎ First paragraph\n ▎ continues here.\n\n ▎ Second paragraph."),
            "First paragraph continues here.\n\nSecond paragraph."
        )

        // --- Basic cleaning (pre-existing behavior) ---

        print("\nBasic cleaning:")

        check("collapses extra whitespace",
            TextCleaner.clean("Hello    world"),
            "Hello world"
        )

        check("joins wrapped lines within a paragraph",
            TextCleaner.clean("Hello\nworld"),
            "Hello world"
        )

        check("preserves paragraph breaks",
            TextCleaner.clean("First paragraph.\n\nSecond paragraph."),
            "First paragraph.\n\nSecond paragraph."
        )

        check("normalizes Windows line endings",
            TextCleaner.clean("Hello\r\nworld"),
            "Hello world"
        )

        check("trims leading and trailing whitespace",
            TextCleaner.clean("  Hello world  "),
            "Hello world"
        )

        check("handles empty string",
            TextCleaner.clean(""),
            ""
        )

        check("leaves clean text unchanged",
            TextCleaner.clean("Already clean text."),
            "Already clean text."
        )

        // --- Summary ---

        print("\n\(passed + failed) tests, \(passed) passed, \(failed) failed")

        if failed > 0 {
            exit(1)
        }
    }
}

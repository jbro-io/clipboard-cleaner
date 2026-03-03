# ClipboardCleaner

A macOS menu bar app that strips formatting from your clipboard. When you copy rich text (from Slack, Notion, web pages, etc.), ClipboardCleaner converts it to plain text so you can paste without carrying over fonts, colors, and styles.

## Quick Start

```bash
bash build.sh           # build the app + zip
bash build.sh install   # copy to ~/Applications, enable auto-start, launch
```

## Usage

ClipboardCleaner lives in your menu bar with a clipboard icon.

- **Left-click** — cleans the clipboard immediately (strips formatting from current contents)
- **Right-click** — opens a menu to quit the app

The app also watches your clipboard and automatically strips formatting when it detects rich text.

## Download from Slack

If someone sent you `ClipboardCleaner.zip`:

1. Unzip it — you'll get `ClipboardCleaner.app`
2. Double-click to run (you may need to right-click → Open the first time to bypass Gatekeeper)
3. For auto-start on login, clone this repo and run `bash build.sh install`

## Uninstall

```bash
bash build.sh uninstall
```

This removes the app from `~/Applications`, removes the login LaunchAgent, and stops any running instance.

## Building from Source

Requires Xcode Command Line Tools (`xcode-select --install`).

```bash
git clone <repo-url>
cd clipboard-cleaner
bash build.sh
open ClipboardCleaner.app
```

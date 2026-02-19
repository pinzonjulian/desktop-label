# Desktop Label

A lightweight macOS menu bar app that shows a floating project name overlay on each Desktop/Space. Built for developers who juggle multiple projects across multiple desktops.

![macOS](https://img.shields.io/badge/macOS-13%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)

## Why?

macOS Spaces have no visual identity — they're just numbered slots. When you're deep in flow across 4+ projects with terminals, editors, and browser sessions everywhere, you lose track of which desktop you're on. Desktop Label fixes that with a small, always-visible, click-through pill that tells you exactly where you are.

## Features

- **Floating overlay** — translucent pill-shaped label pinned to a screen corner
- **Click-through** — never interferes with your workflow
- **Follows you across Spaces** — updates automatically when you switch desktops
- **Menu bar app** — no dock icon, stays out of the way
- **Settings UI** — add/remove/rename spaces, adjust position, font size, opacity, and colors
- **JSON config** — also editable at `~/.config/desktop-label/config.json`

## Install

```bash
git clone https://github.com/pinzonjulian/desktop-label.git
cd desktop-label
swift build -c release
mkdir -p ~/bin && cp .build/release/DesktopLabel ~/bin/
```

Then run `~/bin/DesktopLabel` or add it to your login items. Make sure `~/bin` is in your `PATH` if you want to run it by name.

## Usage

On first launch, a default config is created at `~/.config/desktop-label/config.json`:

```json
{
  "spaces": {
    "1": "project-a",
    "2": "project-b",
    "3": "personal"
  },
  "fontSize": 14,
  "opacity": 0.75,
  "position": "top-left",
  "backgroundColor": "#000000",
  "textColor": "#FFFFFF"
}
```

You can edit this file directly or use **🏷 → Settings…** in the menu bar.

### Menu bar options

| Item | Description |
|------|-------------|
| About Desktop Label | Links to repo and origin thread |
| Settings… (⌘,) | Open the settings UI |
| Reload Config (⌘R) | Reload config from disk |
| Quit (⌘Q) | Exit the app |

### Position options

`top-left` · `top-right` · `bottom-left` · `bottom-right`

## Uninstall

```bash
# Stop the app
pkill DesktopLabel

# Remove the binary
rm ~/bin/DesktopLabel

# Remove config and all app data
rm -rf ~/.config/desktop-label
```

If you added Desktop Label to your login items, remove it from **System Settings → General → Login Items**.

## How it works

Desktop Label uses macOS CoreGraphics private SPI (`CGSGetActiveSpace`, `CGSCopyManagedDisplaySpaces`) to detect the current Space — the same stable APIs used by [yabai](https://github.com/koekeishiya/yabai) and [SketchyBar](https://github.com/FelixKratz/SketchyBar). It listens for `activeSpaceDidChangeNotification` to update the label when you switch desktops.

## Origin

This project was built in a single [Amp](https://ampcode.com) session. See the [original thread](https://ampcode.com/threads/T-019c73ba-8aa6-75d6-8de8-cc3538fe7eb2).

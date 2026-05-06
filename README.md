<div align="right">

[中文](README_CN.md) | **English**

</div>

<div align="center">

<img src="https://raw.githubusercontent.com/Sanchez-77/molly-releases/main/assets/icon.png" width="128" height="128" alt="Molly">

# Molly

**Your AI coding buddy, right on your desktop.**

A desktop pet cat that reacts in real time to Claude Code's status.
Flips through books while thinking, types while working, celebrates when done — and purrs when you pet it.

[![Download](https://img.shields.io/github/v/release/Sanchez-77/molly-releases?label=Download&color=blue)](https://github.com/Sanchez-77/molly-releases/releases/latest)
[![macOS](https://img.shields.io/badge/macOS-13.0%2B-black)](https://github.com/Sanchez-77/molly-releases/releases/latest)

[**Download**](https://github.com/Sanchez-77/molly-releases/releases/latest) · [**Features**](#features) · [**Getting Started**](#getting-started)

</div>

---

## Features

### Multi-Agent Integration

Molly listens to hook events via Webhook and switches animations in real time. Supports **10 terminal AI agents** with one-click hook setup, managed from the settings page:

**Claude Code** · **Cursor** · **Gemini CLI** · **Qoder** · **Qwen Code** · **Factory** · **CodeBuddy** · **Codex** · **Kimi** · **OpenCode**

| AI Status | Molly Reaction |
|---|---|
| User submits prompt | Flips through books |
| Tool call in progress | Types on keyboard |
| Task complete | Happy celebration + sound |
| Waiting for approval | Permission panel pops up |
| Session ends | Dozes off |
| Idle too long | Falls asleep |

### 20+ Animations

#### Daily

| Idle | Stretch | Lick Paw | Sleep | Drink | Music |
|:---:|:---:|:---:|:---:|:---:|:---:|
| <img src="assets/gif/idle.gif" width="100"> | <img src="assets/gif/stretch.gif" width="100"> | <img src="assets/gif/lick.gif" width="100"> | <img src="assets/gif/sleep.gif" width="100"> | <img src="assets/gif/drink.gif" width="100"> | <img src="assets/gif/music.gif" width="100"> |

#### Interactive

| Poke | Pet | Drag | Typing |
|:---:|:---:|:---:|:---:|
| <img src="assets/gif/poke.gif" width="100"> | <img src="assets/gif/pet.gif" width="100"> | <img src="assets/gif/drag.gif" width="100"> | <img src="assets/gif/typing.gif" width="100"> |

#### Work & Status

| Search | Think | Working | Done | Notify |
|:---:|:---:|:---:|:---:|:---:|
| <img src="assets/gif/search.gif" width="100"> | <img src="assets/gif/think.gif" width="100"> | <img src="assets/gif/working.gif" width="100"> | <img src="assets/gif/done.gif" width="100"> | <img src="assets/gif/notify.gif" width="100"> |

### Edge Docking + Terminal Session Panel

<img src="assets/gif/dock.gif" width="600">

Drag to the screen edge to auto-dock. Hover to reveal the terminal session panel:

- Live status of all Claude sessions
- Click to jump to the corresponding terminal window (supports Terminal / iTerm2 / Kitty / WezTerm / Ghostty)
- Inline permission approval and option prompts — no workflow interruption
- Hydration reminder countdown integrated in the panel title bar

### Multi-Terminal Support

| Terminal | tty Jump | Window Title Match |
|---|---|---|
| Terminal.app | ✅ | ✅ |
| iTerm2 | ✅ | ✅ |
| Kitty | ✅ | - |
| WezTerm | ✅ | - |
| Ghostty | - | ✅ |

### Permission Interaction

- **Inline permission prompt** — Approve directly in the docked panel without leaving your workflow
- **Elicitation dialog** — When Claude asks a question, pick an option right from the popup
- **Permission hotkey** — Configurable modifier + key combo, no mouse needed
- **Auto-dismiss** — Approve in the editor and Molly's popup closes automatically

### Other Features

- **Sparkle auto-update** — Get notified when a new version is available
- **Lark notification listener** — Plays alert animation on Dock badge changes
- **Hydration reminder** — Custom intervals in seconds / minutes / hours
- **Process discovery** — Auto-detects AI sessions not registered via hooks
- **Drag & pet** — Drag to play, swipe back and forth to trigger purring animation

---

## Getting Started

### 1. Download & Install

Go to [Releases](https://github.com/Sanchez-77/molly-releases/releases/latest), download the latest zip, unzip and drag into your Applications folder.

### 2. Configure Hooks

Molly auto-detects installed AI agents and configures hooks on first launch. You can also manage hooks from the "AI Agents" tab in Settings.

For manual Claude Code setup, add the following to `hooks` in `~/.claude/settings.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [{ "hooks": [{ "type": "command", "command": "bash ~/.clawd/hook.sh thinking" }] }],
    "PreToolUse": [{ "hooks": [{ "type": "command", "command": "bash ~/.clawd/hook.sh working" }] }],
    "Stop": [{ "hooks": [{ "type": "command", "command": "bash ~/.clawd/hook.sh attention" }] }],
    "SessionStart": [{ "hooks": [{ "type": "command", "command": "bash ~/.clawd/hook.sh idle" }] }],
    "SessionEnd": [{ "hooks": [{ "type": "command", "command": "bash ~/.clawd/hook.sh sleeping" }] }]
  }
}
```

### 3. Start Using

Launch Molly → Drag to the right edge of the screen → Open a terminal with Claude Code → Molly comes alive.

---

## How It Works

```
Claude Code ──Hook Event──→ hook.sh ──HTTP──→ Molly Webhook (port 23333)
                                                    │
                                          ┌─────────┼─────────┐
                                          ▼         ▼         ▼
                                     Animations  Session   Permission
                                                  Panel     Prompt
```

---

## Requirements

- macOS 13.0+
- Claude Code (with hooks configured)

---

<div align="center">
<sub>Made with ❤️ and Claude</sub>
</div>

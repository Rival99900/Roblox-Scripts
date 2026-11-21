# 🕵️ RobloxSpy

**Remote spy, instance explorer, script viewer and session recorder for Roblox — in one script.**

A fusion of [SimpleSpy](https://github.com/exxtremestuffs/SimpleSpySource), [DarkDEX V5](https://github.com/AZYsGithub/DarkDEX-V5) and [Cobalt](https://gitlab.com/cobalt-roblox/cobalt), rebuilt from scratch with a custom GUI, 21 languages, PC + mobile support and wide executor compatibility.

![Version](https://img.shields.io/badge/version-1.1.0-blue)
![Luau](https://img.shields.io/badge/language-Luau-00A2FF)
![Platforms](https://img.shields.io/badge/platforms-PC%20%7C%20Mobile-brightgreen)
![Languages](https://img.shields.io/badge/UI%20languages-21-orange)

> ✅ **Status:** v1.1.0 tested in-game by the author on **Delta** (PC + iPhone). Other executors are supported through feature detection but have not all been tested.

---

## 🎉 What's new in v1.1.0

- **Single instance + Unload:** running the script again replaces the old copy; *Settings → Tools → Unload* removes every hook and the GUI cleanly
- **Anti-flood & grouping:** identical calls collapse into one `×N` row, spammy remotes are capped per second
- **More capture:** `InvokeServer` return values, `OnClientInvoke` (server → client) and `BindableEvent` / `BindableFunction` (all toggleable)
- **Per-remote stats** (total, rate, first/last, callers), **arg diff** against the previous call, **keyword alerts**
- **Watch list** and ignore / block lists **saved per game**
- **Export a whole session as a replay script** (with `task.wait` gaps)
- **New ⚠ Errors tab** collecting RobloxSpy's own internal errors
- **Drawn icons** (close, maximize, minimize, tabs), reopen button with an **unread counter**, **RightShift** keybind on PC
- **Mobile:** bottom tab bar, bigger rows and buttons; **tooltips** everywhere (long-press on mobile); empty-state messages
- **Appearance:** accent color, window transparency, text size
- Faster Explorer (incremental refresh), lighter append-only auto-save, connection-leak fixes

A "What's new" popup is shown once after updating (reopen it from *Settings → Tools*).

---

## 🚀 Quick start

Paste this into your executor:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Rival99900/Roblox-Scripts/refs/heads/main/RobloxSpy/loader.lua"))()
```

The loader downloads the single-file bundle (`dist/RobloxSpy-bundle.lua`) and runs it.

**Offline / local use:** copy `dist/RobloxSpy-bundle.lua` into your executor's script box (or its `workspace` folder) and execute it — it contains every module, no other file is needed.

---

## ✨ Features

### 🛰 Remote Spy
- Live capture of `FireServer`, `InvokeServer` and `OnClientEvent` (incl. `UnreliableRemoteEvent`)
- Optional: `InvokeServer` **return values**, `OnClientInvoke`, `BindableEvent` / `BindableFunction`
- **Grouping ×N** of identical consecutive calls, **anti-flood** limit per remote
- **Stats** per remote, **diff** vs the previous call (changed args in yellow), **keyword alerts**
- **Detail panel** for every event: remote, class, method, direction, path, calling script, call number, timestamp, status, every argument with its type and full value
- **R2S (Remote-to-Script)** code generated for each outgoing call, and a `firesignal` replay snippet for incoming events
- Actions: 📋 copy code · 🧭 copy path · 📦 copy args · 🔁 re-fire · 🔇 ignore (stop logging) · ⛔ block calls (never reach the server) · 🗑 delete
- ⭐ Watch list · ignore / block lists saved **per game**
- Filters (All / Fire / Invoke / Incoming / ClientInvoke / Bindable / Watched / Blocked), live text search, pause / resume / clear
- ⛶ **Expand** button to read an event full-screen

### 🗂 Explorer (DarkDEX-style)
- Live game tree with class icons, lazy expansion, **nil instances** root
- **Deep search** across the whole game (results with full paths)
- **Editable properties**: booleans, numbers, strings, `Color3`, `Vector3`, attributes
- Attributes and CollectionService tags
- Actions: copy path · copy as code · teleport · view source · clone · destroy (client side)

### 📶 Network Monitor
- Total calls, calls/sec, unique remotes, blocked count
- 60-second traffic graph and top-10 most active remotes (click a row to filter the spy)

### 🧾 Script Viewer
- **Background scan** (no freeze) from `getscripts`, `getloadedmodules`, `getrunningscripts`, `getnilinstances` and the full game tree — deduplicated
- Filters: All / Local / Module / Running + text search
- Virtualized list (tens of thousands of entries, no lag), CoreGui internals skipped, adaptive layout (side by side / stacked)
- Clear message when a script can't be decompiled (reason from the executor)
- Decompile (`decompile` → `getsourcecode` → `.Source` fallbacks) with line numbers, no size limit
- Copy source or save it as `.lua`

### 🕘 Session History
- Every play session is recorded (JSON) and listed: game, date, duration, calls, remotes, player, executor
- 🔴 live session always shown first, 📍 badge for sessions of the current game
- Open a session to browse its entries, export it as `.txt` or copy it
- **Search across all saved sessions** at once
- 🧾 **Export as script**: replay a whole session in order

### ⚠ Errors
- Internal RobloxSpy errors, deduplicated with a counter — copy all / clear

### 🛠 Settings
- 🌐 **21 languages** (drop-down) — auto-detected from your Roblox language, saved between runs
- 💾 Save logs (`.txt` readable + R2S, `.json`, `.csv`) into a folder of your choice
- 🔁 **Auto-save** to that folder every 30 s / 1 / 5 / 10 min (append-only, split into parts)
- 📋 Copy logs to clipboard (fallback when the executor can't write files)
- Toggles: log incoming events, auto-scroll, pause capture
- Capture: returns, OnClientInvoke, Bindables, grouping, anti-flood limit
- Alerts: keyword list
- Appearance: accent (blue / purple / green / red / orange), transparency, text size, bottom tabs (mobile), keybind (PC)
- Tools: export session as script, What's new, Unload
- 📐 Window size presets (Small / Medium / Large)
- Executor capability report

### 🎨 Interface
- **100% custom GUI** — no Rayfield, no external UI library
- Dark theme, toast notifications for every action
- Drawn vector-style icons (no emoji dependency for window controls and tabs)
- Drag, resize, maximize, minimize, close → round button to reopen, with an unread counter
- PC keybind (default **RightShift**) to show / hide
- Tooltips on every icon button (hover on PC, long-press on mobile)
- Dragging never moves the camera/character, and the window and button **never leave the screen** (PC and mobile, any rotation)
- Mobile: icon tabs at the bottom, bigger rows and touch targets

---

## 🌐 Languages

English · Français · Deutsch · Español · Português · Русский · Italiano · Nederlands · Polski · 中文 · 日本語 · Türkçe · 한국어 · العربية · Tiếng Việt · Svenska · Ελληνικά · Română · Українська · Čeština · Dansk

The interface, notifications, event labels and generated-code comments are translated. Missing strings fall back to English.

---

## 🖥️ Executor compatibility

RobloxSpy detects what your executor offers and adapts. Minimum: `loadstring` + `game:HttpGet`.

| Function | Used for | If missing |
|---|---|---|
| `hookmetamethod` + `getnamecallmethod` | Outgoing call capture (preferred) | Falls back to `hookfunction` |
| `hookfunction` | Outgoing call capture (fallback) | Only incoming events are logged |
| `setnamecallmethod` | Extra safety in the hook | Skipped |
| `getconnections` | Safe incoming listener | 10 s delay before listening |
| `getcallbackvalue` | `OnClientInvoke` capture | Option disabled |
| `writefile` / `readfile` / `listfiles` | Saves, auto-save, history | Clear error message, use *Copy logs* |
| `setclipboard` | Copy buttons | Error notification |
| `decompile` | Script viewer | Fallbacks, then a message |
| `getnilinstances`, `getscripts`… | Explorer / scanner extras | Skipped |

Targets: Delta, Wave, Solara, Volt, Real and others.

**Where are files saved?** In your executor's `workspace` folder (PC: `<Executor>/workspace`, iPhone/Android: the executor's folder in the Files app), under the folder set in Settings (default `RobloxSpy/exports`). Sessions go to `RobloxSpy/sessions`, settings to `RobloxSpy/config`.

---

## 🛡️ How it works

### Hooking
1. **Preferred:** `hookmetamethod(game, "__namecall", …)`. The hook never makes a `:` method call before handing control back to the game — such a call would overwrite the current namecall method and turn the game's `FireServer`/`InvokeServer` into something else. Type checks use `.ClassName` only.
2. **Fallback:** `hookfunction` on `FireServer` / `InvokeServer`, always calling the true original.
3. The hook only **queues** the call. Serialization, session recording and GUI updates run later in a Heartbeat loop owned by the executor thread, so the game's call is never slowed down or broken.

### Incoming events
Roblox hands queued server messages to the **first** `OnClientEvent` listener. To avoid stealing them (which breaks lobbies, shops, etc.), RobloxSpy only listens to a remote once the game itself is already listening (`getconnections`).

### R2S example
```lua
-- RobloxSpy — Remote-to-Script
local remote = game:GetService("ReplicatedStorage").Events.BuyItem
remote:FireServer("Sword", 3, true)
```
Supported types include `string`, `number`, `boolean`, `nil`, `Instance`, `Vector3`, `CFrame`, `Color3`, `BrickColor`, `UDim2`, `EnumItem` and nested tables.

---

## 📦 Project structure

```
RobloxSpy/
├── loader.lua                ← loadstring entry point (downloads dist/ bundle)
├── dist/
│   └── RobloxSpy-bundle.lua  ← single-file build (all modules)
├── init.lua                  ← main entry: window, tabs, history, settings, auto-save
├── core/
│   ├── compat.lua            ← executor detection & safe wrappers
│   ├── config.lua            ← persistent settings
│   ├── i18n.lua              ← 21-language translations
│   ├── errors.lua            ← internal error log (Errors tab)
│   ├── serializer.lua        ← value → Lua code, R2S generator
│   ├── hooks.lua             ← __namecall / hookfunction engine + capture queue
│   └── session.lua           ← session recording, history, search, export
├── gui/
│   ├── framework.lua         ← window, tabs, drag/clamp, toasts, maximize
│   ├── theme.lua             ← colors, accents, fonts, text scale
│   ├── icons.lua             ← drawn icons (window controls, tabs, actions)
│   └── components/
│       ├── log-entry.lua     ← event row
│       └── search-bar.lua    ← search input
├── modules/
│   ├── remote-spy.lua        ← feed + detail panel
│   ├── explorer.lua          ← DarkDEX-style explorer
│   ├── network-monitor.lua   ← traffic dashboard
│   └── script-viewer.lua     ← scanner / decompiler
└── utils/
    └── search.lua            ← search helpers
```

About 15,000 lines of Luau in the bundle (a large part are translations).

---

## ❓ FAQ

**The game breaks / behaves strangely.** Turn off *Capture InvokeServer returns* and *OnClientInvoke* in Settings → Capture, then use Unload and re-run.

**Some calls are missing.** Check the anti-flood limit and the status bar's "skipped" counter; raise the limit or set it to Off.

**How do I close it completely?** Settings → Tools → Unload. Running the loader again also replaces the old instance.

**Settings reset after updating?** Settings are kept; only the "What's new" popup appears once.

---

## 📜 Changelog

- **1.1.0** — single instance, Unload, anti-flood + grouping, returns / OnClientInvoke / Bindables capture, stats, diff, alerts, per-game lists, session replay export, Errors tab, drawn icons, keybind, mobile bottom tabs, appearance options, tooltips, empty states, performance and leak fixes
- **1.0.0** — first public release: remote spy, explorer, network monitor, script viewer, session history, 21 languages

---

## ⚠️ Disclaimer

- The loader sends **anonymous usage statistics** to [ScriptBlox](https://scriptblox.com) analytics: executor name, platform, PlaceId, session events and a SHA-256 hash of your UserId (no username). Run `dist/RobloxSpy-bundle.lua` directly to avoid it
- For **educational and research purposes** only
- No guarantee of safety or undetectability; server-side checks still apply
- The authors are not responsible for bans or any other consequences

---

## 🏷️ Credits

- **Created by** Rival960 with the help of Claude
- **Inspired by** SimpleSpy, DarkDEX V5 and Cobalt
- **Version** 1.0.0

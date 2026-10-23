# Roblox Scripts Hub

A collection of Roblox exploit scripts for various games, featuring multilingual support and a Rayfield UI.

## 📚 Repository Overview

This repository contains Roblox exploit scripts created by **Rival960**, using the **Rayfield UI** library and the **Luau** scripting language.

### Current Available Scripts

#### 🔴 SCP vs Guard Hub
**Game**: [Be an SCP or Guard](https://www.roblox.com/games/121461214257813/Be-an-SCP-or-Guard)

An exploit hub for the SCP Foundation roleplay game, with gameplay and utility tools for both Guards and SCPs.

**Key Features**:
- **Enemy ESP** - Team-based filtering with health display
- **Silent Aim** - Triggered on weapon fire, with FOV-based targeting
- **Flight** - PC and mobile controls with adjustable speed
- **NoClip** - Walk through walls and obstacles
- **Ban Broadcast Listener** - Listens for ban broadcast events and prints a console message (see [Safety & Limitations](#%EF%B8%8F-safety--limitations))
- **Doors Control** - Bulk facility door and checkpoint management
- **Fullbright** - Raises brightness and disables global shadows
- **21 languages** - Multilingual interface

### Installation & Usage

#### Method 1: Direct Execution (Recommended)

1. **Open your Roblox exploit executor** (Wave, Delta, Hydrogen, Codex, Solara, etc.)
2. **Join the game**: "Be an SCP or Guard" on Roblox
3. **Paste this command** into your executor:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Rival99900/Roblox-Scripts/refs/heads/main/scripts/Be-an-SCP-or-Guard-KEYLESS.lua"))()
```

4. **Press Execute** - The GUI loads with the Rayfield UI

#### Method 2: Manual Execution

1. Copy the complete script from `scripts/Be-an-SCP-or-Guard-KEYLESS.lua`
2. Paste into your executor
3. Execute in-game

#### Method 3: Local Hosting

If hosting locally:
```lua
loadstring(readfile("path/to/Be-an-SCP-or-Guard-KEYLESS.lua"))()
```

---

## 🎮 Features Breakdown

### Vision & ESP Module
- **Enemy Detection** - Highlights players on the opposing team
- **Team Filtering** - Ignores teammates
- **Role Identification** - SCP vs Human player detection
- **Health Display** - HP shown on player tags
- **Billboard Info Tags** - Floating player information

### Movement & Flight System
- **PC & Mobile Flight** - Keyboard and touch controls
- **Adjustable Fly Speed** - From 10 to 300 studs/second
- **NoClip Mode** - Disables collisions to pass through walls
- **Walk Speed** - Adjustable base movement speed
- **Camera-Based Movement** - WASD + Space/Shift, relative to the camera

### Combat & Silent Aim
- **Fire-Triggered Aiming** - Active only while attacking
- **FOV-Based Targeting** - Targets within a configurable field of view
- **Distance Setting** - Maximum aim distance (20-300 studs)
- **FOV Setting** - Targeting radius (10-200 pixels)
- **Hitbox Expansion** - Enlarges enemy hitboxes up to 10x
- **Freeze Ammo** - Keeps ammunition from decreasing

### Facility Control
- **Bulk Door Operations** - Open/close doors together
- **Multiple Interaction Methods** - ProximityPrompts, ClickDetectors and RemoteEvents
- **Checkpoint Interaction** - Interacts with checkpoints by name
- **Recursive Scanning** - Finds doors nested in the workspace

### Visual Enhancements
- **Fullbright** - Raises lighting brightness and disables global shadows. It also sets the in-game clock to a fixed time (14:00); there is no day/night cycle

### Additional Tools
- **Teleport to Closest Enemy** - Moves your character to the nearest target
- **Walk Speed Reapply** - Applies the chosen walk speed again after respawn
- **Language Selector** - Switches between 21 languages (the full UI updates after re-executing the script)

---

## 🌍 Supported Languages

| Language | Code | Language | Code |
|----------|------|----------|------|
| English | EN | German | DE |
| Français | FR | Español | ES |
| Português | PT | Русский | RU |
| Italiano | IT | Nederlands | NL |
| Polski | PL | 中文 | ZH |
| 日本語 | JA | Türkçe | TR |
| 한국어 | KO | العربية | AR |
| Tiếng Việt | VI | Svenska | SV |
| Ελληνικά | EL | Română | RO |
| Українська | UK | Čeština | CS |
| Dansk | DA | | |

---

## ⚙️ Technical Architecture

### Core Framework
- **UI Library**: Rayfield (loaded from `sirius.menu/rayfield`)
- **Language**: Luau (Roblox's scripting language)
- **Services**: Players, RunService, UserInputService, Workspace, ReplicatedStorage, Lighting

### Implementation Notes
- **Main loop** - `RunService` loop that updates features every frame
- **pcall wrapping** - Some operations are wrapped in `pcall` to avoid stopping the script on an error
- **Entity scanning** - Scans players and workspace objects to find targets and doors

### Safety Checks
- **Team Filtering** - `isEnemy()` decides whether a player is treated as an enemy
- **Role Detection** - `isPlayerSCP()` identifies SCP players
- **Ban Event Listener** - Connects to the `BroadcastBan` event and prints a message

---

## 🎯 Gameplay Guides

### Playing as a Guard

**Suggested setup**:
1. Enable ESP to locate SCPs
2. Enable Silent Aim for combat
3. Enable Fullbright for visibility in the facility
4. Use Teleport to Closest Enemy to engage quickly
5. Use the door controls to contain SCP breaches

**Tips**:
- Stay in groups
- Use flight to reach high positions
- Control key checkpoints

### Playing as an SCP

**Suggested setup**:
1. Enable Fly to move quickly
2. Enable NoClip to reach hidden passages
3. Use ESP to track guard movements
4. Use the door controls to seal areas

**Tips**:
- Use flight for vertical positions
- Use NoClip to reach hiding spots

---

## 🛡️ Safety & Limitations

**This script does not protect your account.** The "Ban Broadcast Listener" only listens for the `BroadcastBan` event and prints a message in the console. It does not block, undo or prevent any ban. Nothing in this script guarantees that you will not be banned.

### Best Practices
- **Use a separate account** if you are worried about losing your main account
- **Vary your playstyle** - Mix script usage with normal gameplay
- **Limit active time** - Don't run the script continuously
- **Share wisely** - Don't give your credentials to others

### Known Limitations
- Door and checkpoint detection relies mostly on object names, so some doors may not be detected
- Server-side checks can block or undo local effects
- Silent Aim effectiveness depends on network latency
- Hitbox expansion may behave differently with some models
- Changing language requires re-executing the script to update the full UI

---

## ⌨️ Control Reference

### Flight Controls
```
W / ↑ Arrow    - Move forward
S / ↓ Arrow    - Move backward
A / ← Arrow    - Move left
D / → Arrow    - Move right
Space          - Move up
Left Shift     - Move down
Mouse          - Look around (camera)
```

### Game Mechanics
```
Left Mouse Click  - Fire weapon / Use tool
Tool/Weapon       - Equipped in character
Movement Input    - Standard Roblox WASD
Camera Input      - Standard Roblox mouse movement
```

---

## 🎛️ Settings & Configuration

### Default Settings

```lua
Settings = {
    ESP_Dynamic = true,          -- Enable/disable ESP
    Fly = false,                 -- Flight mode
    FlySpeed = 50,               -- Flight velocity (10-300)
    NoClip = false,              -- Collision bypass
    Fullbright = false,          -- Brightness boost
    SilentAim = false,           -- Auto-aiming
    SilentAimMaxDist = 120,      -- Max aim distance (20-300)
    SilentAimFov = 60,           -- FOV size (10-200)
    FreezeAmmo = true,           -- Freeze ammunition
    AntiBan = true,              -- Ban broadcast listener (prints a message only)
    Hitbox_Enabled = false,      -- Hitbox expansion
    HitboxSize = 2,              -- Hitbox multiplier (2-10)
    WalkSpeed = 16,              -- Base movement speed
}
```

### Example Configurations

**Beginner**:
- Fly Speed: 75 studs/s
- Walk Speed: 40
- Silent Aim: Disabled
- Fullbright: Enabled
- ESP: Enabled

**Advanced**:
- Fly Speed: 150 studs/s
- Walk Speed: 100
- Silent Aim: Enabled (Dist: 150, FOV: 80)
- Hitbox: Enabled (Size: 5x)
- Fullbright: Disabled

**Low-visibility**:
- Fly Speed: 50 studs/s
- Walk Speed: 16 (normal)
- Silent Aim: Disabled
- Fullbright: Disabled
- ESP: Disabled

---

## 🐛 Troubleshooting

### Script Won't Load

**Problem**: GUI doesn't appear after execution

**Solutions**:
1. Verify you're in-game (not the main menu)
2. Wait a few seconds for Rayfield to load
3. Check your internet connection
4. Try a different executor
5. Make sure your executor is up to date

### Features Not Working

**Problem**: A toggle doesn't seem to activate a feature

**Solutions**:
1. Make sure the toggle is ON
2. Check that your character exists (respawn if needed)
3. For ESP: make sure enemies are nearby
4. For Fly: your character must be alive
5. Re-execute the script if it is stuck

### Performance Issues / Lag

**Solutions**:
1. Disable Fullbright
2. Disable ESP
3. Reduce Fly Speed
4. Close background applications
5. Lower the game's graphics settings

### Account Bans

No feature in this script prevents bans. To reduce risk:
1. Don't use exploits excessively
2. Mix normal gameplay with script usage
3. Don't repeatedly target the same player
4. Use a separate account if you are worried

---

## 📊 System Requirements

### Minimum Requirements
- **OS**: Windows, macOS, or Linux
- **Executor**: A Roblox exploit executor that is up to date
- **RAM**: 2 GB minimum
- **Internet**: Stable connection required

---

## 🔄 Version

### Current Version: 1.0.0

**Status**: untested in-game

**What's Included**:
- Hub with the features listed above
- 21-language interface
- Rayfield UI with 6 tabs

**Known Limitations**:
- See [Known Limitations](#known-limitations)

---

## 📞 Support & Communication

### How to Get Help

**GitHub Issues**:
- Report bugs with detailed information
- Include executor and OS information
- Describe the steps to reproduce the issue
- Attach screenshots if applicable

**Direct Contact**:
- **Discord**: rival960
- **GitHub**: @Rival99900
- **YouTube**: rival9607

### Reporting Issues

When reporting issues, include:
```
- Executor: (Wave/Delta/Hydrogen/etc)
- Operating System: (Windows/Mac/Linux)
- Script Version: (1.0.0)
- Issue Description: (Detailed description)
- Steps to Reproduce: (1. ... 2. ... 3. ...)
- Error Message: (If any)
- Screenshots/Video: (If helpful)
```

---

## 👥 Contributing

1. **Fork the repository** on GitHub
2. **Create a feature branch**: `git checkout -b feature/YourFeature`
3. **Make your changes** with clear commit messages
4. **Push to the branch**: `git push origin feature/YourFeature`
5. **Open a Pull Request** with a description of the changes

### Contribution Guidelines
- Follow the existing code style
- Add comments for complex logic
- Test your changes in-game and say what you tested
- Update the documentation if needed

---

## ⚠️ Disclaimer & Legal

### Educational Purpose Only

This project is provided **for educational purposes only**. By using it, you agree that you:

- Are responsible for complying with Roblox's Terms of Service
- Accept the risks, including account bans or suspension
- Are responsible for your own decisions about script usage
- Are responsible for any consequences of using the script

**The creator assumes no liability for**:
- Account bans or suspensions
- Data loss or account compromise
- Game updates breaking compatibility
- Any other consequences of usage

### Your Responsibility

By using this script, you agree to:
- Use it responsibly
- Not harm other players' experience
- Follow game rules and guidelines
- Accept all risks involved

---

## 📄 License & Attribution

This project is provided as-is, without a specific license.

### Creator Information
- **Creator**: Rival960
- **Developer Accounts**:
  - Discord: `rival960`
  - GitHub: [@Rival99900](https://github.com/Rival99900)
  - YouTube: `rival9607`

### Acknowledgments
- **Rayfield UI Library** - UI framework used by the script

---

## 🎉 Getting Started

### Quick Start

1. Join the "Be an SCP or Guard" game on Roblox
2. Open your exploit executor
3. Paste and execute:
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Rival99900/Roblox-Scripts/refs/heads/main/scripts/Be-an-SCP-or-Guard-KEYLESS.lua"))()
```
4. Wait for the GUI to load

---

## 📚 Additional Resources

### Learning Luau
- [Roblox Luau Documentation](https://roblox.github.io/luau/)
- [Roblox API Reference](https://developer.roblox.com/en-us/api-reference)

---

## ⭐ Repository Stats

- **Current Version**: 1.0.0
- **Supported Games**: 1 (Be an SCP or Guard)
- **Languages**: 21
- **Script Length**: 1,275 lines
- **Status**: working

---

**Last Updated**: October 21, 2026
**Maintained By**: Rival960

---

## 📞 Contact

- **Discord**: rival960
- **GitHub**: [@Rival99900](https://github.com/Rival99900)
- **YouTube**: [rival9607](https://youtube.com/@rival9607)

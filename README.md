# Roblox Scripts Hub

A comprehensive collection of advanced exploit scripts for various Roblox games, featuring multilingual support, robust security, and user-friendly interfaces.

## 📚 Repository Overview

This repository contains professionally-developed Roblox exploit scripts created by **Rival960**, leveraging the **Rayfield UI Framework** for intuitive user experience and **Luau** scripting language for optimal performance.

### Current Available Scripts

#### 🔴 SCP vs Guard Hub Pro
**Game**: [Be an SCP or Guard](https://www.roblox.com/games/121461214257813/Be-an-SCP-or-Guard)

A feature-rich exploit hub designed specifically for the SCP Foundation roleplay game, providing gameplay enhancements and utility tools for both Guards and SCPs.

**Key Features**:
- **Dynamic Enemy ESP** - Strict team-based filtering with real-time health displays
- **Balanced Silent Aim** - Weapon-fire triggered auto-aiming with FOV-based targeting
- **Universal Flight System** - PC & Mobile compatible flying with adjustable speed
- **NoClip Traversal** - Walk through walls and obstacles
- **Anti-Ban Protection** - Built-in safety mechanisms to prevent account bans
- **Doors Control** - Bulk facility door and checkpoint management
- **Fullbright Mode** - Enhanced visibility with dynamic lighting
- **21-Language Support** - Complete multilingual interface

### Installation & Usage

#### Method 1: Direct Execution (Recommended)

1. **Open your Roblox exploit executor** (Wave, Delta, Hydrogen, Codex, Solara, etc.)
2. **Join the game**: "Be an SCP or Guard" on Roblox
3. **Paste this command** into your executor:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Rival99900/Roblox-Scripts/refs/heads/main/scripts/Be-an-SCP-or-Guard-KEYLESS.lua"))()
```

4. **Press Execute** - The GUI will load automatically with Rayfield UI

#### Method 2: Manual Execution

1. Copy the complete script from `Be-an-SCP-or-Guard-KEYLESS.lua`
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
- **Dynamic Enemy Detection** - Automatically identifies and highlights enemies
- **Strict Team Filtering** - Never targets or affects teammates
- **Role-Based Identification** - SCP vs Human player detection
- **Health Display** - Real-time HP information on nameplates
- **Billboard Info Tags** - Floating player information displays
- **Proximity-Based Alerts** - Visual indicators for nearby threats

### Movement & Flight System
- **Universal PC & Mobile Fly** - Works on all platforms seamlessly
- **Adjustable Fly Speed** - Customizable from 10 to 300 studs/second
- **NoClip Mode** - Bypass collision detection for wall traversal
- **Independent Walk Speed** - Modify base movement speed
- **Camera-Based Movement** - Smooth directional input using WASD + Space/Shift

### Combat & Silent Aim
- **Weapon-Fire Triggered Aiming** - Activates only during active attacks
- **FOV-Based Target Acquisition** - Smart targeting within configurable field of view
- **Distance Customization** - Adjust maximum aiming range (20-300 studs)
- **FOV Adjustment** - Fine-tune targeting radius (10-200 pixels)
- **Clean Hitbox Expansion** - Expand enemy hitboxes up to 10x for easier targeting
- **Infinite Ammo Support** - Freeze ammo for unlimited ammunition

### Facility Control
- **Bulk Door Operations** - Open/close all doors simultaneously
- **Multi-Detection Methods** - Works with ProximityPrompts, ClickDetectors, and RemoteEvents
- **Checkpoint Hacking** - Automatic security checkpoint interaction
- **Recursive Scanning** - Detects nested door structures in workspace

### Visual Enhancements
- **Fullbright Mode** - Remove darkness and shadows for maximum visibility
- **Dynamic Lighting Control** - Automatic day/night cycle management
- **Shadow Removal System** - Eliminate shadows for better visibility
- **Global Brightness Adjustment** - Complete lighting control

### Additional Tools
- **Teleport to Closest Enemy** - Instantly move to nearest target
- **Auto Walk Speed Sync** - Automatic speed application on respawn
- **Language Selector** - Switch between 21 languages dynamically

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
- **UI Library**: Rayfield (Keyless Implementation)
- **Language**: Luau (Roblox's scripting language)
- **Services**: Players, RunService, UserInputService, Workspace, ReplicatedStorage, Lighting

### Optimization Features
- **RenderStepped Loop** - 60 FPS compatible main execution loop
- **PCall Safety Wrapping** - Comprehensive error handling throughout
- **Efficient Entity Filtering** - Optimized player and object scanning
- **Minimal Memory Footprint** - Low CPU and RAM usage

### Security Implementation
- **Strict Team Filtering** - `isEnemy()` function prevents friendly fire
- **Role-Based Detection** - `isPlayerSCP()` identifies SCP players
- **Ban Protection Events** - Intercepts ban broadcast signals
- **Safe Operation Wrapping** - All critical operations protected with pcall blocks

---

## 🎯 Gameplay Guides

### Playing as a Guard

**Recommended Setup**:
1. Enable Dynamic ESP to locate SCPs
2. Activate Silent Aim for combat advantage
3. Enable Fullbright for facility visibility
4. Use TP to Closest Enemy for quick engagement
5. Control doors to contain SCP breaches

**Strategy Tips**:
- Stay in groups for safety
- Use flight to reach high positions
- Control key checkpoints
- Protect the facility entrance

### Playing as an SCP

**Recommended Setup**:
1. Enable Fly to navigate quickly
2. Activate NoClip for hidden passages
3. Use ESP to track guard movements
4. Control doors to seal areas
5. Hunt strategically

**Strategy Tips**:
- Use flight for vertical advantage
- Find hiding spots with NoClip
- Avoid early detection
- Hunt aggressively late game

---

## 🛡️ Safety & Security

### Anti-Ban Features
- **Event Interception** - Monitors ban broadcast events
- **Safe Execution** - All operations wrapped in protective pcall blocks
- **Legitimate Integration** - Uses standard game mechanics
- **No Game-Breaking Mods** - Respects game structure

### Best Practices
- **Use Fresh Account** - Better for long-term safety
- **Vary Playstyle** - Mix script usage with normal gameplay
- **Enable Anti-Ban** - Always keep this feature activated
- **Limit Active Time** - Don't run continuously 24/7
- **Share Wisely** - Don't give credentials to others

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
    FreezeAmmo = true,           -- Infinite ammo
    AntiBan = true,              -- Ban protection
    Hitbox_Enabled = false,      -- Hitbox expansion
    HitboxSize = 2,              -- Hitbox multiplier (2-10)
    WalkSpeed = 16,              -- Base movement speed
}
```

### Recommended Configurations

**Beginner Profile**:
- Fly Speed: 75 studs/s
- Walk Speed: 40
- Silent Aim: Disabled
- Fullbright: Enabled
- ESP: Enabled

**Advanced Profile**:
- Fly Speed: 150 studs/s
- Walk Speed: 100
- Silent Aim: Enabled (Dist: 150, FOV: 80)
- Hitbox: Enabled (Size: 5x)
- Fullbright: Disabled

**Stealth Profile**:
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
1. Verify you're in-game (not main menu)
2. Wait 3-5 seconds for Rayfield to load
3. Check internet connection
4. Try a different executor
5. Make sure executor is up-to-date

### Features Not Working

**Problem**: Toggle doesn't seem to activate feature

**Solutions**:
1. Ensure feature toggle is ON (blue)
2. Check if character exists (press R to respawn)
3. For ESP: Make sure enemies exist nearby
4. For Fly: Character must be alive
5. Re-execute script if stuck

### Performance Issues / Lag

**Problem**: Script causes game lag or freezing

**Solutions**:
1. Disable Fullbright (heavy on rendering)
2. Disable Dynamic ESP (uses resources)
3. Reduce Fly Speed to 50-75
4. Close background applications
5. Lower game graphics settings

### Ban Concerns

**Problem**: Account getting banned or flagged

**Prevention**:
1. Enable Anti-Ban protection
2. Don't use exploits excessively
3. Mix normal gameplay with script usage
4. Don't target same player repeatedly
5. Vary your behavior patterns
6. Use separate account if worried

---

## 📊 System Requirements

### Minimum Requirements
- **OS**: Windows, macOS, or Linux
- **Executor**: Any updated Roblox exploit executor
- **RAM**: 2GB minimum
- **Internet**: Stable connection required
- **Browser**: Any modern browser (for Roblox)

### Recommended Setup
- **OS**: Windows 10/11 or macOS Monterey+
- **Executor**: Wave, Delta, or Solara
- **RAM**: 4GB+
- **Processor**: Intel i5 equivalent or better
- **Internet**: 50+ Mbps connection

---

## 🔄 Update & Version History

### Current Version: 1.0.0

**Release Date**: October 21, 2026

**Status**: ✅ Production Ready

**What's Included**:
- ✅ Complete hub implementation
- ✅ All major gameplay features
- ✅ 21-language multilingual support
- ✅ Rayfield UI with 6 customizable tabs
- ✅ Anti-ban protection system
- ✅ Optimized performance loop
- ✅ Professional documentation

**Known Limitations**:
- Hitbox expansion may vary with custom SCP models
- Some specialized door types may require manual activation
- Silent Aim effectiveness depends on network latency
- Language switching requires script re-execution for full UI update

---

## 📞 Support & Communication

### How to Get Help

**GitHub Issues**:
- Report bugs with detailed information
- Include executor and OS information
- Describe steps to reproduce issue
- Attach screenshots if applicable

**GitHub Discussions**:
- Ask general questions
- Share tips and tricks
- Discuss gameplay strategies
- Community support available

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

We welcome contributions! Here's how to help:

1. **Fork the repository** on GitHub
2. **Create feature branch**: `git checkout -b feature/YourFeature`
3. **Make your changes** with clear commit messages
4. **Push to branch**: `git push origin feature/YourFeature`
5. **Open Pull Request** with detailed description

### Contribution Guidelines
- Follow existing code style
- Add comments for complex logic
- Test thoroughly before submitting
- Update documentation if needed
- Keep commits focused and clean

---

## ⚠️ Disclaimer & Legal

### Educational Purpose Only

This project is provided **for educational purposes only**. Users acknowledge and agree that they are:

- Responsible for complying with Roblox's Terms of Service
- Aware of potential risks including account bans or suspension
- Making informed decisions about script usage
- Liable for any consequences from script usage
- Following all applicable local and international laws

**The creator assumes no liability for**:
- Account bans or suspensions
- Data loss or account compromise
- Game updates breaking compatibility
- Any other consequences from usage

### Your Responsibility

By using this script, you agree to:
- Use it responsibly and ethically
- Not harm other players' experience
- Follow game rules and guidelines
- Accept all risks involved
- Indemnify the creator from liability

---

## 📄 License & Attribution

This project is provided as-is without specific license restrictions.

### Creator Information
- **Creator**: Rival960
- **Developer Accounts**:
  - Discord: `rival960`
  - GitHub: [@Rival99900](https://github.com/Rival99900)
  - YouTube: `rival9607`

### Acknowledgments
- **Rayfield UI Library** - Keyless UI framework
- **Roblox Community** - Script testing and feedback
- **Translators** - 21-language support
- **Beta Testers** - Feature validation

---

## 🎉 Getting Started

### Quick Start (30 seconds)

1. Join "Be an SCP or Guard" game on Roblox
2. Open your exploit executor
3. Paste and execute:
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Rival99900/Roblox-Scripts/main/SCP_Guard_Hub_Pro.lua"))()
```
4. Wait for GUI to load
5. Enjoy! 🎮

---

## 📚 Additional Resources

### Learning Luau
- [Roblox Luau Documentation](https://roblox.github.io/luau/)
- [Roblox API Reference](https://developer.roblox.com/en-us/api-reference)
- [Community Scripts & Resources](https://github.com/Rival99900/Roblox-Scripts)

### Community Links
- Roblox Developer Forums
- Roblox Community Discord servers
- GitHub Script repositories
- YouTube tutorial channels

---

## 🔮 Future Plans

### Planned Updates
- Additional game support
- Enhanced feature set
- Performance optimizations
- UI/UX improvements
- Community feature requests

### Feature Roadmap
- Custom keybind configuration
- Theme customization options
- Advanced analytics
- Plugin system for extensions
- Cross-game compatibility

---

## ⭐ Repository Stats

- **Current Version**: 1.0.0
- **Release Date**: October 21, 2026
- **Supported Games**: 1 (SCP vs Guard)
- **Languages**: 21
- **Lines of Code**: 1000+
- **Status**: ✅ Production Ready

---

## 🙏 Thank You

Thank you for using **Roblox Scripts Hub**! 

Your support helps improve and expand this project. If you find this useful, consider:
- ⭐ Starring this repository
- 🐛 Reporting issues and bugs
- 💡 Suggesting new features
- 👥 Contributing improvements
- 📢 Sharing with others

---

**Last Updated**: October 21, 2026  
**Version**: 1.0.0  
**Status**: ✅ Production Ready  
**Maintained By**: Rival960

---

## 📞 Contact

For questions, suggestions, or support:
- **Discord**: rival960
- **GitHub**: [@Rival99900](https://github.com/Rival99900)
- **YouTube**: [rival9607](https://youtube.com/@rival9607)

Happy scripting! 🎮✨

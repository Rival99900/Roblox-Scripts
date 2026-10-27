# Roblox Scripts Hub

> Keyless Roblox exploit scripts with Rayfield UI — 21 languages, multi-game support.

<a href="https://rscripts.net/user/Rival960" target="_blank"><img alt="Rival960 on Rscripts" loading="lazy" width="360" height="132" src="https://rscripts.net/api/embed/user/Rival960?theme=dark" /></a>

---

## 📜 Available Scripts

| Script | Game | Features | Status |
|--------|------|----------|--------|
| [SCP vs Guard Hub](#-scp-vs-guard-hub) | [Be an SCP or Guard](https://www.roblox.com/games/121461214257813/Be-an-SCP-or-Guard) | ESP, Silent Aim, Fly, Hitbox, Doors | untested |
| [Tactical SWAT Hub](#-tactical-swat-hub) | [Tactical: Swat Simulator](https://www.roblox.com/games/6571478429) | NPC ESP, Hitbox, Auto Arrest, Fly, Doors | untested |

---

## 🔵 SCP vs Guard Hub

**Game**: [Be an SCP or Guard](https://www.roblox.com/games/121461214257813/Be-an-SCP-or-Guard)

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Rival99900/Roblox-Scripts/refs/heads/main/scripts/Be-an-SCP-or-Guard-KEYLESS.lua"))()
```

### Features

| Category | Feature | Notes |
|----------|---------|-------|
| **ESP** | Enemy Highlight + HP tags | Team-filtered (Guards vs SCPs) |
| **Combat** | Silent Aim | Fire-triggered, FOV-based |
| **Combat** | Hitbox Expand | Up to 10× |
| **Combat** | Freeze Ammo | Keeps ammo at 999 |
| **Movement** | Fly | PC (WASD+Space/Shift) + Mobile |
| **Movement** | NoClip | Pass through walls |
| **Movement** | Walk Speed | Adjustable slider |
| **Facility** | Open / Close All Doors | ProximityPrompts, ClickDetectors, RemoteEvents |
| **Utility** | Fullbright | Fixed clock 14h, shadows off |
| **Utility** | Teleport to Closest Enemy | Instant gap-close |
| **Utility** | 21 Languages | Re-execute to apply change |

---

## 🔴 Tactical SWAT Hub

**Game**: [Tactical: Swat Simulator](https://www.roblox.com/games/6571478429)

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Rival99900/Roblox-Scripts/refs/heads/main/scripts/Tactical-Swat-Simulator-KEYLESS.lua"))()
```

### Features

| Category | Feature | Notes |
|----------|---------|-------|
| **ESP** | Suspect ESP | Armed NPCs — orange highlight + HP |
| **ESP** | Civilian ESP | Unarmed NPCs — blue highlight |
| **ESP** | Objective ESP | Mission items — yellow highlight |
| **ESP** | Enemy Player ESP | Team-filtered |
| **Combat** | Hitbox Expand | Suspects only, up to 25× |
| **Movement** | Fly | PC (WASD+Space/Shift) + Mobile overlay buttons |
| **Movement** | NoClip | Pass through walls |
| **Movement** | Walk Speed | Adjustable slider |
| **Auto** | Auto Arrest | Targets unarmed civilians/hostages; ShoutNPC prerequisite |
| **Auto** | Bring Nearest / Bring All | Teleports suspects to you |
| **Auto** | Open / Close Doors | `ChangeDoor` remote + prompt fallback |
| **Auto** | Secure Evidence | Scans workspace for evidence by keyword |
| **Utility** | Fullbright, Anti-AFK | Standard utilities |
| **Utility** | 21 Languages | Re-execute to apply change |

**NPC Detection** — works across all maps including Broken Bars:
- **Suspect** = NPC carrying a `Tool` (weapon), or name contains `Suspect / Criminal / Prisoner / Inmate`
- **Civilian** = any other live NPC (unarmed → arrest target)

---

## 🌍 Languages

All scripts support **21 languages**:

| | | | | | | |
|-|-|-|-|-|-|-|
| 🇬🇧 EN | 🇫🇷 FR | 🇩🇪 DE | 🇪🇸 ES | 🇵🇹 PT | 🇷🇺 RU | 🇮🇹 IT |
| 🇳🇱 NL | 🇵🇱 PL | 🇨🇳 ZH | 🇯🇵 JA | 🇹🇷 TR | 🇰🇷 KO | 🇸🇦 AR |
| 🇻🇳 VI | 🇸🇪 SV | 🇬🇷 EL | 🇷🇴 RO | 🇺🇦 UK | 🇨🇿 CS | 🇩🇰 DA |

> ⚠️ Language change requires re-executing the script to update the UI.

---

## ⚠️ Disclaimer

These scripts are provided **for educational purposes only**.  
Using exploits may violate [Roblox's Terms of Service](https://en.help.roblox.com/hc/en-us/articles/115004647846) and can result in account bans.  
The author assumes **no responsibility** for any consequences. Use at your own risk.

---

## 👤 Author

**Rival960** — [Rscripts Profile](https://rscripts.net/@Rival960) · [GitHub](https://github.com/Rival99900) · Discord: `rival960` · YouTube: [rival9607](https://www.youtube.com/@rival9607)

# Roblox Scripts Hub

> Keyless Roblox exploit scripts with Rayfield UI — 21 languages, multi-game support.

<a href="https://rscripts.net/user/Rival9601" target="_blank"><img alt="Rival9601 on Rscripts" loading="lazy" width="360" height="132" src="https://rscripts.net/api/embed/user/Rival9601?theme=dark" /></a>

---

## 📜 Available Scripts

| Script | Game | Features | Status |
|--------|------|----------|--------|
| [SCP vs Guard Hub](#-scp-vs-guard-hub) | [Be an SCP or Guard](https://www.roblox.com/games/121461214257813/Be-an-SCP-or-Guard) | ESP, Silent Aim, Fly, Hitbox, Doors | work |
| [Tactical SWAT Hub](#-tactical-swat-hub) | [Tactical: Swat Simulator](https://www.roblox.com/games/102837194624695/Tactical-Swat-Simulator) | NPC ESP, Hitbox, Auto Arrest, Fly, Doors | work |
| [Tower of Zombies Hub](#-tower-of-zombies-hub) | [Tower of Zombies](https://www.roblox.com/games/99122501338948/Tower-of-Zombies) | Aimbot, Auto Bring, Fly, NoClip, WalkSpeed | work |

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

**Game**: [Tactical: Swat Simulator](https://www.roblox.com/games/102837194624695/Tactical-Swat-Simulator)

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

## 🟢 Tower of Zombies Hub

**Game**: [Tower of Zombies](https://www.roblox.com/games/99122501338948/Tower-of-Zombies)

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Rival99900/Roblox-Scripts/refs/heads/main/scripts/Tower-of-Zombies-KEYLESS.lua"))()
```

### Features

| Category | Feature | Notes |
|----------|---------|-------|
| **Combat** | Aimbot | Locks camera onto the nearest zombie; HeadHitbox → Head → HRP fallback |
| **Combat** | Auto Bring | Teleports all living zombies around you in a spread circle; client-side only |
| **Combat** | Bring Radius | 1–10 studs — controls how tightly zombies cluster |
| **Combat** | Bring Interval | 0.1–2.0 s — controls how often the teleport runs |
| **Movement** | Fly | PC (WASD + Space/Shift) + Mobile overlay buttons |
| **Movement** | NoClip | Pass through walls |
| **Movement** | Walk Speed | Adjustable slider |
| **Movement** | Infinite Jump | Hold Space to keep jumping |
| **Utility** | Fullbright | Fixed clock 14h, shadows off |
| **Utility** | Anti-AFK | Micro-rotation every 60 s to avoid kick |
| **Utility** | 21 Languages | Re-execute to apply change |

**Auto Bring notes**:
- Pure client-side CFrame manipulation — no server remotes involved
- Sets zombie `WalkSpeed = 0` while active; restores `WalkSpeed = 16` on toggle off
- Zombies must be in `workspace.ActiveZombies` (standard Tower of Zombies folder)

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

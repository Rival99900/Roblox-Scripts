--[[
    ================================================================
    Tower of Zombies Hub — Tower of Zombies
    Created by Rival960 with the help of Claude
    Version: v1.3.0 | Languages: 21 | Rayfield UI
    Status: untested in-game
    ================================================================
]]

-- Task library compatibility shim (Volt and other executors)
if not task then
    task = {
        wait  = function(t) return wait(t or 0) end,
        spawn = function(f, ...) return spawn(f, ...) end,
        defer = function(f, ...) return spawn(f, ...) end,
    }
end

-- ScriptBlox analytics (async so a slow HttpGet never blocks the main thread)
task.spawn(function()
    pcall(function() loadstring(game:HttpGet("https://scriptblox.com/ingest/clientv2.lua"))("proj_3c37645b6d4a", "1.0.0", false) end)
end)

-- Services
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- ================================================================
-- Language System (21 languages)
-- ================================================================
local CurrentLang = "EN"

local Translations = {
    EN = {
        WindowTitle         = "Tower of Zombies Hub",
        WindowSubtitle      = "by Rival960",
        TabHome             = "Home",
        TabCombat           = "Combat",
        TabMovement         = "Movement",
        TabTools            = "Tools & Visuals",
        CreditsTitle        = "Credits",
        CreditsContent      = "Created by Rival960 with the help of AI\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.3.0 — Silent Aim + Rapid Fire",
        ReleaseNotesTitle   = "v1.3.0 — Release Notes",
        ReleaseNotesContent = "v1.2.0: Fixed ammo reserve location, added melee weapon support, improved executor stability.\nv1.2.1: Fixed game freeze on Volt and other executors caused by task.wait() inside Heartbeat handler; Rayfield now loads asynchronously to prevent main thread blocking.\nv1.3.0: Added Silent Aim (range slider) and Rapid Fire (up to 100 shots/s, ranged + melee); Infinite/Freeze Ammo now keep Reserve at 99999.\n\nFound a bug or want to request a feature? Open an issue on GitHub (Rival99900/Roblox-Scripts) or post on ScriptBlox.",
        Aimbot              = "Aimbot",
        AutoBring           = "Auto Bring",
        BringRadius         = "Bring Radius (studs)",
        BringInterval       = "Bring Interval (s)",
        MaxZombieDist       = "Max Zombie Distance",
        InfiniteAmmo        = "Infinite Ammo",
        FreezeAmmo          = "Freeze Ammo",
        FlyToggle           = "Fly",
        FlySpeed            = "Fly Speed",
        NoClip              = "NoClip",
        WalkSpeed           = "Walk Speed",
        InfJump             = "Infinite Jump",
        AntiAFK             = "Anti-AFK",
        Fullbright          = "Fullbright",
        LanguageSelect      = "Language",
        LangNote            = "Language change requires re-execution",
        MeleeSupport        = "Melee Support",
        RapidFire           = "Rapid Fire",
        SilentAim           = "Silent Aim",
        SilentRange         = "Silent Aim Range (studs)",
        FireRate            = "Fire Rate (shots/s)",
    },
    FR = {
        WindowTitle         = "Tower of Zombies Hub",
        WindowSubtitle      = "par Rival960",
        TabHome             = "Accueil",
        TabCombat           = "Combat",
        TabMovement         = "Déplacement",
        TabTools            = "Outils & Visuels",
        CreditsTitle        = "Crédits",
        CreditsContent      = "Créé par Rival960 avec l'aide de l'IA\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.3.0 — Silent Aim + Rapid Fire",
        ReleaseNotesTitle   = "v1.3.0 — Notes de Version",
        ReleaseNotesContent = "v1.2.0 : Correction de l'emplacement de la réserve de munitions, support des armes de mêlée, stabilité executor améliorée.\nv1.2.1 : Correction du gel du jeu sur Volt et autres executors causé par task.wait() dans le handler Heartbeat ; Rayfield se charge maintenant de manière asynchrone.\nv1.3.0 : Ajout du Silent Aim (slider de portée) et du Tir Rapide (jusqu'à 100 tirs/s, distance + mêlée) ; Munitions Infinies/Gelées gardent la réserve à 99999.\n\nVous avez trouvé un bug ou souhaitez demander une fonctionnalité ? Ouvrez un ticket sur GitHub (Rival99900/Roblox-Scripts) ou postez sur ScriptBlox.",
        Aimbot              = "Aimbot",
        AutoBring           = "Auto Attirer",
        BringRadius         = "Rayon d'attrait (studs)",
        BringInterval       = "Intervalle d'attrait (s)",
        MaxZombieDist       = "Distance Max Zombie",
        InfiniteAmmo        = "Munitions Infinies",
        FreezeAmmo          = "Geler les Munitions",
        FlyToggle           = "Vol",
        FlySpeed            = "Vitesse de Vol",
        NoClip              = "NoClip",
        WalkSpeed           = "Vitesse de Marche",
        InfJump             = "Saut Infini",
        AntiAFK             = "Anti-AFK",
        Fullbright          = "Luminosité Max",
        LanguageSelect      = "Langue",
        LangNote            = "Le changement de langue nécessite une ré-exécution",
        MeleeSupport        = "Support Mêlée",
        RapidFire           = "Tir Rapide",
        SilentAim           = "Silent Aim",
        SilentRange         = "Portée du Silent Aim (studs)",
        FireRate            = "Cadence (tirs/s)",
    },
    DE = {
        WindowTitle         = "Tower of Zombies Hub",
        WindowSubtitle      = "von Rival960",
        TabHome             = "Start",
        TabCombat           = "Kampf",
        TabMovement         = "Bewegung",
        TabTools            = "Tools & Visuals",
        CreditsTitle        = "Credits",
        CreditsContent      = "Erstellt von Rival960 mit KI-Hilfe\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.3.0 — Silent Aim + Rapid Fire",
        ReleaseNotesTitle   = "v1.3.0 — Versionshinweise",
        ReleaseNotesContent = "v1.2.0: Munitionsreserve-Speicherort behoben, Nahkampfwaffen-Support hinzugefügt, Executor-Stabilität verbessert.\nv1.2.1: Spieleinfrierung auf Volt und anderen Executors durch task.wait() im Heartbeat-Handler behoben; Rayfield lädt jetzt asynchron.\nv1.3.0: Silent Aim (Reichweiten-Slider) und Schnellfeuer (bis 100 Schuss/s, Fernkampf + Nahkampf) hinzugefügt; Unendlich/Eingefrorene Munition hält Reserve auf 99999.\n\nBug gefunden oder Feature-Wunsch? Erstelle ein Issue auf GitHub (Rival99900/Roblox-Scripts) oder schreibe auf ScriptBlox.",
        Aimbot              = "Aimbot",
        AutoBring           = "Auto Anziehen",
        BringRadius         = "Anzugsradius (studs)",
        BringInterval       = "Anzugsintervall (s)",
        MaxZombieDist       = "Max Zombie-Distanz",
        InfiniteAmmo        = "Unendlich Munition",
        FreezeAmmo          = "Munition Einfrieren",
        FlyToggle           = "Fliegen",
        FlySpeed            = "Fluggeschwindigkeit",
        NoClip              = "NoClip",
        WalkSpeed           = "Laufgeschwindigkeit",
        InfJump             = "Unendlicher Sprung",
        AntiAFK             = "Anti-AFK",
        Fullbright          = "Vollhelligkeit",
        LanguageSelect      = "Sprache",
        LangNote            = "Sprachänderung erfordert Neuausführung",
        MeleeSupport        = "Nahkampf-Support",
        RapidFire           = "Schnellfeuer",
        SilentAim           = "Silent Aim",
        SilentRange         = "Silent-Aim-Reichweite (studs)",
        FireRate            = "Feuerrate (Schuss/s)",
    },
    ES = {
        WindowTitle         = "Tower of Zombies Hub",
        WindowSubtitle      = "por Rival960",
        TabHome             = "Inicio",
        TabCombat           = "Combate",
        TabMovement         = "Movimiento",
        TabTools            = "Herramientas",
        CreditsTitle        = "Créditos",
        CreditsContent      = "Creado por Rival960 con ayuda de IA\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.3.0 — Silent Aim + Rapid Fire",
        ReleaseNotesTitle   = "v1.3.0 — Notas de Versión",
        ReleaseNotesContent = "v1.2.0: Corrección de la ubicación de la reserva de munición, soporte de armas cuerpo a cuerpo, estabilidad mejorada.\nv1.2.1: Corrección del congelamiento en Volt y otros executors causado por task.wait() dentro del handler Heartbeat; Rayfield ahora carga de forma asíncrona.\nv1.3.0: Añadido Silent Aim (slider de alcance) y Disparo Rápido (hasta 100 disparos/s, distancia + cuerpo a cuerpo); Munición Infinita/Congelada mantiene la reserva en 99999.\n\n¿Encontraste un error o quieres pedir una función? Abre un issue en GitHub (Rival99900/Roblox-Scripts) o publica en ScriptBlox.",
        Aimbot              = "Aimbot",
        AutoBring           = "Auto Atraer",
        BringRadius         = "Radio de Atracción (studs)",
        BringInterval       = "Intervalo de Atracción (s)",
        MaxZombieDist       = "Distancia Máx Zombie",
        InfiniteAmmo        = "Munición Infinita",
        FreezeAmmo          = "Congelar Munición",
        FlyToggle           = "Volar",
        FlySpeed            = "Velocidad de Vuelo",
        NoClip              = "NoClip",
        WalkSpeed           = "Velocidad de Caminar",
        InfJump             = "Salto Infinito",
        AntiAFK             = "Anti-AFK",
        Fullbright          = "Brillo Total",
        LanguageSelect      = "Idioma",
        LangNote            = "El cambio de idioma requiere re-ejecución",
        MeleeSupport        = "Soporte Cuerpo a Cuerpo",
        RapidFire           = "Disparo Rápido",
        SilentAim           = "Silent Aim",
        SilentRange         = "Alcance del Silent Aim (studs)",
        FireRate            = "Cadencia (disparos/s)",
    },
    PT = {
        WindowTitle         = "Tower of Zombies Hub",
        WindowSubtitle      = "por Rival960",
        TabHome             = "Início",
        TabCombat           = "Combate",
        TabMovement         = "Movimento",
        TabTools            = "Ferramentas",
        CreditsTitle        = "Créditos",
        CreditsContent      = "Criado por Rival960 com ajuda de IA\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.3.0 — Silent Aim + Rapid Fire",
        ReleaseNotesTitle   = "v1.3.0 — Notas da Versão",
        ReleaseNotesContent = "v1.2.0: Correção da localização da reserva de munição, suporte a armas corpo a corpo, estabilidade melhorada.\nv1.2.1: Correção do congelamento no Volt e outros executors causado por task.wait() dentro do handler Heartbeat; Rayfield agora carrega de forma assíncrona.\nv1.3.0: Adicionado Silent Aim (slider de alcance) e Tiro Rápido (até 100 tiros/s, distância + corpo a corpo); Munição Infinita/Congelada mantém a reserva em 99999.\n\nEncontrou um bug ou quer sugerir uma função? Abra uma issue no GitHub (Rival99900/Roblox-Scripts) ou publique no ScriptBlox.",
        Aimbot              = "Aimbot",
        AutoBring           = "Auto Atrair",
        BringRadius         = "Raio de Atração (studs)",
        BringInterval       = "Intervalo de Atração (s)",
        MaxZombieDist       = "Distância Máx Zumbi",
        InfiniteAmmo        = "Munição Infinita",
        FreezeAmmo          = "Congelar Munição",
        FlyToggle           = "Voar",
        FlySpeed            = "Velocidade de Voo",
        NoClip              = "NoClip",
        WalkSpeed           = "Velocidade de Caminhada",
        InfJump             = "Salto Infinito",
        AntiAFK             = "Anti-AFK",
        Fullbright          = "Brilho Total",
        LanguageSelect      = "Idioma",
        LangNote            = "Mudança de idioma requer re-execução",
        MeleeSupport        = "Suporte Corpo a Corpo",
        RapidFire           = "Tiro Rápido",
        SilentAim           = "Silent Aim",
        SilentRange         = "Alcance do Silent Aim (studs)",
        FireRate            = "Cadência (tiros/s)",
    },
    RU = {
        WindowTitle         = "Tower of Zombies Hub",
        WindowSubtitle      = "от Rival960",
        TabHome             = "Главная",
        TabCombat           = "Бой",
        TabMovement         = "Движение",
        TabTools            = "Инструменты",
        CreditsTitle        = "Авторы",
        CreditsContent      = "Создано Rival960 с помощью ИИ\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.3.0 — Silent Aim + Rapid Fire",
        ReleaseNotesTitle   = "v1.3.0 — Примечания к версии",
        ReleaseNotesContent = "v1.2.0: Исправлено расположение резерва патронов, добавлена поддержка оружия ближнего боя, улучшена стабильность.\nv1.2.1: Исправлено зависание на Volt и других executors из-за task.wait() внутри обработчика Heartbeat; Rayfield теперь загружается асинхронно.\nv1.3.0: Добавлены Silent Aim (слайдер дальности) и быстрая стрельба (до 100 выстр/с, дальний + ближний бой); бесконечные/замороженные патроны держат резерв на 99999.\n\nНашли баг или хотите предложить функцию? Создайте issue на GitHub (Rival99900/Roblox-Scripts) или напишите на ScriptBlox.",
        Aimbot              = "Аимбот",
        AutoBring           = "Авто Притяжение",
        BringRadius         = "Радиус притяжения (ст.)",
        BringInterval       = "Интервал притяжения (с)",
        MaxZombieDist       = "Макс дистанция зомби",
        InfiniteAmmo        = "Бесконечные патроны",
        FreezeAmmo          = "Заморозить патроны",
        FlyToggle           = "Полёт",
        FlySpeed            = "Скорость полёта",
        NoClip              = "NoClip",
        WalkSpeed           = "Скорость ходьбы",
        InfJump             = "Бесконечный прыжок",
        AntiAFK             = "Анти-АФК",
        Fullbright          = "Полная яркость",
        LanguageSelect      = "Язык",
        LangNote            = "Смена языка требует повторного запуска",
        MeleeSupport        = "Поддержка ближнего боя",
        RapidFire           = "Быстрая стрельба",
        SilentAim           = "Silent Aim",
        SilentRange         = "Дальность Silent Aim (ст.)",
        FireRate            = "Скорострельность (выстр/с)",
    },
    IT = {
        WindowTitle         = "Tower of Zombies Hub",
        WindowSubtitle      = "di Rival960",
        TabHome             = "Home",
        TabCombat           = "Combattimento",
        TabMovement         = "Movimento",
        TabTools            = "Strumenti",
        CreditsTitle        = "Crediti",
        CreditsContent      = "Creato da Rival960 con l'aiuto dell'IA\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.3.0 — Silent Aim + Rapid Fire",
        ReleaseNotesTitle   = "v1.3.0 — Note di Versione",
        ReleaseNotesContent = "v1.2.0: Corretta posizione della riserva munizioni, aggiunto supporto armi da mischia, stabilità migliorata.\nv1.2.1: Corretto il congelamento su Volt e altri executor causato da task.wait() nell'handler Heartbeat; Rayfield ora si carica in modo asincrono.\nv1.3.0: Aggiunti Silent Aim (slider di portata) e Fuoco Rapido (fino a 100 colpi/s, distanza + mischia); Munizioni Infinite/Bloccate tengono la riserva a 99999.\n\nHai trovato un bug o vuoi richiedere una funzione? Apri un'issue su GitHub (Rival99900/Roblox-Scripts) o scrivi su ScriptBlox.",
        Aimbot              = "Aimbot",
        AutoBring           = "Auto Attira",
        BringRadius         = "Raggio di Attrazione (studs)",
        BringInterval       = "Intervallo di Attrazione (s)",
        MaxZombieDist       = "Distanza Max Zombie",
        InfiniteAmmo        = "Munizioni Infinite",
        FreezeAmmo          = "Blocca Munizioni",
        FlyToggle           = "Volo",
        FlySpeed            = "Velocità di Volo",
        NoClip              = "NoClip",
        WalkSpeed           = "Velocità di Camminata",
        InfJump             = "Salto Infinito",
        AntiAFK             = "Anti-AFK",
        Fullbright          = "Piena Luminosità",
        LanguageSelect      = "Lingua",
        LangNote            = "Il cambio lingua richiede una ri-esecuzione",
        MeleeSupport        = "Supporto Mischia",
        RapidFire           = "Fuoco Rapido",
        SilentAim           = "Silent Aim",
        SilentRange         = "Portata Silent Aim (studs)",
        FireRate            = "Cadenza (colpi/s)",
    },
    NL = {
        WindowTitle         = "Tower of Zombies Hub",
        WindowSubtitle      = "door Rival960",
        TabHome             = "Start",
        TabCombat           = "Gevecht",
        TabMovement         = "Beweging",
        TabTools            = "Tools & Visuals",
        CreditsTitle        = "Credits",
        CreditsContent      = "Gemaakt door Rival960 met AI-hulp\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.3.0 — Silent Aim + Rapid Fire",
        ReleaseNotesTitle   = "v1.3.0 — Versienotities",
        ReleaseNotesContent = "v1.2.0: Locatie munitiereserve gecorrigeerd, melee-wapenondersteuning toegevoegd, stabiliteit verbeterd.\nv1.2.1: Bevriezing op Volt en andere executors verholpen veroorzaakt door task.wait() in de Heartbeat-handler; Rayfield laadt nu asynchroon.\nv1.3.0: Silent Aim (bereik-slider) en Snelvuur (tot 100 schoten/s, afstand + melee) toegevoegd; Oneindige/Bevroren Munitie houdt reserve op 99999.\n\nBug gevonden of wil je een functie aanvragen? Open een issue op GitHub (Rival99900/Roblox-Scripts) of post op ScriptBlox.",
        Aimbot              = "Aimbot",
        AutoBring           = "Auto Aantrekken",
        BringRadius         = "Aantrekkingsradius (studs)",
        BringInterval       = "Aantrekkingsinterval (s)",
        MaxZombieDist       = "Max Zombie Afstand",
        InfiniteAmmo        = "Oneindige Munitie",
        FreezeAmmo          = "Bevriezing Munitie",
        FlyToggle           = "Vliegen",
        FlySpeed            = "Vliegsnelheid",
        NoClip              = "NoClip",
        WalkSpeed           = "Loopsnelheid",
        InfJump             = "Oneindig Springen",
        AntiAFK             = "Anti-AFK",
        Fullbright          = "Maximale Helderheid",
        LanguageSelect      = "Taal",
        LangNote            = "Taalwijziging vereist heruitvoering",
        MeleeSupport        = "Melee-ondersteuning",
        RapidFire           = "Snelvuur",
        SilentAim           = "Silent Aim",
        SilentRange         = "Silent Aim Bereik (studs)",
        FireRate            = "Vuursnelheid (schoten/s)",
    },
    PL = {
        WindowTitle         = "Tower of Zombies Hub",
        WindowSubtitle      = "przez Rival960",
        TabHome             = "Strona główna",
        TabCombat           = "Walka",
        TabMovement         = "Ruch",
        TabTools            = "Narzędzia",
        CreditsTitle        = "Kredyty",
        CreditsContent      = "Stworzone przez Rival960 z pomocą AI\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.3.0 — Silent Aim + Rapid Fire",
        ReleaseNotesTitle   = "v1.3.0 — Informacje o Wersji",
        ReleaseNotesContent = "v1.2.0: Poprawiono lokalizację rezerwy amunicji, dodano wsparcie broni białej, poprawiono stabilność.\nv1.2.1: Naprawiono zamrożenie gry na Volt i innych executorach spowodowane task.wait() wewnątrz handlera Heartbeat; Rayfield ładuje się teraz asynchronicznie.\nv1.3.0: Dodano Silent Aim (suwak zasięgu) i Szybki Ogień (do 100 strz/s, dystans + walka wręcz); Nieskończona/Zamrożona Amunicja trzyma rezerwę na 99999.\n\nZnalazłeś błąd lub chcesz zgłosić funkcję? Otwórz issue na GitHub (Rival99900/Roblox-Scripts) lub napisz na ScriptBlox.",
        Aimbot              = "Aimbot",
        AutoBring           = "Auto Przyciąganie",
        BringRadius         = "Promień przyciągania (studs)",
        BringInterval       = "Interwał przyciągania (s)",
        MaxZombieDist       = "Maks. dystans zombie",
        InfiniteAmmo        = "Nieskończona Amunicja",
        FreezeAmmo          = "Zamroź Amunicję",
        FlyToggle           = "Latanie",
        FlySpeed            = "Prędkość lotu",
        NoClip              = "NoClip",
        WalkSpeed           = "Prędkość chodu",
        InfJump             = "Nieskończony Skok",
        AntiAFK             = "Anti-AFK",
        Fullbright          = "Pełna jasność",
        LanguageSelect      = "Język",
        LangNote            = "Zmiana języka wymaga ponownego uruchomienia",
        MeleeSupport        = "Wsparcie walki wręcz",
        RapidFire           = "Szybki Ogień",
        SilentAim           = "Silent Aim",
        SilentRange         = "Zasięg Silent Aim (studs)",
        FireRate            = "Szybkostrzelność (strz/s)",
    },
    ZH = {
        WindowTitle         = "行尸走肉枢纽",
        WindowSubtitle      = "由 Rival960",
        TabHome             = "主页",
        TabCombat           = "战斗",
        TabMovement         = "移动",
        TabTools            = "工具与视觉",
        CreditsTitle        = "致谢",
        CreditsContent      = "由 Rival960 借助 AI 创建\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.3.0 — Silent Aim + Rapid Fire",
        ReleaseNotesTitle   = "v1.3.0 — 版本说明",
        ReleaseNotesContent = "v1.2.0：修复了备用弹药位置，添加近战武器支持，改善executor稳定性。\nv1.2.1：修复了Volt及其他executor因Heartbeat处理器中的task.wait()导致的游戏冻结；Rayfield现在异步加载。\nv1.3.0：新增静默瞄准（范围滑块）和快速射击（最高 100 发/秒，远程 + 近战）；无限/冻结弹药将备用弹药保持在 99999。\n\n发现漏洞或想申请功能？请在 GitHub (Rival99900/Roblox-Scripts) 提交 issue 或在 ScriptBlox 发帖。",
        Aimbot              = "自动瞄准",
        AutoBring           = "自动吸引",
        BringRadius         = "吸引半径 (格)",
        BringInterval       = "吸引间隔 (秒)",
        MaxZombieDist       = "最大僵尸距离",
        InfiniteAmmo        = "无限弹药",
        FreezeAmmo          = "冻结弹药",
        FlyToggle           = "飞行",
        FlySpeed            = "飞行速度",
        NoClip              = "穿墙",
        WalkSpeed           = "行走速度",
        InfJump             = "无限跳跃",
        AntiAFK             = "防离线",
        Fullbright          = "全亮",
        LanguageSelect      = "语言",
        LangNote            = "语言更改需要重新执行",
        MeleeSupport        = "近战支持",
        RapidFire           = "快速射击",
        SilentAim           = "静默瞄准",
        SilentRange         = "静默瞄准范围 (格)",
        FireRate            = "射速 (发/秒)",
    },
    JA = {
        WindowTitle         = "ゾンビタワーハブ",
        WindowSubtitle      = "Rival960 制作",
        TabHome             = "ホーム",
        TabCombat           = "戦闘",
        TabMovement         = "移動",
        TabTools            = "ツール",
        CreditsTitle        = "クレジット",
        CreditsContent      = "Rival960 と AI の協力で作成\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.3.0 — Silent Aim + Rapid Fire",
        ReleaseNotesTitle   = "v1.3.0 — リリースノート",
        ReleaseNotesContent = "v1.2.0：予備弾薬の場所を修正、近接武器サポートを追加、安定性を改善。\nv1.2.1：HeartbeatハンドラーのtaskタスクwaitによるVoltおよび他のExecutorでのフリーズを修正；Rayfieldが非同期で読み込まれるように変更。\nv1.3.0：サイレントエイム（範囲スライダー）と連射（最大 100 発/秒、遠距離＋近接）を追加；無限/固定弾薬で予備弾薬を 99999 に維持。\n\nバグ発見や機能リクエストはGitHub (Rival99900/Roblox-Scripts) のissueまたはScriptBloxに投稿してください。",
        Aimbot              = "エイムボット",
        AutoBring           = "自動引き寄せ",
        BringRadius         = "引き寄せ半径 (スタッド)",
        BringInterval       = "引き寄せ間隔 (秒)",
        MaxZombieDist       = "最大ゾンビ距離",
        InfiniteAmmo        = "無限弾薬",
        FreezeAmmo          = "弾薬固定",
        FlyToggle           = "フライ",
        FlySpeed            = "飛行速度",
        NoClip              = "ノークリップ",
        WalkSpeed           = "歩行速度",
        InfJump             = "無限ジャンプ",
        AntiAFK             = "アンチAFK",
        Fullbright          = "フルブライト",
        LanguageSelect      = "言語",
        LangNote            = "言語変更は再実行が必要です",
        MeleeSupport        = "近接サポート",
        RapidFire           = "連射",
        SilentAim           = "サイレントエイム",
        SilentRange         = "サイレントエイム範囲 (スタッド)",
        FireRate            = "連射速度 (発/秒)",
    },
    TR = {
        WindowTitle         = "Tower of Zombies Hub",
        WindowSubtitle      = "Rival960 tarafından",
        TabHome             = "Ana Sayfa",
        TabCombat           = "Savaş",
        TabMovement         = "Hareket",
        TabTools            = "Araçlar",
        CreditsTitle        = "Krediler",
        CreditsContent      = "Rival960 tarafından AI yardımıyla yapılmıştır\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.3.0 — Silent Aim + Rapid Fire",
        ReleaseNotesTitle   = "v1.3.0 — Sürüm Notları",
        ReleaseNotesContent = "v1.2.0: Mermi rezerv konumu düzeltildi, yakın dövüş silahı desteği eklendi, kararlılık geliştirildi.\nv1.2.1: Heartbeat handler içindeki task.wait() nedeniyle Volt ve diğer executörlerde yaşanan oyun donması düzeltildi; Rayfield artık eşzamansız yükleniyor.\nv1.3.0: Silent Aim (menzil kaydırıcı) ve Hızlı Ateş (100 atış/sn'ye kadar, uzak + yakın dövüş) eklendi; Sonsuz/Dondurulmuş Mermi rezervi 99999'da tutar.\n\nBir hata buldunuz veya özellik talep etmek mi istiyorsunuz? GitHub'da (Rival99900/Roblox-Scripts) issue açın veya ScriptBlox'ta paylaşın.",
        Aimbot              = "Aimbot",
        AutoBring           = "Otomatik Çekme",
        BringRadius         = "Çekme Yarıçapı (studs)",
        BringInterval       = "Çekme Aralığı (s)",
        MaxZombieDist       = "Maks Zombi Mesafesi",
        InfiniteAmmo        = "Sonsuz Mermi",
        FreezeAmmo          = "Mermiyi Dondur",
        FlyToggle           = "Uçuş",
        FlySpeed            = "Uçuş Hızı",
        NoClip              = "NoClip",
        WalkSpeed           = "Yürüyüş Hızı",
        InfJump             = "Sonsuz Zıplama",
        AntiAFK             = "Anti-AFK",
        Fullbright          = "Tam Parlaklık",
        LanguageSelect      = "Dil",
        LangNote            = "Dil değişikliği yeniden başlatma gerektirir",
        MeleeSupport        = "Yakın Dövüş Desteği",
        RapidFire           = "Hızlı Ateş",
        SilentAim           = "Silent Aim",
        SilentRange         = "Silent Aim Menzili (studs)",
        FireRate            = "Atış Hızı (atış/sn)",
    },
    KO = {
        WindowTitle         = "좀비 타워 허브",
        WindowSubtitle      = "Rival960 제작",
        TabHome             = "홈",
        TabCombat           = "전투",
        TabMovement         = "이동",
        TabTools            = "도구",
        CreditsTitle        = "크레딧",
        CreditsContent      = "Rival960이 AI의 도움으로 제작\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.3.0 — Silent Aim + Rapid Fire",
        ReleaseNotesTitle   = "v1.3.0 — 릴리즈 노트",
        ReleaseNotesContent = "v1.2.0: 예비 탄약 위치 수정, 근접 무기 지원 추가, 안정성 개선.\nv1.2.1: Heartbeat 핸들러 내 task.wait()로 인한 Volt 및 다른 executor의 게임 프리즈 수정; Rayfield가 이제 비동기적으로 로드됩니다.\nv1.3.0: 사일런트 에임(범위 슬라이더)과 연사(최대 100발/초, 원거리 + 근접) 추가; 무한/고정 탄약이 예비 탄약을 99999로 유지.\n\n버그를 찾거나 기능을 요청하고 싶다면? GitHub (Rival99900/Roblox-Scripts)에 이슈를 열거나 ScriptBlox에 게시하세요.",
        Aimbot              = "에임봇",
        AutoBring           = "자동 끌어오기",
        BringRadius         = "끌어오기 반경 (스터드)",
        BringInterval       = "끌어오기 간격 (초)",
        MaxZombieDist       = "최대 좀비 거리",
        InfiniteAmmo        = "무한 탄약",
        FreezeAmmo          = "탄약 고정",
        FlyToggle           = "비행",
        FlySpeed            = "비행 속도",
        NoClip              = "노클립",
        WalkSpeed           = "걷기 속도",
        InfJump             = "무한 점프",
        AntiAFK             = "Anti-AFK",
        Fullbright          = "전체 밝기",
        LanguageSelect      = "언어",
        LangNote            = "언어 변경은 재실행이 필요합니다",
        MeleeSupport        = "근접 무기 지원",
        RapidFire           = "연사",
        SilentAim           = "사일런트 에임",
        SilentRange         = "사일런트 에임 범위 (스터드)",
        FireRate            = "연사 속도 (발/초)",
    },
    AR = {
        WindowTitle         = "Tower of Zombies Hub",
        WindowSubtitle      = "بواسطة Rival960",
        TabHome             = "الرئيسية",
        TabCombat           = "القتال",
        TabMovement         = "الحركة",
        TabTools            = "الأدوات",
        CreditsTitle        = "الاعتمادات",
        CreditsContent      = "تم إنشاؤه بواسطة Rival960 بمساعدة الذكاء الاصطناعي\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.3.0 — Silent Aim + Rapid Fire",
        ReleaseNotesTitle   = "v1.3.0 — ملاحظات الإصدار",
        ReleaseNotesContent = "v1.2.0: إصلاح موقع احتياطي الذخيرة، دعم الأسلحة المتلاحمة، تحسين الاستقرار.\nv1.2.1: إصلاح تجميد اللعبة على Volt والمنفذين الآخرين بسبب task.wait() داخل معالج Heartbeat؛ يتم الآن تحميل Rayfield بشكل غير متزامن.\nv1.3.0: إضافة التصويب الصامت (شريط المدى) والإطلاق السريع (حتى 100 طلقة/ث، بعيد + متلاحم)؛ الذخيرة اللانهائية/المجمدة تبقي الاحتياطي عند 99999.\n\nوجدت خطأ أو تريد طلب ميزة؟ افتح issue على GitHub (Rival99900/Roblox-Scripts) أو انشر على ScriptBlox.",
        Aimbot              = "أيمبوت",
        AutoBring           = "جذب تلقائي",
        BringRadius         = "نطاق الجذب (وحدة)",
        BringInterval       = "فترة الجذب (ث)",
        MaxZombieDist       = "أقصى مسافة للزومبي",
        InfiniteAmmo        = "ذخيرة لا نهائية",
        FreezeAmmo          = "تجميد الذخيرة",
        FlyToggle           = "طيران",
        FlySpeed            = "سرعة الطيران",
        NoClip              = "اختراق الجدران",
        WalkSpeed           = "سرعة المشي",
        InfJump             = "قفز لانهائي",
        AntiAFK             = "مانع الخمول",
        Fullbright          = "سطوع كامل",
        LanguageSelect      = "اللغة",
        LangNote            = "تغيير اللغة يتطلب إعادة التشغيل",
        MeleeSupport        = "دعم القتال المتلاحم",
        RapidFire           = "إطلاق سريع",
        SilentAim           = "تصويب صامت",
        SilentRange         = "مدى التصويب الصامت (وحدة)",
        FireRate            = "معدل الإطلاق (طلقة/ث)",
    },
    VI = {
        WindowTitle         = "Tower of Zombies Hub",
        WindowSubtitle      = "bởi Rival960",
        TabHome             = "Trang Chủ",
        TabCombat           = "Chiến Đấu",
        TabMovement         = "Di Chuyển",
        TabTools            = "Công Cụ",
        CreditsTitle        = "Tín Dụng",
        CreditsContent      = "Tạo bởi Rival960 với sự trợ giúp của AI\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.3.0 — Silent Aim + Rapid Fire",
        ReleaseNotesTitle   = "v1.3.0 — Ghi Chú Phiên Bản",
        ReleaseNotesContent = "v1.2.0: Sửa vị trí dự trữ đạn, thêm hỗ trợ vũ khí cận chiến, cải thiện độ ổn định.\nv1.2.1: Sửa lỗi đóng băng trên Volt và các executor khác do task.wait() bên trong handler Heartbeat; Rayfield giờ tải không đồng bộ.\nv1.3.0: Thêm Silent Aim (thanh tầm bắn) và Bắn Nhanh (tối đa 100 phát/s, tầm xa + cận chiến); Đạn Vô Hạn/Đóng Băng giữ dự trữ ở 99999.\n\nTìm thấy lỗi hoặc muốn yêu cầu tính năng? Mở issue trên GitHub (Rival99900/Roblox-Scripts) hoặc đăng trên ScriptBlox.",
        Aimbot              = "Aimbot",
        AutoBring           = "Tự Động Kéo",
        BringRadius         = "Bán Kính Kéo (studs)",
        BringInterval       = "Khoảng Thời Gian Kéo (s)",
        MaxZombieDist       = "Khoảng Cách Zombie Tối Đa",
        InfiniteAmmo        = "Đạn Vô Hạn",
        FreezeAmmo          = "Đóng Băng Đạn",
        FlyToggle           = "Bay",
        FlySpeed            = "Tốc Độ Bay",
        NoClip              = "NoClip",
        WalkSpeed           = "Tốc Độ Đi",
        InfJump             = "Nhảy Vô Hạn",
        AntiAFK             = "Chống AFK",
        Fullbright          = "Độ Sáng Tối Đa",
        LanguageSelect      = "Ngôn Ngữ",
        LangNote            = "Thay đổi ngôn ngữ cần khởi động lại",
        MeleeSupport        = "Hỗ Trợ Cận Chiến",
        RapidFire           = "Bắn Nhanh",
        SilentAim           = "Silent Aim",
        SilentRange         = "Tầm Silent Aim (studs)",
        FireRate            = "Tốc Độ Bắn (phát/s)",
    },
    SV = {
        WindowTitle         = "Tower of Zombies Hub",
        WindowSubtitle      = "av Rival960",
        TabHome             = "Hem",
        TabCombat           = "Strid",
        TabMovement         = "Rörelse",
        TabTools            = "Verktyg",
        CreditsTitle        = "Erkännanden",
        CreditsContent      = "Skapad av Rival960 med hjälp av AI\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.3.0 — Silent Aim + Rapid Fire",
        ReleaseNotesTitle   = "v1.3.0 — Versionsanteckningar",
        ReleaseNotesContent = "v1.2.0: Korrigerade plats för ammunitionsreserv, lade till stöd för närstridsvapen, förbättrad stabilitet.\nv1.2.1: Åtgärdade spelfrysning på Volt och andra executors orsakad av task.wait() i Heartbeat-handler; Rayfield laddas nu asynkront.\nv1.3.0: Lade till Silent Aim (räckviddsreglage) och Snabbeld (upp till 100 skott/s, avstånd + närstrid); Oändlig/Fryst Ammunition håller reserven på 99999.\n\nHittade du en bugg eller vill begära en funktion? Öppna ett issue på GitHub (Rival99900/Roblox-Scripts) eller posta på ScriptBlox.",
        Aimbot              = "Aimbot",
        AutoBring           = "Auto Hämta",
        BringRadius         = "Hämtningsradie (studs)",
        BringInterval       = "Hämtningsintervall (s)",
        MaxZombieDist       = "Max Zombieavstånd",
        InfiniteAmmo        = "Oändlig Ammunition",
        FreezeAmmo          = "Frys Ammunition",
        FlyToggle           = "Flyg",
        FlySpeed            = "Flyghastighet",
        NoClip              = "NoClip",
        WalkSpeed           = "Gånghastighet",
        InfJump             = "Oändligt Hopp",
        AntiAFK             = "Anti-AFK",
        Fullbright          = "Full Ljusstyrka",
        LanguageSelect      = "Språk",
        LangNote            = "Språkändring kräver omstartning",
        MeleeSupport        = "Närstridsstöd",
        RapidFire           = "Snabbeld",
        SilentAim           = "Silent Aim",
        SilentRange         = "Silent Aim Räckvidd (studs)",
        FireRate            = "Eldhastighet (skott/s)",
    },
    EL = {
        WindowTitle         = "Tower of Zombies Hub",
        WindowSubtitle      = "από Rival960",
        TabHome             = "Αρχική",
        TabCombat           = "Μάχη",
        TabMovement         = "Κίνηση",
        TabTools            = "Εργαλεία",
        CreditsTitle        = "Εύσημα",
        CreditsContent      = "Δημιουργήθηκε από Rival960 με βοήθεια AI\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.3.0 — Silent Aim + Rapid Fire",
        ReleaseNotesTitle   = "v1.3.0 — Σημειώσεις Έκδοσης",
        ReleaseNotesContent = "v1.2.0: Διορθώθηκε η θέση του αποθεματικού πυρομαχικών, προστέθηκε υποστήριξη όπλων εκ του σύνεγγυς, βελτιωμένη σταθερότητα.\nv1.2.1: Διορθώθηκε το πάγωμα στο Volt και άλλους executor λόγω task.wait() εντός του handler Heartbeat· το Rayfield φορτώνεται πλέον ασύγχρονα.\nv1.3.0: Προστέθηκαν Silent Aim (ρυθμιστικό εμβέλειας) και Γρήγορα Πυρά (έως 100 βολές/δ, απόσταση + σώμα με σώμα)· Άπειρα/Παγωμένα Πυρομαχικά κρατούν το αποθεματικό στα 99999.\n\nΒρήκατε σφάλμα ή θέλετε να ζητήσετε λειτουργία; Ανοίξτε ένα issue στο GitHub (Rival99900/Roblox-Scripts) ή δημοσιεύστε στο ScriptBlox.",
        Aimbot              = "Aimbot",
        AutoBring           = "Αυτόματη Έλξη",
        BringRadius         = "Ακτίνα Έλξης (studs)",
        BringInterval       = "Διάστημα Έλξης (s)",
        MaxZombieDist       = "Μέγ. Απόσταση Ζόμπι",
        InfiniteAmmo        = "Άπειρα Πυρομαχικά",
        FreezeAmmo          = "Πάγωμα Πυρομαχικών",
        FlyToggle           = "Πτήση",
        FlySpeed            = "Ταχύτητα Πτήσης",
        NoClip              = "NoClip",
        WalkSpeed           = "Ταχύτητα Βαδίσματος",
        InfJump             = "Άπειρο Άλμα",
        AntiAFK             = "Anti-AFK",
        Fullbright          = "Πλήρης Φωτεινότητα",
        LanguageSelect      = "Γλώσσα",
        LangNote            = "Η αλλαγή γλώσσας απαιτεί επανεκτέλεση",
        MeleeSupport        = "Υποστήριξη Εκ του Σύνεγγυς",
        RapidFire           = "Γρήγορα Πυρά",
        SilentAim           = "Silent Aim",
        SilentRange         = "Εμβέλεια Silent Aim (studs)",
        FireRate            = "Ρυθμός Βολής (βολές/δ)",
    },
    RO = {
        WindowTitle         = "Tower of Zombies Hub",
        WindowSubtitle      = "de Rival960",
        TabHome             = "Acasă",
        TabCombat           = "Luptă",
        TabMovement         = "Mișcare",
        TabTools            = "Instrumente",
        CreditsTitle        = "Credite",
        CreditsContent      = "Creat de Rival960 cu ajutorul AI\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.3.0 — Silent Aim + Rapid Fire",
        ReleaseNotesTitle   = "v1.3.0 — Note de Lansare",
        ReleaseNotesContent = "v1.2.0: Corectată locația rezervei de muniție, adăugat suport arme corp la corp, stabilitate îmbunătățită.\nv1.2.1: Remediată înghețarea jocului pe Volt și alți executori cauzată de task.wait() în handlerul Heartbeat; Rayfield se încarcă acum asincron.\nv1.3.0: Adăugat Silent Aim (slider de rază) și Foc Rapid (până la 100 focuri/s, distanță + corp la corp); Muniția Infinită/Înghețată ține rezerva la 99999.\n\nAți găsit un bug sau doriți să solicitați o funcție? Deschideți un issue pe GitHub (Rival99900/Roblox-Scripts) sau postați pe ScriptBlox.",
        Aimbot              = "Aimbot",
        AutoBring           = "Auto Atragere",
        BringRadius         = "Raza de Atragere (studs)",
        BringInterval       = "Interval Atragere (s)",
        MaxZombieDist       = "Dist. Maximă Zombie",
        InfiniteAmmo        = "Muniție Infinită",
        FreezeAmmo          = "Îngheță Muniție",
        FlyToggle           = "Zbor",
        FlySpeed            = "Viteză Zbor",
        NoClip              = "NoClip",
        WalkSpeed           = "Viteză Mers",
        InfJump             = "Salt Infinit",
        AntiAFK             = "Anti-AFK",
        Fullbright          = "Luminozitate Maximă",
        LanguageSelect      = "Limbă",
        LangNote            = "Schimbarea limbii necesită re-executare",
        MeleeSupport        = "Suport Corp la Corp",
        RapidFire           = "Foc Rapid",
        SilentAim           = "Silent Aim",
        SilentRange         = "Rază Silent Aim (studs)",
        FireRate            = "Cadență (focuri/s)",
    },
    UK = {
        WindowTitle         = "Tower of Zombies Hub",
        WindowSubtitle      = "від Rival960",
        TabHome             = "Головна",
        TabCombat           = "Бій",
        TabMovement         = "Рух",
        TabTools            = "Інструменти",
        CreditsTitle        = "Автори",
        CreditsContent      = "Створено Rival960 за допомогою AI\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.3.0 — Silent Aim + Rapid Fire",
        ReleaseNotesTitle   = "v1.3.0 — Примітки до версії",
        ReleaseNotesContent = "v1.2.0: Виправлено розташування резерву патронів, додано підтримку зброї ближнього бою, покращена стабільність.\nv1.2.1: Виправлено зависання на Volt та інших executor через task.wait() всередині обробника Heartbeat; Rayfield тепер завантажується асинхронно.\nv1.3.0: Додано Silent Aim (слайдер дальності) та швидку стрільбу (до 100 постр/с, дальній + ближній бій); нескінченні/заморожені патрони тримають резерв на 99999.\n\nЗнайшли баг або хочете запропонувати функцію? Створіть issue на GitHub (Rival99900/Roblox-Scripts) або напишіть на ScriptBlox.",
        Aimbot              = "Аімбот",
        AutoBring           = "Авто Притягання",
        BringRadius         = "Радіус притягання (ст.)",
        BringInterval       = "Інтервал притягання (с)",
        MaxZombieDist       = "Макс дистанція зомбі",
        InfiniteAmmo        = "Нескінченні патрони",
        FreezeAmmo          = "Заморозити патрони",
        FlyToggle           = "Політ",
        FlySpeed            = "Швидкість польоту",
        NoClip              = "NoClip",
        WalkSpeed           = "Швидкість ходьби",
        InfJump             = "Нескінченний Стрибок",
        AntiAFK             = "Анти-АФК",
        Fullbright          = "Повна яскравість",
        LanguageSelect      = "Мова",
        LangNote            = "Зміна мови потребує перезапуску",
        MeleeSupport        = "Підтримка ближнього бою",
        RapidFire           = "Швидка стрільба",
        SilentAim           = "Silent Aim",
        SilentRange         = "Дальність Silent Aim (ст.)",
        FireRate            = "Скорострільність (постр/с)",
    },
    CS = {
        WindowTitle         = "Tower of Zombies Hub",
        WindowSubtitle      = "od Rival960",
        TabHome             = "Domů",
        TabCombat           = "Boj",
        TabMovement         = "Pohyb",
        TabTools            = "Nástroje",
        CreditsTitle        = "Poděkování",
        CreditsContent      = "Vytvořeno Rival960 s pomocí AI\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.3.0 — Silent Aim + Rapid Fire",
        ReleaseNotesTitle   = "v1.3.0 — Poznámky k Vydání",
        ReleaseNotesContent = "v1.2.0: Opravena poloha zásoby munice, přidána podpora zbraní zblízka, zlepšena stabilita.\nv1.2.1: Opraveno zamrznutí hry na Volt a dalších executorech způsobené task.wait() uvnitř handleru Heartbeat; Rayfield se nyní načítá asynchronně.\nv1.3.0: Přidán Silent Aim (posuvník dosahu) a Rychlá Palba (až 100 ran/s, dálka + zblízka); Nekonečná/Zmrazená Munice drží zásobu na 99999.\n\nNašli jste chybu nebo chcete požádat o funkci? Otevřete issue na GitHub (Rival99900/Roblox-Scripts) nebo přidejte příspěvek na ScriptBlox.",
        Aimbot              = "Aimbot",
        AutoBring           = "Auto Přitáhnout",
        BringRadius         = "Poloměr přitáhnutí (studs)",
        BringInterval       = "Interval přitáhnutí (s)",
        MaxZombieDist       = "Max vzdálenost zombie",
        InfiniteAmmo        = "Nekonečná Munice",
        FreezeAmmo          = "Zmrazit Munici",
        FlyToggle           = "Létání",
        FlySpeed            = "Rychlost letu",
        NoClip              = "NoClip",
        WalkSpeed           = "Rychlost chůze",
        InfJump             = "Nekonečný Skok",
        AntiAFK             = "Anti-AFK",
        Fullbright          = "Plný jas",
        LanguageSelect      = "Jazyk",
        LangNote            = "Změna jazyka vyžaduje restartování",
        MeleeSupport        = "Podpora boje zblízka",
        RapidFire           = "Rychlá Palba",
        SilentAim           = "Silent Aim",
        SilentRange         = "Dosah Silent Aim (studs)",
        FireRate            = "Kadence (ran/s)",
    },
    DA = {
        WindowTitle         = "Tower of Zombies Hub",
        WindowSubtitle      = "af Rival960",
        TabHome             = "Hjem",
        TabCombat           = "Kamp",
        TabMovement         = "Bevægelse",
        TabTools            = "Værktøjer",
        CreditsTitle        = "Anerkendelser",
        CreditsContent      = "Oprettet af Rival960 med hjælp fra AI\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.3.0 — Silent Aim + Rapid Fire",
        ReleaseNotesTitle   = "v1.3.0 — Udgivelsesnoter",
        ReleaseNotesContent = "v1.2.0: Rettet placering af ammunitionsreserve, tilføjet støtte til nærkampsvåben, forbedret stabilitet.\nv1.2.1: Rettet spilfrysning på Volt og andre executors forårsaget af task.wait() inde i Heartbeat-handler; Rayfield indlæses nu asynkront.\nv1.3.0: Tilføjet Silent Aim (rækkevidde-skyder) og Hurtig Ild (op til 100 skud/s, afstand + nærkamp); Uendelig/Frosset Ammunition holder reserven på 99999.\n\nFandt du en fejl eller vil du anmode om en funktion? Åbn et issue på GitHub (Rival99900/Roblox-Scripts) eller post på ScriptBlox.",
        Aimbot              = "Aimbot",
        AutoBring           = "Auto Hent",
        BringRadius         = "Hentningsradius (studs)",
        BringInterval       = "Hentningsinterval (s)",
        MaxZombieDist       = "Maks Zombie Afstand",
        InfiniteAmmo        = "Uendelig Ammunition",
        FreezeAmmo          = "Frys Ammunition",
        FlyToggle           = "Fly",
        FlySpeed            = "Flyvehastighed",
        NoClip              = "NoClip",
        WalkSpeed           = "Gåhastighed",
        InfJump             = "Uendeligt Hop",
        AntiAFK             = "Anti-AFK",
        Fullbright          = "Fuld Lysstyrke",
        LanguageSelect      = "Sprog",
        LangNote            = "Sprogændring kræver genstart",
        MeleeSupport        = "Nærkampsstøtte",
        RapidFire           = "Hurtig Ild",
        SilentAim           = "Silent Aim",
        SilentRange         = "Silent Aim Rækkevidde (studs)",
        FireRate            = "Skudhastighed (skud/s)",
    },
}

local function T(key)
    local t = Translations[CurrentLang]
    if t and t[key] then return t[key] end
    return Translations["EN"][key] or key
end

-- ================================================================
-- Settings
-- ================================================================
local Settings = {
    Aimbot        = false,
    AutoBring     = false,
    BringRadius   = 3,
    BringInterval = 0.3,
    MaxZombieDist = 300,
    InfiniteAmmo  = false,
    FreezeAmmo    = false,
    Fly           = false,
    FlySpeed      = 60,
    NoClip        = false,
    WalkSpeed     = 16,
    InfJump       = false,
    AntiAFK       = false,
    Fullbright    = false,
    RapidFire     = false,
    SilentAim     = false,
    SilentRange   = 150,
    FireRate      = 10,
}

-- Ammo state
local _frozenClip    = nil
local _frozenReserve = nil

-- Fire rate limiting
local lastFireTime  = 0
local FIRE_COOLDOWN = 0.08

-- Aimbot lockout detection
local lastDamageTime = tick()

-- Auto Bring connection (stored so it can be disconnected on toggle OFF)
local bringTimer    = 0
local autoBringConn = nil

-- ================================================================
-- Melee support
-- ================================================================
local MeleeRemote = ReplicatedStorage.Events.Actions.MeleeRequest

local function isMelee(tool)
    if not tool then return false end
    return tool:FindFirstChild("Exit") == nil or tool:FindFirstChild("Info") == nil
end

-- ================================================================
-- Character helpers
-- ================================================================
local function getChar() return LocalPlayer.Character end
local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

-- ================================================================
-- Ammo helpers
-- ================================================================

-- Immediately write ammo values:
--   Clip  → Character[tool].Info.Clip (upvalue [19] confirmed)
--   Reserve → LocalPlayer.Reserve     (upvalue [33] confirmed)
local function applyAmmoNow(clipVal, reserveVal)
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            local info = tool:FindFirstChild("Info")
            if info then
                local clip = info:FindFirstChild("Clip")
                if clip then clip.Value = clipVal end
            end
        end
        local reserve = LocalPlayer:FindFirstChild("Reserve")
        if reserve then reserve.Value = reserveVal end
    end)
end

-- ================================================================
-- forceHandlerAmmo — patch the weapon Handler's internal clip value
-- v1.3.0 fix: the old version compared against the value it had
-- just written (so it never matched) and called debug.getupvalue on
-- the script Instance instead of its functions. Now it finds the
-- Handler's Lua functions via getgc (cached per Handler) and replaces
-- upvalues equal to the OLD clip value.
-- ================================================================
local _handlerFnCache = setmetatable({}, { __mode = "k" })

local function getHandlerFunctions(handler)
    local cached = _handlerFnCache[handler]
    if cached then return cached end
    local list = {}
    if getgc and debug and debug.getupvalue and debug.setupvalue then
        pcall(function()
            for _, f in ipairs(getgc(false)) do
                if type(f) == "function" and (not islclosure or islclosure(f)) then
                    local ok, env = pcall(getfenv, f)
                    if ok and type(env) == "table" then
                        local ok2, scr = pcall(function() return env.script end)
                        if ok2 and scr == handler then
                            list[#list + 1] = f
                        end
                    end
                end
            end
        end)
    end
    _handlerFnCache[handler] = list
    return list
end

local function forceHandlerAmmo(tool, targetValue, oldValue)
    if not tool or not oldValue or oldValue == targetValue then return end
    local handler = tool:FindFirstChild("Handler")
               or  tool:FindFirstChildOfClass("LocalScript")
    if not handler then return end
    pcall(function()
        for _, f in ipairs(getHandlerFunctions(handler)) do
            for i = 1, 200 do
                local ok, a, b = pcall(debug.getupvalue, f, i)
                if not ok then break end
                -- some executors return (name, value), others return value only
                local val = b
                if val == nil and type(a) ~= "string" then val = a end
                if a == nil and b == nil then break end
                if type(val) == "number" and val == oldValue then
                    pcall(debug.setupvalue, f, i, targetValue)
                end
            end
        end
    end)
end

-- Per-tool frozen clip (Freeze Ammo), so switching weapons works
local _frozenByTool = setmetatable({}, { __mode = "k" })

-- Apply the active ammo mode to the equipped tool right now
local function ammoTick()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local tool    = char:FindFirstChildOfClass("Tool")
        local reserve = LocalPlayer:FindFirstChild("Reserve")
        if not (Settings.InfiniteAmmo or Settings.FreezeAmmo) then return end

        -- Reserve always 99999 in both modes (game reserve is 2)
        if reserve and reserve.Value ~= 99999 then reserve.Value = 99999 end
        if not tool or isMelee(tool) then return end

        local info = tool:FindFirstChild("Info")
        local clip = info and info:FindFirstChild("Clip")
        if not clip then return end

        local want
        if Settings.InfiniteAmmo then
            want = 99999
        else
            want = _frozenByTool[tool]
            if not want then
                want = (clip.Value > 0) and clip.Value or 12
                _frozenByTool[tool] = want
            end
        end
        if clip.Value ~= want then
            local old = clip.Value
            clip.Value = want
            forceHandlerAmmo(tool, want, old)
        end
    end)
end

-- ================================================================
-- softReequip — reset Handler state via backpack re-parent
-- ================================================================
local function softReequip()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local tool = char:FindFirstChildOfClass("Tool")
        if not tool then return end
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if not backpack then return end
        tool.Parent = backpack
        task.wait(0.15)
        if LocalPlayer.Character then
            tool.Parent = LocalPlayer.Character
        end
        -- Re-apply active ammo mode
        task.wait(0.05)
        ammoTick()
    end)
end

-- ================================================================
-- Rayfield load (keyless) — async to avoid blocking main thread
-- Bug fix v1.2.1: synchronous load could block Volt's scheduler
-- ================================================================
local Rayfield     = nil
local rayfieldReady = false

task.spawn(function()
    local ok, result = pcall(function()
        return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
    end)
    if ok and result then
        Rayfield = result
    else
        warn("[Hub] Rayfield load failed: " .. tostring(result))
    end
    rayfieldReady = true
end)

local _rfWaited = 0
while not rayfieldReady do
    task.wait(0.1)
    _rfWaited = _rfWaited + 0.1
    if _rfWaited >= 20 then
        warn("[Hub] Rayfield timed out after 20s")
        return
    end
end

if not Rayfield then return end

local Window = Rayfield:CreateWindow({
    Name             = T("WindowTitle"),
    LoadingTitle     = T("WindowTitle"),
    LoadingSubtitle  = T("WindowSubtitle"),
    ConfigurationSaving = { Enabled = false },
    Discord          = { Enabled = false },
    KeySystem        = false,
})

-- ================================================================
-- Combat helpers
-- ================================================================

local function getClosestZombieTarget(maxDist)
    local hrp = getHRP()
    if not hrp then return nil end
    local bestPart, bestDist = nil, maxDist
    local zombieFolder = workspace:FindFirstChild("ActiveZombies")
    if not zombieFolder then return nil end
    for _, zombie in ipairs(zombieFolder:GetChildren()) do
        local hum = zombie:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            local zhrp = zombie:FindFirstChild("HumanoidRootPart")
            if zhrp then
                local dist = (zhrp.Position - hrp.Position).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    bestPart = zombie:FindFirstChild("HeadHitbox")
                           or zombie:FindFirstChild("Head")
                           or zhrp
                end
            end
        end
    end
    return bestPart
end

-- fireAtTarget — handles both ranged and melee weapons
local function fireAtTarget(targetPart, bypassCooldown)
    local now = tick()
    local cooldown = FIRE_COOLDOWN
    if Settings.SilentAim and Settings.FireRate > 0 then
        cooldown = 1 / math.min(Settings.FireRate, 30)
    end
    if not bypassCooldown and (now - lastFireTime) < cooldown then return false end
    lastFireTime = now

    local char = LocalPlayer.Character
    if not char then return false end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return false end

    -- Force ammo (ranged only — melee has no clip)
    local info = tool:FindFirstChild("Info")
    if info then
        local clip = info:FindFirstChild("Clip")
        if clip and clip.Value < 1 then clip.Value = 99999 end
    end
    local reserve = LocalPlayer:FindFirstChild("Reserve")
    if reserve and reserve.Value < 1 then reserve.Value = 99999 end

    pcall(function() tool:SetAttribute("Firing", false) end)
    pcall(function() tool:SetAttribute("ContinuousFireActive", false) end)

    local fired = false

    if isMelee(tool) then
        -- Melee: bring zombie to within 3 studs, then fire MeleeRequest
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp and targetPart then
            local zombieHRP = targetPart.Parent
                          and targetPart.Parent:FindFirstChild("HumanoidRootPart")
            if zombieHRP then
                pcall(function()
                    zombieHRP.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 0, -3))
                end)
            end
        end
        pcall(function()
            MeleeRemote:FireServer()
            fired = true
        end)
        pcall(function() tool:SetAttribute("Firing", false) end)
    else
        -- Ranged: use Fire + Fire_2 remotes
        local weaponName = tool.Name
        local exitPart   = tool:FindFirstChild("Exit")
        if not exitPart then return false end
        local hitPos    = targetPart.Position
        local rayOrigin = hitPos + Vector3.new(0, 0.01, 0)
        local normalVec = Vector3.new(0, 1, 0)
        pcall(function()
            ReplicatedStorage.Events.Actions.Fire:FireServer(
                weaponName,
                {{ targetPart, hitPos, normalVec }},
                {{ weaponName, rayOrigin, hitPos, hitPos, true, targetPart, false, false, "Default", exitPart }}
            )
            fired = true
        end)
        pcall(function()
            ReplicatedStorage.Events.Actions.Fire_2:FireServer(
                weaponName,
                {{ targetPart, hitPos, normalVec }},
                {{ weaponName, rayOrigin, hitPos, hitPos, true, targetPart, false, false, "Default", exitPart }}
            )
            fired = true
        end)
    end

    if fired then
        lastDamageTime = tick()
    end
    return fired
end

-- ================================================================
-- TABS
-- ================================================================

local HomeTab = Window:CreateTab(T("TabHome"), 4483362458)
HomeTab:CreateParagraph({
    Title   = T("CreditsTitle"),
    Content = T("CreditsContent"),
})
HomeTab:CreateParagraph({
    Title   = T("ReleaseNotesTitle"),
    Content = T("ReleaseNotesContent"),
})

local CombatTab = Window:CreateTab(T("TabCombat"), 4483362458)

CombatTab:CreateToggle({
    Name         = T("Aimbot"),
    CurrentValue = false,
    Callback     = function(val)
        Settings.Aimbot = val
        if val then
            lastDamageTime = tick()
        end
    end,
})

CombatTab:CreateSlider({
    Name         = T("MaxZombieDist"),
    Range        = {50, 500},
    Increment    = 10,
    CurrentValue = 300,
    Callback     = function(val) Settings.MaxZombieDist = val end,
})

CombatTab:CreateToggle({
    Name         = T("AutoBring"),
    CurrentValue = false,
    Callback     = function(val)
        Settings.AutoBring = val
        if val then
            bringTimer = 0
            if autoBringConn then autoBringConn:Disconnect() end
            -- Bug fix v1.2.1: removed task.wait() that was directly inside the
            -- Heartbeat handler — yielding inside a Heartbeat callback freezes
            -- the thread scheduler on Volt and other strict executors.
            -- The bringTimer + dt accumulator already controls the interval.
            autoBringConn = RunService.Heartbeat:Connect(function(dt)
                if not Settings.AutoBring then return end
                bringTimer = bringTimer + dt
                if bringTimer < Settings.BringInterval then return end
                bringTimer = 0
                task.spawn(function()
                    pcall(function()
                        local hrp = getHRP()
                        if not hrp then return end
                        local zombieFolder = workspace:FindFirstChild("ActiveZombies")
                        if not zombieFolder then return end
                        local zombies = zombieFolder:GetChildren()
                        local total   = #zombies
                        if total == 0 then return end

                        local char = LocalPlayer.Character
                        local tool = char and char:FindFirstChildOfClass("Tool")
                        local meleeMode = isMelee(tool)

                        for i, zombie in ipairs(zombies) do
                            local hum = zombie:FindFirstChildOfClass("Humanoid")
                            if hum and hum.Health > 0 then
                                local zhrp = zombie:FindFirstChild("HumanoidRootPart")
                                if zhrp then
                                    local radius = meleeMode and 3 or Settings.BringRadius
                                    local angle  = ((i - 1) / total) * (2 * math.pi)
                                    local offset = Vector3.new(
                                        math.cos(angle), 0, math.sin(angle)
                                    ) * radius
                                    pcall(function()
                                        zhrp.CFrame   = CFrame.new(hrp.Position + offset)
                                        hum.WalkSpeed = 0
                                    end)
                                    if Settings.Aimbot then
                                        local target = zombie:FindFirstChild("HeadHitbox")
                                                    or zombie:FindFirstChild("Head")
                                                    or zhrp
                                        if meleeMode then
                                            pcall(function() MeleeRemote:FireServer() end)
                                        else
                                            task.spawn(function() fireAtTarget(target) end)
                                        end
                                        task.wait(0.05)
                                    else
                                        task.wait(0.01)
                                    end
                                end
                            end
                        end
                    end)
                end)
            end)
        else
            if autoBringConn then
                autoBringConn:Disconnect()
                autoBringConn = nil
            end
            bringTimer = 0
            pcall(function()
                local zombieFolder = workspace:FindFirstChild("ActiveZombies")
                if not zombieFolder then return end
                for _, zombie in ipairs(zombieFolder:GetChildren()) do
                    local hum = zombie:FindFirstChildOfClass("Humanoid")
                    if hum then hum.WalkSpeed = 16 end
                end
            end)
        end
    end,
})

CombatTab:CreateSlider({
    Name         = T("BringRadius"),
    Range        = {1, 10},
    Increment    = 1,
    CurrentValue = 3,
    Callback     = function(val) Settings.BringRadius = val end,
})

CombatTab:CreateSlider({
    Name         = T("BringInterval"),
    Range        = {0.1, 2.0},
    Increment    = 0.1,
    CurrentValue = 0.3,
    Callback     = function(val) Settings.BringInterval = val end,
})

CombatTab:CreateToggle({
    Name         = T("InfiniteAmmo"),
    CurrentValue = false,
    Callback     = function(val)
        Settings.InfiniteAmmo = val
        if val then
            Settings.FreezeAmmo = false
            _frozenClip    = nil
            _frozenReserve = nil
            ammoTick()
        end
    end,
})

CombatTab:CreateToggle({
    Name         = T("FreezeAmmo"),
    CurrentValue = false,
    Callback     = function(val)
        Settings.FreezeAmmo = val
        if val then
            Settings.InfiniteAmmo = false
            -- Freeze the current clip of each weapon (captured per tool)
            for k in pairs(_frozenByTool) do _frozenByTool[k] = nil end
            _frozenClip    = true
            _frozenReserve = 99999
            ammoTick()
        else
            _frozenClip    = nil
            _frozenReserve = nil
            for k in pairs(_frozenByTool) do _frozenByTool[k] = nil end
        end
    end,
})

-- ================================================================
-- Shared fire input (mouse button 1 / screen touch held)
-- ================================================================
local fireHolding = false

UserInputService.InputBegan:Connect(function(inp, proc)
    if proc then return end
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        fireHolding = true
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        fireHolding = false
    end
end)

-- Zombie part under the cursor, or nil
local function getCursorZombiePart()
    local target = nil
    pcall(function()
        local mouse  = LocalPlayer:GetMouse()
        local part   = mouse and mouse.Target
        local folder = workspace:FindFirstChild("ActiveZombies")
        if part and folder and part:IsDescendantOf(folder) then
            local model = part
            while model and model.Parent ~= folder do model = model.Parent end
            if model then
                local hum = model:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    target = model:FindFirstChild("HeadHitbox")
                          or model:FindFirstChild("Head")
                          or model:FindFirstChild("HumanoidRootPart")
                end
            end
        end
    end)
    return target
end

-- ================================================================
-- Silent Aim (v1.3.0)
-- While firing, hits the zombie under the cursor, otherwise the
-- closest zombie within Silent Aim Range. Melee uses MeleeRequest.
-- ================================================================
local function getSilentTarget()
    local cursor = getCursorZombiePart()
    if cursor then
        local hrp = getHRP()
        if hrp and (cursor.Position - hrp.Position).Magnitude <= Settings.SilentRange then
            return cursor
        end
    end
    return getClosestZombieTarget(Settings.SilentRange)
end

-- ================================================================
-- Rapid Fire helpers (v1.3.0) — weapon cooldown reset
-- Ranged: extra Fire/Fire_2 shots on the zombie under the cursor.
-- Melee: extra MeleeRequest swings at the chosen rate.
-- Also clears the weapon's Firing/cooldown attributes so the
-- game's own handler does not wait between shots.
-- ================================================================
local function clearWeaponCooldown(tool)
    pcall(function()
        for name, val in pairs(tool:GetAttributes()) do
            local n = string.lower(name)
            if type(val) == "boolean" and (n:find("cooldown") or n:find("debounce") or n == "firing" or n:find("swinging")) then
                tool:SetAttribute(name, false)
            elseif type(val) == "number" and (n:find("cooldown") or n:find("debounce")) then
                tool:SetAttribute(name, 0)
            end
        end
    end)
end

-- Silent Aim loop (unchanged behaviour, max 30 shots/s)
task.spawn(function()
    while true do
        local rate = math.clamp(Settings.FireRate or 10, 1, 30)
        task.wait(1 / rate)
        if fireHolding and Settings.SilentAim and not Settings.RapidFire then
            pcall(function()
                local char = LocalPlayer.Character
                local tool = char and char:FindFirstChildOfClass("Tool")
                if not tool then return end
                local target = getSilentTarget()
                if isMelee(tool) then
                    if target then
                        fireAtTarget(target)          -- pulls zombie close + swings
                    else
                        MeleeRemote:FireServer()
                        lastDamageTime = tick()
                    end
                elseif target then
                    fireAtTarget(target)
                end
            end)
        end
    end
end)

-- Rapid Fire (v1.3.0) — up to 100 shots/s
-- Heartbeat accumulator: several shots per frame when the rate is
-- higher than the frame rate. Handler never yields (Volt-safe);
-- the actual firing runs in task.spawn.
-- Target: ONLY the zombie you aim at (never other zombies, even if
-- Silent Aim is ON) — the zombie you aim at (camera ray through cursor/touch, with a small
-- tolerance around the ray).
local lastAimPos = nil
UserInputService.InputChanged:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch then
        lastAimPos = Vector2.new(inp.Position.X, inp.Position.Y)
    end
end)
UserInputService.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch then
        lastAimPos = Vector2.new(inp.Position.X, inp.Position.Y)
    end
end)

local function getAimedZombiePart()
    local cursor = getCursorZombiePart()
    if cursor then return cursor end
    local best = nil
    pcall(function()
        local cam    = workspace.CurrentCamera
        local folder = workspace:FindFirstChild("ActiveZombies")
        if not cam or not folder then return end
        local pos
        if UserInputService.TouchEnabled and lastAimPos then
            pos = lastAimPos
        else
            pos = UserInputService:GetMouseLocation()
        end
        local ray = cam:ViewportPointToRay(pos.X, pos.Y)
        local bestDist = 3 -- studs of tolerance around the aim ray
        for _, zombie in ipairs(folder:GetChildren()) do
            local hum = zombie:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local part = zombie:FindFirstChild("HeadHitbox")
                          or zombie:FindFirstChild("Head")
                          or zombie:FindFirstChild("HumanoidRootPart")
                if part then
                    local rel = part.Position - ray.Origin
                    local along = rel:Dot(ray.Direction)
                    if along > 0 and along <= Settings.MaxZombieDist then
                        local off = (rel - ray.Direction * along).Magnitude
                        if off < bestDist then
                            bestDist = off
                            best = part
                        end
                    end
                end
            end
        end
    end)
    return best
end

-- Weapon fire-rate boost: speeds up the game's own firing (visible
-- shots) by scaling rate/cooldown values in tool.Info and tool
-- attributes. Originals are restored when Rapid Fire is turned off
-- or the weapon is unequipped.
local _rateOriginals = {}   -- [instance or {tool,attr}] = original

local RATE_UP   = { "firerate", "rpm", "rateoffire", "shootrate", "fire_rate" }
local RATE_DOWN = { "cooldown", "firedelay", "delay", "debounce", "firecooldown", "shotdelay", "swingcooldown" }

local function rateKind(name)
    local n = string.lower(name)
    for _, k in ipairs(RATE_UP)   do if n == k or n:find(k, 1, true) then return "up"   end end
    for _, k in ipairs(RATE_DOWN) do if n == k or n:find(k, 1, true) then return "down" end end
    return nil
end

local function restoreWeaponRate()
    for key, orig in pairs(_rateOriginals) do
        pcall(function()
            if typeof(key) == "Instance" then
                key.Value = orig
            elseif type(key) == "table" then
                key[1]:SetAttribute(key[2], orig)
            end
        end)
        _rateOriginals[key] = nil
    end
end

local _boostedTool = nil
local function boostWeaponRate(tool)
    if _boostedTool == tool then return end
    restoreWeaponRate()
    _boostedTool = tool
    if not tool then return end
    local factor = math.max(1, (Settings.FireRate or 10) / 10)
    pcall(function()
        local info = tool:FindFirstChild("Info")
        local holders = { tool }
        if info then holders[#holders + 1] = info end
        for _, holder in ipairs(holders) do
            for _, v in ipairs(holder:GetChildren()) do
                if v:IsA("NumberValue") or v:IsA("IntValue") then
                    local kind = rateKind(v.Name)
                    if kind and v.Value > 0 then
                        _rateOriginals[v] = v.Value
                        if kind == "up" then
                            v.Value = v.Value * factor
                        else
                            v.Value = v.Value / factor
                        end
                    end
                end
            end
            for name, val in pairs(holder:GetAttributes()) do
                if type(val) == "number" and val > 0 then
                    local kind = rateKind(name)
                    if kind then
                        _rateOriginals[{ holder, name }] = val
                        holder:SetAttribute(name, kind == "up" and val * factor or val / factor)
                    end
                end
            end
        end
    end)
end

local rapidAccum = 0
RunService.Heartbeat:Connect(function(dt)
    -- No yield in this handler (Volt-safe)
    if not Settings.RapidFire then
        if _boostedTool then
            _boostedTool = nil
            restoreWeaponRate()
        end
        rapidAccum = 0
        return
    end
    local char = LocalPlayer.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    if tool ~= _boostedTool then boostWeaponRate(tool) end

    if not fireHolding or not tool then
        rapidAccum = 0
        return
    end

    -- Native activation every frame → the game's own (visible) shots
    pcall(function()
        clearWeaponCooldown(tool)
        tool:Activate()
    end)

    local rate = math.clamp(Settings.FireRate or 10, 1, 100)
    rapidAccum = rapidAccum + dt * rate
    local shots = math.floor(rapidAccum)
    if shots < 1 then return end
    rapidAccum = rapidAccum - shots
    shots = math.min(shots, 10)
    task.spawn(function()
        pcall(function()
            local target = getAimedZombiePart()
            for _ = 1, shots do
                if isMelee(tool) then
                    pcall(function() MeleeRemote:FireServer() end)
                    lastDamageTime = tick()
                elseif target then
                    fireAtTarget(target, true)
                end
            end
        end)
    end)
end)

CombatTab:CreateToggle({
    Name         = T("SilentAim"),
    CurrentValue = false,
    Callback     = function(val) Settings.SilentAim = val end,
})

CombatTab:CreateSlider({
    Name         = T("SilentRange"),
    Range        = {10, 500},
    Increment    = 10,
    CurrentValue = 150,
    Callback     = function(val) Settings.SilentRange = val end,
})

CombatTab:CreateToggle({
    Name         = T("RapidFire"),
    CurrentValue = false,
    Callback     = function(val)
        Settings.RapidFire = val
        if not val then
            _boostedTool = nil
            restoreWeaponRate()
        end
    end,
})

CombatTab:CreateSlider({
    Name         = T("FireRate"),
    Range        = {1, 100},
    Increment    = 1,
    CurrentValue = 10,
    Callback     = function(val)
        Settings.FireRate = val
        if Settings.RapidFire then
            _boostedTool = nil   -- re-apply boost with the new factor
            restoreWeaponRate()
        end
    end,
})

-- ───── Movement Tab ─────
local MovementTab = Window:CreateTab(T("TabMovement"), 4483362458)

-- ================================================================
-- Fly system (do not touch logic — only pcall wraps on Instance.new)
-- ================================================================
local FLYING       = false
local FLY_BTN_UP   = 0
local FLY_BTN_DOWN = 0
local flyKeyDown, flyKeyUp
local _flyUpBtn, _flyDownBtn

local function enableFly()
    local char = getChar()
    local hrp  = getHRP()
    local hum  = getHum()
    if not char or not hrp or not hum then return end

    if flyKeyDown then flyKeyDown:Disconnect() end
    if flyKeyUp   then flyKeyUp:Disconnect()   end

    FLYING = true

    local CTRL = {F=0, B=0, L=0, R=0, UP=0, DOWN=0}

    local bv, bg
    pcall(function()
        bv = Instance.new("BodyVelocity")
        bv.Name      = "_SWAT_FLY_BV"
        bv.MaxForce  = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity  = Vector3.zero
        bv.Parent    = hrp
    end)
    pcall(function()
        bg = Instance.new("BodyGyro")
        bg.Name      = "_SWAT_FLY_BG"
        bg.P         = 9e4
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.CFrame    = hrp.CFrame
        bg.Parent    = hrp
    end)
    if not bv or not bg then FLYING = false return end

    hum.PlatformStand = true

    flyKeyDown = UserInputService.InputBegan:Connect(function(inp, proc)
        if proc then return end
        local k = inp.KeyCode
        if     k == Enum.KeyCode.W          then CTRL.F    =  1
        elseif k == Enum.KeyCode.S          then CTRL.B    = -1
        elseif k == Enum.KeyCode.A          then CTRL.L    = -1
        elseif k == Enum.KeyCode.D          then CTRL.R    =  1
        elseif k == Enum.KeyCode.Space      then CTRL.UP   =  1
        elseif k == Enum.KeyCode.LeftShift
            or k == Enum.KeyCode.RightShift then CTRL.DOWN = -1
        end
    end)

    flyKeyUp = UserInputService.InputEnded:Connect(function(inp, proc)
        if proc then return end
        local k = inp.KeyCode
        if     k == Enum.KeyCode.W          then CTRL.F    = 0
        elseif k == Enum.KeyCode.S          then CTRL.B    = 0
        elseif k == Enum.KeyCode.A          then CTRL.L    = 0
        elseif k == Enum.KeyCode.D          then CTRL.R    = 0
        elseif k == Enum.KeyCode.Space      then CTRL.UP   = 0
        elseif k == Enum.KeyCode.LeftShift
            or k == Enum.KeyCode.RightShift then CTRL.DOWN = 0
        end
    end)

    if _flyUpBtn   then _flyUpBtn.Visible   = true end
    if _flyDownBtn then _flyDownBtn.Visible = true end

    task.spawn(function()
        while FLYING do
            task.wait()
            local camCF    = workspace.CurrentCamera.CFrame
            local rawLook  = camCF.LookVector
            local rawRight = camCF.RightVector
            local spd      = Settings.FlySpeed

            local flatLook  = Vector3.new(rawLook.X,  0, rawLook.Z)
            local flatRight = Vector3.new(rawRight.X, 0, rawRight.Z)
            if flatLook.Magnitude  > 0 then flatLook  = flatLook.Unit  end
            if flatRight.Magnitude > 0 then flatRight = flatRight.Unit end

            local pcVel = flatLook  * CTRL.F
                        + flatLook  * CTRL.B
                        + flatRight * CTRL.R
                        + flatRight * CTRL.L

            local md        = hum.MoveDirection
            local mobileVel = Vector3.new(md.X, 0, md.Z)

            local horizVel
            if md.Magnitude > 0.1 then
                horizVel = mobileVel * spd
            else
                horizVel = pcVel * spd
            end

            local vertVel = Vector3.new(0, (CTRL.UP + CTRL.DOWN + FLY_BTN_UP + FLY_BTN_DOWN) * spd, 0)
            bv.Velocity = horizVel + vertVel
            bg.CFrame   = camCF
        end
    end)
end

local function disableFly()
    FLYING = false
    FLY_BTN_UP   = 0
    FLY_BTN_DOWN = 0
    if flyKeyDown then flyKeyDown:Disconnect(); flyKeyDown = nil end
    if flyKeyUp   then flyKeyUp:Disconnect();   flyKeyUp   = nil end
    local hrp = getHRP()
    if hrp then
        local b = hrp:FindFirstChild("_SWAT_FLY_BV"); if b then b:Destroy() end
        local g = hrp:FindFirstChild("_SWAT_FLY_BG"); if g then g:Destroy() end
    end
    local h = getHum()
    if h then h.PlatformStand = false end
    if _flyUpBtn   then _flyUpBtn.Visible   = false end
    if _flyDownBtn then _flyDownBtn.Visible = false end
end

-- Mobile ▲▼ buttons
if UserInputService.TouchEnabled then
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        local flyGui = Instance.new("ScreenGui")
        flyGui.Name           = "TozFlyOverlay"
        flyGui.ResetOnSpawn   = false
        flyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        flyGui.Parent         = playerGui

        local BTN = 60
        local GAP = 8

        local function makeBtn(text, xOffset)
            local btn = Instance.new("TextButton")
            btn.Size                   = UDim2.new(0, BTN, 0, BTN)
            btn.Position               = UDim2.new(0.5, xOffset, 1, -(BTN + 20))
            btn.AnchorPoint            = Vector2.new(0, 0)
            btn.BackgroundColor3       = Color3.fromRGB(40, 40, 40)
            btn.BackgroundTransparency = 0.3
            btn.TextColor3             = Color3.new(1, 1, 1)
            btn.Text                   = text
            btn.TextScaled             = true
            btn.Font                   = Enum.Font.GothamBold
            btn.Visible                = false
            btn.Parent                 = flyGui
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 10)
            corner.Parent       = btn
            return btn
        end

        _flyUpBtn   = makeBtn("▲", -(BTN + GAP / 2))
        _flyDownBtn = makeBtn("▼",   GAP / 2)

        _flyUpBtn.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch then FLY_BTN_UP = 1 end
        end)
        _flyUpBtn.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch then FLY_BTN_UP = 0 end
        end)
        _flyDownBtn.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch then FLY_BTN_DOWN = -1 end
        end)
        _flyDownBtn.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch then FLY_BTN_DOWN = 0 end
        end)
    end
end

MovementTab:CreateToggle({
    Name         = T("FlyToggle"),
    CurrentValue = false,
    Callback     = function(val)
        Settings.Fly = val
        if val then enableFly() else disableFly() end
    end,
})

MovementTab:CreateSlider({
    Name         = T("FlySpeed"),
    Range        = {10, 300},
    Increment    = 5,
    CurrentValue = 60,
    Callback     = function(val) Settings.FlySpeed = val end,
})

local noClipConn
MovementTab:CreateToggle({
    Name         = T("NoClip"),
    CurrentValue = false,
    Callback     = function(val)
        Settings.NoClip = val
        if val then
            if not noClipConn then
                -- Bug fix v1.2.1: removed task.wait() that was directly inside
                -- the Stepped handler — same freeze issue as in Heartbeat.
                noClipConn = RunService.Stepped:Connect(function()
                    if not Settings.NoClip then
                        noClipConn:Disconnect()
                        noClipConn = nil
                        return
                    end
                    pcall(function()
                        local char = getChar()
                        if not char then return end
                        for _, p in ipairs(char:GetDescendants()) do
                            if p:IsA("BasePart") then p.CanCollide = false end
                        end
                    end)
                end)
            end
        else
            if noClipConn then noClipConn:Disconnect() noClipConn = nil end
        end
    end,
})

MovementTab:CreateSlider({
    Name         = T("WalkSpeed"),
    Range        = {16, 250},
    Increment    = 1,
    CurrentValue = 16,
    Callback     = function(val)
        Settings.WalkSpeed = val
        pcall(function()
            local hum = getHum()
            if hum then hum.WalkSpeed = val end
        end)
    end,
})

MovementTab:CreateToggle({
    Name         = T("InfJump"),
    CurrentValue = false,
    Callback     = function(val) Settings.InfJump = val end,
})

local ToolsTab = Window:CreateTab(T("TabTools"), 4483362458)

ToolsTab:CreateToggle({
    Name         = T("Fullbright"),
    CurrentValue = false,
    Callback     = function(val)
        Settings.Fullbright = val
        pcall(function()
            local lighting = game:GetService("Lighting")
            if val then
                lighting.Brightness    = 10
                lighting.GlobalShadows = false
                lighting.ClockTime     = 14
            else
                lighting.Brightness    = 1
                lighting.GlobalShadows = true
                lighting.ClockTime     = 14
            end
        end)
    end,
})

local afkThread
ToolsTab:CreateToggle({
    Name         = T("AntiAFK"),
    CurrentValue = false,
    Callback     = function(val)
        Settings.AntiAFK = val
        if val then
            if not afkThread then
                afkThread = task.spawn(function()
                    while Settings.AntiAFK do
                        task.wait(60)
                        pcall(function()
                            local hrp = getHRP()
                            if hrp then
                                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(0.01), 0)
                            end
                        end)
                    end
                    afkThread = nil
                end)
            end
        end
    end,
})

ToolsTab:CreateDropdown({
    Name          = T("LanguageSelect"),
    Options       = {"EN","FR","DE","ES","PT","RU","IT","NL","PL","ZH","JA","TR","KO","AR","VI","SV","EL","RO","UK","CS","DA"},
    CurrentOption = {"EN"},
    Callback      = function(opt)
        CurrentLang = type(opt) == "table" and opt[1] or opt
    end,
})

ToolsTab:CreateLabel(T("LangNote"))

-- ================================================================
-- Ammo maintenance loop — 0.3s interval
-- Clip  → tool.Info.Clip
-- Reserve → LocalPlayer.Reserve (confirmed upvalue [33])
-- ================================================================
task.spawn(function()
    while true do
        task.wait(0.3)
        ammoTick()
    end
end)

-- Re-apply instantly on weapon switch / respawn (fixes "need to toggle
-- off and on again"). Handler is given a moment to initialise.
local function watchCharacterTools(char)
    if not char then return end
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            task.spawn(function()
                task.wait(0.1)
                ammoTick()
                task.wait(0.4)
                ammoTick()
            end)
        end
    end)
end
watchCharacterTools(LocalPlayer.Character)
LocalPlayer.CharacterAdded:Connect(watchCharacterTools)

-- ================================================================
-- Lockout watchdog — 0.5s interval
-- ================================================================
task.spawn(function()
    while true do
        task.wait(0.5)
        if Settings.Aimbot and (tick() - lastDamageTime) > 3 then
            local target = getClosestZombieTarget(Settings.MaxZombieDist)
            if target then
                softReequip()
                lastDamageTime = tick()
            end
        end
    end
end)

-- ================================================================
-- Main Loops
-- ================================================================

local aimbotConn
local function connectAimbot()
    if aimbotConn then aimbotConn:Disconnect() end
    aimbotConn = RunService.RenderStepped:Connect(function()
        if not Settings.Aimbot then return end
        pcall(function()
            local cam        = workspace.CurrentCamera
            local targetPart = getClosestZombieTarget(Settings.MaxZombieDist)
            if targetPart then
                cam.CFrame = CFrame.lookAt(cam.CFrame.Position, targetPart.Position)
            end
        end)
        -- Fire melee automatically when in aimbot mode with melee weapon
        pcall(function()
            local char = LocalPlayer.Character
            local tool = char and char:FindFirstChildOfClass("Tool")
            if tool and isMelee(tool) then
                local target = getClosestZombieTarget(Settings.MaxZombieDist)
                if target then
                    fireAtTarget(target)
                end
            end
        end)
    end)
end
connectAimbot()
LocalPlayer.CharacterAdded:Connect(function()
    connectAimbot()
    lastDamageTime = tick()
end)

UserInputService.JumpRequest:Connect(function()
    if not Settings.InfJump then return end
    pcall(function()
        local hum = getHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end)

pcall(function()
    ReplicatedStorage.Events.Communication.LavaRising.OnClientEvent:Connect(function()
        Rayfield:Notify({
            Title    = "⚠️ Lava Rising!",
            Content  = "Lava is rising — climb fast!",
            Duration = 4,
            Image    = 4483362458,
        })
    end)
end)

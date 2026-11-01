--[[
    ================================================================
    Tower of Zombies Hub — Tower of Zombies
    Created by Rival960 with the help of Claude
    Version: v1.1.0 | Languages: 21 | Rayfield UI
    Status: untested in-game
    ================================================================
]]

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
        CreditsContent      = "Created by Rival960 with the help of AI\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.1.0 — Combat Update",
        ReleaseNotesTitle   = "v1.1.0 — Release Notes",
        ReleaseNotesContent = "New features: Infinite Ammo, Freeze Ammo, Kill Aura, Auto Bring improvements, Aimbot ammo override fix.\nFound a bug or want to request a feature? Open an issue on GitHub (Rival99900/Roblox-Scripts) or post on ScriptBlox.",
        Aimbot              = "Aimbot",
        AutoBring           = "Auto Bring",
        BringRadius         = "Bring Radius (studs)",
        BringInterval       = "Bring Interval (s)",
        MaxZombieDist       = "Max Zombie Distance",
        InfiniteAmmo        = "Infinite Ammo",
        FreezeAmmo          = "Freeze Ammo",
        KillAura            = "Kill Aura",
        KillAuraRange       = "Kill Aura Range",
        KillAuraInterval    = "Kill Aura Interval (s)",
        FlyToggle           = "Fly",
        FlySpeed            = "Fly Speed",
        NoClip              = "NoClip",
        WalkSpeed           = "Walk Speed",
        InfJump             = "Infinite Jump",
        AntiAFK             = "Anti-AFK",
        Fullbright          = "Fullbright",
        LanguageSelect      = "Language",
        LangNote            = "Language change requires re-execution",
    },
    FR = {
        WindowTitle         = "Tower of Zombies Hub",
        WindowSubtitle      = "par Rival960",
        TabHome             = "Accueil",
        TabCombat           = "Combat",
        TabMovement         = "Déplacement",
        TabTools            = "Outils & Visuels",
        CreditsTitle        = "Crédits",
        CreditsContent      = "Créé par Rival960 avec l'aide de l'IA\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.1.0 — Mise à Jour Combat",
        ReleaseNotesTitle   = "v1.1.0 — Notes de Version",
        ReleaseNotesContent = "Nouvelles fonctionnalités : Munitions Infinies, Geler les Munitions, Aura de Mort, améliorations Auto Attirer, correction munitions Aimbot.\nVous avez trouvé un bug ou souhaitez demander une fonctionnalité ? Ouvrez un ticket sur GitHub (Rival99900/Roblox-Scripts) ou postez sur ScriptBlox.",
        Aimbot              = "Aimbot",
        AutoBring           = "Auto Attirer",
        BringRadius         = "Rayon d'attrait (studs)",
        BringInterval       = "Intervalle d'attrait (s)",
        MaxZombieDist       = "Distance Max Zombie",
        InfiniteAmmo        = "Munitions Infinies",
        FreezeAmmo          = "Geler les Munitions",
        KillAura            = "Aura de Mort",
        KillAuraRange       = "Portée de l'Aura",
        KillAuraInterval    = "Intervalle de l'Aura (s)",
        FlyToggle           = "Vol",
        FlySpeed            = "Vitesse de Vol",
        NoClip              = "NoClip",
        WalkSpeed           = "Vitesse de Marche",
        InfJump             = "Saut Infini",
        AntiAFK             = "Anti-AFK",
        Fullbright          = "Luminosité Max",
        LanguageSelect      = "Langue",
        LangNote            = "Le changement de langue nécessite une ré-exécution",
    },
    DE = {
        WindowTitle         = "Tower of Zombies Hub",
        WindowSubtitle      = "von Rival960",
        TabHome             = "Start",
        TabCombat           = "Kampf",
        TabMovement         = "Bewegung",
        TabTools            = "Tools & Visuals",
        CreditsTitle        = "Credits",
        CreditsContent      = "Erstellt von Rival960 mit KI-Hilfe\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.1.0 — Kampf-Update",
        ReleaseNotesTitle   = "v1.1.0 — Versionshinweise",
        ReleaseNotesContent = "Neue Features: Unendlich Munition, Munition Einfrieren, Todes-Aura, Auto Anziehen Verbesserungen, Aimbot Munitionsfehler behoben.\nBug gefunden oder Feature-Wunsch? Erstelle ein Issue auf GitHub (Rival99900/Roblox-Scripts) oder schreibe auf ScriptBlox.",
        Aimbot              = "Aimbot",
        AutoBring           = "Auto Anziehen",
        BringRadius         = "Anzugsradius (studs)",
        BringInterval       = "Anzugsintervall (s)",
        MaxZombieDist       = "Max Zombie-Distanz",
        InfiniteAmmo        = "Unendlich Munition",
        FreezeAmmo          = "Munition Einfrieren",
        KillAura            = "Todes-Aura",
        KillAuraRange       = "Aura-Reichweite",
        KillAuraInterval    = "Aura-Intervall (s)",
        FlyToggle           = "Fliegen",
        FlySpeed            = "Fluggeschwindigkeit",
        NoClip              = "NoClip",
        WalkSpeed           = "Laufgeschwindigkeit",
        InfJump             = "Unendlicher Sprung",
        AntiAFK             = "Anti-AFK",
        Fullbright          = "Vollhelligkeit",
        LanguageSelect      = "Sprache",
        LangNote            = "Sprachänderung erfordert Neuausführung",
    },
    ES = {
        WindowTitle         = "Tower of Zombies Hub",
        WindowSubtitle      = "por Rival960",
        TabHome             = "Inicio",
        TabCombat           = "Combate",
        TabMovement         = "Movimiento",
        TabTools            = "Herramientas",
        CreditsTitle        = "Créditos",
        CreditsContent      = "Creado por Rival960 con ayuda de IA\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.1.0 — Actualización de Combate",
        ReleaseNotesTitle   = "v1.1.0 — Notas de Versión",
        ReleaseNotesContent = "Nuevas funciones: Munición Infinita, Congelar Munición, Aura Mortífera, mejoras Auto Atraer, corrección munición Aimbot.\n¿Encontraste un error o quieres pedir una función? Abre un issue en GitHub (Rival99900/Roblox-Scripts) o publica en ScriptBlox.",
        Aimbot              = "Aimbot",
        AutoBring           = "Auto Atraer",
        BringRadius         = "Radio de Atracción (studs)",
        BringInterval       = "Intervalo de Atracción (s)",
        MaxZombieDist       = "Distancia Máx Zombie",
        InfiniteAmmo        = "Munición Infinita",
        FreezeAmmo          = "Congelar Munición",
        KillAura            = "Aura Mortífera",
        KillAuraRange       = "Alcance del Aura",
        KillAuraInterval    = "Intervalo del Aura (s)",
        FlyToggle           = "Volar",
        FlySpeed            = "Velocidad de Vuelo",
        NoClip              = "NoClip",
        WalkSpeed           = "Velocidad de Caminar",
        InfJump             = "Salto Infinito",
        AntiAFK             = "Anti-AFK",
        Fullbright          = "Brillo Total",
        LanguageSelect      = "Idioma",
        LangNote            = "El cambio de idioma requiere re-ejecución",
    },
    PT = {
        WindowTitle         = "Tower of Zombies Hub",
        WindowSubtitle      = "por Rival960",
        TabHome             = "Início",
        TabCombat           = "Combate",
        TabMovement         = "Movimento",
        TabTools            = "Ferramentas",
        CreditsTitle        = "Créditos",
        CreditsContent      = "Criado por Rival960 com ajuda de IA\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.1.0 — Atualização de Combate",
        ReleaseNotesTitle   = "v1.1.0 — Notas da Versão",
        ReleaseNotesContent = "Novidades: Munição Infinita, Congelar Munição, Aura Mortal, melhorias Auto Atrair, correção de munição do Aimbot.\nEncontrou um bug ou quer sugerir uma função? Abra uma issue no GitHub (Rival99900/Roblox-Scripts) ou publique no ScriptBlox.",
        Aimbot              = "Aimbot",
        AutoBring           = "Auto Atrair",
        BringRadius         = "Raio de Atração (studs)",
        BringInterval       = "Intervalo de Atração (s)",
        MaxZombieDist       = "Distância Máx Zumbi",
        InfiniteAmmo        = "Munição Infinita",
        FreezeAmmo          = "Congelar Munição",
        KillAura            = "Aura Mortal",
        KillAuraRange       = "Alcance da Aura",
        KillAuraInterval    = "Intervalo da Aura (s)",
        FlyToggle           = "Voar",
        FlySpeed            = "Velocidade de Voo",
        NoClip              = "NoClip",
        WalkSpeed           = "Velocidade de Caminhada",
        InfJump             = "Salto Infinito",
        AntiAFK             = "Anti-AFK",
        Fullbright          = "Brilho Total",
        LanguageSelect      = "Idioma",
        LangNote            = "Mudança de idioma requer re-execução",
    },
    RU = {
        WindowTitle         = "Tower of Zombies Hub",
        WindowSubtitle      = "от Rival960",
        TabHome             = "Главная",
        TabCombat           = "Бой",
        TabMovement         = "Движение",
        TabTools            = "Инструменты",
        CreditsTitle        = "Авторы",
        CreditsContent      = "Создано Rival960 с помощью ИИ\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.1.0 — Боевое Обновление",
        ReleaseNotesTitle   = "v1.1.0 — Примечания к версии",
        ReleaseNotesContent = "Новое: Бесконечные патроны, Заморозить патроны, Аура убийства, улучшения Авто Притяжение, исправление патронов аимбота.\nНашли баг или хотите предложить функцию? Создайте issue на GitHub (Rival99900/Roblox-Scripts) или напишите на ScriptBlox.",
        Aimbot              = "Аимбот",
        AutoBring           = "Авто Притяжение",
        BringRadius         = "Радиус притяжения (ст.)",
        BringInterval       = "Интервал притяжения (с)",
        MaxZombieDist       = "Макс дистанция зомби",
        InfiniteAmmo        = "Бесконечные патроны",
        FreezeAmmo          = "Заморозить патроны",
        KillAura            = "Аура убийства",
        KillAuraRange       = "Дальность ауры",
        KillAuraInterval    = "Интервал ауры (с)",
        FlyToggle           = "Полёт",
        FlySpeed            = "Скорость полёта",
        NoClip              = "NoClip",
        WalkSpeed           = "Скорость ходьбы",
        InfJump             = "Бесконечный прыжок",
        AntiAFK             = "Анти-АФК",
        Fullbright          = "Полная яркость",
        LanguageSelect      = "Язык",
        LangNote            = "Смена языка требует повторного запуска",
    },
    IT = {
        WindowTitle         = "Tower of Zombies Hub",
        WindowSubtitle      = "di Rival960",
        TabHome             = "Home",
        TabCombat           = "Combattimento",
        TabMovement         = "Movimento",
        TabTools            = "Strumenti",
        CreditsTitle        = "Crediti",
        CreditsContent      = "Creato da Rival960 con l'aiuto dell'IA\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.1.0 — Aggiornamento Combattimento",
        ReleaseNotesTitle   = "v1.1.0 — Note di Versione",
        ReleaseNotesContent = "Novità: Munizioni Infinite, Blocca Munizioni, Aura Letale, miglioramenti Auto Attira, fix munizioni Aimbot.\nHai trovato un bug o vuoi richiedere una funzione? Apri un'issue su GitHub (Rival99900/Roblox-Scripts) o scrivi su ScriptBlox.",
        Aimbot              = "Aimbot",
        AutoBring           = "Auto Attira",
        BringRadius         = "Raggio di Attrazione (studs)",
        BringInterval       = "Intervallo di Attrazione (s)",
        MaxZombieDist       = "Distanza Max Zombie",
        InfiniteAmmo        = "Munizioni Infinite",
        FreezeAmmo          = "Blocca Munizioni",
        KillAura            = "Aura Letale",
        KillAuraRange       = "Raggio dell'Aura",
        KillAuraInterval    = "Intervallo dell'Aura (s)",
        FlyToggle           = "Volo",
        FlySpeed            = "Velocità di Volo",
        NoClip              = "NoClip",
        WalkSpeed           = "Velocità di Camminata",
        InfJump             = "Salto Infinito",
        AntiAFK             = "Anti-AFK",
        Fullbright          = "Piena Luminosità",
        LanguageSelect      = "Lingua",
        LangNote            = "Il cambio lingua richiede una ri-esecuzione",
    },
    NL = {
        WindowTitle         = "Tower of Zombies Hub",
        WindowSubtitle      = "door Rival960",
        TabHome             = "Start",
        TabCombat           = "Gevecht",
        TabMovement         = "Beweging",
        TabTools            = "Tools & Visuals",
        CreditsTitle        = "Credits",
        CreditsContent      = "Gemaakt door Rival960 met AI-hulp\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.1.0 — Gevechtsupdate",
        ReleaseNotesTitle   = "v1.1.0 — Versienotities",
        ReleaseNotesContent = "Nieuwe functies: Oneindige Munitie, Bevriezing Munitie, Doodsaura, verbeteringen Auto Aantrekken, Aimbot munitiefix.\nBug gevonden of wil je een functie aanvragen? Open een issue op GitHub (Rival99900/Roblox-Scripts) of post op ScriptBlox.",
        Aimbot              = "Aimbot",
        AutoBring           = "Auto Aantrekken",
        BringRadius         = "Aantrekkingsradius (studs)",
        BringInterval       = "Aantrekkingsinterval (s)",
        MaxZombieDist       = "Max Zombie Afstand",
        InfiniteAmmo        = "Oneindige Munitie",
        FreezeAmmo          = "Bevriezing Munitie",
        KillAura            = "Doodsaura",
        KillAuraRange       = "Aura-bereik",
        KillAuraInterval    = "Aura-interval (s)",
        FlyToggle           = "Vliegen",
        FlySpeed            = "Vliegsnelheid",
        NoClip              = "NoClip",
        WalkSpeed           = "Loopsnelheid",
        InfJump             = "Oneindig Springen",
        AntiAFK             = "Anti-AFK",
        Fullbright          = "Maximale Helderheid",
        LanguageSelect      = "Taal",
        LangNote            = "Taalwijziging vereist heruitvoering",
    },
    PL = {
        WindowTitle         = "Tower of Zombies Hub",
        WindowSubtitle      = "przez Rival960",
        TabHome             = "Strona główna",
        TabCombat           = "Walka",
        TabMovement         = "Ruch",
        TabTools            = "Narzędzia",
        CreditsTitle        = "Kredyty",
        CreditsContent      = "Stworzone przez Rival960 z pomocą AI\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.1.0 — Aktualizacja Walki",
        ReleaseNotesTitle   = "v1.1.0 — Informacje o Wersji",
        ReleaseNotesContent = "Nowe funkcje: Nieskończona Amunicja, Zamroź Amunicję, Aura Śmierci, ulepszenia Auto Przyciąganie, poprawka amunicji Aimbot.\nZnalazłeś błąd lub chcesz zgłosić funkcję? Otwórz issue na GitHub (Rival99900/Roblox-Scripts) lub napisz na ScriptBlox.",
        Aimbot              = "Aimbot",
        AutoBring           = "Auto Przyciąganie",
        BringRadius         = "Promień przyciągania (studs)",
        BringInterval       = "Interwał przyciągania (s)",
        MaxZombieDist       = "Maks. dystans zombie",
        InfiniteAmmo        = "Nieskończona Amunicja",
        FreezeAmmo          = "Zamroź Amunicję",
        KillAura            = "Aura Śmierci",
        KillAuraRange       = "Zasięg Aury",
        KillAuraInterval    = "Interwał Aury (s)",
        FlyToggle           = "Latanie",
        FlySpeed            = "Prędkość lotu",
        NoClip              = "NoClip",
        WalkSpeed           = "Prędkość chodu",
        InfJump             = "Nieskończony Skok",
        AntiAFK             = "Anti-AFK",
        Fullbright          = "Pełna jasność",
        LanguageSelect      = "Język",
        LangNote            = "Zmiana języka wymaga ponownego uruchomienia",
    },
    ZH = {
        WindowTitle         = "行尸走肉枢纽",
        WindowSubtitle      = "由 Rival960",
        TabHome             = "主页",
        TabCombat           = "战斗",
        TabMovement         = "移动",
        TabTools            = "工具与视觉",
        CreditsTitle        = "致谢",
        CreditsContent      = "由 Rival960 借助 AI 创建\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.1.0 — 战斗更新",
        ReleaseNotesTitle   = "v1.1.0 — 版本说明",
        ReleaseNotesContent = "新功能：无限弹药、冻结弹药、杀戮光环、自动吸引改进、瞄准弹药修复。\n发现漏洞或想申请功能？请在 GitHub (Rival99900/Roblox-Scripts) 提交 issue 或在 ScriptBlox 发帖。",
        Aimbot              = "自动瞄准",
        AutoBring           = "自动吸引",
        BringRadius         = "吸引半径 (格)",
        BringInterval       = "吸引间隔 (秒)",
        MaxZombieDist       = "最大僵尸距离",
        InfiniteAmmo        = "无限弹药",
        FreezeAmmo          = "冻结弹药",
        KillAura            = "杀戮光环",
        KillAuraRange       = "光环范围",
        KillAuraInterval    = "光环间隔 (秒)",
        FlyToggle           = "飞行",
        FlySpeed            = "飞行速度",
        NoClip              = "穿墙",
        WalkSpeed           = "行走速度",
        InfJump             = "无限跳跃",
        AntiAFK             = "防离线",
        Fullbright          = "全亮",
        LanguageSelect      = "语言",
        LangNote            = "语言更改需要重新执行",
    },
    JA = {
        WindowTitle         = "ゾンビタワーハブ",
        WindowSubtitle      = "Rival960 制作",
        TabHome             = "ホーム",
        TabCombat           = "戦闘",
        TabMovement         = "移動",
        TabTools            = "ツール",
        CreditsTitle        = "クレジット",
        CreditsContent      = "Rival960 と AI の協力で作成\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.1.0 — 戦闘アップデート",
        ReleaseNotesTitle   = "v1.1.0 — リリースノート",
        ReleaseNotesContent = "新機能：無限弾薬、弾薬固定、キルオーラ、自動引き寄せ改善、エイムボット弾薬修正。\nバグ発見や機能リクエストはGitHub (Rival99900/Roblox-Scripts) のissueまたはScriptBloxに投稿してください。",
        Aimbot              = "エイムボット",
        AutoBring           = "自動引き寄せ",
        BringRadius         = "引き寄せ半径 (スタッド)",
        BringInterval       = "引き寄せ間隔 (秒)",
        MaxZombieDist       = "最大ゾンビ距離",
        InfiniteAmmo        = "無限弾薬",
        FreezeAmmo          = "弾薬固定",
        KillAura            = "キルオーラ",
        KillAuraRange       = "オーラ範囲",
        KillAuraInterval    = "オーラ間隔 (秒)",
        FlyToggle           = "フライ",
        FlySpeed            = "飛行速度",
        NoClip              = "ノークリップ",
        WalkSpeed           = "歩行速度",
        InfJump             = "無限ジャンプ",
        AntiAFK             = "アンチAFK",
        Fullbright          = "フルブライト",
        LanguageSelect      = "言語",
        LangNote            = "言語変更は再実行が必要です",
    },
    TR = {
        WindowTitle         = "Tower of Zombies Hub",
        WindowSubtitle      = "Rival960 tarafından",
        TabHome             = "Ana Sayfa",
        TabCombat           = "Savaş",
        TabMovement         = "Hareket",
        TabTools            = "Araçlar",
        CreditsTitle        = "Krediler",
        CreditsContent      = "Rival960 tarafından AI yardımıyla yapılmıştır\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.1.0 — Savaş Güncellemesi",
        ReleaseNotesTitle   = "v1.1.0 — Sürüm Notları",
        ReleaseNotesContent = "Yeni özellikler: Sonsuz Mermi, Mermiyi Dondur, Ölüm Aurası, Otomatik Çekme iyileştirmeleri, Aimbot mermi düzeltmesi.\nBir hata buldunuz veya özellik talep etmek mi istiyorsunuz? GitHub'da (Rival99900/Roblox-Scripts) issue açın veya ScriptBlox'ta paylaşın.",
        Aimbot              = "Aimbot",
        AutoBring           = "Otomatik Çekme",
        BringRadius         = "Çekme Yarıçapı (studs)",
        BringInterval       = "Çekme Aralığı (s)",
        MaxZombieDist       = "Maks Zombi Mesafesi",
        InfiniteAmmo        = "Sonsuz Mermi",
        FreezeAmmo          = "Mermiyi Dondur",
        KillAura            = "Ölüm Aurası",
        KillAuraRange       = "Aura Menzili",
        KillAuraInterval    = "Aura Aralığı (s)",
        FlyToggle           = "Uçuş",
        FlySpeed            = "Uçuş Hızı",
        NoClip              = "NoClip",
        WalkSpeed           = "Yürüyüş Hızı",
        InfJump             = "Sonsuz Zıplama",
        AntiAFK             = "Anti-AFK",
        Fullbright          = "Tam Parlaklık",
        LanguageSelect      = "Dil",
        LangNote            = "Dil değişikliği yeniden başlatma gerektirir",
    },
    KO = {
        WindowTitle         = "좀비 타워 허브",
        WindowSubtitle      = "Rival960 제작",
        TabHome             = "홈",
        TabCombat           = "전투",
        TabMovement         = "이동",
        TabTools            = "도구",
        CreditsTitle        = "크레딧",
        CreditsContent      = "Rival960이 AI의 도움으로 제작\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.1.0 — 전투 업데이트",
        ReleaseNotesTitle   = "v1.1.0 — 릴리즈 노트",
        ReleaseNotesContent = "새 기능: 무한 탄약, 탄약 고정, 킬 오라, 자동 끌어오기 개선, 에임봇 탄약 수정.\n버그를 찾거나 기능을 요청하고 싶다면? GitHub (Rival99900/Roblox-Scripts)에 이슈를 열거나 ScriptBlox에 게시하세요.",
        Aimbot              = "에임봇",
        AutoBring           = "자동 끌어오기",
        BringRadius         = "끌어오기 반경 (스터드)",
        BringInterval       = "끌어오기 간격 (초)",
        MaxZombieDist       = "최대 좀비 거리",
        InfiniteAmmo        = "무한 탄약",
        FreezeAmmo          = "탄약 고정",
        KillAura            = "킬 오라",
        KillAuraRange       = "오라 범위",
        KillAuraInterval    = "오라 간격 (초)",
        FlyToggle           = "비행",
        FlySpeed            = "비행 속도",
        NoClip              = "노클립",
        WalkSpeed           = "걷기 속도",
        InfJump             = "무한 점프",
        AntiAFK             = "Anti-AFK",
        Fullbright          = "전체 밝기",
        LanguageSelect      = "언어",
        LangNote            = "언어 변경은 재실행이 필요합니다",
    },
    AR = {
        WindowTitle         = "Tower of Zombies Hub",
        WindowSubtitle      = "بواسطة Rival960",
        TabHome             = "الرئيسية",
        TabCombat           = "القتال",
        TabMovement         = "الحركة",
        TabTools            = "الأدوات",
        CreditsTitle        = "الاعتمادات",
        CreditsContent      = "تم إنشاؤه بواسطة Rival960 بمساعدة الذكاء الاصطناعي\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.1.0 — تحديث القتال",
        ReleaseNotesTitle   = "v1.1.0 — ملاحظات الإصدار",
        ReleaseNotesContent = "ميزات جديدة: ذخيرة لا نهائية، تجميد الذخيرة، هالة القتل، تحسينات الجذب التلقائي، إصلاح ذخيرة الأيمبوت.\nوجدت خطأ أو تريد طلب ميزة؟ افتح issue على GitHub (Rival99900/Roblox-Scripts) أو انشر على ScriptBlox.",
        Aimbot              = "أيمبوت",
        AutoBring           = "جذب تلقائي",
        BringRadius         = "نطاق الجذب (وحدة)",
        BringInterval       = "فترة الجذب (ث)",
        MaxZombieDist       = "أقصى مسافة للزومبي",
        InfiniteAmmo        = "ذخيرة لا نهائية",
        FreezeAmmo          = "تجميد الذخيرة",
        KillAura            = "هالة القتل",
        KillAuraRange       = "نطاق الهالة",
        KillAuraInterval    = "فترة الهالة (ث)",
        FlyToggle           = "طيران",
        FlySpeed            = "سرعة الطيران",
        NoClip              = "اختراق الجدران",
        WalkSpeed           = "سرعة المشي",
        InfJump             = "قفز لانهائي",
        AntiAFK             = "مانع الخمول",
        Fullbright          = "سطوع كامل",
        LanguageSelect      = "اللغة",
        LangNote            = "تغيير اللغة يتطلب إعادة التشغيل",
    },
    VI = {
        WindowTitle         = "Tower of Zombies Hub",
        WindowSubtitle      = "bởi Rival960",
        TabHome             = "Trang Chủ",
        TabCombat           = "Chiến Đấu",
        TabMovement         = "Di Chuyển",
        TabTools            = "Công Cụ",
        CreditsTitle        = "Tín Dụng",
        CreditsContent      = "Tạo bởi Rival960 với sự trợ giúp của AI\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.1.0 — Cập Nhật Chiến Đấu",
        ReleaseNotesTitle   = "v1.1.0 — Ghi Chú Phiên Bản",
        ReleaseNotesContent = "Tính năng mới: Đạn Vô Hạn, Đóng Băng Đạn, Aura Hủy Diệt, cải tiến Tự Động Kéo, sửa lỗi đạn Aimbot.\nTìm thấy lỗi hoặc muốn yêu cầu tính năng? Mở issue trên GitHub (Rival99900/Roblox-Scripts) hoặc đăng trên ScriptBlox.",
        Aimbot              = "Aimbot",
        AutoBring           = "Tự Động Kéo",
        BringRadius         = "Bán Kính Kéo (studs)",
        BringInterval       = "Khoảng Thời Gian Kéo (s)",
        MaxZombieDist       = "Khoảng Cách Zombie Tối Đa",
        InfiniteAmmo        = "Đạn Vô Hạn",
        FreezeAmmo          = "Đóng Băng Đạn",
        KillAura            = "Aura Hủy Diệt",
        KillAuraRange       = "Phạm Vi Aura",
        KillAuraInterval    = "Khoảng Aura (s)",
        FlyToggle           = "Bay",
        FlySpeed            = "Tốc Độ Bay",
        NoClip              = "NoClip",
        WalkSpeed           = "Tốc Độ Đi",
        InfJump             = "Nhảy Vô Hạn",
        AntiAFK             = "Chống AFK",
        Fullbright          = "Độ Sáng Tối Đa",
        LanguageSelect      = "Ngôn Ngữ",
        LangNote            = "Thay đổi ngôn ngữ cần khởi động lại",
    },
    SV = {
        WindowTitle         = "Tower of Zombies Hub",
        WindowSubtitle      = "av Rival960",
        TabHome             = "Hem",
        TabCombat           = "Strid",
        TabMovement         = "Rörelse",
        TabTools            = "Verktyg",
        CreditsTitle        = "Erkännanden",
        CreditsContent      = "Skapad av Rival960 med hjälp av AI\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.1.0 — Stridsuppdatering",
        ReleaseNotesTitle   = "v1.1.0 — Versionsanteckningar",
        ReleaseNotesContent = "Nya funktioner: Oändlig Ammunition, Frys Ammunition, Dödsaura, förbättringar Auto Hämta, Aimbot ammunition fix.\nHittade du en bugg eller vill begära en funktion? Öppna ett issue på GitHub (Rival99900/Roblox-Scripts) eller posta på ScriptBlox.",
        Aimbot              = "Aimbot",
        AutoBring           = "Auto Hämta",
        BringRadius         = "Hämtningsradie (studs)",
        BringInterval       = "Hämtningsintervall (s)",
        MaxZombieDist       = "Max Zombieavstånd",
        InfiniteAmmo        = "Oändlig Ammunition",
        FreezeAmmo          = "Frys Ammunition",
        KillAura            = "Dödsaura",
        KillAuraRange       = "Aura-räckvidd",
        KillAuraInterval    = "Aura-intervall (s)",
        FlyToggle           = "Flyg",
        FlySpeed            = "Flyghastighet",
        NoClip              = "NoClip",
        WalkSpeed           = "Gånghastighet",
        InfJump             = "Oändligt Hopp",
        AntiAFK             = "Anti-AFK",
        Fullbright          = "Full Ljusstyrka",
        LanguageSelect      = "Språk",
        LangNote            = "Språkändring kräver omstartning",
    },
    EL = {
        WindowTitle         = "Tower of Zombies Hub",
        WindowSubtitle      = "από Rival960",
        TabHome             = "Αρχική",
        TabCombat           = "Μάχη",
        TabMovement         = "Κίνηση",
        TabTools            = "Εργαλεία",
        CreditsTitle        = "Εύσημα",
        CreditsContent      = "Δημιουργήθηκε από Rival960 με βοήθεια AI\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.1.0 — Ενημέρωση Μάχης",
        ReleaseNotesTitle   = "v1.1.0 — Σημειώσεις Έκδοσης",
        ReleaseNotesContent = "Νέα χαρακτηριστικά: Άπειρα Πυρομαχικά, Πάγωμα Πυρομαχικών, Θανατηφόρα Αύρα, βελτιώσεις Αυτόματη Έλξη, διόρθωση πυρομαχικών Aimbot.\nΒρήκατε σφάλμα ή θέλετε να ζητήσετε λειτουργία; Ανοίξτε ένα issue στο GitHub (Rival99900/Roblox-Scripts) ή δημοσιεύστε στο ScriptBlox.",
        Aimbot              = "Aimbot",
        AutoBring           = "Αυτόματη Έλξη",
        BringRadius         = "Ακτίνα Έλξης (studs)",
        BringInterval       = "Διάστημα Έλξης (s)",
        MaxZombieDist       = "Μέγ. Απόσταση Ζόμπι",
        InfiniteAmmo        = "Άπειρα Πυρομαχικά",
        FreezeAmmo          = "Πάγωμα Πυρομαχικών",
        KillAura            = "Θανατηφόρα Αύρα",
        KillAuraRange       = "Εμβέλεια Αύρας",
        KillAuraInterval    = "Διάστημα Αύρας (s)",
        FlyToggle           = "Πτήση",
        FlySpeed            = "Ταχύτητα Πτήσης",
        NoClip              = "NoClip",
        WalkSpeed           = "Ταχύτητα Βαδίσματος",
        InfJump             = "Άπειρο Άλμα",
        AntiAFK             = "Anti-AFK",
        Fullbright          = "Πλήρης Φωτεινότητα",
        LanguageSelect      = "Γλώσσα",
        LangNote            = "Η αλλαγή γλώσσας απαιτεί επανεκτέλεση",
    },
    RO = {
        WindowTitle         = "Tower of Zombies Hub",
        WindowSubtitle      = "de Rival960",
        TabHome             = "Acasă",
        TabCombat           = "Luptă",
        TabMovement         = "Mișcare",
        TabTools            = "Instrumente",
        CreditsTitle        = "Credite",
        CreditsContent      = "Creat de Rival960 cu ajutorul AI\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.1.0 — Actualizare Luptă",
        ReleaseNotesTitle   = "v1.1.0 — Note de Lansare",
        ReleaseNotesContent = "Funcții noi: Muniție Infinită, Îngheță Muniție, Aura Morții, îmbunătățiri Auto Atragere, corectare muniție Aimbot.\nAți găsit un bug sau doriți să solicitați o funcție? Deschideți un issue pe GitHub (Rival99900/Roblox-Scripts) sau postați pe ScriptBlox.",
        Aimbot              = "Aimbot",
        AutoBring           = "Auto Atragere",
        BringRadius         = "Raza de Atragere (studs)",
        BringInterval       = "Interval Atragere (s)",
        MaxZombieDist       = "Dist. Maximă Zombie",
        InfiniteAmmo        = "Muniție Infinită",
        FreezeAmmo          = "Îngheță Muniție",
        KillAura            = "Aura Morții",
        KillAuraRange       = "Raza Aurei",
        KillAuraInterval    = "Interval Aură (s)",
        FlyToggle           = "Zbor",
        FlySpeed            = "Viteză Zbor",
        NoClip              = "NoClip",
        WalkSpeed           = "Viteză Mers",
        InfJump             = "Salt Infinit",
        AntiAFK             = "Anti-AFK",
        Fullbright          = "Luminozitate Maximă",
        LanguageSelect      = "Limbă",
        LangNote            = "Schimbarea limbii necesită re-executare",
    },
    UK = {
        WindowTitle         = "Tower of Zombies Hub",
        WindowSubtitle      = "від Rival960",
        TabHome             = "Головна",
        TabCombat           = "Бій",
        TabMovement         = "Рух",
        TabTools            = "Інструменти",
        CreditsTitle        = "Автори",
        CreditsContent      = "Створено Rival960 за допомогою AI\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.1.0 — Бойове Оновлення",
        ReleaseNotesTitle   = "v1.1.0 — Примітки до версії",
        ReleaseNotesContent = "Нове: Нескінченні патрони, Заморозити патрони, Аура вбивства, покращення Авто Притягання, виправлення патронів аімбота.\nЗнайшли баг або хочете запропонувати функцію? Створіть issue на GitHub (Rival99900/Roblox-Scripts) або напишіть на ScriptBlox.",
        Aimbot              = "Аімбот",
        AutoBring           = "Авто Притягання",
        BringRadius         = "Радіус притягання (ст.)",
        BringInterval       = "Інтервал притягання (с)",
        MaxZombieDist       = "Макс дистанція зомбі",
        InfiniteAmmo        = "Нескінченні патрони",
        FreezeAmmo          = "Заморозити патрони",
        KillAura            = "Аура вбивства",
        KillAuraRange       = "Дальність аури",
        KillAuraInterval    = "Інтервал аури (с)",
        FlyToggle           = "Політ",
        FlySpeed            = "Швидкість польоту",
        NoClip              = "NoClip",
        WalkSpeed           = "Швидкість ходьби",
        InfJump             = "Нескінченний Стрибок",
        AntiAFK             = "Анти-АФК",
        Fullbright          = "Повна яскравість",
        LanguageSelect      = "Мова",
        LangNote            = "Зміна мови потребує перезапуску",
    },
    CS = {
        WindowTitle         = "Tower of Zombies Hub",
        WindowSubtitle      = "od Rival960",
        TabHome             = "Domů",
        TabCombat           = "Boj",
        TabMovement         = "Pohyb",
        TabTools            = "Nástroje",
        CreditsTitle        = "Poděkování",
        CreditsContent      = "Vytvořeno Rival960 s pomocí AI\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.1.0 — Bojová Aktualizace",
        ReleaseNotesTitle   = "v1.1.0 — Poznámky k Vydání",
        ReleaseNotesContent = "Nové funkce: Nekonečná Munice, Zmrazit Munici, Smrtící Aura, vylepšení Auto Přitáhnout, oprava munice Aimbot.\nNašli jste chybu nebo chcete požádat o funkci? Otevřete issue na GitHub (Rival99900/Roblox-Scripts) nebo přidejte příspěvek na ScriptBlox.",
        Aimbot              = "Aimbot",
        AutoBring           = "Auto Přitáhnout",
        BringRadius         = "Poloměr přitáhnutí (studs)",
        BringInterval       = "Interval přitáhnutí (s)",
        MaxZombieDist       = "Max vzdálenost zombie",
        InfiniteAmmo        = "Nekonečná Munice",
        FreezeAmmo          = "Zmrazit Munici",
        KillAura            = "Smrtící Aura",
        KillAuraRange       = "Dosah Aury",
        KillAuraInterval    = "Interval Aury (s)",
        FlyToggle           = "Létání",
        FlySpeed            = "Rychlost letu",
        NoClip              = "NoClip",
        WalkSpeed           = "Rychlost chůze",
        InfJump             = "Nekonečný Skok",
        AntiAFK             = "Anti-AFK",
        Fullbright          = "Plný jas",
        LanguageSelect      = "Jazyk",
        LangNote            = "Změna jazyka vyžaduje restartování",
    },
    DA = {
        WindowTitle         = "Tower of Zombies Hub",
        WindowSubtitle      = "af Rival960",
        TabHome             = "Hjem",
        TabCombat           = "Kamp",
        TabMovement         = "Bevægelse",
        TabTools            = "Værktøjer",
        CreditsTitle        = "Anerkendelser",
        CreditsContent      = "Oprettet af Rival960 med hjælp fra AI\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.1.0 — Kampsopdatering",
        ReleaseNotesTitle   = "v1.1.0 — Udgivelsesnoter",
        ReleaseNotesContent = "Nye funktioner: Uendelig Ammunition, Frys Ammunition, Dødsuddunstning, forbedringer Auto Hent, Aimbot ammunition fix.\nFandt du en fejl eller vil du anmode om en funktion? Åbn et issue på GitHub (Rival99900/Roblox-Scripts) eller post på ScriptBlox.",
        Aimbot              = "Aimbot",
        AutoBring           = "Auto Hent",
        BringRadius         = "Hentningsradius (studs)",
        BringInterval       = "Hentningsinterval (s)",
        MaxZombieDist       = "Maks Zombie Afstand",
        InfiniteAmmo        = "Uendelig Ammunition",
        FreezeAmmo          = "Frys Ammunition",
        KillAura            = "Dødsuddunstning",
        KillAuraRange       = "Aura-rækkevidde",
        KillAuraInterval    = "Aura-interval (s)",
        FlyToggle           = "Fly",
        FlySpeed            = "Flyvehastighed",
        NoClip              = "NoClip",
        WalkSpeed           = "Gåhastighed",
        InfJump             = "Uendeligt Hop",
        AntiAFK             = "Anti-AFK",
        Fullbright          = "Fuld Lysstyrke",
        LanguageSelect      = "Sprog",
        LangNote            = "Sprogændring kræver genstart",
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
    Aimbot           = false,
    AutoBring        = false,
    BringRadius      = 3,
    BringInterval    = 0.3,
    MaxZombieDist    = 300,
    InfiniteAmmo     = false,
    FreezeAmmo       = false,
    KillAura         = false,
    KillAuraRange    = 200,
    KillAuraInterval = 0.1,
    Fly              = false,
    FlySpeed         = 60,
    NoClip           = false,
    WalkSpeed        = 16,
    InfJump          = false,
    AntiAFK          = false,
    Fullbright       = false,
}

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
-- Rayfield load (keyless)
-- ================================================================
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)
if not success or not Rayfield then return end

local Window = Rayfield:CreateWindow({
    Name             = T("WindowTitle"),
    LoadingTitle     = T("WindowTitle"),
    LoadingSubtitle  = T("WindowSubtitle"),
    ConfigurationSaving = { Enabled = false },
    Discord          = { Enabled = false },
    KeySystem        = false,
})

-- ================================================================
-- Shared combat helpers
-- ================================================================

-- Find closest zombie target within maxDist (math only, no raycast)
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

-- Fire remote — math only, no workspace:Raycast, penetrates all walls
-- Sets ammo to prevent reload interrupting fire; fires both Fire and Fire_2 remotes
local function fireAtTarget(targetPart)
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    local weaponName = tool.Name
    local exitPart   = tool:FindFirstChild("Exit")
    if not exitPart then return end

    -- Set ammo to prevent reload interrupting fire
    local info = tool:FindFirstChild("Info")
    if info then
        local clip    = info:FindFirstChild("Clip")
        local reserve = info:FindFirstChild("Reserve")
        if clip    then clip.Value    = 99999 end
        if reserve then reserve.Value = 99999 end
    end

    local rayOrigin = exitPart.WorldPosition
    local hitPos    = targetPart.Position
    local normalVec = (rayOrigin - hitPos).Unit  -- from target back to barrel

    pcall(function()
        game:GetService("ReplicatedStorage").Events.Actions.Fire:FireServer(
            weaponName,
            {{ targetPart, hitPos, normalVec }},
            {{ weaponName, rayOrigin, hitPos, hitPos, true, targetPart, false, false, "Default", exitPart }}
        )
    end)
    pcall(function()
        game:GetService("ReplicatedStorage").Events.Actions.Fire_2:FireServer(
            weaponName,
            {{ targetPart, hitPos, normalVec }},
            {{ weaponName, rayOrigin, hitPos, hitPos, true, targetPart, false, false, "Default", exitPart }}
        )
    end)

    -- Fix A: reset stuck debounce attributes after firing
    pcall(function()
        local tool2 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool2 then
            tool2:SetAttribute("Firing", false)
            tool2:SetAttribute("ContinuousFireActive", false)
            tool2:SetAttribute("ContinuousFireDirection", Vector3.zero)
        end
    end)
end

-- ================================================================
-- TABS
-- ================================================================

-- ───── Tab 1: Home ─────
local HomeTab = Window:CreateTab(T("TabHome"), 4483362458)
HomeTab:CreateParagraph({
    Title   = T("CreditsTitle"),
    Content = T("CreditsContent"),
})
HomeTab:CreateParagraph({
    Title   = T("ReleaseNotesTitle"),
    Content = T("ReleaseNotesContent"),
})

-- ───── Tab 2: Combat ─────
local CombatTab = Window:CreateTab(T("TabCombat"), 4483362458)

CombatTab:CreateToggle({
    Name         = T("Aimbot"),
    CurrentValue = false,
    Callback     = function(val) Settings.Aimbot = val end,
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
        -- When turned off, restore WalkSpeed of all zombies
        if not val then
            pcall(function()
                local zombieFolder = workspace:FindFirstChild("ActiveZombies")
                if not zombieFolder then return end
                for _, zombie in ipairs(zombieFolder:GetChildren()) do
                    local hum = zombie:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.WalkSpeed = 16  -- default Roblox walk speed
                    end
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
    Callback     = function(val) Settings.InfiniteAmmo = val end,
})

CombatTab:CreateToggle({
    Name         = T("FreezeAmmo"),
    CurrentValue = false,
    Callback     = function(val)
        Settings.FreezeAmmo = val
        if not val then
            -- Clear cached ammo so it re-samples on next enable
            Settings._frozenClip    = nil
            Settings._frozenReserve = nil
        end
    end,
})

CombatTab:CreateToggle({
    Name         = T("KillAura"),
    CurrentValue = false,
    Callback     = function(val) Settings.KillAura = val end,
})

CombatTab:CreateSlider({
    Name         = T("KillAuraRange"),
    Range        = {50, 500},
    Increment    = 10,
    CurrentValue = 200,
    Callback     = function(val) Settings.KillAuraRange = val end,
})

CombatTab:CreateSlider({
    Name         = T("KillAuraInterval"),
    Range        = {0.05, 0.5},
    Increment    = 0.05,
    CurrentValue = 0.1,
    Callback     = function(val) Settings.KillAuraInterval = val end,
})

-- ───── Tab 3: Movement ─────
local MovementTab = Window:CreateTab(T("TabMovement"), 4483362458)

-- ================================================================
-- Fly system (confirmed working — do not touch)
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

    local bv = Instance.new("BodyVelocity")
    bv.Name      = "_SWAT_FLY_BV"
    bv.MaxForce  = Vector3.new(9e9, 9e9, 9e9)
    bv.Velocity  = Vector3.zero
    bv.Parent    = hrp

    local bg = Instance.new("BodyGyro")
    bg.Name      = "_SWAT_FLY_BG"
    bg.P         = 9e4
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.CFrame    = hrp.CFrame
    bg.Parent    = hrp

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

    if _flyUpBtn   then _flyUpBtn.Visible   = true  end
    if _flyDownBtn then _flyDownBtn.Visible = true   end

    task.spawn(function()
        while FLYING do
            task.wait()
            local camCF    = workspace.CurrentCamera.CFrame
            local rawLook  = camCF.LookVector
            local rawRight = camCF.RightVector
            local spd      = Settings.FlySpeed

            -- Flatten to horizontal plane so vertical camera tilt does not affect direction
            local flatLook  = Vector3.new(rawLook.X,  0, rawLook.Z)
            local flatRight = Vector3.new(rawRight.X, 0, rawRight.Z)
            if flatLook.Magnitude  > 0 then flatLook  = flatLook.Unit  end
            if flatRight.Magnitude > 0 then flatRight = flatRight.Unit end

            -- PC: WASD via CTRL table
            local pcVel = flatLook  * CTRL.F   -- W: positive
                        + flatLook  * CTRL.B   -- S: negative
                        + flatRight * CTRL.R   -- D: positive
                        + flatRight * CTRL.L   -- A: negative

            -- Mobile: MoveDirection is already world-space horizontal, use directly
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

-- Mobile ▲▼ buttons: 60×60, bottom-center, hidden until fly is on
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

-- NoClip
local noClipConn
MovementTab:CreateToggle({
    Name         = T("NoClip"),
    CurrentValue = false,
    Callback     = function(val)
        Settings.NoClip = val
        if val then
            if not noClipConn then
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

-- WalkSpeed
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

-- Infinite Jump
MovementTab:CreateToggle({
    Name         = T("InfJump"),
    CurrentValue = false,
    Callback     = function(val) Settings.InfJump = val end,
})

-- ───── Tab 4: Tools & Visuals ─────
local ToolsTab = Window:CreateTab(T("TabTools"), 4483362458)

-- Fullbright
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

-- Anti-AFK
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
                        pcall(function()
                            local hrp = getHRP()
                            if hrp then
                                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(0.01), 0)
                            end
                        end)
                        task.wait(60)
                    end
                    afkThread = nil
                end)
            end
        end
    end,
})

-- Language selector
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
-- Main Loops
-- ================================================================

-- Aimbot: RenderStepped camera-lock only (Fix B: single persistent connection, no rapid fire)
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
    end)
end
connectAimbot()
-- Reconnect on respawn to avoid stale upvalues
LocalPlayer.CharacterAdded:Connect(function()
    connectAimbot()
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if not Settings.InfJump then return end
    pcall(function()
        local hum = getHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end)

-- Infinite Ammo: Heartbeat loop — sets all ammo values to 99999 every 0.1s
local infiniteAmmoTimer = 0
RunService.Heartbeat:Connect(function(dt)
    if not Settings.InfiniteAmmo then
        infiniteAmmoTimer = 0
        return
    end
    infiniteAmmoTimer = infiniteAmmoTimer + dt
    if infiniteAmmoTimer < 0.1 then return end
    infiniteAmmoTimer = 0
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local tool = char:FindFirstChildOfClass("Tool")
        if not tool then return end
        -- Direct Info/Clip and Info/Reserve
        local info = tool:FindFirstChild("Info")
        if info then
            local clip    = info:FindFirstChild("Clip")
            local reserve = info:FindFirstChild("Reserve")
            if clip    then clip.Value    = 99999 end
            if reserve then reserve.Value = 99999 end
        end
        -- Recursive search for common ammo value names
        for _, v in ipairs(tool:GetDescendants()) do
            if v:IsA("IntValue") or v:IsA("NumberValue") then
                local n = v.Name:lower()
                if n == "clip" or n == "reserve" or n == "ammo"
                    or n == "magammo" or n == "currentammo" or n == "storedammo" then
                    v.Value = 99999
                end
            end
        end
    end)
end)

-- Freeze Ammo: Heartbeat loop — caches ammo on first detection, restores every tick
local freezeAmmoTimer = 0
RunService.Heartbeat:Connect(function(dt)
    if not Settings.FreezeAmmo then
        freezeAmmoTimer = 0
        return
    end
    freezeAmmoTimer = freezeAmmoTimer + dt
    if freezeAmmoTimer < 0.1 then return end
    freezeAmmoTimer = 0
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local tool = char:FindFirstChildOfClass("Tool")
        if not tool then return end
        local info = tool:FindFirstChild("Info")
        if not info then return end
        local clip    = info:FindFirstChild("Clip")
        local reserve = info:FindFirstChild("Reserve")
        -- Cache on first tick
        if clip    and Settings._frozenClip    == nil then Settings._frozenClip    = clip.Value    end
        if reserve and Settings._frozenReserve == nil then Settings._frozenReserve = reserve.Value end
        -- Restore cached values
        if clip    and Settings._frozenClip    ~= nil then clip.Value    = Settings._frozenClip    end
        if reserve and Settings._frozenReserve ~= nil then reserve.Value = Settings._frozenReserve end
    end)
end)

-- Kill Aura: Heartbeat loop — fires at all living zombies in range every KillAuraInterval
local killAuraTimer = 0
RunService.Heartbeat:Connect(function(dt)
    if not Settings.KillAura then
        killAuraTimer = 0
        return
    end
    killAuraTimer = killAuraTimer + dt
    if killAuraTimer < Settings.KillAuraInterval then return end
    killAuraTimer = 0
    task.spawn(function()
        pcall(function()
            local hrp = getHRP()
            if not hrp then return end
            local char = LocalPlayer.Character
            if not char then return end
            local tool = char:FindFirstChildOfClass("Tool")
            if not tool then return end
            local zombieFolder = workspace:FindFirstChild("ActiveZombies")
            if not zombieFolder then return end
            for _, zombie in ipairs(zombieFolder:GetChildren()) do
                local hum = zombie:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local zhrp = zombie:FindFirstChild("HumanoidRootPart")
                    if zhrp then
                        local dist = (zhrp.Position - hrp.Position).Magnitude
                        if dist <= Settings.KillAuraRange then
                            local target = zombie:FindFirstChild("HeadHitbox")
                                        or zombie:FindFirstChild("Head")
                                        or zhrp
                            fireAtTarget(target)
                            task.wait(0.05)  -- Fix C: gap between zombies to avoid server rate-limit
                        end
                    end
                end
            end
        end)
    end)
end)

-- Auto Bring: Heartbeat loop — teleports all living zombies in a circle around the player
-- Pure client-side CFrame manipulation; freezes zombie WalkSpeed while active
local bringTimer = 0
RunService.Heartbeat:Connect(function(dt)
    if not Settings.AutoBring then
        bringTimer = 0
        return
    end
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

            for i, zombie in ipairs(zombies) do
                local hum = zombie:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local zhrp = zombie:FindFirstChild("HumanoidRootPart")
                    if zhrp then
                        -- Spread zombies evenly in a circle around the player
                        local angle  = ((i - 1) / total) * (2 * math.pi)
                        local offset = Vector3.new(
                            math.cos(angle),
                            0,
                            math.sin(angle)
                        ) * Settings.BringRadius
                        local targetPos = hrp.Position + offset
                        pcall(function()
                            zhrp.CFrame   = CFrame.new(targetPos)
                            hum.WalkSpeed = 0
                        end)
                        -- When Aimbot is also ON, fire at each brought zombie
                        if Settings.Aimbot then
                            local target = zombie:FindFirstChild("HeadHitbox")
                                        or zombie:FindFirstChild("Head")
                                        or zhrp
                            task.spawn(function() fireAtTarget(target) end)
                        end
                        task.wait(0.01)
                    end
                end
            end
        end)
    end)
end)

-- LavaRising event notification
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

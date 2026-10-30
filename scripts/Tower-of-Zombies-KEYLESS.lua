--[[
    ================================================================
    Tower of Zombies Hub — Tower of Zombies
    Created by Rival960 with the help of Claude
    Version: v1.0.0 | Languages: 21 | Rayfield UI
    Status: untested in-game
    Game: https://www.roblox.com/games/99122501338948/Tower-of-Zombies
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
        WindowTitle      = "Tower of Zombies Hub",
        WindowSubtitle   = "by Rival960",
        TabHome          = "Home",
        TabCombat        = "Combat",
        TabMovement      = "Movement",
        TabTools         = "Tools & Visuals",
        CreditsTitle     = "Credits",
        CreditsContent   = "Created by Rival960 with the help of AI\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — First Release",
        Aimbot           = "Aimbot",
        RapidFire        = "Rapid Fire",
        RapidFireDelay   = "Rapid Fire Delay (s)",
        KillAura         = "Kill Aura",
        KillAuraDelay    = "Kill Aura Delay (s)",
        KillAuraRange    = "Kill Aura Range",
        MaxZombieDist    = "Max Zombie Distance",
        FlyToggle        = "Fly",
        FlySpeed         = "Fly Speed",
        NoClip           = "NoClip",
        WalkSpeed        = "Walk Speed",
        InfJump          = "Infinite Jump",
        AntiAFK          = "Anti-AFK",
        Fullbright       = "Fullbright",
        LanguageSelect   = "Language",
        LangNote         = "Language change requires re-execution",
    },
    FR = {
        WindowTitle      = "Tower of Zombies Hub",
        WindowSubtitle   = "par Rival960",
        TabHome          = "Accueil",
        TabCombat        = "Combat",
        TabMovement      = "Déplacement",
        TabTools         = "Outils & Visuels",
        CreditsTitle     = "Crédits",
        CreditsContent   = "Créé par Rival960 avec l'aide de l'IA\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — Première Release",
        Aimbot           = "Aimbot",
        RapidFire        = "Tir Rapide",
        RapidFireDelay   = "Délai Tir Rapide (s)",
        KillAura         = "Kill Aura",
        KillAuraDelay    = "Délai Kill Aura (s)",
        KillAuraRange    = "Portée Kill Aura",
        MaxZombieDist    = "Distance Max Zombie",
        FlyToggle        = "Vol",
        FlySpeed         = "Vitesse de Vol",
        NoClip           = "NoClip",
        WalkSpeed        = "Vitesse de Marche",
        InfJump          = "Saut Infini",
        AntiAFK          = "Anti-AFK",
        Fullbright       = "Luminosité Max",
        LanguageSelect   = "Langue",
        LangNote         = "Le changement de langue nécessite une ré-exécution",
    },
    DE = {
        WindowTitle      = "Tower of Zombies Hub",
        WindowSubtitle   = "von Rival960",
        TabHome          = "Start",
        TabCombat        = "Kampf",
        TabMovement      = "Bewegung",
        TabTools         = "Tools & Visuals",
        CreditsTitle     = "Credits",
        CreditsContent   = "Erstellt von Rival960 mit KI-Hilfe\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — Erstveröffentlichung",
        Aimbot           = "Aimbot",
        RapidFire        = "Schnellfeuer",
        RapidFireDelay   = "Schnellfeuer Verzögerung (s)",
        KillAura         = "Kill Aura",
        KillAuraDelay    = "Kill Aura Verzögerung (s)",
        KillAuraRange    = "Kill Aura Reichweite",
        MaxZombieDist    = "Max Zombie-Distanz",
        FlyToggle        = "Fliegen",
        FlySpeed         = "Fluggeschwindigkeit",
        NoClip           = "NoClip",
        WalkSpeed        = "Laufgeschwindigkeit",
        InfJump          = "Unendlicher Sprung",
        AntiAFK          = "Anti-AFK",
        Fullbright       = "Vollhelligkeit",
        LanguageSelect   = "Sprache",
        LangNote         = "Sprachänderung erfordert Neuausführung",
    },
    ES = {
        WindowTitle      = "Tower of Zombies Hub",
        WindowSubtitle   = "por Rival960",
        TabHome          = "Inicio",
        TabCombat        = "Combate",
        TabMovement      = "Movimiento",
        TabTools         = "Herramientas",
        CreditsTitle     = "Créditos",
        CreditsContent   = "Creado por Rival960 con ayuda de IA\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — Primera Versión",
        Aimbot           = "Aimbot",
        RapidFire        = "Fuego Rápido",
        RapidFireDelay   = "Retraso Fuego Rápido (s)",
        KillAura         = "Kill Aura",
        KillAuraDelay    = "Retraso Kill Aura (s)",
        KillAuraRange    = "Alcance Kill Aura",
        MaxZombieDist    = "Distancia Máx Zombie",
        FlyToggle        = "Volar",
        FlySpeed         = "Velocidad de Vuelo",
        NoClip           = "NoClip",
        WalkSpeed        = "Velocidad de Caminar",
        InfJump          = "Salto Infinito",
        AntiAFK          = "Anti-AFK",
        Fullbright       = "Brillo Total",
        LanguageSelect   = "Idioma",
        LangNote         = "El cambio de idioma requiere re-ejecución",
    },
    PT = {
        WindowTitle      = "Tower of Zombies Hub",
        WindowSubtitle   = "por Rival960",
        TabHome          = "Início",
        TabCombat        = "Combate",
        TabMovement      = "Movimento",
        TabTools         = "Ferramentas",
        CreditsTitle     = "Créditos",
        CreditsContent   = "Criado por Rival960 com ajuda de IA\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — Primeiro Lançamento",
        Aimbot           = "Aimbot",
        RapidFire        = "Tiro Rápido",
        RapidFireDelay   = "Atraso Tiro Rápido (s)",
        KillAura         = "Kill Aura",
        KillAuraDelay    = "Atraso Kill Aura (s)",
        KillAuraRange    = "Alcance Kill Aura",
        MaxZombieDist    = "Distância Máx Zumbi",
        FlyToggle        = "Voar",
        FlySpeed         = "Velocidade de Voo",
        NoClip           = "NoClip",
        WalkSpeed        = "Velocidade de Caminhada",
        InfJump          = "Salto Infinito",
        AntiAFK          = "Anti-AFK",
        Fullbright       = "Brilho Total",
        LanguageSelect   = "Idioma",
        LangNote         = "Mudança de idioma requer re-execução",
    },
    RU = {
        WindowTitle      = "Tower of Zombies Hub",
        WindowSubtitle   = "от Rival960",
        TabHome          = "Главная",
        TabCombat        = "Бой",
        TabMovement      = "Движение",
        TabTools         = "Инструменты",
        CreditsTitle     = "Авторы",
        CreditsContent   = "Создано Rival960 с помощью ИИ\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — Первый Выпуск",
        Aimbot           = "Аимбот",
        RapidFire        = "Быстрый Огонь",
        RapidFireDelay   = "Задержка быстрого огня (с)",
        KillAura         = "Kill Aura",
        KillAuraDelay    = "Задержка Kill Aura (с)",
        KillAuraRange    = "Радиус Kill Aura",
        MaxZombieDist    = "Макс дистанция зомби",
        FlyToggle        = "Полёт",
        FlySpeed         = "Скорость полёта",
        NoClip           = "NoClip",
        WalkSpeed        = "Скорость ходьбы",
        InfJump          = "Бесконечный прыжок",
        AntiAFK          = "Анти-АФК",
        Fullbright       = "Полная яркость",
        LanguageSelect   = "Язык",
        LangNote         = "Смена языка требует повторного запуска",
    },
    IT = {
        WindowTitle      = "Tower of Zombies Hub",
        WindowSubtitle   = "di Rival960",
        TabHome          = "Home",
        TabCombat        = "Combattimento",
        TabMovement      = "Movimento",
        TabTools         = "Strumenti",
        CreditsTitle     = "Crediti",
        CreditsContent   = "Creato da Rival960 con l'aiuto dell'IA\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — Prima Release",
        Aimbot           = "Aimbot",
        RapidFire        = "Fuoco Rapido",
        RapidFireDelay   = "Ritardo Fuoco Rapido (s)",
        KillAura         = "Kill Aura",
        KillAuraDelay    = "Ritardo Kill Aura (s)",
        KillAuraRange    = "Raggio Kill Aura",
        MaxZombieDist    = "Distanza Max Zombie",
        FlyToggle        = "Volo",
        FlySpeed         = "Velocità di Volo",
        NoClip           = "NoClip",
        WalkSpeed        = "Velocità di Camminata",
        InfJump          = "Salto Infinito",
        AntiAFK          = "Anti-AFK",
        Fullbright       = "Piena Luminosità",
        LanguageSelect   = "Lingua",
        LangNote         = "Il cambio lingua richiede una ri-esecuzione",
    },
    NL = {
        WindowTitle      = "Tower of Zombies Hub",
        WindowSubtitle   = "door Rival960",
        TabHome          = "Start",
        TabCombat        = "Gevecht",
        TabMovement      = "Beweging",
        TabTools         = "Tools & Visuals",
        CreditsTitle     = "Credits",
        CreditsContent   = "Gemaakt door Rival960 met AI-hulp\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — Eerste Release",
        Aimbot           = "Aimbot",
        RapidFire        = "Snel Vuren",
        RapidFireDelay   = "Snel Vuren Vertraging (s)",
        KillAura         = "Kill Aura",
        KillAuraDelay    = "Kill Aura Vertraging (s)",
        KillAuraRange    = "Kill Aura Bereik",
        MaxZombieDist    = "Max Zombie Afstand",
        FlyToggle        = "Vliegen",
        FlySpeed         = "Vliegsnelheid",
        NoClip           = "NoClip",
        WalkSpeed        = "Loopsnelheid",
        InfJump          = "Oneindig Springen",
        AntiAFK          = "Anti-AFK",
        Fullbright       = "Maximale Helderheid",
        LanguageSelect   = "Taal",
        LangNote         = "Taalwijziging vereist heruitvoering",
    },
    PL = {
        WindowTitle      = "Tower of Zombies Hub",
        WindowSubtitle   = "przez Rival960",
        TabHome          = "Strona główna",
        TabCombat        = "Walka",
        TabMovement      = "Ruch",
        TabTools         = "Narzędzia",
        CreditsTitle     = "Kredyty",
        CreditsContent   = "Stworzone przez Rival960 z pomocą AI\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — Pierwsze Wydanie",
        Aimbot           = "Aimbot",
        RapidFire        = "Szybki Ogień",
        RapidFireDelay   = "Opóźnienie szybkiego ognia (s)",
        KillAura         = "Kill Aura",
        KillAuraDelay    = "Opóźnienie Kill Aura (s)",
        KillAuraRange    = "Zasięg Kill Aura",
        MaxZombieDist    = "Maks. dystans zombie",
        FlyToggle        = "Latanie",
        FlySpeed         = "Prędkość lotu",
        NoClip           = "NoClip",
        WalkSpeed        = "Prędkość chodu",
        InfJump          = "Nieskończony Skok",
        AntiAFK          = "Anti-AFK",
        Fullbright       = "Pełna jasność",
        LanguageSelect   = "Język",
        LangNote         = "Zmiana języka wymaga ponownego uruchomienia",
    },
    ZH = {
        WindowTitle      = "行尸走肉枢纽",
        WindowSubtitle   = "由 Rival960",
        TabHome          = "主页",
        TabCombat        = "战斗",
        TabMovement      = "移动",
        TabTools         = "工具与视觉",
        CreditsTitle     = "致谢",
        CreditsContent   = "由 Rival960 借助 AI 创建\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — 首次发布",
        Aimbot           = "自动瞄准",
        RapidFire        = "快速射击",
        RapidFireDelay   = "快速射击延迟 (秒)",
        KillAura         = "杀戮光环",
        KillAuraDelay    = "杀戮光环延迟 (秒)",
        KillAuraRange    = "杀戮光环范围",
        MaxZombieDist    = "最大僵尸距离",
        FlyToggle        = "飞行",
        FlySpeed         = "飞行速度",
        NoClip           = "穿墙",
        WalkSpeed        = "行走速度",
        InfJump          = "无限跳跃",
        AntiAFK          = "防离线",
        Fullbright       = "全亮",
        LanguageSelect   = "语言",
        LangNote         = "语言更改需要重新执行",
    },
    JA = {
        WindowTitle      = "ゾンビタワーハブ",
        WindowSubtitle   = "Rival960 制作",
        TabHome          = "ホーム",
        TabCombat        = "戦闘",
        TabMovement      = "移動",
        TabTools         = "ツール",
        CreditsTitle     = "クレジット",
        CreditsContent   = "Rival960 と AI の協力で作成\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — 初版",
        Aimbot           = "エイムボット",
        RapidFire        = "連射",
        RapidFireDelay   = "連射遅延 (秒)",
        KillAura         = "キルオーラ",
        KillAuraDelay    = "キルオーラ遅延 (秒)",
        KillAuraRange    = "キルオーラ範囲",
        MaxZombieDist    = "最大ゾンビ距離",
        FlyToggle        = "フライ",
        FlySpeed         = "飛行速度",
        NoClip           = "ノークリップ",
        WalkSpeed        = "歩行速度",
        InfJump          = "無限ジャンプ",
        AntiAFK          = "アンチAFK",
        Fullbright       = "フルブライト",
        LanguageSelect   = "言語",
        LangNote         = "言語変更は再実行が必要です",
    },
    TR = {
        WindowTitle      = "Tower of Zombies Hub",
        WindowSubtitle   = "Rival960 tarafından",
        TabHome          = "Ana Sayfa",
        TabCombat        = "Savaş",
        TabMovement      = "Hareket",
        TabTools         = "Araçlar",
        CreditsTitle     = "Krediler",
        CreditsContent   = "Rival960 tarafından AI yardımıyla yapılmıştır\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — İlk Çıkış",
        Aimbot           = "Aimbot",
        RapidFire        = "Hızlı Ateş",
        RapidFireDelay   = "Hızlı Ateş Gecikmesi (s)",
        KillAura         = "Kill Aura",
        KillAuraDelay    = "Kill Aura Gecikmesi (s)",
        KillAuraRange    = "Kill Aura Menzili",
        MaxZombieDist    = "Maks Zombi Mesafesi",
        FlyToggle        = "Uçuş",
        FlySpeed         = "Uçuş Hızı",
        NoClip           = "NoClip",
        WalkSpeed        = "Yürüyüş Hızı",
        InfJump          = "Sonsuz Zıplama",
        AntiAFK          = "Anti-AFK",
        Fullbright       = "Tam Parlaklık",
        LanguageSelect   = "Dil",
        LangNote         = "Dil değişikliği yeniden başlatma gerektirir",
    },
    KO = {
        WindowTitle      = "좀비 타워 허브",
        WindowSubtitle   = "Rival960 제작",
        TabHome          = "홈",
        TabCombat        = "전투",
        TabMovement      = "이동",
        TabTools         = "도구",
        CreditsTitle     = "크레딧",
        CreditsContent   = "Rival960이 AI의 도움으로 제작\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — 첫 번째 릴리즈",
        Aimbot           = "에임봇",
        RapidFire        = "연사",
        RapidFireDelay   = "연사 지연 (초)",
        KillAura         = "킬 오라",
        KillAuraDelay    = "킬 오라 지연 (초)",
        KillAuraRange    = "킬 오라 범위",
        MaxZombieDist    = "최대 좀비 거리",
        FlyToggle        = "비행",
        FlySpeed         = "비행 속도",
        NoClip           = "노클립",
        WalkSpeed        = "걷기 속도",
        InfJump          = "무한 점프",
        AntiAFK          = "Anti-AFK",
        Fullbright       = "전체 밝기",
        LanguageSelect   = "언어",
        LangNote         = "언어 변경은 재실행이 필요합니다",
    },
    AR = {
        WindowTitle      = "Tower of Zombies Hub",
        WindowSubtitle   = "بواسطة Rival960",
        TabHome          = "الرئيسية",
        TabCombat        = "القتال",
        TabMovement      = "الحركة",
        TabTools         = "الأدوات",
        CreditsTitle     = "الاعتمادات",
        CreditsContent   = "تم إنشاؤه بواسطة Rival960 بمساعدة الذكاء الاصطناعي\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — الإصدار الأول",
        Aimbot           = "أيمبوت",
        RapidFire        = "إطلاق نار سريع",
        RapidFireDelay   = "تأخير الإطلاق السريع (ث)",
        KillAura         = "هالة القتل",
        KillAuraDelay    = "تأخير هالة القتل (ث)",
        KillAuraRange    = "نطاق هالة القتل",
        MaxZombieDist    = "أقصى مسافة للزومبي",
        FlyToggle        = "طيران",
        FlySpeed         = "سرعة الطيران",
        NoClip           = "اختراق الجدران",
        WalkSpeed        = "سرعة المشي",
        InfJump          = "قفز لانهائي",
        AntiAFK          = "مانع الخمول",
        Fullbright       = "سطوع كامل",
        LanguageSelect   = "اللغة",
        LangNote         = "تغيير اللغة يتطلب إعادة التشغيل",
    },
    VI = {
        WindowTitle      = "Tower of Zombies Hub",
        WindowSubtitle   = "bởi Rival960",
        TabHome          = "Trang Chủ",
        TabCombat        = "Chiến Đấu",
        TabMovement      = "Di Chuyển",
        TabTools         = "Công Cụ",
        CreditsTitle     = "Tín Dụng",
        CreditsContent   = "Tạo bởi Rival960 với sự trợ giúp của AI\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — Phát Hành Đầu Tiên",
        Aimbot           = "Aimbot",
        RapidFire        = "Bắn Nhanh",
        RapidFireDelay   = "Độ trễ bắn nhanh (s)",
        KillAura         = "Kill Aura",
        KillAuraDelay    = "Độ trễ Kill Aura (s)",
        KillAuraRange    = "Tầm Kill Aura",
        MaxZombieDist    = "Khoảng Cách Zombie Tối Đa",
        FlyToggle        = "Bay",
        FlySpeed         = "Tốc Độ Bay",
        NoClip           = "NoClip",
        WalkSpeed        = "Tốc Độ Đi",
        InfJump          = "Nhảy Vô Hạn",
        AntiAFK          = "Chống AFK",
        Fullbright       = "Độ Sáng Tối Đa",
        LanguageSelect   = "Ngôn Ngữ",
        LangNote         = "Thay đổi ngôn ngữ cần khởi động lại",
    },
    SV = {
        WindowTitle      = "Tower of Zombies Hub",
        WindowSubtitle   = "av Rival960",
        TabHome          = "Hem",
        TabCombat        = "Strid",
        TabMovement      = "Rörelse",
        TabTools         = "Verktyg",
        CreditsTitle     = "Erkännanden",
        CreditsContent   = "Skapad av Rival960 med hjälp av AI\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — Första Utgåvan",
        Aimbot           = "Aimbot",
        RapidFire        = "Snabbeld",
        RapidFireDelay   = "Snabbeld Fördröjning (s)",
        KillAura         = "Kill Aura",
        KillAuraDelay    = "Kill Aura Fördröjning (s)",
        KillAuraRange    = "Kill Aura Räckvidd",
        MaxZombieDist    = "Max Zombieavstånd",
        FlyToggle        = "Flyg",
        FlySpeed         = "Flyghastighet",
        NoClip           = "NoClip",
        WalkSpeed        = "Gånghastighet",
        InfJump          = "Oändligt Hopp",
        AntiAFK          = "Anti-AFK",
        Fullbright       = "Full Ljusstyrka",
        LanguageSelect   = "Språk",
        LangNote         = "Språkändring kräver omstartning",
    },
    EL = {
        WindowTitle      = "Tower of Zombies Hub",
        WindowSubtitle   = "από Rival960",
        TabHome          = "Αρχική",
        TabCombat        = "Μάχη",
        TabMovement      = "Κίνηση",
        TabTools         = "Εργαλεία",
        CreditsTitle     = "Εύσημα",
        CreditsContent   = "Δημιουργήθηκε από Rival960 με βοήθεια AI\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — Πρώτη Κυκλοφορία",
        Aimbot           = "Aimbot",
        RapidFire        = "Γρήγορα Πυρά",
        RapidFireDelay   = "Καθυστέρηση Γρήγορων Πυρών (s)",
        KillAura         = "Kill Aura",
        KillAuraDelay    = "Καθυστέρηση Kill Aura (s)",
        KillAuraRange    = "Εμβέλεια Kill Aura",
        MaxZombieDist    = "Μέγ. Απόσταση Ζόμπι",
        FlyToggle        = "Πτήση",
        FlySpeed         = "Ταχύτητα Πτήσης",
        NoClip           = "NoClip",
        WalkSpeed        = "Ταχύτητα Βαδίσματος",
        InfJump          = "Άπειρο Άλμα",
        AntiAFK          = "Anti-AFK",
        Fullbright       = "Πλήρης Φωτεινότητα",
        LanguageSelect   = "Γλώσσα",
        LangNote         = "Η αλλαγή γλώσσας απαιτεί επανεκτέλεση",
    },
    RO = {
        WindowTitle      = "Tower of Zombies Hub",
        WindowSubtitle   = "de Rival960",
        TabHome          = "Acasă",
        TabCombat        = "Luptă",
        TabMovement      = "Mișcare",
        TabTools         = "Instrumente",
        CreditsTitle     = "Credite",
        CreditsContent   = "Creat de Rival960 cu ajutorul AI\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — Prima Lansare",
        Aimbot           = "Aimbot",
        RapidFire        = "Foc Rapid",
        RapidFireDelay   = "Întârziere Foc Rapid (s)",
        KillAura         = "Kill Aura",
        KillAuraDelay    = "Întârziere Kill Aura (s)",
        KillAuraRange    = "Raza Kill Aura",
        MaxZombieDist    = "Dist. Maximă Zombie",
        FlyToggle        = "Zbor",
        FlySpeed         = "Viteză Zbor",
        NoClip           = "NoClip",
        WalkSpeed        = "Viteză Mers",
        InfJump          = "Salt Infinit",
        AntiAFK          = "Anti-AFK",
        Fullbright       = "Luminozitate Maximă",
        LanguageSelect   = "Limbă",
        LangNote         = "Schimbarea limbii necesită re-executare",
    },
    UK = {
        WindowTitle      = "Tower of Zombies Hub",
        WindowSubtitle   = "від Rival960",
        TabHome          = "Головна",
        TabCombat        = "Бій",
        TabMovement      = "Рух",
        TabTools         = "Інструменти",
        CreditsTitle     = "Автори",
        CreditsContent   = "Створено Rival960 за допомогою AI\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — Перший Випуск",
        Aimbot           = "Аімбот",
        RapidFire        = "Швидкий Вогонь",
        RapidFireDelay   = "Затримка швидкого вогню (с)",
        KillAura         = "Kill Aura",
        KillAuraDelay    = "Затримка Kill Aura (с)",
        KillAuraRange    = "Радіус Kill Aura",
        MaxZombieDist    = "Макс дистанція зомбі",
        FlyToggle        = "Політ",
        FlySpeed         = "Швидкість польоту",
        NoClip           = "NoClip",
        WalkSpeed        = "Швидкість ходьби",
        InfJump          = "Нескінченний Стрибок",
        AntiAFK          = "Анти-АФК",
        Fullbright       = "Повна яскравість",
        LanguageSelect   = "Мова",
        LangNote         = "Зміна мови потребує перезапуску",
    },
    CS = {
        WindowTitle      = "Tower of Zombies Hub",
        WindowSubtitle   = "od Rival960",
        TabHome          = "Domů",
        TabCombat        = "Boj",
        TabMovement      = "Pohyb",
        TabTools         = "Nástroje",
        CreditsTitle     = "Poděkování",
        CreditsContent   = "Vytvořeno Rival960 s pomocí AI\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — První Vydání",
        Aimbot           = "Aimbot",
        RapidFire        = "Rychlá Střelba",
        RapidFireDelay   = "Zpoždění rychlé střelby (s)",
        KillAura         = "Kill Aura",
        KillAuraDelay    = "Zpoždění Kill Aura (s)",
        KillAuraRange    = "Dosah Kill Aura",
        MaxZombieDist    = "Max vzdálenost zombie",
        FlyToggle        = "Létání",
        FlySpeed         = "Rychlost letu",
        NoClip           = "NoClip",
        WalkSpeed        = "Rychlost chůze",
        InfJump          = "Nekonečný Skok",
        AntiAFK          = "Anti-AFK",
        Fullbright       = "Plný jas",
        LanguageSelect   = "Jazyk",
        LangNote         = "Změna jazyka vyžaduje restartování",
    },
    DA = {
        WindowTitle      = "Tower of Zombies Hub",
        WindowSubtitle   = "af Rival960",
        TabHome          = "Hjem",
        TabCombat        = "Kamp",
        TabMovement      = "Bevægelse",
        TabTools         = "Værktøjer",
        CreditsTitle     = "Anerkendelser",
        CreditsContent   = "Oprettet af Rival960 med hjælp fra AI\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — Første Udgivelse",
        Aimbot           = "Aimbot",
        RapidFire        = "Hurtig Ild",
        RapidFireDelay   = "Hurtig Ild Forsinkelse (s)",
        KillAura         = "Kill Aura",
        KillAuraDelay    = "Kill Aura Forsinkelse (s)",
        KillAuraRange    = "Kill Aura Rækkevidde",
        MaxZombieDist    = "Maks Zombie Afstand",
        FlyToggle        = "Fly",
        FlySpeed         = "Flyvehastighed",
        NoClip           = "NoClip",
        WalkSpeed        = "Gåhastighed",
        InfJump          = "Uendeligt Hop",
        AntiAFK          = "Anti-AFK",
        Fullbright       = "Fuld Lysstyrke",
        LanguageSelect   = "Sprog",
        LangNote         = "Sprogændring kræver genstart",
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
    RapidFire        = false,
    RapidFireDelay   = 0.1,
    KillAura         = false,
    KillAuraDelay    = 0.15,
    KillAuraRange    = 150,
    MaxZombieDist    = 300,
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

-- Shared fire function — math only, no workspace:Raycast, penetrates all walls
local function fireAtTarget(weaponName, targetPart)
    local char = LocalPlayer.Character
    if not char then return end
    local weapon   = char:FindFirstChild(weaponName)
    if not weapon  then return end
    local exitPart = weapon:FindFirstChild("Exit")
    if not exitPart then return end
    local rayOrigin = exitPart.WorldPosition
    local hitPos    = targetPart.Position
    local normalVec = (rayOrigin - hitPos).Unit  -- from target back to barrel
    pcall(function()
        game:GetService("ReplicatedStorage").Events.Actions.Fire:FireServer(
            weaponName,
            { { targetPart, hitPos, normalVec } },
            { { weaponName, rayOrigin, hitPos, hitPos, true, targetPart, false, false, "Default", exitPart } }
        )
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

-- ───── Tab 2: Combat ─────
local CombatTab = Window:CreateTab(T("TabCombat"), 4483362458)

CombatTab:CreateToggle({
    Name         = T("Aimbot"),
    CurrentValue = false,
    Callback     = function(val) Settings.Aimbot = val end,
})

CombatTab:CreateToggle({
    Name         = T("RapidFire"),
    CurrentValue = false,
    Callback     = function(val) Settings.RapidFire = val end,
})

CombatTab:CreateSlider({
    Name         = T("RapidFireDelay"),
    Range        = {0.05, 0.5},
    Increment    = 0.05,
    CurrentValue = 0.1,
    Callback     = function(val) Settings.RapidFireDelay = val end,
})

CombatTab:CreateSlider({
    Name         = T("MaxZombieDist"),
    Range        = {50, 500},
    Increment    = 10,
    CurrentValue = 300,
    Callback     = function(val) Settings.MaxZombieDist = val end,
})

CombatTab:CreateToggle({
    Name         = T("KillAura"),
    CurrentValue = false,
    Callback     = function(val) Settings.KillAura = val end,
})

CombatTab:CreateSlider({
    Name         = T("KillAuraDelay"),
    Range        = {0.05, 0.5},
    Increment    = 0.05,
    CurrentValue = 0.15,
    Callback     = function(val) Settings.KillAuraDelay = val end,
})

CombatTab:CreateSlider({
    Name         = T("KillAuraRange"),
    Range        = {50, 500},
    Increment    = 10,
    CurrentValue = 150,
    Callback     = function(val) Settings.KillAuraRange = val end,
})

-- ───── Tab 3: Movement ─────
local MovementTab = Window:CreateTab(T("TabMovement"), 4483362458)

-- ================================================================
-- Fly system (exact implementation from spec 097915f3 — do not touch)
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
            local cam = workspace.CurrentCamera
            local spd = Settings.FlySpeed
            local md  = hum.MoveDirection
            local vel
            if md.Magnitude > 0.1 then
                local fwd   = Vector3.new(cam.CFrame.LookVector.X,  0, cam.CFrame.LookVector.Z)
                local right = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z)
                if fwd.Magnitude   > 0 then fwd   = fwd.Unit   end
                if right.Magnitude > 0 then right = right.Unit end
                vel = (fwd * (-md.Z) + right * md.X) * spd
                    + Vector3.new(0, (CTRL.UP + CTRL.DOWN + FLY_BTN_UP + FLY_BTN_DOWN) * spd, 0)
            else
                vel = (cam.CFrame.LookVector  * (CTRL.F + CTRL.B)
                     + cam.CFrame.RightVector * (CTRL.L + CTRL.R)
                     + Vector3.new(0, (CTRL.UP + CTRL.DOWN + FLY_BTN_UP + FLY_BTN_DOWN), 0)) * spd
            end
            bv.Velocity = vel
            bg.CFrame   = cam.CFrame
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

-- Aimbot: RenderStepped camera-lock — do not touch
RunService.RenderStepped:Connect(function()
    if not Settings.Aimbot then return end
    pcall(function()
        local cam        = workspace.CurrentCamera
        local targetPart = getClosestZombieTarget(Settings.MaxZombieDist)
        if targetPart then
            cam.CFrame = CFrame.lookAt(cam.CFrame.Position, targetPart.Position)
        end
    end)
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if not Settings.InfJump then return end
    pcall(function()
        local hum = getHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end)

-- Rapid Fire: Heartbeat loop, fires via shared fireAtTarget
local rapidFireTimer = 0
RunService.Heartbeat:Connect(function(dt)
    if not Settings.RapidFire then
        rapidFireTimer = 0
        return
    end
    rapidFireTimer = rapidFireTimer + dt
    if rapidFireTimer < Settings.RapidFireDelay then return end
    rapidFireTimer = 0
    pcall(function()
        local char = getChar()
        if not char then return end
        local tool = char:FindFirstChildOfClass("Tool")
        if not tool then return end
        local weaponName = tool.Name
        local targetPart = getClosestZombieTarget(Settings.MaxZombieDist)
        if not targetPart then return end
        fireAtTarget(weaponName, targetPart)
    end)
end)

-- Kill Aura: Heartbeat loop, fires at every zombie within range via shared fireAtTarget
local killAuraTimer = 0
RunService.Heartbeat:Connect(function(dt)
    if not Settings.KillAura then
        killAuraTimer = 0
        return
    end
    killAuraTimer = killAuraTimer + dt
    if killAuraTimer < Settings.KillAuraDelay then return end
    killAuraTimer = 0
    task.spawn(function()
        pcall(function()
            local char = getChar()
            if not char then return end
            local tool = char:FindFirstChildOfClass("Tool")
            if not tool then return end
            local weaponName   = tool.Name
            local hrp          = getHRP()
            if not hrp then return end
            local zombieFolder = workspace:FindFirstChild("ActiveZombies")
            if not zombieFolder then return end
            for _, zombie in ipairs(zombieFolder:GetChildren()) do
                local hum = zombie:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local zhrp = zombie:FindFirstChild("HumanoidRootPart")
                    if zhrp then
                        local dist = (zhrp.Position - hrp.Position).Magnitude
                        if dist <= Settings.KillAuraRange then
                            local targetPart = zombie:FindFirstChild("HeadHitbox")
                                or zombie:FindFirstChild("Head")
                                or zhrp
                            fireAtTarget(weaponName, targetPart)
                            task.wait(0.01)
                        end
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

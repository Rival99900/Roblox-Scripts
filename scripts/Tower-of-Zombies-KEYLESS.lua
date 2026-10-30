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
        WindowTitle       = "Tower of Zombies Hub",
        WindowSubtitle    = "by Rival960",
        TabHome           = "Home",
        TabCombat         = "Combat",
        TabMovement       = "Movement",
        TabTools          = "Tools & Visuals",
        CreditsTitle      = "Credits",
        CreditsContent    = "Created by Rival960 with the help of AI\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — First Release",
        SilentAim         = "Silent Aim",
        AutoFire          = "Auto Fire",
        AutoFireDelay     = "Auto Fire Delay (s)",
        KillAura          = "Kill Aura",
        KillAuraDistance  = "Kill Aura Distance",
        MaxZombieDistance = "Max Zombie Distance",
        FlyToggle         = "Fly",
        FlySpeed          = "Fly Speed",
        NoClip            = "NoClip",
        WalkSpeed         = "Walk Speed",
        InfJump           = "Infinite Jump",
        AntiAFK           = "Anti-AFK",
        Fullbright        = "Fullbright",
        LanguageSelect    = "Language",
        LangNote          = "Language change requires re-execution",
    },
    FR = {
        WindowTitle       = "Tower of Zombies Hub",
        WindowSubtitle    = "par Rival960",
        TabHome           = "Accueil",
        TabCombat         = "Combat",
        TabMovement       = "Déplacement",
        TabTools          = "Outils & Visuels",
        CreditsTitle      = "Crédits",
        CreditsContent    = "Créé par Rival960 avec l'aide de l'IA\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — Première Release",
        SilentAim         = "Tir Silencieux",
        AutoFire          = "Tir Automatique",
        AutoFireDelay     = "Délai Tir Auto (s)",
        KillAura          = "Kill Aura",
        KillAuraDistance  = "Distance Kill Aura",
        MaxZombieDistance = "Distance Max Zombie",
        FlyToggle         = "Vol",
        FlySpeed          = "Vitesse de Vol",
        NoClip            = "NoClip",
        WalkSpeed         = "Vitesse de Marche",
        InfJump           = "Saut Infini",
        AntiAFK           = "Anti-AFK",
        Fullbright        = "Luminosité Max",
        LanguageSelect    = "Langue",
        LangNote          = "Le changement de langue nécessite une ré-exécution",
    },
    DE = {
        WindowTitle       = "Tower of Zombies Hub",
        WindowSubtitle    = "von Rival960",
        TabHome           = "Start",
        TabCombat         = "Kampf",
        TabMovement       = "Bewegung",
        TabTools          = "Tools & Visuals",
        CreditsTitle      = "Credits",
        CreditsContent    = "Erstellt von Rival960 mit KI-Hilfe\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — Erstveröffentlichung",
        SilentAim         = "Silent Aim",
        AutoFire          = "Auto-Feuer",
        AutoFireDelay     = "Auto-Feuer Verzögerung (s)",
        KillAura          = "Kill Aura",
        KillAuraDistance  = "Kill Aura Distanz",
        MaxZombieDistance = "Max Zombie-Distanz",
        FlyToggle         = "Fliegen",
        FlySpeed          = "Fluggeschwindigkeit",
        NoClip            = "NoClip",
        WalkSpeed         = "Laufgeschwindigkeit",
        InfJump           = "Unendlicher Sprung",
        AntiAFK           = "Anti-AFK",
        Fullbright        = "Vollhelligkeit",
        LanguageSelect    = "Sprache",
        LangNote          = "Sprachänderung erfordert Neuausführung",
    },
    ES = {
        WindowTitle       = "Tower of Zombies Hub",
        WindowSubtitle    = "por Rival960",
        TabHome           = "Inicio",
        TabCombat         = "Combate",
        TabMovement       = "Movimiento",
        TabTools          = "Herramientas",
        CreditsTitle      = "Créditos",
        CreditsContent    = "Creado por Rival960 con ayuda de IA\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — Primera Versión",
        SilentAim         = "Apuntado Silencioso",
        AutoFire          = "Disparo Automático",
        AutoFireDelay     = "Retraso Disparo Auto (s)",
        KillAura          = "Kill Aura",
        KillAuraDistance  = "Distancia Kill Aura",
        MaxZombieDistance = "Distancia Máx Zombie",
        FlyToggle         = "Volar",
        FlySpeed          = "Velocidad de Vuelo",
        NoClip            = "NoClip",
        WalkSpeed         = "Velocidad de Caminar",
        InfJump           = "Salto Infinito",
        AntiAFK           = "Anti-AFK",
        Fullbright        = "Brillo Total",
        LanguageSelect    = "Idioma",
        LangNote          = "El cambio de idioma requiere re-ejecución",
    },
    PT = {
        WindowTitle       = "Tower of Zombies Hub",
        WindowSubtitle    = "por Rival960",
        TabHome           = "Início",
        TabCombat         = "Combate",
        TabMovement       = "Movimento",
        TabTools          = "Ferramentas",
        CreditsTitle      = "Créditos",
        CreditsContent    = "Criado por Rival960 com ajuda de IA\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — Primeiro Lançamento",
        SilentAim         = "Mira Silenciosa",
        AutoFire          = "Disparo Automático",
        AutoFireDelay     = "Atraso Disparo Auto (s)",
        KillAura          = "Kill Aura",
        KillAuraDistance  = "Distância Kill Aura",
        MaxZombieDistance = "Distância Máx Zumbi",
        FlyToggle         = "Voar",
        FlySpeed          = "Velocidade de Voo",
        NoClip            = "NoClip",
        WalkSpeed         = "Velocidade de Caminhada",
        InfJump           = "Salto Infinito",
        AntiAFK           = "Anti-AFK",
        Fullbright        = "Brilho Total",
        LanguageSelect    = "Idioma",
        LangNote          = "Mudança de idioma requer re-execução",
    },
    RU = {
        WindowTitle       = "Tower of Zombies Hub",
        WindowSubtitle    = "от Rival960",
        TabHome           = "Главная",
        TabCombat         = "Бой",
        TabMovement       = "Движение",
        TabTools          = "Инструменты",
        CreditsTitle      = "Авторы",
        CreditsContent    = "Создано Rival960 с помощью ИИ\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — Первый Выпуск",
        SilentAim         = "Тихий Прицел",
        AutoFire          = "Авто Огонь",
        AutoFireDelay     = "Задержка авто огня (с)",
        KillAura          = "Kill Aura",
        KillAuraDistance  = "Дистанция Kill Aura",
        MaxZombieDistance = "Макс дистанция зомбі",
        FlyToggle         = "Полёт",
        FlySpeed          = "Скорость полёта",
        NoClip            = "NoClip",
        WalkSpeed         = "Скорость ходьбы",
        InfJump           = "Бесконечный прыжок",
        AntiAFK           = "Анти-АФК",
        Fullbright        = "Полная яркость",
        LanguageSelect    = "Язык",
        LangNote          = "Смена языка требует повторного запуска",
    },
    IT = {
        WindowTitle       = "Tower of Zombies Hub",
        WindowSubtitle    = "di Rival960",
        TabHome           = "Home",
        TabCombat         = "Combattimento",
        TabMovement       = "Movimento",
        TabTools          = "Strumenti",
        CreditsTitle      = "Crediti",
        CreditsContent    = "Creato da Rival960 con l'aiuto dell'IA\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — Prima Release",
        SilentAim         = "Mira Silenziosa",
        AutoFire          = "Fuoco Automatico",
        AutoFireDelay     = "Ritardo Fuoco Auto (s)",
        KillAura          = "Kill Aura",
        KillAuraDistance  = "Distanza Kill Aura",
        MaxZombieDistance = "Distanza Max Zombie",
        FlyToggle         = "Volo",
        FlySpeed          = "Velocità di Volo",
        NoClip            = "NoClip",
        WalkSpeed         = "Velocità di Camminata",
        InfJump           = "Salto Infinito",
        AntiAFK           = "Anti-AFK",
        Fullbright        = "Piena Luminosità",
        LanguageSelect    = "Lingua",
        LangNote          = "Il cambio lingua richiede una ri-esecuzione",
    },
    NL = {
        WindowTitle       = "Tower of Zombies Hub",
        WindowSubtitle    = "door Rival960",
        TabHome           = "Start",
        TabCombat         = "Gevecht",
        TabMovement       = "Beweging",
        TabTools          = "Tools & Visuals",
        CreditsTitle      = "Credits",
        CreditsContent    = "Gemaakt door Rival960 met AI-hulp\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — Eerste Release",
        SilentAim         = "Silent Aim",
        AutoFire          = "Automatisch Vuren",
        AutoFireDelay     = "Auto Vuren Vertraging (s)",
        KillAura          = "Kill Aura",
        KillAuraDistance  = "Kill Aura Afstand",
        MaxZombieDistance = "Max Zombie Afstand",
        FlyToggle         = "Vliegen",
        FlySpeed          = "Vliegsnelheid",
        NoClip            = "NoClip",
        WalkSpeed         = "Loopsnelheid",
        InfJump           = "Oneindig Springen",
        AntiAFK           = "Anti-AFK",
        Fullbright        = "Maximale Helderheid",
        LanguageSelect    = "Taal",
        LangNote          = "Taalwijziging vereist heruitvoering",
    },
    PL = {
        WindowTitle       = "Tower of Zombies Hub",
        WindowSubtitle    = "przez Rival960",
        TabHome           = "Strona główna",
        TabCombat         = "Walka",
        TabMovement       = "Ruch",
        TabTools          = "Narzędzia",
        CreditsTitle      = "Kredyty",
        CreditsContent    = "Stworzone przez Rival960 z pomocą AI\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — Pierwsze Wydanie",
        SilentAim         = "Cichy Celownik",
        AutoFire          = "Automatyczna Strzela",
        AutoFireDelay     = "Opóźnienie auto strzały (s)",
        KillAura          = "Kill Aura",
        KillAuraDistance  = "Dystans Kill Aura",
        MaxZombieDistance = "Maks. dystans zombie",
        FlyToggle         = "Latanie",
        FlySpeed          = "Prędkość lotu",
        NoClip            = "NoClip",
        WalkSpeed         = "Prędkość chodu",
        InfJump           = "Nieskończony Skok",
        AntiAFK           = "Anti-AFK",
        Fullbright        = "Pełna jasność",
        LanguageSelect    = "Język",
        LangNote          = "Zmiana języka wymaga ponownego uruchomienia",
    },
    ZH = {
        WindowTitle       = "行尸走肉枢纽",
        WindowSubtitle    = "由 Rival960",
        TabHome           = "主页",
        TabCombat         = "战斗",
        TabMovement       = "移动",
        TabTools          = "工具与视觉",
        CreditsTitle      = "致谢",
        CreditsContent    = "由 Rival960 借助 AI 创建\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — 首次发布",
        SilentAim         = "静默瞄准",
        AutoFire          = "自动射击",
        AutoFireDelay     = "自动射击延迟 (秒)",
        KillAura          = "杀戮光环",
        KillAuraDistance  = "杀戮光环距离",
        MaxZombieDistance = "最大僵尸距离",
        FlyToggle         = "飞行",
        FlySpeed          = "飞行速度",
        NoClip            = "穿墙",
        WalkSpeed         = "行走速度",
        InfJump           = "无限跳跃",
        AntiAFK           = "防离线",
        Fullbright        = "全亮",
        LanguageSelect    = "语言",
        LangNote          = "语言更改需要重新执行",
    },
    JA = {
        WindowTitle       = "ゾンビタワーハブ",
        WindowSubtitle    = "Rival960 制作",
        TabHome           = "ホーム",
        TabCombat         = "戦闘",
        TabMovement       = "移動",
        TabTools          = "ツール",
        CreditsTitle      = "クレジット",
        CreditsContent    = "Rival960 と AI の協力で作成\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — 初版",
        SilentAim         = "サイレントエイム",
        AutoFire          = "オートファイア",
        AutoFireDelay     = "オートファイア遅延 (秒)",
        KillAura          = "キルオーラ",
        KillAuraDistance  = "キルオーラ距離",
        MaxZombieDistance = "最大ゾンビ距離",
        FlyToggle         = "フライ",
        FlySpeed          = "飛行速度",
        NoClip            = "ノークリップ",
        WalkSpeed         = "歩行速度",
        InfJump           = "無限ジャンプ",
        AntiAFK           = "アンチAFK",
        Fullbright        = "フルブライト",
        LanguageSelect    = "言語",
        LangNote          = "言語変更は再実行が必要です",
    },
    TR = {
        WindowTitle       = "Tower of Zombies Hub",
        WindowSubtitle    = "Rival960 tarafından",
        TabHome           = "Ana Sayfa",
        TabCombat         = "Savaş",
        TabMovement       = "Hareket",
        TabTools          = "Araçlar",
        CreditsTitle      = "Krediler",
        CreditsContent    = "Rival960 tarafından AI yardımıyla yapılmıştır\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — İlk Çıkış",
        SilentAim         = "Sessiz Nişan",
        AutoFire          = "Otomatik Ateş",
        AutoFireDelay     = "Oto Ateş Gecikmesi (s)",
        KillAura          = "Kill Aura",
        KillAuraDistance  = "Kill Aura Mesafesi",
        MaxZombieDistance = "Maks Zombi Mesafesi",
        FlyToggle         = "Uçuş",
        FlySpeed          = "Uçuş Hızı",
        NoClip            = "NoClip",
        WalkSpeed         = "Yürüyüş Hızı",
        InfJump           = "Sonsuz Zıplama",
        AntiAFK           = "Anti-AFK",
        Fullbright        = "Tam Parlaklık",
        LanguageSelect    = "Dil",
        LangNote          = "Dil değişikliği yeniden başlatma gerektirir",
    },
    KO = {
        WindowTitle       = "좀비 타워 허브",
        WindowSubtitle    = "Rival960 제작",
        TabHome           = "홈",
        TabCombat         = "전투",
        TabMovement       = "이동",
        TabTools          = "도구",
        CreditsTitle      = "크레딧",
        CreditsContent    = "Rival960이 AI의 도움으로 제작\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — 첫 번째 릴리즈",
        SilentAim         = "사일런트 에임",
        AutoFire          = "자동 발사",
        AutoFireDelay     = "자동 발사 지연 (초)",
        KillAura          = "킬 오라",
        KillAuraDistance  = "킬 오라 거리",
        MaxZombieDistance = "최대 좀비 거리",
        FlyToggle         = "비행",
        FlySpeed          = "비행 속도",
        NoClip            = "노클립",
        WalkSpeed         = "걷기 속도",
        InfJump           = "무한 점프",
        AntiAFK           = "Anti-AFK",
        Fullbright        = "전체 밝기",
        LanguageSelect    = "언어",
        LangNote          = "언어 변경은 재실행이 필요합니다",
    },
    AR = {
        WindowTitle       = "Tower of Zombies Hub",
        WindowSubtitle    = "بواسطة Rival960",
        TabHome           = "الرئيسية",
        TabCombat         = "القتال",
        TabMovement       = "الحركة",
        TabTools          = "الأدوات",
        CreditsTitle      = "الاعتمادات",
        CreditsContent    = "تم إنشاؤه بواسطة Rival960 بمساعدة الذكاء الاصطناعي\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — الإصدار الأول",
        SilentAim         = "التصويب الصامت",
        AutoFire          = "إطلاق نار تلقائي",
        AutoFireDelay     = "تأخير الإطلاق التلقائي (ث)",
        KillAura          = "هالة القتل",
        KillAuraDistance  = "مسافة هالة القتل",
        MaxZombieDistance = "أقصى مسافة للزومبي",
        FlyToggle         = "طيران",
        FlySpeed          = "سرعة الطيران",
        NoClip            = "اختراق الجدران",
        WalkSpeed         = "سرعة المشي",
        InfJump           = "قفز لانهائي",
        AntiAFK           = "مانع الخمول",
        Fullbright        = "سطوع كامل",
        LanguageSelect    = "اللغة",
        LangNote          = "تغيير اللغة يتطلب إعادة التشغيل",
    },
    VI = {
        WindowTitle       = "Tower of Zombies Hub",
        WindowSubtitle    = "bởi Rival960",
        TabHome           = "Trang Chủ",
        TabCombat         = "Chiến Đấu",
        TabMovement       = "Di Chuyển",
        TabTools          = "Công Cụ",
        CreditsTitle      = "Tín Dụng",
        CreditsContent    = "Tạo bởi Rival960 với sự trợ giúp của AI\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — Phát Hành Đầu Tiên",
        SilentAim         = "Silent Aim",
        AutoFire          = "Bắn Tự Động",
        AutoFireDelay     = "Độ trễ bắn tự động (s)",
        KillAura          = "Kill Aura",
        KillAuraDistance  = "Khoảng cách Kill Aura",
        MaxZombieDistance = "Khoảng Cách Zombie Tối Đa",
        FlyToggle         = "Bay",
        FlySpeed          = "Tốc Độ Bay",
        NoClip            = "NoClip",
        WalkSpeed         = "Tốc Độ Đi",
        InfJump           = "Nhảy Vô Hạn",
        AntiAFK           = "Chống AFK",
        Fullbright        = "Độ Sáng Tối Đa",
        LanguageSelect    = "Ngôn Ngữ",
        LangNote          = "Thay đổi ngôn ngữ cần khởi động lại",
    },
    SV = {
        WindowTitle       = "Tower of Zombies Hub",
        WindowSubtitle    = "av Rival960",
        TabHome           = "Hem",
        TabCombat         = "Strid",
        TabMovement       = "Rörelse",
        TabTools          = "Verktyg",
        CreditsTitle      = "Erkännanden",
        CreditsContent    = "Skapad av Rival960 med hjälp av AI\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — Första Utgåvan",
        SilentAim         = "Tyst Sikte",
        AutoFire          = "Automatisk Eld",
        AutoFireDelay     = "Auto Eld Fördröjning (s)",
        KillAura          = "Kill Aura",
        KillAuraDistance  = "Kill Aura Avstånd",
        MaxZombieDistance = "Max Zombieavstånd",
        FlyToggle         = "Flyg",
        FlySpeed          = "Flyghastighet",
        NoClip            = "NoClip",
        WalkSpeed         = "Gånghastighet",
        InfJump           = "Oändligt Hopp",
        AntiAFK           = "Anti-AFK",
        Fullbright        = "Full Ljusstyrka",
        LanguageSelect    = "Språk",
        LangNote          = "Språkändring kräver omstartning",
    },
    EL = {
        WindowTitle       = "Tower of Zombies Hub",
        WindowSubtitle    = "από Rival960",
        TabHome           = "Αρχική",
        TabCombat         = "Μάχη",
        TabMovement       = "Κίνηση",
        TabTools          = "Εργαλεία",
        CreditsTitle      = "Εύσημα",
        CreditsContent    = "Δημιουργήθηκε από Rival960 με βοήθεια AI\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — Πρώτη Κυκλοφορία",
        SilentAim         = "Σιωπηλό Σημάδι",
        AutoFire          = "Αυτόματα Πυρά",
        AutoFireDelay     = "Καθυστέρηση Αυτ. Πυρών (s)",
        KillAura          = "Kill Aura",
        KillAuraDistance  = "Απόσταση Kill Aura",
        MaxZombieDistance = "Μέγ. Απόσταση Ζόμπι",
        FlyToggle         = "Πτήση",
        FlySpeed          = "Ταχύτητα Πτήσης",
        NoClip            = "NoClip",
        WalkSpeed         = "Ταχύτητα Βαδίσματος",
        InfJump           = "Άπειρο Άλμα",
        AntiAFK           = "Anti-AFK",
        Fullbright        = "Πλήρης Φωτεινότητα",
        LanguageSelect    = "Γλώσσα",
        LangNote          = "Η αλλαγή γλώσσας απαιτεί επανεκτέλεση",
    },
    RO = {
        WindowTitle       = "Tower of Zombies Hub",
        WindowSubtitle    = "de Rival960",
        TabHome           = "Acasă",
        TabCombat         = "Luptă",
        TabMovement       = "Mișcare",
        TabTools          = "Instrumente",
        CreditsTitle      = "Credite",
        CreditsContent    = "Creat de Rival960 cu ajutorul AI\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — Prima Lansare",
        SilentAim         = "Ochire Silențioasă",
        AutoFire          = "Tragere Automată",
        AutoFireDelay     = "Întârziere Tragere Auto (s)",
        KillAura          = "Kill Aura",
        KillAuraDistance  = "Distanță Kill Aura",
        MaxZombieDistance = "Dist. Maximă Zombie",
        FlyToggle         = "Zbor",
        FlySpeed          = "Viteză Zbor",
        NoClip            = "NoClip",
        WalkSpeed         = "Viteză Mers",
        InfJump           = "Salt Infinit",
        AntiAFK           = "Anti-AFK",
        Fullbright        = "Luminozitate Maximă",
        LanguageSelect    = "Limbă",
        LangNote          = "Schimbarea limbii necesită re-executare",
    },
    UK = {
        WindowTitle       = "Tower of Zombies Hub",
        WindowSubtitle    = "від Rival960",
        TabHome           = "Головна",
        TabCombat         = "Бій",
        TabMovement       = "Рух",
        TabTools          = "Інструменти",
        CreditsTitle      = "Автори",
        CreditsContent    = "Створено Rival960 за допомогою AI\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — Перший Випуск",
        SilentAim         = "Тихий Приціл",
        AutoFire          = "Авто Вогонь",
        AutoFireDelay     = "Затримка авто вогню (с)",
        KillAura          = "Kill Aura",
        KillAuraDistance  = "Дистанція Kill Aura",
        MaxZombieDistance = "Макс дистанція зомбі",
        FlyToggle         = "Політ",
        FlySpeed          = "Швидкість польоту",
        NoClip            = "NoClip",
        WalkSpeed         = "Швидкість ходьби",
        InfJump           = "Нескінченний Стрибок",
        AntiAFK           = "Анти-АФК",
        Fullbright        = "Повна яскравість",
        LanguageSelect    = "Мова",
        LangNote          = "Зміна мови потребує перезапуску",
    },
    CS = {
        WindowTitle       = "Tower of Zombies Hub",
        WindowSubtitle    = "od Rival960",
        TabHome           = "Domů",
        TabCombat         = "Boj",
        TabMovement       = "Pohyb",
        TabTools          = "Nástroje",
        CreditsTitle      = "Poděkování",
        CreditsContent    = "Vytvořeno Rival960 s pomocí AI\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — První Vydání",
        SilentAim         = "Tichý Zaměřovač",
        AutoFire          = "Automatická Střelba",
        AutoFireDelay     = "Zpoždění auto střelby (s)",
        KillAura          = "Kill Aura",
        KillAuraDistance  = "Vzdálenost Kill Aura",
        MaxZombieDistance = "Max vzdálenost zombie",
        FlyToggle         = "Létání",
        FlySpeed          = "Rychlost letu",
        NoClip            = "NoClip",
        WalkSpeed         = "Rychlost chůze",
        InfJump           = "Nekonečný Skok",
        AntiAFK           = "Anti-AFK",
        Fullbright        = "Plný jas",
        LanguageSelect    = "Jazyk",
        LangNote          = "Změna jazyka vyžaduje restartování",
    },
    DA = {
        WindowTitle       = "Tower of Zombies Hub",
        WindowSubtitle    = "af Rival960",
        TabHome           = "Hjem",
        TabCombat         = "Kamp",
        TabMovement       = "Bevægelse",
        TabTools          = "Værktøjer",
        CreditsTitle      = "Anerkendelser",
        CreditsContent    = "Oprettet af Rival960 med hjælp fra AI\nGitHub: Rival99900 | Discord: rival960 | YouTube: rival9607\nv1.0.0 — Første Udgivelse",
        SilentAim         = "Stille Sigte",
        AutoFire          = "Automatisk Ild",
        AutoFireDelay     = "Auto Ild Forsinkelse (s)",
        KillAura          = "Kill Aura",
        KillAuraDistance  = "Kill Aura Afstand",
        MaxZombieDistance = "Maks Zombie Afstand",
        FlyToggle         = "Fly",
        FlySpeed          = "Flyvehastighed",
        NoClip            = "NoClip",
        WalkSpeed         = "Gåhastighed",
        InfJump           = "Uendeligt Hop",
        AntiAFK           = "Anti-AFK",
        Fullbright        = "Fuld Lysstyrke",
        LanguageSelect    = "Sprog",
        LangNote          = "Sprogændring kræver genstart",
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
    SilentAim         = false,
    AutoFire          = false,
    AutoFireDelay     = 0.3,
    KillAura          = false,
    KillAuraDistance  = 150,
    MaxZombieDistance = 300,
    Fly               = false,
    FlySpeed          = 60,
    NoClip            = false,
    WalkSpeed         = 16,
    InfJump           = false,
    AntiAFK           = false,
    Fullbright        = false,
}

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
-- Helper: closest zombie within distance
-- ================================================================
local function getClosestZombie(maxDist)
    local char = LocalPlayer.Character
    if not char then return nil, nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, nil end

    local best, bestPart, bestDist = nil, nil, maxDist
    local zombieFolder = workspace:FindFirstChild("ActiveZombies")
    if not zombieFolder then return nil, nil end

    for _, zombie in ipairs(zombieFolder:GetChildren()) do
        local hum = zombie:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            local zhrp = zombie:FindFirstChild("HumanoidRootPart")
            if zhrp then
                local dist = (zhrp.Position - hrp.Position).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    best     = zombie
                    bestPart = zombie:FindFirstChild("HeadHitbox")
                        or zombie:FindFirstChild("Head")
                        or zhrp
                end
            end
        end
    end
    return best, bestPart
end

-- ================================================================
-- Helper: fire at target part — confirmed remote structure
-- normalVec = (rayOrigin - hitPos).Unit  (pointing FROM target TO exit)
-- ================================================================
local function fireSilentShot(weaponName, targetPart)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild(weaponName) then return end
    local exitPart = char[weaponName]:FindFirstChild("Exit")
    if not exitPart then return end
    local rayOrigin = exitPart.WorldPosition
    local hitPos    = targetPart.Position
    local normalVec = (rayOrigin - hitPos).Unit
    pcall(function()
        local FireEvent = ReplicatedStorage.Events.Actions.Fire
        FireEvent:FireServer(
            weaponName,
            { { targetPart, hitPos, normalVec } },
            { { weaponName, rayOrigin, hitPos, hitPos, true, targetPart, false, false, "Default", exitPart } }
        )
    end)
end

-- Wrapper used by Auto Fire and Kill Aura (no weaponName arg needed)
local function doFire(targetPart)
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    fireSilentShot(tool.Name, targetPart)
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

-- Silent Aim
CombatTab:CreateToggle({
    Name         = T("SilentAim"),
    CurrentValue = false,
    Callback     = function(val) Settings.SilentAim = val end,
})

-- Auto Fire
CombatTab:CreateToggle({
    Name         = T("AutoFire"),
    CurrentValue = false,
    Callback     = function(val) Settings.AutoFire = val end,
})

CombatTab:CreateSlider({
    Name         = T("AutoFireDelay"),
    Range        = {0.1, 2},
    Increment    = 0.1,
    CurrentValue = 0.3,
    Callback     = function(val) Settings.AutoFireDelay = val end,
})

CombatTab:CreateSlider({
    Name         = T("MaxZombieDistance"),
    Range        = {50, 500},
    Increment    = 10,
    CurrentValue = 300,
    Callback     = function(val) Settings.MaxZombieDistance = val end,
})

-- Kill Aura
CombatTab:CreateToggle({
    Name         = T("KillAura"),
    CurrentValue = false,
    Callback     = function(val) Settings.KillAura = val end,
})

CombatTab:CreateSlider({
    Name         = T("KillAuraDistance"),
    Range        = {50, 500},
    Increment    = 10,
    CurrentValue = 150,
    Callback     = function(val) Settings.KillAuraDistance = val end,
})

-- ───── Tab 3: Movement ─────
local MovementTab = Window:CreateTab(T("TabMovement"), 4483362458)

-- Fly
-- BodyVelocity/BodyGyro are created lazily inside RenderStepped the first
-- time Fly is enabled, so the toggle callback never touches Character directly.
local flyBodyVel, flyBodyGyro, flyRenderConn

local function destroyFlyObjects()
    if flyBodyVel  then pcall(function() flyBodyVel:Destroy()  end) flyBodyVel  = nil end
    if flyBodyGyro then pcall(function() flyBodyGyro:Destroy() end) flyBodyGyro = nil end
end

local function stopFly()
    if flyRenderConn then flyRenderConn:Disconnect() flyRenderConn = nil end
    destroyFlyObjects()
end

-- Mobile up/down overlay: 60×60, bottom-center, visible only when Fly ON + touch
local flyGui = nil
local function createFlyGui()
    if not UserInputService.TouchEnabled then return end
    if flyGui then return end
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end

    flyGui = Instance.new("ScreenGui")
    flyGui.Name           = "TozFlyOverlay"
    flyGui.ResetOnSpawn   = false
    flyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    flyGui.Parent         = playerGui

    local BTN_SIZE = 60
    local GAP      = 8
    -- Centre the pair: total width = 2*60 + gap = 128, offset from centre = -64
    local function makeBtn(text, xOffset)
        local btn = Instance.new("TextButton")
        btn.Size                   = UDim2.new(0, BTN_SIZE, 0, BTN_SIZE)
        btn.Position               = UDim2.new(0.5, xOffset, 1, -(BTN_SIZE + 20))
        btn.AnchorPoint            = Vector2.new(0, 0)
        btn.BackgroundColor3       = Color3.fromRGB(40, 40, 40)
        btn.BackgroundTransparency = 0.3
        btn.TextColor3             = Color3.new(1, 1, 1)
        btn.Text                   = text
        btn.TextScaled             = true
        btn.Font                   = Enum.Font.GothamBold
        btn.Parent                 = flyGui
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent       = btn
        return btn
    end

    -- ▲ left of centre, ▼ right of centre
    local upBtn   = makeBtn("▲", -(BTN_SIZE + GAP / 2))
    local downBtn = makeBtn("▼",   GAP / 2)

    local upHeld, downHeld = false, false

    upBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then upHeld = true end
    end)
    upBtn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then upHeld = false end
    end)
    downBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then downHeld = true end
    end)
    downBtn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then downHeld = false end
    end)

    flyGui._upHeld   = function() return upHeld   end
    flyGui._downHeld = function() return downHeld end
end

local function destroyFlyGui()
    if flyGui then pcall(function() flyGui:Destroy() end) flyGui = nil end
end

MovementTab:CreateToggle({
    Name         = T("FlyToggle"),
    CurrentValue = false,
    Callback     = function(val)
        Settings.Fly = val
        if val then
            -- Start the RenderStepped loop; BodyVelocity/BodyGyro created lazily inside
            if not flyRenderConn then
                flyRenderConn = RunService.RenderStepped:Connect(function()
                    if not Settings.Fly then
                        stopFly()
                        return
                    end

                    local char = LocalPlayer.Character
                    if not char then return end
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end

                    -- Lazy creation: build physics objects the first time we have an HRP
                    if not flyBodyVel or not flyBodyVel.Parent then
                        destroyFlyObjects()
                        flyBodyVel            = Instance.new("BodyVelocity")
                        flyBodyVel.Velocity   = Vector3.zero
                        flyBodyVel.MaxForce   = Vector3.new(1e5, 1e5, 1e5)
                        flyBodyVel.Parent     = hrp
                    end
                    if not flyBodyGyro or not flyBodyGyro.Parent then
                        flyBodyGyro           = Instance.new("BodyGyro")
                        flyBodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
                        flyBodyGyro.D         = 100
                        flyBodyGyro.CFrame    = hrp.CFrame
                        flyBodyGyro.Parent    = hrp
                    end

                    local cam = workspace.CurrentCamera
                    local dir = Vector3.zero

                    -- PC: WASD + Space/LeftShift
                    if UserInputService:IsKeyDown(Enum.KeyCode.W)         then dir = dir + cam.CFrame.LookVector  end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S)         then dir = dir - cam.CFrame.LookVector  end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A)         then dir = dir - cam.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D)         then dir = dir + cam.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then dir = dir + Vector3.new(0,  1, 0)  end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir + Vector3.new(0, -1, 0)  end

                    -- Mobile: thumb-stick direction + overlay buttons
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.MoveDirection.Magnitude > 0 then
                        dir = dir + hum.MoveDirection
                    end
                    if flyGui then
                        if flyGui._upHeld   and flyGui._upHeld()   then dir = dir + Vector3.new(0,  1, 0) end
                        if flyGui._downHeld and flyGui._downHeld()  then dir = dir + Vector3.new(0, -1, 0) end
                    end

                    flyBodyVel.Velocity = dir.Magnitude > 0 and dir.Unit * Settings.FlySpeed or Vector3.zero
                    flyBodyGyro.CFrame  = cam.CFrame
                end)
            end
            createFlyGui()
        else
            stopFly()
            destroyFlyGui()
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
                end
            end)
        end
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
                        local char = LocalPlayer.Character
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
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = val end
            end
        end)
    end,
})

-- Infinite Jump (replaces JumpPower — JumpPower alone doesn't work in this game)
MovementTab:CreateToggle({
    Name         = T("InfJump"),
    CurrentValue = false,
    Callback     = function(val)
        Settings.InfJump = val
    end,
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

-- Anti-AFK (moved from Auto Actions)
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
                            local char = LocalPlayer.Character
                            if char then
                                local hrp = char:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(0.01), 0)
                                end
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

-- Silent Aim: hook Tool.Activated, disconnect when tool is unequipped
local activatedConn = nil

local function hookChar(char)
    local function connectTool(tool)
        if activatedConn then activatedConn:Disconnect() activatedConn = nil end
        activatedConn = tool.Activated:Connect(function()
            if not Settings.SilentAim then return end
            local _, targetPart = getClosestZombie(Settings.MaxZombieDistance)
            if targetPart then
                pcall(fireSilentShot, tool.Name, targetPart)
            end
        end)
    end

    -- Hook any tool already in the character
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Tool") then connectTool(obj) end
    end

    char.ChildAdded:Connect(function(obj)
        if obj:IsA("Tool") then connectTool(obj) end
    end)
    char.ChildRemoved:Connect(function(obj)
        if obj:IsA("Tool") then
            if activatedConn then activatedConn:Disconnect() activatedConn = nil end
        end
    end)
end

pcall(function()
    if LocalPlayer.Character then hookChar(LocalPlayer.Character) end
end)
LocalPlayer.CharacterAdded:Connect(function(char) hookChar(char) end)

-- Infinite Jump: JumpRequest fires on every jump attempt
UserInputService.JumpRequest:Connect(function()
    if not Settings.InfJump then return end
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)
end)

-- Auto Fire: Heartbeat loop, respects AutoFireDelay
local autoFireTimer = 0
RunService.Heartbeat:Connect(function(dt)
    if Settings.AutoFire then
        autoFireTimer = autoFireTimer + dt
        if autoFireTimer >= Settings.AutoFireDelay then
            autoFireTimer = 0
            -- Note: effectiveness depends on server-side hit detection and weapon fire rate.
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                if not char:FindFirstChildOfClass("Tool") then return end
                local _, targetPart = getClosestZombie(Settings.MaxZombieDistance)
                if targetPart then
                    doFire(targetPart)
                end
            end)
        end
    else
        autoFireTimer = 0
    end
end)

-- Kill Aura: batched, fires at every zombie within KillAuraDistance simultaneously
task.spawn(function()
    while true do
        if Settings.KillAura then
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                local tool = char:FindFirstChildOfClass("Tool")
                if not tool then return end
                local exit = tool:FindFirstChild("Exit")
                if not exit then return end

                local zombieFolder = workspace:FindFirstChild("ActiveZombies")
                if not zombieFolder then return end

                local hitTable   = {}
                local extraTable = {}

                for _, zombie in ipairs(zombieFolder:GetChildren()) do
                    local hum = zombie:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        local zhrp = zombie:FindFirstChild("HumanoidRootPart")
                        if zhrp then
                            local dist = (zhrp.Position - hrp.Position).Magnitude
                            if dist <= Settings.KillAuraDistance then
                                local targetPart = zombie:FindFirstChild("ChestHitbox")
                                    or zombie:FindFirstChild("HeadHitbox")
                                    or zombie:FindFirstChild("Head")
                                    or zhrp
                                local hitPos = targetPart.Position
                                local normal = Vector3.new(0, 0, 0)
                                table.insert(hitTable, { targetPart, hitPos, normal })
                                table.insert(extraTable, {
                                    tool.Name,
                                    exit.WorldPosition,
                                    hitPos,
                                    hitPos,
                                    true,
                                    targetPart,
                                    false,
                                    false,
                                    "Default",
                                    exit,
                                })
                            end
                        end
                    end
                end

                if #hitTable > 0 then
                    pcall(function()
                        ReplicatedStorage.Events.Actions.Fire:FireServer(tool.Name, hitTable, extraTable)
                    end)
                end
            end)
        end
        task.wait()
    end
end)

-- Listen for incoming game events (display only — no auto-load notification)
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

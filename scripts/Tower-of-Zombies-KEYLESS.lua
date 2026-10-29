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
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- ================================================================
-- Language System (21 languages)
-- ================================================================
local CurrentLang = "EN"

local Translations = {
    EN = {
        WindowTitle     = "Tower of Zombies Hub",
        WindowSubtitle  = "by Rival960",
        TabHome         = "Home",
        TabCombat       = "Combat",
        TabMovement     = "Movement",
        TabAutoActions  = "Auto Actions",
        TabTools        = "Tools & Visuals",
        -- Home
        HomeWelcome     = "Welcome to Tower of Zombies Hub!",
        HomeVersion     = "Version: v1.0.0 — First Release",
        HomeCredits     = "Created by Rival960 with the help of AI",
        HomeGitHub      = "GitHub: Rival99900",
        HomeDiscord     = "Discord: rival960",
        HomeYouTube     = "YouTube: rival9607",
        HomeStatus      = "Status: untested in-game",
        -- Combat
        SilentAim       = "Silent Aim",
        AutoFire        = "Auto Fire",
        MaxZombieDistance = "Max Zombie Distance",
        -- Movement
        FlyToggle       = "Fly",
        FlySpeed        = "Fly Speed",
        NoClip          = "NoClip",
        WalkSpeed       = "Walk Speed",
        JumpPower       = "Jump Power",
        -- Auto Actions
        AutoRollBtn     = "Roll Wheel Once",
        AutoRollToggle  = "Auto Roll (every 3s)",
        AutoJoinBtn     = "Auto Join Lobby",
        AntiAFK         = "Anti-AFK",
        -- Tools
        Fullbright      = "Fullbright",
        LanguageSelect  = "Language",
        LangNote        = "Language change requires re-execution",
        -- Notifications
        NotifRollTitle  = "Wheel Result",
        NotifRollFail   = "Roll failed — try again",
        NotifJoinOk     = "Joining lobby...",
        NotifJoinFail   = "Attempted join — verify in game",
    },
    FR = {
        WindowTitle     = "Tower of Zombies Hub",
        WindowSubtitle  = "par Rival960",
        TabHome         = "Accueil",
        TabCombat       = "Combat",
        TabMovement     = "Déplacement",
        TabAutoActions  = "Actions Auto",
        TabTools        = "Outils & Visuels",
        HomeWelcome     = "Bienvenue dans Tower of Zombies Hub !",
        HomeVersion     = "Version : v1.0.0 — Première Release",
        HomeCredits     = "Créé par Rival960 avec l'aide de l'IA",
        HomeGitHub      = "GitHub : Rival99900",
        HomeDiscord     = "Discord : rival960",
        HomeYouTube     = "YouTube : rival9607",
        HomeStatus      = "Statut : non testé en jeu",
        SilentAim       = "Tir Silencieux",
        AutoFire        = "Tir Automatique",
        MaxZombieDistance = "Distance Max Zombie",
        FlyToggle       = "Vol",
        FlySpeed        = "Vitesse de Vol",
        NoClip          = "NoClip",
        WalkSpeed       = "Vitesse de Marche",
        JumpPower       = "Puissance de Saut",
        AutoRollBtn     = "Lancer la Roue",
        AutoRollToggle  = "Roue Auto (3s)",
        AutoJoinBtn     = "Rejoindre Lobby Auto",
        AntiAFK         = "Anti-AFK",
        Fullbright      = "Luminosité Max",
        LanguageSelect  = "Langue",
        LangNote        = "Le changement de langue nécessite une ré-exécution",
        NotifRollTitle  = "Résultat de la Roue",
        NotifRollFail   = "Echec du lancer — réessayez",
        NotifJoinOk     = "Connexion au lobby...",
        NotifJoinFail   = "Tentative de connexion — vérifiez en jeu",
    },
    DE = {
        WindowTitle     = "Tower of Zombies Hub",
        WindowSubtitle  = "von Rival960",
        TabHome         = "Start",
        TabCombat       = "Kampf",
        TabMovement     = "Bewegung",
        TabAutoActions  = "Auto-Aktionen",
        TabTools        = "Tools & Visuals",
        HomeWelcome     = "Willkommen im Tower of Zombies Hub!",
        HomeVersion     = "Version: v1.0.0 — Erstveröffentlichung",
        HomeCredits     = "Erstellt von Rival960 mit KI-Hilfe",
        HomeGitHub      = "GitHub: Rival99900",
        HomeDiscord     = "Discord: rival960",
        HomeYouTube     = "YouTube: rival9607",
        HomeStatus      = "Status: nicht im Spiel getestet",
        SilentAim       = "Silent Aim",
        AutoFire        = "Auto-Feuer",
        MaxZombieDistance = "Max Zombie-Distanz",
        FlyToggle       = "Fliegen",
        FlySpeed        = "Fluggeschwindigkeit",
        NoClip          = "NoClip",
        WalkSpeed       = "Laufgeschwindigkeit",
        JumpPower       = "Sprungkraft",
        AutoRollBtn     = "Rad drehen",
        AutoRollToggle  = "Auto-Rad (3s)",
        AutoJoinBtn     = "Lobby auto beitreten",
        AntiAFK         = "Anti-AFK",
        Fullbright      = "Vollhelligkeit",
        LanguageSelect  = "Sprache",
        LangNote        = "Sprachänderung erfordert Neuausführung",
        NotifRollTitle  = "Rad-Ergebnis",
        NotifRollFail   = "Dreh fehlgeschlagen — erneut versuchen",
        NotifJoinOk     = "Lobby wird beigetreten...",
        NotifJoinFail   = "Beitrittsversuch — im Spiel prüfen",
    },
    ES = {
        WindowTitle     = "Tower of Zombies Hub",
        WindowSubtitle  = "por Rival960",
        TabHome         = "Inicio",
        TabCombat       = "Combate",
        TabMovement     = "Movimiento",
        TabAutoActions  = "Acciones Auto",
        TabTools        = "Herramientas",
        HomeWelcome     = "¡Bienvenido al Tower of Zombies Hub!",
        HomeVersion     = "Versión: v1.0.0 — Primera Versión",
        HomeCredits     = "Creado por Rival960 con ayuda de IA",
        HomeGitHub      = "GitHub: Rival99900",
        HomeDiscord     = "Discord: rival960",
        HomeYouTube     = "YouTube: rival9607",
        HomeStatus      = "Estado: no probado en el juego",
        SilentAim       = "Apuntado Silencioso",
        AutoFire        = "Disparo Automático",
        MaxZombieDistance = "Distancia Máx Zombie",
        FlyToggle       = "Volar",
        FlySpeed        = "Velocidad de Vuelo",
        NoClip          = "NoClip",
        WalkSpeed       = "Velocidad de Caminar",
        JumpPower       = "Potencia de Salto",
        AutoRollBtn     = "Girar la Rueda",
        AutoRollToggle  = "Rueda Auto (3s)",
        AutoJoinBtn     = "Unirse a Lobby Auto",
        AntiAFK         = "Anti-AFK",
        Fullbright      = "Brillo Total",
        LanguageSelect  = "Idioma",
        LangNote        = "El cambio de idioma requiere re-ejecución",
        NotifRollTitle  = "Resultado de la Rueda",
        NotifRollFail   = "Giro fallido — intenta de nuevo",
        NotifJoinOk     = "Uniéndose al lobby...",
        NotifJoinFail   = "Intento de unión — verifica en el juego",
    },
    PT = {
        WindowTitle     = "Tower of Zombies Hub",
        WindowSubtitle  = "por Rival960",
        TabHome         = "Início",
        TabCombat       = "Combate",
        TabMovement     = "Movimento",
        TabAutoActions  = "Ações Auto",
        TabTools        = "Ferramentas",
        HomeWelcome     = "Bem-vindo ao Tower of Zombies Hub!",
        HomeVersion     = "Versão: v1.0.0 — Primeiro Lançamento",
        HomeCredits     = "Criado por Rival960 com ajuda de IA",
        HomeGitHub      = "GitHub: Rival99900",
        HomeDiscord     = "Discord: rival960",
        HomeYouTube     = "YouTube: rival9607",
        HomeStatus      = "Status: não testado no jogo",
        SilentAim       = "Mira Silenciosa",
        AutoFire        = "Disparo Automático",
        MaxZombieDistance = "Distância Máx Zumbi",
        FlyToggle       = "Voar",
        FlySpeed        = "Velocidade de Voo",
        NoClip          = "NoClip",
        WalkSpeed       = "Velocidade de Caminhada",
        JumpPower       = "Força de Pulo",
        AutoRollBtn     = "Girar a Roda",
        AutoRollToggle  = "Roda Auto (3s)",
        AutoJoinBtn     = "Entrar Lobby Auto",
        AntiAFK         = "Anti-AFK",
        Fullbright      = "Brilho Total",
        LanguageSelect  = "Idioma",
        LangNote        = "Mudança de idioma requer re-execução",
        NotifRollTitle  = "Resultado da Roda",
        NotifRollFail   = "Giro falhou — tente novamente",
        NotifJoinOk     = "Entrando no lobby...",
        NotifJoinFail   = "Tentativa de entrada — verifique no jogo",
    },
    RU = {
        WindowTitle     = "Tower of Zombies Hub",
        WindowSubtitle  = "от Rival960",
        TabHome         = "Главная",
        TabCombat       = "Бой",
        TabMovement     = "Движение",
        TabAutoActions  = "Авто действия",
        TabTools        = "Инструменты",
        HomeWelcome     = "Добро пожаловать в Tower of Zombies Hub!",
        HomeVersion     = "Версия: v1.0.0 — Первый Выпуск",
        HomeCredits     = "Создано Rival960 с помощью ИИ",
        HomeGitHub      = "GitHub: Rival99900",
        HomeDiscord     = "Discord: rival960",
        HomeYouTube     = "YouTube: rival9607",
        HomeStatus      = "Статус: не проверено в игре",
        SilentAim       = "Тихий Прицел",
        AutoFire        = "Авто Огонь",
        MaxZombieDistance = "Макс дист. зомби",
        FlyToggle       = "Полёт",
        FlySpeed        = "Скорость полёта",
        NoClip          = "NoClip",
        WalkSpeed       = "Скорость ходьбы",
        JumpPower       = "Сила прыжка",
        AutoRollBtn     = "Крутить колесо",
        AutoRollToggle  = "Авто колесо (3с)",
        AutoJoinBtn     = "Войти в лобби авто",
        AntiAFK         = "Анти-АФК",
        Fullbright      = "Полная яркость",
        LanguageSelect  = "Язык",
        LangNote        = "Смена языка требует повторного запуска",
        NotifRollTitle  = "Результат колеса",
        NotifRollFail   = "Прокрутка не удалась — попробуйте снова",
        NotifJoinOk     = "Вход в лобби...",
        NotifJoinFail   = "Попытка входа — проверьте в игре",
    },
    IT = {
        WindowTitle     = "Tower of Zombies Hub",
        WindowSubtitle  = "di Rival960",
        TabHome         = "Home",
        TabCombat       = "Combattimento",
        TabMovement     = "Movimento",
        TabAutoActions  = "Azioni Auto",
        TabTools        = "Strumenti",
        HomeWelcome     = "Benvenuto nel Tower of Zombies Hub!",
        HomeVersion     = "Versione: v1.0.0 — Prima Release",
        HomeCredits     = "Creato da Rival960 con l'aiuto dell'IA",
        HomeGitHub      = "GitHub: Rival99900",
        HomeDiscord     = "Discord: rival960",
        HomeYouTube     = "YouTube: rival9607",
        HomeStatus      = "Stato: non testato in gioco",
        SilentAim       = "Mira Silenziosa",
        AutoFire        = "Fuoco Automatico",
        MaxZombieDistance = "Distanza Max Zombie",
        FlyToggle       = "Volo",
        FlySpeed        = "Velocità di Volo",
        NoClip          = "NoClip",
        WalkSpeed       = "Velocità di Camminata",
        JumpPower       = "Potenza di Salto",
        AutoRollBtn     = "Gira la Ruota",
        AutoRollToggle  = "Ruota Auto (3s)",
        AutoJoinBtn     = "Unisciti Lobby Auto",
        AntiAFK         = "Anti-AFK",
        Fullbright      = "Piena Luminosità",
        LanguageSelect  = "Lingua",
        LangNote        = "Il cambio lingua richiede una ri-esecuzione",
        NotifRollTitle  = "Risultato della Ruota",
        NotifRollFail   = "Giro fallito — riprova",
        NotifJoinOk     = "Unendosi alla lobby...",
        NotifJoinFail   = "Tentativo di unione — controlla in gioco",
    },
    NL = {
        WindowTitle     = "Tower of Zombies Hub",
        WindowSubtitle  = "door Rival960",
        TabHome         = "Start",
        TabCombat       = "Gevecht",
        TabMovement     = "Beweging",
        TabAutoActions  = "Auto Acties",
        TabTools        = "Tools & Visuals",
        HomeWelcome     = "Welkom bij Tower of Zombies Hub!",
        HomeVersion     = "Versie: v1.0.0 — Eerste Release",
        HomeCredits     = "Gemaakt door Rival960 met AI-hulp",
        HomeGitHub      = "GitHub: Rival99900",
        HomeDiscord     = "Discord: rival960",
        HomeYouTube     = "YouTube: rival9607",
        HomeStatus      = "Status: niet getest in het spel",
        SilentAim       = "Silent Aim",
        AutoFire        = "Automatisch Vuren",
        MaxZombieDistance = "Max Zombie Afstand",
        FlyToggle       = "Vliegen",
        FlySpeed        = "Vliegsnelheid",
        NoClip          = "NoClip",
        WalkSpeed       = "Loopsnelheid",
        JumpPower       = "Sprongkracht",
        AutoRollBtn     = "Wiel Draaien",
        AutoRollToggle  = "Auto Wiel (3s)",
        AutoJoinBtn     = "Lobby Auto Joinen",
        AntiAFK         = "Anti-AFK",
        Fullbright      = "Maximale Helderheid",
        LanguageSelect  = "Taal",
        LangNote        = "Taalwijziging vereist heruitvoering",
        NotifRollTitle  = "Wielresultaat",
        NotifRollFail   = "Gooien mislukt — probeer opnieuw",
        NotifJoinOk     = "Lobby betreden...",
        NotifJoinFail   = "Poging gedaan — controleer in het spel",
    },
    PL = {
        WindowTitle     = "Tower of Zombies Hub",
        WindowSubtitle  = "przez Rival960",
        TabHome         = "Strona główna",
        TabCombat       = "Walka",
        TabMovement     = "Ruch",
        TabAutoActions  = "Auto Akcje",
        TabTools        = "Narzędzia",
        HomeWelcome     = "Witaj w Tower of Zombies Hub!",
        HomeVersion     = "Wersja: v1.0.0 — Pierwsze Wydanie",
        HomeCredits     = "Stworzone przez Rival960 z pomocą AI",
        HomeGitHub      = "GitHub: Rival99900",
        HomeDiscord     = "Discord: rival960",
        HomeYouTube     = "YouTube: rival9607",
        HomeStatus      = "Status: niezweryfikowane w grze",
        SilentAim       = "Cichy Celownik",
        AutoFire        = "Automatyczny Ogień",
        MaxZombieDistance = "Maks. dystans zombie",
        FlyToggle       = "Latanie",
        FlySpeed        = "Prędkość lotu",
        NoClip          = "NoClip",
        WalkSpeed       = "Prędkość chodu",
        JumpPower       = "Moc skoku",
        AutoRollBtn     = "Zakręć kołem",
        AutoRollToggle  = "Auto koło (3s)",
        AutoJoinBtn     = "Dołącz do lobby auto",
        AntiAFK         = "Anti-AFK",
        Fullbright      = "Pełna jasność",
        LanguageSelect  = "Język",
        LangNote        = "Zmiana języka wymaga ponownego uruchomienia",
        NotifRollTitle  = "Wynik koła",
        NotifRollFail   = "Obrót nieudany — spróbuj ponownie",
        NotifJoinOk     = "Dołączanie do lobby...",
        NotifJoinFail   = "Próba dołączenia — sprawdź w grze",
    },
    ZH = {
        WindowTitle     = "行尸走肉枢纽",
        WindowSubtitle  = "由 Rival960",
        TabHome         = "主页",
        TabCombat       = "战斗",
        TabMovement     = "移动",
        TabAutoActions  = "自动操作",
        TabTools        = "工具与视觉",
        HomeWelcome     = "欢迎来到行尸走肉枢纽！",
        HomeVersion     = "版本: v1.0.0 — 首次发布",
        HomeCredits     = "由 Rival960 借助 AI 创建",
        HomeGitHub      = "GitHub: Rival99900",
        HomeDiscord     = "Discord: rival960",
        HomeYouTube     = "YouTube: rival9607",
        HomeStatus      = "状态: 未在游戏中测试",
        SilentAim       = "静默瞄准",
        AutoFire        = "自动射击",
        MaxZombieDistance = "最大僵尸距离",
        FlyToggle       = "飞行",
        FlySpeed        = "飞行速度",
        NoClip          = "穿墙",
        WalkSpeed       = "行走速度",
        JumpPower       = "跳跃力",
        AutoRollBtn     = "转动轮盘",
        AutoRollToggle  = "自动轮盘(3s)",
        AutoJoinBtn     = "自动加入大厅",
        AntiAFK         = "防离线",
        Fullbright      = "全亮",
        LanguageSelect  = "语言",
        LangNote        = "语言更改需要重新执行",
        NotifRollTitle  = "轮盘结果",
        NotifRollFail   = "轮盘失败 — 请重试",
        NotifJoinOk     = "正在加入大厅...",
        NotifJoinFail   = "尝试加入 — 请在游戏中确认",
    },
    JA = {
        WindowTitle     = "ゾンビタワーハブ",
        WindowSubtitle  = "Rival960 制作",
        TabHome         = "ホーム",
        TabCombat       = "戦闘",
        TabMovement     = "移動",
        TabAutoActions  = "自動操作",
        TabTools        = "ツール",
        HomeWelcome     = "ゾンビタワーハブへようこそ！",
        HomeVersion     = "バージョン: v1.0.0 — 初版",
        HomeCredits     = "Rival960 と AI の協力で作成",
        HomeGitHub      = "GitHub: Rival99900",
        HomeDiscord     = "Discord: rival960",
        HomeYouTube     = "YouTube: rival9607",
        HomeStatus      = "状態: ゲーム未テスト",
        SilentAim       = "サイレントエイム",
        AutoFire        = "オートファイア",
        MaxZombieDistance = "最大ゾンビ距離",
        FlyToggle       = "フライ",
        FlySpeed        = "飛行速度",
        NoClip          = "ノークリップ",
        WalkSpeed       = "歩行速度",
        JumpPower       = "ジャンプ力",
        AutoRollBtn     = "ホイールを回す",
        AutoRollToggle  = "オートロール (3秒)",
        AutoJoinBtn     = "ロビー自動参加",
        AntiAFK         = "アンチAFK",
        Fullbright      = "フルブライト",
        LanguageSelect  = "言語",
        LangNote        = "言語変更は再実行が必要です",
        NotifRollTitle  = "ホイール結果",
        NotifRollFail   = "ロール失敗 — 再試行してください",
        NotifJoinOk     = "ロビーに参加中...",
        NotifJoinFail   = "参加試行 — ゲームで確認してください",
    },
    TR = {
        WindowTitle     = "Tower of Zombies Hub",
        WindowSubtitle  = "Rival960 tarafından",
        TabHome         = "Ana Sayfa",
        TabCombat       = "Savaş",
        TabMovement     = "Hareket",
        TabAutoActions  = "Oto Eylemler",
        TabTools        = "Araçlar",
        HomeWelcome     = "Tower of Zombies Hub'a Hoş Geldiniz!",
        HomeVersion     = "Sürüm: v1.0.0 — İlk Çıkış",
        HomeCredits     = "Rival960 tarafından AI yardımıyla yapılmıştır",
        HomeGitHub      = "GitHub: Rival99900",
        HomeDiscord     = "Discord: rival960",
        HomeYouTube     = "YouTube: rival9607",
        HomeStatus      = "Durum: oyunda test edilmedi",
        SilentAim       = "Sessiz Nişan",
        AutoFire        = "Otomatik Ateş",
        MaxZombieDistance = "Maks Zombi Mesafesi",
        FlyToggle       = "Uçuş",
        FlySpeed        = "Uçuş Hızı",
        NoClip          = "NoClip",
        WalkSpeed       = "Yürüyüş Hızı",
        JumpPower       = "Zıplama Gücü",
        AutoRollBtn     = "Çarkı Döndür",
        AutoRollToggle  = "Oto Çark (3s)",
        AutoJoinBtn     = "Lobiye Oto Katıl",
        AntiAFK         = "Anti-AFK",
        Fullbright      = "Tam Parlaklık",
        LanguageSelect  = "Dil",
        LangNote        = "Dil değişikliği yeniden başlatma gerektirir",
        NotifRollTitle  = "Çark Sonucu",
        NotifRollFail   = "Dönüş başarısız — tekrar dene",
        NotifJoinOk     = "Lobiye katılıyor...",
        NotifJoinFail   = "Katılım denemesi — oyunda kontrol et",
    },
    KO = {
        WindowTitle     = "좀비 타워 허브",
        WindowSubtitle  = "Rival960 제작",
        TabHome         = "홈",
        TabCombat       = "전투",
        TabMovement     = "이동",
        TabAutoActions  = "자동 동작",
        TabTools        = "도구",
        HomeWelcome     = "좀비 타워 허브에 오신 것을 환영합니다!",
        HomeVersion     = "버전: v1.0.0 — 첫 번째 릴리즈",
        HomeCredits     = "Rival960이 AI의 도움으로 제작",
        HomeGitHub      = "GitHub: Rival99900",
        HomeDiscord     = "Discord: rival960",
        HomeYouTube     = "YouTube: rival9607",
        HomeStatus      = "상태: 게임 내 미테스트",
        SilentAim       = "사일런트 에임",
        AutoFire        = "자동 발사",
        MaxZombieDistance = "최대 좀비 거리",
        FlyToggle       = "비행",
        FlySpeed        = "비행 속도",
        NoClip          = "노클립",
        WalkSpeed       = "걷기 속도",
        JumpPower       = "점프력",
        AutoRollBtn     = "휠 돌리기",
        AutoRollToggle  = "자동 휠 (3초)",
        AutoJoinBtn     = "자동 로비 참가",
        AntiAFK         = "Anti-AFK",
        Fullbright      = "전체 밝기",
        LanguageSelect  = "언어",
        LangNote        = "언어 변경은 재실행이 필요합니다",
        NotifRollTitle  = "휠 결과",
        NotifRollFail   = "돌리기 실패 — 다시 시도",
        NotifJoinOk     = "로비 참가 중...",
        NotifJoinFail   = "참가 시도 — 게임에서 확인",
    },
    AR = {
        WindowTitle     = "Tower of Zombies Hub",
        WindowSubtitle  = "بواسطة Rival960",
        TabHome         = "الرئيسية",
        TabCombat       = "القتال",
        TabMovement     = "الحركة",
        TabAutoActions  = "الإجراءات التلقائية",
        TabTools        = "الأدوات",
        HomeWelcome     = "مرحبًا بك في Tower of Zombies Hub!",
        HomeVersion     = "الإصدار: v1.0.0 — الإصدار الأول",
        HomeCredits     = "تم إنشاؤه بواسطة Rival960 بمساعدة الذكاء الاصطناعي",
        HomeGitHub      = "GitHub: Rival99900",
        HomeDiscord     = "Discord: rival960",
        HomeYouTube     = "YouTube: rival9607",
        HomeStatus      = "الحالة: لم يُختبر في اللعبة",
        SilentAim       = "التصويب الصامت",
        AutoFire        = "إطلاق نار تلقائي",
        MaxZombieDistance = "أقصى مسافة للزومبي",
        FlyToggle       = "طيران",
        FlySpeed        = "سرعة الطيران",
        NoClip          = "اختراق الجدران",
        WalkSpeed       = "سرعة المشي",
        JumpPower       = "قوة القفز",
        AutoRollBtn     = "تدوير العجلة",
        AutoRollToggle  = "عجلة تلقائية (3ث)",
        AutoJoinBtn     = "الانضمام للردهة تلقائياً",
        AntiAFK         = "مانع الخمول",
        Fullbright      = "سطوع كامل",
        LanguageSelect  = "اللغة",
        LangNote        = "تغيير اللغة يتطلب إعادة التشغيل",
        NotifRollTitle  = "نتيجة العجلة",
        NotifRollFail   = "فشل الدوران — حاول مجدداً",
        NotifJoinOk     = "جاري الانضمام للردهة...",
        NotifJoinFail   = "محاولة انضمام — تحقق في اللعبة",
    },
    VI = {
        WindowTitle     = "Tower of Zombies Hub",
        WindowSubtitle  = "bởi Rival960",
        TabHome         = "Trang Chủ",
        TabCombat       = "Chiến Đấu",
        TabMovement     = "Di Chuyển",
        TabAutoActions  = "Hành Động Tự Động",
        TabTools        = "Công Cụ",
        HomeWelcome     = "Chào mừng đến Tower of Zombies Hub!",
        HomeVersion     = "Phiên bản: v1.0.0 — Phát Hành Đầu Tiên",
        HomeCredits     = "Tạo bởi Rival960 với sự trợ giúp của AI",
        HomeGitHub      = "GitHub: Rival99900",
        HomeDiscord     = "Discord: rival960",
        HomeYouTube     = "YouTube: rival9607",
        HomeStatus      = "Trạng thái: chưa thử nghiệm trong game",
        SilentAim       = "Silent Aim",
        AutoFire        = "Bắn Tự Động",
        MaxZombieDistance = "Khoảng Cách Zombie Tối Đa",
        FlyToggle       = "Bay",
        FlySpeed        = "Tốc Độ Bay",
        NoClip          = "NoClip",
        WalkSpeed       = "Tốc Độ Đi",
        JumpPower       = "Lực Nhảy",
        AutoRollBtn     = "Quay Bánh Xe",
        AutoRollToggle  = "Tự Động Quay (3s)",
        AutoJoinBtn     = "Tự Động Vào Sảnh",
        AntiAFK         = "Chống AFK",
        Fullbright      = "Độ Sáng Tối Đa",
        LanguageSelect  = "Ngôn Ngữ",
        LangNote        = "Thay đổi ngôn ngữ cần khởi động lại",
        NotifRollTitle  = "Kết Quả Bánh Xe",
        NotifRollFail   = "Quay thất bại — thử lại",
        NotifJoinOk     = "Đang vào sảnh...",
        NotifJoinFail   = "Đã thử vào — kiểm tra trong game",
    },
    SV = {
        WindowTitle     = "Tower of Zombies Hub",
        WindowSubtitle  = "av Rival960",
        TabHome         = "Hem",
        TabCombat       = "Strid",
        TabMovement     = "Rörelse",
        TabAutoActions  = "Auto-åtgärder",
        TabTools        = "Verktyg",
        HomeWelcome     = "Välkommen till Tower of Zombies Hub!",
        HomeVersion     = "Version: v1.0.0 — Första Utgåvan",
        HomeCredits     = "Skapad av Rival960 med hjälp av AI",
        HomeGitHub      = "GitHub: Rival99900",
        HomeDiscord     = "Discord: rival960",
        HomeYouTube     = "YouTube: rival9607",
        HomeStatus      = "Status: otestad i spelet",
        SilentAim       = "Tyst Sikte",
        AutoFire        = "Automatisk Eld",
        MaxZombieDistance = "Max Zombieavstånd",
        FlyToggle       = "Flyg",
        FlySpeed        = "Flyghastighet",
        NoClip          = "NoClip",
        WalkSpeed       = "Gånghastighet",
        JumpPower       = "Hoppkraft",
        AutoRollBtn     = "Snurra Hjulet",
        AutoRollToggle  = "Auto-hjul (3s)",
        AutoJoinBtn     = "Auto Gå Med i Lobby",
        AntiAFK         = "Anti-AFK",
        Fullbright      = "Full Ljusstyrka",
        LanguageSelect  = "Språk",
        LangNote        = "Språkändring kräver omstartning",
        NotifRollTitle  = "Hjulresultat",
        NotifRollFail   = "Snurr misslyckades — försök igen",
        NotifJoinOk     = "Går med i lobbyn...",
        NotifJoinFail   = "Försök gjort — kontrollera i spelet",
    },
    EL = {
        WindowTitle     = "Tower of Zombies Hub",
        WindowSubtitle  = "από Rival960",
        TabHome         = "Αρχική",
        TabCombat       = "Μάχη",
        TabMovement     = "Κίνηση",
        TabAutoActions  = "Αυτόματες Ενέργειες",
        TabTools        = "Εργαλεία",
        HomeWelcome     = "Καλωσορίσατε στο Tower of Zombies Hub!",
        HomeVersion     = "Έκδοση: v1.0.0 — Πρώτη Κυκλοφορία",
        HomeCredits     = "Δημιουργήθηκε από Rival960 με βοήθεια AI",
        HomeGitHub      = "GitHub: Rival99900",
        HomeDiscord     = "Discord: rival960",
        HomeYouTube     = "YouTube: rival9607",
        HomeStatus      = "Κατάσταση: μη δοκιμασμένο στο παιχνίδι",
        SilentAim       = "Σιωπηλό Σημάδι",
        AutoFire        = "Αυτόματα Πυρά",
        MaxZombieDistance = "Μέγ. Απόσταση Ζόμπι",
        FlyToggle       = "Πτήση",
        FlySpeed        = "Ταχύτητα Πτήσης",
        NoClip          = "NoClip",
        WalkSpeed       = "Ταχύτητα Βαδίσματος",
        JumpPower       = "Δύναμη Άλματος",
        AutoRollBtn     = "Γύρισε τον Τροχό",
        AutoRollToggle  = "Αυτόματος Τροχός (3s)",
        AutoJoinBtn     = "Αυτόματη Σύνδεση Lobby",
        AntiAFK         = "Anti-AFK",
        Fullbright      = "Πλήρης Φωτεινότητα",
        LanguageSelect  = "Γλώσσα",
        LangNote        = "Η αλλαγή γλώσσας απαιτεί επανεκτέλεση",
        NotifRollTitle  = "Αποτέλεσμα Τροχού",
        NotifRollFail   = "Αποτυχία περιστροφής — δοκιμάστε ξανά",
        NotifJoinOk     = "Σύνδεση στο lobby...",
        NotifJoinFail   = "Απόπειρα σύνδεσης — ελέγξτε στο παιχνίδι",
    },
    RO = {
        WindowTitle     = "Tower of Zombies Hub",
        WindowSubtitle  = "de Rival960",
        TabHome         = "Acasă",
        TabCombat       = "Luptă",
        TabMovement     = "Mișcare",
        TabAutoActions  = "Acțiuni Auto",
        TabTools        = "Instrumente",
        HomeWelcome     = "Bun venit la Tower of Zombies Hub!",
        HomeVersion     = "Versiune: v1.0.0 — Prima Lansare",
        HomeCredits     = "Creat de Rival960 cu ajutorul AI",
        HomeGitHub      = "GitHub: Rival99900",
        HomeDiscord     = "Discord: rival960",
        HomeYouTube     = "YouTube: rival9607",
        HomeStatus      = "Stare: netestat în joc",
        SilentAim       = "Ochire Silențioasă",
        AutoFire        = "Tragere Automată",
        MaxZombieDistance = "Dist. Maximă Zombie",
        FlyToggle       = "Zbor",
        FlySpeed        = "Viteză Zbor",
        NoClip          = "NoClip",
        WalkSpeed       = "Viteză Mers",
        JumpPower       = "Putere Salt",
        AutoRollBtn     = "Rotește Roata",
        AutoRollToggle  = "Roată Auto (3s)",
        AutoJoinBtn     = "Alătură-te Auto Lobby",
        AntiAFK         = "Anti-AFK",
        Fullbright      = "Luminozitate Maximă",
        LanguageSelect  = "Limbă",
        LangNote        = "Schimbarea limbii necesită re-executare",
        NotifRollTitle  = "Rezultat Roată",
        NotifRollFail   = "Rotire eșuată — încearcă din nou",
        NotifJoinOk     = "Se alătură lobby-ului...",
        NotifJoinFail   = "Tentativă de alăturare — verifică în joc",
    },
    UK = {
        WindowTitle     = "Tower of Zombies Hub",
        WindowSubtitle  = "від Rival960",
        TabHome         = "Головна",
        TabCombat       = "Бій",
        TabMovement     = "Рух",
        TabAutoActions  = "Авто дії",
        TabTools        = "Інструменти",
        HomeWelcome     = "Ласкаво просимо до Tower of Zombies Hub!",
        HomeVersion     = "Версія: v1.0.0 — Перший Випуск",
        HomeCredits     = "Створено Rival960 за допомогою AI",
        HomeGitHub      = "GitHub: Rival99900",
        HomeDiscord     = "Discord: rival960",
        HomeYouTube     = "YouTube: rival9607",
        HomeStatus      = "Статус: не перевірено в грі",
        SilentAim       = "Тихий Приціл",
        AutoFire        = "Авто Вогонь",
        MaxZombieDistance = "Макс відстань зомбі",
        FlyToggle       = "Політ",
        FlySpeed        = "Швидкість польоту",
        NoClip          = "NoClip",
        WalkSpeed       = "Швидкість ходьби",
        JumpPower       = "Сила стрибка",
        AutoRollBtn     = "Покрутити колесо",
        AutoRollToggle  = "Авто колесо (3с)",
        AutoJoinBtn     = "Авто вхід в лобі",
        AntiAFK         = "Анти-АФК",
        Fullbright      = "Повна яскравість",
        LanguageSelect  = "Мова",
        LangNote        = "Зміна мови потребує перезапуску",
        NotifRollTitle  = "Результат колеса",
        NotifRollFail   = "Прокрутка не вдалась — спробуйте знову",
        NotifJoinOk     = "Вхід до лобі...",
        NotifJoinFail   = "Спроба входу — перевірте в грі",
    },
    CS = {
        WindowTitle     = "Tower of Zombies Hub",
        WindowSubtitle  = "od Rival960",
        TabHome         = "Domů",
        TabCombat       = "Boj",
        TabMovement     = "Pohyb",
        TabAutoActions  = "Auto Akce",
        TabTools        = "Nástroje",
        HomeWelcome     = "Vítejte v Tower of Zombies Hub!",
        HomeVersion     = "Verze: v1.0.0 — První Vydání",
        HomeCredits     = "Vytvořeno Rival960 s pomocí AI",
        HomeGitHub      = "GitHub: Rival99900",
        HomeDiscord     = "Discord: rival960",
        HomeYouTube     = "YouTube: rival9607",
        HomeStatus      = "Stav: netestováno ve hře",
        SilentAim       = "Tichý Zaměřovač",
        AutoFire        = "Automatická Střelba",
        MaxZombieDistance = "Max vzdálenost zombie",
        FlyToggle       = "Létání",
        FlySpeed        = "Rychlost letu",
        NoClip          = "NoClip",
        WalkSpeed       = "Rychlost chůze",
        JumpPower       = "Síla skoku",
        AutoRollBtn     = "Točit kolo",
        AutoRollToggle  = "Auto kolo (3s)",
        AutoJoinBtn     = "Auto vstup do lobby",
        AntiAFK         = "Anti-AFK",
        Fullbright      = "Plný jas",
        LanguageSelect  = "Jazyk",
        LangNote        = "Změna jazyka vyžaduje restartování",
        NotifRollTitle  = "Výsledek kola",
        NotifRollFail   = "Otočení selhalo — zkuste znovu",
        NotifJoinOk     = "Vstupuji do lobby...",
        NotifJoinFail   = "Pokus o vstup — ověřte ve hře",
    },
    DA = {
        WindowTitle     = "Tower of Zombies Hub",
        WindowSubtitle  = "af Rival960",
        TabHome         = "Hjem",
        TabCombat       = "Kamp",
        TabMovement     = "Bevægelse",
        TabAutoActions  = "Auto Handlinger",
        TabTools        = "Værktøjer",
        HomeWelcome     = "Velkommen til Tower of Zombies Hub!",
        HomeVersion     = "Version: v1.0.0 — Første Udgivelse",
        HomeCredits     = "Oprettet af Rival960 med hjælp fra AI",
        HomeGitHub      = "GitHub: Rival99900",
        HomeDiscord     = "Discord: rival960",
        HomeYouTube     = "YouTube: rival9607",
        HomeStatus      = "Status: ikke testet i spillet",
        SilentAim       = "Stille Sigte",
        AutoFire        = "Automatisk Ild",
        MaxZombieDistance = "Maks Zombie Afstand",
        FlyToggle       = "Fly",
        FlySpeed        = "Flyvehastighed",
        NoClip          = "NoClip",
        WalkSpeed       = "Gåhastighed",
        JumpPower       = "Springkraft",
        AutoRollBtn     = "Drej Hjulet",
        AutoRollToggle  = "Auto Hjul (3s)",
        AutoJoinBtn     = "Auto Deltag i Lobby",
        AntiAFK         = "Anti-AFK",
        Fullbright      = "Fuld Lysstyrke",
        LanguageSelect  = "Sprog",
        LangNote        = "Sprogændring kræver genstart",
        NotifRollTitle  = "Hjulresultat",
        NotifRollFail   = "Drej mislykkedes — prøv igen",
        NotifJoinOk     = "Tilslutter lobby...",
        NotifJoinFail   = "Forsøg gjort — tjek i spillet",
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
    SilentAim           = false,
    AutoFire            = false,
    MaxZombieDistance   = 300,
    Fly                 = false,
    FlySpeed            = 60,
    NoClip              = false,
    WalkSpeed           = 16,
    JumpPower           = 50,
    AutoRoll            = false,
    AntiAFK             = false,
    Fullbright          = false,
}

-- ================================================================
-- Remote references (confirmed from Cobalt log analysis)
-- ================================================================
local FireEvent    = nil
local RollWheel    = nil
local LobbyEvent   = nil

pcall(function()
    FireEvent  = ReplicatedStorage.Events.Actions.Fire
    RollWheel  = ReplicatedStorage.Events.Wheel.RollWheel
    LobbyEvent = ReplicatedStorage.Events.Gameplay.Lobby
end)

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
-- Helper: closest zombie
-- ================================================================
local function getClosestZombie()
    local char = LocalPlayer.Character
    if not char then return nil, nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, nil end

    local best, bestPart, bestDist = nil, nil, Settings.MaxZombieDistance
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
                    -- Prefer HeadHitbox, fall back through valid parts
                    bestPart = zombie:FindFirstChild("HeadHitbox")
                        or zombie:FindFirstChild("ChestHitbox")
                        or zombie:FindFirstChild("Head")
                        or zhrp
                end
            end
        end
    end
    return best, bestPart
end

-- ================================================================
-- Helper: fire weapon at target part
-- ================================================================
local function fireAtPart(targetPart)
    if not FireEvent then return end
    local char = LocalPlayer.Character
    if not char then return end
    local weapon = char:FindFirstChildOfClass("Tool")
    if not weapon then return end
    local exit = weapon:FindFirstChild("Exit")
    if not exit then return end

    local weaponName = weapon.Name
    local rayOrigin  = exit.WorldPosition
    local hitPos     = targetPart.Position
    local normal     = (rayOrigin - hitPos).Unit

    pcall(function()
        FireEvent:FireServer(
            weaponName,
            { { targetPart, hitPos, normal } },
            {
                {
                    weaponName,
                    rayOrigin,
                    hitPos,
                    hitPos,
                    true,
                    targetPart,
                    false,
                    false,
                    "Default",
                    exit,
                }
            }
        )
    end)
end

-- ================================================================
-- TABS
-- ================================================================

-- ───── Tab 1: Home ─────
local HomeTab = Window:CreateTab(T("TabHome"), 4483362458)
HomeTab:CreateLabel(T("HomeWelcome"))
HomeTab:CreateLabel(T("HomeVersion"))
HomeTab:CreateLabel(T("HomeCredits"))
HomeTab:CreateLabel(T("HomeGitHub"))
HomeTab:CreateLabel(T("HomeDiscord"))
HomeTab:CreateLabel(T("HomeYouTube"))
HomeTab:CreateLabel(T("HomeStatus"))

-- ───── Tab 2: Combat ─────
local CombatTab = Window:CreateTab(T("TabCombat"), 4483362458)

CombatTab:CreateToggle({
    Name         = T("SilentAim"),
    CurrentValue = false,
    Callback     = function(val)
        Settings.SilentAim = val
    end,
})

CombatTab:CreateToggle({
    Name         = T("AutoFire"),
    CurrentValue = false,
    Callback     = function(val)
        Settings.AutoFire = val
    end,
})

CombatTab:CreateSlider({
    Name         = T("MaxZombieDistance"),
    Range        = {50, 500},
    Increment    = 10,
    CurrentValue = 300,
    Callback     = function(val)
        Settings.MaxZombieDistance = val
    end,
})

-- ───── Tab 3: Movement ─────
local MovementTab = Window:CreateTab(T("TabMovement"), 4483362458)

-- Fly
local flyBodyVel, flyBodyGyro
local flyConn

local function destroyFly()
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if flyBodyVel  then flyBodyVel:Destroy()  flyBodyVel  = nil end
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
end

local function setupFly()
    destroyFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    flyBodyVel = Instance.new("BodyVelocity")
    flyBodyVel.Velocity        = Vector3.zero
    flyBodyVel.MaxForce        = Vector3.new(1e5, 1e5, 1e5)
    flyBodyVel.Parent          = hrp

    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque      = Vector3.new(1e5, 1e5, 1e5)
    flyBodyGyro.D              = 100
    flyBodyGyro.CFrame         = hrp.CFrame
    flyBodyGyro.Parent         = hrp

    flyConn = RunService.RenderStepped:Connect(function()
        if not Settings.Fly then destroyFly() return end
        local char2 = LocalPlayer.Character
        if not char2 then return end
        local hrp2 = char2:FindFirstChild("HumanoidRootPart")
        if not hrp2 then return end

        local cam = workspace.CurrentCamera
        local dir = Vector3.zero

        -- PC: WASD + Space/Shift
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            dir = dir + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            dir = dir - Vector3.new(0, 1, 0)
        end

        -- Mobile: MoveDirection
        local hum = char2:FindFirstChildOfClass("Humanoid")
        if hum and hum.MoveDirection.Magnitude > 0 then
            dir = dir + hum.MoveDirection
        end

        if flyBodyVel and flyBodyVel.Parent then
            flyBodyVel.Velocity = dir.Magnitude > 0
                and dir.Unit * Settings.FlySpeed
                or  Vector3.zero
        end
        if flyBodyGyro and flyBodyGyro.Parent then
            flyBodyGyro.CFrame = cam.CFrame
        end
    end)
end

MovementTab:CreateToggle({
    Name         = T("FlyToggle"),
    CurrentValue = false,
    Callback     = function(val)
        Settings.Fly = val
        if val then
            setupFly()
        else
            destroyFly()
            -- Restore humanoid state
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
            end
        end
    end,
})

MovementTab:CreateSlider({
    Name         = T("FlySpeed"),
    Range        = {10, 300},
    Increment    = 5,
    CurrentValue = 60,
    Callback     = function(val)
        Settings.FlySpeed = val
    end,
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
                noClipConn = RunService.RenderStepped:Connect(function()
                    if not Settings.NoClip then
                        noClipConn:Disconnect()
                        noClipConn = nil
                        return
                    end
                    local char = LocalPlayer.Character
                    if not char then return end
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
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
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = val end
        end
    end,
})

-- JumpPower
MovementTab:CreateSlider({
    Name         = T("JumpPower"),
    Range        = {50, 300},
    Increment    = 5,
    CurrentValue = 50,
    Callback     = function(val)
        Settings.JumpPower = val
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = val end
        end
    end,
})

-- ───── Tab 4: Auto Actions ─────
local AutoTab = Window:CreateTab(T("TabAutoActions"), 4483362458)

-- Auto Roll: single button
AutoTab:CreateButton({
    Name     = T("AutoRollBtn"),
    Callback = function()
        if not RollWheel then
            Rayfield:Notify({ Title = T("NotifRollTitle"), Content = T("NotifRollFail"), Duration = 3, Image = 4483362458 })
            return
        end
        pcall(function() RollWheel:FireServer() end)
    end,
})

-- Auto Roll: repeating toggle
local autoRollConn
AutoTab:CreateToggle({
    Name         = T("AutoRollToggle"),
    CurrentValue = false,
    Callback     = function(val)
        Settings.AutoRoll = val
        if val then
            if not autoRollConn then
                autoRollConn = task.spawn(function()
                    while Settings.AutoRoll do
                        if RollWheel then
                            pcall(function() RollWheel:FireServer() end)
                        end
                        task.wait(3)
                    end
                    autoRollConn = nil
                end)
            end
        end
    end,
})

-- Listen for wheel results
pcall(function()
    RollWheel.OnClientEvent:Connect(function(itemName, rarity)
        pcall(function()
            Rayfield:Notify({
                Title   = T("NotifRollTitle"),
                Content = tostring(itemName) .. " — " .. tostring(rarity),
                Duration = 5,
                Image   = 4483362458,
            })
        end)
    end)
end)

-- Auto Join Lobby button
AutoTab:CreateButton({
    Name     = T("AutoJoinBtn"),
    Callback = function()
        -- Limit note: lobby ID must be discovered from the GUI at runtime;
        -- the search below attempts to find it from PlayerGui frames.
        -- Hardcoded fallback "1" may not work on all servers.
        local lobbyId = "1"
        local found   = false

        pcall(function()
            local gui = LocalPlayer:FindFirstChild("PlayerGui")
            if not gui then return end
            for _, desc in ipairs(gui:GetDescendants()) do
                local n = desc.Name:lower()
                if (n:find("lobby") or n:find("join")) and desc:IsA("Frame") then
                    -- Try to extract a numeric ID from child labels
                    for _, child in ipairs(desc:GetDescendants()) do
                        if child:IsA("TextLabel") or child:IsA("TextButton") then
                            local num = child.Text:match("%d+")
                            if num then
                                lobbyId = num
                                found   = true
                                break
                            end
                        end
                    end
                end
                if found then break end
            end
        end)

        if LobbyEvent then
            pcall(function() LobbyEvent:FireServer("Join", lobbyId) end)
            Rayfield:Notify({ Title = T("TabAutoActions"), Content = T("NotifJoinOk") .. " (ID: " .. lobbyId .. ")", Duration = 4, Image = 4483362458 })
        else
            Rayfield:Notify({ Title = T("TabAutoActions"), Content = T("NotifJoinFail"), Duration = 4, Image = 4483362458 })
        end
    end,
})

-- Anti-AFK
local afkConn
AutoTab:CreateToggle({
    Name         = T("AntiAFK"),
    CurrentValue = false,
    Callback     = function(val)
        Settings.AntiAFK = val
        if val then
            if not afkConn then
                afkConn = task.spawn(function()
                    while Settings.AntiAFK do
                        -- Tiny CFrame nudge to prevent server-side AFK kick
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
                    afkConn = nil
                end)
            end
        end
    end,
})

-- ───── Tab 5: Tools & Visuals ─────
local ToolsTab = Window:CreateTab(T("TabTools"), 4483362458)

ToolsTab:CreateToggle({
    Name         = T("Fullbright"),
    CurrentValue = false,
    Callback     = function(val)
        Settings.Fullbright = val
        pcall(function()
            local lighting = game:GetService("Lighting")
            if val then
                lighting.Brightness      = 10
                lighting.GlobalShadows   = false
                lighting.ClockTime       = 14
            else
                lighting.Brightness      = 1
                lighting.GlobalShadows   = true
                lighting.ClockTime       = 14
            end
        end)
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
-- Main Loops
-- ================================================================

-- Silent Aim: hook Tool.Activated
LocalPlayer.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(function(obj)
        if obj:IsA("Tool") then
            obj.Activated:Connect(function()
                if Settings.SilentAim then
                    local _, targetPart = getClosestZombie()
                    if targetPart then
                        pcall(function() fireAtPart(targetPart) end)
                    end
                end
            end)
        end
    end)
end)

-- Also wire existing tool on current character
pcall(function()
    local char = LocalPlayer.Character
    if char then
        char.ChildAdded:Connect(function(obj)
            if obj:IsA("Tool") then
                obj.Activated:Connect(function()
                    if Settings.SilentAim then
                        local _, targetPart = getClosestZombie()
                        if targetPart then
                            pcall(function() fireAtPart(targetPart) end)
                        end
                    end
                end)
            end
        end)
    end
end)

-- Auto Fire loop (every 0.2s via Heartbeat)
-- Note: effectiveness depends on server-side hit detection and weapon fire rate.
local autoFireTimer = 0
RunService.Heartbeat:Connect(function(dt)
    if Settings.AutoFire then
        autoFireTimer = autoFireTimer + dt
        if autoFireTimer >= 0.2 then
            autoFireTimer = 0
            local char = LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Tool") then
                local _, targetPart = getClosestZombie()
                if targetPart then
                    pcall(function() fireAtPart(targetPart) end)
                end
            end
        end
    else
        autoFireTimer = 0
    end
end)

-- Listen for incoming game events (display only)
pcall(function()
    ReplicatedStorage.Events.Communication.Notification.OnClientEvent:Connect(function(msg)
        Rayfield:Notify({ Title = T("WindowTitle"), Content = tostring(msg), Duration = 3, Image = 4483362458 })
    end)
end)

pcall(function()
    ReplicatedStorage.Events.Communication.LavaRising.OnClientEvent:Connect(function()
        Rayfield:Notify({ Title = "⚠️ Lava Rising!", Content = "Lava is rising — climb fast!", Duration = 4, Image = 4483362458 })
    end)
end)

-- ================================================================
-- Startup notification
-- ================================================================
Rayfield:Notify({
    Title    = T("WindowTitle"),
    Content  = T("HomeVersion"),
    Duration = 5,
    Image    = 4483362458,
})

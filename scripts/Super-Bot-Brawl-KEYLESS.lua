--[[
    ================================================================
    Super Bot Brawl Hub — Super Bot Brawl
    Created by Rival960 with the help of Claude
    Version: 1.0.0 | Languages: 21 | Rayfield UI
    ================================================================
    Features:
      - God Mode (MaxHealth + HealthChanged + Dead state block)
      - Auto Farm (auto-attack nearest bot with cooldown)
      - ESP Bots (highlight + HP billboard on all NPCs)
      - Teleport to Nearest Bot
      - Fly (PC: WASD/Space/Shift | Mobile: joystick + on-screen ▲/▼)
      - NoClip (pass through walls — HumanoidRootPart stays collidable)
      - Walk Speed (adjustable)
      - Fullbright (brightness boost, fixed clock)
      - 21-language interface
    ================================================================
--]]

-- ───────────────────────────────────────────────────────────────
-- SERVICES
-- ───────────────────────────────────────────────────────────────
local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace     = game:GetService("Workspace")
local Lighting      = game:GetService("Lighting")

local LocalPlayer   = Players.LocalPlayer

-- ───────────────────────────────────────────────────────────────
-- 21-LANGUAGE SYSTEM
-- ───────────────────────────────────────────────────────────────
local CurrentLang = "EN"

local Translations = {
    EN = {
        WindowTitle     = "Super Bot Brawl Hub",
        TabHome         = "Home",
        TabVision       = "Vision",
        TabMovement     = "Movement",
        TabCombat       = "Combat",
        TabTools        = "Tools",
        ESPBots         = "ESP Bots",
        ESPBotsDesc     = "Highlight nearby bots and show their HP",
        TPNearestBot    = "TP to Nearest Bot",
        TPNearestDesc   = "Teleport in front of the closest bot",
        Fly             = "Fly",
        FlyDesc         = "Toggle flight mode",
        FlySpeed        = "Fly Speed",
        NoClip          = "NoClip",
        NoClipDesc      = "Pass through walls and obstacles",
        WalkSpeed       = "Walk Speed",
        GodMode         = "God Mode",
        GodModeDesc     = "Continuously restore HP — almost indestructible",
        AutoFarm        = "Auto Farm",
        AutoFarmDesc    = "Automatically attack the nearest bot",
        AutoFarmDelay   = "Farm Delay (s)",
        HitboxToggle    = "Expand Hitboxes",
        HitboxDesc      = "Increase bot hitbox size to hit more easily",
        HitboxSize      = "Hitbox Size",
        Fullbright      = "Fullbright",
        FullbrightDesc  = "Raise brightness and disable shadows",
        LangSelect      = "Language",
        CreditsTitle    = "Super Bot Brawl Hub",
        CreditsContent  = "Created by Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — First release",
        Loaded          = "Hub loaded! Fight smarter.",
    },
    FR = {
        WindowTitle     = "Super Bot Brawl Hub",
        TabHome         = "Accueil",
        TabVision       = "Vision",
        TabMovement     = "Mouvement",
        TabCombat       = "Combat",
        TabTools        = "Outils",
        ESPBots         = "ESP Bots",
        ESPBotsDesc     = "Surligner les bots proches et afficher leurs PV",
        TPNearestBot    = "TP au Bot le plus proche",
        TPNearestDesc   = "Se téléporter devant le bot le plus proche",
        Fly             = "Vol",
        FlyDesc         = "Activer le mode vol",
        FlySpeed        = "Vitesse de vol",
        NoClip          = "NoClip",
        NoClipDesc      = "Passer à travers les murs et obstacles",
        WalkSpeed       = "Vitesse de marche",
        GodMode         = "Mode Dieu",
        GodModeDesc     = "Restaure les PV en continu — quasi invincible",
        AutoFarm        = "Auto Farm",
        AutoFarmDesc    = "Attaque automatiquement le bot le plus proche",
        AutoFarmDelay   = "Délai farm (s)",
        HitboxToggle    = "Agrandir les Hitboxes",
        HitboxDesc      = "Agrandir la hitbox des bots pour frapper plus facilement",
        HitboxSize      = "Taille Hitbox",
        Fullbright      = "Luminosité max",
        FullbrightDesc  = "Augmenter la luminosité et désactiver les ombres",
        LangSelect      = "Langue",
        CreditsTitle    = "Super Bot Brawl Hub",
        CreditsContent  = "Créé par Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Première version",
        Loaded          = "Hub chargé ! Combats plus intelligemment.",
    },
    DE = {
        WindowTitle     = "Super Bot Brawl Hub",
        TabHome         = "Start",
        TabVision       = "Sicht",
        TabMovement     = "Bewegung",
        TabCombat       = "Kampf",
        TabTools        = "Werkzeuge",
        ESPBots         = "ESP Bots",
        ESPBotsDesc     = "Nahe Bots hervorheben und HP anzeigen",
        TPNearestBot    = "TP zum nächsten Bot",
        TPNearestDesc   = "Zum nächsten Bot teleportieren",
        Fly             = "Fliegen",
        FlyDesc         = "Flugmodus umschalten",
        FlySpeed        = "Fluggeschwindigkeit",
        NoClip          = "NoClip",
        NoClipDesc      = "Durch Wände und Hindernisse gehen",
        WalkSpeed       = "Laufgeschwindigkeit",
        GodMode         = "Gottmodus",
        GodModeDesc     = "HP kontinuierlich wiederherstellen — fast unverwundbar",
        AutoFarm        = "Auto Farm",
        AutoFarmDesc    = "Greift automatisch den nächsten Bot an",
        AutoFarmDelay   = "Farm-Verzögerung (s)",
        HitboxToggle    = "Hitboxen vergrößern",
        HitboxDesc      = "Bot-Hitboxen vergrößern, um leichter zu treffen",
        HitboxSize      = "Hitbox-Größe",
        Fullbright      = "Vollhell",
        FullbrightDesc  = "Helligkeit erhöhen und Schatten deaktivieren",
        LangSelect      = "Sprache",
        CreditsTitle    = "Super Bot Brawl Hub",
        CreditsContent  = "Erstellt von Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Erste Version",
        Loaded          = "Hub geladen! Kämpfe klüger.",
    },
    ES = {
        WindowTitle     = "Super Bot Brawl Hub",
        TabHome         = "Inicio",
        TabVision       = "Visión",
        TabMovement     = "Movimiento",
        TabCombat       = "Combate",
        TabTools        = "Herramientas",
        ESPBots         = "ESP Bots",
        ESPBotsDesc     = "Resaltar bots cercanos y mostrar su HP",
        TPNearestBot    = "TP al Bot más cercano",
        TPNearestDesc   = "Teletransportarse frente al bot más cercano",
        Fly             = "Volar",
        FlyDesc         = "Activar modo vuelo",
        FlySpeed        = "Velocidad de vuelo",
        NoClip          = "NoClip",
        NoClipDesc      = "Atravesar paredes y obstáculos",
        WalkSpeed       = "Velocidad de marcha",
        GodMode         = "Modo Dios",
        GodModeDesc     = "Restaurar HP continuamente — casi indestructible",
        AutoFarm        = "Auto Farm",
        AutoFarmDesc    = "Ataca automáticamente al bot más cercano",
        AutoFarmDelay   = "Retraso farm (s)",
        HitboxToggle    = "Ampliar Hitboxes",
        HitboxDesc      = "Aumentar el tamaño del hitbox de los bots",
        HitboxSize      = "Tamaño Hitbox",
        Fullbright      = "Brillo máximo",
        FullbrightDesc  = "Aumentar brillo y desactivar sombras",
        LangSelect      = "Idioma",
        CreditsTitle    = "Super Bot Brawl Hub",
        CreditsContent  = "Creado por Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Primera versión",
        Loaded          = "¡Hub cargado! Lucha de forma más inteligente.",
    },
    PT = {
        WindowTitle     = "Super Bot Brawl Hub",
        TabHome         = "Início",
        TabVision       = "Visão",
        TabMovement     = "Movimento",
        TabCombat       = "Combate",
        TabTools        = "Ferramentas",
        ESPBots         = "ESP Bots",
        ESPBotsDesc     = "Destacar bots próximos e mostrar HP",
        TPNearestBot    = "TP para o Bot mais próximo",
        TPNearestDesc   = "Teleportar para o bot mais próximo",
        Fly             = "Voar",
        FlyDesc         = "Ativar modo de voo",
        FlySpeed        = "Velocidade de voo",
        NoClip          = "NoClip",
        NoClipDesc      = "Atravessar paredes e obstáculos",
        WalkSpeed       = "Velocidade de caminhada",
        GodMode         = "Modo Deus",
        GodModeDesc     = "Restaurar HP continuamente — quase indestrutível",
        AutoFarm        = "Auto Farm",
        AutoFarmDesc    = "Ataca automaticamente o bot mais próximo",
        AutoFarmDelay   = "Atraso do farm (s)",
        HitboxToggle    = "Expandir Hitboxes",
        HitboxDesc      = "Aumentar o tamanho da hitbox dos bots",
        HitboxSize      = "Tamanho Hitbox",
        Fullbright      = "Brilho máximo",
        FullbrightDesc  = "Aumentar brilho e desativar sombras",
        LangSelect      = "Idioma",
        CreditsTitle    = "Super Bot Brawl Hub",
        CreditsContent  = "Criado por Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Primeira versão",
        Loaded          = "Hub carregado! Lute de forma mais inteligente.",
    },
    RU = {
        WindowTitle     = "Super Bot Brawl Hub",
        TabHome         = "Главная",
        TabVision       = "Зрение",
        TabMovement     = "Движение",
        TabCombat       = "Бой",
        TabTools        = "Инструменты",
        ESPBots         = "ESP ботов",
        ESPBotsDesc     = "Выделить ближайших ботов и показать их HP",
        TPNearestBot    = "ТП к ближайшему боту",
        TPNearestDesc   = "Телепортироваться к ближайшему боту",
        Fly             = "Полёт",
        FlyDesc         = "Включить режим полёта",
        FlySpeed        = "Скорость полёта",
        NoClip          = "Ноклип",
        NoClipDesc      = "Проходить сквозь стены и препятствия",
        WalkSpeed       = "Скорость ходьбы",
        GodMode         = "Режим Бога",
        GodModeDesc     = "Непрерывно восстанавливать HP — почти неуязвим",
        AutoFarm        = "Авто фарм",
        AutoFarmDesc    = "Автоматически атаковать ближайшего бота",
        AutoFarmDelay   = "Задержка фарма (с)",
        HitboxToggle    = "Расширить хитбоксы",
        HitboxDesc      = "Увеличить хитбокс ботов для лёгкого попадания",
        HitboxSize      = "Размер хитбокса",
        Fullbright      = "Максяркость",
        FullbrightDesc  = "Увеличить яркость и отключить тени",
        LangSelect      = "Язык",
        CreditsTitle    = "Super Bot Brawl Hub",
        CreditsContent  = "Создано Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Первый выпуск",
        Loaded          = "Хаб загружен! Сражайся умнее.",
    },
    IT = {
        WindowTitle     = "Super Bot Brawl Hub",
        TabHome         = "Home",
        TabVision       = "Visione",
        TabMovement     = "Movimento",
        TabCombat       = "Combattimento",
        TabTools        = "Strumenti",
        ESPBots         = "ESP Bot",
        ESPBotsDesc     = "Evidenziare i bot vicini e mostrare i loro HP",
        TPNearestBot    = "TP al Bot più vicino",
        TPNearestDesc   = "Teletrasportarsi davanti al bot più vicino",
        Fly             = "Volare",
        FlyDesc         = "Attivare modalità volo",
        FlySpeed        = "Velocità di volo",
        NoClip          = "NoClip",
        NoClipDesc      = "Attraversare muri e ostacoli",
        WalkSpeed       = "Velocità di camminata",
        GodMode         = "Modalità Dio",
        GodModeDesc     = "Ripristino continuo HP — quasi indistruttibile",
        AutoFarm        = "Auto Farm",
        AutoFarmDesc    = "Attacca automaticamente il bot più vicino",
        AutoFarmDelay   = "Ritardo farm (s)",
        HitboxToggle    = "Espandi Hitbox",
        HitboxDesc      = "Aumenta la hitbox dei bot per colpire più facilmente",
        HitboxSize      = "Dimensione Hitbox",
        Fullbright      = "Luminosità massima",
        FullbrightDesc  = "Aumenta luminosità e disattiva ombre",
        LangSelect      = "Lingua",
        CreditsTitle    = "Super Bot Brawl Hub",
        CreditsContent  = "Creato da Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Prima versione",
        Loaded          = "Hub caricato! Combatti in modo più intelligente.",
    },
    NL = {
        WindowTitle     = "Super Bot Brawl Hub",
        TabHome         = "Start",
        TabVision       = "Zicht",
        TabMovement     = "Beweging",
        TabCombat       = "Gevecht",
        TabTools        = "Hulpmiddelen",
        ESPBots         = "ESP Bots",
        ESPBotsDesc     = "Nabijgelegen bots markeren en HP weergeven",
        TPNearestBot    = "TP naar dichtstbijzijnde Bot",
        TPNearestDesc   = "Teleporteer naar de dichtstbijzijnde bot",
        Fly             = "Vliegen",
        FlyDesc         = "Vliegmodus in-/uitschakelen",
        FlySpeed        = "Vliegsnelheid",
        NoClip          = "NoClip",
        NoClipDesc      = "Door muren en obstakels lopen",
        WalkSpeed       = "Loopsnelheid",
        GodMode         = "Godmodus",
        GodModeDesc     = "HP continu herstellen — bijna onverwoestbaar",
        AutoFarm        = "Auto Farm",
        AutoFarmDesc    = "Valt automatisch de dichtstbijzijnde bot aan",
        AutoFarmDelay   = "Farm vertraging (s)",
        HitboxToggle    = "Hitboxen vergroten",
        HitboxDesc      = "Hitbox van bots vergroten voor gemakkelijker treffen",
        HitboxSize      = "Hitbox grootte",
        Fullbright      = "Maximale helderheid",
        FullbrightDesc  = "Helderheid verhogen en schaduwen uitschakelen",
        LangSelect      = "Taal",
        CreditsTitle    = "Super Bot Brawl Hub",
        CreditsContent  = "Gemaakt door Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Eerste versie",
        Loaded          = "Hub geladen! Vecht slimmer.",
    },
    PL = {
        WindowTitle     = "Super Bot Brawl Hub",
        TabHome         = "Główna",
        TabVision       = "Wzrok",
        TabMovement     = "Ruch",
        TabCombat       = "Walka",
        TabTools        = "Narzędzia",
        ESPBots         = "ESP Boty",
        ESPBotsDesc     = "Podświetl pobliskie boty i pokaż ich HP",
        TPNearestBot    = "TP do najbliższego Bota",
        TPNearestDesc   = "Teleportuj się do najbliższego bota",
        Fly             = "Latanie",
        FlyDesc         = "Włącz tryb lotu",
        FlySpeed        = "Prędkość lotu",
        NoClip          = "NoClip",
        NoClipDesc      = "Przechodzić przez ściany i przeszkody",
        WalkSpeed       = "Prędkość chodzenia",
        GodMode         = "Tryb Boga",
        GodModeDesc     = "Ciągłe przywracanie HP — prawie niezniszczalny",
        AutoFarm        = "Auto Farm",
        AutoFarmDesc    = "Automatycznie atakuje najbliższego bota",
        AutoFarmDelay   = "Opóźnienie farmu (s)",
        HitboxToggle    = "Rozszerz Hitboxy",
        HitboxDesc      = "Zwiększ hitbox botów dla łatwiejszych trafień",
        HitboxSize      = "Rozmiar Hitboxa",
        Fullbright      = "Pełna jasność",
        FullbrightDesc  = "Zwiększ jasność i wyłącz cienie",
        LangSelect      = "Język",
        CreditsTitle    = "Super Bot Brawl Hub",
        CreditsContent  = "Stworzone przez Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Pierwsza wersja",
        Loaded          = "Hub załadowany! Walcz mądrzej.",
    },
    ZH = {
        WindowTitle     = "超级机器人乱斗Hub",
        TabHome         = "主页",
        TabVision       = "视野",
        TabMovement     = "移动",
        TabCombat       = "战斗",
        TabTools        = "工具",
        ESPBots         = "ESP机器人",
        ESPBotsDesc     = "高亮附近机器人并显示HP",
        TPNearestBot    = "传送至最近机器人",
        TPNearestDesc   = "传送到最近的机器人前方",
        Fly             = "飞行",
        FlyDesc         = "切换飞行模式",
        FlySpeed        = "飞行速度",
        NoClip          = "穿墙",
        NoClipDesc      = "穿过墙壁和障碍物",
        WalkSpeed       = "移动速度",
        GodMode         = "无敌模式",
        GodModeDesc     = "持续恢复HP — 几乎无敌",
        AutoFarm        = "自动刷怪",
        AutoFarmDesc    = "自动攻击最近的机器人",
        AutoFarmDelay   = "刷怪延迟（秒）",
        HitboxToggle    = "扩大判定框",
        HitboxDesc      = "扩大机器人的判定框以便更容易命中",
        HitboxSize      = "判定框大小",
        Fullbright      = "全亮",
        FullbrightDesc  = "提高亮度并关闭阴影",
        LangSelect      = "语言",
        CreditsTitle    = "超级机器人乱斗Hub",
        CreditsContent  = "由 Rival960 创建\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — 首次发布",
        Loaded          = "Hub已加载！更智慧地战斗。",
    },
    JA = {
        WindowTitle     = "スーパーボットブロールHub",
        TabHome         = "ホーム",
        TabVision       = "視覚",
        TabMovement     = "移動",
        TabCombat       = "戦闘",
        TabTools        = "ツール",
        ESPBots         = "ESPボット",
        ESPBotsDesc     = "近くのボットをハイライトしてHPを表示",
        TPNearestBot    = "最近のボットにTP",
        TPNearestDesc   = "最も近いボットの前にテレポート",
        Fly             = "飛行",
        FlyDesc         = "飛行モードを切り替える",
        FlySpeed        = "飛行速度",
        NoClip          = "ノークリップ",
        NoClipDesc      = "壁や障害物を通り抜ける",
        WalkSpeed       = "移動速度",
        GodMode         = "神モード",
        GodModeDesc     = "継続的にHPを回復 — ほぼ無敵",
        AutoFarm        = "オートファーム",
        AutoFarmDesc    = "最も近いボットを自動攻撃",
        AutoFarmDelay   = "ファーム遅延（秒）",
        HitboxToggle    = "ヒットボックス拡張",
        HitboxDesc      = "ボットのヒットボックスを拡大して当てやすく",
        HitboxSize      = "ヒットボックスサイズ",
        Fullbright      = "フルブライト",
        FullbrightDesc  = "明るさを上げてシャドウを無効化",
        LangSelect      = "言語",
        CreditsTitle    = "スーパーボットブロールHub",
        CreditsContent  = "Rival960 作\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — 初回リリース",
        Loaded          = "Hub読み込み完了！より賢く戦おう。",
    },
    TR = {
        WindowTitle     = "Super Bot Brawl Hub",
        TabHome         = "Ana Sayfa",
        TabVision       = "Görüş",
        TabMovement     = "Hareket",
        TabCombat       = "Savaş",
        TabTools        = "Araçlar",
        ESPBots         = "ESP Botlar",
        ESPBotsDesc     = "Yakındaki botları vurgula ve HP göster",
        TPNearestBot    = "En Yakın Bota TP",
        TPNearestDesc   = "En yakın botun önüne ışınlan",
        Fly             = "Uçuş",
        FlyDesc         = "Uçuş modunu aç/kapat",
        FlySpeed        = "Uçuş Hızı",
        NoClip          = "NoClip",
        NoClipDesc      = "Duvarlardan ve engellerden geç",
        WalkSpeed       = "Yürüyüş Hızı",
        GodMode         = "Tanrı Modu",
        GodModeDesc     = "HP'yi sürekli yenile — neredeyse yok edilemez",
        AutoFarm        = "Otomatik Farm",
        AutoFarmDesc    = "En yakın botu otomatik saldır",
        AutoFarmDelay   = "Farm gecikmesi (s)",
        HitboxToggle    = "Hitbox Genişlet",
        HitboxDesc      = "Bot hitboxlarını büyüt — daha kolay vur",
        HitboxSize      = "Hitbox Boyutu",
        Fullbright      = "Tam Parlaklık",
        FullbrightDesc  = "Parlaklığı artır ve gölgeleri devre dışı bırak",
        LangSelect      = "Dil",
        CreditsTitle    = "Super Bot Brawl Hub",
        CreditsContent  = "Rival960 tarafından oluşturuldu\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — İlk sürüm",
        Loaded          = "Hub yüklendi! Daha akıllıca savaş.",
    },
    KO = {
        WindowTitle     = "슈퍼 봇 브롤 허브",
        TabHome         = "홈",
        TabVision       = "시야",
        TabMovement     = "이동",
        TabCombat       = "전투",
        TabTools        = "도구",
        ESPBots         = "ESP 봇",
        ESPBotsDesc     = "근처 봇 강조 표시 및 HP 표시",
        TPNearestBot    = "가장 가까운 봇으로 TP",
        TPNearestDesc   = "가장 가까운 봇 앞으로 순간이동",
        Fly             = "비행",
        FlyDesc         = "비행 모드 전환",
        FlySpeed        = "비행 속도",
        NoClip          = "노클립",
        NoClipDesc      = "벽과 장애물을 통과",
        WalkSpeed       = "이동 속도",
        GodMode         = "갓 모드",
        GodModeDesc     = "HP 지속 회복 — 거의 불사",
        AutoFarm        = "자동 파밍",
        AutoFarmDesc    = "가장 가까운 봇을 자동 공격",
        AutoFarmDelay   = "파밍 딜레이(초)",
        HitboxToggle    = "히트박스 확장",
        HitboxDesc      = "봇 히트박스 확대로 더 쉽게 타격",
        HitboxSize      = "히트박스 크기",
        Fullbright      = "풀브라이트",
        FullbrightDesc  = "밝기 증가 및 그림자 비활성화",
        LangSelect      = "언어",
        CreditsTitle    = "슈퍼 봇 브롤 허브",
        CreditsContent  = "Rival960 제작\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — 첫 번째 릴리스",
        Loaded          = "허브 로드 완료! 더 스마트하게 싸우자.",
    },
    AR = {
        WindowTitle     = "سوبر بوت برول هاب",
        TabHome         = "الرئيسية",
        TabVision       = "الرؤية",
        TabMovement     = "الحركة",
        TabCombat       = "القتال",
        TabTools        = "الأدوات",
        ESPBots         = "ESP الروبوتات",
        ESPBotsDesc     = "تمييز الروبوتات القريبة وعرض HP",
        TPNearestBot    = "انتقال إلى أقرب روبوت",
        TPNearestDesc   = "الانتقال أمام أقرب روبوت",
        Fly             = "الطيران",
        FlyDesc         = "تبديل وضع الطيران",
        FlySpeed        = "سرعة الطيران",
        NoClip          = "نوكليب",
        NoClipDesc      = "المرور عبر الجدران والعوائق",
        WalkSpeed       = "سرعة المشي",
        GodMode         = "وضع الإله",
        GodModeDesc     = "استعادة HP بشكل مستمر — شبه لا يُهزم",
        AutoFarm        = "زراعة تلقائية",
        AutoFarmDesc    = "مهاجمة أقرب روبوت تلقائياً",
        AutoFarmDelay   = "تأخير الزراعة (ث)",
        HitboxToggle    = "توسيع Hitbox",
        HitboxDesc      = "تكبير Hitbox الروبوتات للإصابة بسهولة",
        HitboxSize      = "حجم Hitbox",
        Fullbright      = "إضاءة كاملة",
        FullbrightDesc  = "رفع السطوع وتعطيل الظلال",
        LangSelect      = "اللغة",
        CreditsTitle    = "سوبر بوت برول هاب",
        CreditsContent  = "أنشأه Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — الإصدار الأول",
        Loaded          = "تم تحميل الهاب! قاتل بذكاء.",
    },
    VI = {
        WindowTitle     = "Super Bot Brawl Hub",
        TabHome         = "Trang chủ",
        TabVision       = "Tầm nhìn",
        TabMovement     = "Di chuyển",
        TabCombat       = "Chiến đấu",
        TabTools        = "Công cụ",
        ESPBots         = "ESP Bots",
        ESPBotsDesc     = "Làm nổi bật bot gần đó và hiển thị HP",
        TPNearestBot    = "TP đến Bot gần nhất",
        TPNearestDesc   = "Dịch chuyển đến phía trước bot gần nhất",
        Fly             = "Bay",
        FlyDesc         = "Bật/tắt chế độ bay",
        FlySpeed        = "Tốc độ bay",
        NoClip          = "NoClip",
        NoClipDesc      = "Đi xuyên tường và chướng ngại vật",
        WalkSpeed       = "Tốc độ đi bộ",
        GodMode         = "Chế độ Thần",
        GodModeDesc     = "Liên tục hồi HP — gần như bất tử",
        AutoFarm        = "Tự động Farm",
        AutoFarmDesc    = "Tự động tấn công bot gần nhất",
        AutoFarmDelay   = "Độ trễ farm (s)",
        HitboxToggle    = "Mở rộng Hitbox",
        HitboxDesc      = "Tăng kích thước hitbox của bot để dễ trúng hơn",
        HitboxSize      = "Kích thước Hitbox",
        Fullbright      = "Sáng tối đa",
        FullbrightDesc  = "Tăng độ sáng và tắt bóng",
        LangSelect      = "Ngôn ngữ",
        CreditsTitle    = "Super Bot Brawl Hub",
        CreditsContent  = "Tạo bởi Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Phiên bản đầu tiên",
        Loaded          = "Hub đã tải! Chiến đấu thông minh hơn.",
    },
    SV = {
        WindowTitle     = "Super Bot Brawl Hub",
        TabHome         = "Hem",
        TabVision       = "Syn",
        TabMovement     = "Rörelse",
        TabCombat       = "Strid",
        TabTools        = "Verktyg",
        ESPBots         = "ESP Botar",
        ESPBotsDesc     = "Markera närliggande botar och visa deras HP",
        TPNearestBot    = "TP till närmaste Bot",
        TPNearestDesc   = "Teleportera framför närmaste boten",
        Fly             = "Flyg",
        FlyDesc         = "Aktivera flygläge",
        FlySpeed        = "Flyghastighet",
        NoClip          = "NoClip",
        NoClipDesc      = "Gå igenom väggar och hinder",
        WalkSpeed       = "Gånghastighet",
        GodMode         = "Gudläge",
        GodModeDesc     = "Återställ HP kontinuerligt — nästan ounerstörbar",
        AutoFarm        = "Auto Farm",
        AutoFarmDesc    = "Attackera automatiskt närmaste boten",
        AutoFarmDelay   = "Farmfördröjning (s)",
        HitboxToggle    = "Utöka Hitboxes",
        HitboxDesc      = "Öka hitbox på botar för lättare träff",
        HitboxSize      = "Hitbox-storlek",
        Fullbright      = "Fullbright",
        FullbrightDesc  = "Öka ljusstyrka och inaktivera skuggor",
        LangSelect      = "Språk",
        CreditsTitle    = "Super Bot Brawl Hub",
        CreditsContent  = "Skapad av Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Första utgåvan",
        Loaded          = "Hub laddad! Kämpa smartare.",
    },
    EL = {
        WindowTitle     = "Super Bot Brawl Hub",
        TabHome         = "Αρχική",
        TabVision       = "Όραση",
        TabMovement     = "Κίνηση",
        TabCombat       = "Μάχη",
        TabTools        = "Εργαλεία",
        ESPBots         = "ESP Bots",
        ESPBotsDesc     = "Επισήμανση κοντινών bots και εμφάνιση HP",
        TPNearestBot    = "TP στο Κοντινότερο Bot",
        TPNearestDesc   = "Τηλεμεταφορά μπροστά στο κοντινότερο bot",
        Fly             = "Πτήση",
        FlyDesc         = "Εναλλαγή λειτουργίας πτήσης",
        FlySpeed        = "Ταχύτητα Πτήσης",
        NoClip          = "NoClip",
        NoClipDesc      = "Περνάς μέσα από τοίχους και εμπόδια",
        WalkSpeed       = "Ταχύτητα Βαδίσματος",
        GodMode         = "Λειτουργία Θεού",
        GodModeDesc     = "Συνεχής αναπλήρωση HP — σχεδόν άτρωτος",
        AutoFarm        = "Αυτόματο Farm",
        AutoFarmDesc    = "Αυτόματη επίθεση στο κοντινότερο bot",
        AutoFarmDelay   = "Καθυστέρηση farm (δευτ.)",
        HitboxToggle    = "Επέκταση Hitbox",
        HitboxDesc      = "Μεγέθυνση hitbox bots για ευκολότερη επαφή",
        HitboxSize      = "Μέγεθος Hitbox",
        Fullbright      = "Πλήρης Φωτεινότητα",
        FullbrightDesc  = "Αύξηση φωτεινότητας και απενεργοποίηση σκιών",
        LangSelect      = "Γλώσσα",
        CreditsTitle    = "Super Bot Brawl Hub",
        CreditsContent  = "Δημιουργήθηκε από τον Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Πρώτη έκδοση",
        Loaded          = "Hub φορτώθηκε! Μάχου εξυπνότερα.",
    },
    RO = {
        WindowTitle     = "Super Bot Brawl Hub",
        TabHome         = "Acasă",
        TabVision       = "Viziune",
        TabMovement     = "Mișcare",
        TabCombat       = "Luptă",
        TabTools        = "Instrumente",
        ESPBots         = "ESP Boți",
        ESPBotsDesc     = "Evidențiază boții din apropiere și arată HP",
        TPNearestBot    = "TP la Cel Mai Aproape Bot",
        TPNearestDesc   = "Teleportare în fața celui mai apropiat bot",
        Fly             = "Zbor",
        FlyDesc         = "Activează modul de zbor",
        FlySpeed        = "Viteza de zbor",
        NoClip          = "NoClip",
        NoClipDesc      = "Treci prin pereți și obstacole",
        WalkSpeed       = "Viteză de mers",
        GodMode         = "Modul Dumnezeu",
        GodModeDesc     = "Restaurează HP continuu — aproape de neînvins",
        AutoFarm        = "Auto Farm",
        AutoFarmDesc    = "Atacă automat cel mai apropiat bot",
        AutoFarmDelay   = "Întârziere farm (s)",
        HitboxToggle    = "Extinde Hitbox",
        HitboxDesc      = "Mărește hitbox-ul boților pentru lovituri mai ușoare",
        HitboxSize      = "Dimensiune Hitbox",
        Fullbright      = "Luminozitate maximă",
        FullbrightDesc  = "Crește luminozitatea și dezactivează umbrele",
        LangSelect      = "Limbă",
        CreditsTitle    = "Super Bot Brawl Hub",
        CreditsContent  = "Creat de Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Prima versiune",
        Loaded          = "Hub încărcat! Luptă mai inteligent.",
    },
    UK = {
        WindowTitle     = "Super Bot Brawl Hub",
        TabHome         = "Головна",
        TabVision       = "Зір",
        TabMovement     = "Рух",
        TabCombat       = "Бій",
        TabTools        = "Інструменти",
        ESPBots         = "ESP ботів",
        ESPBotsDesc     = "Підсвічувати ближніх ботів і показувати HP",
        TPNearestBot    = "ТП до найближчого бота",
        TPNearestDesc   = "Телепортуватися до найближчого бота",
        Fly             = "Політ",
        FlyDesc         = "Увімкнути режим польоту",
        FlySpeed        = "Швидкість польоту",
        NoClip          = "Нокліп",
        NoClipDesc      = "Проходити крізь стіни й перешкоди",
        WalkSpeed       = "Швидкість ходьби",
        GodMode         = "Режим Бога",
        GodModeDesc     = "Безперервне відновлення HP — майже невразливий",
        AutoFarm        = "Авто фарм",
        AutoFarmDesc    = "Автоматично атакує найближчого бота",
        AutoFarmDelay   = "Затримка фарму (с)",
        HitboxToggle    = "Розширити хітбокси",
        HitboxDesc      = "Збільшити хітбокс ботів для легшого попадання",
        HitboxSize      = "Розмір хітбоксу",
        Fullbright      = "Повна яскравість",
        FullbrightDesc  = "Збільшити яскравість і вимкнути тіні",
        LangSelect      = "Мова",
        CreditsTitle    = "Super Bot Brawl Hub",
        CreditsContent  = "Створено Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Перший випуск",
        Loaded          = "Hub завантажено! Бийся розумніше.",
    },
    CS = {
        WindowTitle     = "Super Bot Brawl Hub",
        TabHome         = "Domů",
        TabVision       = "Vidění",
        TabMovement     = "Pohyb",
        TabCombat       = "Boj",
        TabTools        = "Nástroje",
        ESPBots         = "ESP Boti",
        ESPBotsDesc     = "Zvýraznit blízké boty a zobrazit jejich HP",
        TPNearestBot    = "TP k nejbližšímu Botovi",
        TPNearestDesc   = "Přesuň se před nejbližšího bota",
        Fly             = "Létání",
        FlyDesc         = "Přepnout letový režim",
        FlySpeed        = "Rychlost letu",
        NoClip          = "NoClip",
        NoClipDesc      = "Procházet zdmi a překážkami",
        WalkSpeed       = "Rychlost chůze",
        GodMode         = "Bůh mód",
        GodModeDesc     = "Průběžná obnova HP — téměř nezničitelný",
        AutoFarm        = "Auto Farm",
        AutoFarmDesc    = "Automaticky útočí na nejbližšího bota",
        AutoFarmDelay   = "Zpoždění farmu (s)",
        HitboxToggle    = "Rozšířit Hitboxy",
        HitboxDesc      = "Zvětšit hitbox botů pro snazší zásah",
        HitboxSize      = "Velikost Hitboxu",
        Fullbright      = "Plné světlo",
        FullbrightDesc  = "Zvýšit jas a vypnout stíny",
        LangSelect      = "Jazyk",
        CreditsTitle    = "Super Bot Brawl Hub",
        CreditsContent  = "Vytvořil Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — První verze",
        Loaded          = "Hub načten! Bojuj chytřeji.",
    },
    DA = {
        WindowTitle     = "Super Bot Brawl Hub",
        TabHome         = "Hjem",
        TabVision       = "Syn",
        TabMovement     = "Bevægelse",
        TabCombat       = "Kamp",
        TabTools        = "Værktøjer",
        ESPBots         = "ESP Bots",
        ESPBotsDesc     = "Fremhæv nærliggende bots og vis deres HP",
        TPNearestBot    = "TP til nærmeste Bot",
        TPNearestDesc   = "Teleportér foran den nærmeste bot",
        Fly             = "Fly",
        FlyDesc         = "Slå flytilstand til/fra",
        FlySpeed        = "Flyhastighed",
        NoClip          = "NoClip",
        NoClipDesc      = "Gå igennem vægge og forhindringer",
        WalkSpeed       = "Gåhastighed",
        GodMode         = "Gudstilstand",
        GodModeDesc     = "Genopret HP kontinuerligt — næsten uforgængelig",
        AutoFarm        = "Auto Farm",
        AutoFarmDesc    = "Angrib automatisk den nærmeste bot",
        AutoFarmDelay   = "Farm-forsinkelse (s)",
        HitboxToggle    = "Udvid Hitboxes",
        HitboxDesc      = "Forstør bot-hitboxes for lettere at ramme",
        HitboxSize      = "Hitbox-størrelse",
        Fullbright      = "Fuld lysstyrke",
        FullbrightDesc  = "Øg lysstyrke og deaktiver skygger",
        LangSelect      = "Sprog",
        CreditsTitle    = "Super Bot Brawl Hub",
        CreditsContent  = "Oprettet af Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Første udgivelse",
        Loaded          = "Hub indlæst! Kæmp klogere.",
    },
}

local function T(key)
    return (Translations[CurrentLang] and Translations[CurrentLang][key])
        or Translations["EN"][key]
        or key
end

-- ───────────────────────────────────────────────────────────────
-- SETTINGS
-- ───────────────────────────────────────────────────────────────
local Settings = {
    GodMode         = false,
    AutoFarm        = false,
    AutoFarmDelay   = 0.3,
    ESP_Bots        = false,
    Fly             = false,
    FlySpeed        = 60,
    NoClip          = false,
    WalkSpeed       = 16,
    Fullbright      = false,
    Hitbox_Enabled  = false,
    HitboxSize      = 3,
}

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ───────────────────────────────────────────────────────────────
-- LOAD RAYFIELD (keyless)
-- ───────────────────────────────────────────────────────────────
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)
if not success or not Rayfield then
    warn("[SuperBotBrawlHub] Failed to load Rayfield.")
    return
end

local Window = Rayfield:CreateWindow({
    Name            = T("WindowTitle"),
    LoadingTitle    = "Loading Hub...",
    LoadingSubtitle = "Created by Rival960 & Claude",
    ConfigurationSaving = { Enabled = false },
    Discord         = { Enabled = false },
    KeySystem       = false,
})

-- ───────────────────────────────────────────────────────────────
-- HELPERS
-- ───────────────────────────────────────────────────────────────

local function getHRP()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

-- Broad bot detection: any Model with a live Humanoid, not a player character,
-- and not the local player. Works whether bots are in Workspace.Bots or not.
local function isBot(model)
    if not model or not model:IsA("Model") then return false end
    if LocalPlayer.Character and (model == LocalPlayer.Character or model:IsDescendantOf(LocalPlayer.Character)) then
        return false
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character == model then return false end
    end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if not model:FindFirstChild("HumanoidRootPart") then return false end
    return true
end

local function getNearestBot()
    local hrp = getHRP()
    if not hrp then return nil, nil end
    local bestDist, bestBot, bestHRP = math.huge, nil, nil
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if isBot(obj) then
            local bhrp = obj:FindFirstChild("HumanoidRootPart")
            if bhrp then
                local d = (bhrp.Position - hrp.Position).Magnitude
                if d < bestDist then
                    bestDist, bestBot, bestHRP = d, obj, bhrp
                end
            end
        end
    end
    return bestBot, bestHRP
end

-- ───────────────────────────────────────────────────────────────
-- GOD MODE
-- ───────────────────────────────────────────────────────────────
local godModeConnection = nil
local originalMaxHealth = nil

local function setGodMode(state)
    local hum = getHumanoid()
    if not hum then return end

    if state then
        if originalMaxHealth == nil then
            originalMaxHealth = hum.MaxHealth
        end
        hum.MaxHealth = math.huge
        hum.Health    = math.huge
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)

        task.spawn(function()
            while Settings.GodMode and hum.Parent do
                hum.MaxHealth = math.huge
                hum.Health    = math.huge
                task.wait()
            end
        end)

        if godModeConnection then godModeConnection:Disconnect() end
        godModeConnection = hum.HealthChanged:Connect(function(newHealth)
            if Settings.GodMode and hum.Parent and newHealth < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
        end)
    else
        if godModeConnection then
            godModeConnection:Disconnect()
            godModeConnection = nil
        end
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        if originalMaxHealth then
            hum.MaxHealth = originalMaxHealth
            hum.Health    = originalMaxHealth
            originalMaxHealth = nil
        else
            hum.MaxHealth = 100
            hum.Health    = math.min(hum.Health, 100)
        end
    end
end

-- ───────────────────────────────────────────────────────────────
-- FLY
-- ───────────────────────────────────────────────────────────────
local flyVelocity, flyGyro
local flyMobileVertical = 0
local mobileFlyGui = nil
local mobileUpBtn, mobileDownBtn

local function createMobileFlyButtons()
    if mobileFlyGui then return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "_SB_MobileFly"
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local function makeBtn(text, yOffset)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 50, 0, 50)
        btn.Position = UDim2.new(1, -70, 0.5, yOffset)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        btn.BackgroundTransparency = 0.3
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Text = text
        btn.TextSize = 24
        btn.Font = Enum.Font.GothamBold
        btn.Parent = gui
        return btn
    end

    mobileUpBtn = makeBtn("▲", -60)
    mobileDownBtn = makeBtn("▼", 0)

    mobileUpBtn.MouseButton1Down:Connect(function() flyMobileVertical = 1 end)
    mobileUpBtn.MouseButton1Up:Connect(function() flyMobileVertical = 0 end)
    mobileDownBtn.MouseButton1Down:Connect(function() flyMobileVertical = -1 end)
    mobileDownBtn.MouseButton1Up:Connect(function() flyMobileVertical = 0 end)

    mobileFlyGui = gui
end

local function enableFly()
    local hrp = getHRP()
    if not hrp then return end

    flyVelocity = Instance.new("BodyVelocity")
    flyVelocity.Velocity    = Vector3.zero
    flyVelocity.MaxForce    = Vector3.new(1e5, 1e5, 1e5)
    flyVelocity.Parent      = hrp

    flyGyro = Instance.new("BodyGyro")
    flyGyro.MaxTorque       = Vector3.new(1e5, 1e5, 1e5)
    flyGyro.P               = 1e4
    flyGyro.CFrame          = hrp.CFrame
    flyGyro.Parent          = hrp

    local hum = getHumanoid()
    if hum then hum.PlatformStand = true end

    if isMobile then
        createMobileFlyButtons()
        if mobileFlyGui then mobileFlyGui.Enabled = true end
    end
end

local function disableFly()
    if flyVelocity then flyVelocity:Destroy(); flyVelocity = nil end
    if flyGyro     then flyGyro:Destroy();     flyGyro     = nil end
    local hum = getHumanoid()
    if hum then hum.PlatformStand = false end
    local hrp = getHRP()
    if hrp then
        hrp.AssemblyLinearVelocity  = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    flyMobileVertical = 0
    if mobileFlyGui then mobileFlyGui.Enabled = false end
end

-- ───────────────────────────────────────────────────────────────
-- NOCLIP WATCHDOG
-- ───────────────────────────────────────────────────────────────
local noclipHooks = {}

local function clearNoclipHooks()
    for part, conn in pairs(noclipHooks) do
        if conn then conn:Disconnect() end
        if part and part.Parent then
            part.CanCollide = true
        end
    end
    noclipHooks = {}
end

local function addNoclipHook(part)
    if not part or not part:IsA("BasePart") or part.Name == "HumanoidRootPart" then
        return
    end
    if noclipHooks[part] then return end
    part.CanCollide = false
    noclipHooks[part] = part:GetPropertyChangedSignal("CanCollide"):Connect(function()
        if Settings.NoClip and part.CanCollide then
            part.CanCollide = false
        end
    end)
end

-- ───────────────────────────────────────────────────────────────
-- AUTO FARM
-- ───────────────────────────────────────────────────────────────
local lastFarmTime = 0

local function doAutoFarm()
    if not Settings.AutoFarm then return end
    local now = tick()
    if now - lastFarmTime < Settings.AutoFarmDelay then return end
    lastFarmTime = now

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local botModel, botHRP = getNearestBot()
    if not botHRP or not botModel then return end

    local offset = (hrp.Position - botHRP.Position).Unit * 4
    hrp.CFrame = CFrame.new(botHRP.Position + offset + Vector3.new(0, 1, 0))

    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        pcall(function() tool:Activate() end)
        for _, v in ipairs(tool:GetDescendants()) do
            if v:IsA("RemoteEvent") then
                pcall(function() v:FireServer() end)
                break
            end
        end
    end
end

-- ───────────────────────────────────────────────────────────────
-- TABS
-- ───────────────────────────────────────────────────────────────

local TabHome = Window:CreateTab(T("TabHome"), 4483362458)
TabHome:CreateParagraph({
    Title   = T("CreditsTitle"),
    Content = T("CreditsContent"),
})

local TabVision = Window:CreateTab(T("TabVision"), 4483362458)

TabVision:CreateToggle({
    Name        = T("ESPBots"),
    CurrentValue = Settings.ESP_Bots,
    Flag        = "ESP_Bots",
    Callback    = function(v) Settings.ESP_Bots = v end,
})

TabVision:CreateButton({
    Name     = T("TPNearestBot"),
    Callback = function()
        local hrp = getHRP()
        if not hrp then return end
        local _, botHRP = getNearestBot()
        if botHRP then
            local dir = (hrp.Position - botHRP.Position).Unit
            hrp.CFrame = CFrame.new(botHRP.Position + dir * 4 + Vector3.new(0, 1, 0))
            Rayfield:Notify({ Title = T("TPNearestBot"), Content = T("TPNearestDesc"), Duration = 2 })
        else
            Rayfield:Notify({ Title = T("TPNearestBot"), Content = "No bot found nearby.", Duration = 2 })
        end
    end,
})

local TabMovement = Window:CreateTab(T("TabMovement"), 4483362458)

TabMovement:CreateToggle({
    Name         = T("Fly"),
    CurrentValue = Settings.Fly,
    Flag         = "Fly",
    Callback     = function(v)
        Settings.Fly = v
        if v then enableFly() else disableFly() end
    end,
})

TabMovement:CreateSlider({
    Name         = T("FlySpeed"),
    Range        = {10, 300},
    Increment    = 5,
    CurrentValue = Settings.FlySpeed,
    Flag         = "FlySpeed",
    Callback     = function(v) Settings.FlySpeed = v end,
})

TabMovement:CreateToggle({
    Name         = T("NoClip"),
    CurrentValue = Settings.NoClip,
    Flag         = "NoClip",
    Callback     = function(v)
        Settings.NoClip = v
        if v then
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    addNoclipHook(part)
                end
                char.DescendantAdded:Connect(function(part)
                    if Settings.NoClip then addNoclipHook(part) end
                end)
            end
        else
            clearNoclipHooks()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.AssemblyLinearVelocity  = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end
            end
        end
    end,
})

TabMovement:CreateSlider({
    Name         = T("WalkSpeed"),
    Range        = {16, 250},
    Increment    = 1,
    CurrentValue = Settings.WalkSpeed,
    Flag         = "WalkSpeed",
    Callback     = function(v)
        Settings.WalkSpeed = v
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = v end
    end,
})

local TabCombat = Window:CreateTab(T("TabCombat"), 4483362458)

TabCombat:CreateToggle({
    Name         = T("GodMode"),
    CurrentValue = Settings.GodMode,
    Flag         = "GodMode",
    Callback     = function(v)
        Settings.GodMode = v
        setGodMode(v)
    end,
})

TabCombat:CreateToggle({
    Name         = T("AutoFarm"),
    CurrentValue = Settings.AutoFarm,
    Flag         = "AutoFarm",
    Callback     = function(v) Settings.AutoFarm = v end,
})

TabCombat:CreateSlider({
    Name         = T("AutoFarmDelay"),
    Range        = {0.1, 2.0},
    Increment    = 0.1,
    CurrentValue = Settings.AutoFarmDelay,
    Flag         = "AutoFarmDelay",
    Callback     = function(v) Settings.AutoFarmDelay = v end,
})

TabCombat:CreateToggle({
    Name         = T("HitboxToggle"),
    CurrentValue = Settings.Hitbox_Enabled,
    Flag         = "Hitbox_Enabled",
    Callback     = function(v)
        Settings.Hitbox_Enabled = v
        if not v then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if isBot(obj) then
                    local bhrp = obj:FindFirstChild("HumanoidRootPart")
                    if bhrp then
                        local orig = bhrp:GetAttribute("HitboxOriginalSize")
                        if orig then
                            bhrp.Size = orig
                            bhrp:SetAttribute("HitboxOriginalSize", nil)
                        else
                            bhrp.Size = Vector3.new(2, 2, 1)
                        end
                        bhrp.Transparency = 1
                        bhrp.CanCollide = true
                    end
                end
            end
        end
    end,
})

TabCombat:CreateSlider({
    Name         = T("HitboxSize"),
    Range        = {2, 10},
    Increment    = 1,
    CurrentValue = Settings.HitboxSize,
    Flag         = "HitboxSize",
    Callback     = function(v) Settings.HitboxSize = v end,
})

local TabTools = Window:CreateTab(T("TabTools"), 4483362458)

TabTools:CreateToggle({
    Name         = T("Fullbright"),
    CurrentValue = Settings.Fullbright,
    Flag         = "Fullbright",
    Callback     = function(v)
        Settings.Fullbright = v
        if v then
            Lighting.Brightness     = 2
            Lighting.ClockTime      = 14
            Lighting.GlobalShadows  = false
        else
            Lighting.Brightness     = 1
            Lighting.ClockTime      = 14
            Lighting.GlobalShadows  = true
        end
    end,
})

local langOptions = {"EN","FR","DE","ES","PT","RU","IT","NL","PL","ZH","JA","TR","KO","AR","VI","SV","EL","RO","UK","CS","DA"}
TabTools:CreateDropdown({
    Name    = T("LangSelect"),
    Options = langOptions,
    CurrentOption = {CurrentLang},
    Flag    = "Language",
    Callback = function(selected)
        CurrentLang = selected[1] or selected
        Rayfield:Notify({
            Title   = "Language",
            Content = "Re-execute the script to apply the new language.",
            Duration = 4,
        })
    end,
})

-- ───────────────────────────────────────────────────────────────
-- MAIN LOOP
-- ───────────────────────────────────────────────────────────────
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end

    local hrp  = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChildOfClass("Humanoid")

    -- NOCLIP: hook new parts if needed
    if Settings.NoClip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                addNoclipHook(part)
            end
        end
    end

    -- FLY
    if Settings.Fly and flyVelocity and flyGyro and hrp then
        local cam   = Workspace.CurrentCamera
        local speed = Settings.FlySpeed
        local dir   = Vector3.zero

        if isMobile then
            -- Horizontal from joystick (MoveDirection is already camera-relative)
            local move = hum and hum.MoveDirection or Vector3.zero
            dir = move
            -- Vertical from on-screen buttons
            if flyMobileVertical ~= 0 then
                dir = dir + Vector3.new(0, flyMobileVertical, 0)
            end
        else
            local uis = UserInputService
            if uis:IsKeyDown(Enum.KeyCode.W) or uis:IsKeyDown(Enum.KeyCode.Up) then
                dir = dir + cam.CFrame.LookVector
            end
            if uis:IsKeyDown(Enum.KeyCode.S) or uis:IsKeyDown(Enum.KeyCode.Down) then
                dir = dir - cam.CFrame.LookVector
            end
            if uis:IsKeyDown(Enum.KeyCode.A) or uis:IsKeyDown(Enum.KeyCode.Left) then
                dir = dir - cam.CFrame.RightVector
            end
            if uis:IsKeyDown(Enum.KeyCode.D) or uis:IsKeyDown(Enum.KeyCode.Right) then
                dir = dir + cam.CFrame.RightVector
            end
            if uis:IsKeyDown(Enum.KeyCode.Space) then
                dir = dir + Vector3.new(0, 1, 0)
            end
            if uis:IsKeyDown(Enum.KeyCode.LeftShift) or uis:IsKeyDown(Enum.KeyCode.RightShift) then
                dir = dir - Vector3.new(0, 1, 0)
            end
        end

        flyVelocity.Velocity = dir.Magnitude > 0 and dir.Unit * speed or Vector3.zero
        flyGyro.CFrame = cam.CFrame
    end

    -- ESP BOTS
    if Settings.ESP_Bots then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if isBot(obj) then
                local botHum = obj:FindFirstChildOfClass("Humanoid")

                local hl = obj:FindFirstChild("_BotESP_Highlight")
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name             = "_BotESP_Highlight"
                    hl.FillColor        = Color3.fromRGB(255, 60, 60)
                    hl.OutlineColor     = Color3.fromRGB(255, 200, 0)
                    hl.FillTransparency = 0.4
                    hl.Parent           = obj
                end

                local bhrp = obj:FindFirstChild("HumanoidRootPart")
                if bhrp then
                    local bb = bhrp:FindFirstChild("_BotESP_BB")
                    if not bb then
                        bb = Instance.new("BillboardGui")
                        bb.Name          = "_BotESP_BB"
                        bb.Size          = UDim2.new(0, 120, 0, 40)
                        bb.StudsOffset   = Vector3.new(0, 3, 0)
                        bb.AlwaysOnTop   = true
                        bb.Parent        = bhrp

                        local lbl = Instance.new("TextLabel")
                        lbl.Name            = "Label"
                        lbl.Size            = UDim2.new(1, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.TextColor3      = Color3.fromRGB(255, 240, 100)
                        lbl.TextStrokeTransparency = 0
                        lbl.TextScaled      = true
                        lbl.Font            = Enum.Font.GothamBold
                        lbl.Parent          = bb
                    end
                    local lbl = bb:FindFirstChild("Label")
                    if lbl and botHum then
                        lbl.Text = string.format("%s\nHP: %d/%d", obj.Name, math.floor(botHum.Health), math.floor(botHum.MaxHealth))
                    end
                end
            end
        end
    else
        for _, obj in ipairs(Workspace:GetDescendants()) do
            local hl = obj:FindFirstChild("_BotESP_Highlight")
            if hl then hl:Destroy() end
            local bhrp = obj:FindFirstChild("HumanoidRootPart")
            if bhrp then
                local bb = bhrp:FindFirstChild("_BotESP_BB")
                if bb then bb:Destroy() end
            end
        end
    end

    -- HITBOX: only bots, never the local player
    if Settings.Hitbox_Enabled then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if isBot(obj) then
                local bhrp = obj:FindFirstChild("HumanoidRootPart")
                if bhrp then
                    if not bhrp:GetAttribute("HitboxOriginalSize") then
                        bhrp:SetAttribute("HitboxOriginalSize", bhrp.Size)
                    end
                    bhrp.Size = Vector3.new(
                        Settings.HitboxSize * 2,
                        Settings.HitboxSize * 2,
                        Settings.HitboxSize * 2
                    )
                    bhrp.Transparency = 0.6
                    bhrp.CanCollide   = false
                end
            end
        end
    end

    -- WALKSPEED
    if hum and hum.WalkSpeed ~= Settings.WalkSpeed and not Settings.Fly then
        hum.WalkSpeed = Settings.WalkSpeed
    end
end)

RunService.Heartbeat:Connect(doAutoFarm)

LocalPlayer.CharacterAdded:Connect(function(_character)
    task.wait(0.5)

    if Settings.GodMode then
        originalMaxHealth = nil
        setGodMode(true)
    end

    if Settings.Fly then
        disableFly()
        task.wait(0.1)
        enableFly()
    end

    if Settings.NoClip then
        -- Re-hook the new character
        clearNoclipHooks()
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                addNoclipHook(part)
            end
        end
    end

    local hum = getHumanoid()
    if hum then hum.WalkSpeed = Settings.WalkSpeed end
end)

Rayfield:Notify({
    Title    = T("WindowTitle"),
    Content  = T("Loaded"),
    Duration = 4,
})

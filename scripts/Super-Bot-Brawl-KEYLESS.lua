--[[
    ================================================================
    Super Bot Brawl Hub — Super Bot Brawl
    Created by Rival960 with the help of Claude
    Version: 1.0.0 | Languages: 21 | Rayfield UI
    ================================================================
    Features:
      - God Mode (health loop, nearly indestructible vs robots)
      - Auto Farm (auto-attack nearest bot with cooldown)
      - ESP Bots (highlight + HP billboard on all NPCs)
      - Teleport to Nearest Bot
      - Fly (WASD + Space/Shift, camera-relative, adjustable speed)
      - NoClip (pass through walls)
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
        -- Vision
        ESPBots         = "ESP Bots",
        ESPBotsDesc     = "Highlight nearby bots and show their HP",
        TPNearestBot    = "TP to Nearest Bot",
        TPNearestDesc   = "Teleport in front of the closest bot",
        -- Movement
        Fly             = "Fly",
        FlyDesc         = "Toggle flight mode",
        FlySpeed        = "Fly Speed",
        NoClip          = "NoClip",
        NoClipDesc      = "Pass through walls and obstacles",
        WalkSpeed       = "Walk Speed",
        -- Combat
        GodMode         = "God Mode",
        GodModeDesc     = "Continuously restore HP — almost indestructible",
        AutoFarm        = "Auto Farm",
        AutoFarmDesc    = "Automatically attack the nearest bot",
        AutoFarmDelay   = "Farm Delay (s)",
        HitboxToggle    = "Expand Hitboxes",
        HitboxDesc      = "Increase bot hitbox size to hit more easily",
        HitboxSize      = "Hitbox Size",
        -- Tools
        Fullbright      = "Fullbright",
        FullbrightDesc  = "Raise brightness and disable shadows",
        LangSelect      = "Language",
        -- Credits
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
    AutoFarmDelay   = 0.3,   -- seconds between attacks (slider 0.1–2.0)
    ESP_Bots        = false,
    Fly             = false,
    FlySpeed        = 60,    -- slider 10–300
    NoClip          = false,
    WalkSpeed       = 16,    -- slider 16–250
    Fullbright      = false,
    Hitbox_Enabled  = false,
    HitboxSize      = 3,     -- slider 2–10 (multiplier)
}

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

-- Returns the Character's HumanoidRootPart, or nil
local function getHRP()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

-- Returns the Character's Humanoid, or nil
local function getHumanoid()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

-- Returns true if the model is a live NPC bot (has Humanoid, not a player)
local function isBot(model)
    if not model:IsA("Model") then return false end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    -- exclude player characters
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character == model then return false end
    end
    return true
end

-- Returns the nearest live bot and its HRP, or nil
local function getNearestBot()
    local hrp = getHRP()
    if not hrp then return nil, nil end
    local bestDist, bestBot, bestHRP = math.huge, nil, nil
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if isBot(obj) then
            local bhrp = obj:FindFirstChild("HumanoidRootPart")
                      or obj:FindFirstChild("Torso")
                      or obj:FindFirstChildOfClass("BasePart")
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
-- GOD MODE (MaxHealth + HealthChanged + safety loop)
-- ───────────────────────────────────────────────────────────────
local godModeConnection = nil
local originalMaxHealth = nil

local function setGodMode(state)
    local hum = getHumanoid()
    if not hum then return end

    if state then
        -- Capture the original MaxHealth only once
        if originalMaxHealth == nil then
            originalMaxHealth = hum.MaxHealth
        end

        hum.MaxHealth = math.huge
        hum.Health    = math.huge

        -- Safety loop: re-apply in case the game resets MaxHealth
        task.spawn(function()
            while Settings.GodMode and hum.Parent do
                hum.MaxHealth = math.huge
                hum.Health    = math.huge
                task.wait()
            end
        end)

        -- React instantly to any health change (more reliable than a loop)
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

        if originalMaxHealth then
            hum.MaxHealth = originalMaxHealth
            hum.Health    = originalMaxHealth
            originalMaxHealth = nil
        else
            -- Fallback: restore default health values
            hum.MaxHealth = 100
            hum.Health    = math.min(hum.Health, 100)
        end
    end
end

-- ───────────────────────────────────────────────────────────────
-- FLY (BodyVelocity + BodyGyro, camera-relative)
-- ───────────────────────────────────────────────────────────────
local flyVelocity, flyGyro

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
end

local function disableFly()
    if flyVelocity then flyVelocity:Destroy(); flyVelocity = nil end
    if flyGyro     then flyGyro:Destroy();     flyGyro     = nil end
    local hum = getHumanoid()
    if hum then hum.PlatformStand = false end
    -- Stop any residual velocity so the character doesn't slide
    local hrp = getHRP()
    if hrp then
        hrp.AssemblyLinearVelocity  = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
end

-- ───────────────────────────────────────────────────────────────
-- AUTO FARM (attack nearest bot with cooldown)
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

    -- Teleport close enough to hit
    local offset = (hrp.Position - botHRP.Position).Unit * 4
    hrp.CFrame = CFrame.new(botHRP.Position + offset + Vector3.new(0, 1, 0))

    -- Try to fire equipped tool
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        pcall(function() tool:Activate() end)
        -- Also fire the tool's remote if one exists
        for _, v in ipairs(tool:GetDescendants()) do
            if v:IsA("RemoteEvent") then
                pcall(function() v:FireServer() end)
                break
            end
        end
    end

    -- Fallback: try generic attack remotes in ReplicatedStorage
    local rs = game:GetService("ReplicatedStorage")
    for _, name in ipairs({
        "Attack", "Hit", "Damage", "DamageBot", "BotHit", "Strike",
        "SwordSlash", "Slash", "Melee", "AttackEvent", "Combat"
    }) do
        local ev = rs:FindFirstChild(name, true)
        if ev and ev:IsA("RemoteEvent") then
            pcall(function() ev:FireServer(botModel) end)
            break
        end
    end
end

-- ───────────────────────────────────────────────────────────────
-- TABS
-- ───────────────────────────────────────────────────────────────

-- ── TAB HOME ────────────────────────────────────────────────────
local TabHome = Window:CreateTab(T("TabHome"), 4483362458)
TabHome:CreateParagraph({
    Title   = T("CreditsTitle"),
    Content = T("CreditsContent"),
})

-- ── TAB VISION ──────────────────────────────────────────────────
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

-- ── TAB MOVEMENT ────────────────────────────────────────────────
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
        if not v then
            -- Restore collisions and stop residual velocity when disabling
            local character = LocalPlayer.Character
            if character then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
                local hrp = character:FindFirstChild("HumanoidRootPart")
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

-- ── TAB COMBAT ──────────────────────────────────────────────────
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
            -- restore original hitbox sizes
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if isBot(obj) then
                    local hrpB = obj:FindFirstChild("HumanoidRootPart")
                    if hrpB and hrpB:FindFirstChild("_origSize") then
                        hrpB.Size = hrpB._origSize.Value
                        hrpB._origSize:Destroy()
                        hrpB.Transparency = 1
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

-- ── TAB TOOLS ───────────────────────────────────────────────────
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
-- MAIN LOOP (RenderStepped — every frame)
-- ───────────────────────────────────────────────────────────────
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end

    local hrp  = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChildOfClass("Humanoid")

    -- NOCLIP: disable collisions on all parts EXCEPT the HumanoidRootPart.
    -- Keeping the root part collidable prevents the character from sliding.
    if Settings.NoClip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.CanCollide then
                part.CanCollide = false
            end
        end
    end

    -- FLY: update velocity from input
    if Settings.Fly and flyVelocity and flyGyro and hrp then
        local cam   = Workspace.CurrentCamera
        local speed = Settings.FlySpeed
        local dir   = Vector3.zero
        local uis   = UserInputService

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

        flyVelocity.Velocity = dir.Magnitude > 0 and dir.Unit * speed or Vector3.zero
        flyGyro.CFrame = cam.CFrame
    end

    -- ESP BOTS: add/refresh Highlight + BillboardGui
    if Settings.ESP_Bots then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if isBot(obj) then
                local botHum = obj:FindFirstChildOfClass("Humanoid")

                -- Highlight
                local hl = obj:FindFirstChild("_BotESP_Highlight")
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name             = "_BotESP_Highlight"
                    hl.FillColor        = Color3.fromRGB(255, 60, 60)
                    hl.OutlineColor     = Color3.fromRGB(255, 200, 0)
                    hl.FillTransparency = 0.4
                    hl.Parent           = obj
                end

                -- BillboardGui (HP label)
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
        -- Clean up ESP when disabled
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

    -- HITBOX: expand bot HRPs each frame
    if Settings.Hitbox_Enabled then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if isBot(obj) then
                local bhrp = obj:FindFirstChild("HumanoidRootPart")
                if bhrp and not bhrp:FindFirstChild("_origSize") then
                    local sv = Instance.new("Vector3Value")
                    sv.Name  = "_origSize"
                    sv.Value = bhrp.Size
                    sv.Parent = bhrp
                end
                if bhrp then
                    bhrp.Size         = Vector3.new(Settings.HitboxSize * 2, Settings.HitboxSize * 2, Settings.HitboxSize * 2)
                    bhrp.Transparency = 0.6
                    bhrp.CanCollide   = false
                end
            end
        end
    end

    -- WALKSPEED: re-apply after respawn
    if hum and hum.WalkSpeed ~= Settings.WalkSpeed and not Settings.Fly then
        hum.WalkSpeed = Settings.WalkSpeed
    end
end)

-- ───────────────────────────────────────────────────────────────
-- AUTO FARM — dedicated heartbeat for attack timing
-- ───────────────────────────────────────────────────────────────
RunService.Heartbeat:Connect(doAutoFarm)

-- ───────────────────────────────────────────────────────────────
-- ON RESPAWN: re-apply fly / godmode / walkspeed
-- ───────────────────────────────────────────────────────────────
LocalPlayer.CharacterAdded:Connect(function(_character)
    task.wait(0.5)

    -- Re-apply GodMode on the new Humanoid
    if Settings.GodMode then
        originalMaxHealth = nil -- force re-capture on the new Humanoid
        setGodMode(true)
    end

    -- Re-apply Fly
    if Settings.Fly then
        disableFly()
        task.wait(0.1)
        enableFly()
    end

    -- Re-apply WalkSpeed
    local hum = getHumanoid()
    if hum then hum.WalkSpeed = Settings.WalkSpeed end
end)

-- ───────────────────────────────────────────────────────────────
-- NOTIFICATION — Hub loaded
-- ───────────────────────────────────────────────────────────────
Rayfield:Notify({
    Title    = T("WindowTitle"),
    Content  = T("Loaded"),
    Duration = 4,
})

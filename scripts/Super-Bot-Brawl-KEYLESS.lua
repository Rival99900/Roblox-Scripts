--[[
    ================================================================
    Super Bot Brawl Hub — Super Bot Brawl
    Created by Rival960 with the help of Claude
    Version: 1.0.0 | Languages: 21 | Rayfield UI
    ================================================================
    Features:
      - Silent Aim (hooks attack remotes, distance limit slider)
      - Auto Farm (attacks nearest bot from above, anti-touch)
      - ESP Bots (highlight + HP billboard on all NPCs)
      - Teleport to Nearest Bot
      - Fly (PC: WASD/Space/Shift | Mobile: joystick + on-screen ▲/▼)
      - NoClip (pass through walls, fully cleans up on disable)
      - Walk Speed (adjustable)
      - No Cooldown (hook task.wait & set tool values to 0)
      - Fullbright (brightness boost, fixed clock)
      - 21-language interface
    ================================================================
--]]

-- ───────────────────────────────────────────────────────────────
-- SERVICES
-- ───────────────────────────────────────────────────────────────
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace        = game:GetService("Workspace")
local Lighting         = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

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
        SilentAim       = "Silent Aim",
        SilentAimDesc   = "Redirect attacks to the nearest bot",
        SilentAimDist   = "Silent Aim Max Distance",
        AutoFarm        = "Auto Farm",
        AutoFarmDesc    = "Automatically attack the nearest bot",
        AutoFarmDelay   = "Farm Delay (s)",
        AntiTouch       = "Anti Touch",
        AntiTouchDesc   = "Prevent bots from dealing touch damage to you",
        NoCooldown      = "No Cooldown",
        NoCooldownDesc  = "Set equipped tool cooldowns to 0 and hook waits",
        Fullbright      = "Fullbright",
        FullbrightDesc  = "Raise brightness and disable shadows",
        LangSelect      = "Language",
        CreditsTitle    = "Super Bot Brawl Hub",
        CreditsContent  = "Created by Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — First release",
        Loaded          = "Hub loaded! Fight smarter.",
        NoBot           = "No bot found nearby.",
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
        SilentAim       = "Silent Aim",
        SilentAimDesc   = "Redirige les attaques vers le bot le plus proche",
        SilentAimDist   = "Distance Max Silent Aim",
        AutoFarm        = "Auto Farm",
        AutoFarmDesc    = "Attaque automatiquement le bot le plus proche",
        AutoFarmDelay   = "Délai farm (s)",
        AntiTouch       = "Anti Touche",
        AntiTouchDesc   = "Empêche les bots de vous infliger des dégâts de contact",
        NoCooldown      = "Pas de Cooldown",
        NoCooldownDesc  = "Met à zéro les cooldowns et intercepte les délais",
        Fullbright      = "Luminosité max",
        FullbrightDesc  = "Augmenter la luminosité et désactiver les ombres",
        LangSelect      = "Langue",
        CreditsTitle    = "Super Bot Brawl Hub",
        CreditsContent  = "Créé par Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Première version",
        Loaded          = "Hub chargé ! Combats plus intelligemment.",
        NoBot           = "Aucun bot trouvé à proximité.",
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
        SilentAim       = "Silent Aim",
        SilentAimDesc   = "Angriffe auf den nächsten Bot umleiten",
        SilentAimDist   = "Silent Aim Max. Distanz",
        AutoFarm        = "Auto Farm",
        AutoFarmDesc    = "Greift automatisch den nächsten Bot an",
        AutoFarmDelay   = "Farm-Verzögerung (s)",
        AntiTouch       = "Anti Touch",
        AntiTouchDesc   = "Verhindert Kontaktschaden durch Bots",
        NoCooldown      = "Kein Cooldown",
        NoCooldownDesc  = "Setzt Abklingzeiten auf 0 und hookt Wartezeiten",
        Fullbright      = "Vollhell",
        FullbrightDesc  = "Helligkeit erhöhen und Schatten deaktivieren",
        LangSelect      = "Sprache",
        CreditsTitle    = "Super Bot Brawl Hub",
        CreditsContent  = "Erstellt von Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Erste Version",
        Loaded          = "Hub geladen! Kämpfe klüger.",
        NoBot           = "Kein Bot in der Nähe gefunden.",
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
        SilentAim       = "Silent Aim",
        SilentAimDesc   = "Redirigir ataques al bot más cercano",
        SilentAimDist   = "Distancia Máx Silent Aim",
        AutoFarm        = "Auto Farm",
        AutoFarmDesc    = "Ataca automáticamente al bot más cercano",
        AutoFarmDelay   = "Retraso farm (s)",
        AntiTouch       = "Anti Contacto",
        AntiTouchDesc   = "Evita que los bots te causen daño por contacto",
        NoCooldown      = "Sin Cooldown",
        NoCooldownDesc  = "Pone a cero los cooldowns e intercepta las esperas",
        Fullbright      = "Brillo máximo",
        FullbrightDesc  = "Aumentar brillo y desactivar sombras",
        LangSelect      = "Idioma",
        CreditsTitle    = "Super Bot Brawl Hub",
        CreditsContent  = "Creado por Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Primera versión",
        Loaded          = "¡Hub cargado! Lucha de forma más inteligente.",
        NoBot           = "No se encontró ningún bot cerca.",
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
        SilentAim       = "Silent Aim",
        SilentAimDesc   = "Redirecionar ataques para o bot mais próximo",
        SilentAimDist   = "Distância Máx Silent Aim",
        AutoFarm        = "Auto Farm",
        AutoFarmDesc    = "Ataca automaticamente o bot mais próximo",
        AutoFarmDelay   = "Atraso do farm (s)",
        AntiTouch       = "Anti Toque",
        AntiTouchDesc   = "Impede que os bots causem dano de contato",
        NoCooldown      = "Sem Cooldown",
        NoCooldownDesc  = "Zera os cooldowns e intercepta as esperas",
        Fullbright      = "Brilho máximo",
        FullbrightDesc  = "Aumentar brilho e desativar sombras",
        LangSelect      = "Idioma",
        CreditsTitle    = "Super Bot Brawl Hub",
        CreditsContent  = "Criado por Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Primeira versão",
        Loaded          = "Hub carregado! Lute de forma mais inteligente.",
        NoBot           = "Nenhum bot encontrado por perto.",
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
        SilentAim       = "Тихий прицел",
        SilentAimDesc   = "Перенаправлять атаки на ближайшего бота",
        SilentAimDist   = "Макс. дистанция тихого прицела",
        AutoFarm        = "Авто фарм",
        AutoFarmDesc    = "Автоматически атаковать ближайшего бота",
        AutoFarmDelay   = "Задержка фарма (с)",
        AntiTouch       = "Анти-касание",
        AntiTouchDesc   = "Предотвращает контактный урон от ботов",
        NoCooldown      = "Без перезарядки",
        NoCooldownDesc  = "Сбрасывает перезарядку и перехватывает задержки",
        Fullbright      = "Максяркость",
        FullbrightDesc  = "Увеличить яркость и отключить тени",
        LangSelect      = "Язык",
        CreditsTitle    = "Super Bot Brawl Hub",
        CreditsContent  = "Создано Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Первый выпуск",
        Loaded          = "Хаб загружен! Сражайся умнее.",
        NoBot           = "Рядом нет ботов.",
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
        SilentAim       = "Silent Aim",
        SilentAimDesc   = "Reindirizza gli attacchi al bot più vicino",
        SilentAimDist   = "Distanza Max Silent Aim",
        AutoFarm        = "Auto Farm",
        AutoFarmDesc    = "Attacca automaticamente il bot più vicino",
        AutoFarmDelay   = "Ritardo farm (s)",
        AntiTouch       = "Anti Contatto",
        AntiTouchDesc   = "Impedisce ai bot di infliggere danni da contatto",
        NoCooldown      = "Nessun Cooldown",
        NoCooldownDesc  = "Azzera i cooldown e intercetta le attese",
        Fullbright      = "Luminosità massima",
        FullbrightDesc  = "Aumenta luminosità e disattiva ombre",
        LangSelect      = "Lingua",
        CreditsTitle    = "Super Bot Brawl Hub",
        CreditsContent  = "Creato da Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Prima versione",
        Loaded          = "Hub caricato! Combatti in modo più intelligente.",
        NoBot           = "Nessun bot trovato nelle vicinanze.",
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
        SilentAim       = "Silent Aim",
        SilentAimDesc   = "Aanvallen omleiden naar de dichtstbijzijnde bot",
        SilentAimDist   = "Silent Aim Max Afstand",
        AutoFarm        = "Auto Farm",
        AutoFarmDesc    = "Valt automatisch de dichtstbijzijnde bot aan",
        AutoFarmDelay   = "Farm vertraging (s)",
        AntiTouch       = "Anti Aanraking",
        AntiTouchDesc   = "Voorkomt aanrakingsschade van bots",
        NoCooldown      = "Geen Cooldown",
        NoCooldownDesc  = "Zet cooldowns op 0 en onderschept wachttijden",
        Fullbright      = "Maximale helderheid",
        FullbrightDesc  = "Helderheid verhogen en schaduwen uitschakelen",
        LangSelect      = "Taal",
        CreditsTitle    = "Super Bot Brawl Hub",
        CreditsContent  = "Gemaakt door Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Eerste versie",
        Loaded          = "Hub geladen! Vecht slimmer.",
        NoBot           = "Geen bot in de buurt gevonden.",
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
        SilentAim       = "Silent Aim",
        SilentAimDesc   = "Przekieruj ataki na najbliższego bota",
        SilentAimDist   = "Maks. dystans Silent Aim",
        AutoFarm        = "Auto Farm",
        AutoFarmDesc    = "Automatycznie atakuje najbliższego bota",
        AutoFarmDelay   = "Opóźnienie farmu (s)",
        AntiTouch       = "Anti Dotyk",
        AntiTouchDesc   = "Zapobiega obrażeniom od kontaktu z botami",
        NoCooldown      = "Brak Cooldownu",
        NoCooldownDesc  = "Zeruje cooldowny i przechwytuje opóźnienia",
        Fullbright      = "Pełna jasność",
        FullbrightDesc  = "Zwiększ jasność i wyłącz cienie",
        LangSelect      = "Język",
        CreditsTitle    = "Super Bot Brawl Hub",
        CreditsContent  = "Stworzone przez Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Pierwsza wersja",
        Loaded          = "Hub załadowany! Walcz mądrzej.",
        NoBot           = "Nie znaleziono bota w pobliżu.",
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
        SilentAim       = "无声自瞄",
        SilentAimDesc   = "将攻击重定向至最近的机器人",
        SilentAimDist   = "无声自瞄最大距离",
        AutoFarm        = "自动刷怪",
        AutoFarmDesc    = "自动攻击最近的机器人",
        AutoFarmDelay   = "刷怪延迟（秒）",
        AntiTouch       = "防触摸",
        AntiTouchDesc   = "防止机器人对你造成接触伤害",
        NoCooldown      = "无冷却",
        NoCooldownDesc  = "将装备冷却设为0并拦截等待",
        Fullbright      = "全亮",
        FullbrightDesc  = "提高亮度并关闭阴影",
        LangSelect      = "语言",
        CreditsTitle    = "超级机器人乱斗Hub",
        CreditsContent  = "由 Rival960 创建\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — 首次发布",
        Loaded          = "Hub已加载！更智慧地战斗。",
        NoBot           = "附近没有找到机器人。",
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
        SilentAim       = "サイレントエイム",
        SilentAimDesc   = "攻撃を最寄りのボットにリダイレクト",
        SilentAimDist   = "サイレントエイム最大距離",
        AutoFarm        = "オートファーム",
        AutoFarmDesc    = "最も近いボットを自動攻撃",
        AutoFarmDelay   = "ファーム遅延（秒）",
        AntiTouch       = "アンチタッチ",
        AntiTouchDesc   = "ボットからの接触ダメージを防ぐ",
        NoCooldown      = "クールダウンなし",
        NoCooldownDesc  = "ツールのクールダウンを0にし、待機をフックする",
        Fullbright      = "フルブライト",
        FullbrightDesc  = "明るさを上げてシャドウを無効化",
        LangSelect      = "言語",
        CreditsTitle    = "スーパーボットブロールHub",
        CreditsContent  = "Rival960 作\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — 初回リリース",
        Loaded          = "Hub読み込み完了！より賢く戦おう。",
        NoBot           = "近くにボットが見つかりません。",
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
        SilentAim       = "Sessiz Nişan",
        SilentAimDesc   = "Saldırıları en yakın bota yönlendir",
        SilentAimDist   = "Sessiz Nişan Maks. Mesafe",
        AutoFarm        = "Otomatik Farm",
        AutoFarmDesc    = "En yakın botu otomatik saldır",
        AutoFarmDelay   = "Farm gecikmesi (s)",
        AntiTouch       = "Anti Dokunma",
        AntiTouchDesc   = "Botların sana temas hasarı vermesini engeller",
        NoCooldown      = "Bekleme Yok",
        NoCooldownDesc  = "Bekleme sürelerini sıfırlar ve gecikmeleri engeller",
        Fullbright      = "Tam Parlaklık",
        FullbrightDesc  = "Parlaklığı artır ve gölgeleri devre dışı bırak",
        LangSelect      = "Dil",
        CreditsTitle    = "Super Bot Brawl Hub",
        CreditsContent  = "Rival960 tarafından oluşturuldu\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — İlk sürüm",
        Loaded          = "Hub yüklendi! Daha akıllıca savaş.",
        NoBot           = "Yakında bot bulunamadı.",
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
        SilentAim       = "사일런트 에임",
        SilentAimDesc   = "공격을 가장 가까운 봇으로 리다이렉트",
        SilentAimDist   = "사일런트 에임 최대 거리",
        AutoFarm        = "자동 파밍",
        AutoFarmDesc    = "가장 가까운 봇을 자동 공격",
        AutoFarmDelay   = "파밍 딜레이(초)",
        AntiTouch       = "안티 터치",
        AntiTouchDesc   = "봇의 접촉 피해를 방지합니다",
        NoCooldown      = "쿨다운 없음",
        NoCooldownDesc  = "장착 도구 쿨다운을 0으로 하고 대기를 차단합니다",
        Fullbright      = "풀브라이트",
        FullbrightDesc  = "밝기 증가 및 그림자 비활성화",
        LangSelect      = "언어",
        CreditsTitle    = "슈퍼 봇 브롤 허브",
        CreditsContent  = "Rival960 제작\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — 첫 번째 릴리스",
        Loaded          = "허브 로드 완료! 더 스마트하게 싸우자.",
        NoBot           = "근처에 봇이 없습니다.",
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
        SilentAim       = "التصويب الصامت",
        SilentAimDesc   = "إعادة توجيه الهجمات إلى أقرب روبوت",
        SilentAimDist   = "أقصى مسافة للتصويب الصامت",
        AutoFarm        = "زراعة تلقائية",
        AutoFarmDesc    = "مهاجمة أقرب روبوت تلقائياً",
        AutoFarmDelay   = "تأخير الزراعة (ث)",
        AntiTouch       = "مضاد اللمس",
        AntiTouchDesc   = "يمنع الروبوتات من إلحاق ضرر اللمس بك",
        NoCooldown      = "بدون تبريد",
        NoCooldownDesc  = "تصفير أوقات التبريد واعتراض فترات الانتظار",
        Fullbright      = "إضاءة كاملة",
        FullbrightDesc  = "رفع السطوع وتعطيل الظلال",
        LangSelect      = "اللغة",
        CreditsTitle    = "سوبر بوت برول هاب",
        CreditsContent  = "أنشأه Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — الإصدار الأول",
        Loaded          = "تم تحميل الهاب! قاتل بذكاء.",
        NoBot           = "لم يتم العثور على روبوت قريب.",
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
        SilentAim       = "Silent Aim",
        SilentAimDesc   = "Chuyển hướng đòn tấn công đến bot gần nhất",
        SilentAimDist   = "Khoảng cách tối đa Silent Aim",
        AutoFarm        = "Tự động Farm",
        AutoFarmDesc    = "Tự động tấn công bot gần nhất",
        AutoFarmDelay   = "Độ trễ farm (s)",
        AntiTouch       = "Chống chạm",
        AntiTouchDesc   = "Ngăn bot gây sát thương chạm cho bạn",
        NoCooldown      = "Không hồi chiêu",
        NoCooldownDesc  = "Đặt hồi chiêu về 0 và chặn thời gian chờ",
        Fullbright      = "Sáng tối đa",
        FullbrightDesc  = "Tăng độ sáng và tắt bóng",
        LangSelect      = "Ngôn ngữ",
        CreditsTitle    = "Super Bot Brawl Hub",
        CreditsContent  = "Tạo bởi Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Phiên bản đầu tiên",
        Loaded          = "Hub đã tải! Chiến đấu thông minh hơn.",
        NoBot           = "Không tìm thấy bot nào gần đây.",
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
        SilentAim       = "Silent Aim",
        SilentAimDesc   = "Omdirigera attacker till närmaste boten",
        SilentAimDist   = "Silent Aim Max Avstånd",
        AutoFarm        = "Auto Farm",
        AutoFarmDesc    = "Attackera automatiskt närmaste boten",
        AutoFarmDelay   = "Farmfördröjning (s)",
        AntiTouch       = "Anti Beröring",
        AntiTouchDesc   = "Förhindrar att botar ger dig beröringsskada",
        NoCooldown      = "Ingen Cooldown",
        NoCooldownDesc  = "Nollställer cooldowns och fångar upp väntetider",
        Fullbright      = "Fullbright",
        FullbrightDesc  = "Öka ljusstyrka och inaktivera skuggor",
        LangSelect      = "Språk",
        CreditsTitle    = "Super Bot Brawl Hub",
        CreditsContent  = "Skapad av Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Första utgåvan",
        Loaded          = "Hub laddad! Kämpa smartare.",
        NoBot           = "Ingen bot hittades i närheten.",
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
        SilentAim       = "Silent Aim",
        SilentAimDesc   = "Ανακατεύθυνση επιθέσεων στο κοντινότερο bot",
        SilentAimDist   = "Μέγιστη Απόσταση Silent Aim",
        AutoFarm        = "Αυτόματο Farm",
        AutoFarmDesc    = "Αυτόματη επίθεση στο κοντινότερο bot",
        AutoFarmDelay   = "Καθυστέρηση farm (δευτ.)",
        AntiTouch       = "Anti Touch",
        AntiTouchDesc   = "Αποτρέπει τα bots από το να σου προκαλούν ζημιά επαφής",
        NoCooldown      = "Χωρίς Cooldown",
        NoCooldownDesc  = "Μηδενίζει τα cooldown και ανακόπτει τις αναμονές",
        Fullbright      = "Πλήρης Φωτεινότητα",
        FullbrightDesc  = "Αύξηση φωτεινότητας και απενεργοποίηση σκιών",
        LangSelect      = "Γλώσσα",
        CreditsTitle    = "Super Bot Brawl Hub",
        CreditsContent  = "Δημιουργήθηκε από τον Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Πρώτη έκδοση",
        Loaded          = "Hub φορτώθηκε! Μάχου εξυπνότερα.",
        NoBot           = "Δεν βρέθηκε bot κοντά.",
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
        SilentAim       = "Silent Aim",
        SilentAimDesc   = "Redirecționează atacurile către cel mai apropiat bot",
        SilentAimDist   = "Distanță Max Silent Aim",
        AutoFarm        = "Auto Farm",
        AutoFarmDesc    = "Atacă automat cel mai apropiat bot",
        AutoFarmDelay   = "Întârziere farm (s)",
        AntiTouch       = "Anti Atingere",
        AntiTouchDesc   = "Împiedică boții să-ți provoace daune de contact",
        NoCooldown      = "Fără Cooldown",
        NoCooldownDesc  = "Setează la 0 timpii de reîncărcare și interceptează așteptările",
        Fullbright      = "Luminozitate maximă",
        FullbrightDesc  = "Crește luminozitatea și dezactivează umbrele",
        LangSelect      = "Limbă",
        CreditsTitle    = "Super Bot Brawl Hub",
        CreditsContent  = "Creat de Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Prima versiune",
        Loaded          = "Hub încărcat! Luptă mai inteligent.",
        NoBot           = "Niciun bot găsit în apropiere.",
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
        SilentAim       = "Тихий приціл",
        SilentAimDesc   = "Перенаправляти атаки на найближчого бота",
        SilentAimDist   = "Макс. дистанція тихого прицілу",
        AutoFarm        = "Авто фарм",
        AutoFarmDesc    = "Автоматично атакує найближчого бота",
        AutoFarmDelay   = "Затримка фарму (с)",
        AntiTouch       = "Анти-дотик",
        AntiTouchDesc   = "Запобігає контактній шкоді від ботів",
        NoCooldown      = "Без перезарядки",
        NoCooldownDesc  = "Скидає перезарядку та перехоплює затримки",
        Fullbright      = "Повна яскравість",
        FullbrightDesc  = "Збільшити яскравість і вимкнути тіні",
        LangSelect      = "Мова",
        CreditsTitle    = "Super Bot Brawl Hub",
        CreditsContent  = "Створено Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Перший випуск",
        Loaded          = "Hub завантажено! Бийся розумніше.",
        NoBot           = "Поруч немає ботів.",
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
        SilentAim       = "Silent Aim",
        SilentAimDesc   = "Přesměrovat útoky na nejbližšího bota",
        SilentAimDist   = "Max. vzdálenost Silent Aim",
        AutoFarm        = "Auto Farm",
        AutoFarmDesc    = "Automaticky útočí na nejbližšího bota",
        AutoFarmDelay   = "Zpoždění farmu (s)",
        AntiTouch       = "Anti Dotyk",
        AntiTouchDesc   = "Zabraňuje poškození kontaktem od botů",
        NoCooldown      = "Bez Cooldownu",
        NoCooldownDesc  = "Nastaví cooldowny na 0 a zachytí čekání",
        Fullbright      = "Plné světlo",
        FullbrightDesc  = "Zvýšit jas a vypnout stíny",
        LangSelect      = "Jazyk",
        CreditsTitle    = "Super Bot Brawl Hub",
        CreditsContent  = "Vytvořil Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — První verze",
        Loaded          = "Hub načten! Bojuj chytřeji.",
        NoBot           = "V okolí nebyl nalezen žádný bot.",
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
        SilentAim       = "Silent Aim",
        SilentAimDesc   = "Omdiriger angreb til den nærmeste bot",
        SilentAimDist   = "Silent Aim Maks. Afstand",
        AutoFarm        = "Auto Farm",
        AutoFarmDesc    = "Angrib automatisk den nærmeste bot",
        AutoFarmDelay   = "Farm-forsinkelse (s)",
        AntiTouch       = "Anti Berøring",
        AntiTouchDesc   = "Forhindrer bots i at give dig berøringsskade",
        NoCooldown      = "Ingen Cooldown",
        NoCooldownDesc  = "Sætter cooldowns til 0 og opsnapper ventetider",
        Fullbright      = "Fuld lysstyrke",
        FullbrightDesc  = "Øg lysstyrke og deaktiver skygger",
        LangSelect      = "Sprog",
        CreditsTitle    = "Super Bot Brawl Hub",
        CreditsContent  = "Oprettet af Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Første udgivelse",
        Loaded          = "Hub indlæst! Kæmp klogere.",
        NoBot           = "Ingen bot fundet i nærheden.",
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
    SilentAim        = false,
    SilentAimMaxDist = 150,
    AutoFarm         = false,
    AutoFarmDelay    = 0.3,
    ESP_Bots         = false,
    Fly              = false,
    FlySpeed         = 60,
    NoClip           = false,
    WalkSpeed        = 16,
    NoCooldown       = false,
    AntiTouch        = false,
    Fullbright       = false,
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

local function isBot(model)
    if not model or not model:IsA("Model") then return false end
    local botsFolder = Workspace:FindFirstChild("Bots")
    if not botsFolder or not model:IsDescendantOf(botsFolder) then return false end
    if Players:GetPlayerFromCharacter(model) then return false end
    if LocalPlayer.Character and model == LocalPlayer.Character then return false end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if not model:FindFirstChild("HumanoidRootPart") then return false end
    return true
end

local function getNearestBot()
    local hrp = getHRP()
    if not hrp then return nil, nil end
    local bestDist, bestBot, bestHRP = math.huge, nil, nil
    local botsFolder = Workspace:FindFirstChild("Bots")
    if not botsFolder then return nil, nil end
    for _, obj in ipairs(botsFolder:GetDescendants()) do
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
-- SILENT AIM (hookmetamethod __namecall)
-- ───────────────────────────────────────────────────────────────
local silentAimConnection = nil
local originalNamecall = nil
local attackRemoteKeywords = {"Attack", "Hit", "Damage", "Shoot", "Strike", "Slash", "Melee", "Swing", "Fire"}

local function getClosestBotToCursor()
    local mouse = UserInputService:GetMouseLocation()
    local cam = Workspace.CurrentCamera
    local hrp = getHRP()
    if not hrp then return nil end
    local closest, minDist = nil, math.huge
    local botsFolder = Workspace:FindFirstChild("Bots")
    if not botsFolder then return nil end
    for _, obj in ipairs(botsFolder:GetDescendants()) do
        if isBot(obj) then
            local bhrp = obj:FindFirstChild("HumanoidRootPart")
            if bhrp then
                local worldDist = (bhrp.Position - hrp.Position).Magnitude
                if worldDist <= Settings.SilentAimMaxDist then
                    local screenPos, onScreen = cam:WorldToViewportPoint(bhrp.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mouse).Magnitude
                        if dist < minDist then
                            minDist = dist
                            closest = bhrp
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function enableSilentAim()
    if originalNamecall then return end

    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    originalNamecall = oldNamecall
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" and not checkcaller() and Settings.SilentAim then
            local args = {...}
            if self:IsA("RemoteEvent") then
                local shouldHook = false
                for _, kw in ipairs(attackRemoteKeywords) do
                    if self.Name:lower():find(kw:lower()) then
                        shouldHook = true
                        break
                    end
                end
                if shouldHook then
                    local target = getClosestBotToCursor()
                    if target then
                        if #args >= 1 and typeof(args[1]) == "Instance" then
                            args[1] = target
                        else
                            table.insert(args, 1, target)
                        end
                    end
                end
            end
            return oldNamecall(self, table.unpack(args))
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end

local function disableSilentAim()
    if originalNamecall then
        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        mt.__namecall = originalNamecall
        setreadonly(mt, true)
        originalNamecall = nil
    end
end

-- ───────────────────────────────────────────────────────────────
-- FLY (BodyVelocity + BodyGyro, PC + Mobile)
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
        btn.Size = UDim2.new(0, 55, 0, 55)
        btn.Position = UDim2.new(1, -80, 0.5, yOffset)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        btn.BackgroundTransparency = 0.3
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Text = text
        btn.TextSize = 26
        btn.Font = Enum.Font.GothamBold
        btn.Parent = gui
        return btn
    end

    mobileUpBtn = makeBtn("▲", -70)
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
    flyVelocity.Velocity = Vector3.zero
    flyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    flyVelocity.Parent = hrp

    flyGyro = Instance.new("BodyGyro")
    flyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    flyGyro.P = 1e4
    flyGyro.CFrame = hrp.CFrame
    flyGyro.Parent = hrp

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
-- NOCLIP (Robust, fully cleans up)
-- ───────────────────────────────────────────────────────────────
local noclipConnection = nil
local originalCollisions = {} -- Stores [Part] = original CanCollide

local function enableNoClip()
    if noclipConnection then return end
    originalCollisions = {}
    local char = LocalPlayer.Character
    if not char then return end

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            originalCollisions[part] = part.CanCollide
            part.CanCollide = false
        end
    end

    noclipConnection = RunService.Heartbeat:Connect(function()
        if not Settings.NoClip then return end
        local c = LocalPlayer.Character
        if not c then return end
        for _, part in ipairs(c:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                if originalCollisions[part] == nil then
                    originalCollisions[part] = part.CanCollide
                end
                part.CanCollide = false
            end
        end
    end)
end

local function disableNoClip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end

    -- Restore original collision states
    for part, originalState in pairs(originalCollisions) do
        if part and part.Parent then
            part.CanCollide = originalState
        end
    end
    originalCollisions = {}

    -- Safety: force CanCollide = true on all current parts
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- ───────────────────────────────────────────────────────────────
-- ANTI TOUCH (Disables touch damage from bots)
-- ───────────────────────────────────────────────────────────────
local antiTouchConnection = nil

local function enableAntiTouch()
    if antiTouchConnection then return end
    antiTouchConnection = RunService.Heartbeat:Connect(function()
        if not Settings.AntiTouch then return end
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanTouch then
                part.CanTouch = false
            end
        end
    end)
end

local function disableAntiTouch()
    if antiTouchConnection then
        antiTouchConnection:Disconnect()
        antiTouchConnection = nil
    end
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanTouch = true
            end
        end
    end
end

-- ───────────────────────────────────────────────────────────────
-- NO COOLDOWN (Hook waits + set tool values to 0)
-- ───────────────────────────────────────────────────────────────
local originalWait = nil
local originalTaskWait = nil

local function applyNoCooldown()
    -- 1. Hook global waits
    if not originalWait then
        originalWait = wait
        wait = function(seconds)
            if Settings.NoCooldown then
                return originalWait(0)
            end
            return originalWait(seconds)
        end
    end
    if not originalTaskWait then
        originalTaskWait = task.wait
        task.wait = function(seconds)
            if Settings.NoCooldown then
                return originalTaskWait(0)
            end
            return originalTaskWait(seconds)
        end
    end

    -- 2. Set tool values to 0
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            tool = backpack:FindFirstChildOfClass("Tool")
        end
    end
    if not tool then return end

    for _, v in ipairs(tool:GetDescendants()) do
        if v:IsA("NumberValue") or v:IsA("IntValue") then
            local n = v.Name:lower()
            if n:find("cooldown") or n:find("firerate") or n:find("delay") or n:find("reload") or n:find("rate") then
                v.Value = 0
            end
        end
    end
end

local function removeNoCooldownHooks()
    if originalWait then
        wait = originalWait
        originalWait = nil
    end
    if originalTaskWait then
        task.wait = originalTaskWait
        originalTaskWait = nil
    end
end

-- ───────────────────────────────────────────────────────────────
-- AUTO FARM (attacks from above)
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
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    local botModel, botHRP = getNearestBot()
    if not botHRP or not botModel then return end

    -- Teleport above the bot (10 studs higher)
    local above = botHRP.Position + Vector3.new(0, 10, 0)
    hrp.CFrame = CFrame.lookAt(above, botHRP.Position)

    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            local newTool = backpack:FindFirstChildOfClass("Tool")
            if newTool then
                hum:EquipTool(newTool)
                task.wait(0.1)
                tool = newTool
            end
        end
    end

    local botHum = botModel:FindFirstChildOfClass("Humanoid")

    if tool then
        for _, v in ipairs(tool:GetDescendants()) do
            if v:IsA("NumberValue") or v:IsA("IntValue") then
                local n = v.Name:lower()
                if n:find("cooldown") or n:find("firerate") or n:find("delay") or n:find("reload") then
                    v.Value = 0
                end
            end
        end
        pcall(function() tool:Activate() end)
        for _, v in ipairs(tool:GetDescendants()) do
            if v:IsA("RemoteEvent") then
                pcall(function() v:FireServer(botHum) end)
            end
        end
    end

    for _, name in ipairs(attackRemoteKeywords) do
        local ev = ReplicatedStorage:FindFirstChild(name, true)
        if ev and ev:IsA("RemoteEvent") then
            pcall(function() ev:FireServer(botHum) end)
            break
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
    Name         = T("ESPBots"),
    CurrentValue = Settings.ESP_Bots,
    Flag         = "ESP_Bots",
    Callback     = function(v) Settings.ESP_Bots = v end,
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
            Rayfield:Notify({ Title = T("TPNearestBot"), Content = T("NoBot"), Duration = 2 })
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
        if v then enableNoClip() else disableNoClip() end
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
    Name         = T("SilentAim"),
    CurrentValue = Settings.SilentAim,
    Flag         = "SilentAim",
    Callback     = function(v)
        Settings.SilentAim = v
        if v then enableSilentAim() else disableSilentAim() end
    end,
})

TabCombat:CreateSlider({
    Name         = T("SilentAimDist"),
    Range        = {10, 500},
    Increment    = 10,
    CurrentValue = Settings.SilentAimMaxDist,
    Flag         = "SilentAimMaxDist",
    Callback     = function(v) Settings.SilentAimMaxDist = v end,
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
    Name         = T("AntiTouch"),
    CurrentValue = Settings.AntiTouch,
    Flag         = "AntiTouch",
    Callback     = function(v)
        Settings.AntiTouch = v
        if v then enableAntiTouch() else disableAntiTouch() end
    end,
})

TabCombat:CreateButton({
    Name     = T("NoCooldown"),
    Callback = function()
        applyNoCooldown()
        Rayfield:Notify({
            Title   = T("NoCooldown"),
            Content = T("NoCooldownDesc"),
            Duration = 2,
        })
    end,
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
    Name          = T("LangSelect"),
    Options       = langOptions,
    CurrentOption = {CurrentLang},
    Flag          = "Language",
    Callback      = function(selected)
        CurrentLang = selected[1] or selected
        Rayfield:Notify({
            Title    = "Language",
            Content  = "Re-execute the script to apply the new language.",
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

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")

    -- Fly
    if Settings.Fly and flyVelocity and flyGyro and hrp then
        local cam   = Workspace.CurrentCamera
        local speed = Settings.FlySpeed
        local dir   = Vector3.zero

        if isMobile then
            local move = hum and hum.MoveDirection or Vector3.zero
            dir = move
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

    -- ESP
    if Settings.ESP_Bots then
        local botsFolder = Workspace:FindFirstChild("Bots")
        if botsFolder then
            for _, obj in ipairs(botsFolder:GetDescendants()) do
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
                            bb.Name        = "_BotESP_BB"
                            bb.Size        = UDim2.new(0, 120, 0, 40)
                            bb.StudsOffset = Vector3.new(0, 3, 0)
                            bb.AlwaysOnTop = true
                            bb.Parent      = bhrp

                            local lbl = Instance.new("TextLabel")
                            lbl.Name                   = "Label"
                            lbl.Size                   = UDim2.new(1, 0, 1, 0)
                            lbl.BackgroundTransparency = 1
                            lbl.TextColor3             = Color3.fromRGB(255, 240, 100)
                            lbl.TextStrokeTransparency = 0
                            lbl.TextScaled             = true
                            lbl.Font                   = Enum.Font.GothamBold
                            lbl.Parent                 = bb
                        end
                        local lbl = bb:FindFirstChild("Label")
                        if lbl and botHum then
                            lbl.Text = string.format("%s\nHP: %d/%d", obj.Name, math.floor(botHum.Health), math.floor(botHum.MaxHealth))
                        end
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

    -- WalkSpeed
    if hum and hum.WalkSpeed ~= Settings.WalkSpeed and not Settings.Fly then
        hum.WalkSpeed = Settings.WalkSpeed
    end
end)

RunService.Heartbeat:Connect(doAutoFarm)

LocalPlayer.CharacterAdded:Connect(function(_character)
    task.wait(0.5)

    if Settings.Fly then
        disableFly()
        task.wait(0.1)
        enableFly()
    end

    if Settings.NoClip then
        enableNoClip()
    end

    if Settings.SilentAim then
        enableSilentAim()
    end

    if Settings.AntiTouch then
        enableAntiTouch()
    end

    local hum = getHumanoid()
    if hum then hum.WalkSpeed = Settings.WalkSpeed end
end)

Rayfield:Notify({
    Title    = T("WindowTitle"),
    Content  = T("Loaded"),
    Duration = 4,
})

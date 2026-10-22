--[[
    ================================================================
    Super Bot Brawl Hub — Super Bot Brawl
    Created by Rival960 & Claude, DeepSeek
    Version: 1.0.0 | Languages: 21 | Rayfield UI
    ================================================================
    Features:
      - Auto Farm (feet on bot head, no damage taken, 0.1s default)
      - Bot Magnet (PivotTo loop, ignores bot chase AI)
      - Anti Ragdoll (event-driven, blocks Ragdoll/Physics/FallingDown/Dead)
      - ESP Bots (highlight + HP billboard on all NPCs)
      - Teleport to Nearest Bot
      - Fly (PC: WASD/Space/Shift | Mobile: joystick + on-screen ▲/▼)
      - NoClip (fully restores original collision states)
      - Walk Speed (adjustable)
      - Fullbright (brightness boost, fixed clock)
      - 21-language interface
    ================================================================
--]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace        = game:GetService("Workspace")
local Lighting         = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

-- ───────────────────────────────────────────────────────────────
-- 21-LANGUAGE SYSTEM
-- ───────────────────────────────────────────────────────────────
local CurrentLang = "EN"

local Translations = {
    EN = {
        WindowTitle = "Super Bot Brawl Hub", TabHome = "Home", TabVision = "Vision", TabMovement = "Movement", TabCombat = "Combat", TabTools = "Tools",
        ESPBots = "ESP Bots", TPNearestBot = "TP to Nearest Bot", TPNearestDesc = "Teleport in front of the closest bot",
        Fly = "Fly", FlySpeed = "Fly Speed", NoClip = "NoClip", WalkSpeed = "Walk Speed",
        AutoFarm = "Auto Farm", AutoFarmDelay = "Farm Delay (s)",
        BotMagnet = "Bot Magnet", BotMagnetDesc = "Gather all bots in one spot",
        AntiRagdoll = "Anti Ragdoll",
        Fullbright = "Fullbright", LangSelect = "Language",
        CreditsTitle = "Super Bot Brawl Hub",
        CreditsContent = "Created by Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — First release",
        Loaded = "Hub loaded! Fight smarter.", NoBot = "No bot found nearby.",
    },
    FR = {
        WindowTitle = "Super Bot Brawl Hub", TabHome = "Accueil", TabVision = "Vision", TabMovement = "Mouvement", TabCombat = "Combat", TabTools = "Outils",
        ESPBots = "ESP Bots", TPNearestBot = "TP au Bot le plus proche", TPNearestDesc = "Se téléporter devant le bot le plus proche",
        Fly = "Vol", FlySpeed = "Vitesse de vol", NoClip = "NoClip", WalkSpeed = "Vitesse de marche",
        AutoFarm = "Auto Farm", AutoFarmDelay = "Délai farm (s)",
        BotMagnet = "Aimant à Bots", BotMagnetDesc = "Regroupe tous les bots en un point",
        AntiRagdoll = "Anti Ragdoll",
        Fullbright = "Luminosité max", LangSelect = "Langue",
        CreditsTitle = "Super Bot Brawl Hub",
        CreditsContent = "Créé par Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Première version",
        Loaded = "Hub chargé ! Combats plus intelligemment.", NoBot = "Aucun bot trouvé à proximité.",
    },
    DE = {
        WindowTitle = "Super Bot Brawl Hub", TabHome = "Start", TabVision = "Sicht", TabMovement = "Bewegung", TabCombat = "Kampf", TabTools = "Werkzeuge",
        ESPBots = "ESP Bots", TPNearestBot = "TP zum nächsten Bot", TPNearestDesc = "Zum nächsten Bot teleportieren",
        Fly = "Fliegen", FlySpeed = "Fluggeschwindigkeit", NoClip = "NoClip", WalkSpeed = "Laufgeschwindigkeit",
        AutoFarm = "Auto Farm", AutoFarmDelay = "Farm-Verzögerung (s)",
        BotMagnet = "Bot-Magnet", BotMagnetDesc = "Sammelt alle Bots an einem Ort",
        AntiRagdoll = "Anti Ragdoll",
        Fullbright = "Vollhell", LangSelect = "Sprache",
        CreditsTitle = "Super Bot Brawl Hub",
        CreditsContent = "Erstellt von Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Erste Version",
        Loaded = "Hub geladen! Kämpfe klüger.", NoBot = "Kein Bot in der Nähe gefunden.",
    },
    ES = {
        WindowTitle = "Super Bot Brawl Hub", TabHome = "Inicio", TabVision = "Visión", TabMovement = "Movimiento", TabCombat = "Combate", TabTools = "Herramientas",
        ESPBots = "ESP Bots", TPNearestBot = "TP al Bot más cercano", TPNearestDesc = "Teletransportarse frente al bot más cercano",
        Fly = "Volar", FlySpeed = "Velocidad de vuelo", NoClip = "NoClip", WalkSpeed = "Velocidad de marcha",
        AutoFarm = "Auto Farm", AutoFarmDelay = "Retraso farm (s)",
        BotMagnet = "Imán de Bots", BotMagnetDesc = "Reúne todos los bots en un punto",
        AntiRagdoll = "Anti Ragdoll",
        Fullbright = "Brillo máximo", LangSelect = "Idioma",
        CreditsTitle = "Super Bot Brawl Hub",
        CreditsContent = "Creado por Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Primera versión",
        Loaded = "¡Hub cargado! Lucha de forma más inteligente.", NoBot = "No se encontró ningún bot cerca.",
    },
    PT = {
        WindowTitle = "Super Bot Brawl Hub", TabHome = "Início", TabVision = "Visão", TabMovement = "Movimento", TabCombat = "Combate", TabTools = "Ferramentas",
        ESPBots = "ESP Bots", TPNearestBot = "TP para o Bot mais próximo", TPNearestDesc = "Teleportar para o bot mais próximo",
        Fly = "Voar", FlySpeed = "Velocidade de voo", NoClip = "NoClip", WalkSpeed = "Velocidade de caminhada",
        AutoFarm = "Auto Farm", AutoFarmDelay = "Atraso do farm (s)",
        BotMagnet = "Ímã de Bots", BotMagnetDesc = "Reúne todos os bots em um só lugar",
        AntiRagdoll = "Anti Ragdoll",
        Fullbright = "Brilho máximo", LangSelect = "Idioma",
        CreditsTitle = "Super Bot Brawl Hub",
        CreditsContent = "Criado por Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Primeira versão",
        Loaded = "Hub carregado! Lute de forma mais inteligente.", NoBot = "Nenhum bot encontrado por perto.",
    },
    RU = {
        WindowTitle = "Super Bot Brawl Hub", TabHome = "Главная", TabVision = "Зрение", TabMovement = "Движение", TabCombat = "Бой", TabTools = "Инструменты",
        ESPBots = "ESP ботов", TPNearestBot = "ТП к ближайшему боту", TPNearestDesc = "Телепортироваться к ближайшему боту",
        Fly = "Полёт", FlySpeed = "Скорость полёта", NoClip = "Ноклип", WalkSpeed = "Скорость ходьбы",
        AutoFarm = "Авто фарм", AutoFarmDelay = "Задержка фарма (с)",
        BotMagnet = "Магнит ботов", BotMagnetDesc = "Собирает всех ботов в одно место",
        AntiRagdoll = "Анти-рагдолл",
        Fullbright = "Максяркость", LangSelect = "Язык",
        CreditsTitle = "Super Bot Brawl Hub",
        CreditsContent = "Создано Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Первый выпуск",
        Loaded = "Хаб загружен! Сражайся умнее.", NoBot = "Рядом нет ботов.",
    },
    IT = {
        WindowTitle = "Super Bot Brawl Hub", TabHome = "Home", TabVision = "Visione", TabMovement = "Movimento", TabCombat = "Combattimento", TabTools = "Strumenti",
        ESPBots = "ESP Bot", TPNearestBot = "TP al Bot più vicino", TPNearestDesc = "Teletrasportarsi davanti al bot più vicino",
        Fly = "Volare", FlySpeed = "Velocità di volo", NoClip = "NoClip", WalkSpeed = "Velocità di camminata",
        AutoFarm = "Auto Farm", AutoFarmDelay = "Ritardo farm (s)",
        BotMagnet = "Calamita Bot", BotMagnetDesc = "Raccoglie tutti i bot in un punto",
        AntiRagdoll = "Anti Ragdoll",
        Fullbright = "Luminosità massima", LangSelect = "Lingua",
        CreditsTitle = "Super Bot Brawl Hub",
        CreditsContent = "Creato da Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Prima versione",
        Loaded = "Hub caricato! Combatti in modo più intelligente.", NoBot = "Nessun bot trovato nelle vicinanze.",
    },
    NL = {
        WindowTitle = "Super Bot Brawl Hub", TabHome = "Start", TabVision = "Zicht", TabMovement = "Beweging", TabCombat = "Gevecht", TabTools = "Hulpmiddelen",
        ESPBots = "ESP Bots", TPNearestBot = "TP naar dichtstbijzijnde Bot", TPNearestDesc = "Teleporteer naar de dichtstbijzijnde bot",
        Fly = "Vliegen", FlySpeed = "Vliegsnelheid", NoClip = "NoClip", WalkSpeed = "Loopsnelheid",
        AutoFarm = "Auto Farm", AutoFarmDelay = "Farm vertraging (s)",
        BotMagnet = "Bot Magneet", BotMagnetDesc = "Verzamelt alle bots op één plek",
        AntiRagdoll = "Anti Ragdoll",
        Fullbright = "Maximale helderheid", LangSelect = "Taal",
        CreditsTitle = "Super Bot Brawl Hub",
        CreditsContent = "Gemaakt door Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Eerste versie",
        Loaded = "Hub geladen! Vecht slimmer.", NoBot = "Geen bot in de buurt gevonden.",
    },
    PL = {
        WindowTitle = "Super Bot Brawl Hub", TabHome = "Główna", TabVision = "Wzrok", TabMovement = "Ruch", TabCombat = "Walka", TabTools = "Narzędzia",
        ESPBots = "ESP Boty", TPNearestBot = "TP do najbliższego Bota", TPNearestDesc = "Teleportuj się do najbliższego bota",
        Fly = "Latanie", FlySpeed = "Prędkość lotu", NoClip = "NoClip", WalkSpeed = "Prędkość chodzenia",
        AutoFarm = "Auto Farm", AutoFarmDelay = "Opóźnienie farmu (s)",
        BotMagnet = "Magnes na Boty", BotMagnetDesc = "Gromadzi wszystkie boty w jednym miejscu",
        AntiRagdoll = "Anti Ragdoll",
        Fullbright = "Pełna jasność", LangSelect = "Język",
        CreditsTitle = "Super Bot Brawl Hub",
        CreditsContent = "Stworzone przez Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Pierwsza wersja",
        Loaded = "Hub załadowany! Walcz mądrzej.", NoBot = "Nie znaleziono bota w pobliżu.",
    },
    ZH = {
        WindowTitle = "超级机器人乱斗Hub", TabHome = "主页", TabVision = "视野", TabMovement = "移动", TabCombat = "战斗", TabTools = "工具",
        ESPBots = "ESP机器人", TPNearestBot = "传送至最近机器人", TPNearestDesc = "传送到最近的机器人前方",
        Fly = "飞行", FlySpeed = "飞行速度", NoClip = "穿墙", WalkSpeed = "移动速度",
        AutoFarm = "自动刷怪", AutoFarmDelay = "刷怪延迟（秒）",
        BotMagnet = "机器人磁铁", BotMagnetDesc = "将所有机器人聚集到一个地方",
        AntiRagdoll = "防布娃娃",
        Fullbright = "全亮", LangSelect = "语言",
        CreditsTitle = "超级机器人乱斗Hub",
        CreditsContent = "由 Rival960 创建\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — 首次发布",
        Loaded = "Hub已加载！更智慧地战斗。", NoBot = "附近没有找到机器人。",
    },
    JA = {
        WindowTitle = "スーパーボットブロールHub", TabHome = "ホーム", TabVision = "視覚", TabMovement = "移動", TabCombat = "戦闘", TabTools = "ツール",
        ESPBots = "ESPボット", TPNearestBot = "最近のボットにTP", TPNearestDesc = "最も近いボットの前にテレポート",
        Fly = "飛行", FlySpeed = "飛行速度", NoClip = "ノークリップ", WalkSpeed = "移動速度",
        AutoFarm = "オートファーム", AutoFarmDelay = "ファーム遅延（秒）",
        BotMagnet = "ボットマグネット", BotMagnetDesc = "すべてのボットを1か所に集める",
        AntiRagdoll = "アンチラグドール",
        Fullbright = "フルブライト", LangSelect = "言語",
        CreditsTitle = "スーパーボットブロールHub",
        CreditsContent = "Rival960 作\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — 初回リリース",
        Loaded = "Hub読み込み完了！より賢く戦おう。", NoBot = "近くにボットが見つかりません。",
    },
    TR = {
        WindowTitle = "Super Bot Brawl Hub", TabHome = "Ana Sayfa", TabVision = "Görüş", TabMovement = "Hareket", TabCombat = "Savaş", TabTools = "Araçlar",
        ESPBots = "ESP Botlar", TPNearestBot = "En Yakın Bota TP", TPNearestDesc = "En yakın botun önüne ışınlan",
        Fly = "Uçuş", FlySpeed = "Uçuş Hızı", NoClip = "NoClip", WalkSpeed = "Yürüyüş Hızı",
        AutoFarm = "Otomatik Farm", AutoFarmDelay = "Farm gecikmesi (s)",
        BotMagnet = "Bot Mıknatısı", BotMagnetDesc = "Tüm botları tek bir yerde toplar",
        AntiRagdoll = "Anti Ragdoll",
        Fullbright = "Tam Parlaklık", LangSelect = "Dil",
        CreditsTitle = "Super Bot Brawl Hub",
        CreditsContent = "Rival960 tarafından oluşturuldu\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — İlk sürüm",
        Loaded = "Hub yüklendi! Daha akıllıca savaş.", NoBot = "Yakında bot bulunamadı.",
    },
    KO = {
        WindowTitle = "슈퍼 봇 브롤 허브", TabHome = "홈", TabVision = "시야", TabMovement = "이동", TabCombat = "전투", TabTools = "도구",
        ESPBots = "ESP 봇", TPNearestBot = "가장 가까운 봇으로 TP", TPNearestDesc = "가장 가까운 봇 앞으로 순간이동",
        Fly = "비행", FlySpeed = "비행 속도", NoClip = "노클립", WalkSpeed = "이동 속도",
        AutoFarm = "자동 파밍", AutoFarmDelay = "파밍 딜레이(초)",
        BotMagnet = "봇 자석", BotMagnetDesc = "모든 봇을 한 곳에 모읍니다",
        AntiRagdoll = "안티 래그돌",
        Fullbright = "풀브라이트", LangSelect = "언어",
        CreditsTitle = "슈퍼 봇 브롤 허브",
        CreditsContent = "Rival960 제작\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — 첫 번째 릴리스",
        Loaded = "허브 로드 완료! 더 스마트하게 싸우자.", NoBot = "근처에 봇이 없습니다.",
    },
    AR = {
        WindowTitle = "سوبر بوت برول هاب", TabHome = "الرئيسية", TabVision = "الرؤية", TabMovement = "الحركة", TabCombat = "القتال", TabTools = "الأدوات",
        ESPBots = "ESP الروبوتات", TPNearestBot = "انتقال إلى أقرب روبوت", TPNearestDesc = "الانتقال أمام أقرب روبوت",
        Fly = "الطيران", FlySpeed = "سرعة الطيران", NoClip = "نوكليب", WalkSpeed = "سرعة المشي",
        AutoFarm = "زراعة تلقائية", AutoFarmDelay = "تأخير الزراعة (ث)",
        BotMagnet = "مغناطيس الروبوتات", BotMagnetDesc = "يجمع كل الروبوتات في مكان واحد",
        AntiRagdoll = "مضاد الراجدول",
        Fullbright = "إضاءة كاملة", LangSelect = "اللغة",
        CreditsTitle = "سوبر بوت برول هاب",
        CreditsContent = "أنشأه Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — الإصدار الأول",
        Loaded = "تم تحميل الهاب! قاتل بذكاء.", NoBot = "لم يتم العثور على روبوت قريب.",
    },
    VI = {
        WindowTitle = "Super Bot Brawl Hub", TabHome = "Trang chủ", TabVision = "Tầm nhìn", TabMovement = "Di chuyển", TabCombat = "Chiến đấu", TabTools = "Công cụ",
        ESPBots = "ESP Bots", TPNearestBot = "TP đến Bot gần nhất", TPNearestDesc = "Dịch chuyển đến phía trước bot gần nhất",
        Fly = "Bay", FlySpeed = "Tốc độ bay", NoClip = "NoClip", WalkSpeed = "Tốc độ đi bộ",
        AutoFarm = "Tự động Farm", AutoFarmDelay = "Độ trễ farm (s)",
        BotMagnet = "Nam Châm Bot", BotMagnetDesc = "Tập hợp tất cả bot ở một nơi",
        AntiRagdoll = "Chống Ragdoll",
        Fullbright = "Sáng tối đa", LangSelect = "Ngôn ngữ",
        CreditsTitle = "Super Bot Brawl Hub",
        CreditsContent = "Tạo bởi Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Phiên bản đầu tiên",
        Loaded = "Hub đã tải! Chiến đấu thông minh hơn.", NoBot = "Không tìm thấy bot nào gần đây.",
    },
    SV = {
        WindowTitle = "Super Bot Brawl Hub", TabHome = "Hem", TabVision = "Syn", TabMovement = "Rörelse", TabCombat = "Strid", TabTools = "Verktyg",
        ESPBots = "ESP Botar", TPNearestBot = "TP till närmaste Bot", TPNearestDesc = "Teleportera framför närmaste boten",
        Fly = "Flyg", FlySpeed = "Flyghastighet", NoClip = "NoClip", WalkSpeed = "Gånghastighet",
        AutoFarm = "Auto Farm", AutoFarmDelay = "Farmfördröjning (s)",
        BotMagnet = "Botmagnet", BotMagnetDesc = "Samlar alla botar på en plats",
        AntiRagdoll = "Anti Ragdoll",
        Fullbright = "Fullbright", LangSelect = "Språk",
        CreditsTitle = "Super Bot Brawl Hub",
        CreditsContent = "Skapad av Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Första utgåvan",
        Loaded = "Hub laddad! Kämpa smartare.", NoBot = "Ingen bot hittades i närheten.",
    },
    EL = {
        WindowTitle = "Super Bot Brawl Hub", TabHome = "Αρχική", TabVision = "Όραση", TabMovement = "Κίνηση", TabCombat = "Μάχη", TabTools = "Εργαλεία",
        ESPBots = "ESP Bots", TPNearestBot = "TP στο Κοντινότερο Bot", TPNearestDesc = "Τηλεμεταφορά μπροστά στο κοντινότερο bot",
        Fly = "Πτήση", FlySpeed = "Ταχύτητα Πτήσης", NoClip = "NoClip", WalkSpeed = "Ταχύτητα Βαδίσματος",
        AutoFarm = "Αυτόματο Farm", AutoFarmDelay = "Καθυστέρηση farm (δευτ.)",
        BotMagnet = "Μαγνήτης Bot", BotMagnetDesc = "Συγκεντρώνει όλα τα bots σε ένα σημείο",
        AntiRagdoll = "Anti Ragdoll",
        Fullbright = "Πλήρης Φωτεινότητα", LangSelect = "Γλώσσα",
        CreditsTitle = "Super Bot Brawl Hub",
        CreditsContent = "Δημιουργήθηκε από τον Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Πρώτη έκδοση",
        Loaded = "Hub φορτώθηκε! Μάχου εξυπνότερα.", NoBot = "Δεν βρέθηκε bot κοντά.",
    },
    RO = {
        WindowTitle = "Super Bot Brawl Hub", TabHome = "Acasă", TabVision = "Viziune", TabMovement = "Mișcare", TabCombat = "Luptă", TabTools = "Instrumente",
        ESPBots = "ESP Boți", TPNearestBot = "TP la Cel Mai Aproape Bot", TPNearestDesc = "Teleportare în fața celui mai apropiat bot",
        Fly = "Zbor", FlySpeed = "Viteza de zbor", NoClip = "NoClip", WalkSpeed = "Viteză de mers",
        AutoFarm = "Auto Farm", AutoFarmDelay = "Întârziere farm (s)",
        BotMagnet = "Magnet de Boți", BotMagnetDesc = "Adună toți boții într-un singur loc",
        AntiRagdoll = "Anti Ragdoll",
        Fullbright = "Luminozitate maximă", LangSelect = "Limbă",
        CreditsTitle = "Super Bot Brawl Hub",
        CreditsContent = "Creat de Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Prima versiune",
        Loaded = "Hub încărcat! Luptă mai inteligent.", NoBot = "Niciun bot găsit în apropiere.",
    },
    UK = {
        WindowTitle = "Super Bot Brawl Hub", TabHome = "Головна", TabVision = "Зір", TabMovement = "Рух", TabCombat = "Бій", TabTools = "Інструменти",
        ESPBots = "ESP ботів", TPNearestBot = "ТП до найближчого бота", TPNearestDesc = "Телепортуватися до найближчого бота",
        Fly = "Політ", FlySpeed = "Швидкість польоту", NoClip = "Нокліп", WalkSpeed = "Швидкість ходьби",
        AutoFarm = "Авто фарм", AutoFarmDelay = "Затримка фарму (с)",
        BotMagnet = "Магніт ботів", BotMagnetDesc = "Збирає всіх ботів в одному місці",
        AntiRagdoll = "Анти-рагдол",
        Fullbright = "Повна яскравість", LangSelect = "Мова",
        CreditsTitle = "Super Bot Brawl Hub",
        CreditsContent = "Створено Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Перший випуск",
        Loaded = "Hub завантажено! Бийся розумніше.", NoBot = "Поруч немає ботів.",
    },
    CS = {
        WindowTitle = "Super Bot Brawl Hub", TabHome = "Domů", TabVision = "Vidění", TabMovement = "Pohyb", TabCombat = "Boj", TabTools = "Nástroje",
        ESPBots = "ESP Boti", TPNearestBot = "TP k nejbližšímu Botovi", TPNearestDesc = "Přesuň se před nejbližšího bota",
        Fly = "Létání", FlySpeed = "Rychlost letu", NoClip = "NoClip", WalkSpeed = "Rychlost chůze",
        AutoFarm = "Auto Farm", AutoFarmDelay = "Zpoždění farmu (s)",
        BotMagnet = "Magnet na Boty", BotMagnetDesc = "Shromažďuje všechny boty na jednom místě",
        AntiRagdoll = "Anti Ragdoll",
        Fullbright = "Plné světlo", LangSelect = "Jazyk",
        CreditsTitle = "Super Bot Brawl Hub",
        CreditsContent = "Vytvořil Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — První verze",
        Loaded = "Hub načten! Bojuj chytřeji.", NoBot = "V okolí nebyl nalezen žádný bot.",
    },
    DA = {
        WindowTitle = "Super Bot Brawl Hub", TabHome = "Hjem", TabVision = "Syn", TabMovement = "Bevægelse", TabCombat = "Kamp", TabTools = "Værktøjer",
        ESPBots = "ESP Bots", TPNearestBot = "TP til nærmeste Bot", TPNearestDesc = "Teleportér foran den nærmeste bot",
        Fly = "Fly", FlySpeed = "Flyhastighed", NoClip = "NoClip", WalkSpeed = "Gåhastighed",
        AutoFarm = "Auto Farm", AutoFarmDelay = "Farm-forsinkelse (s)",
        BotMagnet = "Bot-Magnet", BotMagnetDesc = "Samler alle bots på ét sted",
        AntiRagdoll = "Anti Ragdoll",
        Fullbright = "Fuld lysstyrke", LangSelect = "Sprog",
        CreditsTitle = "Super Bot Brawl Hub",
        CreditsContent = "Oprettet af Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Første udgivelse",
        Loaded = "Hub indlæst! Kæmp klogere.", NoBot = "Ingen bot fundet i nærheden.",
    },
}

local function T(key)
    return (Translations[CurrentLang] and Translations[CurrentLang][key])
        or Translations["EN"][key]
        or key
end

local Settings = {
    AutoFarm         = false,
    AutoFarmDelay    = 0.1,
    BotMagnet        = false,
    ESP_Bots         = false,
    Fly              = false,
    FlySpeed         = 60,
    NoClip           = false,
    WalkSpeed        = 16,
    AntiRagdoll      = false,
    Fullbright       = false,
}

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

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
    LoadingSubtitle = "Created by Rival960 & Claude, DeepSeek",
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

local function getCharacterHeight()
    local char = LocalPlayer.Character
    if not char then return 5 end
    local ok, size = pcall(function()
        local _, sz = char:GetBoundingBox()
        return sz
    end)
    if ok and size then return size.Y end
    return 5
end

local function getBotHeight(botModel)
    if not botModel then return 5 end
    local ok, size = pcall(function()
        local _, sz = botModel:GetBoundingBox()
        return sz
    end)
    if ok and size then return size.Y end
    return 5
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
    if hum and not Settings.AutoFarm then hum.PlatformStand = false end
    local hrp = getHRP()
    if hrp then
        hrp.AssemblyLinearVelocity  = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    flyMobileVertical = 0
    if mobileFlyGui then mobileFlyGui.Enabled = false end
end

-- ───────────────────────────────────────────────────────────────
-- NOCLIP
-- ───────────────────────────────────────────────────────────────
local noclipConnection = nil
local originalCanCollide = {}

local function enableNoClip()
    if noclipConnection then return end
    originalCanCollide = {}
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            originalCanCollide[part] = part.CanCollide
            part.CanCollide = false
        end
    end
    noclipConnection = RunService.Heartbeat:Connect(function()
        if not Settings.NoClip then return end
        local c = LocalPlayer.Character
        if not c then return end
        local hrp = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChildOfClass("Humanoid")
        for _, part in ipairs(c:GetDescendants()) do
            if part:IsA("BasePart") then
                if originalCanCollide[part] == nil then
                    originalCanCollide[part] = part.CanCollide
                end
                if part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
        if hrp and hum and hum.MoveDirection.Magnitude < 0.1 then
            local v = hrp.AssemblyLinearVelocity
            hrp.AssemblyLinearVelocity = Vector3.new(0, v.Y, 0)
        end
    end)
end

local function disableNoClip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    for part, originalState in pairs(originalCanCollide) do
        if part and part.Parent then
            part.CanCollide = originalState
        end
    end
    originalCanCollide = {}
end

-- ───────────────────────────────────────────────────────────────
-- ANTI RAGDOLL
-- ───────────────────────────────────────────────────────────────
local antiRagdollConn = nil
local ragdollConstraintConn = nil
local blockedStates = {
    [Enum.HumanoidStateType.Ragdoll] = true,
    [Enum.HumanoidStateType.FallingDown] = true,
    [Enum.HumanoidStateType.Physics] = true,
    [Enum.HumanoidStateType.Dead] = true,
}

local function cleanRagdollMinimal(char)
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("Motor6D") and not v.Enabled then
            pcall(function() v.Enabled = true end)
        elseif v:IsA("BallSocketConstraint") or v:IsA("HingeConstraint") then
            pcall(function() v:Destroy() end)
        end
    end
end

local function enableAntiRagdoll()
    if antiRagdollConn then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    for state in pairs(blockedStates) do
        pcall(function() hum:SetStateEnabled(state, false) end)
    end
    antiRagdollConn = hum.StateChanged:Connect(function(_, newState)
        if not Settings.AntiRagdoll then return end
        if blockedStates[newState] then
            local c = LocalPlayer.Character
            if c then cleanRagdollMinimal(c) end
        end
    end)
    ragdollConstraintConn = char.DescendantAdded:Connect(function(desc)
        if not Settings.AntiRagdoll then return end
        if desc:IsA("BallSocketConstraint") or desc:IsA("HingeConstraint") then
            task.defer(function() pcall(function() desc:Destroy() end) end)
        end
    end)
end

local function disableAntiRagdoll()
    if antiRagdollConn then antiRagdollConn:Disconnect(); antiRagdollConn = nil end
    if ragdollConstraintConn then ragdollConstraintConn:Disconnect(); ragdollConstraintConn = nil end
    local hum = getHumanoid()
    if hum then
        for state in pairs(blockedStates) do
            pcall(function() hum:SetStateEnabled(state, true) end)
        end
    end
end

-- ───────────────────────────────────────────────────────────────
-- BOT MAGNET (PivotTo loop, ignores bot chase AI)
-- ───────────────────────────────────────────────────────────────
local botMagnetConnection = nil
local magnetAnchor = nil
local lastMagnetTick = 0
local magnetOriginalCollide = {}

local function getMagnetAnchor()
    return magnetAnchor
end

local function doBotMagnet()
    if not Settings.BotMagnet then
        magnetAnchor = nil
        return
    end

    local now = tick()
    if now - lastMagnetTick < 0.1 then return end
    lastMagnetTick = now

    local hrp = getHRP()
    if not hrp then return end

    if not magnetAnchor or (hrp.Position - magnetAnchor).Magnitude > 30 then
        magnetAnchor = hrp.Position + hrp.CFrame.LookVector * 10
        magnetAnchor = Vector3.new(magnetAnchor.X, hrp.Position.Y, magnetAnchor.Z)
    end

    local botsFolder = Workspace:FindFirstChild("Bots")
    if not botsFolder then return end

    local idx = 0
    for _, obj in ipairs(botsFolder:GetDescendants()) do
        if isBot(obj) then
            local bhrp = obj:FindFirstChild("HumanoidRootPart")
            if bhrp then
                if bhrp.Anchored then bhrp.Anchored = false end

                -- Disable collision on bot parts during magnet
                for _, part in ipairs(obj:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        if magnetOriginalCollide[part] == nil then
                            magnetOriginalCollide[part] = true
                        end
                        part.CanCollide = false
                    end
                end

                local row = math.floor(idx / 4)
                local col = idx % 4
                local targetX = magnetAnchor.X + (col - 1.5) * 8
                local targetZ = magnetAnchor.Z + row * 8
                local targetPos = Vector3.new(targetX, magnetAnchor.Y, targetZ)

                -- PivotTo overrides bot chase AI. Do it every tick to keep them there.
                pcall(function()
                    obj:PivotTo(CFrame.new(targetPos))
                end)

                idx = idx + 1
            end
        end
    end
end

local function enableBotMagnet()
    if botMagnetConnection then return end
    magnetAnchor = nil
    lastMagnetTick = 0
    magnetOriginalCollide = {}
    botMagnetConnection = RunService.Heartbeat:Connect(function()
        if not Settings.BotMagnet then return end
        pcall(doBotMagnet)
    end)
end

local function disableBotMagnet()
    if botMagnetConnection then
        botMagnetConnection:Disconnect()
        botMagnetConnection = nil
    end
    for part, _ in pairs(magnetOriginalCollide) do
        if part and part.Parent then
            part.CanCollide = true
        end
    end
    magnetOriginalCollide = {}
    magnetAnchor = nil
end

-- ───────────────────────────────────────────────────────────────
-- ANTI TOUCH (during Auto Farm: stop bots & player from touching)
-- ───────────────────────────────────────────────────────────────
local antiTouchFarmState = {}
local antiTouchFarmStateSaved = false

local function saveAndDisableTouch()
    if antiTouchFarmStateSaved then return end
    antiTouchFarmStateSaved = true
    antiTouchFarmState = {}

    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                antiTouchFarmState[part] = {
                    CanTouch = part.CanTouch,
                    TouchInterest = part:FindFirstChildOfClass("TouchInterest"),
                }
                part.CanTouch = false
                local ti = part:FindFirstChildOfClass("TouchInterest")
                if ti then pcall(function() ti:Destroy() end) end
            end
        end
    end

    local botsFolder = Workspace:FindFirstChild("Bots")
    if botsFolder then
        for _, obj in ipairs(botsFolder:GetDescendants()) do
            if isBot(obj) then
                for _, part in ipairs(obj:GetDescendants()) do
                    if part:IsA("BasePart") then
                        antiTouchFarmState[part] = {
                            CanTouch = part.CanTouch,
                            TouchInterest = part:FindFirstChildOfClass("TouchInterest"),
                        }
                        part.CanTouch = false
                        local ti = part:FindFirstChildOfClass("TouchInterest")
                        if ti then pcall(function() ti:Destroy() end) end
                    end
                end
            end
        end
    end
end

local function restoreTouch()
    if not antiTouchFarmStateSaved then return end
    antiTouchFarmStateSaved = false
    for part, state in pairs(antiTouchFarmState) do
        if part and part.Parent then
            pcall(function() part.CanTouch = state.CanTouch end)
        end
    end
    antiTouchFarmState = {}
end

-- ───────────────────────────────────────────────────────────────
-- AUTO FARM (no God Mode, CanTouch disabled, safe height)
-- ───────────────────────────────────────────────────────────────
local lastFarmTime = 0
local lastTeleportTime = 0
local farmActive = false
local botHeights = setmetatable({}, { __mode = "k" })

local function restoreFarmState()
    farmActive = false
    restoreTouch()
    local hum = getHumanoid()
    if hum then hum.PlatformStand = false end
end

local function doAutoFarm()
    if not Settings.AutoFarm then
        if farmActive then restoreFarmState() end
        return
    end
    farmActive = true

    -- Disable touch on player and bots while farming (no God Mode needed)
    saveAndDisableTouch()

    local now = tick()
    if now - lastFarmTime < Settings.AutoFarmDelay then return end
    lastFarmTime = now

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    -- If Bot Magnet is active, position above the cluster
    local targetHRP = nil
    local targetModel = nil

    if Settings.BotMagnet and magnetAnchor then
        targetHRP = magnetAnchor
        -- find a bot from cluster for height reference
        local botModel, botHRP = getNearestBot()
        if botHRP then targetModel = botModel end
    else
        local botModel, botHRP = getNearestBot()
        if botHRP then
            targetHRP = botHRP.Position
            targetModel = botModel
        end
    end

    if not targetHRP then return end

    hum.PlatformStand = true

    local botHeight = 5
    if targetModel then
        local cached = botHeights[targetModel]
        if cached then
            botHeight = cached
        else
            botHeight = getBotHeight(targetModel)
            botHeights[targetModel] = botHeight
        end
    end
    local charHeight = getCharacterHeight()

    -- Place player feet 2 studs above bot HEAD
    -- HRP.Y = botTop + charHeight/2 + 2 = (targetHRP.Y + botHeight/2) + charHeight/2 + 2
    -- For a small char (3) and small bot (4): HRP.Y = target + 2 + 1.5 + 2 = target + 5.5
    -- For a big char (7) and big bot (8): HRP.Y = target + 4 + 3.5 + 2 = target + 9.5
    local targetY = targetHRP.Y + (botHeight / 2) + (charHeight / 2) + 2

    local dist = (hrp.Position - targetHRP).Magnitude
    if now - lastTeleportTime > 0.35 or dist > 10 then
        lastTeleportTime = now
        -- Horizontal: 2 studs offset for tool range
        local flatDir = Vector3.new(hrp.Position.X - targetHRP.X, 0, hrp.Position.Z - targetHRP.Z)
        if flatDir.Magnitude < 0.5 then
            flatDir = Vector3.new(2, 0, 0)
        else
            flatDir = flatDir.Unit * 2
        end
        local targetPos = Vector3.new(targetHRP.X + flatDir.X, targetY, targetHRP.Z + flatDir.Z)
        hrp.CFrame = CFrame.lookAt(targetPos, Vector3.new(targetHRP.X, targetY, targetHRP.Z))
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    else
        local lookAt = Vector3.new(targetHRP.X, hrp.Position.Y, targetHRP.Z)
        if (hrp.Position - lookAt).Magnitude > 0.5 then
            hrp.CFrame = CFrame.lookAt(hrp.Position, lookAt)
        end
    end

    -- Equip tool
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            local newTool = backpack:FindFirstChildOfClass("Tool")
            if newTool then
                hum:EquipTool(newTool)
                task.wait(0.05)
                tool = newTool
            end
        end
    end

    local botHum = targetModel and targetModel:FindFirstChildOfClass("Humanoid")

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
end

-- ───────────────────────────────────────────────────────────────
-- TABS
-- ───────────────────────────────────────────────────────────────

local TabHome = Window:CreateTab(T("TabHome"), 4483362458)
TabHome:CreateParagraph({ Title = T("CreditsTitle"), Content = T("CreditsContent") })

local TabVision = Window:CreateTab(T("TabVision"), 4483362458)
TabVision:CreateToggle({ Name = T("ESPBots"), CurrentValue = Settings.ESP_Bots, Flag = "ESP_Bots", Callback = function(v) Settings.ESP_Bots = v end })
TabVision:CreateButton({
    Name = T("TPNearestBot"),
    Callback = function()
        local hrp = getHRP(); if not hrp then return end
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
TabMovement:CreateToggle({ Name = T("Fly"), CurrentValue = Settings.Fly, Flag = "Fly", Callback = function(v) Settings.Fly = v; if v then enableFly() else disableFly() end end })
TabMovement:CreateSlider({ Name = T("FlySpeed"), Range = {10, 300}, Increment = 5, CurrentValue = Settings.FlySpeed, Flag = "FlySpeed", Callback = function(v) Settings.FlySpeed = v end })
TabMovement:CreateToggle({ Name = T("NoClip"), CurrentValue = Settings.NoClip, Flag = "NoClip", Callback = function(v) Settings.NoClip = v; if v then enableNoClip() else disableNoClip() end end })
TabMovement:CreateSlider({ Name = T("WalkSpeed"), Range = {16, 250}, Increment = 1, CurrentValue = Settings.WalkSpeed, Flag = "WalkSpeed", Callback = function(v) Settings.WalkSpeed = v; local hum = getHumanoid(); if hum then hum.WalkSpeed = v end end })

local TabCombat = Window:CreateTab(T("TabCombat"), 4483362458)
TabCombat:CreateToggle({ Name = T("AutoFarm"), CurrentValue = Settings.AutoFarm, Flag = "AutoFarm", Callback = function(v) Settings.AutoFarm = v; if not v then restoreFarmState() end end })
TabCombat:CreateSlider({ Name = T("AutoFarmDelay"), Range = {0.1, 2.0}, Increment = 0.1, CurrentValue = Settings.AutoFarmDelay, Flag = "AutoFarmDelay", Callback = function(v) Settings.AutoFarmDelay = v end })
TabCombat:CreateToggle({ Name = T("BotMagnet"), CurrentValue = Settings.BotMagnet, Flag = "BotMagnet", Callback = function(v) Settings.BotMagnet = v; if v then enableBotMagnet() else disableBotMagnet() end end })
TabCombat:CreateToggle({ Name = T("AntiRagdoll"), CurrentValue = Settings.AntiRagdoll, Flag = "AntiRagdoll", Callback = function(v) Settings.AntiRagdoll = v; if v then enableAntiRagdoll() else disableAntiRagdoll() end end })

local TabTools = Window:CreateTab(T("TabTools"), 4483362458)
TabTools:CreateToggle({ Name = T("Fullbright"), CurrentValue = Settings.Fullbright, Flag = "Fullbright", Callback = function(v)
    Settings.Fullbright = v
    if v then
        Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.GlobalShadows = false
    else
        Lighting.Brightness = 1; Lighting.ClockTime = 14; Lighting.GlobalShadows = true
    end
end })

local langOptions = {"EN","FR","DE","ES","PT","RU","IT","NL","PL","ZH","JA","TR","KO","AR","VI","SV","EL","RO","UK","CS","DA"}
TabTools:CreateDropdown({
    Name = T("LangSelect"), Options = langOptions, CurrentOption = {CurrentLang}, Flag = "Language",
    Callback = function(selected)
        CurrentLang = selected[1] or selected
        Rayfield:Notify({ Title = "Language", Content = "Re-execute the script to apply the new language.", Duration = 4 })
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

    if Settings.Fly and flyVelocity and flyGyro and hrp then
        local cam = Workspace.CurrentCamera
        local speed = Settings.FlySpeed
        local dir = Vector3.zero
        if isMobile then
            local move = hum and hum.MoveDirection or Vector3.zero
            dir = move
            if flyMobileVertical ~= 0 then
                dir = dir + Vector3.new(0, flyMobileVertical, 0)
            end
        else
            local uis = UserInputService
            if uis:IsKeyDown(Enum.KeyCode.W) or uis:IsKeyDown(Enum.KeyCode.Up) then dir = dir + cam.CFrame.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.S) or uis:IsKeyDown(Enum.KeyCode.Down) then dir = dir - cam.CFrame.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.A) or uis:IsKeyDown(Enum.KeyCode.Left) then dir = dir - cam.CFrame.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.D) or uis:IsKeyDown(Enum.KeyCode.Right) then dir = dir + cam.CFrame.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
            if uis:IsKeyDown(Enum.KeyCode.LeftShift) or uis:IsKeyDown(Enum.KeyCode.RightShift) then dir = dir - Vector3.new(0, 1, 0) end
        end
        flyVelocity.Velocity = dir.Magnitude > 0 and dir.Unit * speed or Vector3.zero
        flyGyro.CFrame = cam.CFrame
    end

    if Settings.ESP_Bots then
        local botsFolder = Workspace:FindFirstChild("Bots")
        if botsFolder then
            for _, obj in ipairs(botsFolder:GetDescendants()) do
                if isBot(obj) then
                    local botHum = obj:FindFirstChildOfClass("Humanoid")
                    local hl = obj:FindFirstChild("_BotESP_Highlight")
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = "_BotESP_Highlight"
                        hl.FillColor = Color3.fromRGB(255, 60, 60)
                        hl.OutlineColor = Color3.fromRGB(255, 200, 0)
                        hl.FillTransparency = 0.4
                        hl.Parent = obj
                    end
                    local bhrp = obj:FindFirstChild("HumanoidRootPart")
                    if bhrp then
                        local bb = bhrp:FindFirstChild("_BotESP_BB")
                        if not bb then
                            bb = Instance.new("BillboardGui")
                            bb.Name = "_BotESP_BB"
                            bb.Size = UDim2.new(0, 120, 0, 40)
                            bb.StudsOffset = Vector3.new(0, 3, 0)
                            bb.AlwaysOnTop = true
                            bb.Parent = bhrp
                            local lbl = Instance.new("TextLabel")
                            lbl.Name = "Label"
                            lbl.Size = UDim2.new(1, 0, 1, 0)
                            lbl.BackgroundTransparency = 1
                            lbl.TextColor3 = Color3.fromRGB(255, 240, 100)
                            lbl.TextStrokeTransparency = 0
                            lbl.TextScaled = true
                            lbl.Font = Enum.Font.GothamBold
                            lbl.Parent = bb
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

    if hum and hum.WalkSpeed ~= Settings.WalkSpeed and not Settings.Fly and not Settings.AutoFarm then
        hum.WalkSpeed = Settings.WalkSpeed
    end
end)

RunService.Heartbeat:Connect(doAutoFarm)

LocalPlayer.CharacterAdded:Connect(function(_character)
    task.wait(0.5)
    if Settings.Fly then disableFly(); task.wait(0.1); enableFly() end
    if Settings.NoClip then enableNoClip() end
    if Settings.AntiRagdoll then enableAntiRagdoll() end
    local hum = getHumanoid()
    if hum then hum.WalkSpeed = Settings.WalkSpeed end
end)

Rayfield:Notify({ Title = T("WindowTitle"), Content = T("Loaded"), Duration = 4 })

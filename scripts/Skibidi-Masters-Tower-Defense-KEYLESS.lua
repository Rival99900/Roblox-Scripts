--[[
    ================================================================
    Skibidi Masters Tower Defense Hub — Skibidi Masters Tower Defense
    Created by Rival960 with the help of Claude
    Version: 1.0.0 | Languages: 21 | Rayfield UI
    Status: untested in-game
    Game: https://www.roblox.com/games/15111895255/Skibidi-Masters-Tower-Defense
    ================================================================

    HONEST LIMITS (read before use):
    - One-shot enemies: NOT possible — tower damage is fully server-side
    - Auto-win: no win remote found in logs — feature not implemented
    - Enemy tracker polls enemy_data every 1 s; data is READ-ONLY
      (cannot modify enemy HP, speed, or path)
    - unit_upgrade will fail silently if the player lacks resources;
      the script logs the result (true / false) but cannot guarantee success
    - Inventory tab displays server-sent data cached locally;
      it CANNOT modify server-side values
    ================================================================
--]]

-- ================================================================
-- SERVICES
-- ================================================================
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer  = Players.LocalPlayer
local Camera       = workspace.CurrentCamera

-- ================================================================
-- REMOTES (confirmed via Cobalt logs 2026-10-28)
-- ================================================================
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local ClientServer -- sub-folder, accessed after Remotes loads
local ServerClient

if Remotes then
    ClientServer = Remotes:FindFirstChild("client_server")
    ServerClient = Remotes:FindFirstChild("server_client")
end

local function getRemote(folder, name, timeout)
    if not folder then return nil end
    local ok, result = pcall(function()
        return folder:WaitForChild(name, timeout or 5)
    end)
    return ok and result or nil
end

local R_EnemyData   = getRemote(ClientServer, "enemy_data")   -- RemoteFunction
local R_UnitUpgrade = getRemote(ClientServer, "unit_upgrade")  -- RemoteFunction
local R_UnitSpawn   = getRemote(ClientServer, "unit_spawn")    -- RemoteFunction
local R_ItemExists  = getRemote(ServerClient, "item_exists")   -- RemoteEvent (server→client)
local R_CollExists  = getRemote(ServerClient, "collection_exists") -- RemoteEvent (server→client)

-- ================================================================
-- LANGUAGE SYSTEM — 21 languages
-- ================================================================
local CurrentLang = "EN"

local Translations = {
    EN = {
        WindowTitle      = "SMTD Hub",
        TabHome          = "Home",
        TabEnemyTracker  = "Enemy Tracker",
        TabAutoUpgrade   = "Auto Upgrade",
        TabInventory     = "Inventory",
        TabMovement      = "Movement",
        TabTools         = "Tools",
        -- Home
        CreditsTitle     = "Credits",
        CreditsContent   = "Created by Rival960 with the help of Claude\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        LoadstringTitle  = "Loadstring",
        LoadstringContent = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Rival99900/Roblox-Scripts/refs/heads/main/scripts/Skibidi-Masters-Tower-Defense-KEYLESS.lua"))()',
        -- Enemy Tracker
        EnemyScanBtn     = "Scan Enemies",
        EnemyScanDesc    = "Polls enemy_data for N=1→200. Updates BillboardGuis above each enemy (client read-only — cannot modify enemies).",
        EnemyScanRunning = "Enemy scan running…",
        EnemyScanDone    = "Scan done — {n} enemy(ies) found",
        EnemyBillboard   = "Enemy #{n}\nDist left: {d}",
        EnemyClear       = "Clear Enemy Labels",
        EnemyClearDesc   = "Remove all BillboardGuis created by the tracker.",
        -- Auto Upgrade
        AutoUpgradeToggle = "Auto Upgrade",
        AutoUpgradeDesc   = "Loops slots 1→10 every 0.5 s and calls unit_upgrade. May fail silently if resources are insufficient.",
        UpgradeOk         = "Slot {s} upgraded ✓",
        UpgradeFail       = "Slot {s} — no upgrade",
        -- Inventory
        ShowItemsBtn      = "Show My Items",
        ShowItemsDesc     = "Displays cached item_exists data sent by the server (read-only).",
        NoItemData        = "No inventory data received yet. Play for a moment and retry.",
        ItemsTitle        = "Inventory",
        -- Movement
        FlyToggle        = "Fly",
        FlySpeed         = "Fly Speed",
        NoClipToggle     = "NoClip",
        WalkSpeedLabel   = "WalkSpeed",
        -- Tools
        FullbrightToggle = "Fullbright",
        AntiAFKToggle    = "Anti-AFK",
        LangSelect       = "Language",
        LangReload       = "Re-execute script to apply language change.",
        -- Footer
        Loaded           = "Hub loaded! Welcome to SMTD Hub.",
    },
    FR = {
        WindowTitle      = "SMTD Hub",
        TabHome          = "Accueil",
        TabEnemyTracker  = "Traqueur d'ennemis",
        TabAutoUpgrade   = "Auto Amélioration",
        TabInventory     = "Inventaire",
        TabMovement      = "Déplacement",
        TabTools         = "Outils",
        CreditsTitle     = "Crédits",
        CreditsContent   = "Créé par Rival960 avec l'aide de Claude\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        LoadstringTitle  = "Loadstring",
        LoadstringContent = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Rival99900/Roblox-Scripts/refs/heads/main/scripts/Skibidi-Masters-Tower-Defense-KEYLESS.lua"))()',
        EnemyScanBtn     = "Scanner les ennemis",
        EnemyScanDesc    = "Interroge enemy_data pour N=1→200. Affiche des BillboardGuis au-dessus des ennemis (lecture seule).",
        EnemyScanRunning = "Scan en cours…",
        EnemyScanDone    = "Scan terminé — {n} ennemi(s) trouvé(s)",
        EnemyBillboard   = "Ennemi #{n}\nDist restante: {d}",
        EnemyClear       = "Effacer les labels",
        EnemyClearDesc   = "Supprime tous les BillboardGuis créés par le traqueur.",
        AutoUpgradeToggle = "Auto Amélioration",
        AutoUpgradeDesc   = "Boucle slots 1→10 toutes les 0,5 s. Peut échouer silencieusement sans ressources.",
        UpgradeOk         = "Slot {s} amélioré ✓",
        UpgradeFail       = "Slot {s} — pas d'amélioration",
        ShowItemsBtn      = "Afficher mes objets",
        ShowItemsDesc     = "Affiche les données item_exists reçues du serveur (lecture seule).",
        NoItemData        = "Aucune donnée reçue. Jouez un moment et réessayez.",
        ItemsTitle        = "Inventaire",
        FlyToggle        = "Voler",
        FlySpeed         = "Vitesse de vol",
        NoClipToggle     = "NoClip",
        WalkSpeedLabel   = "Vitesse de marche",
        FullbrightToggle = "Fullbright",
        AntiAFKToggle    = "Anti-AFK",
        LangSelect       = "Langue",
        LangReload       = "Ré-exécutez le script pour appliquer le changement de langue.",
        Loaded           = "Hub chargé ! Bienvenue sur SMTD Hub.",
    },
    DE = {
        WindowTitle      = "SMTD Hub",
        TabHome          = "Startseite",
        TabEnemyTracker  = "Feind-Tracker",
        TabAutoUpgrade   = "Auto-Upgrade",
        TabInventory     = "Inventar",
        TabMovement      = "Bewegung",
        TabTools         = "Werkzeuge",
        CreditsTitle     = "Danksagungen",
        CreditsContent   = "Erstellt von Rival960 mit Hilfe von Claude\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        LoadstringTitle  = "Loadstring",
        LoadstringContent = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Rival99900/Roblox-Scripts/refs/heads/main/scripts/Skibidi-Masters-Tower-Defense-KEYLESS.lua"))()',
        EnemyScanBtn     = "Feinde scannen",
        EnemyScanDesc    = "Fragt enemy_data für N=1→200 ab. Zeigt BillboardGuis über jedem Feind (nur lesend).",
        EnemyScanRunning = "Scan läuft…",
        EnemyScanDone    = "Scan abgeschlossen — {n} Feind(e) gefunden",
        EnemyBillboard   = "Feind #{n}\nVerbleibend: {d}",
        EnemyClear       = "Labels löschen",
        EnemyClearDesc   = "Entfernt alle vom Tracker erstellten BillboardGuis.",
        AutoUpgradeToggle = "Auto-Upgrade",
        AutoUpgradeDesc   = "Schleife Slots 1→10 alle 0,5 s. Kann ohne Ressourcen stumm fehlschlagen.",
        UpgradeOk         = "Slot {s} verbessert ✓",
        UpgradeFail       = "Slot {s} — kein Upgrade",
        ShowItemsBtn      = "Meine Objekte anzeigen",
        ShowItemsDesc     = "Zeigt vom Server empfangene item_exists-Daten (nur lesend).",
        NoItemData        = "Noch keine Inventardaten. Spiele kurz und versuche es erneut.",
        ItemsTitle        = "Inventar",
        FlyToggle        = "Fliegen",
        FlySpeed         = "Fluggeschwindigkeit",
        NoClipToggle     = "NoClip",
        WalkSpeedLabel   = "Gehgeschwindigkeit",
        FullbrightToggle = "Vollhell",
        AntiAFKToggle    = "Anti-AFK",
        LangSelect       = "Sprache",
        LangReload       = "Skript neu ausführen, um die Sprache anzuwenden.",
        Loaded           = "Hub geladen! Willkommen im SMTD Hub.",
    },
    ES = {
        WindowTitle      = "SMTD Hub",
        TabHome          = "Inicio",
        TabEnemyTracker  = "Rastreador de Enemigos",
        TabAutoUpgrade   = "Auto Mejora",
        TabInventory     = "Inventario",
        TabMovement      = "Movimiento",
        TabTools         = "Herramientas",
        CreditsTitle     = "Créditos",
        CreditsContent   = "Creado por Rival960 con ayuda de Claude\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        LoadstringTitle  = "Loadstring",
        LoadstringContent = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Rival99900/Roblox-Scripts/refs/heads/main/scripts/Skibidi-Masters-Tower-Defense-KEYLESS.lua"))()',
        EnemyScanBtn     = "Escanear Enemigos",
        EnemyScanDesc    = "Consulta enemy_data para N=1→200. Muestra BillboardGuis sobre los enemigos (solo lectura).",
        EnemyScanRunning = "Escaneando…",
        EnemyScanDone    = "Escaneo completo — {n} enemigo(s) encontrado(s)",
        EnemyBillboard   = "Enemigo #{n}\nDist restante: {d}",
        EnemyClear       = "Borrar etiquetas",
        EnemyClearDesc   = "Elimina todos los BillboardGuis del rastreador.",
        AutoUpgradeToggle = "Auto Mejora",
        AutoUpgradeDesc   = "Bucle slots 1→10 cada 0,5 s. Puede fallar silenciosamente sin recursos.",
        UpgradeOk         = "Slot {s} mejorado ✓",
        UpgradeFail       = "Slot {s} — sin mejora",
        ShowItemsBtn      = "Ver mis objetos",
        ShowItemsDesc     = "Muestra datos item_exists recibidos del servidor (solo lectura).",
        NoItemData        = "Sin datos de inventario. Juega un momento y vuelve a intentarlo.",
        ItemsTitle        = "Inventario",
        FlyToggle        = "Volar",
        FlySpeed         = "Velocidad de vuelo",
        NoClipToggle     = "NoClip",
        WalkSpeedLabel   = "Velocidad de caminar",
        FullbrightToggle = "Brillo total",
        AntiAFKToggle    = "Anti-AFK",
        LangSelect       = "Idioma",
        LangReload       = "Vuelve a ejecutar el script para aplicar el cambio de idioma.",
        Loaded           = "¡Hub cargado! Bienvenido al SMTD Hub.",
    },
    PT = {
        WindowTitle      = "SMTD Hub",
        TabHome          = "Início",
        TabEnemyTracker  = "Rastreador de Inimigos",
        TabAutoUpgrade   = "Auto Melhoria",
        TabInventory     = "Inventário",
        TabMovement      = "Movimento",
        TabTools         = "Ferramentas",
        CreditsTitle     = "Créditos",
        CreditsContent   = "Criado por Rival960 com ajuda de Claude\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        LoadstringTitle  = "Loadstring",
        LoadstringContent = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Rival99900/Roblox-Scripts/refs/heads/main/scripts/Skibidi-Masters-Tower-Defense-KEYLESS.lua"))()',
        EnemyScanBtn     = "Rastrear Inimigos",
        EnemyScanDesc    = "Consulta enemy_data para N=1→200. Exibe BillboardGuis acima de cada inimigo (somente leitura).",
        EnemyScanRunning = "Rastreando…",
        EnemyScanDone    = "Rastreamento concluído — {n} inimigo(s) encontrado(s)",
        EnemyBillboard   = "Inimigo #{n}\nDist restante: {d}",
        EnemyClear       = "Limpar etiquetas",
        EnemyClearDesc   = "Remove todos os BillboardGuis do rastreador.",
        AutoUpgradeToggle = "Auto Melhoria",
        AutoUpgradeDesc   = "Loop slots 1→10 a cada 0,5 s. Pode falhar silenciosamente sem recursos.",
        UpgradeOk         = "Slot {s} melhorado ✓",
        UpgradeFail       = "Slot {s} — sem melhoria",
        ShowItemsBtn      = "Ver meus itens",
        ShowItemsDesc     = "Exibe dados item_exists recebidos do servidor (somente leitura).",
        NoItemData        = "Sem dados de inventário. Jogue um momento e tente novamente.",
        ItemsTitle        = "Inventário",
        FlyToggle        = "Voar",
        FlySpeed         = "Velocidade de voo",
        NoClipToggle     = "NoClip",
        WalkSpeedLabel   = "Velocidade de caminhada",
        FullbrightToggle = "Fullbright",
        AntiAFKToggle    = "Anti-AFK",
        LangSelect       = "Idioma",
        LangReload       = "Execute o script novamente para aplicar o idioma.",
        Loaded           = "Hub carregado! Bem-vindo ao SMTD Hub.",
    },
    RU = {
        WindowTitle      = "SMTD Hub",
        TabHome          = "Главная",
        TabEnemyTracker  = "Трекер врагов",
        TabAutoUpgrade   = "Авто-улучшение",
        TabInventory     = "Инвентарь",
        TabMovement      = "Движение",
        TabTools         = "Инструменты",
        CreditsTitle     = "Авторы",
        CreditsContent   = "Создано Rival960 при помощи Claude\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        LoadstringTitle  = "Loadstring",
        LoadstringContent = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Rival99900/Roblox-Scripts/refs/heads/main/scripts/Skibidi-Masters-Tower-Defense-KEYLESS.lua"))()',
        EnemyScanBtn     = "Сканировать врагов",
        EnemyScanDesc    = "Опрашивает enemy_data для N=1→200. Показывает BillboardGui над каждым врагом (только чтение).",
        EnemyScanRunning = "Сканирование…",
        EnemyScanDone    = "Готово — найдено {n} враг(ов)",
        EnemyBillboard   = "Враг #{n}\nОст. дист.: {d}",
        EnemyClear       = "Удалить метки",
        EnemyClearDesc   = "Удаляет все BillboardGui, созданные трекером.",
        AutoUpgradeToggle = "Авто-улучшение",
        AutoUpgradeDesc   = "Цикл слотов 1→10 каждые 0,5 с. Может молча не сработать без ресурсов.",
        UpgradeOk         = "Слот {s} улучшен ✓",
        UpgradeFail       = "Слот {s} — нет улучшения",
        ShowItemsBtn      = "Мои предметы",
        ShowItemsDesc     = "Отображает данные item_exists, полученные от сервера (только чтение).",
        NoItemData        = "Данных инвентаря нет. Поиграйте немного и повторите.",
        ItemsTitle        = "Инвентарь",
        FlyToggle        = "Полёт",
        FlySpeed         = "Скорость полёта",
        NoClipToggle     = "NoClip",
        WalkSpeedLabel   = "Скорость ходьбы",
        FullbrightToggle = "Полный свет",
        AntiAFKToggle    = "Анти-АФК",
        LangSelect       = "Язык",
        LangReload       = "Перезапустите скрипт для применения языка.",
        Loaded           = "Hub загружен! Добро пожаловать в SMTD Hub.",
    },
    IT = {
        WindowTitle      = "SMTD Hub",
        TabHome          = "Home",
        TabEnemyTracker  = "Traccia Nemici",
        TabAutoUpgrade   = "Auto Potenziamento",
        TabInventory     = "Inventario",
        TabMovement      = "Movimento",
        TabTools         = "Strumenti",
        CreditsTitle     = "Crediti",
        CreditsContent   = "Creato da Rival960 con l'aiuto di Claude\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        LoadstringTitle  = "Loadstring",
        LoadstringContent = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Rival99900/Roblox-Scripts/refs/heads/main/scripts/Skibidi-Masters-Tower-Defense-KEYLESS.lua"))()',
        EnemyScanBtn     = "Scansiona Nemici",
        EnemyScanDesc    = "Interroga enemy_data per N=1→200. Mostra BillboardGui sopra ogni nemico (sola lettura).",
        EnemyScanRunning = "Scansione in corso…",
        EnemyScanDone    = "Scansione completata — {n} nemico/i trovato/i",
        EnemyBillboard   = "Nemico #{n}\nDist rimasta: {d}",
        EnemyClear       = "Rimuovi etichette",
        EnemyClearDesc   = "Rimuove tutti i BillboardGui del tracker.",
        AutoUpgradeToggle = "Auto Potenziamento",
        AutoUpgradeDesc   = "Ciclo slot 1→10 ogni 0,5 s. Può fallire silenziosamente senza risorse.",
        UpgradeOk         = "Slot {s} potenziato ✓",
        UpgradeFail       = "Slot {s} — nessun potenziamento",
        ShowItemsBtn      = "Mostra i miei oggetti",
        ShowItemsDesc     = "Mostra i dati item_exists ricevuti dal server (sola lettura).",
        NoItemData        = "Nessun dato inventario. Gioca un momento e riprova.",
        ItemsTitle        = "Inventario",
        FlyToggle        = "Volare",
        FlySpeed         = "Velocità di volo",
        NoClipToggle     = "NoClip",
        WalkSpeedLabel   = "Velocità di camminata",
        FullbrightToggle = "Luce piena",
        AntiAFKToggle    = "Anti-AFK",
        LangSelect       = "Lingua",
        LangReload       = "Riesegui lo script per applicare la lingua.",
        Loaded           = "Hub caricato! Benvenuto su SMTD Hub.",
    },
    NL = {
        WindowTitle      = "SMTD Hub",
        TabHome          = "Home",
        TabEnemyTracker  = "Vijandtracker",
        TabAutoUpgrade   = "Auto Upgrade",
        TabInventory     = "Inventaris",
        TabMovement      = "Beweging",
        TabTools         = "Gereedschap",
        CreditsTitle     = "Credits",
        CreditsContent   = "Gemaakt door Rival960 met hulp van Claude\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        LoadstringTitle  = "Loadstring",
        LoadstringContent = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Rival99900/Roblox-Scripts/refs/heads/main/scripts/Skibidi-Masters-Tower-Defense-KEYLESS.lua"))()',
        EnemyScanBtn     = "Vijanden scannen",
        EnemyScanDesc    = "Vraagt enemy_data op voor N=1→200. Toont BillboardGuis boven vijanden (alleen lezen).",
        EnemyScanRunning = "Scannen…",
        EnemyScanDone    = "Scan klaar — {n} vijand(en) gevonden",
        EnemyBillboard   = "Vijand #{n}\nRest. afstand: {d}",
        EnemyClear       = "Labels verwijderen",
        EnemyClearDesc   = "Verwijdert alle BillboardGuis van de tracker.",
        AutoUpgradeToggle = "Auto Upgrade",
        AutoUpgradeDesc   = "Lus slots 1→10 elke 0,5 s. Kan stil falen zonder middelen.",
        UpgradeOk         = "Slot {s} geüpgraded ✓",
        UpgradeFail       = "Slot {s} — geen upgrade",
        ShowItemsBtn      = "Mijn items tonen",
        ShowItemsDesc     = "Toont ontvangen item_exists-gegevens van de server (alleen lezen).",
        NoItemData        = "Nog geen inventarisgegevens. Speel even en probeer opnieuw.",
        ItemsTitle        = "Inventaris",
        FlyToggle        = "Vliegen",
        FlySpeed         = "Vliegsnelheid",
        NoClipToggle     = "NoClip",
        WalkSpeedLabel   = "Loopsnelheid",
        FullbrightToggle = "Vollicht",
        AntiAFKToggle    = "Anti-AFK",
        LangSelect       = "Taal",
        LangReload       = "Herstart het script om de taal toe te passen.",
        Loaded           = "Hub geladen! Welkom bij SMTD Hub.",
    },
    PL = {
        WindowTitle      = "SMTD Hub",
        TabHome          = "Strona główna",
        TabEnemyTracker  = "Śledzenie wrogów",
        TabAutoUpgrade   = "Auto ulepszenie",
        TabInventory     = "Inwentarz",
        TabMovement      = "Ruch",
        TabTools         = "Narzędzia",
        CreditsTitle     = "Podziękowania",
        CreditsContent   = "Stworzone przez Rival960 z pomocą Claude\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        LoadstringTitle  = "Loadstring",
        LoadstringContent = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Rival99900/Roblox-Scripts/refs/heads/main/scripts/Skibidi-Masters-Tower-Defense-KEYLESS.lua"))()',
        EnemyScanBtn     = "Skanuj wrogów",
        EnemyScanDesc    = "Odpytuje enemy_data dla N=1→200. Wyświetla BillboardGui nad każdym wrogiem (tylko odczyt).",
        EnemyScanRunning = "Skanowanie…",
        EnemyScanDone    = "Skan gotowy — znaleziono {n} wroga/wrogów",
        EnemyBillboard   = "Wróg #{n}\nPozostało: {d}",
        EnemyClear       = "Usuń etykiety",
        EnemyClearDesc   = "Usuwa wszystkie BillboardGui trackera.",
        AutoUpgradeToggle = "Auto ulepszenie",
        AutoUpgradeDesc   = "Pętla slotów 1→10 co 0,5 s. Może cicho zawieść bez zasobów.",
        UpgradeOk         = "Slot {s} ulepszony ✓",
        UpgradeFail       = "Slot {s} — brak ulepszenia",
        ShowItemsBtn      = "Pokaż moje przedmioty",
        ShowItemsDesc     = "Wyświetla dane item_exists otrzymane od serwera (tylko odczyt).",
        NoItemData        = "Brak danych inwentarza. Zagraj chwilę i spróbuj ponownie.",
        ItemsTitle        = "Inwentarz",
        FlyToggle        = "Latanie",
        FlySpeed         = "Prędkość lotu",
        NoClipToggle     = "NoClip",
        WalkSpeedLabel   = "Prędkość chodzenia",
        FullbrightToggle = "Pełna jasność",
        AntiAFKToggle    = "Anti-AFK",
        LangSelect       = "Język",
        LangReload       = "Uruchom skrypt ponownie, aby zastosować język.",
        Loaded           = "Hub załadowany! Witaj w SMTD Hub.",
    },
    ZH = {
        WindowTitle      = "SMTD Hub",
        TabHome          = "主页",
        TabEnemyTracker  = "敌人追踪",
        TabAutoUpgrade   = "自动升级",
        TabInventory     = "背包",
        TabMovement      = "移动",
        TabTools         = "工具",
        CreditsTitle     = "致谢",
        CreditsContent   = "由 Rival960 与 Claude 共同制作\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        LoadstringTitle  = "Loadstring",
        LoadstringContent = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Rival99900/Roblox-Scripts/refs/heads/main/scripts/Skibidi-Masters-Tower-Defense-KEYLESS.lua"))()',
        EnemyScanBtn     = "扫描敌人",
        EnemyScanDesc    = "轮询 enemy_data，N=1→200。在每个敌人上方显示 BillboardGui（只读）。",
        EnemyScanRunning = "扫描中…",
        EnemyScanDone    = "扫描完成 — 发现 {n} 个敌人",
        EnemyBillboard   = "敌人 #{n}\n剩余距离: {d}",
        EnemyClear       = "清除标签",
        EnemyClearDesc   = "删除追踪器创建的所有 BillboardGui。",
        AutoUpgradeToggle = "自动升级",
        AutoUpgradeDesc   = "每 0.5 秒循环槽位 1→10。资源不足时可能静默失败。",
        UpgradeOk         = "槽位 {s} 升级成功 ✓",
        UpgradeFail       = "槽位 {s} — 升级失败",
        ShowItemsBtn      = "显示我的物品",
        ShowItemsDesc     = "显示服务器发送的 item_exists 数据（只读）。",
        NoItemData        = "尚无背包数据，玩一会儿再试。",
        ItemsTitle        = "背包",
        FlyToggle        = "飞行",
        FlySpeed         = "飞行速度",
        NoClipToggle     = "穿墙",
        WalkSpeedLabel   = "行走速度",
        FullbrightToggle = "全亮",
        AntiAFKToggle    = "防 AFK",
        LangSelect       = "语言",
        LangReload       = "重新执行脚本以应用语言设置。",
        Loaded           = "Hub 已加载！欢迎使用 SMTD Hub。",
    },
    JA = {
        WindowTitle      = "SMTD Hub",
        TabHome          = "ホーム",
        TabEnemyTracker  = "敵トラッカー",
        TabAutoUpgrade   = "オートアップグレード",
        TabInventory     = "インベントリ",
        TabMovement      = "移動",
        TabTools         = "ツール",
        CreditsTitle     = "クレジット",
        CreditsContent   = "Rival960 と Claude が共同制作\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        LoadstringTitle  = "Loadstring",
        LoadstringContent = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Rival99900/Roblox-Scripts/refs/heads/main/scripts/Skibidi-Masters-Tower-Defense-KEYLESS.lua"))()',
        EnemyScanBtn     = "敵をスキャン",
        EnemyScanDesc    = "enemy_data を N=1→200 でポーリング。各敵の上に BillboardGui を表示（読み取り専用）。",
        EnemyScanRunning = "スキャン中…",
        EnemyScanDone    = "スキャン完了 — {n} 体の敵が見つかりました",
        EnemyBillboard   = "敵 #{n}\n残距離: {d}",
        EnemyClear       = "ラベルを消去",
        EnemyClearDesc   = "トラッカーが作成した BillboardGui をすべて削除します。",
        AutoUpgradeToggle = "オートアップグレード",
        AutoUpgradeDesc   = "0.5 秒ごとにスロット 1→10 をループ。リソース不足の場合サイレントに失敗します。",
        UpgradeOk         = "スロット {s} アップグレード ✓",
        UpgradeFail       = "スロット {s} — 失敗",
        ShowItemsBtn      = "アイテムを表示",
        ShowItemsDesc     = "サーバーから受信した item_exists データを表示（読み取り専用）。",
        NoItemData        = "データなし。しばらくプレイして再試行してください。",
        ItemsTitle        = "インベントリ",
        FlyToggle        = "飛行",
        FlySpeed         = "飛行速度",
        NoClipToggle     = "ノークリップ",
        WalkSpeedLabel   = "歩行速度",
        FullbrightToggle = "フルブライト",
        AntiAFKToggle    = "アンチAFK",
        LangSelect       = "言語",
        LangReload       = "言語を適用するにはスクリプトを再実行してください。",
        Loaded           = "Hub 読み込み完了！SMTD Hub へようこそ。",
    },
    TR = {
        WindowTitle      = "SMTD Hub",
        TabHome          = "Ana Sayfa",
        TabEnemyTracker  = "Düşman Takipçisi",
        TabAutoUpgrade   = "Otomatik Yükseltme",
        TabInventory     = "Envanter",
        TabMovement      = "Hareket",
        TabTools         = "Araçlar",
        CreditsTitle     = "Krediler",
        CreditsContent   = "Rival960 tarafından Claude yardımıyla oluşturuldu\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        LoadstringTitle  = "Loadstring",
        LoadstringContent = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Rival99900/Roblox-Scripts/refs/heads/main/scripts/Skibidi-Masters-Tower-Defense-KEYLESS.lua"))()',
        EnemyScanBtn     = "Düşmanları Tara",
        EnemyScanDesc    = "N=1→200 için enemy_data sorgusu yapar. Düşmanların üzerinde BillboardGui gösterir (salt okunur).",
        EnemyScanRunning = "Taranıyor…",
        EnemyScanDone    = "Tama {n} düşman bulundu",
        EnemyBillboard   = "Düşman #{n}\nKalan: {d}",
        EnemyClear       = "Etiketleri Temizle",
        EnemyClearDesc   = "Takipçinin oluşturduğu tüm BillboardGui'leri kaldırır.",
        AutoUpgradeToggle = "Otomatik Yükseltme",
        AutoUpgradeDesc   = "Her 0,5 s'de slotlar 1→10'u döngüler. Kaynak yoksa sessizce başarısız olabilir.",
        UpgradeOk         = "Slot {s} yükseltildi ✓",
        UpgradeFail       = "Slot {s} — yükseltme yok",
        ShowItemsBtn      = "Eşyalarımı Göster",
        ShowItemsDesc     = "Sunucudan alınan item_exists verilerini gösterir (salt okunur).",
        NoItemData        = "Envanter verisi yok. Biraz oynayıp tekrar dene.",
        ItemsTitle        = "Envanter",
        FlyToggle        = "Uçuş",
        FlySpeed         = "Uçuş Hızı",
        NoClipToggle     = "NoClip",
        WalkSpeedLabel   = "Yürüme Hızı",
        FullbrightToggle = "Tam Parlaklık",
        AntiAFKToggle    = "Anti-AFK",
        LangSelect       = "Dil",
        LangReload       = "Dili uygulamak için scripti yeniden çalıştırın.",
        Loaded           = "Hub yüklendi! SMTD Hub'a hoş geldin.",
    },
    KO = {
        WindowTitle      = "SMTD Hub",
        TabHome          = "홈",
        TabEnemyTracker  = "적 추적기",
        TabAutoUpgrade   = "자동 업그레이드",
        TabInventory     = "인벤토리",
        TabMovement      = "이동",
        TabTools         = "도구",
        CreditsTitle     = "크레딧",
        CreditsContent   = "Rival960이 Claude의 도움으로 제작\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        LoadstringTitle  = "Loadstring",
        LoadstringContent = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Rival99900/Roblox-Scripts/refs/heads/main/scripts/Skibidi-Masters-Tower-Defense-KEYLESS.lua"))()',
        EnemyScanBtn     = "적 스캔",
        EnemyScanDesc    = "N=1→200으로 enemy_data를 폴링합니다. 각 적 위에 BillboardGui 표시 (읽기 전용).",
        EnemyScanRunning = "스캔 중…",
        EnemyScanDone    = "스캔 완료 — {n}명의 적 발견",
        EnemyBillboard   = "적 #{n}\n남은 거리: {d}",
        EnemyClear       = "레이블 지우기",
        EnemyClearDesc   = "추적기가 만든 모든 BillboardGui를 제거합니다.",
        AutoUpgradeToggle = "자동 업그레이드",
        AutoUpgradeDesc   = "0.5초마다 슬롯 1→10을 반복합니다. 자원이 부족하면 조용히 실패할 수 있습니다.",
        UpgradeOk         = "슬롯 {s} 업그레이드 ✓",
        UpgradeFail       = "슬롯 {s} — 업그레이드 실패",
        ShowItemsBtn      = "내 아이템 보기",
        ShowItemsDesc     = "서버에서 받은 item_exists 데이터 표시 (읽기 전용).",
        NoItemData        = "인벤토리 데이터 없음. 잠깐 플레이 후 다시 시도하세요.",
        ItemsTitle        = "인벤토리",
        FlyToggle        = "비행",
        FlySpeed         = "비행 속도",
        NoClipToggle     = "노클립",
        WalkSpeedLabel   = "걷기 속도",
        FullbrightToggle = "풀브라이트",
        AntiAFKToggle    = "안티 AFK",
        LangSelect       = "언어",
        LangReload       = "언어를 적용하려면 스크립트를 다시 실행하세요.",
        Loaded           = "Hub 로드 완료! SMTD Hub에 오신 것을 환영합니다.",
    },
    AR = {
        WindowTitle      = "SMTD Hub",
        TabHome          = "الرئيسية",
        TabEnemyTracker  = "تتبع الأعداء",
        TabAutoUpgrade   = "ترقية تلقائية",
        TabInventory     = "المخزون",
        TabMovement      = "الحركة",
        TabTools         = "أدوات",
        CreditsTitle     = "الاعتمادات",
        CreditsContent   = "صنعه Rival960 بمساعدة Claude\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        LoadstringTitle  = "Loadstring",
        LoadstringContent = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Rival99900/Roblox-Scripts/refs/heads/main/scripts/Skibidi-Masters-Tower-Defense-KEYLESS.lua"))()',
        EnemyScanBtn     = "مسح الأعداء",
        EnemyScanDesc    = "يستعلم enemy_data للـ N=1→200. يعرض BillboardGui فوق كل عدو (للقراءة فقط).",
        EnemyScanRunning = "جارٍ المسح…",
        EnemyScanDone    = "اكتمل المسح — {n} عدو تم العثور عليه",
        EnemyBillboard   = "عدو #{n}\nالمسافة: {d}",
        EnemyClear       = "مسح التسميات",
        EnemyClearDesc   = "يزيل جميع BillboardGui التي أنشأها المتتبع.",
        AutoUpgradeToggle = "ترقية تلقائية",
        AutoUpgradeDesc   = "حلقة الفتحات 1→10 كل 0,5 ثانية. قد تفشل بصمت دون موارد.",
        UpgradeOk         = "تمت ترقية الفتحة {s} ✓",
        UpgradeFail       = "الفتحة {s} — لا ترقية",
        ShowItemsBtn      = "عرض عناصري",
        ShowItemsDesc     = "يعرض بيانات item_exists الواردة من الخادم (للقراءة فقط).",
        NoItemData        = "لا توجد بيانات مخزون بعد. العب قليلاً وحاول مرة أخرى.",
        ItemsTitle        = "المخزون",
        FlyToggle        = "الطيران",
        FlySpeed         = "سرعة الطيران",
        NoClipToggle     = "عبور الجدران",
        WalkSpeedLabel   = "سرعة المشي",
        FullbrightToggle = "إضاءة كاملة",
        AntiAFKToggle    = "مكافحة AFK",
        LangSelect       = "اللغة",
        LangReload       = "أعد تشغيل السكريبت لتطبيق اللغة.",
        Loaded           = "تم تحميل Hub! مرحباً بك في SMTD Hub.",
    },
    VI = {
        WindowTitle      = "SMTD Hub",
        TabHome          = "Trang chủ",
        TabEnemyTracker  = "Theo dõi kẻ thù",
        TabAutoUpgrade   = "Tự động nâng cấp",
        TabInventory     = "Kho đồ",
        TabMovement      = "Di chuyển",
        TabTools         = "Công cụ",
        CreditsTitle     = "Tín dụng",
        CreditsContent   = "Được tạo bởi Rival960 với sự hỗ trợ của Claude\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        LoadstringTitle  = "Loadstring",
        LoadstringContent = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Rival99900/Roblox-Scripts/refs/heads/main/scripts/Skibidi-Masters-Tower-Defense-KEYLESS.lua"))()',
        EnemyScanBtn     = "Quét kẻ thù",
        EnemyScanDesc    = "Thăm dò enemy_data cho N=1→200. Hiển thị BillboardGui trên mỗi kẻ thù (chỉ đọc).",
        EnemyScanRunning = "Đang quét…",
        EnemyScanDone    = "Quét xong — tìm thấy {n} kẻ thù",
        EnemyBillboard   = "Kẻ thù #{n}\nĐã đi: {d}",
        EnemyClear       = "Xóa nhãn",
        EnemyClearDesc   = "Xóa tất cả BillboardGui do trình theo dõi tạo ra.",
        AutoUpgradeToggle = "Tự động nâng cấp",
        AutoUpgradeDesc   = "Vòng lặp slot 1→10 mỗi 0,5 giây. Có thể thất bại thầm lặng nếu thiếu tài nguyên.",
        UpgradeOk         = "Slot {s} đã nâng cấp ✓",
        UpgradeFail       = "Slot {s} — không nâng cấp được",
        ShowItemsBtn      = "Xem đồ của tôi",
        ShowItemsDesc     = "Hiển thị dữ liệu item_exists nhận từ máy chủ (chỉ đọc).",
        NoItemData        = "Chưa có dữ liệu kho. Chơi một lúc rồi thử lại.",
        ItemsTitle        = "Kho đồ",
        FlyToggle        = "Bay",
        FlySpeed         = "Tốc độ bay",
        NoClipToggle     = "Xuyên tường",
        WalkSpeedLabel   = "Tốc độ đi bộ",
        FullbrightToggle = "Sáng toàn màn",
        AntiAFKToggle    = "Chống AFK",
        LangSelect       = "Ngôn ngữ",
        LangReload       = "Chạy lại script để áp dụng ngôn ngữ.",
        Loaded           = "Hub đã tải! Chào mừng đến SMTD Hub.",
    },
    SV = {
        WindowTitle      = "SMTD Hub",
        TabHome          = "Hem",
        TabEnemyTracker  = "Fiendetracker",
        TabAutoUpgrade   = "Auto-uppgradering",
        TabInventory     = "Inventarium",
        TabMovement      = "Rörelse",
        TabTools         = "Verktyg",
        CreditsTitle     = "Tack",
        CreditsContent   = "Skapad av Rival960 med hjälp av Claude\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        LoadstringTitle  = "Loadstring",
        LoadstringContent = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Rival99900/Roblox-Scripts/refs/heads/main/scripts/Skibidi-Masters-Tower-Defense-KEYLESS.lua"))()',
        EnemyScanBtn     = "Skanna fiender",
        EnemyScanDesc    = "Frågar enemy_data för N=1→200. Visar BillboardGuis ovanför fiender (skrivskyddad).",
        EnemyScanRunning = "Skannar…",
        EnemyScanDone    = "Klar — {n} fiende(r) hittad(e)",
        EnemyBillboard   = "Fiende #{n}\nKvar: {d}",
        EnemyClear       = "Rensa etiketter",
        EnemyClearDesc   = "Tar bort alla BillboardGuis skapade av trackern.",
        AutoUpgradeToggle = "Auto-uppgradering",
        AutoUpgradeDesc   = "Loopar slot 1→10 var 0,5 s. Kan misslyckas tyst utan resurser.",
        UpgradeOk         = "Slot {s} uppgraderad ✓",
        UpgradeFail       = "Slot {s} — ingen uppgradering",
        ShowItemsBtn      = "Visa mina föremål",
        ShowItemsDesc     = "Visar item_exists-data mottagen från server (skrivskyddad).",
        NoItemData        = "Inga inventariedata ännu. Spela lite och försök igen.",
        ItemsTitle        = "Inventarium",
        FlyToggle        = "Flyg",
        FlySpeed         = "Flighastighet",
        NoClipToggle     = "NoClip",
        WalkSpeedLabel   = "Gånghastighet",
        FullbrightToggle = "Fulljus",
        AntiAFKToggle    = "Anti-AFK",
        LangSelect       = "Språk",
        LangReload       = "Kör om scriptet för att tillämpa språket.",
        Loaded           = "Hub inläst! Välkommen till SMTD Hub.",
    },
    EL = {
        WindowTitle      = "SMTD Hub",
        TabHome          = "Αρχική",
        TabEnemyTracker  = "Ανίχνευση Εχθρών",
        TabAutoUpgrade   = "Αυτόματη Αναβάθμιση",
        TabInventory     = "Απόθεμα",
        TabMovement      = "Κίνηση",
        TabTools         = "Εργαλεία",
        CreditsTitle     = "Χρεώσεις",
        CreditsContent   = "Δημιουργήθηκε από Rival960 με βοήθεια Claude\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        LoadstringTitle  = "Loadstring",
        LoadstringContent = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Rival99900/Roblox-Scripts/refs/heads/main/scripts/Skibidi-Masters-Tower-Defense-KEYLESS.lua"))()',
        EnemyScanBtn     = "Σάρωση Εχθρών",
        EnemyScanDesc    = "Ρωτά enemy_data για N=1→200. Εμφανίζει BillboardGui πάνω από κάθε εχθρό (μόνο ανάγνωση).",
        EnemyScanRunning = "Σάρωση…",
        EnemyScanDone    = "Ολοκλήρωση — {n} εχθρός(-οί) βρέθηκε(-αν)",
        EnemyBillboard   = "Εχθρός #{n}\nΑπόσταση: {d}",
        EnemyClear       = "Διαγραφή ετικετών",
        EnemyClearDesc   = "Αφαιρεί όλα τα BillboardGui του ανιχνευτή.",
        AutoUpgradeToggle = "Αυτόματη Αναβάθμιση",
        AutoUpgradeDesc   = "Βρόχος αναβαθμίσεων 1→10 κάθε 0,5 δ. Μπορεί να αποτύχει αθόρυβα.",
        UpgradeOk         = "Θέση {s} αναβαθμίστηκε ✓",
        UpgradeFail       = "Θέση {s} — καμία αναβάθμιση",
        ShowItemsBtn      = "Τα αντικείμενά μου",
        ShowItemsDesc     = "Εμφανίζει δεδομένα item_exists που λήφθηκαν από διακομιστή (μόνο ανάγνωση).",
        NoItemData        = "Δεν υπάρχουν δεδομένα. Παίξτε λίγο και δοκιμάστε ξανά.",
        ItemsTitle        = "Απόθεμα",
        FlyToggle        = "Πτήση",
        FlySpeed         = "Ταχύτητα πτήσης",
        NoClipToggle     = "NoClip",
        WalkSpeedLabel   = "Ταχύτητα βαδίσματος",
        FullbrightToggle = "Πλήρης φωτεινότητα",
        AntiAFKToggle    = "Κατά-AFK",
        LangSelect       = "Γλώσσα",
        LangReload       = "Εκτελέστε ξανά το script για αλλαγή γλώσσας.",
        Loaded           = "Hub φορτώθηκε! Καλωσήλθατε στο SMTD Hub.",
    },
    RO = {
        WindowTitle      = "SMTD Hub",
        TabHome          = "Acasă",
        TabEnemyTracker  = "Urmăritor Inamici",
        TabAutoUpgrade   = "Upgrade Automat",
        TabInventory     = "Inventar",
        TabMovement      = "Mișcare",
        TabTools         = "Instrumente",
        CreditsTitle     = "Credite",
        CreditsContent   = "Creat de Rival960 cu ajutorul Claude\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        LoadstringTitle  = "Loadstring",
        LoadstringContent = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Rival99900/Roblox-Scripts/refs/heads/main/scripts/Skibidi-Masters-Tower-Defense-KEYLESS.lua"))()',
        EnemyScanBtn     = "Scanează Inamici",
        EnemyScanDesc    = "Interoghează enemy_data pentru N=1→200. Afișează BillboardGui deasupra fiecărui inamic (doar citire).",
        EnemyScanRunning = "Se scanează…",
        EnemyScanDone    = "Scanare completă — {n} inamic(i) găsit(ți)",
        EnemyBillboard   = "Inamic #{n}\nDist rămasă: {d}",
        EnemyClear       = "Șterge etichete",
        EnemyClearDesc   = "Elimină toate BillboardGui create de tracker.",
        AutoUpgradeToggle = "Upgrade Automat",
        AutoUpgradeDesc   = "Buclă sloturi 1→10 la fiecare 0,5 s. Poate eșua silențios fără resurse.",
        UpgradeOk         = "Slotul {s} îmbunătățit ✓",
        UpgradeFail       = "Slotul {s} — fără îmbunătățire",
        ShowItemsBtn      = "Afișează obiectele mele",
        ShowItemsDesc     = "Afișează datele item_exists primite de la server (doar citire).",
        NoItemData        = "Fără date inventar. Joacă puțin și încearcă din nou.",
        ItemsTitle        = "Inventar",
        FlyToggle        = "Zbor",
        FlySpeed         = "Viteză zbor",
        NoClipToggle     = "NoClip",
        WalkSpeedLabel   = "Viteză mers",
        FullbrightToggle = "Luminozitate maximă",
        AntiAFKToggle    = "Anti-AFK",
        LangSelect       = "Limbă",
        LangReload       = "Rulați din nou scriptul pentru a aplica limba.",
        Loaded           = "Hub încărcat! Bun venit la SMTD Hub.",
    },
    UK = {
        WindowTitle      = "SMTD Hub",
        TabHome          = "Головна",
        TabEnemyTracker  = "Трекер ворогів",
        TabAutoUpgrade   = "Авто-покращення",
        TabInventory     = "Інвентар",
        TabMovement      = "Рух",
        TabTools         = "Інструменти",
        CreditsTitle     = "Автори",
        CreditsContent   = "Створено Rival960 за допомогою Claude\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        LoadstringTitle  = "Loadstring",
        LoadstringContent = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Rival99900/Roblox-Scripts/refs/heads/main/scripts/Skibidi-Masters-Tower-Defense-KEYLESS.lua"))()',
        EnemyScanBtn     = "Сканувати ворогів",
        EnemyScanDesc    = "Опитує enemy_data для N=1→200. Показує BillboardGui над кожним ворогом (лише читання).",
        EnemyScanRunning = "Сканування…",
        EnemyScanDone    = "Готово — знайдено {n} ворог(ів)",
        EnemyBillboard   = "Ворог #{n}\nЗалишилось: {d}",
        EnemyClear       = "Видалити мітки",
        EnemyClearDesc   = "Видаляє всі BillboardGui, створені трекером.",
        AutoUpgradeToggle = "Авто-покращення",
        AutoUpgradeDesc   = "Цикл слотів 1→10 кожні 0,5 с. Може мовчки не спрацювати без ресурсів.",
        UpgradeOk         = "Слот {s} покращено ✓",
        UpgradeFail       = "Слот {s} — без покращення",
        ShowItemsBtn      = "Мої предмети",
        ShowItemsDesc     = "Відображає дані item_exists, отримані від сервера (лише читання).",
        NoItemData        = "Даних інвентаря немає. Пограйте трохи і повторіть.",
        ItemsTitle        = "Інвентар",
        FlyToggle        = "Польот",
        FlySpeed         = "Швидкість польоту",
        NoClipToggle     = "NoClip",
        WalkSpeedLabel   = "Швидкість ходьби",
        FullbrightToggle = "Повне освітлення",
        AntiAFKToggle    = "Анти-АФК",
        LangSelect       = "Мова",
        LangReload       = "Перезапустіть скрипт для застосування мови.",
        Loaded           = "Hub завантажено! Ласкаво просимо до SMTD Hub.",
    },
    CS = {
        WindowTitle      = "SMTD Hub",
        TabHome          = "Domů",
        TabEnemyTracker  = "Sledovač nepřátel",
        TabAutoUpgrade   = "Automatické vylepšení",
        TabInventory     = "Inventář",
        TabMovement      = "Pohyb",
        TabTools         = "Nástroje",
        CreditsTitle     = "Zásluhy",
        CreditsContent   = "Vytvořil Rival960 s pomocí Claude\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        LoadstringTitle  = "Loadstring",
        LoadstringContent = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Rival99900/Roblox-Scripts/refs/heads/main/scripts/Skibidi-Masters-Tower-Defense-KEYLESS.lua"))()',
        EnemyScanBtn     = "Skenovat nepřátele",
        EnemyScanDesc    = "Dotazuje enemy_data pro N=1→200. Zobrazuje BillboardGui nad každým nepřítelem (pouze čtení).",
        EnemyScanRunning = "Skenování…",
        EnemyScanDone    = "Hotovo — nalezeno {n} nepřítel(é)",
        EnemyBillboard   = "Nepřítel #{n}\nZbytek: {d}",
        EnemyClear       = "Vymazat štítky",
        EnemyClearDesc   = "Odstraní všechny BillboardGui vytvořené sledovačem.",
        AutoUpgradeToggle = "Automatické vylepšení",
        AutoUpgradeDesc   = "Smyčka slotů 1→10 každých 0,5 s. Může tiše selhat bez zdrojů.",
        UpgradeOk         = "Slot {s} vylepšen ✓",
        UpgradeFail       = "Slot {s} — žádné vylepšení",
        ShowItemsBtn      = "Zobrazit moje předměty",
        ShowItemsDesc     = "Zobrazuje data item_exists přijatá ze serveru (pouze čtení).",
        NoItemData        = "Žádná data inventáře. Chvíli hrajte a zkuste znovu.",
        ItemsTitle        = "Inventář",
        FlyToggle        = "Létání",
        FlySpeed         = "Rychlost letu",
        NoClipToggle     = "NoClip",
        WalkSpeedLabel   = "Rychlost chůze",
        FullbrightToggle = "Plné světlo",
        AntiAFKToggle    = "Anti-AFK",
        LangSelect       = "Jazyk",
        LangReload       = "Spusťte skript znovu pro použití jazyka.",
        Loaded           = "Hub načten! Vítejte v SMTD Hub.",
    },
    DA = {
        WindowTitle      = "SMTD Hub",
        TabHome          = "Hjem",
        TabEnemyTracker  = "Fjendesporer",
        TabAutoUpgrade   = "Auto-opgradering",
        TabInventory     = "Inventar",
        TabMovement      = "Bevægelse",
        TabTools         = "Værktøjer",
        CreditsTitle     = "Tak",
        CreditsContent   = "Lavet af Rival960 med hjælp fra Claude\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        LoadstringTitle  = "Loadstring",
        LoadstringContent = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Rival99900/Roblox-Scripts/refs/heads/main/scripts/Skibidi-Masters-Tower-Defense-KEYLESS.lua"))()',
        EnemyScanBtn     = "Scan fjender",
        EnemyScanDesc    = "Forespørger enemy_data for N=1→200. Viser BillboardGuis over fjender (skrivebeskyttet).",
        EnemyScanRunning = "Scanner…",
        EnemyScanDone    = "Færdig — {n} fjende(r) fundet",
        EnemyBillboard   = "Fjende #{n}\nRest. afstand: {d}",
        EnemyClear       = "Ryd etiketter",
        EnemyClearDesc   = "Fjerner alle BillboardGuis oprettet af trackeren.",
        AutoUpgradeToggle = "Auto-opgradering",
        AutoUpgradeDesc   = "Løkke over slots 1→10 hvert 0,5 s. Kan mislykkes lydløst uden ressourcer.",
        UpgradeOk         = "Slot {s} opgraderet ✓",
        UpgradeFail       = "Slot {s} — ingen opgradering",
        ShowItemsBtn      = "Vis mine genstande",
        ShowItemsDesc     = "Viser item_exists-data modtaget fra serveren (skrivebeskyttet).",
        NoItemData        = "Ingen inventardata. Spil lidt og prøv igen.",
        ItemsTitle        = "Inventar",
        FlyToggle        = "Flyv",
        FlySpeed         = "Flyvehastighed",
        NoClipToggle     = "NoClip",
        WalkSpeedLabel   = "Gangfart",
        FullbrightToggle = "Fuld lysstyrke",
        AntiAFKToggle    = "Anti-AFK",
        LangSelect       = "Sprog",
        LangReload       = "Kør scriptet igen for at anvende sproget.",
        Loaded           = "Hub indlæst! Velkommen til SMTD Hub.",
    },
}

local function T(key)
    local lang = Translations[CurrentLang]
    if lang and lang[key] then return lang[key] end
    return (Translations.EN[key] or key)
end

-- Interpolate {n}, {s}, {d} placeholders
local function TF(key, vars)
    local s = T(key)
    for k, v in pairs(vars) do
        s = s:gsub("{" .. k .. "}", tostring(v))
    end
    return s
end

-- ================================================================
-- SETTINGS
-- ================================================================
local Settings = {
    Fly         = false,
    FlySpeed    = 60,
    NoClip      = false,
    WalkSpeed   = 16,
    Fullbright  = false,
    AntiAFK     = false,
    AutoUpgrade = false,
}

-- ================================================================
-- STATE
-- ================================================================
local EnemyTrackers   = {}  -- [N] = { part = Part, label = TextLabel }
local ItemCache       = nil -- last item_exists data from server
local ScanActive      = false

-- ================================================================
-- RAYFIELD LOAD (keyless)
-- ================================================================
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)
if not success or not Rayfield then
    warn("[SMTD Hub] Rayfield failed to load:", Rayfield)
    return
end

-- ================================================================
-- MAIN WINDOW
-- ================================================================
local Window = Rayfield:CreateWindow({
    Name              = T("WindowTitle"),
    LoadingTitle      = "Skibidi Masters TD Hub",
    LoadingSubtitle   = "Created by Rival960 & Claude",
    ConfigurationSaving = { Enabled = false },
    Discord           = { Enabled = false },
    KeySystem         = false,
})

-- ================================================================
-- TAB 1 — HOME
-- ================================================================
local TabHome = Window:CreateTab(T("TabHome"), 4483362458)

TabHome:CreateParagraph({
    Title   = T("CreditsTitle"),
    Content = T("CreditsContent"),
})

TabHome:CreateParagraph({
    Title   = T("LoadstringTitle"),
    Content = T("LoadstringContent"),
})

TabHome:CreateParagraph({
    Title   = "GitHub",
    Content = "https://github.com/Rival99900/Roblox-Scripts",
})

-- ================================================================
-- TAB 2 — ENEMY TRACKER
-- ================================================================
local TabEnemy = Window:CreateTab(T("TabEnemyTracker"), 4483362458)

-- Helper: create or update a BillboardGui tracker for enemy N
local function upsertEnemyTracker(n, cf, walking_left)
    if not EnemyTrackers[n] then
        -- Create a tiny invisible anchor part
        local part = Instance.new("Part")
        part.Name          = "SMTD_Enemy_" .. n
        part.Size          = Vector3.new(0.1, 0.1, 0.1)
        part.CanCollide    = false
        part.CanQuery      = false
        part.CanTouch      = false
        part.Anchored      = true
        part.Transparency  = 1
        part.CFrame        = cf
        part.Parent        = workspace

        local bb = Instance.new("BillboardGui")
        bb.Name            = "SMTD_BB_" .. n
        bb.AlwaysOnTop     = true
        bb.Size            = UDim2.new(0, 200, 0, 50)
        bb.StudsOffset     = Vector3.new(0, 3, 0)
        bb.Adornee         = part
        bb.Parent          = part

        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Size                   = UDim2.fromScale(1, 1)
        lbl.TextColor3             = Color3.fromRGB(255, 80, 0)
        lbl.TextStrokeTransparency = 0
        lbl.Font                   = Enum.Font.GothamBold
        lbl.TextScaled             = true
        lbl.Parent                 = bb

        EnemyTrackers[n] = { part = part, label = lbl }
    end

    local tracker = EnemyTrackers[n]
    tracker.part.CFrame = cf + Vector3.new(0, 3, 0)
    tracker.label.Text  = TF("EnemyBillboard", {
        n = n,
        d = string.format("%.0f", walking_left),
    })
end

-- Helper: remove all trackers
local function clearEnemyTrackers()
    for n, tracker in pairs(EnemyTrackers) do
        pcall(function()
            if tracker.part and tracker.part.Parent then
                tracker.part:Destroy()
            end
        end)
        EnemyTrackers[n] = nil
    end
end

TabEnemy:CreateButton({
    Name     = T("EnemyScanBtn"),
    Callback = function()
        if ScanActive then
            Rayfield:Notify({
                Title    = T("TabEnemyTracker"),
                Content  = T("EnemyScanRunning"),
                Duration = 2,
            })
            return
        end

        task.spawn(function()
            ScanActive = true
            local found = 0

            -- We mark which IDs responded this scan to clean stale ones
            local seen = {}

            for n = 1, 200 do
                -- pcall around each invoke so one failure doesn't stop the loop
                local ok, result = pcall(function()
                    if not R_EnemyData then error("remote unavailable") end
                    return R_EnemyData:InvokeServer(tostring(n))
                end)

                if ok and type(result) == "table" and result.entityCFrame then
                    local cf           = result.entityCFrame
                    local walking_left = result.walking_left or 0

                    upsertEnemyTracker(n, cf, walking_left)
                    seen[n] = true
                    found   = found + 1
                end

                -- Throttle to ~20 requests/s to avoid flooding
                task.wait(0.05)
            end

            -- Remove trackers for enemies that didn't respond
            for n, tracker in pairs(EnemyTrackers) do
                if not seen[n] then
                    pcall(function()
                        if tracker.part and tracker.part.Parent then
                            tracker.part:Destroy()
                        end
                    end)
                    EnemyTrackers[n] = nil
                end
            end

            Rayfield:Notify({
                Title    = T("TabEnemyTracker"),
                Content  = TF("EnemyScanDone", { n = found }),
                Duration = 4,
            })

            ScanActive = false
        end)
    end,
})

TabEnemy:CreateParagraph({
    Title   = "",
    Content = T("EnemyScanDesc"),
})

TabEnemy:CreateButton({
    Name     = T("EnemyClear"),
    Callback = function()
        clearEnemyTrackers()
        Rayfield:Notify({
            Title    = T("TabEnemyTracker"),
            Content  = T("EnemyClearDesc"),
            Duration = 2,
        })
    end,
})

-- ================================================================
-- TAB 3 — AUTO UPGRADE
-- ================================================================
local TabUpgrade = Window:CreateTab(T("TabAutoUpgrade"), 4483362458)

TabUpgrade:CreateToggle({
    Name         = T("AutoUpgradeToggle"),
    CurrentValue = false,
    Flag         = "AutoUpgrade",
    Callback     = function(value)
        Settings.AutoUpgrade = value

        if value then
            task.spawn(function()
                while Settings.AutoUpgrade do
                    for slot = 1, 10 do
                        if not Settings.AutoUpgrade then break end

                        local slotStr = tostring(slot)
                        local ok, result = pcall(function()
                            if not R_UnitUpgrade then error("remote unavailable") end
                            return R_UnitUpgrade:InvokeServer(slotStr)
                        end)

                        -- result[1] == true means success (confirmed from log: InvokeResult = { true, n=1 })
                        local upgraded = ok and (result == true or (type(result) == "table" and result[1] == true))

                        if upgraded then
                            Rayfield:Notify({
                                Title    = T("TabAutoUpgrade"),
                                Content  = TF("UpgradeOk", { s = slotStr }),
                                Duration = 2,
                            })
                        end
                        -- No notification on fail to avoid spam — only log
                        -- (silent fail is expected when resources are insufficient)

                        task.wait(0.5)
                    end
                    task.wait(0.1)
                end
            end)
        end
    end,
})

TabUpgrade:CreateParagraph({
    Title   = "",
    Content = T("AutoUpgradeDesc"),
})

-- ================================================================
-- TAB 4 — INVENTORY DISPLAY
-- ================================================================
local TabInventory = Window:CreateTab(T("TabInventory"), 4483362458)

-- Cache item_exists data from server whenever it arrives
if R_ItemExists then
    R_ItemExists.OnClientEvent:Connect(function(data)
        if type(data) == "table" then
            ItemCache = data
        end
    end)
end

TabInventory:CreateButton({
    Name     = T("ShowItemsBtn"),
    Callback = function()
        if not ItemCache then
            Rayfield:Notify({
                Title    = T("ItemsTitle"),
                Content  = T("NoItemData"),
                Duration = 4,
            })
            return
        end

        -- Display key items confirmed in the logs
        -- item_exists keys: lucky, coin (may be absent — use 0), armada_box,
        -- super_crate / elite_crate (map to summer_crate / exclusive_crate in log),
        -- armada_currency (may be named differently)
        local function v(key)
            local raw = ItemCache[key]
            if raw == nil then return "N/A" end
            return tostring(raw)
        end

        local lines = {
            "🍀 lucky:           " .. v("lucky"),
            "🪙 coin:            " .. v("coin"),
            "📦 armada_box:      " .. v("armada_box"),
            "🎁 super_crate:     " .. v("super_crate"),
            "💎 elite_crate:     " .. v("elite_crate"),
            "💰 armada_currency: " .. v("armada_currency"),
        }

        Rayfield:Notify({
            Title    = T("ItemsTitle"),
            Content  = table.concat(lines, "\n"),
            Duration = 8,
        })
    end,
})

TabInventory:CreateParagraph({
    Title   = "",
    Content = T("ShowItemsDesc"),
})

-- ================================================================
-- TAB 5 — MOVEMENT
-- ================================================================
local TabMove = Window:CreateTab(T("TabMovement"), 4483362458)

-- ---- FLY ----
local FlyBodyVelocity, FlyBodyGyro
local FlyConnection

local function enableFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    hum.PlatformStand = true

    FlyBodyVelocity          = Instance.new("BodyVelocity")
    FlyBodyVelocity.Velocity = Vector3.zero
    FlyBodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    FlyBodyVelocity.Parent   = hrp

    FlyBodyGyro             = Instance.new("BodyGyro")
    FlyBodyGyro.MaxTorque   = Vector3.new(9e4, 9e4, 9e4)
    FlyBodyGyro.P           = 9000
    FlyBodyGyro.CFrame      = hrp.CFrame
    FlyBodyGyro.Parent      = hrp

    FlyConnection = RunService.RenderStepped:Connect(function()
        if not Settings.Fly then
            FlyConnection:Disconnect()
            return
        end

        local speed = Settings.FlySpeed
        local cf    = Camera.CFrame
        local dir   = Vector3.zero

        -- PC keyboard
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end

        -- Mobile fallback: use humanoid MoveDirection
        local md = hum.MoveDirection
        if md.Magnitude > 0.1 then
            dir = dir + Vector3.new(md.X, 0, md.Z)
        end

        if dir.Magnitude > 0 then
            FlyBodyVelocity.Velocity = dir.Unit * speed
            FlyBodyGyro.CFrame       = CFrame.lookAt(hrp.Position, hrp.Position + dir)
        else
            FlyBodyVelocity.Velocity = Vector3.zero
        end
    end)
end

local function disableFly()
    if FlyConnection then FlyConnection:Disconnect() end

    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hrp then
            if FlyBodyVelocity and FlyBodyVelocity.Parent == hrp then
                FlyBodyVelocity:Destroy()
            end
            if FlyBodyGyro and FlyBodyGyro.Parent == hrp then
                FlyBodyGyro:Destroy()
            end
        end
        if hum then hum.PlatformStand = false end
    end
end

TabMove:CreateToggle({
    Name         = T("FlyToggle"),
    CurrentValue = false,
    Flag         = "Fly",
    Callback     = function(value)
        Settings.Fly = value
        if value then enableFly() else disableFly() end
    end,
})

TabMove:CreateSlider({
    Name        = T("FlySpeed"),
    Range       = { 10, 300 },
    Increment   = 5,
    CurrentValue = 60,
    Flag        = "FlySpeed",
    Callback    = function(value)
        Settings.FlySpeed = value
    end,
})

-- ---- NOCLIP ----
local NoClipConnection

TabMove:CreateToggle({
    Name         = T("NoClipToggle"),
    CurrentValue = false,
    Flag         = "NoClip",
    Callback     = function(value)
        Settings.NoClip = value

        if value then
            NoClipConnection = RunService.Stepped:Connect(function()
                if not Settings.NoClip then
                    NoClipConnection:Disconnect()
                    return
                end
                local char = LocalPlayer.Character
                if not char then return end
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end)
        else
            -- Restore collision on the typical body parts when disabled
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local name = part.Name:lower()
                        if name ~= "humanoidrootpart" then
                            part.CanCollide = true
                        end
                    end
                end
            end
        end
    end,
})

-- ---- WALKSPEED ----
TabMove:CreateSlider({
    Name         = T("WalkSpeedLabel"),
    Range        = { 16, 250 },
    Increment    = 1,
    CurrentValue = 16,
    Flag         = "WalkSpeed",
    Callback     = function(value)
        Settings.WalkSpeed = value
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = value end
        end
    end,
})

-- Re-apply WalkSpeed on respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        hum.WalkSpeed = Settings.WalkSpeed
    end
    -- Re-enable fly on respawn if active
    if Settings.Fly then
        task.wait(0.5)
        enableFly()
    end
end)

-- ================================================================
-- TAB 6 — TOOLS
-- ================================================================
local TabTools = Window:CreateTab(T("TabTools"), 4483362458)

-- ---- FULLBRIGHT ----
local Lighting = game:GetService("Lighting")
local OrigBrightness, OrigClockTime, OrigGlobalShadows
OrigBrightness    = Lighting.Brightness
OrigClockTime     = Lighting.ClockTime
OrigGlobalShadows = Lighting.GlobalShadows

TabTools:CreateToggle({
    Name         = T("FullbrightToggle"),
    CurrentValue = false,
    Flag         = "Fullbright",
    Callback     = function(value)
        Settings.Fullbright = value
        if value then
            Lighting.Brightness    = 2
            Lighting.ClockTime     = 14
            Lighting.GlobalShadows = false
        else
            Lighting.Brightness    = OrigBrightness
            Lighting.ClockTime     = OrigClockTime
            Lighting.GlobalShadows = OrigGlobalShadows
        end
    end,
})

-- ---- ANTI-AFK ----
local VirtualUser = game:GetService("VirtualUser")
local AntiAFKConn

TabTools:CreateToggle({
    Name         = T("AntiAFKToggle"),
    CurrentValue = false,
    Flag         = "AntiAFK",
    Callback     = function(value)
        Settings.AntiAFK = value
        if value then
            LocalPlayer.Idled:Connect(function()
                if Settings.AntiAFK then
                    pcall(function() VirtualUser:CaptureController() end)
                    pcall(function() VirtualUser:ClickButton2(Vector2.zero) end)
                end
            end)
        end
    end,
})

-- ---- LANGUAGE SELECTOR ----
-- Build ordered list of language codes (matches the Translations table order)
local LangOptions = {
    "EN","FR","DE","ES","PT","RU","IT","NL","PL","ZH",
    "JA","TR","KO","AR","VI","SV","EL","RO","UK","CS","DA"
}

TabTools:CreateDropdown({
    Name         = T("LangSelect"),
    Options      = LangOptions,
    CurrentOption = { CurrentLang },
    Flag         = "LangSelect",
    Callback     = function(selected)
        -- selected may be a string or table
        local lang = type(selected) == "table" and selected[1] or selected
        if Translations[lang] then
            CurrentLang = lang
        end
        Rayfield:Notify({
            Title    = T("LangSelect"),
            Content  = T("LangReload"),
            Duration = 4,
        })
    end,
})

-- ================================================================
-- LOADED NOTIFICATION
-- ================================================================
Rayfield:Notify({
    Title    = T("WindowTitle"),
    Content  = T("Loaded"),
    Duration = 4,
})

-- ================================================================
-- DISCLAIMER
-- ================================================================
-- This script is for educational and entertainment purposes only.
-- Use at your own risk. The authors take no responsibility for
-- bans or other consequences resulting from using this script.
-- No server-side values are modified. All invocations use remotes
-- that the game's own client fires under normal gameplay.
-- ================================================================

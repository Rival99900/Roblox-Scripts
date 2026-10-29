--[[
    ================================================================
    Skibidi Masters Tower Defense Hub — Skibidi Masters Tower Defense
    Created by Rival960 with the help of Claude
    Version: 1.0.0 | Languages: 21 | Rayfield UI
    Status: untested in-game
    Game: https://www.roblox.com/games/15111895255/Skibidi-Masters-Tower-Defense
    ================================================================

    HONEST LIMITS (read before use):
    - unit_upgrade will fail silently if the player lacks resources;
      the script logs the result (true/false) but cannot guarantee success
    - tasks_update is server→client read-only. Claiming rewards requires
      a server-side remote not visible in logs. The Tasks tab only reads
      and displays cached server data.
    - "Spoof All Tasks" only changes what the client sees in the UI.
      No rewards are granted. Server data is unchanged.
    - Code redemption success depends on the game's server validation.
      Already-redeemed codes will silently fail. GUI element names may
      differ between game updates — open the codes panel first.
    ================================================================
--]]

-- ================================================================
-- SERVICES
-- ================================================================
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting          = game:GetService("Lighting")

local ok_vu, VirtualUser = pcall(function() return game:GetService("VirtualUser") end)
if not ok_vu then VirtualUser = nil end

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

-- ================================================================
-- REMOTES (confirmed via Cobalt logs 2026-10-28)
-- ================================================================
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local ClientServer, ServerClient

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

local R_UnitUpgrade = getRemote(ClientServer, "unit_upgrade")  -- RemoteFunction
local R_TasksUpdate = getRemote(ServerClient, "tasks_update")  -- RemoteEvent (server→client)

-- ================================================================
-- LANGUAGE SYSTEM — 21 languages
-- ================================================================
local CurrentLang = "EN"

local Translations = {
    EN = {
        WindowTitle       = "SMTD Hub",
        TabHome           = "Home",
        TabAutoUpgrade    = "Auto Upgrade",
        TabTasks          = "Tasks",
        TabCodes          = "Codes",
        TabMovement       = "Movement",
        TabTools          = "Tools",
        -- Home
        CreditsTitle      = "Credits",
        CreditsContent    = "Created by Rival960 with the help of Claude\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        VersionTitle      = "Version",
        VersionContent    = "v1.0.0 — First Release",
        -- Auto Upgrade
        AutoUpgradeToggle = "Auto Upgrade",
        AutoUpgradeDesc   = "Loops slots 1→10 every 0.5 s and calls unit_upgrade. May fail silently if resources are insufficient.",
        UpgradeOk         = "Slot {s} upgraded ✓",
        -- Tasks
        ShowTasksBtn      = "Show Tasks Status",
        ShowTasksDesc     = "Displays the last tasks_update payload received from the server (read-only). Claiming rewards requires a server-side remote not visible in logs.",
        NoTaskData        = "No task data received yet. Play for a moment and retry.",
        TasksTitle        = "Tasks Status",
        SpoofTasksBtn     = "Spoof All Tasks as Claimed (Visual Only)",
        SpoofTasksDesc    = "Fires a fake tasks_update to the client UI only. No server rewards are granted.",
        SpoofDone         = "Tasks spoofed client-side (visual only — no server rewards)",
        -- Codes
        RedeemCodesBtn    = "Auto Redeem All Codes",
        RedeemCodesDesc   = "Searches the in-game GUI for a code input box, then types and submits each code. Open the codes panel first. Success depends on server validation.",
        RedeemDone        = "Attempted {n} codes. Check in-game for results.",
        RedeemNotFound    = "Code input not found in GUI — open the codes panel in-game first, then run this again.",
        -- Movement
        FlyToggle         = "Fly",
        FlySpeed          = "Fly Speed",
        NoClipToggle      = "NoClip",
        WalkSpeedLabel    = "WalkSpeed",
        -- Tools
        FullbrightToggle  = "Fullbright",
        AntiAFKToggle     = "Anti-AFK",
        LangSelect        = "Language",
        LangReload        = "Re-execute script to apply language change.",
        -- Footer
        Loaded            = "Hub loaded! Welcome to SMTD Hub v1.0.0",
    },
    FR = {
        WindowTitle       = "SMTD Hub",
        TabHome           = "Accueil",
        TabAutoUpgrade    = "Auto Amélioration",
        TabTasks          = "Tâches",
        TabCodes          = "Codes",
        TabMovement       = "Déplacement",
        TabTools          = "Outils",
        CreditsTitle      = "Crédits",
        CreditsContent    = "Créé par Rival960 avec l'aide de Claude\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        VersionTitle      = "Version",
        VersionContent    = "v1.0.0 — Première version",
        AutoUpgradeToggle = "Auto Amélioration",
        AutoUpgradeDesc   = "Boucle slots 1→10 toutes les 0,5 s. Peut échouer silencieusement sans ressources.",
        UpgradeOk         = "Slot {s} amélioré ✓",
        ShowTasksBtn      = "Afficher les tâches",
        ShowTasksDesc     = "Affiche les dernières données tasks_update reçues du serveur (lecture seule).",
        NoTaskData        = "Aucune donnée de tâche. Jouez un moment et réessayez.",
        TasksTitle        = "État des tâches",
        SpoofTasksBtn     = "Simuler toutes les tâches complétées (visuel)",
        SpoofTasksDesc    = "Envoie un faux tasks_update à l'UI client seulement. Aucune récompense serveur.",
        SpoofDone         = "Tâches simulées côté client (visuel uniquement — aucune récompense serveur)",
        RedeemCodesBtn    = "Utiliser tous les codes",
        RedeemCodesDesc   = "Recherche la zone de saisie de code dans l'UI et soumet chaque code. Ouvrez le panneau codes d'abord.",
        RedeemDone        = "{n} codes tentés. Vérifiez en jeu pour les résultats.",
        RedeemNotFound    = "Zone de saisie introuvable — ouvrez d'abord le panneau codes en jeu.",
        FlyToggle         = "Voler",
        FlySpeed          = "Vitesse de vol",
        NoClipToggle      = "NoClip",
        WalkSpeedLabel    = "Vitesse de marche",
        FullbrightToggle  = "Fullbright",
        AntiAFKToggle     = "Anti-AFK",
        LangSelect        = "Langue",
        LangReload        = "Ré-exécutez le script pour appliquer la langue.",
        Loaded            = "Hub chargé ! Bienvenue sur SMTD Hub v1.0.0",
    },
    DE = {
        WindowTitle       = "SMTD Hub",
        TabHome           = "Startseite",
        TabAutoUpgrade    = "Auto-Upgrade",
        TabTasks          = "Aufgaben",
        TabCodes          = "Codes",
        TabMovement       = "Bewegung",
        TabTools          = "Werkzeuge",
        CreditsTitle      = "Danksagungen",
        CreditsContent    = "Erstellt von Rival960 mit Hilfe von Claude\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        VersionTitle      = "Version",
        VersionContent    = "v1.0.0 — Erste Version",
        AutoUpgradeToggle = "Auto-Upgrade",
        AutoUpgradeDesc   = "Schleife Slots 1→10 alle 0,5 s. Kann ohne Ressourcen stumm fehlschlagen.",
        UpgradeOk         = "Slot {s} verbessert ✓",
        ShowTasksBtn      = "Aufgabenstatus anzeigen",
        ShowTasksDesc     = "Zeigt die zuletzt empfangenen tasks_update-Daten vom Server (nur lesend).",
        NoTaskData        = "Keine Aufgabendaten. Spiele kurz und versuche es erneut.",
        TasksTitle        = "Aufgabenstatus",
        SpoofTasksBtn     = "Alle Aufgaben als erledigt simulieren (visuell)",
        SpoofTasksDesc    = "Sendet ein gefälschtes tasks_update nur an die Client-UI. Keine Server-Belohnungen.",
        SpoofDone         = "Aufgaben clientseitig simuliert (nur visuell — keine Server-Belohnungen)",
        RedeemCodesBtn    = "Alle Codes einlösen",
        RedeemCodesDesc   = "Sucht das Code-Eingabefeld in der UI und sendet jeden Code. Öffne zuerst das Code-Panel.",
        RedeemDone        = "{n} Codes versucht. Prüfe das Spiel auf Ergebnisse.",
        RedeemNotFound    = "Code-Eingabe nicht gefunden — öffne zuerst das Code-Panel im Spiel.",
        FlyToggle         = "Fliegen",
        FlySpeed          = "Fluggeschwindigkeit",
        NoClipToggle      = "NoClip",
        WalkSpeedLabel    = "Gehgeschwindigkeit",
        FullbrightToggle  = "Vollhell",
        AntiAFKToggle     = "Anti-AFK",
        LangSelect        = "Sprache",
        LangReload        = "Skript neu ausführen, um die Sprache anzuwenden.",
        Loaded            = "Hub geladen! Willkommen im SMTD Hub v1.0.0",
    },
    ES = {
        WindowTitle       = "SMTD Hub",
        TabHome           = "Inicio",
        TabAutoUpgrade    = "Auto Mejora",
        TabTasks          = "Tareas",
        TabCodes          = "Códigos",
        TabMovement       = "Movimiento",
        TabTools          = "Herramientas",
        CreditsTitle      = "Créditos",
        CreditsContent    = "Creado por Rival960 con ayuda de Claude\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        VersionTitle      = "Versión",
        VersionContent    = "v1.0.0 — Primera versión",
        AutoUpgradeToggle = "Auto Mejora",
        AutoUpgradeDesc   = "Bucle slots 1→10 cada 0,5 s. Puede fallar silenciosamente sin recursos.",
        UpgradeOk         = "Slot {s} mejorado ✓",
        ShowTasksBtn      = "Ver estado de tareas",
        ShowTasksDesc     = "Muestra los últimos datos tasks_update recibidos del servidor (solo lectura).",
        NoTaskData        = "Sin datos de tareas. Juega un momento y vuelve a intentarlo.",
        TasksTitle        = "Estado de tareas",
        SpoofTasksBtn     = "Simular todas las tareas completadas (visual)",
        SpoofTasksDesc    = "Envía un tasks_update falso solo a la UI cliente. Sin recompensas del servidor.",
        SpoofDone         = "Tareas simuladas en el cliente (solo visual — sin recompensas del servidor)",
        RedeemCodesBtn    = "Canjear todos los códigos",
        RedeemCodesDesc   = "Busca el campo de entrada de código en la UI y envía cada código. Abre el panel de códigos primero.",
        RedeemDone        = "{n} códigos intentados. Comprueba el juego para ver resultados.",
        RedeemNotFound    = "Campo de código no encontrado — abre primero el panel de códigos en el juego.",
        FlyToggle         = "Volar",
        FlySpeed          = "Velocidad de vuelo",
        NoClipToggle      = "NoClip",
        WalkSpeedLabel    = "Velocidad de caminar",
        FullbrightToggle  = "Brillo total",
        AntiAFKToggle     = "Anti-AFK",
        LangSelect        = "Idioma",
        LangReload        = "Vuelve a ejecutar el script para aplicar el idioma.",
        Loaded            = "¡Hub cargado! Bienvenido al SMTD Hub v1.0.0",
    },
    PT = {
        WindowTitle       = "SMTD Hub",
        TabHome           = "Início",
        TabAutoUpgrade    = "Auto Melhoria",
        TabTasks          = "Tarefas",
        TabCodes          = "Códigos",
        TabMovement       = "Movimento",
        TabTools          = "Ferramentas",
        CreditsTitle      = "Créditos",
        CreditsContent    = "Criado por Rival960 com ajuda de Claude\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        VersionTitle      = "Versão",
        VersionContent    = "v1.0.0 — Primeiro lançamento",
        AutoUpgradeToggle = "Auto Melhoria",
        AutoUpgradeDesc   = "Loop slots 1→10 a cada 0,5 s. Pode falhar silenciosamente sem recursos.",
        UpgradeOk         = "Slot {s} melhorado ✓",
        ShowTasksBtn      = "Ver status das tarefas",
        ShowTasksDesc     = "Exibe os últimos dados tasks_update recebidos do servidor (somente leitura).",
        NoTaskData        = "Sem dados de tarefas. Jogue um momento e tente novamente.",
        TasksTitle        = "Status das tarefas",
        SpoofTasksBtn     = "Simular todas as tarefas concluídas (visual)",
        SpoofTasksDesc    = "Envia um tasks_update falso apenas para a UI do cliente. Sem recompensas do servidor.",
        SpoofDone         = "Tarefas simuladas no cliente (apenas visual — sem recompensas do servidor)",
        RedeemCodesBtn    = "Resgatar todos os códigos",
        RedeemCodesDesc   = "Procura o campo de código na UI e envia cada código. Abra o painel de códigos primeiro.",
        RedeemDone        = "{n} códigos tentados. Verifique no jogo os resultados.",
        RedeemNotFound    = "Campo de código não encontrado — abra primeiro o painel de códigos no jogo.",
        FlyToggle         = "Voar",
        FlySpeed          = "Velocidade de voo",
        NoClipToggle      = "NoClip",
        WalkSpeedLabel    = "Velocidade de caminhada",
        FullbrightToggle  = "Fullbright",
        AntiAFKToggle     = "Anti-AFK",
        LangSelect        = "Idioma",
        LangReload        = "Execute o script novamente para aplicar o idioma.",
        Loaded            = "Hub carregado! Bem-vindo ao SMTD Hub v1.0.0",
    },
    RU = {
        WindowTitle       = "SMTD Hub",
        TabHome           = "Главная",
        TabAutoUpgrade    = "Авто-улучшение",
        TabTasks          = "Задания",
        TabCodes          = "Коды",
        TabMovement       = "Движение",
        TabTools          = "Инструменты",
        CreditsTitle      = "Авторы",
        CreditsContent    = "Создано Rival960 при помощи Claude\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        VersionTitle      = "Версия",
        VersionContent    = "v1.0.0 — Первый выпуск",
        AutoUpgradeToggle = "Авто-улучшение",
        AutoUpgradeDesc   = "Цикл слотов 1→10 каждые 0,5 с. Может молча не сработать без ресурсов.",
        UpgradeOk         = "Слот {s} улучшен ✓",
        ShowTasksBtn      = "Показать задания",
        ShowTasksDesc     = "Отображает последние данные tasks_update от сервера (только чтение).",
        NoTaskData        = "Данных заданий нет. Поиграйте немного и повторите.",
        TasksTitle        = "Статус заданий",
        SpoofTasksBtn     = "Симулировать выполнение всех заданий (визуально)",
        SpoofTasksDesc    = "Отправляет фейковый tasks_update только клиентскому UI. Награды не выдаются.",
        SpoofDone         = "Задания симулированы на клиенте (только визуально — без наград)",
        RedeemCodesBtn    = "Активировать все коды",
        RedeemCodesDesc   = "Ищет поле ввода кода в UI и отправляет каждый код. Сначала откройте панель кодов.",
        RedeemDone        = "Отправлено {n} кодов. Проверьте результаты в игре.",
        RedeemNotFound    = "Поле ввода кода не найдено — сначала откройте панель кодов в игре.",
        FlyToggle         = "Полёт",
        FlySpeed          = "Скорость полёта",
        NoClipToggle      = "NoClip",
        WalkSpeedLabel    = "Скорость ходьбы",
        FullbrightToggle  = "Полный свет",
        AntiAFKToggle     = "Анти-АФК",
        LangSelect        = "Язык",
        LangReload        = "Перезапустите скрипт для применения языка.",
        Loaded            = "Hub загружен! Добро пожаловать в SMTD Hub v1.0.0",
    },
    IT = {
        WindowTitle       = "SMTD Hub",
        TabHome           = "Home",
        TabAutoUpgrade    = "Auto Potenziamento",
        TabTasks          = "Missioni",
        TabCodes          = "Codici",
        TabMovement       = "Movimento",
        TabTools          = "Strumenti",
        CreditsTitle      = "Crediti",
        CreditsContent    = "Creato da Rival960 con l'aiuto di Claude\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        VersionTitle      = "Versione",
        VersionContent    = "v1.0.0 — Prima versione",
        AutoUpgradeToggle = "Auto Potenziamento",
        AutoUpgradeDesc   = "Ciclo slot 1→10 ogni 0,5 s. Può fallire silenziosamente senza risorse.",
        UpgradeOk         = "Slot {s} potenziato ✓",
        ShowTasksBtn      = "Mostra stato missioni",
        ShowTasksDesc     = "Mostra gli ultimi dati tasks_update ricevuti dal server (sola lettura).",
        NoTaskData        = "Nessun dato missioni. Gioca un momento e riprova.",
        TasksTitle        = "Stato missioni",
        SpoofTasksBtn     = "Simula tutte le missioni completate (visuale)",
        SpoofTasksDesc    = "Invia un tasks_update falso solo alla UI client. Nessuna ricompensa server.",
        SpoofDone         = "Missioni simulate lato client (solo visuale — nessuna ricompensa server)",
        RedeemCodesBtn    = "Riscatta tutti i codici",
        RedeemCodesDesc   = "Cerca il campo codice nella UI e invia ogni codice. Apri prima il pannello codici.",
        RedeemDone        = "{n} codici tentati. Controlla i risultati nel gioco.",
        RedeemNotFound    = "Campo codice non trovato — apri prima il pannello codici nel gioco.",
        FlyToggle         = "Volare",
        FlySpeed          = "Velocità di volo",
        NoClipToggle      = "NoClip",
        WalkSpeedLabel    = "Velocità di camminata",
        FullbrightToggle  = "Luce piena",
        AntiAFKToggle     = "Anti-AFK",
        LangSelect        = "Lingua",
        LangReload        = "Riesegui lo script per applicare la lingua.",
        Loaded            = "Hub caricato! Benvenuto su SMTD Hub v1.0.0",
    },
    NL = {
        WindowTitle       = "SMTD Hub",
        TabHome           = "Home",
        TabAutoUpgrade    = "Auto Upgrade",
        TabTasks          = "Taken",
        TabCodes          = "Codes",
        TabMovement       = "Beweging",
        TabTools          = "Gereedschap",
        CreditsTitle      = "Credits",
        CreditsContent    = "Gemaakt door Rival960 met hulp van Claude\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        VersionTitle      = "Versie",
        VersionContent    = "v1.0.0 — Eerste versie",
        AutoUpgradeToggle = "Auto Upgrade",
        AutoUpgradeDesc   = "Lus slots 1→10 elke 0,5 s. Kan stil falen zonder middelen.",
        UpgradeOk         = "Slot {s} geüpgraded ✓",
        ShowTasksBtn      = "Taakstatus tonen",
        ShowTasksDesc     = "Toont de laatste tasks_update gegevens van de server (alleen lezen).",
        NoTaskData        = "Geen taakgegevens. Speel even en probeer opnieuw.",
        TasksTitle        = "Taakstatus",
        SpoofTasksBtn     = "Alle taken als voltooid simuleren (visueel)",
        SpoofTasksDesc    = "Stuurt een nep tasks_update alleen naar de client-UI. Geen serverbeloningen.",
        SpoofDone         = "Taken gesimuleerd aan clientzijde (alleen visueel — geen serverbeloningen)",
        RedeemCodesBtn    = "Alle codes inwisselen",
        RedeemCodesDesc   = "Zoekt het code-invoerveld in de UI en stuurt elke code. Open het codepaneel eerst.",
        RedeemDone        = "{n} codes geprobeerd. Controleer het spel voor resultaten.",
        RedeemNotFound    = "Code-invoerveld niet gevonden — open eerst het codepaneel in het spel.",
        FlyToggle         = "Vliegen",
        FlySpeed          = "Vliegsnelheid",
        NoClipToggle      = "NoClip",
        WalkSpeedLabel    = "Loopsnelheid",
        FullbrightToggle  = "Vollicht",
        AntiAFKToggle     = "Anti-AFK",
        LangSelect        = "Taal",
        LangReload        = "Herstart het script om de taal toe te passen.",
        Loaded            = "Hub geladen! Welkom bij SMTD Hub v1.0.0",
    },
    PL = {
        WindowTitle       = "SMTD Hub",
        TabHome           = "Strona główna",
        TabAutoUpgrade    = "Auto ulepszenie",
        TabTasks          = "Zadania",
        TabCodes          = "Kody",
        TabMovement       = "Ruch",
        TabTools          = "Narzędzia",
        CreditsTitle      = "Podziękowania",
        CreditsContent    = "Stworzone przez Rival960 z pomocą Claude\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        VersionTitle      = "Wersja",
        VersionContent    = "v1.0.0 — Pierwsze wydanie",
        AutoUpgradeToggle = "Auto ulepszenie",
        AutoUpgradeDesc   = "Pętla slotów 1→10 co 0,5 s. Może cicho zawieść bez zasobów.",
        UpgradeOk         = "Slot {s} ulepszony ✓",
        ShowTasksBtn      = "Pokaż status zadań",
        ShowTasksDesc     = "Wyświetla ostatnie dane tasks_update otrzymane z serwera (tylko odczyt).",
        NoTaskData        = "Brak danych zadań. Zagraj chwilę i spróbuj ponownie.",
        TasksTitle        = "Status zadań",
        SpoofTasksBtn     = "Symuluj wszystkie zadania jako ukończone (wizualnie)",
        SpoofTasksDesc    = "Wysyła fałszywy tasks_update tylko do UI klienta. Brak nagród serwerowych.",
        SpoofDone         = "Zadania symulowane po stronie klienta (tylko wizualnie — brak nagród serwera)",
        RedeemCodesBtn    = "Użyj wszystkich kodów",
        RedeemCodesDesc   = "Szuka pola kodu w UI i wysyła każdy kod. Najpierw otwórz panel kodów.",
        RedeemDone        = "Wypróbowano {n} kodów. Sprawdź wyniki w grze.",
        RedeemNotFound    = "Pole kodu nie znalezione — otwórz najpierw panel kodów w grze.",
        FlyToggle         = "Latanie",
        FlySpeed          = "Prędkość lotu",
        NoClipToggle      = "NoClip",
        WalkSpeedLabel    = "Prędkość chodzenia",
        FullbrightToggle  = "Pełna jasność",
        AntiAFKToggle     = "Anti-AFK",
        LangSelect        = "Język",
        LangReload        = "Uruchom skrypt ponownie, aby zastosować język.",
        Loaded            = "Hub załadowany! Witaj w SMTD Hub v1.0.0",
    },
    ZH = {
        WindowTitle       = "SMTD Hub",
        TabHome           = "主页",
        TabAutoUpgrade    = "自动升级",
        TabTasks          = "任务",
        TabCodes          = "兑换码",
        TabMovement       = "移动",
        TabTools          = "工具",
        CreditsTitle      = "致谢",
        CreditsContent    = "由 Rival960 与 Claude 共同制作\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        VersionTitle      = "版本",
        VersionContent    = "v1.0.0 — 首次发布",
        AutoUpgradeToggle = "自动升级",
        AutoUpgradeDesc   = "每 0.5 秒循环槽位 1→10。资源不足时可能静默失败。",
        UpgradeOk         = "槽位 {s} 升级成功 ✓",
        ShowTasksBtn      = "显示任务状态",
        ShowTasksDesc     = "显示从服务器收到的最新 tasks_update 数据（只读）。",
        NoTaskData        = "尚无任务数据，玩一会儿再试。",
        TasksTitle        = "任务状态",
        SpoofTasksBtn     = "模拟所有任务已完成（仅视觉）",
        SpoofTasksDesc    = "仅向客户端 UI 发送伪造的 tasks_update。不授予服务器奖励。",
        SpoofDone         = "任务已在客户端模拟（仅视觉效果 — 不获得服务器奖励）",
        RedeemCodesBtn    = "自动兑换所有码",
        RedeemCodesDesc   = "在 UI 中搜索兑换码输入框并提交每个码。请先打开兑换码面板。",
        RedeemDone        = "已尝试 {n} 个兑换码，请在游戏中查看结果。",
        RedeemNotFound    = "未找到兑换码输入框 — 请先在游戏中打开兑换码面板。",
        FlyToggle         = "飞行",
        FlySpeed          = "飞行速度",
        NoClipToggle      = "穿墙",
        WalkSpeedLabel    = "行走速度",
        FullbrightToggle  = "全亮",
        AntiAFKToggle     = "防 AFK",
        LangSelect        = "语言",
        LangReload        = "重新执行脚本以应用语言设置。",
        Loaded            = "Hub 已加载！欢迎使用 SMTD Hub v1.0.0",
    },
    JA = {
        WindowTitle       = "SMTD Hub",
        TabHome           = "ホーム",
        TabAutoUpgrade    = "オートアップグレード",
        TabTasks          = "タスク",
        TabCodes          = "コード",
        TabMovement       = "移動",
        TabTools          = "ツール",
        CreditsTitle      = "クレジット",
        CreditsContent    = "Rival960 と Claude が共同制作\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        VersionTitle      = "バージョン",
        VersionContent    = "v1.0.0 — 初回リリース",
        AutoUpgradeToggle = "オートアップグレード",
        AutoUpgradeDesc   = "0.5 秒ごとにスロット 1→10 をループ。リソース不足の場合サイレントに失敗します。",
        UpgradeOk         = "スロット {s} アップグレード ✓",
        ShowTasksBtn      = "タスク状況を表示",
        ShowTasksDesc     = "サーバーから受信した最新の tasks_update データを表示（読み取り専用）。",
        NoTaskData        = "タスクデータなし。しばらくプレイして再試行してください。",
        TasksTitle        = "タスク状況",
        SpoofTasksBtn     = "全タスクを完了済みに偽装（ビジュアルのみ）",
        SpoofTasksDesc    = "クライアント UI にのみ偽の tasks_update を送信します。サーバー報酬は付与されません。",
        SpoofDone         = "タスクをクライアント側で偽装しました（ビジュアルのみ — サーバー報酬なし）",
        RedeemCodesBtn    = "全コードを自動入力",
        RedeemCodesDesc   = "UI のコード入力欄を探し、各コードを送信します。先にコードパネルを開いてください。",
        RedeemDone        = "{n} 件のコードを試みました。ゲーム内で結果を確認してください。",
        RedeemNotFound    = "コード入力欄が見つかりません — 先にゲーム内でコードパネルを開いてください。",
        FlyToggle         = "飛行",
        FlySpeed          = "飛行速度",
        NoClipToggle      = "ノークリップ",
        WalkSpeedLabel    = "歩行速度",
        FullbrightToggle  = "フルブライト",
        AntiAFKToggle     = "アンチAFK",
        LangSelect        = "言語",
        LangReload        = "言語を適用するにはスクリプトを再実行してください。",
        Loaded            = "Hub 読み込み完了！SMTD Hub v1.0.0 へようこそ。",
    },
    TR = {
        WindowTitle       = "SMTD Hub",
        TabHome           = "Ana Sayfa",
        TabAutoUpgrade    = "Otomatik Yükseltme",
        TabTasks          = "Görevler",
        TabCodes          = "Kodlar",
        TabMovement       = "Hareket",
        TabTools          = "Araçlar",
        CreditsTitle      = "Krediler",
        CreditsContent    = "Rival960 tarafından Claude yardımıyla oluşturuldu\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        VersionTitle      = "Sürüm",
        VersionContent    = "v1.0.0 — İlk sürüm",
        AutoUpgradeToggle = "Otomatik Yükseltme",
        AutoUpgradeDesc   = "Her 0,5 s'de slotlar 1→10'u döngüler. Kaynak yoksa sessizce başarısız olabilir.",
        UpgradeOk         = "Slot {s} yükseltildi ✓",
        ShowTasksBtn      = "Görev durumunu göster",
        ShowTasksDesc     = "Sunucudan alınan son tasks_update verilerini gösterir (salt okunur).",
        NoTaskData        = "Görev verisi yok. Biraz oynayıp tekrar dene.",
        TasksTitle        = "Görev Durumu",
        SpoofTasksBtn     = "Tüm görevleri tamamlandı olarak simüle et (görsel)",
        SpoofTasksDesc    = "Yalnızca istemci UI'ına sahte tasks_update gönderir. Sunucu ödülü verilmez.",
        SpoofDone         = "Görevler istemci tarafında simüle edildi (yalnızca görsel — sunucu ödülü yok)",
        RedeemCodesBtn    = "Tüm kodları kullan",
        RedeemCodesDesc   = "UI'da kod giriş alanını arar ve her kodu gönderir. Önce kod panelini aç.",
        RedeemDone        = "{n} kod denendi. Sonuçlar için oyunu kontrol et.",
        RedeemNotFound    = "Kod giriş alanı bulunamadı — önce oyunda kod panelini aç.",
        FlyToggle         = "Uçuş",
        FlySpeed          = "Uçuş Hızı",
        NoClipToggle      = "NoClip",
        WalkSpeedLabel    = "Yürüme Hızı",
        FullbrightToggle  = "Tam Parlaklık",
        AntiAFKToggle     = "Anti-AFK",
        LangSelect        = "Dil",
        LangReload        = "Dili uygulamak için scripti yeniden çalıştırın.",
        Loaded            = "Hub yüklendi! SMTD Hub v1.0.0'a hoş geldin.",
    },
    KO = {
        WindowTitle       = "SMTD Hub",
        TabHome           = "홈",
        TabAutoUpgrade    = "자동 업그레이드",
        TabTasks          = "임무",
        TabCodes          = "코드",
        TabMovement       = "이동",
        TabTools          = "도구",
        CreditsTitle      = "크레딧",
        CreditsContent    = "Rival960이 Claude의 도움으로 제작\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        VersionTitle      = "버전",
        VersionContent    = "v1.0.0 — 첫 번째 출시",
        AutoUpgradeToggle = "자동 업그레이드",
        AutoUpgradeDesc   = "0.5초마다 슬롯 1→10을 반복합니다. 자원이 부족하면 조용히 실패할 수 있습니다.",
        UpgradeOk         = "슬롯 {s} 업그레이드 ✓",
        ShowTasksBtn      = "임무 상태 보기",
        ShowTasksDesc     = "서버에서 받은 최신 tasks_update 데이터 표시 (읽기 전용).",
        NoTaskData        = "임무 데이터 없음. 잠깐 플레이 후 다시 시도하세요.",
        TasksTitle        = "임무 상태",
        SpoofTasksBtn     = "모든 임무 완료로 위장 (시각 전용)",
        SpoofTasksDesc    = "클라이언트 UI에만 가짜 tasks_update를 보냅니다. 서버 보상은 없습니다.",
        SpoofDone         = "임무를 클라이언트에서 위장했습니다 (시각 전용 — 서버 보상 없음)",
        RedeemCodesBtn    = "모든 코드 자동 입력",
        RedeemCodesDesc   = "UI에서 코드 입력창을 찾아 각 코드를 제출합니다. 먼저 코드 패널을 여세요.",
        RedeemDone        = "{n}개의 코드를 시도했습니다. 게임에서 결과를 확인하세요.",
        RedeemNotFound    = "코드 입력창을 찾을 수 없습니다 — 먼저 게임 내 코드 패널을 여세요.",
        FlyToggle         = "비행",
        FlySpeed          = "비행 속도",
        NoClipToggle      = "노클립",
        WalkSpeedLabel    = "걷기 속도",
        FullbrightToggle  = "풀브라이트",
        AntiAFKToggle     = "안티 AFK",
        LangSelect        = "언어",
        LangReload        = "언어를 적용하려면 스크립트를 다시 실행하세요.",
        Loaded            = "Hub 로드 완료! SMTD Hub v1.0.0에 오신 것을 환영합니다.",
    },
    AR = {
        WindowTitle       = "SMTD Hub",
        TabHome           = "الرئيسية",
        TabAutoUpgrade    = "ترقية تلقائية",
        TabTasks          = "المهام",
        TabCodes          = "الأكواد",
        TabMovement       = "الحركة",
        TabTools          = "أدوات",
        CreditsTitle      = "الاعتمادات",
        CreditsContent    = "صنعه Rival960 بمساعدة Claude\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        VersionTitle      = "الإصدار",
        VersionContent    = "v1.0.0 — الإصدار الأول",
        AutoUpgradeToggle = "ترقية تلقائية",
        AutoUpgradeDesc   = "حلقة الفتحات 1→10 كل 0,5 ثانية. قد تفشل بصمت دون موارد.",
        UpgradeOk         = "تمت ترقية الفتحة {s} ✓",
        ShowTasksBtn      = "عرض حالة المهام",
        ShowTasksDesc     = "يعرض آخر بيانات tasks_update المستلمة من الخادم (للقراءة فقط).",
        NoTaskData        = "لا توجد بيانات مهام. العب قليلاً وحاول مرة أخرى.",
        TasksTitle        = "حالة المهام",
        SpoofTasksBtn     = "محاكاة جميع المهام كمكتملة (مرئي فقط)",
        SpoofTasksDesc    = "يرسل tasks_update مزيف إلى واجهة المستخدم فقط. لا توجد مكافآت من الخادم.",
        SpoofDone         = "تمت محاكاة المهام على جانب العميل (مرئي فقط — لا مكافآت من الخادم)",
        RedeemCodesBtn    = "استرداد جميع الأكواد",
        RedeemCodesDesc   = "يبحث عن حقل إدخال الكود في الواجهة ويرسل كل كود. افتح لوحة الأكواد أولاً.",
        RedeemDone        = "تمت محاولة {n} كوداً. تحقق من النتائج في اللعبة.",
        RedeemNotFound    = "لم يتم العثور على حقل الكود — افتح لوحة الأكواد في اللعبة أولاً.",
        FlyToggle         = "الطيران",
        FlySpeed          = "سرعة الطيران",
        NoClipToggle      = "عبور الجدران",
        WalkSpeedLabel    = "سرعة المشي",
        FullbrightToggle  = "إضاءة كاملة",
        AntiAFKToggle     = "مكافحة AFK",
        LangSelect        = "اللغة",
        LangReload        = "أعد تشغيل السكريبت لتطبيق اللغة.",
        Loaded            = "تم تحميل Hub! مرحباً بك في SMTD Hub v1.0.0",
    },
    VI = {
        WindowTitle       = "SMTD Hub",
        TabHome           = "Trang chủ",
        TabAutoUpgrade    = "Tự động nâng cấp",
        TabTasks          = "Nhiệm vụ",
        TabCodes          = "Mã code",
        TabMovement       = "Di chuyển",
        TabTools          = "Công cụ",
        CreditsTitle      = "Tín dụng",
        CreditsContent    = "Được tạo bởi Rival960 với sự hỗ trợ của Claude\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        VersionTitle      = "Phiên bản",
        VersionContent    = "v1.0.0 — Phát hành đầu tiên",
        AutoUpgradeToggle = "Tự động nâng cấp",
        AutoUpgradeDesc   = "Vòng lặp slot 1→10 mỗi 0,5 giây. Có thể thất bại thầm lặng nếu thiếu tài nguyên.",
        UpgradeOk         = "Slot {s} đã nâng cấp ✓",
        ShowTasksBtn      = "Xem trạng thái nhiệm vụ",
        ShowTasksDesc     = "Hiển thị dữ liệu tasks_update mới nhất nhận từ máy chủ (chỉ đọc).",
        NoTaskData        = "Chưa có dữ liệu nhiệm vụ. Chơi một lúc rồi thử lại.",
        TasksTitle        = "Trạng thái nhiệm vụ",
        SpoofTasksBtn     = "Giả mạo tất cả nhiệm vụ hoàn thành (chỉ hiển thị)",
        SpoofTasksDesc    = "Gửi tasks_update giả chỉ đến UI client. Không có phần thưởng từ máy chủ.",
        SpoofDone         = "Nhiệm vụ đã được giả mạo phía client (chỉ hiển thị — không có phần thưởng máy chủ)",
        RedeemCodesBtn    = "Tự động nhập tất cả mã",
        RedeemCodesDesc   = "Tìm ô nhập mã trong UI và gửi từng mã. Mở bảng mã trước.",
        RedeemDone        = "Đã thử {n} mã. Kiểm tra kết quả trong game.",
        RedeemNotFound    = "Không tìm thấy ô nhập mã — hãy mở bảng mã trong game trước.",
        FlyToggle         = "Bay",
        FlySpeed          = "Tốc độ bay",
        NoClipToggle      = "Xuyên tường",
        WalkSpeedLabel    = "Tốc độ đi bộ",
        FullbrightToggle  = "Sáng toàn màn",
        AntiAFKToggle     = "Chống AFK",
        LangSelect        = "Ngôn ngữ",
        LangReload        = "Chạy lại script để áp dụng ngôn ngữ.",
        Loaded            = "Hub đã tải! Chào mừng đến SMTD Hub v1.0.0",
    },
    SV = {
        WindowTitle       = "SMTD Hub",
        TabHome           = "Hem",
        TabAutoUpgrade    = "Auto-uppgradering",
        TabTasks          = "Uppdrag",
        TabCodes          = "Koder",
        TabMovement       = "Rörelse",
        TabTools          = "Verktyg",
        CreditsTitle      = "Tack",
        CreditsContent    = "Skapad av Rival960 med hjälp av Claude\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        VersionTitle      = "Version",
        VersionContent    = "v1.0.0 — Första utgåvan",
        AutoUpgradeToggle = "Auto-uppgradering",
        AutoUpgradeDesc   = "Loopar slot 1→10 var 0,5 s. Kan misslyckas tyst utan resurser.",
        UpgradeOk         = "Slot {s} uppgraderad ✓",
        ShowTasksBtn      = "Visa uppdragsstatus",
        ShowTasksDesc     = "Visar senaste tasks_update-data från servern (skrivskyddad).",
        NoTaskData        = "Inga uppdragsdata. Spela lite och försök igen.",
        TasksTitle        = "Uppdragsstatus",
        SpoofTasksBtn     = "Simulera alla uppdrag slutförda (visuellt)",
        SpoofTasksDesc    = "Skickar ett falskt tasks_update bara till klient-UI. Inga serverbelöningar.",
        SpoofDone         = "Uppdrag simulerade på klientsidan (endast visuellt — inga serverbelöningar)",
        RedeemCodesBtn    = "Lös in alla koder",
        RedeemCodesDesc   = "Söker kodinmatningsfältet i UI och skickar varje kod. Öppna kodpanelen först.",
        RedeemDone        = "{n} koder försökta. Kontrollera spelet för resultat.",
        RedeemNotFound    = "Kodinmatning hittades inte — öppna kodpanelen i spelet först.",
        FlyToggle         = "Flyg",
        FlySpeed          = "Flighastighet",
        NoClipToggle      = "NoClip",
        WalkSpeedLabel    = "Gånghastighet",
        FullbrightToggle  = "Fulljus",
        AntiAFKToggle     = "Anti-AFK",
        LangSelect        = "Språk",
        LangReload        = "Kör om scriptet för att tillämpa språket.",
        Loaded            = "Hub inläst! Välkommen till SMTD Hub v1.0.0",
    },
    EL = {
        WindowTitle       = "SMTD Hub",
        TabHome           = "Αρχική",
        TabAutoUpgrade    = "Αυτόματη Αναβάθμιση",
        TabTasks          = "Αποστολές",
        TabCodes          = "Κωδικοί",
        TabMovement       = "Κίνηση",
        TabTools          = "Εργαλεία",
        CreditsTitle      = "Χρεώσεις",
        CreditsContent    = "Δημιουργήθηκε από Rival960 με βοήθεια Claude\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        VersionTitle      = "Έκδοση",
        VersionContent    = "v1.0.0 — Πρώτη έκδοση",
        AutoUpgradeToggle = "Αυτόματη Αναβάθμιση",
        AutoUpgradeDesc   = "Βρόχος αναβαθμίσεων 1→10 κάθε 0,5 δ. Μπορεί να αποτύχει αθόρυβα χωρίς πόρους.",
        UpgradeOk         = "Θέση {s} αναβαθμίστηκε ✓",
        ShowTasksBtn      = "Εμφάνιση αποστολών",
        ShowTasksDesc     = "Εμφανίζει τα τελευταία δεδομένα tasks_update από τον διακομιστή (μόνο ανάγνωση).",
        NoTaskData        = "Δεν υπάρχουν δεδομένα αποστολών. Παίξτε λίγο και δοκιμάστε ξανά.",
        TasksTitle        = "Κατάσταση Αποστολών",
        SpoofTasksBtn     = "Προσομοίωση όλων ολοκληρωμένων (μόνο οπτικό)",
        SpoofTasksDesc    = "Στέλνει ψεύτικο tasks_update μόνο στο UI του πελάτη. Χωρίς ανταμοιβές διακομιστή.",
        SpoofDone         = "Αποστολές προσομοιώθηκαν στον πελάτη (μόνο οπτικό — χωρίς ανταμοιβές)",
        RedeemCodesBtn    = "Εξαργύρωση όλων των κωδικών",
        RedeemCodesDesc   = "Αναζητά πεδίο εισαγωγής κωδικού στο UI και στέλνει κάθε κωδικό. Ανοίξτε πρώτα τον πίνακα κωδικών.",
        RedeemDone        = "Δοκιμάστηκαν {n} κωδικοί. Ελέγξτε αποτελέσματα στο παιχνίδι.",
        RedeemNotFound    = "Πεδίο κωδικού δεν βρέθηκε — ανοίξτε πρώτα τον πίνακα κωδικών στο παιχνίδι.",
        FlyToggle         = "Πτήση",
        FlySpeed          = "Ταχύτητα πτήσης",
        NoClipToggle      = "NoClip",
        WalkSpeedLabel    = "Ταχύτητα βαδίσματος",
        FullbrightToggle  = "Πλήρης φωτεινότητα",
        AntiAFKToggle     = "Κατά-AFK",
        LangSelect        = "Γλώσσα",
        LangReload        = "Εκτελέστε ξανά το script για αλλαγή γλώσσας.",
        Loaded            = "Hub φορτώθηκε! Καλωσήλθατε στο SMTD Hub v1.0.0",
    },
    RO = {
        WindowTitle       = "SMTD Hub",
        TabHome           = "Acasă",
        TabAutoUpgrade    = "Upgrade Automat",
        TabTasks          = "Misiuni",
        TabCodes          = "Coduri",
        TabMovement       = "Mișcare",
        TabTools          = "Instrumente",
        CreditsTitle      = "Credite",
        CreditsContent    = "Creat de Rival960 cu ajutorul Claude\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        VersionTitle      = "Versiune",
        VersionContent    = "v1.0.0 — Prima lansare",
        AutoUpgradeToggle = "Upgrade Automat",
        AutoUpgradeDesc   = "Buclă sloturi 1→10 la fiecare 0,5 s. Poate eșua silențios fără resurse.",
        UpgradeOk         = "Slotul {s} îmbunătățit ✓",
        ShowTasksBtn      = "Afișează statusul misiunilor",
        ShowTasksDesc     = "Afișează ultimele date tasks_update primite de la server (doar citire).",
        NoTaskData        = "Fără date misiuni. Joacă puțin și încearcă din nou.",
        TasksTitle        = "Status misiuni",
        SpoofTasksBtn     = "Simulează toate misiunile completate (vizual)",
        SpoofTasksDesc    = "Trimite un tasks_update fals doar la UI-ul clientului. Fără recompense server.",
        SpoofDone         = "Misiuni simulate pe client (doar vizual — fără recompense server)",
        RedeemCodesBtn    = "Valorifică toate codurile",
        RedeemCodesDesc   = "Caută câmpul de cod în UI și trimite fiecare cod. Deschide panoul de coduri întâi.",
        RedeemDone        = "{n} coduri încercate. Verificați rezultatele în joc.",
        RedeemNotFound    = "Câmpul de cod nu a fost găsit — deschideți mai întâi panoul de coduri în joc.",
        FlyToggle         = "Zbor",
        FlySpeed          = "Viteză zbor",
        NoClipToggle      = "NoClip",
        WalkSpeedLabel    = "Viteză mers",
        FullbrightToggle  = "Luminozitate maximă",
        AntiAFKToggle     = "Anti-AFK",
        LangSelect        = "Limbă",
        LangReload        = "Rulați din nou scriptul pentru a aplica limba.",
        Loaded            = "Hub încărcat! Bun venit la SMTD Hub v1.0.0",
    },
    UK = {
        WindowTitle       = "SMTD Hub",
        TabHome           = "Головна",
        TabAutoUpgrade    = "Авто-покращення",
        TabTasks          = "Завдання",
        TabCodes          = "Коди",
        TabMovement       = "Рух",
        TabTools          = "Інструменти",
        CreditsTitle      = "Автори",
        CreditsContent    = "Створено Rival960 за допомогою Claude\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        VersionTitle      = "Версія",
        VersionContent    = "v1.0.0 — Перший випуск",
        AutoUpgradeToggle = "Авто-покращення",
        AutoUpgradeDesc   = "Цикл слотів 1→10 кожні 0,5 с. Може мовчки не спрацювати без ресурсів.",
        UpgradeOk         = "Слот {s} покращено ✓",
        ShowTasksBtn      = "Показати завдання",
        ShowTasksDesc     = "Відображає останні дані tasks_update від сервера (лише читання).",
        NoTaskData        = "Даних завдань немає. Пограйте трохи і повторіть.",
        TasksTitle        = "Статус завдань",
        SpoofTasksBtn     = "Симулювати всі завдання виконаними (лише візуально)",
        SpoofTasksDesc    = "Надсилає фейковий tasks_update лише клієнтському UI. Нагороди не видаються.",
        SpoofDone         = "Завдання симульовані на клієнті (лише візуально — без нагород сервера)",
        RedeemCodesBtn    = "Активувати всі коди",
        RedeemCodesDesc   = "Шукає поле введення коду в UI і відправляє кожен код. Спочатку відкрийте панель кодів.",
        RedeemDone        = "Надіслано {n} кодів. Перевірте результати в грі.",
        RedeemNotFound    = "Поле введення коду не знайдено — спочатку відкрийте панель кодів у грі.",
        FlyToggle         = "Польот",
        FlySpeed          = "Швидкість польоту",
        NoClipToggle      = "NoClip",
        WalkSpeedLabel    = "Швидкість ходьби",
        FullbrightToggle  = "Повне освітлення",
        AntiAFKToggle     = "Анти-АФК",
        LangSelect        = "Мова",
        LangReload        = "Перезапустіть скрипт для застосування мови.",
        Loaded            = "Hub завантажено! Ласкаво просимо до SMTD Hub v1.0.0",
    },
    CS = {
        WindowTitle       = "SMTD Hub",
        TabHome           = "Domů",
        TabAutoUpgrade    = "Automatické vylepšení",
        TabTasks          = "Úkoly",
        TabCodes          = "Kódy",
        TabMovement       = "Pohyb",
        TabTools          = "Nástroje",
        CreditsTitle      = "Zásluhy",
        CreditsContent    = "Vytvořil Rival960 s pomocí Claude\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        VersionTitle      = "Verze",
        VersionContent    = "v1.0.0 — První vydání",
        AutoUpgradeToggle = "Automatické vylepšení",
        AutoUpgradeDesc   = "Smyčka slotů 1→10 každých 0,5 s. Může tiše selhat bez zdrojů.",
        UpgradeOk         = "Slot {s} vylepšen ✓",
        ShowTasksBtn      = "Zobrazit stav úkolů",
        ShowTasksDesc     = "Zobrazuje poslední data tasks_update přijatá ze serveru (pouze čtení).",
        NoTaskData        = "Žádná data úkolů. Chvíli hrajte a zkuste znovu.",
        TasksTitle        = "Stav úkolů",
        SpoofTasksBtn     = "Simulovat všechny úkoly jako splněné (vizuálně)",
        SpoofTasksDesc    = "Odešle falešný tasks_update pouze do klientské UI. Žádné serverové odměny.",
        SpoofDone         = "Úkoly simulovány na klientu (pouze vizuálně — žádné odměny serveru)",
        RedeemCodesBtn    = "Uplatnit všechny kódy",
        RedeemCodesDesc   = "Hledá pole pro zadání kódu v UI a odesílá každý kód. Nejprve otevřete panel kódů.",
        RedeemDone        = "Bylo pokusů {n} kódů. Zkontrolujte výsledky ve hře.",
        RedeemNotFound    = "Pole kódu nenalezeno — nejprve otevřete panel kódů ve hře.",
        FlyToggle         = "Létání",
        FlySpeed          = "Rychlost letu",
        NoClipToggle      = "NoClip",
        WalkSpeedLabel    = "Rychlost chůze",
        FullbrightToggle  = "Plné světlo",
        AntiAFKToggle     = "Anti-AFK",
        LangSelect        = "Jazyk",
        LangReload        = "Spusťte skript znovu pro použití jazyka.",
        Loaded            = "Hub načten! Vítejte v SMTD Hub v1.0.0",
    },
    DA = {
        WindowTitle       = "SMTD Hub",
        TabHome           = "Hjem",
        TabAutoUpgrade    = "Auto-opgradering",
        TabTasks          = "Opgaver",
        TabCodes          = "Koder",
        TabMovement       = "Bevægelse",
        TabTools          = "Værktøjer",
        CreditsTitle      = "Tak",
        CreditsContent    = "Lavet af Rival960 med hjælp fra Claude\nDiscord: rival960 | GitHub: Rival99900 | YouTube: rival9607",
        VersionTitle      = "Version",
        VersionContent    = "v1.0.0 — Første udgivelse",
        AutoUpgradeToggle = "Auto-opgradering",
        AutoUpgradeDesc   = "Løkke over slots 1→10 hvert 0,5 s. Kan mislykkes lydløst uden ressourcer.",
        UpgradeOk         = "Slot {s} opgraderet ✓",
        ShowTasksBtn      = "Vis opgavestatus",
        ShowTasksDesc     = "Viser de seneste tasks_update-data modtaget fra serveren (skrivebeskyttet).",
        NoTaskData        = "Ingen opgavedata. Spil lidt og prøv igen.",
        TasksTitle        = "Opgavestatus",
        SpoofTasksBtn     = "Simuler alle opgaver som fuldført (visuelt)",
        SpoofTasksDesc    = "Sender et falsk tasks_update kun til klient-UI. Ingen serverbelønninger.",
        SpoofDone         = "Opgaver simuleret på klientsiden (kun visuelt — ingen serverbelønninger)",
        RedeemCodesBtn    = "Indløs alle koder",
        RedeemCodesDesc   = "Søger kodeinputfeltet i UI og sender hver kode. Åbn kodepanelet først.",
        RedeemDone        = "{n} koder forsøgt. Tjek spillet for resultater.",
        RedeemNotFound    = "Kodeinput ikke fundet — åbn kodepanelet i spillet først.",
        FlyToggle         = "Flyv",
        FlySpeed          = "Flyvehastighed",
        NoClipToggle      = "NoClip",
        WalkSpeedLabel    = "Gangfart",
        FullbrightToggle  = "Fuld lysstyrke",
        AntiAFKToggle     = "Anti-AFK",
        LangSelect        = "Sprog",
        LangReload        = "Kør scriptet igen for at anvende sproget.",
        Loaded            = "Hub indlæst! Velkommen til SMTD Hub v1.0.0",
    },
}

local function T(key)
    local lang = Translations[CurrentLang]
    if lang and lang[key] then return lang[key] end
    return (Translations.EN[key] or key)
end

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
-- CODES LIST — known codes to attempt
-- ================================================================
local Codes = {
    "130KLIKES", "125KLIKES", "120KLIKES", "115KLIKES", "110KLIKES",
    "105KLIKES", "100KLIKES", "JULY4", "CONTRACTS", "EASTER2026",
    "GOODBYE2025", "ANGRYTV", "SORRYFORDELAY", "NEWDISCORDSERVER",
    "GRANDUPDATE", "DELAYCODE3", "DELAYCODE2", "80KLIKES",
    "75KLIKES", "70KLIKES", "SUMMER2024",
}

-- ================================================================
-- TASKS CACHE — filled by tasks_update OnClientEvent
-- ================================================================
local TasksCache = nil

if R_TasksUpdate then
    pcall(function()
        R_TasksUpdate.OnClientEvent:Connect(function(data)
            if type(data) == "table" then
                TasksCache = data
            end
        end)
    end)
end

-- ================================================================
-- LIGHTING STATE — captured before any fullbright change
-- ================================================================
local OrigBrightness    = Lighting.Brightness
local OrigClockTime     = Lighting.ClockTime
local OrigGlobalShadows = Lighting.GlobalShadows

-- ================================================================
-- RAYFIELD LOAD (keyless)
-- ================================================================
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)
if not success then
    warn("[SMTD Hub] Rayfield failed to load:", Rayfield)
    return
end

-- ================================================================
-- MAIN WINDOW
-- ================================================================
local Window = Rayfield:CreateWindow({
    Name                = T("WindowTitle"),
    LoadingTitle        = "Skibidi Masters TD Hub",
    LoadingSubtitle     = "Created by Rival960 & Claude",
    ConfigurationSaving = { Enabled = false },
    Discord             = { Enabled = false },
    KeySystem           = false,
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
    Title   = T("VersionTitle"),
    Content = T("VersionContent"),
})

-- ================================================================
-- TAB 2 — AUTO UPGRADE
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

                        -- result == true confirmed from log: InvokeResult = { true, n=1 }
                        local upgraded = ok and (
                            result == true or
                            (type(result) == "table" and result[1] == true)
                        )

                        if upgraded then
                            Rayfield:Notify({
                                Title    = T("TabAutoUpgrade"),
                                Content  = TF("UpgradeOk", { s = slotStr }),
                                Duration = 2,
                            })
                        end

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
-- TAB 3 — TASKS WATCHER
-- ================================================================
local TabTasks = Window:CreateTab(T("TabTasks"), 4483362458)

local function formatTaskList(taskTable, label)
    if type(taskTable) ~= "table" then return label .. ": N/A\n" end
    local lines = { label .. ":" }
    for _, t in ipairs(taskTable) do
        if type(t) == "table" then
            local id      = tostring(t.id or "?")
            local claimed = t.claimed and "✓" or "✗"
            local prog    = t.progress ~= nil and (" [" .. tostring(t.progress) .. "]") or ""
            table.insert(lines, "  #" .. id .. prog .. " " .. claimed)
        end
    end
    return table.concat(lines, "\n")
end

TabTasks:CreateButton({
    Name     = T("ShowTasksBtn"),
    Callback = function()
        if not TasksCache then
            Rayfield:Notify({
                Title    = T("TasksTitle"),
                Content  = T("NoTaskData"),
                Duration = 4,
            })
            return
        end

        local lines  = {}
        local daily  = nil
        local weekly = nil

        pcall(function()
            daily  = TasksCache.tasks and TasksCache.tasks.daily
            weekly = TasksCache.tasks and TasksCache.tasks.weekly
        end)

        table.insert(lines, daily  and formatTaskList(daily,  "Daily")  or "Daily: N/A")
        table.insert(lines, weekly and formatTaskList(weekly, "Weekly") or "Weekly: N/A")

        pcall(function()
            if TasksCache.progress then
                table.insert(lines, "Daily total:  " .. tostring(TasksCache.progress.daily  or "?"))
                table.insert(lines, "Weekly total: " .. tostring(TasksCache.progress.weekly or "?"))
            end
        end)

        Rayfield:Notify({
            Title    = T("TasksTitle"),
            Content  = table.concat(lines, "\n"),
            Duration = 10,
        })
    end,
})

TabTasks:CreateParagraph({ Title = "", Content = T("ShowTasksDesc") })

TabTasks:CreateButton({
    Name     = T("SpoofTasksBtn"),
    Callback = function()
        if not R_TasksUpdate then
            Rayfield:Notify({
                Title    = T("TabTasks"),
                Content  = "tasks_update remote not found.",
                Duration = 3,
            })
            return
        end

        pcall(function()
            local weeklySpoof = {}
            for i = 1, 9 do
                weeklySpoof[i] = { id = i, progress = 999999, claimed = true }
            end

            local dailySpoof = {}
            for i = 1, 15 do
                dailySpoof[i] = { id = i, progress = 999999, claimed = true }
            end

            local spoofPayload = {
                week  = "2026_43",
                day   = "10/28/26",
                tasks = {
                    weekly = weeklySpoof,
                    daily  = dailySpoof,
                },
                claimed = {
                    weekly = { 1, 2, 3, 4, 5, 6, 7, 8, 9 },
                    daily  = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 },
                },
                progress = {
                    weekly = 9999,
                    daily  = 9999,
                },
            }

            TasksCache = spoofPayload
            firesignal(R_TasksUpdate.OnClientEvent, spoofPayload)
        end)

        Rayfield:Notify({
            Title    = T("TabTasks"),
            Content  = T("SpoofDone"),
            Duration = 4,
        })
    end,
})

TabTasks:CreateParagraph({ Title = "", Content = T("SpoofTasksDesc") })

-- ================================================================
-- TAB 4 — CODES
-- ================================================================
local TabCodes = Window:CreateTab(T("TabCodes"), 4483362458)

local function findInGui(root, predicate)
    for _, obj in ipairs(root:GetDescendants()) do
        if predicate(obj) then return obj end
    end
    return nil
end

local function nameContainsAny(name, keywords)
    local lower = name:lower()
    for _, kw in ipairs(keywords) do
        if lower:find(kw, 1, true) then return true end
    end
    return false
end

TabCodes:CreateButton({
    Name     = T("RedeemCodesBtn"),
    Callback = function()
        task.spawn(function()
            local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
            if not playerGui then
                Rayfield:Notify({ Title = T("TabCodes"), Content = T("RedeemNotFound"), Duration = 5 })
                return
            end

            local codeBox   = nil
            local submitBtn = nil

            pcall(function()
                codeBox = findInGui(playerGui, function(obj)
                    return obj:IsA("TextBox") and
                        nameContainsAny(obj.Name, { "code", "input" })
                end)
            end)

            if not codeBox then
                Rayfield:Notify({ Title = T("TabCodes"), Content = T("RedeemNotFound"), Duration = 5 })
                return
            end

            local function findSubmitIn(container)
                return findInGui(container, function(obj)
                    return obj:IsA("TextButton") and
                        nameContainsAny(obj.Name, { "send", "submit", "redeem", "claim" })
                end)
            end

            pcall(function()
                local parent = codeBox.Parent
                if parent then submitBtn = findSubmitIn(parent) end
                if not submitBtn then submitBtn = findSubmitIn(playerGui) end
            end)

            if not submitBtn then
                Rayfield:Notify({ Title = T("TabCodes"), Content = T("RedeemNotFound"), Duration = 5 })
                return
            end

            local attempted = 0
            for _, code in ipairs(Codes) do
                pcall(function()
                    codeBox.Text = code
                    pcall(function() submitBtn.MouseButton1Click:Fire() end)
                    attempted = attempted + 1
                end)
                task.wait(0.5)
            end

            Rayfield:Notify({
                Title    = T("TabCodes"),
                Content  = TF("RedeemDone", { n = attempted }),
                Duration = 5,
            })
        end)
    end,
})

TabCodes:CreateParagraph({ Title = "", Content = T("RedeemCodesDesc") })

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

    FlyBodyGyro           = Instance.new("BodyGyro")
    FlyBodyGyro.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
    FlyBodyGyro.P         = 9000
    FlyBodyGyro.CFrame    = hrp.CFrame
    FlyBodyGyro.Parent    = hrp

    FlyConnection = RunService.RenderStepped:Connect(function()
        if not Settings.Fly then
            FlyConnection:Disconnect()
            return
        end

        local speed = Settings.FlySpeed
        local cf    = Camera.CFrame
        local dir   = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W)         then dir = dir + cf.LookVector  end
        if UserInputService:IsKeyDown(Enum.KeyCode.S)         then dir = dir - cf.LookVector  end
        if UserInputService:IsKeyDown(Enum.KeyCode.A)         then dir = dir - cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D)         then dir = dir + cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then dir = dir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end

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
            if FlyBodyVelocity and FlyBodyVelocity.Parent == hrp then FlyBodyVelocity:Destroy() end
            if FlyBodyGyro     and FlyBodyGyro.Parent     == hrp then FlyBodyGyro:Destroy()     end
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
    Name         = T("FlySpeed"),
    Range        = { 10, 300 },
    Increment    = 5,
    CurrentValue = 60,
    Flag         = "FlySpeed",
    Callback     = function(value) Settings.FlySpeed = value end,
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
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name:lower() ~= "humanoidrootpart" then
                        part.CanCollide = true
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

LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then hum.WalkSpeed = Settings.WalkSpeed end
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
TabTools:CreateToggle({
    Name         = T("AntiAFKToggle"),
    CurrentValue = false,
    Flag         = "AntiAFK",
    Callback     = function(value)
        Settings.AntiAFK = value
        if value and VirtualUser then
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
local LangOptions = {
    "EN","FR","DE","ES","PT","RU","IT","NL","PL","ZH",
    "JA","TR","KO","AR","VI","SV","EL","RO","UK","CS","DA",
}

TabTools:CreateDropdown({
    Name          = T("LangSelect"),
    Options       = LangOptions,
    CurrentOption = { CurrentLang },
    Flag          = "LangSelect",
    Callback      = function(selected)
        local lang = type(selected) == "table" and selected[1] or selected
        if Translations[lang] then CurrentLang = lang end
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
-- Use at your own risk. No server-side values are modified.
-- Spoofed tasks are client-side only. Code redemption depends on
-- server-side validation.
-- ================================================================

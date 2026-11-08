--[[
    ================================================================
    Tactical SWAT Hub — Tactical: Swat Simulator
    Created by Rival960 with the help of Claude
    Version: 1.1.2 | Languages: 21 | Rayfield UI | PC + Mobile
    Status: untested in-game
    ================================================================
--]]

-- ───────────────────────────────────────────────────────────────
-- SERVICES
-- ───────────────────────────────────────────────────────────────
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local Workspace          = game:GetService("Workspace")
local Lighting           = game:GetService("Lighting")
local VirtualUser        = game:GetService("VirtualUser")

local LocalPlayer        = Players.LocalPlayer

-- ───────────────────────────────────────────────────────────────
-- EXECUTOR COMPATIBILITY SHIM
-- ───────────────────────────────────────────────────────────────
if not task then
    task = {
        wait  = function(t) return wait(t) end,
        spawn = function(f, ...) return spawn(f, ...) end,
        defer = function(f, ...) return spawn(f, ...) end,
    }
end

-- ───────────────────────────────────────────────────────────────
-- 21-LANGUAGE SYSTEM
-- ───────────────────────────────────────────────────────────────
local CurrentLang = "EN"

local Translations = {
    EN = {
        WindowTitle      = "Tactical SWAT Hub",
        TabHome          = "Home",
        TabCombat        = "Combat",
        TabWeapons       = "Weapons",
        TabMovement      = "Movement",
        TabAuto          = "Auto",
        TabTools         = "Tools",
        -- Combat
        ESPEnabled       = "ESP (Criminals/Civilians)",
        ESPDesc          = "Criminals = orange+hitbox | Civilians = blue, no hitbox",
        ObjectiveESP     = "Objective ESP",
        ObjectiveESPDesc = "Highlight mission objectives in yellow through walls",
        HitboxToggle     = "Expand Hitboxes (Criminals only)",
        HitboxDesc       = "Enlarge criminal NPC HRPs for easier hits",
        HitboxSize       = "Hitbox Size",
        -- Weapons
        InfiniteAmmo     = "Infinite Ammo",
        InfiniteAmmoDesc = "Keep all ammo values at 999",
        FreezeAmmo       = "Freeze Ammo",
        FreezeAmmoDesc   = "Prevent ammo from decreasing",
        FastReload       = "Fast Reload",
        FastReloadDesc   = "Instantly reload equipped weapon",
        RapidFire        = "Rapid Fire",
        RapidFireDesc    = "Set fire rate to maximum (ACS API required)",
        Wallbang         = "Wallbang + One Shot",
        WallbangDesc     = "Bullets penetrate walls and deal max damage (ACS API required)",
        WallCheck        = "Wall Check",
        WallCheckDesc    = "Raycast check — which suspects are behind cover",
        -- Movement
        Fly              = "Fly",
        FlyDesc          = "Flight mode — WASD+Space/Shift (PC) or MoveDir (Mobile)",
        FlySpeed         = "Fly Speed",
        NoClip           = "NoClip",
        NoClipDesc       = "Pass through walls and obstacles",
        WalkSpeed        = "Walk Speed",
        Jump             = "Enable Jump",
        JumpDesc         = "Force jump re-enabled — game disables it by default",
        JumpPower        = "Jump Power",
        InfJump          = "Infinite Jump",
        InfJumpDesc      = "Continuously jump by holding the jump button/key",
        -- Auto
        AutoArrest       = "Auto Arrest",
        AutoArrestDesc   = "Auto-fire arrest prompts on suspects in range (hands up required)",
        AutoArrestDelay  = "Arrest Delay (s)",
        AutoArrestDist   = "Max Arrest Distance (studs)",
        BringNearest     = "Bring Nearest Suspect",
        BringNearestDesc = "Teleport the closest suspect to you",
        BringAll         = "Bring All Suspects",
        BringAllDesc     = "Teleport all suspects around you",
        OpenDoors        = "Open All Doors",
        OpenDoorsDesc    = "Fire all door/gate/checkpoint prompts",
        -- Tools
        Fullbright       = "Fullbright",
        FullbrightDesc   = "Max brightness, disable shadows",
        AntiAFK          = "Anti-AFK",
        AntiAFKDesc      = "Prevent auto-kick from inactivity",
        LangSelect       = "Language",
        -- Credits
        CreditsTitle     = "Tactical SWAT Hub",
        CreditsContent   = "Created by Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.2 — Weapons tab | Jump re-enable | Infinite Jump | getgc fix",
        Loaded           = "Hub loaded! Tactical advantage enabled.",
    },
    FR = {
        WindowTitle      = "Tactical SWAT Hub",
        TabHome          = "Accueil",
        TabCombat        = "Combat",
        TabWeapons       = "Armes",
        TabMovement      = "Mouvement",
        TabAuto          = "Auto",
        TabTools         = "Outils",
        ESPEnabled       = "ESP Suspects",
        ESPDesc          = "Surligner les suspects + HP à travers les murs",
        HitboxToggle     = "Agrandir les Hitboxes",
        HitboxDesc       = "Agrandir les HRP des suspects",
        HitboxSize       = "Taille Hitbox",
        InfiniteAmmo     = "Munitions infinies",
        InfiniteAmmoDesc = "Maintient les munitions à 999",
        FreezeAmmo       = "Bloquer les munitions",
        FreezeAmmoDesc   = "Empêche les munitions de diminuer",
        FastReload       = "Rechargement rapide",
        FastReloadDesc   = "Recharge instantanément l'arme équipée",
        RapidFire        = "Tir rapide",
        RapidFireDesc    = "Cadence de tir maximale (API ACS requise)",
        Wallbang         = "Wallbang + Un coup",
        WallbangDesc     = "Balles traversent les murs, dégâts max (API ACS requise)",
        WallCheck        = "Vérification des murs",
        WallCheckDesc    = "Rayon de détection — quels suspects sont derrière un couvert",
        Fly              = "Vol",
        FlyDesc          = "Mode vol (WASD + boutons haut/bas)",
        FlySpeed         = "Vitesse de vol",
        FloatUp          = "Monter ▲",
        FloatDown        = "Descendre ▼",
        NoClip           = "NoClip",
        NoClipDesc       = "Passer à travers les murs",
        WalkSpeed        = "Vitesse de marche",
        Jump             = "Sauter (touche E / bouton)",
        JumpDesc         = "Force un saut même si désactivé",
        JumpPower        = "Puissance du saut",
        AutoArrest       = "Auto Arrestation",
        AutoArrestDesc   = "Déclenche automatiquement les prompts d'arrestation",
        AutoArrestDelay  = "Délai (s)",
        BringNearest     = "Amener le suspect le plus proche",
        BringNearestDesc = "Téléporte le suspect le plus proche vers toi",
        BringAll         = "Amener tous les suspects",
        BringAllDesc     = "Téléporte tous les suspects près de toi",
        OpenDoors        = "Ouvrir toutes les portes",
        OpenDoorsDesc    = "Déclenche tous les prompts porte/portail",
        Fullbright       = "Luminosité max",
        FullbrightDesc   = "Luminosité max, pas d'ombres",
        AntiAFK          = "Anti-AFK",
        AntiAFKDesc      = "Empêche le kick pour inactivité",
        LangSelect       = "Langue",
        CreditsTitle     = "Tactical SWAT Hub",
        CreditsContent   = "Créé par Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.2 — Onglet Armes | Saut réactivé | Saut infini | Correctif getgc",
        Loaded           = "Hub chargé ! Avantage tactique activé.",
    },
    DE = {
        WindowTitle      = "Tactical SWAT Hub",
        TabHome          = "Start",
        TabCombat        = "Kampf",
        TabWeapons       = "Waffen",
        TabMovement      = "Bewegung",
        TabAuto          = "Auto",
        TabTools         = "Werkzeuge",
        ESPEnabled       = "ESP Verdächtige",
        ESPDesc          = "Verdächtige hervorheben + HP durch Wände",
        HitboxToggle     = "Hitboxen vergrößern",
        HitboxDesc       = "HRPs der Verdächtigen vergrößern",
        HitboxSize       = "Hitbox-Größe",
        InfiniteAmmo     = "Unbegrenzte Munition",
        InfiniteAmmoDesc = "Munitionswerte auf 999 halten",
        FreezeAmmo       = "Munition einfrieren",
        FreezeAmmoDesc   = "Verhindert, dass Munition abnimmt",
        FastReload       = "Schnellnachladen",
        FastReloadDesc   = "Ausgerüstete Waffe sofort nachladen",
        RapidFire        = "Schnellfeuer",
        RapidFireDesc    = "Feuerrate auf Maximum setzen (ACS API erforderlich)",
        Wallbang         = "Wallbang + Ein Schuss",
        WallbangDesc     = "Kugeln durchdringen Wände, maximaler Schaden (ACS API erforderlich)",
        WallCheck        = "Wandprüfung",
        WallCheckDesc    = "Raycast-Prüfung — welche Verdächtigen hinter Deckung sind",
        Fly              = "Fliegen",
        FlyDesc          = "Flugmodus (WASD + Auf/Ab-Tasten)",
        FlySpeed         = "Fluggeschwindigkeit",
        FloatUp          = "Aufsteigen ▲",
        FloatDown        = "Absteigen ▼",
        NoClip           = "NoClip",
        NoClipDesc       = "Durch Wände und Hindernisse gehen",
        WalkSpeed        = "Laufgeschwindigkeit",
        Jump             = "Springen (E-Taste / Button)",
        JumpDesc         = "Erzwingt einen Sprung auch wenn deaktiviert",
        JumpPower        = "Sprungkraft",
        AutoArrest       = "Auto-Verhaftung",
        AutoArrestDesc   = "Verhaftungs-Prompts automatisch auslösen",
        AutoArrestDelay  = "Verhaftungsverzögerung (s)",
        BringNearest     = "Nächsten Verdächtigen bringen",
        BringNearestDesc = "Nächsten Verdächtigen zu dir teleportieren",
        BringAll         = "Alle Verdächtigen bringen",
        BringAllDesc     = "Alle Verdächtigen zu dir teleportieren",
        OpenDoors        = "Alle Türen öffnen",
        OpenDoorsDesc    = "Alle Tür-/Tor-Prompts auslösen",
        Fullbright       = "Vollhell",
        FullbrightDesc   = "Max. Helligkeit, Schatten deaktiviert",
        AntiAFK          = "Anti-AFK",
        AntiAFKDesc      = "Verhindert den Rauswurf wegen Inaktivität",
        LangSelect       = "Sprache",
        CreditsTitle     = "Tactical SWAT Hub",
        CreditsContent   = "Erstellt von Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.2 — Waffen-Tab | Sprung reaktiviert | Unendl. Sprung | getgc-Fix",
        Loaded           = "Hub geladen! Taktischer Vorteil aktiviert.",
    },
    ES = {
        WindowTitle      = "Tactical SWAT Hub",
        TabHome          = "Inicio",
        TabCombat        = "Combate",
        TabWeapons       = "Armas",
        TabMovement      = "Movimiento",
        TabAuto          = "Auto",
        TabTools         = "Herramientas",
        ESPEnabled       = "ESP Sospechosos",
        ESPDesc          = "Resaltar sospechosos + HP a través de paredes",
        HitboxToggle     = "Ampliar Hitboxes",
        HitboxDesc       = "Ampliar HRPs de sospechosos",
        HitboxSize       = "Tamaño Hitbox",
        InfiniteAmmo     = "Munición infinita",
        InfiniteAmmoDesc = "Mantener munición en 999",
        FreezeAmmo       = "Congelar munición",
        FreezeAmmoDesc   = "Impedir que disminuya la munición",
        FastReload       = "Recarga rápida",
        FastReloadDesc   = "Recargar arma equipada al instante",
        RapidFire        = "Fuego rápido",
        RapidFireDesc    = "Cadencia de fuego máxima (requiere ACS API)",
        Wallbang         = "Wallbang + Un disparo",
        WallbangDesc     = "Las balas atraviesan paredes, daño máximo (requiere ACS API)",
        WallCheck        = "Verificación de paredes",
        WallCheckDesc    = "Comprobación de rayo — qué sospechosos están detrás de cobertura",
        Fly              = "Volar",
        FlyDesc          = "Modo vuelo (WASD + botones arriba/abajo)",
        FlySpeed         = "Velocidad de vuelo",
        FloatUp          = "Subir ▲",
        FloatDown        = "Bajar ▼",
        NoClip           = "NoClip",
        NoClipDesc       = "Atravesar paredes y obstáculos",
        WalkSpeed        = "Velocidad de marcha",
        Jump             = "Saltar (tecla E / botón)",
        JumpDesc         = "Fuerza un salto aunque esté desactivado",
        JumpPower        = "Potencia de salto",
        AutoArrest       = "Auto Arresto",
        AutoArrestDesc   = "Disparar automáticamente prompts de arresto",
        AutoArrestDelay  = "Retraso (s)",
        BringNearest     = "Traer sospechoso más cercano",
        BringNearestDesc = "Teleportar al sospechoso más cercano",
        BringAll         = "Traer todos los sospechosos",
        BringAllDesc     = "Teleportar todos los sospechosos cerca",
        OpenDoors        = "Abrir todas las puertas",
        OpenDoorsDesc    = "Disparar todos los prompts de puertas",
        Fullbright       = "Brillo máximo",
        FullbrightDesc   = "Brillo máximo, sin sombras",
        AntiAFK          = "Anti-AFK",
        AntiAFKDesc      = "Evitar expulsión por inactividad",
        LangSelect       = "Idioma",
        CreditsTitle     = "Tactical SWAT Hub",
        CreditsContent   = "Creado por Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.2 — Pestaña Armas | Salto reactivado | Salto infinito | Fix getgc",
        Loaded           = "¡Hub cargado! Ventaja táctica activada.",
    },
    PT = {
        WindowTitle      = "Tactical SWAT Hub",
        TabHome          = "Início",
        TabCombat        = "Combate",
        TabWeapons       = "Armas",
        TabMovement      = "Movimento",
        TabAuto          = "Auto",
        TabTools         = "Ferramentas",
        ESPEnabled       = "ESP Suspeitos",
        ESPDesc          = "Destacar suspeitos + HP através das paredes",
        HitboxToggle     = "Expandir Hitboxes",
        HitboxDesc       = "Ampliar HRPs dos suspeitos",
        HitboxSize       = "Tamanho Hitbox",
        InfiniteAmmo     = "Munição infinita",
        InfiniteAmmoDesc = "Manter munição em 999",
        FreezeAmmo       = "Congelar munição",
        FreezeAmmoDesc   = "Impedir diminuição de munição",
        FastReload       = "Recarga rápida",
        FastReloadDesc   = "Recarregar arma equipada instantaneamente",
        RapidFire        = "Fogo rápido",
        RapidFireDesc    = "Taxa de fogo máxima (requer ACS API)",
        Wallbang         = "Wallbang + Um tiro",
        WallbangDesc     = "Balas atravessam paredes, dano máximo (requer ACS API)",
        WallCheck        = "Verificação de parede",
        WallCheckDesc    = "Verificação de raio — quais suspeitos estão atrás de cobertura",
        Fly              = "Voar",
        FlyDesc          = "Modo voo (WASD + botões cima/baixo)",
        FlySpeed         = "Velocidade de voo",
        FloatUp          = "Subir ▲",
        FloatDown        = "Descer ▼",
        NoClip           = "NoClip",
        NoClipDesc       = "Atravessar paredes e obstáculos",
        WalkSpeed        = "Velocidade de caminhada",
        Jump             = "Pular (tecla E / botão)",
        JumpDesc         = "Força um salto mesmo quando desativado",
        JumpPower        = "Força do salto",
        AutoArrest       = "Auto Prisão",
        AutoArrestDesc   = "Disparar automaticamente prompts de prisão",
        AutoArrestDelay  = "Atraso (s)",
        BringNearest     = "Trazer suspeito mais próximo",
        BringNearestDesc = "Teleportar o suspeito mais próximo",
        BringAll         = "Trazer todos os suspeitos",
        BringAllDesc     = "Teleportar todos os suspeitos",
        OpenDoors        = "Abrir todas as portas",
        OpenDoorsDesc    = "Disparar todos os prompts de portas",
        Fullbright       = "Brilho máximo",
        FullbrightDesc   = "Brilho máximo, sem sombras",
        AntiAFK          = "Anti-AFK",
        AntiAFKDesc      = "Evitar expulsão por inatividade",
        LangSelect       = "Idioma",
        CreditsTitle     = "Tactical SWAT Hub",
        CreditsContent   = "Criado por Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.2 — Aba Armas | Salto reativado | Salto infinito | Correção getgc",
        Loaded           = "Hub carregado! Vantagem tática ativada.",
    },
    RU = {
        WindowTitle      = "Tactical SWAT Hub",
        TabHome          = "Главная",
        TabCombat        = "Бой",
        TabWeapons       = "Оружие",
        TabMovement      = "Движение",
        TabAuto          = "Авто",
        TabTools         = "Инструменты",
        ESPEnabled       = "ESP подозреваемых",
        ESPDesc          = "Подсветка подозреваемых + HP сквозь стены",
        HitboxToggle     = "Расширить хитбоксы",
        HitboxDesc       = "Увеличить HRP подозреваемых",
        HitboxSize       = "Размер хитбокса",
        InfiniteAmmo     = "Бесконечные патроны",
        InfiniteAmmoDesc = "Держать патроны на уровне 999",
        FreezeAmmo       = "Заморозить патроны",
        FreezeAmmoDesc   = "Предотвратить расход патронов",
        FastReload       = "Быстрая перезарядка",
        FastReloadDesc   = "Мгновенная перезарядка оружия",
        RapidFire        = "Быстрый огонь",
        RapidFireDesc    = "Максимальная скорострельность (требуется ACS API)",
        Wallbang         = "Пробитие стен + Один выстрел",
        WallbangDesc     = "Пули пробивают стены, максимальный урон (требуется ACS API)",
        WallCheck        = "Проверка стен",
        WallCheckDesc    = "Трассировка луча — кто из подозреваемых за укрытием",
        Fly              = "Полёт",
        FlyDesc          = "Режим полёта (WASD + кнопки вверх/вниз)",
        FlySpeed         = "Скорость полёта",
        FloatUp          = "Вверх ▲",
        FloatDown        = "Вниз ▼",
        NoClip           = "Ноклип",
        NoClipDesc       = "Проходить сквозь стены",
        WalkSpeed        = "Скорость ходьбы",
        Jump             = "Прыжок (E / кнопка)",
        JumpDesc         = "Принудительный прыжок даже если отключён",
        JumpPower        = "Сила прыжка",
        AutoArrest       = "Авто-арест",
        AutoArrestDesc   = "Автоматически активирует промпты ареста",
        AutoArrestDelay  = "Задержка (с)",
        BringNearest     = "Притянуть ближайшего",
        BringNearestDesc = "Телепортировать ближайшего подозреваемого к себе",
        BringAll         = "Притянуть всех",
        BringAllDesc     = "Телепортировать всех подозреваемых к себе",
        OpenDoors        = "Открыть все двери",
        OpenDoorsDesc    = "Активировать все промпты дверей",
        Fullbright       = "Макс. яркость",
        FullbrightDesc   = "Макс. яркость, без теней",
        AntiAFK          = "Анти-AFK",
        AntiAFKDesc      = "Предотвратить кик за бездействие",
        LangSelect       = "Язык",
        CreditsTitle     = "Tactical SWAT Hub",
        CreditsContent   = "Создано Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.2 — Вкладка Оружие | Прыжок восстановлен | Бесконечный прыжок | Исправление getgc",
        Loaded           = "Hub загружен! Тактическое преимущество активировано.",
    },
    IT = {
        WindowTitle      = "Tactical SWAT Hub",
        TabHome          = "Home",
        TabCombat        = "Combattimento",
        TabWeapons       = "Armi",
        TabMovement      = "Movimento",
        TabAuto          = "Auto",
        TabTools         = "Strumenti",
        ESPEnabled       = "ESP Sospettati",
        ESPDesc          = "Evidenziare sospettati + HP attraverso i muri",
        HitboxToggle     = "Espandi Hitbox",
        HitboxDesc       = "Ingrandire i HRP dei sospettati",
        HitboxSize       = "Dimensione Hitbox",
        InfiniteAmmo     = "Munizioni infinite",
        InfiniteAmmoDesc = "Mantenere le munizioni a 999",
        FreezeAmmo       = "Congela munizioni",
        FreezeAmmoDesc   = "Impedisce la diminuzione delle munizioni",
        FastReload       = "Ricarica veloce",
        FastReloadDesc   = "Ricaricare immediatamente l'arma equipaggiata",
        RapidFire        = "Fuoco rapido",
        RapidFireDesc    = "Cadenza di fuoco massima (richiede ACS API)",
        Wallbang         = "Wallbang + Un colpo",
        WallbangDesc     = "I proiettili attraversano i muri, danno massimo (richiede ACS API)",
        WallCheck        = "Controllo muri",
        WallCheckDesc    = "Controllo raycast — quali sospetti sono dietro copertura",
        Fly              = "Volare",
        FlyDesc          = "Modalità volo (WASD + pulsanti su/giù)",
        FlySpeed         = "Velocità di volo",
        FloatUp          = "Su ▲",
        FloatDown        = "Giù ▼",
        NoClip           = "NoClip",
        NoClipDesc       = "Attraversare muri e ostacoli",
        WalkSpeed        = "Velocità di camminata",
        Jump             = "Salta (tasto E / pulsante)",
        JumpDesc         = "Forza un salto anche se disabilitato",
        JumpPower        = "Potenza salto",
        AutoArrest       = "Auto Arresto",
        AutoArrestDesc   = "Attiva automaticamente i prompt di arresto",
        AutoArrestDelay  = "Ritardo (s)",
        BringNearest     = "Porta il sospettato più vicino",
        BringNearestDesc = "Teleporta il sospettato più vicino da te",
        BringAll         = "Porta tutti i sospettati",
        BringAllDesc     = "Teleporta tutti i sospettati vicino a te",
        OpenDoors        = "Apri tutte le porte",
        OpenDoorsDesc    = "Attiva tutti i prompt porte/cancelli",
        Fullbright       = "Luminosità massima",
        FullbrightDesc   = "Luminosità max, ombre disattivate",
        AntiAFK          = "Anti-AFK",
        AntiAFKDesc      = "Previeni il kick per inattività",
        LangSelect       = "Lingua",
        CreditsTitle     = "Tactical SWAT Hub",
        CreditsContent   = "Creato da Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.2 — Scheda Armi | Salto riattivato | Salto infinito | Fix getgc",
        Loaded           = "Hub caricato! Vantaggio tattico attivato.",
    },
    NL = {
        WindowTitle      = "Tactical SWAT Hub",
        TabHome          = "Start",
        TabCombat        = "Gevecht",
        TabWeapons       = "Wapens",
        TabMovement      = "Beweging",
        TabAuto          = "Auto",
        TabTools         = "Hulpmiddelen",
        ESPEnabled       = "ESP Verdachten",
        ESPDesc          = "Verdachten markeren + HP door muren",
        HitboxToggle     = "Hitboxen vergroten",
        HitboxDesc       = "HRP's van verdachten vergroten",
        HitboxSize       = "Hitbox grootte",
        InfiniteAmmo     = "Oneindige munitie",
        InfiniteAmmoDesc = "Munitiewaarden op 999 houden",
        FreezeAmmo       = "Munitie bevriezen",
        FreezeAmmoDesc   = "Voorkom dat munitie afneemt",
        FastReload       = "Snel herladen",
        FastReloadDesc   = "Uitgerust wapen direct herladen",
        RapidFire        = "Snel vuren",
        RapidFireDesc    = "Vuursnelheid op maximum instellen (ACS API vereist)",
        Wallbang         = "Wallbang + Één schot",
        WallbangDesc     = "Kogels doorboren muren, maximale schade (ACS API vereist)",
        WallCheck        = "Muurcontrole",
        WallCheckDesc    = "Raycast-controle — welke verdachten achter dekking zitten",
        Fly              = "Vliegen",
        FlyDesc          = "Vliegmodus (WASD + omhoog/omlaag knoppen)",
        FlySpeed         = "Vliegsnelheid",
        FloatUp          = "Omhoog ▲",
        FloatDown        = "Omlaag ▼",
        NoClip           = "NoClip",
        NoClipDesc       = "Door muren en obstakels lopen",
        WalkSpeed        = "Loopsnelheid",
        Jump             = "Springen (E-toets / knop)",
        JumpDesc         = "Dwingt een sprong af ook als uitgeschakeld",
        JumpPower        = "Springkracht",
        AutoArrest       = "Auto-Arrestatie",
        AutoArrestDesc   = "Arrestatieprompts automatisch activeren",
        AutoArrestDelay  = "Vertraging (s)",
        BringNearest     = "Dichtstbijzijnde verdachte brengen",
        BringNearestDesc = "Dichtstbijzijnde verdachte naar jou teleporteren",
        BringAll         = "Alle verdachten brengen",
        BringAllDesc     = "Alle verdachten naar jou teleporteren",
        OpenDoors        = "Alle deuren openen",
        OpenDoorsDesc    = "Alle deur/poort-prompts activeren",
        Fullbright       = "Maximale helderheid",
        FullbrightDesc   = "Max. helderheid, schaduwen uitgeschakeld",
        AntiAFK          = "Anti-AFK",
        AntiAFKDesc      = "Kick door inactiviteit voorkomen",
        LangSelect       = "Taal",
        CreditsTitle     = "Tactical SWAT Hub",
        CreditsContent   = "Gemaakt door Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.2 — Wapens tab | Sprong heractiveerd | Oneindig springen | getgc-fix",
        Loaded           = "Hub geladen! Tactisch voordeel geactiveerd.",
    },
    PL = {
        WindowTitle      = "Tactical SWAT Hub",
        TabHome          = "Główna",
        TabCombat        = "Walka",
        TabWeapons       = "Broń",
        TabMovement      = "Ruch",
        TabAuto          = "Auto",
        TabTools         = "Narzędzia",
        ESPEnabled       = "ESP Podejrzani",
        ESPDesc          = "Podświetl podejrzanych + HP przez ściany",
        HitboxToggle     = "Rozszerz Hitboxy",
        HitboxDesc       = "Powiększ HRP podejrzanych",
        HitboxSize       = "Rozmiar Hitboxa",
        InfiniteAmmo     = "Nieskończona amunicja",
        InfiniteAmmoDesc = "Utrzymuj amunicję na poziomie 999",
        FreezeAmmo       = "Zamroz amunicję",
        FreezeAmmoDesc   = "Zapobiegaj zmniejszaniu się amunicji",
        FastReload       = "Szybkie przeładowanie",
        FastReloadDesc   = "Natychmiastowe przeładowanie wyposażonej broni",
        RapidFire        = "Szybki ogień",
        RapidFireDesc    = "Maksymalna szybkostrzelność (wymaga ACS API)",
        Wallbang         = "Wallbang + Jeden strzał",
        WallbangDesc     = "Kule przenikają przez ściany, maksymalne obrażenia (wymaga ACS API)",
        WallCheck        = "Sprawdzenie ściany",
        WallCheckDesc    = "Sprawdzenie raycasta — którzy podejrzani są za osłoną",
        Fly              = "Latanie",
        FlyDesc          = "Tryb lotu (WASD + przyciski góra/dół)",
        FlySpeed         = "Prędkość lotu",
        FloatUp          = "W górę ▲",
        FloatDown        = "W dół ▼",
        NoClip           = "NoClip",
        NoClipDesc       = "Przechodzenie przez ściany",
        WalkSpeed        = "Prędkość chodzenia",
        Jump             = "Skok (klawisz E / przycisk)",
        JumpDesc         = "Wymusza skok nawet gdy wyłączony",
        JumpPower        = "Siła skoku",
        AutoArrest       = "Auto-Areszowanie",
        AutoArrestDesc   = "Automatycznie wyzwala prompty aresztu",
        AutoArrestDelay  = "Opóźnienie (s)",
        BringNearest     = "Przyprowadź najbliższego podejrzanego",
        BringNearestDesc = "Teleportuje najbliższego podejrzanego do ciebie",
        BringAll         = "Przyprowadź wszystkich podejrzanych",
        BringAllDesc     = "Teleportuje wszystkich podejrzanych do ciebie",
        OpenDoors        = "Otwórz wszystkie drzwi",
        OpenDoorsDesc    = "Aktywuj wszystkie prompty drzwi/bram",
        Fullbright       = "Pełna jasność",
        FullbrightDesc   = "Maks. jasność, cienie wyłączone",
        AntiAFK          = "Anti-AFK",
        AntiAFKDesc      = "Zapobiegaj wyrzuceniu za bezczynność",
        LangSelect       = "Język",
        CreditsTitle     = "Tactical SWAT Hub",
        CreditsContent   = "Stworzone przez Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.2 — Zakładka Bronie | Skok przywrócony | Nieskończone skoki | Poprawka getgc",
        Loaded           = "Hub załadowany! Taktyczna przewaga aktywowana.",
    },
    ZH = {
        WindowTitle      = "战术特警Hub",
        TabHome          = "主页",
        TabCombat        = "战斗",
        TabWeapons       = "武器",
        TabMovement      = "移动",
        TabAuto          = "自动",
        TabTools         = "工具",
        ESPEnabled       = "ESP嫌疑人",
        ESPDesc          = "高亮嫌疑人 + 透视HP",
        HitboxToggle     = "扩大判定框",
        HitboxDesc       = "扩大嫌疑人的HRP",
        HitboxSize       = "判定框大小",
        InfiniteAmmo     = "无限弹药",
        InfiniteAmmoDesc = "保持弹药值为999",
        FreezeAmmo       = "冻结弹药",
        FreezeAmmoDesc   = "防止弹药减少",
        FastReload       = "快速装弹",
        FastReloadDesc   = "立即重新装弹",
        RapidFire        = "快速射击",
        RapidFireDesc    = "将射速设为最大（需要 ACS API）",
        Wallbang         = "穿墙+一击必杀",
        WallbangDesc     = "子弹穿透墙壁，造成最大伤害（需要 ACS API）",
        WallCheck        = "穿墙检测",
        WallCheckDesc    = "射线检测 — 哪些嫌疑人在掩体后面",
        Fly              = "飞行",
        FlyDesc          = "飞行模式（WASD + 上下按钮）",
        FlySpeed         = "飞行速度",
        FloatUp          = "上升 ▲",
        FloatDown        = "下降 ▼",
        NoClip           = "穿墙",
        NoClipDesc       = "穿过墙壁和障碍物",
        WalkSpeed        = "移动速度",
        Jump             = "跳跃（E键 / 按钮）",
        JumpDesc         = "即使禁用也能强制跳跃",
        JumpPower        = "跳跃力度",
        AutoArrest       = "自动逮捕",
        AutoArrestDesc   = "自动触发逮捕提示",
        AutoArrestDelay  = "延迟（秒）",
        BringNearest     = "传送最近嫌疑人",
        BringNearestDesc = "将最近的嫌疑人传送到你身边",
        BringAll         = "传送所有嫌疑人",
        BringAllDesc     = "将所有嫌疑人传送到你身边",
        OpenDoors        = "开启所有门",
        OpenDoorsDesc    = "触发所有门/闸提示",
        Fullbright       = "全亮",
        FullbrightDesc   = "最大亮度，关闭阴影",
        AntiAFK          = "防挂机",
        AntiAFKDesc      = "防止因挂机被踢出",
        LangSelect       = "语言",
        CreditsTitle     = "战术特警Hub",
        CreditsContent   = "由 Rival960 创建\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.2 — 武器选项卡 | 跳跃重新启用 | 无限跳跃 | getgc 修复",
        Loaded           = "Hub已加载！战术优势已激活。",
    },
    JA = {
        WindowTitle      = "タクティカルSWATHub",
        TabHome          = "ホーム",
        TabCombat        = "戦闘",
        TabWeapons       = "武器",
        TabMovement      = "移動",
        TabAuto          = "オート",
        TabTools         = "ツール",
        ESPEnabled       = "ESP容疑者",
        ESPDesc          = "容疑者を強調+壁越しHP表示",
        HitboxToggle     = "ヒットボックス拡張",
        HitboxDesc       = "容疑者のHRPを拡大",
        HitboxSize       = "ヒットボックスサイズ",
        InfiniteAmmo     = "無限弾薬",
        InfiniteAmmoDesc = "弾薬を999に維持",
        FreezeAmmo       = "弾薬固定",
        FreezeAmmoDesc   = "弾薬の減少を防ぐ",
        FastReload       = "高速リロード",
        FastReloadDesc   = "装備中の武器を即座にリロード",
        RapidFire        = "ラピッドファイア",
        RapidFireDesc    = "発射レートを最大に設定（ACS API が必要）",
        Wallbang         = "ウォールバン＋ワンショット",
        WallbangDesc     = "弾丸が壁を貫通し、最大ダメージを与える（ACS API が必要）",
        WallCheck        = "壁チェック",
        WallCheckDesc    = "レイキャスト確認 — 掩体に隠れている容疑者を表示",
        Fly              = "飛行",
        FlyDesc          = "飛行モード（WASD + 上下ボタン）",
        FlySpeed         = "飛行速度",
        FloatUp          = "上昇 ▲",
        FloatDown        = "下降 ▼",
        NoClip           = "ノークリップ",
        NoClipDesc       = "壁や障害物を通り抜ける",
        WalkSpeed        = "移動速度",
        Jump             = "ジャンプ（Eキー / ボタン）",
        JumpDesc         = "無効時でも強制ジャンプ",
        JumpPower        = "ジャンプ力",
        AutoArrest       = "自動逮捕",
        AutoArrestDesc   = "逮捕プロンプトを自動実行",
        AutoArrestDelay  = "遅延（秒）",
        BringNearest     = "最近の容疑者を召喚",
        BringNearestDesc = "最近の容疑者をTPで手元に召喚",
        BringAll         = "全容疑者を召喚",
        BringAllDesc     = "全容疑者をTPで手元に召喚",
        OpenDoors        = "全ドアを開ける",
        OpenDoorsDesc    = "全ドア/ゲートプロンプトを実行",
        Fullbright       = "フルブライト",
        FullbrightDesc   = "最大輝度、影を無効化",
        AntiAFK          = "アンチAFK",
        AntiAFKDesc      = "放置キックを防止",
        LangSelect       = "言語",
        CreditsTitle     = "タクティカルSWATHub",
        CreditsContent   = "Rival960 作\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.2 — 武器タブ | ジャンプ再有効化 | 無限ジャンプ | getgc 修正",
        Loaded           = "Hub読み込み完了！タクティカル優位性が有効化されました。",
    },
    TR = {
        WindowTitle      = "Tactical SWAT Hub",
        TabHome          = "Ana Sayfa",
        TabCombat        = "Savaş",
        TabWeapons       = "Silahlar",
        TabMovement      = "Hareket",
        TabAuto          = "Otomatik",
        TabTools         = "Araçlar",
        ESPEnabled       = "ESP Şüpheliler",
        ESPDesc          = "Şüphelileri vurgula + duvar arkasında HP göster",
        HitboxToggle     = "Hitbox Genişlet",
        HitboxDesc       = "Şüphelilerin HRP'lerini büyüt",
        HitboxSize       = "Hitbox Boyutu",
        InfiniteAmmo     = "Sonsuz Mermi",
        InfiniteAmmoDesc = "Mermi değerlerini 999'da tut",
        FreezeAmmo       = "Mermiyi Dondur",
        FreezeAmmoDesc   = "Merminin azalmasını engelle",
        FastReload       = "Hızlı Şarj",
        FastReloadDesc   = "Donanımlı silahı anında şarj et",
        RapidFire        = "Hızlı Ateş",
        RapidFireDesc    = "Atış hızını maksimuma ayarla (ACS API gerekli)",
        Wallbang         = "Duvar Delme + Tek Atış",
        WallbangDesc     = "Mermiler duvarları deler, maksimum hasar (ACS API gerekli)",
        WallCheck        = "Duvar Kontrolü",
        WallCheckDesc    = "Işın kontrolü — hangi şüpheliler siperde",
        Fly              = "Uçuş",
        FlyDesc          = "Uçuş modu (WASD + yukarı/aşağı butonları)",
        FlySpeed         = "Uçuş Hızı",
        FloatUp          = "Yukarı ▲",
        FloatDown        = "Aşağı ▼",
        NoClip           = "NoClip",
        NoClipDesc       = "Duvarlardan ve engellerden geç",
        WalkSpeed        = "Yürüyüş Hızı",
        Jump             = "Zıpla (E tuşu / buton)",
        JumpDesc         = "Devre dışı olsa bile zıplamayı zorla",
        JumpPower        = "Zıplama Gücü",
        AutoArrest       = "Otomatik Tutuklama",
        AutoArrestDesc   = "Tutuklama promptlarını otomatik tetikle",
        AutoArrestDelay  = "Gecikme (s)",
        BringNearest     = "En Yakın Şüpheliyi Getir",
        BringNearestDesc = "En yakın şüpheliyi yanına teleportle",
        BringAll         = "Tüm Şüphelileri Getir",
        BringAllDesc     = "Tüm şüphelileri yanına teleportle",
        OpenDoors        = "Tüm Kapıları Aç",
        OpenDoorsDesc    = "Tüm kapı/geçit promptlarını tetikle",
        Fullbright       = "Tam Parlaklık",
        FullbrightDesc   = "Maks. parlaklık, gölgeler devre dışı",
        AntiAFK          = "Anti-AFK",
        AntiAFKDesc      = "Hareketsizlik kickini önle",
        LangSelect       = "Dil",
        CreditsTitle     = "Tactical SWAT Hub",
        CreditsContent   = "Rival960 tarafından\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.2 — Silah sekmesi | Zıplama yeniden etkin | Sonsuz zıplama | getgc düzeltmesi",
        Loaded           = "Hub yüklendi! Taktik avantaj aktif.",
    },
    KO = {
        WindowTitle      = "택티컬 스왓 허브",
        TabHome          = "홈",
        TabCombat        = "전투",
        TabWeapons       = "무기",
        TabMovement      = "이동",
        TabAuto          = "자동",
        TabTools         = "도구",
        ESPEnabled       = "ESP 용의자",
        ESPDesc          = "용의자 강조 + 벽 너머 HP 표시",
        HitboxToggle     = "히트박스 확장",
        HitboxDesc       = "용의자 HRP 크기 확대",
        HitboxSize       = "히트박스 크기",
        InfiniteAmmo     = "무한 탄약",
        InfiniteAmmoDesc = "탄약 값을 999로 유지",
        FreezeAmmo       = "탄약 고정",
        FreezeAmmoDesc   = "탄약 감소 방지",
        FastReload       = "빠른 장전",
        FastReloadDesc   = "장착 무기 즉시 장전",
        RapidFire        = "빠른 사격",
        RapidFireDesc    = "발사 속도를 최대로 설정 (ACS API 필요)",
        Wallbang         = "월뱅 + 원샷",
        WallbangDesc     = "총알이 벽을 관통하고 최대 피해 (ACS API 필요)",
        WallCheck        = "벽 확인",
        WallCheckDesc    = "레이캐스트 확인 — 어떤 용의자가 엄폐물 뒤에 있는지",
        Fly              = "비행",
        FlyDesc          = "비행 모드 (WASD + 위/아래 버튼)",
        FlySpeed         = "비행 속도",
        FloatUp          = "위로 ▲",
        FloatDown        = "아래로 ▼",
        NoClip           = "노클립",
        NoClipDesc       = "벽과 장애물을 통과",
        WalkSpeed        = "이동 속도",
        Jump             = "점프 (E키 / 버튼)",
        JumpDesc         = "비활성화 상태에서도 점프 강제",
        JumpPower        = "점프 파워",
        AutoArrest       = "자동 체포",
        AutoArrestDesc   = "체포 프롬프트 자동 실행",
        AutoArrestDelay  = "지연 (초)",
        BringNearest     = "가장 가까운 용의자 소환",
        BringNearestDesc = "가장 가까운 용의자를 TP로 소환",
        BringAll         = "모든 용의자 소환",
        BringAllDesc     = "모든 용의자를 TP로 소환",
        OpenDoors        = "모든 문 열기",
        OpenDoorsDesc    = "모든 문/게이트 프롬프트 실행",
        Fullbright       = "풀브라이트",
        FullbrightDesc   = "최대 밝기, 그림자 비활성화",
        AntiAFK          = "안티 AFK",
        AntiAFKDesc      = "비활동으로 인한 킥 방지",
        LangSelect       = "언어",
        CreditsTitle     = "택티컬 스왓 허브",
        CreditsContent   = "Rival960 제작\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.2 — 무기 탭 | 점프 재활성화 | 무한 점프 | getgc 수정",
        Loaded           = "허브 로드 완료! 전술적 이점 활성화.",
    },
    AR = {
        WindowTitle      = "تاكتيكال سوات هاب",
        TabHome          = "الرئيسية",
        TabCombat        = "القتال",
        TabWeapons       = "الأسلحة",
        TabMovement      = "الحركة",
        TabAuto          = "أوتوماتيك",
        TabTools         = "الأدوات",
        ESPEnabled       = "ESP المشتبه بهم",
        ESPDesc          = "تمييز المشتبه بهم + HP عبر الجدران",
        HitboxToggle     = "توسيع Hitbox",
        HitboxDesc       = "تكبير HRP المشتبه بهم",
        HitboxSize       = "حجم Hitbox",
        InfiniteAmmo     = "ذخيرة لا نهائية",
        InfiniteAmmoDesc = "الإبقاء على الذخيرة عند 999",
        FreezeAmmo       = "تجميد الذخيرة",
        FreezeAmmoDesc   = "منع نقص الذخيرة",
        FastReload       = "إعادة تحميل سريعة",
        FastReloadDesc   = "إعادة تحميل السلاح المجهز فوراً",
        RapidFire        = "إطلاق نار سريع",
        RapidFireDesc    = "ضبط معدل إطلاق النار على الحد الأقصى (يتطلب ACS API)",
        Wallbang         = "اختراق الجدران + طلقة واحدة",
        WallbangDesc     = "الرصاصات تخترق الجدران وتسبب أقصى ضرر (يتطلب ACS API)",
        WallCheck        = "فحص الجدران",
        WallCheckDesc    = "فحص الأشعة — أي المشتبه بهم خلف الغطاء",
        Fly              = "الطيران",
        FlyDesc          = "وضع الطيران (WASD + أزرار أعلى/أسفل)",
        FlySpeed         = "سرعة الطيران",
        FloatUp          = "أعلى ▲",
        FloatDown        = "أسفل ▼",
        NoClip           = "نوكليب",
        NoClipDesc       = "المرور عبر الجدران والعوائق",
        WalkSpeed        = "سرعة المشي",
        Jump             = "القفز (مفتاح E / زر)",
        JumpDesc         = "القفز القسري حتى عند التعطيل",
        JumpPower        = "قوة القفز",
        AutoArrest       = "اعتقال تلقائي",
        AutoArrestDesc   = "تشغيل موجهات الاعتقال تلقائياً",
        AutoArrestDelay  = "التأخير (ث)",
        BringNearest     = "إحضار أقرب مشتبه به",
        BringNearestDesc = "نقل أقرب مشتبه به إليك",
        BringAll         = "إحضار جميع المشتبه بهم",
        BringAllDesc     = "نقل جميع المشتبه بهم إليك",
        OpenDoors        = "فتح جميع الأبواب",
        OpenDoorsDesc    = "تشغيل جميع موجهات الأبواب",
        Fullbright       = "إضاءة كاملة",
        FullbrightDesc   = "سطوع قصوى، تعطيل الظلال",
        AntiAFK          = "مانع AFK",
        AntiAFKDesc      = "منع الطرد بسبب عدم النشاط",
        LangSelect       = "اللغة",
        CreditsTitle     = "تاكتيكال سوات هاب",
        CreditsContent   = "أنشأه Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.2 — تبويب الأسلحة | إعادة تفعيل القفز | قفز لا نهائي | إصلاح getgc",
        Loaded           = "تم تحميل الهاب! تم تفعيل الميزة التكتيكية.",
    },
    VI = {
        WindowTitle      = "Tactical SWAT Hub",
        TabHome          = "Trang chủ",
        TabCombat        = "Chiến đấu",
        TabWeapons       = "Vũ khí",
        TabMovement      = "Di chuyển",
        TabAuto          = "Tự động",
        TabTools         = "Công cụ",
        ESPEnabled       = "ESP Nghi phạm",
        ESPDesc          = "Làm nổi bật nghi phạm + HP qua tường",
        HitboxToggle     = "Mở rộng Hitbox",
        HitboxDesc       = "Phóng to HRP nghi phạm",
        HitboxSize       = "Kích thước Hitbox",
        InfiniteAmmo     = "Đạn vô hạn",
        InfiniteAmmoDesc = "Giữ tất cả giá trị đạn ở mức 999",
        FreezeAmmo       = "Đóng băng đạn",
        FreezeAmmoDesc   = "Ngăn đạn giảm",
        FastReload       = "Nạp đạn nhanh",
        FastReloadDesc   = "Nạp đạn ngay lập tức",
        RapidFire        = "Bắn nhanh",
        RapidFireDesc    = "Đặt tốc độ bắn tối đa (yêu cầu ACS API)",
        Wallbang         = "Xuyên tường + Một phát",
        WallbangDesc     = "Đạn xuyên tường, sát thương tối đa (yêu cầu ACS API)",
        WallCheck        = "Kiểm tra tường",
        WallCheckDesc    = "Kiểm tra raycast — nghi phạm nào đang ẩn sau chướng ngại vật",
        Fly              = "Bay",
        FlyDesc          = "Chế độ bay (WASD + nút lên/xuống)",
        FlySpeed         = "Tốc độ bay",
        FloatUp          = "Bay lên ▲",
        FloatDown        = "Hạ xuống ▼",
        NoClip           = "NoClip",
        NoClipDesc       = "Đi xuyên tường và chướng ngại vật",
        WalkSpeed        = "Tốc độ đi bộ",
        Jump             = "Nhảy (phím E / nút)",
        JumpDesc         = "Bắt buộc nhảy ngay cả khi bị vô hiệu",
        JumpPower        = "Lực nhảy",
        AutoArrest       = "Tự động bắt giữ",
        AutoArrestDesc   = "Tự động kích hoạt prompt bắt giữ",
        AutoArrestDelay  = "Độ trễ (s)",
        BringNearest     = "Đưa nghi phạm gần nhất đến",
        BringNearestDesc = "Dịch chuyển nghi phạm gần nhất đến bạn",
        BringAll         = "Đưa tất cả nghi phạm đến",
        BringAllDesc     = "Dịch chuyển tất cả nghi phạm đến bạn",
        OpenDoors        = "Mở tất cả cửa",
        OpenDoorsDesc    = "Kích hoạt tất cả prompt cửa/cổng",
        Fullbright       = "Sáng tối đa",
        FullbrightDesc   = "Độ sáng tối đa, tắt bóng",
        AntiAFK          = "Chống AFK",
        AntiAFKDesc      = "Ngăn bị đuổi vì không hoạt động",
        LangSelect       = "Ngôn ngữ",
        CreditsTitle     = "Tactical SWAT Hub",
        CreditsContent   = "Tạo bởi Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.2 — Tab Vũ khí | Bật lại nhảy | Nhảy vô hạn | Sửa lỗi getgc",
        Loaded           = "Hub đã tải! Lợi thế chiến thuật được kích hoạt.",
    },
    SV = {
        WindowTitle      = "Tactical SWAT Hub",
        TabHome          = "Hem",
        TabCombat        = "Strid",
        TabWeapons       = "Vapen",
        TabMovement      = "Rörelse",
        TabAuto          = "Auto",
        TabTools         = "Verktyg",
        ESPEnabled       = "ESP Misstänkta",
        ESPDesc          = "Markera misstänkta + HP genom väggar",
        HitboxToggle     = "Utöka Hitboxes",
        HitboxDesc       = "Förstora HRP hos misstänkta",
        HitboxSize       = "Hitbox-storlek",
        InfiniteAmmo     = "Oändlig ammunition",
        InfiniteAmmoDesc = "Håll ammunition på 999",
        FreezeAmmo       = "Frys ammunition",
        FreezeAmmoDesc   = "Förhindra att ammunition minskar",
        FastReload       = "Snabb omladdning",
        FastReloadDesc   = "Omedelbar omladdning av utrustat vapen",
        RapidFire        = "Snabbskjutning",
        RapidFireDesc    = "Ställ in eldhastighet på max (ACS API krävs)",
        Wallbang         = "Wallbang + Enkelt skott",
        WallbangDesc     = "Kulor penetrerar väggar, maximal skada (ACS API krävs)",
        WallCheck        = "Väggkontroll",
        WallCheckDesc    = "Raycast-kontroll — vilka misstänkta befinner sig bakom skydd",
        Fly              = "Flyg",
        FlyDesc          = "Flygläge (WASD + upp/ner-knappar)",
        FlySpeed         = "Flyghastighet",
        FloatUp          = "Uppåt ▲",
        FloatDown        = "Nedåt ▼",
        NoClip           = "NoClip",
        NoClipDesc       = "Gå igenom väggar och hinder",
        WalkSpeed        = "Gånghastighet",
        Jump             = "Hoppa (E-tangent / knapp)",
        JumpDesc         = "Tvinga hopp även om inaktiverat",
        JumpPower        = "Hoppkraft",
        AutoArrest       = "Auto-Gripning",
        AutoArrestDesc   = "Aktivera gripningspromptar automatiskt",
        AutoArrestDelay  = "Fördröjning (s)",
        BringNearest     = "Hämta närmaste misstänkte",
        BringNearestDesc = "Teleportera närmaste misstänkte till dig",
        BringAll         = "Hämta alla misstänkta",
        BringAllDesc     = "Teleportera alla misstänkta till dig",
        OpenDoors        = "Öppna alla dörrar",
        OpenDoorsDesc    = "Aktivera alla dörr-/portpromptar",
        Fullbright       = "Fullbright",
        FullbrightDesc   = "Max ljusstyrka, skuggor inaktiverade",
        AntiAFK          = "Anti-AFK",
        AntiAFKDesc      = "Förhindra kick på grund av inaktivitet",
        LangSelect       = "Språk",
        CreditsTitle     = "Tactical SWAT Hub",
        CreditsContent   = "Skapad av Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.2 — Vapenfliken | Hopp återaktiverat | Oändliga hop | getgc-fix",
        Loaded           = "Hub laddad! Taktisk fördel aktiverad.",
    },
    EL = {
        WindowTitle      = "Tactical SWAT Hub",
        TabHome          = "Αρχική",
        TabCombat        = "Μάχη",
        TabWeapons       = "Όπλα",
        TabMovement      = "Κίνηση",
        TabAuto          = "Αυτόματο",
        TabTools         = "Εργαλεία",
        ESPEnabled       = "ESP Ύποπτοι",
        ESPDesc          = "Επισήμανση υπόπτων + HP μέσα από τοίχους",
        HitboxToggle     = "Επέκταση Hitbox",
        HitboxDesc       = "Μεγέθυνση HRP υπόπτων",
        HitboxSize       = "Μέγεθος Hitbox",
        InfiniteAmmo     = "Άπειρα πυρομαχικά",
        InfiniteAmmoDesc = "Διατήρηση πυρομαχικών στο 999",
        FreezeAmmo       = "Πάγωμα πυρομαχικών",
        FreezeAmmoDesc   = "Αποτροπή μείωσης πυρομαχικών",
        FastReload       = "Γρήγορη επαναφόρτιση",
        FastReloadDesc   = "Άμεση επαναφόρτιση εξοπλισμένου όπλου",
        RapidFire        = "Γρήγορη βολή",
        RapidFireDesc    = "Ρύθμιση ρυθμού πυροδότησης στο μέγιστο (απαιτείται ACS API)",
        Wallbang         = "Διάτρηση τοίχου + Ένα πλήγμα",
        WallbangDesc     = "Οι σφαίρες διαπερνούν τοίχους, μέγιστη ζημιά (απαιτείται ACS API)",
        WallCheck        = "Έλεγχος τοίχου",
        WallCheckDesc    = "Έλεγχος ακτίνας — ποιοι ύποπτοι κρύβονται πίσω από κάλυψη",
        Fly              = "Πτήση",
        FlyDesc          = "Λειτουργία πτήσης (WASD + πάνω/κάτω)",
        FlySpeed         = "Ταχύτητα πτήσης",
        FloatUp          = "Πάνω ▲",
        FloatDown        = "Κάτω ▼",
        NoClip           = "NoClip",
        NoClipDesc       = "Περνάς μέσα από τοίχους και εμπόδια",
        WalkSpeed        = "Ταχύτητα βαδίσματος",
        Jump             = "Άλμα (πλήκτρο E / κουμπί)",
        JumpDesc         = "Εξαναγκασμός άλματος ακόμα κι αν απενεργοποιηθεί",
        JumpPower        = "Δύναμη άλματος",
        AutoArrest       = "Αυτόματη σύλληψη",
        AutoArrestDesc   = "Αυτόματη ενεργοποίηση προτροπών σύλληψης",
        AutoArrestDelay  = "Καθυστέρηση (δευτ.)",
        BringNearest     = "Φέρε τον κοντινότερο ύποπτο",
        BringNearestDesc = "Τηλεμεταφορά κοντινότερου υπόπτου κοντά σου",
        BringAll         = "Φέρε όλους τους ύποπτους",
        BringAllDesc     = "Τηλεμεταφορά όλων των υπόπτων κοντά σου",
        OpenDoors        = "Άνοιγμα όλων των θυρών",
        OpenDoorsDesc    = "Ενεργοποίηση προτροπών θυρών/πυλών",
        Fullbright       = "Πλήρης φωτεινότητα",
        FullbrightDesc   = "Μέγ. φωτεινότητα, σκιές απενεργοποιημένες",
        AntiAFK          = "Anti-AFK",
        AntiAFKDesc      = "Αποτροπή αποβολής λόγω αδράνειας",
        LangSelect       = "Γλώσσα",
        CreditsTitle     = "Tactical SWAT Hub",
        CreditsContent   = "Δημιουργήθηκε από τον Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.2 — Καρτέλα Όπλα | Επανεκκίνηση άλματος | Άπειρο άλμα | Διόρθωση getgc",
        Loaded           = "Hub φορτώθηκε! Τακτικό πλεονέκτημα ενεργοποιήθηκε.",
    },
    RO = {
        WindowTitle      = "Tactical SWAT Hub",
        TabHome          = "Acasă",
        TabCombat        = "Luptă",
        TabWeapons       = "Arme",
        TabMovement      = "Mișcare",
        TabAuto          = "Auto",
        TabTools         = "Instrumente",
        ESPEnabled       = "ESP Suspecți",
        ESPDesc          = "Evidențierea suspecților + HP prin pereți",
        HitboxToggle     = "Extinde Hitbox",
        HitboxDesc       = "Mărind HRP-urile suspecților",
        HitboxSize       = "Dimensiune Hitbox",
        InfiniteAmmo     = "Muniție infinită",
        InfiniteAmmoDesc = "Menținerea muniției la 999",
        FreezeAmmo       = "Îngheață muniția",
        FreezeAmmoDesc   = "Previne scăderea muniției",
        FastReload       = "Reîncărcare rapidă",
        FastReloadDesc   = "Reîncarcă imediat arma echipată",
        RapidFire        = "Foc rapid",
        RapidFireDesc    = "Setează rata de foc la maximum (necesită ACS API)",
        Wallbang         = "Wallbang + Un foc",
        WallbangDesc     = "Gloanțele penetrează pereții, daune maxime (necesită ACS API)",
        WallCheck        = "Verificare pereți",
        WallCheckDesc    = "Verificare raycast — ce suspecți se află în spatele acoperirii",
        Fly              = "Zbor",
        FlyDesc          = "Mod de zbor (WASD + butoane sus/jos)",
        FlySpeed         = "Viteza de zbor",
        FloatUp          = "Sus ▲",
        FloatDown        = "Jos ▼",
        NoClip           = "NoClip",
        NoClipDesc       = "Treci prin pereți și obstacole",
        WalkSpeed        = "Viteză de mers",
        Jump             = "Salt (tasta E / buton)",
        JumpDesc         = "Forțează un salt chiar și când e dezactivat",
        JumpPower        = "Puterea saltului",
        AutoArrest       = "Arest Automat",
        AutoArrestDesc   = "Activare automată a prompturilor de arest",
        AutoArrestDelay  = "Întârziere (s)",
        BringNearest     = "Aduce suspectul cel mai apropiat",
        BringNearestDesc = "Teleportează suspectul cel mai apropiat la tine",
        BringAll         = "Aduce toți suspecții",
        BringAllDesc     = "Teleportează toți suspecții la tine",
        OpenDoors        = "Deschide toate ușile",
        OpenDoorsDesc    = "Activează toate prompturile de uși/porți",
        Fullbright       = "Luminozitate maximă",
        FullbrightDesc   = "Luminozitate max, umbre dezactivate",
        AntiAFK          = "Anti-AFK",
        AntiAFKDesc      = "Previne kickul din cauza inactivității",
        LangSelect       = "Limbă",
        CreditsTitle     = "Tactical SWAT Hub",
        CreditsContent   = "Creat de Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.2 — Tab Arme | Săritură reactivată | Săritură infinită | Remediere getgc",
        Loaded           = "Hub încărcat! Avantaj tactic activat.",
    },
    UK = {
        WindowTitle      = "Tactical SWAT Hub",
        TabHome          = "Головна",
        TabCombat        = "Бій",
        TabWeapons       = "Зброя",
        TabMovement      = "Рух",
        TabAuto          = "Авто",
        TabTools         = "Інструменти",
        ESPEnabled       = "ESP підозрюваних",
        ESPDesc          = "Підсвічення підозрюваних + HP крізь стіни",
        HitboxToggle     = "Розширити хітбокси",
        HitboxDesc       = "Збільшити HRP підозрюваних",
        HitboxSize       = "Розмір хітбоксу",
        InfiniteAmmo     = "Безкінечні патрони",
        InfiniteAmmoDesc = "Тримати патрони на рівні 999",
        FreezeAmmo       = "Заморозити патрони",
        FreezeAmmoDesc   = "Запобігти витраті патронів",
        FastReload       = "Швидке перезаряджання",
        FastReloadDesc   = "Миттєве перезаряджання зброї",
        RapidFire        = "Швидкий вогонь",
        RapidFireDesc    = "Максимальна швидкість стрільби (потрібен ACS API)",
        Wallbang         = "Пробиття стін + Один постріл",
        WallbangDesc     = "Кулі пробивають стіни, максимальний урон (потрібен ACS API)",
        WallCheck        = "Перевірка стін",
        WallCheckDesc    = "Трасування промення — які підозрювані за укриттям",
        Fly              = "Політ",
        FlyDesc          = "Режим польоту (WASD + кнопки вгору/вниз)",
        FlySpeed         = "Швидкість польоту",
        FloatUp          = "Вгору ▲",
        FloatDown        = "Вниз ▼",
        NoClip           = "Нокліп",
        NoClipDesc       = "Проходити крізь стіни й перешкоди",
        WalkSpeed        = "Швидкість ходьби",
        Jump             = "Стрибок (клавіша E / кнопка)",
        JumpDesc         = "Примусовий стрибок навіть якщо вимкнений",
        JumpPower        = "Сила стрибка",
        AutoArrest       = "Авто-арешт",
        AutoArrestDesc   = "Автоматично активує підказки арешту",
        AutoArrestDelay  = "Затримка (с)",
        BringNearest     = "Притягнути найближчого",
        BringNearestDesc = "Телепортувати найближчого підозрюваного до себе",
        BringAll         = "Притягнути всіх",
        BringAllDesc     = "Телепортувати всіх підозрюваних до себе",
        OpenDoors        = "Відкрити всі двері",
        OpenDoorsDesc    = "Активувати всі підказки дверей/воріт",
        Fullbright       = "Повна яскравість",
        FullbrightDesc   = "Максимальна яскравість, тіні вимкнено",
        AntiAFK          = "Анти-AFK",
        AntiAFKDesc      = "Запобігти кіку за бездіяльність",
        LangSelect       = "Мова",
        CreditsTitle     = "Tactical SWAT Hub",
        CreditsContent   = "Створено Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.2 — Вкладка Зброя | Стрибок відновлено | Нескінченний стрибок | Виправлення getgc",
        Loaded           = "Hub завантажено! Тактичну перевагу активовано.",
    },
    CS = {
        WindowTitle      = "Tactical SWAT Hub",
        TabHome          = "Domů",
        TabCombat        = "Boj",
        TabWeapons       = "Zbraně",
        TabMovement      = "Pohyb",
        TabAuto          = "Auto",
        TabTools         = "Nástroje",
        ESPEnabled       = "ESP Podezřelí",
        ESPDesc          = "Zvýraznit podezřelé + HP skrz zdi",
        HitboxToggle     = "Rozšířit Hitboxy",
        HitboxDesc       = "Zvětšit HRP podezřelých",
        HitboxSize       = "Velikost Hitboxu",
        InfiniteAmmo     = "Nekonečná munice",
        InfiniteAmmoDesc = "Udržovat munici na 999",
        FreezeAmmo       = "Zmrazit munici",
        FreezeAmmoDesc   = "Zabránit snižování munice",
        FastReload       = "Rychlé přebíjení",
        FastReloadDesc   = "Okamžité přebití vybavené zbraně",
        RapidFire        = "Rychlá střelba",
        RapidFireDesc    = "Nastavit kadenci na maximum (vyžaduje ACS API)",
        Wallbang         = "Průstřel zdí + Jeden výstřel",
        WallbangDesc     = "Náboje prostřelují zdi, maximální poškození (vyžaduje ACS API)",
        WallCheck        = "Kontrola zdí",
        WallCheckDesc    = "Raycast kontrola — kteří podezřelí jsou za krytem",
        Fly              = "Létání",
        FlyDesc          = "Letový režim (WASD + tlačítka nahoru/dolů)",
        FlySpeed         = "Rychlost letu",
        FloatUp          = "Nahoru ▲",
        FloatDown        = "Dolů ▼",
        NoClip           = "NoClip",
        NoClipDesc       = "Procházet zdmi a překážkami",
        WalkSpeed        = "Rychlost chůze",
        Jump             = "Skok (klávesa E / tlačítko)",
        JumpDesc         = "Vynutit skok i když je deaktivován",
        JumpPower        = "Síla skoku",
        AutoArrest       = "Auto-Zatčení",
        AutoArrestDesc   = "Automaticky spouštět výzvy k zatčení",
        AutoArrestDelay  = "Prodleva (s)",
        BringNearest     = "Přivést nejbližšího podezřelého",
        BringNearestDesc = "Teleportovat nejbližšího podezřelého k tobě",
        BringAll         = "Přivést všechny podezřelé",
        BringAllDesc     = "Teleportovat všechny podezřelé k tobě",
        OpenDoors        = "Otevřít všechna dveře",
        OpenDoorsDesc    = "Aktivovat všechny výzvy dveří/bran",
        Fullbright       = "Plné světlo",
        FullbrightDesc   = "Max. jas, stíny deaktivovány",
        AntiAFK          = "Anti-AFK",
        AntiAFKDesc      = "Zabránit kicku za nečinnost",
        LangSelect       = "Jazyk",
        CreditsTitle     = "Tactical SWAT Hub",
        CreditsContent   = "Vytvořil Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.2 — Záložka Zbraně | Skok obnoven | Nekonečný skok | Oprava getgc",
        Loaded           = "Hub načten! Taktická výhoda aktivována.",
    },
    DA = {
        WindowTitle      = "Tactical SWAT Hub",
        TabHome          = "Hjem",
        TabCombat        = "Kamp",
        TabWeapons       = "Våben",
        TabMovement      = "Bevægelse",
        TabAuto          = "Auto",
        TabTools         = "Værktøjer",
        ESPEnabled       = "ESP Mistænkte",
        ESPDesc          = "Fremhæv mistænkte + HP gennem vægge",
        HitboxToggle     = "Udvid Hitboxes",
        HitboxDesc       = "Forstør HRP hos mistænkte",
        HitboxSize       = "Hitbox-størrelse",
        InfiniteAmmo     = "Uendelig ammunition",
        InfiniteAmmoDesc = "Hold ammunition på 999",
        FreezeAmmo       = "Frys ammunition",
        FreezeAmmoDesc   = "Forhindre at ammunition falder",
        FastReload       = "Hurtig genopfyldning",
        FastReloadDesc   = "Øjeblikkelig genopfyldning af udrustet våben",
        RapidFire        = "Hurtig skydning",
        RapidFireDesc    = "Sæt skudfrekvens til maksimum (kræver ACS API)",
        Wallbang         = "Wallbang + Et skud",
        WallbangDesc     = "Kugler gennemtrænger vægge, maksimal skade (kræver ACS API)",
        WallCheck        = "Vægkontrol",
        WallCheckDesc    = "Raycast-kontrol — hvilke mistænkte er bag dækning",
        Fly              = "Fly",
        FlyDesc          = "Flytilstand (WASD + op/ned-knapper)",
        FlySpeed         = "Flyhastighed",
        FloatUp          = "Op ▲",
        FloatDown        = "Ned ▼",
        NoClip           = "NoClip",
        NoClipDesc       = "Gå igennem vægge og forhindringer",
        WalkSpeed        = "Gånghastighed",
        Jump             = "Hop (E-tast / knap)",
        JumpDesc         = "Tving et hop selvom deaktiveret",
        JumpPower        = "Hoppekraft",
        AutoArrest       = "Auto-Anholdelse",
        AutoArrestDesc   = "Aktiver anholdelses-prompts automatisk",
        AutoArrestDelay  = "Forsinkelse (s)",
        BringNearest     = "Hent nærmeste mistænkte",
        BringNearestDesc = "Teleportér nærmeste mistænkte til dig",
        BringAll         = "Hent alle mistænkte",
        BringAllDesc     = "Teleportér alle mistænkte til dig",
        OpenDoors        = "Åbn alle døre",
        OpenDoorsDesc    = "Aktiver alle dør-/portprompts",
        Fullbright       = "Fuld lysstyrke",
        FullbrightDesc   = "Maks. lysstyrke, skygger deaktiveret",
        AntiAFK          = "Anti-AFK",
        AntiAFKDesc      = "Forhindre kick pga. inaktivitet",
        LangSelect       = "Sprog",
        CreditsTitle     = "Tactical SWAT Hub",
        CreditsContent   = "Oprettet af Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.2 — Våben-fanen | Hop genaktiveret | Uendelige hop | getgc-rettelse",
        Loaded           = "Hub indlæst! Taktisk fordel aktiveret.",
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
    -- Combat
    ESP             = false,
    ObjectiveESP    = false,
    Hitbox          = false,
    HitboxSize      = 4,
    -- Weapons
    InfiniteAmmo    = false,
    FreezeAmmo      = false,
    RapidFire       = false,
    Wallbang        = false,
    _origShootRate  = nil,
    _origPenetration= nil,
    _origIgnoreProt = nil,
    _origTorsoDmg   = nil,
    _origLimbDmg    = nil,
    _frozenAmmo     = nil,
    _frozenAmmoInGun= nil,
    -- Movement
    Fly             = false,
    JumpEnabled     = false,
    JumpPower       = 50,
    InfJump         = false,
    FlySpeed        = 60,
    NoClip          = false,
    WalkSpeed       = 16,
    -- Auto / Tools
    AutoArrest      = false,
    AutoArrestDelay = 0.5,
    AutoArrestDist  = 10,   -- studs; 0 = unlimited
    AntiAFK         = false,
    Fullbright      = false,
}

-- ───────────────────────────────────────────────────────────────
-- LOAD RAYFIELD (keyless)
-- ───────────────────────────────────────────────────────────────
local Rayfield
local ok, err = pcall(function()
    Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)
if not ok or not Rayfield then
    warn("[Hub] Rayfield failed to load: " .. tostring(err))
    return
end

local Window = Rayfield:CreateWindow({
    Name            = T("WindowTitle"),
    LoadingTitle    = "Tactical SWAT Hub",
    LoadingSubtitle = "By Rival960 & Claude",
    ConfigurationSaving = { Enabled = false },
    Discord         = { Enabled = false },
    KeySystem       = false,
})

-- ───────────────────────────────────────────────────────────────
-- ACS UPVALUE INFRASTRUCTURE
-- Triple-method discovery: getgc() → getscriptclosures → getconnections
-- getgc() is primary (Volt/Delta/Real/Fluxus); most reliable.
-- Falls back gracefully when debug API is unavailable.
-- ───────────────────────────────────────────────────────────────
local _acsCache    = {func=nil, idx=nil, tbl=nil}
local _nonLethalUV = nil

-- Scan upvalues of f (and one level of function upvalues) for ACS config.
local function _matchACS(f)
    if type(f) ~= "function" then return false end
    -- Direct upvalue scan
    for i = 1, 35 do
        local ok, uv = pcall(debug.getupvalue, f, i)
        if ok and type(uv) == "table"
            and rawget(uv, "ShootRate") ~= nil
            and rawget(uv, "BulletPenetration") ~= nil then
            _acsCache = {func=f, idx=i, tbl=uv}
            local ok9, uv9 = pcall(debug.getupvalue, f, 9)
            if ok9 and type(uv9) == "table" then _nonLethalUV = uv9 end
            return true
        end
    end
    -- One level of recursion: scan function-type upvalues
    for i = 1, 35 do
        local ok, uv = pcall(debug.getupvalue, f, i)
        if ok and type(uv) == "function" then
            local ok2, _ = pcall(debug.getupvalue, uv, 1)
            if ok2 then
                for j = 1, 35 do
                    local ok3, uv3 = pcall(debug.getupvalue, uv, j)
                    if ok3 and type(uv3) == "table"
                        and rawget(uv3, "ShootRate") ~= nil
                        and rawget(uv3, "BulletPenetration") ~= nil then
                        _acsCache = {func=uv, idx=j, tbl=uv3}
                        local ok9, uv9 = pcall(debug.getupvalue, uv, 9)
                        if ok9 and type(uv9) == "table" then _nonLethalUV = uv9 end
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function getACSConfig()
    if _acsCache.tbl then return _acsCache.func, _acsCache.idx, _acsCache.tbl end
    if not (debug and debug.getupvalue) then return nil end

    -- METHOD A: getgc() — scan all live Lua closures (Volt/Delta/Real/Fluxus)
    if getgc then
        local ok, objs = pcall(getgc, true)
        if ok and objs then
            for _, obj in ipairs(objs) do
                if type(obj) == "function" then
                    if _matchACS(obj) then
                        return _acsCache.func, _acsCache.idx, _acsCache.tbl
                    end
                end
            end
        end
    end

    -- METHOD B: getscriptclosures (Synapse X / some Delta)
    local char = LocalPlayer.Character
    if char and getscriptclosures then
        local acs = char:FindFirstChild("ACS_Client")
        local fw  = acs and acs:FindFirstChild("ACS_Framework")
        if fw then
            local ok, cls = pcall(getscriptclosures, fw)
            if ok and cls then
                for _, f in ipairs(cls) do
                    if _matchACS(f) then
                        return _acsCache.func, _acsCache.idx, _acsCache.tbl
                    end
                end
            end
        end
    end

    -- METHOD C: getconnections on known events (fallback)
    if getconnections then
        local char2 = LocalPlayer.Character
        local tool  = char2 and char2:FindFirstChildOfClass("Tool")
        local evs   = {}
        if tool then evs[#evs+1] = tool.Activated end
        local ok2, mouse = pcall(function() return LocalPlayer:GetMouse() end)
        if ok2 and mouse then evs[#evs+1] = mouse.Button1Down end
        evs[#evs+1] = UserInputService.InputBegan
        for _, ev in ipairs(evs) do
            local ok3, conns = pcall(getconnections, ev)
            if ok3 and conns then
                for _, conn in ipairs(conns) do
                    local f; pcall(function() f = conn.Function end)
                    if _matchACS(f) then
                        return _acsCache.func, _acsCache.idx, _acsCache.tbl
                    end
                end
            end
        end
    end

    return nil
end

local function setACSValue(key, value)
    local f, i, cfg = getACSConfig()
    if not f then return false end
    return pcall(function()
        cfg[key] = value
        if debug and debug.setupvalue then debug.setupvalue(f, i, cfg) end
    end)
end

-- Non-lethal check: returns true if the equipped tool should not receive
-- damage/fire-rate overrides (Candy Zapper, Taser, Beanbag Shotgun).
-- Uses _nonLethalUV (upvalue [9]) cached alongside the config.
local function isNonLethal()
    local char = LocalPlayer.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    if not tool then return false end
    local name = tool.Name
    local NL = {["Candy Zapper"]=true, ["Taser"]=true, ["Beanbag Shotgun"]=true}
    if NL[name] then return true end
    if _nonLethalUV and _nonLethalUV[name] then return true end
    return false
end

local function getCurrentToolName()
    local char = LocalPlayer.Character; if not char then return nil end
    local tool = char:FindFirstChildOfClass("Tool")
    return tool and tool.Name or nil
end

-- ───────────────────────────────────────────────────────────────
-- HELPERS
-- ───────────────────────────────────────────────────────────────
local function getChar()  return LocalPlayer.Character end
local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

-- Is this model a live NPC (not a player)?
local function isNPC(model)
    if not model:IsA("Model") then return false end
    local h = model:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then return false end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character == model then return false end
    end
    return true
end

-- NPC classification: armed = suspect/criminal, unarmed = civilian/hostage.
-- Priority order:
--   1. Tool child present in model → suspect (armed criminal, works on all maps)
--   2. Name keyword match          → suspect (fallback for edge cases)
--   3. Everything else             → civilian/hostage (unarmed, to be arrested/secured)
-- This correctly handles:
--   • Standard map: guards/criminals carry weapons (Tool)
--   • Broken Bars:  prisoners carrying weapons = suspects; unarmed prisoners = hostages

-- Keywords (case-insensitive) that identify a suspect by model name (fallback)
local SUSPECT_NAME_KW = {"suspect", "criminal", "prisoner", "inmate"}

-- Returns true if model is a live suspect (NPC + armed OR name keyword match)
local function isSuspect(model)
    if not isNPC(model) then return false end
    -- Armed check: any Tool in the model = this NPC is a criminal
    if model:FindFirstChildOfClass("Tool") then return true end
    -- Name keyword fallback
    local ok2, n = pcall(function() return model.Name:lower() end)
    if ok2 and n then
        for _, kw in ipairs(SUSPECT_NAME_KW) do
            local fm = pcall(function() return n:find(kw, 1, true) end)
            if fm and n:find(kw, 1, true) then return true end
        end
    end
    return false
end

-- Returns true if model is a live civilian/hostage (unarmed NPC, not a suspect)
local function isCivilian(model)
    if not isNPC(model) then return false end
    return not isSuspect(model)
end

-- isCriminal is an alias for isSuspect (used by hitbox/ESP internals)
local function isCriminal(model) return isSuspect(model) end

-- Get all live suspect NPCs — direct children of workspace (confirmed by game log)
local function getAllSuspects()
    local list = {}
    for _, obj in ipairs(Workspace:GetChildren()) do
        if isSuspect(obj) then list[#list+1] = obj end
    end
    return list
end

-- Get nearest suspect HRP + model
local function getNearestSuspect()
    local hrp = getHRP()
    if not hrp then return nil, nil end
    local best, bhrp, bd = nil, nil, math.huge
    for _, obj in ipairs(getAllSuspects()) do
        local sh = obj:FindFirstChild("HumanoidRootPart")
              or obj:FindFirstChildOfClass("BasePart")
        if sh then
            local d = (sh.Position - hrp.Position).Magnitude
            if d < bd then best, bhrp, bd = obj, sh, d end
        end
    end
    return best, bhrp
end

-- ── ENEMY PLAYER DETECTION (team-based) ──────────────────────────
-- Returns true if `model` is a Character belonging to a player on
-- the opposite team from LocalPlayer.
-- Returns true if 'model' belongs to an enemy player (different team).
-- Uses Team object first; falls back to TeamColor when teams are nil/unassigned.
local function isEnemyPlayer(model)
    if not model then return false end
    local neutral = BrickColor.new("Medium stone grey")
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character == model then
            local myTeam    = LocalPlayer.Team
            local theirTeam = p.Team
            if myTeam and theirTeam then
                return theirTeam ~= myTeam
            end
            -- Fallback: compare TeamColor (ignores neutral/unassigned)
            local myColor    = LocalPlayer.TeamColor
            local theirColor = p.TeamColor
            if myColor and theirColor
                and myColor ~= neutral and theirColor ~= neutral then
                return theirColor ~= myColor
            end
            return false
        end
    end
    return false
end

-- Returns all live enemy player Characters (same TeamColor logic)
local function getAllEnemyPlayers()
    local list    = {}
    local neutral = BrickColor.new("Medium stone grey")
    local myTeam  = LocalPlayer.Team
    local myColor = LocalPlayer.TeamColor
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local isEnemy = false
            if myTeam and p.Team then
                isEnemy = p.Team ~= myTeam
            elseif myColor and p.TeamColor
                and myColor ~= neutral and p.TeamColor ~= neutral then
                isEnemy = p.TeamColor ~= myColor
            end
            if isEnemy then
                local char = p.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        list[#list+1] = char
                    end
                end
            end
        end
    end
    return list
end

-- WorldToViewportPoint wrapper (returns screenPos, onScreen)
local function worldToScreen(pos)
    local cam = Workspace.CurrentCamera
    local sp, vis = cam:WorldToViewportPoint(pos)
    return Vector2.new(sp.X, sp.Y), vis and sp.Z > 0
end

-- ───────────────────────────────────────────────────────────────
-- FLY — Infinite Yield style (BodyVelocity + BodyGyro)
--        WASD + Space/Shift on PC | MoveDirection on Mobile
--        On-screen ▲▼ buttons (mobile) set FLY_BTN_UP / FLY_BTN_DOWN
-- ───────────────────────────────────────────────────────────────
local FLYING       = false
local FLY_BTN_UP   = 0  -- set to  1 while on-screen ▲ button is held
local FLY_BTN_DOWN = 0  -- set to -1 while on-screen ▼ button is held
local flyKeyDown, flyKeyUp

-- ── INFINITE JUMP ─────────────────────────────────────────────────────────
local _infJumpConn
local function setupInfJump(char)
    if _infJumpConn then _infJumpConn:Disconnect() end
    _infJumpConn = nil
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    _infJumpConn = hum.StateChanged:Connect(function(_, new)
        if Settings.InfJump
            and new == Enum.HumanoidStateType.Freefall then
            task.wait(0.08)
            if Settings.InfJump then
                local h = getHum()
                if h then
                    h.JumpPower = Settings.JumpPower
                    h:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end
    end)
end

-- Forward references to on-screen overlay buttons (created after Rayfield loads)
local _flyUpBtn, _flyDownBtn

local function enableFly()
    local char = getChar()
    local hrp  = getHRP()
    local hum  = getHum()
    if not char or not hrp or not hum then return end

    -- Disconnect any previous listeners
    if flyKeyDown then flyKeyDown:Disconnect() end
    if flyKeyUp   then flyKeyUp:Disconnect()   end

    FLYING = true

    local CTRL = {F=0, B=0, L=0, R=0, UP=0, DOWN=0}

    local bv, bg
    local physOk = pcall(function()
        bv = Instance.new("BodyVelocity")
        bv.Name      = "_SWAT_FLY_BV"
        bv.MaxForce  = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity  = Vector3.zero
        bv.Parent    = hrp

        bg = Instance.new("BodyGyro")
        bg.Name      = "_SWAT_FLY_BG"
        bg.P         = 9e4
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.CFrame    = hrp.CFrame
        bg.Parent    = hrp
    end)
    if not physOk or not bv or not bg then
        warn("[Hub] Fly: BodyVelocity/BodyGyro unavailable on this executor.")
        FLYING = false
        Settings.Fly = false
        return
    end

    hum.PlatformStand = true

    flyKeyDown = UserInputService.InputBegan:Connect(function(inp, proc)
        if proc then return end
        local k = inp.KeyCode
        local s = 1
        if k == Enum.KeyCode.W     then CTRL.F    =  s
        elseif k == Enum.KeyCode.S then CTRL.B    = -s
        elseif k == Enum.KeyCode.A then CTRL.L    = -s
        elseif k == Enum.KeyCode.D then CTRL.R    =  s
        elseif k == Enum.KeyCode.Space      then CTRL.UP   =  s
        elseif k == Enum.KeyCode.LeftShift
            or k == Enum.KeyCode.RightShift then CTRL.DOWN = -s
        end
    end)

    flyKeyUp = UserInputService.InputEnded:Connect(function(inp, proc)
        if proc then return end
        local k = inp.KeyCode
        if k == Enum.KeyCode.W     then CTRL.F    = 0
        elseif k == Enum.KeyCode.S then CTRL.B    = 0
        elseif k == Enum.KeyCode.A then CTRL.L    = 0
        elseif k == Enum.KeyCode.D then CTRL.R    = 0
        elseif k == Enum.KeyCode.Space      then CTRL.UP   = 0
        elseif k == Enum.KeyCode.LeftShift
            or k == Enum.KeyCode.RightShift then CTRL.DOWN = 0
        end
    end)

    -- Show on-screen fly buttons
    if _flyUpBtn   then _flyUpBtn.Visible   = true end
    if _flyDownBtn then _flyDownBtn.Visible = true end

    task.spawn(function()
        while FLYING do
            task.wait(0.016)
            local cam   = Workspace.CurrentCamera
            local spd   = Settings.FlySpeed
            -- Mobile: MoveDirection gives horizontal intent
            local md    = hum.MoveDirection
            local hasMobile = md.Magnitude > 0.1

            local vel
            if hasMobile then
                -- Project mobile MoveDirection onto camera-flat plane
                local fwd   = Vector3.new(cam.CFrame.LookVector.X,  0, cam.CFrame.LookVector.Z)
                local right = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z)
                if fwd.Magnitude  > 0 then fwd   = fwd.Unit   end
                if right.Magnitude > 0 then right = right.Unit end
                vel = (fwd * (-md.Z) + right * md.X) * spd
                    + Vector3.new(0, (CTRL.UP + CTRL.DOWN + FLY_BTN_UP + FLY_BTN_DOWN) * spd, 0)
            else
                -- PC WASD
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
        local b = hrp:FindFirstChild("_SWAT_FLY_BV")
        if b then b:Destroy() end
        local g = hrp:FindFirstChild("_SWAT_FLY_BG")
        if g then g:Destroy() end
    end
    local h = getHum()
    if h then h.PlatformStand = false end
    -- Hide on-screen fly buttons
    if _flyUpBtn   then _flyUpBtn.Visible   = false end
    if _flyDownBtn then _flyDownBtn.Visible = false end
end


-- ───────────────────────────────────────────────────────────────
-- SURRENDER DETECTION — checks if a criminal NPC has hands up
-- (BoolValues, StringValues, and playing animation track names)
-- ───────────────────────────────────────────────────────────────
local SURRENDER_TAGS = {
    "handsup","surrendered","surrender","issurrendered",
    "canarrest","arrestready","raised","hands","cuffed",
    "detained","freeze","complying","yielding"
}

local function isSurrendered(model)
    for _, v in ipairs(model:GetDescendants()) do
        if v:IsA("BoolValue") then
            local ok2, vn = pcall(function() return v.Name:lower() end)
            if ok2 and vn then
                for _, tag in ipairs(SURRENDER_TAGS) do
                    local fm = pcall(function() return vn:find(tag) end)
                    if fm and vn:find(tag) and v.Value == true then return true end
                end
            end
        elseif v:IsA("StringValue") then
            local ok2, vn = pcall(function() return v.Name:lower() end)
            local ok3, vv = pcall(function() return v.Value:lower() end)
            if ok2 and ok3 and vn and vv then
                for _, tag in ipairs(SURRENDER_TAGS) do
                    local fnOk, fnRes = pcall(function() return vn:find(tag) end)
                    if fnOk and fnRes then
                        if vv == "true" or vv == "yes" or vv == "1"
                        or vv == "surrendered" or vv == "up" then
                            return true
                        end
                    end
                    local fvOk, fvRes = pcall(function() return vv:find(tag) end)
                    if fvOk and fvRes then return true end
                end
            end
        end
    end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if hum then
        local anim = hum:FindFirstChildOfClass("Animator")
        if anim then
            for _, track in ipairs(anim:GetPlayingAnimationTracks()) do
                local ok2, tn = pcall(function() return track.Name:lower() end)
                if ok2 and tn then
                    for _, tag in ipairs(SURRENDER_TAGS) do
                        local fm = pcall(function() return tn:find(tag) end)
                        if fm and tn:find(tag) then return true end
                    end
                end
            end
        end
    end
    return false
end

-- ───────────────────────────────────────────────────────────────
-- OVERLAY UI — on-screen buttons (NOT inside Rayfield)
--   Fly  ▲  — visible only when flying (top)
--   Fly  ▼  — visible only when flying (below)
-- ───────────────────────────────────────────────────────────────
local function createOverlayUI()
    -- Clean up any previous instance
    local old = LocalPlayer.PlayerGui:FindFirstChild("_SWAT_OVERLAY")
    if old then old:Destroy() end

    local sg = Instance.new("ScreenGui")
    sg.Name             = "_SWAT_OVERLAY"
    sg.ResetOnSpawn     = false
    sg.IgnoreGuiInset   = true
    sg.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
    sg.Parent           = LocalPlayer.PlayerGui

    local function makeBtn(name, text, col, ax, ay, w, h)
        local btn = Instance.new("TextButton")
        btn.Name                   = name
        btn.Size                   = UDim2.new(0, w, 0, h)
        btn.AnchorPoint            = Vector2.new(0.5, 0.5)
        btn.Position               = UDim2.new(ax, 0, ay, 0)
        btn.BackgroundColor3       = col
        btn.BackgroundTransparency = 0.25
        btn.BorderSizePixel        = 0
        btn.Text                   = text
        btn.TextColor3             = Color3.fromRGB(255, 255, 255)
        btn.TextStrokeTransparency = 0.4
        btn.Font                   = Enum.Font.GothamBold
        btn.TextSize               = 16
        btn.AutoButtonColor        = true
        btn.Parent                 = sg

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0.3, 0)
        corner.Parent = btn

        local stroke = Instance.new("UIStroke")
        stroke.Color       = Color3.fromRGB(255, 255, 255)
        stroke.Thickness   = 1.5
        stroke.Transparency = 0.5
        stroke.Parent = btn

        return btn
    end

    -- Fly Up button — right side, hidden until flying
    _flyUpBtn = makeBtn("FlyUpBtn", "▲",
        Color3.fromRGB(20, 180, 80), 0.93, 0.70, 60, 60)
    _flyUpBtn.Visible = false

    -- Fly Down button — right side below up, hidden until flying
    _flyDownBtn = makeBtn("FlyDownBtn", "▼",
        Color3.fromRGB(200, 60, 30), 0.93, 0.80, 60, 60)
    _flyDownBtn.Visible = false

    -- ── Fly Up/Down — hold to fly vertically ─────────────────
    _flyUpBtn.MouseButton1Down:Connect(function() FLY_BTN_UP = 1   end)
    _flyUpBtn.MouseButton1Up:Connect(function()   FLY_BTN_UP = 0   end)
    _flyUpBtn.MouseLeave:Connect(function()       FLY_BTN_UP = 0   end)

    _flyDownBtn.MouseButton1Down:Connect(function() FLY_BTN_DOWN = -1 end)
    _flyDownBtn.MouseButton1Up:Connect(function()   FLY_BTN_DOWN = 0  end)
    _flyDownBtn.MouseLeave:Connect(function()       FLY_BTN_DOWN = 0  end)

    -- If fly is currently active, show fly buttons immediately
    if FLYING then
        _flyUpBtn.Visible   = true
        _flyDownBtn.Visible = true
    end
end

-- Create overlay UI now (after LocalPlayer is available)
createOverlayUI()

-- ───────────────────────────────────────────────────────────────
-- TABS
-- ───────────────────────────────────────────────────────────────

-- ── TAB HOME ────────────────────────────────────────────────────
local TabHome = Window:CreateTab(T("TabHome"), 4483362458)
TabHome:CreateParagraph({
    Title   = T("CreditsTitle"),
    Content = T("CreditsContent"),
})

-- ── TAB COMBAT ──────────────────────────────────────────────────
local TabCombat = Window:CreateTab(T("TabCombat"), 4483362458)

TabCombat:CreateToggle({
    Name         = T("ESPEnabled"),
    CurrentValue = Settings.ESP,
    Flag         = "ESP",
    Callback     = function(v) Settings.ESP = v end,
})

TabCombat:CreateToggle({
    Name         = T("ObjectiveESP"),
    CurrentValue = Settings.ObjectiveESP,
    Flag         = "ObjectiveESP",
    Callback     = function(v) Settings.ObjectiveESP = v end,
})

TabCombat:CreateDivider()

TabCombat:CreateToggle({
    Name         = T("HitboxToggle"),
    CurrentValue = Settings.Hitbox,
    Flag         = "Hitbox",
    Callback     = function(v)
        Settings.Hitbox = v
        if not v then
            -- restore original sizes + transparency (suspect NPCs only)
            for _, obj in ipairs(Workspace:GetChildren()) do
                if isSuspect(obj) then
                    local hrpS = obj:FindFirstChild("HumanoidRootPart")
                    if hrpS then
                        local sv = hrpS:FindFirstChild("_origSzSWAT")
                        if sv then hrpS.Size = sv.Value; sv:Destroy() end
                        local tv = hrpS:FindFirstChild("_origTrSWAT")
                        if tv then
                            hrpS.Transparency = tv.Value
                            hrpS.LocalTransparencyModifier = 0
                            tv:Destroy()
                        end
                        local box = hrpS:FindFirstChild("_hbBoxSWAT")
                        if box then box:Destroy() end
                    end
                end
            end
        end
    end,
})
TabCombat:CreateSlider({
    Name         = T("HitboxSize"),
    Range        = {2, 25},
    Increment    = 1,
    CurrentValue = Settings.HitboxSize,
    Flag         = "HitboxSize",
    Callback     = function(v) Settings.HitboxSize = v end,
})

-- ── TAB WEAPONS ─────────────────────────────────────────────────
local TabWeapons = Window:CreateTab(T("TabWeapons"), 4483362458)

-- a) Infinite Ammo
TabWeapons:CreateToggle({
    Name         = T("InfiniteAmmo"),
    CurrentValue = Settings.InfiniteAmmo,
    Flag         = "InfiniteAmmo",
    Callback     = function(v)
        Settings.InfiniteAmmo = v
        if v then
            task.spawn(function()
                while Settings.InfiniteAmmo do
                    if not isNonLethal() then
                        local _, _, cfg = getACSConfig()
                        if cfg then
                            setACSValue("Ammo", 99999)
                            setACSValue("AmmoInGun", 99999)
                            setACSValue("StoredAmmo", math.huge)
                        else
                            Rayfield:Notify({Title="Weapons", Content="Fire your weapon once to activate", Duration=4})
                            Settings.InfiniteAmmo = false
                            break
                        end
                    end
                    task.wait(0.3)
                end
            end)
        end
    end,
})

-- b) Freeze Ammo
TabWeapons:CreateToggle({
    Name         = T("FreezeAmmo"),
    CurrentValue = Settings.FreezeAmmo,
    Flag         = "FreezeAmmo",
    Callback     = function(v)
        Settings.FreezeAmmo = v
        if v then
            -- Cache current ammo values
            local _, _, cfg = getACSConfig()
            if cfg then
                Settings._frozenAmmo     = cfg.Ammo     or 25
                Settings._frozenAmmoInGun= cfg.AmmoInGun or 25
            else
                Settings._frozenAmmo     = 25
                Settings._frozenAmmoInGun= 25
            end
            task.spawn(function()
                while Settings.FreezeAmmo do
                    if not isNonLethal() then
                        setACSValue("Ammo",     Settings._frozenAmmo)
                        setACSValue("AmmoInGun",Settings._frozenAmmoInGun)
                    end
                    task.wait(0.3)
                end
            end)
        end
    end,
})

TabWeapons:CreateDivider()

-- c) Fast Reload (one-shot button)
TabWeapons:CreateButton({
    Name     = T("FastReload"),
    Callback = function()
        local ok1 = setACSValue("Ammo", 999)
        local ok2 = setACSValue("AmmoInGun", 999)
        setACSValue("StoredAmmo", math.huge)
        -- Secondary path: fire the ACS reload remote if upvalue [7] is available
        pcall(function()
            local evFolder
            if _acsCache.func then
                local okE, ev = pcall(debug.getupvalue, _acsCache.func, 7)
                if okE and ev then evFolder = ev end
            end
            if not evFolder then
                evFolder = game:GetService("ReplicatedStorage")
                    :FindFirstChild("ACS_Engine")
                evFolder = evFolder and evFolder:FindFirstChild("Events")
            end
            if evFolder then
                local reload = evFolder:FindFirstChild("Reload")
                if reload then reload:FireServer() end
            end
        end)
        if ok1 or ok2 then
            Rayfield:Notify({Title = T("FastReload"), Content = "✓ Reloaded!", Duration = 2})
        else
            Rayfield:Notify({Title = T("FastReload"), Content = "Fire your weapon once to activate", Duration = 3})
        end
    end,
})

TabWeapons:CreateDivider()

-- d) Rapid Fire toggle
TabWeapons:CreateToggle({
    Name         = T("RapidFire"),
    CurrentValue = Settings.RapidFire,
    Flag         = "RapidFire",
    Callback     = function(v)
        Settings.RapidFire = v
        if v then
            -- Cache original shoot rate on first activation
            local _, _, cfg = getACSConfig()
            if cfg and Settings._origShootRate == nil then
                Settings._origShootRate = cfg.ShootRate or 750
            elseif Settings._origShootRate == nil then
                Settings._origShootRate = 750
            end
            task.spawn(function()
                while Settings.RapidFire do
                    if not isNonLethal() then
                        if _acsCache.tbl then
                            setACSValue("ShootRate", 10)
                        else
                            Rayfield:Notify({Title="Weapons", Content="Fire your weapon once to activate", Duration=4})
                            Settings.RapidFire = false
                            break
                        end
                    end
                    task.wait(0.3)
                end
                -- Restore original shoot rate when loop exits
                pcall(function()
                    if Settings._origShootRate ~= nil then
                        setACSValue("ShootRate", Settings._origShootRate)
                    end
                end)
            end)
        else
            if Settings._origShootRate ~= nil then
                setACSValue("ShootRate", Settings._origShootRate)
            end
        end
    end,
})

-- e) Wallbang + One Shot toggle
TabWeapons:CreateToggle({
    Name         = T("Wallbang"),
    CurrentValue = Settings.Wallbang,
    Flag         = "Wallbang",
    Callback     = function(v)
        Settings.Wallbang = v
        if v then
            task.spawn(function()
                -- Cache originals on first activation
                local _, _, cfg = getACSConfig()
                if cfg and Settings._origPenetration == nil then
                    Settings._origPenetration = cfg.BulletPenetration or 70
                    Settings._origIgnoreProt  = cfg.IgnoreProtection  or false
                    Settings._origTorsoDmg    = cfg.TorsoDamage and {cfg.TorsoDamage[1], cfg.TorsoDamage[2]} or {57,62}
                    Settings._origLimbDmg     = cfg.LimbDamage  and {cfg.LimbDamage[1],  cfg.LimbDamage[2]}  or {30,35}
                elseif not cfg and Settings._origPenetration == nil then
                    Settings._origPenetration = 70
                    Settings._origIgnoreProt  = false
                    Settings._origTorsoDmg    = {57,62}
                    Settings._origLimbDmg     = {30,35}
                end
                while Settings.Wallbang do
                    if not isNonLethal() then
                        if _acsCache.tbl then
                            setACSValue("BulletPenetration", 100)
                            setACSValue("IgnoreProtection",  true)
                            setACSValue("TorsoDamage", {9999,9999})
                            setACSValue("LimbDamage",  {9999,9999})
                        else
                            Rayfield:Notify({Title="Weapons", Content="Fire your weapon once to activate", Duration=4})
                            Settings.Wallbang = false
                            break
                        end
                    end
                    task.wait(0.3)
                end
                -- Restore originals when loop exits
                pcall(function()
                    if Settings._origPenetration ~= nil then
                        setACSValue("BulletPenetration", Settings._origPenetration)
                        setACSValue("IgnoreProtection",  Settings._origIgnoreProt)
                        setACSValue("TorsoDamage",       Settings._origTorsoDmg)
                        setACSValue("LimbDamage",        Settings._origLimbDmg)
                        Settings._origPenetration = nil
                        Settings._origIgnoreProt  = nil
                        Settings._origTorsoDmg    = nil
                        Settings._origLimbDmg     = nil
                    end
                end)
            end)
        else
            -- Restore originals immediately when toggled off
            if Settings._origPenetration ~= nil then
                setACSValue("BulletPenetration", Settings._origPenetration)
                setACSValue("IgnoreProtection",  Settings._origIgnoreProt)
                setACSValue("TorsoDamage",       Settings._origTorsoDmg)
                setACSValue("LimbDamage",        Settings._origLimbDmg)
                Settings._origPenetration = nil
                Settings._origIgnoreProt  = nil
                Settings._origTorsoDmg    = nil
                Settings._origLimbDmg     = nil
            end
        end
    end,
})

-- f) Wall Check (one-shot raycast button)
TabWeapons:CreateButton({
    Name     = T("WallCheck"),
    Callback = function()
        pcall(function()
            local myHRP = getHRP()
            if not myHRP then
                Rayfield:Notify({Title = T("WallCheck"), Content = "No character", Duration = 3})
                return
            end
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = {LocalPlayer.Character}

            local lines = {}
            for _, obj in ipairs(Workspace:GetChildren()) do
                if isSuspect(obj) then
                    local sHRP = obj:FindFirstChild("HumanoidRootPart")
                    if sHRP then
                        local dir    = (sHRP.Position - myHRP.Position)
                        local result = Workspace:Raycast(myHRP.Position, dir, params)
                        local behindWall = result and not result.Instance:IsDescendantOf(obj)
                        lines[#lines+1] = obj.Name .. (behindWall and " 🔴 WALL" or " 🟢 CLEAR")
                    end
                end
            end
            local summary = #lines > 0 and table.concat(lines, "\n") or "No suspects found"
            Rayfield:Notify({Title = T("WallCheck"), Content = summary, Duration = 8})
        end)
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
    Range        = {10, 350},
    Increment    = 5,
    CurrentValue = Settings.FlySpeed,
    Flag         = "FlySpeed",
    Callback     = function(v) Settings.FlySpeed = v end,
})

TabMovement:CreateDivider()

TabMovement:CreateToggle({
    Name         = T("NoClip"),
    CurrentValue = Settings.NoClip,
    Flag         = "NoClip",
    Callback     = function(v) Settings.NoClip = v end,
})
TabMovement:CreateSlider({
    Name         = T("WalkSpeed"),
    Range        = {16, 350},
    Increment    = 2,
    CurrentValue = Settings.WalkSpeed,
    Flag         = "WalkSpeed",
    Callback     = function(v)
        Settings.WalkSpeed = v
        local h = getHum()
        if h then h.WalkSpeed = v end
    end,
})

TabMovement:CreateDivider()
TabMovement:CreateToggle({
    Name         = T("Jump"),
    CurrentValue = Settings.JumpEnabled,
    Flag         = "JumpEnabled",
    Callback     = function(v) Settings.JumpEnabled = v end,
})
TabMovement:CreateSlider({
    Name         = T("JumpPower"),
    Range        = {10, 300},
    Increment    = 5,
    CurrentValue = Settings.JumpPower,
    Flag         = "JumpPower",
    Callback     = function(v)
        Settings.JumpPower = v
        local h = getHum()
        if h and Settings.JumpEnabled then h.JumpPower = v end
    end,
})
TabMovement:CreateDivider()
TabMovement:CreateToggle({
    Name         = T("InfJump"),
    CurrentValue = Settings.InfJump,
    Flag         = "InfJump",
    Callback     = function(v) Settings.InfJump = v end,
})

-- ── TAB AUTO ────────────────────────────────────────────────────
local TabAuto = Window:CreateTab(T("TabAuto"), 4483362458)

TabAuto:CreateToggle({
    Name         = T("AutoArrest"),
    CurrentValue = Settings.AutoArrest,
    Flag         = "AutoArrest",
    Callback     = function(v) Settings.AutoArrest = v end,
})
TabAuto:CreateSlider({
    Name         = T("AutoArrestDelay"),
    Range        = {0.1, 3.0},
    Increment    = 0.1,
    CurrentValue = Settings.AutoArrestDelay,
    Flag         = "AutoArrestDelay",
    Callback     = function(v) Settings.AutoArrestDelay = v end,
})
TabAuto:CreateSlider({
    Name         = T("AutoArrestDist"),
    Range        = {0, 500},
    Increment    = 5,
    CurrentValue = Settings.AutoArrestDist,
    Flag         = "AutoArrestDist",
    Callback     = function(v) Settings.AutoArrestDist = v end,
})

TabAuto:CreateDivider()

TabAuto:CreateButton({
    Name     = T("BringNearest"),
    Callback = function()
        local hrp = getHRP()
        if not hrp then return end
        local _, bhrp = getNearestSuspect()
        if bhrp then
            bhrp.CFrame = CFrame.new(hrp.Position + Vector3.new(2, 0, 0))
            Rayfield:Notify({Title = T("BringNearest"), Content = "✓", Duration = 2})
        end
    end,
})
TabAuto:CreateButton({
    Name     = T("BringAll"),
    Callback = function()
        local hrp = getHRP()
        if not hrp then return end
        local suspects = getAllSuspects()
        local count = 0
        for i, s in ipairs(suspects) do
            local sh = s:FindFirstChild("HumanoidRootPart")
            if sh then
                local angle = (i-1) * (2*math.pi / math.max(#suspects,1))
                local offset = Vector3.new(math.cos(angle)*4, 0, math.sin(angle)*4)
                sh.CFrame = CFrame.new(hrp.Position + offset)
                count = count + 1
            end
        end
        Rayfield:Notify({Title = T("BringAll"), Content = count.." suspects brought", Duration = 2})
    end,
})

TabAuto:CreateDivider()

TabAuto:CreateButton({
    Name     = T("OpenDoors"),
    Callback = function()
        local count = 0
        -- Primary: workspace.Map.Doors container + ChangeDoor remote (confirmed via Cobalt log)
        -- Action "Open" confirmed: Event:FireServer(door, "Open")
        local ChangeDoor
        pcall(function()
            local net = game:GetService("ReplicatedStorage"):FindFirstChild("Network")
            if net then ChangeDoor = net:FindFirstChild("ChangeDoor") end
        end)
        local doorsFolder
        pcall(function()
            doorsFolder = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Doors")
        end)
        if ChangeDoor and doorsFolder then
            for _, door in ipairs(doorsFolder:GetChildren()) do
                pcall(function() ChangeDoor:FireServer(door, "Open") end)
                count = count + 1
            end
            if count > 0 then
                Rayfield:Notify({Title = T("OpenDoors"), Content = count.." doors opened", Duration = 2})
                return
            end
        end
        -- Fallback: proximity prompts labelled open/unlock/enter
        local OPEN_KW = {"open","unlock","enter","push","pull"}
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                local lbl = obj.ActionText:lower()
                for _, kw in ipairs(OPEN_KW) do
                    if lbl:find(kw) then
                        pcall(function() fireproximityprompt(obj) end)
                        count = count + 1
                        break
                    end
                end
            end
        end
        Rayfield:Notify({Title = T("OpenDoors"), Content = count > 0 and count.." open prompts fired" or "No doors found", Duration = 2})
    end,
})

TabAuto:CreateButton({
    Name     = "Close All Doors",
    Callback = function()
        local count = 0
        -- Primary: workspace.Map.Doors container + ChangeDoor remote
        -- Action "Kick" confirmed via Cobalt log: Event:FireServer(door, "Kick")
        local ChangeDoor
        pcall(function()
            local net = game:GetService("ReplicatedStorage"):FindFirstChild("Network")
            if net then ChangeDoor = net:FindFirstChild("ChangeDoor") end
        end)
        local doorsFolder
        pcall(function()
            doorsFolder = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Doors")
        end)
        if ChangeDoor and doorsFolder then
            for _, door in ipairs(doorsFolder:GetChildren()) do
                pcall(function() ChangeDoor:FireServer(door, "Kick") end)
                count = count + 1
            end
            if count > 0 then
                Rayfield:Notify({Title = "Close All Doors", Content = count.." doors closed", Duration = 2})
                return
            end
        end
        -- Fallback: proximity prompts labelled close/lock/shut
        local CLOSE_KW = {"close","shut","lock","seal"}
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                local lbl = obj.ActionText:lower()
                for _, kw in ipairs(CLOSE_KW) do
                    if lbl:find(kw) then
                        pcall(function() fireproximityprompt(obj) end)
                        count = count + 1
                        break
                    end
                end
            end
        end
        if count == 0 then
            Rayfield:Notify({Title = "Close All Doors", Content = "No doors found — check Map.Doors path", Duration = 3})
        else
            Rayfield:Notify({Title = "Close All Doors", Content = count.." doors closed", Duration = 2})
        end
    end,
})

TabAuto:CreateDivider()

TabAuto:CreateButton({
    Name     = "Secure Evidence / Validate Objective",
    Callback = function()
        -- Locate the SecureEvidence remote (works on all maps)
        local SecureEvidence
        pcall(function()
            local net = ReplicatedStorage:FindFirstChild("Network")
            if net then SecureEvidence = net:FindFirstChild("SecureEvidence") end
        end)
        if not SecureEvidence then
            Rayfield:Notify({Title = "Secure Evidence", Content = "SecureEvidence remote not found", Duration = 3})
            return
        end
        -- Generic keyword scan: matches evidence objects regardless of map
        local EVIDENCE_KW = {"evidence", "cash", "money", "drug", "package", "objective"}
        local found, secured = 0, 0
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") or obj:IsA("BasePart") then
                local n = obj.Name:lower()
                for _, kw in ipairs(EVIDENCE_KW) do
                    if n:find(kw, 1, true) then
                        found = found + 1
                        local ok = pcall(function() SecureEvidence:FireServer(obj) end)
                        if ok then secured = secured + 1 end
                        break
                    end
                end
            end
        end
        Rayfield:Notify({
            Title   = "Secure Evidence",
            Content = secured .. "/" .. found .. " objects secured",
            Duration = 3,
        })
    end,
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
            Lighting.Brightness    = 2
            Lighting.ClockTime     = 14
            Lighting.GlobalShadows = false
        else
            Lighting.Brightness    = 1
            Lighting.ClockTime     = 14
            Lighting.GlobalShadows = true
        end
    end,
})

TabTools:CreateToggle({
    Name         = T("AntiAFK"),
    CurrentValue = Settings.AntiAFK,
    Flag         = "AntiAFK",
    Callback     = function(v) Settings.AntiAFK = v end,
})

local langOpts = {"EN","FR","DE","ES","PT","RU","IT","NL","PL","ZH","JA","TR","KO","AR","VI","SV","EL","RO","UK","CS","DA"}
TabTools:CreateDropdown({
    Name          = T("LangSelect"),
    Options       = langOpts,
    CurrentOption = {CurrentLang},
    Flag          = "Language",
    Callback      = function(sel)
        CurrentLang = sel[1] or sel
        Rayfield:Notify({Title="Language", Content="Re-execute to apply.", Duration=4})
    end,
})


-- ───────────────────────────────────────────────────────────────
-- AUTO ARREST: loop
-- ───────────────────────────────────────────────────────────────
local lastArrestTime = 0
local ARREST_KEYWORDS = {
    "arrest","handcuff","detain","cuff","interact",
    "capture","tackle","subdue","grab","seize","apprehend"
}

local function tryAutoArrest()
    if not Settings.AutoArrest then return end
    local now = tick()
    if now - lastArrestTime < Settings.AutoArrestDelay then return end
    lastArrestTime = now

    local hrp = getHRP()
    if not hrp then return end

    local maxDist = Settings.AutoArrestDist  -- 0 = unlimited

    local function inRange(pos)
        if maxDist <= 0 then return true end
        return (pos - hrp.Position).Magnitude <= maxDist
    end

    -- Grab ShoutNPC remote once (makes suspects kneel/surrender before arrest)
    local ShoutNPC
    pcall(function()
        local net = ReplicatedStorage:FindFirstChild("Network")
        if net then ShoutNPC = net:FindFirstChild("ShoutNPC") end
    end)

    -- Strategy 1: fire ProximityPrompts on civilian/hostage NPC models (unarmed = to arrest)
    --   • Distance check: NPC must be within AutoArrestDist
    --   • ShoutNPC is fired first to make the civilian comply (prerequisite for cuff prompt)
    --   • Suspects (armed criminals) are NEVER targeted here — they must be neutralised by shooting
    for _, obj in ipairs(Workspace:GetChildren()) do
        if isCivilian(obj) then
            local npcHRP = obj:FindFirstChild("HumanoidRootPart")
            if npcHRP and inRange(npcHRP.Position) then
                -- Fire ShoutNPC to make civilian comply (required before cuff prompt appears)
                if ShoutNPC then
                    pcall(function() ShoutNPC:FireServer(obj) end)
                end
                -- Short delay so the kneel animation registers before we fire arrest prompt
                task.delay(0.3, function()
                    local surrendered = isSurrendered(obj)
                    for _, pp in ipairs(obj:GetDescendants()) do
                        if pp:IsA("ProximityPrompt") then
                            pcall(function() fireproximityprompt(pp) end)
                        elseif pp:IsA("ClickDetector") and surrendered then
                            pcall(function() fireclickdetector(pp) end)
                        end
                    end
                end)
            end
        end
    end

    -- Strategy 2: scan ALL ProximityPrompts by ActionText keyword, within distance
    for _, pp in ipairs(Workspace:GetDescendants()) do
        if pp:IsA("ProximityPrompt") then
            local ppPart = pp.Parent
            if ppPart and ppPart:IsA("BasePart") and inRange(ppPart.Position) then
                local action = (pp.ActionText or ""):lower()
                local name   = pp.Name:lower()
                for _, kw in ipairs(ARREST_KEYWORDS) do
                    if action:find(kw) or name:find(kw) then
                        pcall(function() fireproximityprompt(pp) end)
                        break
                    end
                end
            end
        elseif pp:IsA("ClickDetector") then
            local cdPart = pp.Parent
            if cdPart and cdPart:IsA("BasePart") and inRange(cdPart.Position) then
                local name = pp.Name:lower()
                for _, kw in ipairs(ARREST_KEYWORDS) do
                    if name:find(kw) then
                        pcall(function() fireclickdetector(pp) end)
                        break
                    end
                end
            end
        end
    end

    -- Strategy 3: fire arrest-named RemoteEvents at root level
    for _, rs in ipairs({ReplicatedStorage, Workspace}) do
        for _, re in ipairs(rs:GetDescendants()) do
            if re:IsA("RemoteEvent") then
                local n = re.Name:lower()
                for _, kw in ipairs(ARREST_KEYWORDS) do
                    if n:find(kw) then
                        pcall(function() re:FireServer() end)
                        break
                    end
                end
            end
        end
    end
end

-- ───────────────────────────────────────────────────────────────
-- ANTI-AFK
-- ───────────────────────────────────────────────────────────────
local lastAFKPing = tick()
local AFK_INTERVAL = 240 -- 4 minutes

-- ───────────────────────────────────────────────────────────────
-- MAIN LOOP (RenderStepped — every frame)
-- ───────────────────────────────────────────────────────────────
local _espTick = 0  -- Volt freeze fix: throttle ESP iterations to 0.1s

RunService.RenderStepped:Connect(function()
    local char = getChar()
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")

    -- ── NOCLIP ────────────────────────────────────────────────
    if Settings.NoClip then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then
                p.CanCollide = false
            end
        end
    end

    -- ── FLY — handled inside enableFly() task.spawn loop ─────
    -- (no per-frame logic here; loop runs autonomously)

    -- ── ESP THROTTLE — only iterate workspace/players every 0.1s ──
    local now = tick()
    if now - _espTick < 0.1 then
        -- Skip ESP this frame; still apply walkspeed below
        if hum and hum.WalkSpeed ~= Settings.WalkSpeed and not Settings.Fly then
            hum.WalkSpeed = Settings.WalkSpeed
        end
        return
    end
    _espTick = now

    -- ── DYNAMIC NPC ESP ───────────────────────────────────────
    local OBJ_KW = {
        "objective","target","goal","bomb","package","case",
        "briefcase","evidence","vault","keycard","intel","device",
        "mission","cargo","loot","artifact","item","objective"
    }

    for _, obj in ipairs(Workspace:GetChildren()) do
        -- Vest presence = suspect; no Vest = civilian; non-NPC = nil
        local isCrim = isSuspect(obj)
        local isCiv  = (not isCrim) and isCivilian(obj)
        local npcType = isCrim and "criminal" or (isCiv and "civilian" or nil)

        if npcType then
            -- ── NPC ESP ───────────────────────────────────────────
            -- Suspects (Vest)  → orange highlight, [SUSPECT] label
            -- Civilians (no Vest) → yellow highlight, [CIVILIAN] label

            local bbTagC   = "_SWAT_BB_C"   -- suspect billboard tag
            local bbTagCiv = "_SWAT_BB_CIV" -- civilian billboard tag

            if Settings.ESP and isCrim then
                -- Remove any leftover civilian highlight on this model
                local civHL = obj:FindFirstChild("_SWAT_HL_CIV")
                if civHL then civHL:Destroy() end
                local sHRPv = obj:FindFirstChild("HumanoidRootPart")
                if sHRPv then
                    local civBB = sHRPv:FindFirstChild(bbTagCiv)
                    if civBB then civBB:Destroy() end
                end

                -- Suspect highlight (orange)
                if not obj:FindFirstChild("_SWAT_HL_C") then
                    local hl = Instance.new("Highlight")
                    hl.Name             = "_SWAT_HL_C"
                    hl.FillTransparency = 0.35
                    hl.FillColor        = Color3.fromRGB(255, 70,  0)
                    hl.OutlineColor     = Color3.fromRGB(255, 200, 0)
                    hl.Parent = obj
                end
                -- Suspect BillboardGui
                local sHRP = obj:FindFirstChild("HumanoidRootPart")
                if sHRP and not sHRP:FindFirstChild(bbTagC) then
                    local bb  = Instance.new("BillboardGui")
                    bb.Name        = bbTagC
                    bb.Size        = UDim2.new(0, 140, 0, 48)
                    bb.StudsOffset = Vector3.new(0, 3.5, 0)
                    bb.AlwaysOnTop = true
                    bb.Parent      = sHRP
                    local lbl = Instance.new("TextLabel")
                    lbl.Name                   = "Lbl"
                    lbl.Size                   = UDim2.new(1,0,1,0)
                    lbl.BackgroundTransparency = 1
                    lbl.TextStrokeTransparency = 0
                    lbl.TextScaled             = true
                    lbl.Font                   = Enum.Font.GothamBold
                    lbl.TextColor3             = Color3.fromRGB(255, 230, 80)
                    lbl.Parent = bb
                end
                -- Update suspect HP label every frame
                local sHRP2 = obj:FindFirstChild("HumanoidRootPart")
                if sHRP2 then
                    local bb = sHRP2:FindFirstChild(bbTagC)
                    local sH = obj:FindFirstChildOfClass("Humanoid")
                    if bb and sH then
                        local l = bb:FindFirstChild("Lbl")
                        if l then
                            l.Text = string.format("[SUSPECT]\n%s\n❤ %d/%d",
                                obj.Name,
                                math.floor(sH.Health),
                                math.floor(sH.MaxHealth))
                        end
                    end
                end

            elseif Settings.ESP and isCiv then
                -- Remove any leftover suspect highlight on this model
                local crimHL = obj:FindFirstChild("_SWAT_HL_C")
                if crimHL then crimHL:Destroy() end
                local sHRPv = obj:FindFirstChild("HumanoidRootPart")
                if sHRPv then
                    local crimBB = sHRPv:FindFirstChild(bbTagC)
                    if crimBB then crimBB:Destroy() end
                end

                -- Civilian highlight (yellow)
                if not obj:FindFirstChild("_SWAT_HL_CIV") then
                    local hl = Instance.new("Highlight")
                    hl.Name             = "_SWAT_HL_CIV"
                    hl.FillTransparency = 0.45
                    hl.FillColor        = Color3.fromRGB(255, 240, 0)
                    hl.OutlineColor     = Color3.fromRGB(255, 200, 50)
                    hl.Parent = obj
                end
                -- Civilian BillboardGui
                local sHRP = obj:FindFirstChild("HumanoidRootPart")
                if sHRP and not sHRP:FindFirstChild(bbTagCiv) then
                    local bb  = Instance.new("BillboardGui")
                    bb.Name        = bbTagCiv
                    bb.Size        = UDim2.new(0, 140, 0, 48)
                    bb.StudsOffset = Vector3.new(0, 3.5, 0)
                    bb.AlwaysOnTop = true
                    bb.Parent      = sHRP
                    local lbl = Instance.new("TextLabel")
                    lbl.Name                   = "Lbl"
                    lbl.Size                   = UDim2.new(1,0,1,0)
                    lbl.BackgroundTransparency = 1
                    lbl.TextStrokeTransparency = 0
                    lbl.TextScaled             = true
                    lbl.Font                   = Enum.Font.GothamBold
                    lbl.TextColor3             = Color3.fromRGB(255, 255, 80)
                    lbl.Parent = bb
                end
                -- Update civilian HP label every frame
                local sHRP2 = obj:FindFirstChild("HumanoidRootPart")
                if sHRP2 then
                    local bb = sHRP2:FindFirstChild(bbTagCiv)
                    local sH = obj:FindFirstChildOfClass("Humanoid")
                    if bb and sH then
                        local l = bb:FindFirstChild("Lbl")
                        if l then
                            l.Text = string.format("[CIVILIAN]\n%s\n❤ %d/%d",
                                obj.Name,
                                math.floor(sH.Health),
                                math.floor(sH.MaxHealth))
                        end
                    end
                end

            else
                -- ESP disabled — clean up all NPC highlights
                local hC   = obj:FindFirstChild("_SWAT_HL_C")
                local hCiv = obj:FindFirstChild("_SWAT_HL_CIV")
                if hC   then hC:Destroy() end
                if hCiv then hCiv:Destroy() end
                local sHRP = obj:FindFirstChild("HumanoidRootPart")
                if sHRP then
                    local bbC   = sHRP:FindFirstChild(bbTagC)
                    local bbCiv = sHRP:FindFirstChild(bbTagCiv)
                    if bbC   then bbC:Destroy() end
                    if bbCiv then bbCiv:Destroy() end
                end
            end

            -- (hitbox handled in dedicated Heartbeat loop below)

        elseif Settings.ObjectiveESP and obj:IsA("BasePart") then
            -- ── OBJECTIVE ESP — non-NPC parts with objective keywords ──
            local n = obj.Name:lower()
            local isObj = false
            for _, kw in ipairs(OBJ_KW) do
                if n:find(kw) then isObj = true; break end
            end
            if isObj then
                if not obj:FindFirstChild("_SWAT_OBJ_HL") then
                    local hl = Instance.new("Highlight")
                    hl.Name             = "_SWAT_OBJ_HL"
                    hl.FillColor        = Color3.fromRGB(255, 255, 0)   -- yellow
                    hl.OutlineColor     = Color3.fromRGB(255, 200, 0)
                    hl.FillTransparency = 0.25
                    hl.Parent           = obj
                    -- Label
                    local bb = Instance.new("BillboardGui")
                    bb.Name        = "_SWAT_OBJ_BB"
                    bb.Size        = UDim2.new(0, 120, 0, 36)
                    bb.StudsOffset = Vector3.new(0, 2.5, 0)
                    bb.AlwaysOnTop = true
                    bb.Parent      = obj
                    local lbl = Instance.new("TextLabel")
                    lbl.Name                   = "Lbl"
                    lbl.Size                   = UDim2.new(1,0,1,0)
                    lbl.BackgroundTransparency = 1
                    lbl.TextColor3             = Color3.fromRGB(255, 255, 100)
                    lbl.TextStrokeTransparency = 0
                    lbl.TextScaled             = true
                    lbl.Font                   = Enum.Font.GothamBold
                    lbl.Text                   = "⭐ "..obj.Name
                    lbl.Parent                 = bb
                end
            end
        else
            -- Objective ESP cleanup when disabled
            if not Settings.ObjectiveESP then
                local hl = obj:FindFirstChild("_SWAT_OBJ_HL")
                if hl then hl:Destroy() end
                local bb = obj:FindFirstChild("_SWAT_OBJ_BB")
                if bb then bb:Destroy() end
            end
        end
    end

    -- ── PLAYER ESP (enemy team) ───────────────────────────────
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local pChar = p.Character
            local isEnemy = isEnemyPlayer(pChar)
            local epHlTag = "_SWAT_EP_HL"
            local epBbTag = "_SWAT_EP_BB"

            if Settings.ESP and isEnemy then
                -- Highlight
                if not pChar:FindFirstChild(epHlTag) then
                    local hl = Instance.new("Highlight")
                    hl.Name             = epHlTag
                    hl.FillColor        = Color3.fromRGB(255, 30, 30)   -- red
                    hl.OutlineColor     = Color3.fromRGB(255, 150, 0)   -- orange border
                    hl.FillTransparency = 0.3
                    hl.Parent           = pChar
                end
                -- BillboardGui above head
                local pHRP = pChar:FindFirstChild("HumanoidRootPart")
                if pHRP and not pHRP:FindFirstChild(epBbTag) then
                    local bb = Instance.new("BillboardGui")
                    bb.Name        = epBbTag
                    bb.Size        = UDim2.new(0, 160, 0, 52)
                    bb.StudsOffset = Vector3.new(0, 4, 0)
                    bb.AlwaysOnTop = true
                    bb.Parent      = pHRP
                    local lbl = Instance.new("TextLabel")
                    lbl.Name                   = "Lbl"
                    lbl.Size                   = UDim2.new(1,0,1,0)
                    lbl.BackgroundTransparency = 1
                    lbl.TextStrokeTransparency = 0
                    lbl.TextScaled             = true
                    lbl.Font                   = Enum.Font.GothamBold
                    lbl.TextColor3             = Color3.fromRGB(255, 100, 100)
                    lbl.Parent                 = bb
                end
                -- Update HP label
                local pHRP2 = pChar:FindFirstChild("HumanoidRootPart")
                if pHRP2 then
                    local bb2 = pHRP2:FindFirstChild(epBbTag)
                    local pH  = pChar:FindFirstChildOfClass("Humanoid")
                    if bb2 and pH then
                        local lbl2 = bb2:FindFirstChild("Lbl")
                        if lbl2 then
                            lbl2.Text = string.format("[ENEMY] %s\n❤ %d/%d",
                                p.Name,
                                math.floor(pH.Health),
                                math.floor(pH.MaxHealth))
                        end
                    end
                end
            else
                -- Cleanup when not enemy or ESP off
                local hl = pChar:FindFirstChild(epHlTag)
                if hl then hl:Destroy() end
                local pHRP = pChar:FindFirstChild("HumanoidRootPart")
                if pHRP then
                    local bb2 = pHRP:FindFirstChild(epBbTag)
                    if bb2 then bb2:Destroy() end
                end
            end

            -- ── PLAYER HITBOX (enemy team) ─────────────────────
            if Settings.Hitbox and isEnemy then
                local pHRP = pChar:FindFirstChild("HumanoidRootPart")
                if pHRP then
                    if not pHRP:FindFirstChild("_origSzEP") then
                        local sv = Instance.new("Vector3Value")
                        sv.Name   = "_origSzEP"
                        sv.Value  = pHRP.Size
                        sv.Parent = pHRP
                    end
                    if not pHRP:FindFirstChild("_origTrEP") then
                        local tv = Instance.new("NumberValue")
                        tv.Name   = "_origTrEP"
                        tv.Value  = pHRP.Transparency
                        tv.Parent = pHRP
                    end
                    local sz = Settings.HitboxSize * 2
                    pHRP.Size                      = Vector3.new(sz, sz, sz)
                    pHRP.LocalTransparencyModifier = 0.35
                    pHRP.CanCollide                = false
                end
            elseif not Settings.Hitbox then
                -- Restore player hitbox
                local pHRP = pChar:FindFirstChild("HumanoidRootPart")
                if pHRP then
                    local sv = pHRP:FindFirstChild("_origSzEP")
                    if sv then pHRP.Size = sv.Value; sv:Destroy() end
                    local tv = pHRP:FindFirstChild("_origTrEP")
                    if tv then
                        pHRP.Transparency = tv.Value
                        pHRP.LocalTransparencyModifier = 0
                        tv:Destroy()
                    end
                end
            end
        end
    end

    -- ── WALKSPEED re-apply ─────────────────────────────────────
    if hum and hum.WalkSpeed ~= Settings.WalkSpeed and not Settings.Fly then
        hum.WalkSpeed = Settings.WalkSpeed
    end

    -- ── JUMP re-apply (game forces JumpPower=0 each frame) ─────
    if Settings.JumpEnabled and hum then
        if hum.JumpPower ~= Settings.JumpPower then
            hum.JumpPower = Settings.JumpPower
        end
        if hum.JumpHeight ~= nil and hum.JumpHeight == 0 then
            pcall(function() hum.JumpHeight = Settings.JumpPower / 5 end)
        end
    end
end) -- end RenderStepped

-- ───────────────────────────────────────────────────────────────
-- HITBOX — dedicated Heartbeat loop (throttled at 0.1s — Volt fix)
-- Uses isSuspect() for universal detection (Vest OR name keyword).
-- Works across all maps including Broken Bars (prisoner name fallback).
-- ───────────────────────────────────────────────────────────────
local _hbTick = 0  -- Volt freeze fix: throttle hitbox iterations to 0.1s

RunService.Heartbeat:Connect(function()
    local hbNow = tick()
    if hbNow - _hbTick < 0.1 then return end
    _hbTick = hbNow
    for _, obj in ipairs(Workspace:GetChildren()) do
        -- Universal suspect detection (Vest OR name keyword)
        if isSuspect(obj) then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local hrp = obj:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if Settings.Hitbox then
                        -- Store original size once
                        if not hrp:FindFirstChild("_origSzSWAT") then
                            local sv = Instance.new("Vector3Value")
                            sv.Name   = "_origSzSWAT"
                            sv.Value  = hrp.Size
                            sv.Parent = hrp
                        end
                        local sz = Settings.HitboxSize * 2
                        hrp.Size                      = Vector3.new(sz, sz, sz)
                        hrp.LocalTransparencyModifier = 0.6
                        hrp.CanCollide                = false
                        -- SelectionBox visible indicator (red/orange)
                        if not hrp:FindFirstChild("_hbBoxSWAT") then
                            local box = Instance.new("SelectionBox")
                            box.Name            = "_hbBoxSWAT"
                            box.Adornee         = hrp
                            box.Color3          = Color3.fromRGB(255, 80, 0)
                            box.LineThickness    = 0.05
                            box.SurfaceColor3   = Color3.fromRGB(255, 80, 0)
                            box.SurfaceTransparency = 0.55
                            box.Parent          = hrp
                        end
                    else
                        -- Restore original size when hitbox is off
                        local sv = hrp:FindFirstChild("_origSzSWAT")
                        if sv then hrp.Size = sv.Value; sv:Destroy() end
                        hrp.LocalTransparencyModifier = 0
                        -- Remove SelectionBox
                        local box = hrp:FindFirstChild("_hbBoxSWAT")
                        if box then box:Destroy() end
                    end
                end
            end
        end
    end
end)

-- ───────────────────────────────────────────────────────────────
-- AUTO ARREST + ANTI-AFK — Heartbeat loop
-- ───────────────────────────────────────────────────────────────
RunService.Heartbeat:Connect(function()
    tryAutoArrest()

    -- Anti-AFK: fake VirtualUser input every 4 minutes
    if Settings.AntiAFK then
        if tick() - lastAFKPing > AFK_INTERVAL then
            lastAFKPing = tick()
            pcall(function()
                VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
                task.wait(0.1)
                VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
            end)
        end
    end
end)

-- ───────────────────────────────────────────────────────────────
-- ON RESPAWN
-- ───────────────────────────────────────────────────────────────
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    -- Clear ACS cache so it re-resolves for the new character
    _acsCache    = {func=nil, idx=nil, tbl=nil}
    _nonLethalUV = nil
    -- Invalidate cache when player equips or unequips a tool
    char.ChildAdded:Connect(function(c)
        if c:IsA("Tool") then _acsCache = {func=nil, idx=nil, tbl=nil}; _nonLethalUV = nil end
    end)
    char.ChildRemoved:Connect(function(c)
        if c:IsA("Tool") then _acsCache = {func=nil, idx=nil, tbl=nil}; _nonLethalUV = nil end
    end)
    createOverlayUI()  -- rebuild overlay buttons after respawn
    if Settings.Fly then
        disableFly()
        task.wait(0.1)
        enableFly()
    end
    setupInfJump(char)
    local h = char:FindFirstChildOfClass("Humanoid")
    if h then
        h.WalkSpeed = Settings.WalkSpeed
        if Settings.JumpEnabled then h.JumpPower = Settings.JumpPower end
    end
end)

-- ───────────────────────────────────────────────────────────────
-- READY
-- ───────────────────────────────────────────────────────────────
Rayfield:Notify({
    Title    = T("WindowTitle"),
    Content  = T("Loaded"),
    Duration = 4,
})

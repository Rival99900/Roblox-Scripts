--[[
    ================================================================
    Tactical SWAT Hub — Tactical: Swat Simulator
    Created by Rival960 with the help of Claude
    Version: 1.0.0 | Languages: 21 | Rayfield UI | PC + Mobile
    Status: untested in-game
    ================================================================
    Features:
      COMBAT
        Silent Aim  — FOV camera redirect toward nearest suspect
                      when weapon fires (PC + Mobile)
        God Mode    — health loop, near-invincible
        ESP         — Highlight + BillboardGui (name + HP) on suspects
        Hitbox      — enlarge suspect HRPs for easier hits
      WEAPONS
        Infinite Ammo  — keeps all ammo values at 999 each frame
        Freeze Ammo    — same, but disables natural consumption
        Fast Reload    — forces reload values to max immediately
      MOVEMENT
        Fly        — WASD/MoveDir + UI Up/Down buttons (PC + Mobile)
        NoClip     — pass through walls
        WalkSpeed  — slider 16–350
        Jump       — BodyVelocity boost (works when JumpPower = 0)
                     PC: E key | Mobile: UI button
      AUTO
        Auto Arrest  — fires all arrest/handcuff ProximityPrompts
                       in range, with configurable delay
        Bring Near   — TP nearest suspect to local player
        Bring All    — TP all suspects to local player
        Open Doors   — fires door/gate/checkpoint prompts
      TOOLS
        Fullbright   — brightness + no shadows, fixed clock
        Anti-AFK     — fake input every 4 min to avoid kick
        Language     — 21 languages (re-exec to apply)
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
        SilentAim        = "Silent Aim",
        SilentAimDesc    = "Redirect shots to nearest suspect when firing",
        SilentAimDist    = "Max Distance (studs)",
        SilentAimFOV     = "FOV Radius (px)",
        GodMode          = "God Mode",
        GodModeDesc      = "Continuously restore HP — near-invincible",
        ESPEnabled       = "ESP Suspects",
        ESPDesc          = "Highlight suspects + show HP through walls",
        HitboxToggle     = "Expand Hitboxes",
        HitboxDesc       = "Enlarge suspect HRPs for easier hits",
        HitboxSize       = "Hitbox Size",
        -- Weapons
        InfiniteAmmo     = "Infinite Ammo",
        InfiniteAmmoDesc = "Keep all ammo values at 999",
        FreezeAmmo       = "Freeze Ammo",
        FreezeAmmoDesc   = "Prevent ammo from decreasing",
        FastReload       = "Fast Reload",
        FastReloadDesc   = "Instantly reload equipped weapon",
        -- Movement
        Fly              = "Fly",
        FlyDesc          = "Flight mode (WASD + Up/Down buttons)",
        FlySpeed         = "Fly Speed",
        FloatUp          = "Float Up ▲",
        FloatDown        = "Float Down ▼",
        NoClip           = "NoClip",
        NoClipDesc       = "Pass through walls and obstacles",
        WalkSpeed        = "Walk Speed",
        Jump             = "Jump (E key / button)",
        JumpDesc         = "Force a jump even when disabled",
        JumpPower        = "Jump Power",
        -- Auto
        AutoArrest       = "Auto Arrest",
        AutoArrestDesc   = "Auto-fire arrest prompts on all suspects",
        AutoArrestDelay  = "Arrest Delay (s)",
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
        CreditsContent   = "Created by Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — First release",
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
        SilentAim        = "Silent Aim",
        SilentAimDesc    = "Redirige les tirs vers le suspect le plus proche",
        SilentAimDist    = "Distance max (studs)",
        SilentAimFOV     = "Rayon FOV (px)",
        GodMode          = "Mode Dieu",
        GodModeDesc      = "Restaure les PV en continu — quasi invincible",
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
        CreditsContent   = "Créé par Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Première version",
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
        SilentAim        = "Silent Aim",
        SilentAimDesc    = "Schüsse zum nächsten Verdächtigen umleiten",
        SilentAimDist    = "Max. Entfernung (Studs)",
        SilentAimFOV     = "FOV-Radius (px)",
        GodMode          = "Gottmodus",
        GodModeDesc      = "HP kontinuierlich wiederherstellen",
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
        CreditsContent   = "Erstellt von Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Erste Version",
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
        SilentAim        = "Silent Aim",
        SilentAimDesc    = "Redirige disparos al sospechoso más cercano",
        SilentAimDist    = "Distancia máx. (studs)",
        SilentAimFOV     = "Radio FOV (px)",
        GodMode          = "Modo Dios",
        GodModeDesc      = "Restaurar HP continuamente — casi invencible",
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
        CreditsContent   = "Creado por Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Primera versión",
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
        SilentAim        = "Silent Aim",
        SilentAimDesc    = "Redireciona tiros para o suspeito mais próximo",
        SilentAimDist    = "Distância máx. (studs)",
        SilentAimFOV     = "Raio FOV (px)",
        GodMode          = "Modo Deus",
        GodModeDesc      = "Restaurar HP continuamente — quase invencível",
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
        CreditsContent   = "Criado por Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Primeira versão",
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
        SilentAim        = "Silent Aim",
        SilentAimDesc    = "Перенаправляет выстрелы на ближайшего подозреваемого",
        SilentAimDist    = "Макс. дистанция (Studs)",
        SilentAimFOV     = "Радиус FOV (px)",
        GodMode          = "Режим Бога",
        GodModeDesc      = "Непрерывное восстановление HP — почти неуязвим",
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
        CreditsContent   = "Создано Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Первый выпуск",
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
        SilentAim        = "Silent Aim",
        SilentAimDesc    = "Redirige i colpi verso il sospettato più vicino",
        SilentAimDist    = "Distanza max (studs)",
        SilentAimFOV     = "Raggio FOV (px)",
        GodMode          = "Modalità Dio",
        GodModeDesc      = "Ripristino HP continuo — quasi invincibile",
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
        CreditsContent   = "Creato da Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Prima versione",
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
        SilentAim        = "Silent Aim",
        SilentAimDesc    = "Schoten omleiden naar dichtstbijzijnde verdachte",
        SilentAimDist    = "Max. afstand (studs)",
        SilentAimFOV     = "FOV-straal (px)",
        GodMode          = "Godmodus",
        GodModeDesc      = "HP continu herstellen — bijna onoverwinnelijk",
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
        CreditsContent   = "Gemaakt door Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Eerste versie",
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
        SilentAim        = "Silent Aim",
        SilentAimDesc    = "Przekierowuje strzały na najbliższego podejrzanego",
        SilentAimDist    = "Maks. dystans (studs)",
        SilentAimFOV     = "Promień FOV (px)",
        GodMode          = "Tryb Boga",
        GodModeDesc      = "Ciągłe przywracanie HP — prawie niezniszczalny",
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
        CreditsContent   = "Stworzone przez Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Pierwsza wersja",
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
        SilentAim        = "静默瞄准",
        SilentAimDesc    = "开枪时将子弹重定向到最近嫌疑人",
        SilentAimDist    = "最大距离（格）",
        SilentAimFOV     = "FOV半径（像素）",
        GodMode          = "无敌模式",
        GodModeDesc      = "持续恢复HP — 几乎无敌",
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
        CreditsContent   = "由 Rival960 创建\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — 首次发布",
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
        SilentAim        = "サイレントエイム",
        SilentAimDesc    = "射撃時に最近の容疑者に向けてリダイレクト",
        SilentAimDist    = "最大距離（Studs）",
        SilentAimFOV     = "FOV半径（px）",
        GodMode          = "神モード",
        GodModeDesc      = "HPを継続回復 — ほぼ無敵",
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
        CreditsContent   = "Rival960 作\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — 初回リリース",
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
        SilentAim        = "Silent Aim",
        SilentAimDesc    = "Ateş ederken en yakın şüpheliye yönlendir",
        SilentAimDist    = "Maks. mesafe (studs)",
        SilentAimFOV     = "FOV yarıçapı (px)",
        GodMode          = "Tanrı Modu",
        GodModeDesc      = "HP'yi sürekli yenile — neredeyse yenilmez",
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
        CreditsContent   = "Rival960 tarafından\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — İlk sürüm",
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
        SilentAim        = "사일런트 에임",
        SilentAimDesc    = "발사 시 가장 가까운 용의자로 탄도 변경",
        SilentAimDist    = "최대 거리 (studs)",
        SilentAimFOV     = "FOV 반경 (px)",
        GodMode          = "갓 모드",
        GodModeDesc      = "HP 지속 회복 — 거의 불사",
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
        CreditsContent   = "Rival960 제작\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — 첫 번째 릴리스",
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
        SilentAim        = "صمت التصويب",
        SilentAimDesc    = "توجيه الطلقات نحو أقرب مشتبه به عند إطلاق النار",
        SilentAimDist    = "المسافة القصوى",
        SilentAimFOV     = "نصف قطر FOV (بكسل)",
        GodMode          = "وضع الإله",
        GodModeDesc      = "استعادة HP بشكل مستمر — شبه لا يُهزم",
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
        CreditsContent   = "أنشأه Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — الإصدار الأول",
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
        SilentAim        = "Silent Aim",
        SilentAimDesc    = "Chuyển hướng đạn sang nghi phạm gần nhất",
        SilentAimDist    = "Khoảng cách tối đa (studs)",
        SilentAimFOV     = "Bán kính FOV (px)",
        GodMode          = "Chế độ Thần",
        GodModeDesc      = "Liên tục hồi HP — gần như bất tử",
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
        CreditsContent   = "Tạo bởi Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Phiên bản đầu tiên",
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
        SilentAim        = "Silent Aim",
        SilentAimDesc    = "Dirigera skott mot närmaste misstänkt",
        SilentAimDist    = "Maks. avstånd (studs)",
        SilentAimFOV     = "FOV-radie (px)",
        GodMode          = "Gudläge",
        GodModeDesc      = "Återställ HP kontinuerligt — nästan osårbar",
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
        CreditsContent   = "Skapad av Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Första versionen",
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
        SilentAim        = "Silent Aim",
        SilentAimDesc    = "Ανακατεύθυνση πυρών στον πλησιέστερο ύποπτο",
        SilentAimDist    = "Μέγ. απόσταση (studs)",
        SilentAimFOV     = "Ακτίνα FOV (px)",
        GodMode          = "Λειτουργία Θεού",
        GodModeDesc      = "Συνεχής αναπλήρωση HP — σχεδόν άτρωτος",
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
        CreditsContent   = "Δημιουργήθηκε από τον Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Πρώτη έκδοση",
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
        SilentAim        = "Silent Aim",
        SilentAimDesc    = "Redirecționează gloanțele spre cel mai apropiat suspect",
        SilentAimDist    = "Distanță max (studs)",
        SilentAimFOV     = "Raza FOV (px)",
        GodMode          = "Modul Dumnezeu",
        GodModeDesc      = "Restaurare HP continuu — aproape invincibil",
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
        CreditsContent   = "Creat de Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Prima versiune",
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
        SilentAim        = "Silent Aim",
        SilentAimDesc    = "Перенаправляє постріли на найближчого підозрюваного",
        SilentAimDist    = "Макс. дистанція (studs)",
        SilentAimFOV     = "Радіус FOV (px)",
        GodMode          = "Режим Бога",
        GodModeDesc      = "Безперервне відновлення HP — майже невразливий",
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
        CreditsContent   = "Створено Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Перший випуск",
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
        SilentAim        = "Silent Aim",
        SilentAimDesc    = "Přesměrovat střely na nejbližšího podezřelého",
        SilentAimDist    = "Max. vzdálenost (studs)",
        SilentAimFOV     = "Poloměr FOV (px)",
        GodMode          = "Bůh mód",
        GodModeDesc      = "Průběžná obnova HP — téměř nezničitelný",
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
        CreditsContent   = "Vytvořil Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — První verze",
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
        SilentAim        = "Silent Aim",
        SilentAimDesc    = "Omdirigér skud mod nærmeste mistænkte",
        SilentAimDist    = "Maks. afstand (studs)",
        SilentAimFOV     = "FOV-radius (px)",
        GodMode          = "Gudstilstand",
        GodModeDesc      = "Genopret HP kontinuerligt — næsten usårlig",
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
        CreditsContent   = "Oprettet af Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.0.0 — Første udgivelse",
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
    SilentAim       = false,
    SilentAimDist   = 150,   -- studs
    SilentAimFOV    = 80,    -- px on screen
    GodMode         = false,
    ESP             = false,
    Hitbox          = false,
    HitboxSize      = 4,
    InfiniteAmmo    = false,
    FreezeAmmo      = false,
    Fly             = false,
    FlySpeed        = 60,
    NoClip          = false,
    WalkSpeed       = 16,
    JumpPower       = 60,
    AutoArrest      = false,
    AutoArrestDelay = 0.5,
    AntiAFK         = false,
    Fullbright      = false,
}

-- ───────────────────────────────────────────────────────────────
-- LOAD RAYFIELD (keyless)
-- ───────────────────────────────────────────────────────────────
local ok, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)
if not ok or not Rayfield then
    warn("[TacticalSWATHub] Could not load Rayfield UI.")
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
local function isSuspect(model)
    if not model:IsA("Model") then return false end
    local h = model:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then return false end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character == model then return false end
    end
    return true
end

-- Get all live suspects in workspace
local function getAllSuspects()
    local list = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
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

-- WorldToViewportPoint wrapper (returns screenPos, onScreen)
local function worldToScreen(pos)
    local cam = Workspace.CurrentCamera
    local sp, vis = cam:WorldToViewportPoint(pos)
    return Vector2.new(sp.X, sp.Y), vis and sp.Z > 0
end

-- ───────────────────────────────────────────────────────────────
-- FLY (BodyVelocity + BodyGyro, camera-relative + MoveDirection)
-- ───────────────────────────────────────────────────────────────
local flyBV, flyBG
local flyUp, flyDown = false, false   -- toggled by UI buttons

local function enableFly()
    local hrp = getHRP()
    if not hrp then return end
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1e5,1e5,1e5)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent   = hrp
    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(1e5,1e5,1e5)
    flyBG.P         = 1e4
    flyBG.CFrame    = hrp.CFrame
    flyBG.Parent    = hrp
    local h = getHum()
    if h then h.PlatformStand = true end
end

local function disableFly()
    if flyBV then flyBV:Destroy(); flyBV = nil end
    if flyBG then flyBG:Destroy(); flyBG = nil end
    local h = getHum()
    if h then h.PlatformStand = false end
    flyUp, flyDown = false, false
end

-- ───────────────────────────────────────────────────────────────
-- JUMP (works when JumpPower = 0 in-game)
-- ───────────────────────────────────────────────────────────────
local function doJump()
    local hrp = getHRP()
    local hum = getHum()
    if not hrp or not hum then return end
    -- BodyVelocity burst
    local bv = Instance.new("BodyVelocity")
    bv.Velocity  = Vector3.new(0, Settings.JumpPower, 0)
    bv.MaxForce  = Vector3.new(0, 1e6, 0)
    bv.Parent    = hrp
    game:GetService("Debris"):AddItem(bv, 0.25)
    -- also try humanoid jump in case JumpPower was reset
    local orig = hum.JumpPower
    hum.JumpPower = Settings.JumpPower
    hum:ChangeState(Enum.HumanoidStateType.Jumping)
    task.delay(0.15, function() pcall(function() hum.JumpPower = orig end) end)
end

-- PC: E key to jump
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.E then
        doJump()
    end
end)

-- ───────────────────────────────────────────────────────────────
-- FAST RELOAD helper
-- ───────────────────────────────────────────────────────────────
local function doFastReload()
    local char = getChar()
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    -- Reset ammo values in the tool
    for _, v in ipairs(tool:GetDescendants()) do
        if (v:IsA("IntValue") or v:IsA("NumberValue")) then
            local n = v.Name:lower()
            if n:find("ammo") or n:find("mag") or n:find("clip") or n:find("bullet") then
                v.Value = 999
            end
        end
    end
    -- Try firing a reload remote if it exists
    for _, v in ipairs(tool:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            local n = v.Name:lower()
            if n:find("reload") then
                pcall(function() v:FireServer() end)
                break
            end
        end
    end
    Rayfield:Notify({Title = T("FastReload"), Content = "✓", Duration = 1})
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

-- ── TAB COMBAT ──────────────────────────────────────────────────
local TabCombat = Window:CreateTab(T("TabCombat"), 4483362458)

TabCombat:CreateToggle({
    Name         = T("SilentAim"),
    CurrentValue = Settings.SilentAim,
    Flag         = "SilentAim",
    Callback     = function(v) Settings.SilentAim = v end,
})
TabCombat:CreateSlider({
    Name         = T("SilentAimDist"),
    Range        = {20, 500},
    Increment    = 10,
    CurrentValue = Settings.SilentAimDist,
    Flag         = "SilentAimDist",
    Callback     = function(v) Settings.SilentAimDist = v end,
})
TabCombat:CreateSlider({
    Name         = T("SilentAimFOV"),
    Range        = {10, 300},
    Increment    = 5,
    CurrentValue = Settings.SilentAimFOV,
    Flag         = "SilentAimFOV",
    Callback     = function(v) Settings.SilentAimFOV = v end,
})

TabCombat:CreateDivider()

TabCombat:CreateToggle({
    Name         = T("GodMode"),
    CurrentValue = Settings.GodMode,
    Flag         = "GodMode",
    Callback     = function(v) Settings.GodMode = v end,
})

TabCombat:CreateDivider()

TabCombat:CreateToggle({
    Name         = T("ESPEnabled"),
    CurrentValue = Settings.ESP,
    Flag         = "ESP",
    Callback     = function(v) Settings.ESP = v end,
})

TabCombat:CreateDivider()

TabCombat:CreateToggle({
    Name         = T("HitboxToggle"),
    CurrentValue = Settings.Hitbox,
    Flag         = "Hitbox",
    Callback     = function(v)
        Settings.Hitbox = v
        if not v then
            -- restore original sizes
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if isSuspect(obj) then
                    local hrpS = obj:FindFirstChild("HumanoidRootPart")
                    if hrpS then
                        local sv = hrpS:FindFirstChild("_origSzSWAT")
                        if sv then
                            hrpS.Size = sv.Value
                            sv:Destroy()
                            hrpS.Transparency = 1
                        end
                    end
                end
            end
        end
    end,
})
TabCombat:CreateSlider({
    Name         = T("HitboxSize"),
    Range        = {2, 12},
    Increment    = 1,
    CurrentValue = Settings.HitboxSize,
    Flag         = "HitboxSize",
    Callback     = function(v) Settings.HitboxSize = v end,
})

-- ── TAB WEAPONS ─────────────────────────────────────────────────
local TabWeapons = Window:CreateTab(T("TabWeapons"), 4483362458)

TabWeapons:CreateToggle({
    Name         = T("InfiniteAmmo"),
    CurrentValue = Settings.InfiniteAmmo,
    Flag         = "InfiniteAmmo",
    Callback     = function(v) Settings.InfiniteAmmo = v end,
})
TabWeapons:CreateToggle({
    Name         = T("FreezeAmmo"),
    CurrentValue = Settings.FreezeAmmo,
    Flag         = "FreezeAmmo",
    Callback     = function(v) Settings.FreezeAmmo = v end,
})
TabWeapons:CreateButton({
    Name     = T("FastReload"),
    Callback = doFastReload,
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
-- Float Up / Down buttons (work on mobile and PC)
TabMovement:CreateButton({
    Name     = T("FloatUp"),
    Callback = function()
        flyUp   = true
        flyDown = false
        task.delay(0.5, function() flyUp = false end)
    end,
})
TabMovement:CreateButton({
    Name     = T("FloatDown"),
    Callback = function()
        flyDown = true
        flyUp   = false
        task.delay(0.5, function() flyDown = false end)
    end,
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

TabMovement:CreateButton({
    Name     = T("Jump"),
    Callback = doJump,
})
TabMovement:CreateSlider({
    Name         = T("JumpPower"),
    Range        = {20, 200},
    Increment    = 5,
    CurrentValue = Settings.JumpPower,
    Flag         = "JumpPower",
    Callback     = function(v) Settings.JumpPower = v end,
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
        local keywords = {"door","gate","porte","checkpoint","portal","barrier","shutter","vault"}
        for _, obj in ipairs(Workspace:GetDescendants()) do
            local n = obj.Name:lower()
            local match = false
            for _, kw in ipairs(keywords) do
                if n:find(kw) then match = true; break end
            end
            if match then
                if obj:IsA("ProximityPrompt") then
                    pcall(function() fireproximityprompt(obj) end); count=count+1
                elseif obj:IsA("ClickDetector") then
                    pcall(function() fireclickdetector(obj) end); count=count+1
                elseif obj:IsA("RemoteEvent") then
                    pcall(function() obj:FireServer(true) end); count=count+1
                end
            end
        end
        Rayfield:Notify({Title = T("OpenDoors"), Content = count.." interactions", Duration = 2})
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
-- SILENT AIM: state
-- ───────────────────────────────────────────────────────────────
local isWeaponFiring = false

-- Hook all tools the player picks up
local function hookTool(tool)
    tool.Activated:Connect(function()
        isWeaponFiring = true
        task.delay(0.12, function() isWeaponFiring = false end)
    end)
end

local function hookChar(char)
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") then hookTool(t) end
    end
    char.ChildAdded:Connect(function(c)
        if c:IsA("Tool") then hookTool(c) end
    end)
end

if LocalPlayer.Character then hookChar(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(hookChar)

-- ───────────────────────────────────────────────────────────────
-- AUTO ARREST: loop
-- ───────────────────────────────────────────────────────────────
local lastArrestTime = 0
local ARREST_KEYWORDS = {
    "arrest","handcuff","detain","cuff","interact",
    "capture","tackle","subdue","grab","seize"
}

local function tryAutoArrest()
    if not Settings.AutoArrest then return end
    local now = tick()
    if now - lastArrestTime < Settings.AutoArrestDelay then return end
    lastArrestTime = now

    local hrp = getHRP()
    if not hrp then return end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        local n = obj.Name:lower()
        local match = false
        for _, kw in ipairs(ARREST_KEYWORDS) do
            if n:find(kw) then match = true; break end
        end
        if match and obj:IsA("ProximityPrompt") then
            pcall(function() fireproximityprompt(obj) end)
        elseif match and obj:IsA("ClickDetector") then
            pcall(function() fireclickdetector(obj) end)
        elseif match and obj:IsA("RemoteEvent") then
            pcall(function() obj:FireServer() end)
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
RunService.RenderStepped:Connect(function()
    local char = getChar()
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")

    -- ── GOD MODE ──────────────────────────────────────────────
    if Settings.GodMode and hum and hum.Health > 0 then
        hum.Health = hum.MaxHealth
    end

    -- ── NOCLIP ────────────────────────────────────────────────
    if Settings.NoClip then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then
                p.CanCollide = false
            end
        end
    end

    -- ── FLY ───────────────────────────────────────────────────
    if Settings.Fly and flyBV and flyBG and hrp then
        local cam   = Workspace.CurrentCamera
        local speed = Settings.FlySpeed
        -- Horizontal: from MoveDirection (works on PC thumbstick + mobile)
        local md = hum and hum.MoveDirection or Vector3.zero
        local dir = Vector3.new(md.X, 0, md.Z)

        -- Vertical: keyboard (PC) or UI button flags
        local uis = UserInputService
        if uis:IsKeyDown(Enum.KeyCode.Space) or flyUp then
            dir = dir + Vector3.new(0, 1, 0)
        end
        if uis:IsKeyDown(Enum.KeyCode.LeftShift)
        or uis:IsKeyDown(Enum.KeyCode.RightShift)
        or flyDown then
            dir = dir - Vector3.new(0, 1, 0)
        end

        flyBV.Velocity = dir.Magnitude > 0 and dir.Unit * speed or Vector3.zero
        flyBG.CFrame   = cam.CFrame
    end

    -- ── INFINITE / FREEZE AMMO ────────────────────────────────
    if Settings.InfiniteAmmo or Settings.FreezeAmmo then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            for _, v in ipairs(tool:GetDescendants()) do
                if v:IsA("IntValue") or v:IsA("NumberValue") then
                    local n = v.Name:lower()
                    if n:find("ammo") or n:find("mag") or n:find("clip")
                    or n:find("bullet") or n:find("reserve") then
                        v.Value = 999
                    end
                end
            end
        end
    end

    -- ── ESP SUSPECTS ──────────────────────────────────────────
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local alive = isSuspect(obj)

        if Settings.ESP and alive then
            -- Highlight
            if not obj:FindFirstChild("_SWAT_HL") then
                local hl = Instance.new("Highlight")
                hl.Name             = "_SWAT_HL"
                hl.FillColor        = Color3.fromRGB(255, 80, 0)
                hl.OutlineColor     = Color3.fromRGB(255, 255, 0)
                hl.FillTransparency = 0.35
                hl.Parent           = obj
            end
            -- BillboardGui
            local sHRP = obj:FindFirstChild("HumanoidRootPart")
            if sHRP and not sHRP:FindFirstChild("_SWAT_BB") then
                local bb = Instance.new("BillboardGui")
                bb.Name        = "_SWAT_BB"
                bb.Size        = UDim2.new(0, 130, 0, 44)
                bb.StudsOffset = Vector3.new(0, 3.5, 0)
                bb.AlwaysOnTop = true
                bb.Parent      = sHRP
                local lbl = Instance.new("TextLabel")
                lbl.Name                    = "Lbl"
                lbl.Size                    = UDim2.new(1,0,1,0)
                lbl.BackgroundTransparency  = 1
                lbl.TextColor3              = Color3.fromRGB(255, 230, 80)
                lbl.TextStrokeTransparency  = 0
                lbl.TextScaled              = true
                lbl.Font                    = Enum.Font.GothamBold
                lbl.Parent                  = bb
            end
            -- Update HP label
            if sHRP then
                local bb = sHRP:FindFirstChild("_SWAT_BB")
                local sH = obj:FindFirstChildOfClass("Humanoid")
                if bb and sH then
                    local l = bb:FindFirstChild("Lbl")
                    if l then
                        l.Text = string.format("[SUSPECT]\n%s\nHP %d/%d",
                            obj.Name,
                            math.floor(sH.Health),
                            math.floor(sH.MaxHealth))
                    end
                end
            end
        else
            -- Clean up if ESP disabled or model died
            local hl = obj:FindFirstChild("_SWAT_HL")
            if hl then hl:Destroy() end
            local sHRP = obj:FindFirstChild("HumanoidRootPart")
            if sHRP then
                local bb = sHRP:FindFirstChild("_SWAT_BB")
                if bb then bb:Destroy() end
            end
        end

        -- ── HITBOX ────────────────────────────────────────────
        if Settings.Hitbox and alive then
            local sHRP = obj:FindFirstChild("HumanoidRootPart")
            if sHRP then
                if not sHRP:FindFirstChild("_origSzSWAT") then
                    local sv = Instance.new("Vector3Value")
                    sv.Name   = "_origSzSWAT"
                    sv.Value  = sHRP.Size
                    sv.Parent = sHRP
                end
                local sz = Settings.HitboxSize * 2
                sHRP.Size         = Vector3.new(sz, sz, sz)
                sHRP.Transparency = 0.65
                sHRP.CanCollide   = false
            end
        end
    end

    -- ── SILENT AIM ────────────────────────────────────────────
    if Settings.SilentAim and isWeaponFiring and hrp then
        local cam     = Workspace.CurrentCamera
        local vpSize  = cam.ViewportSize
        local center  = Vector2.new(vpSize.X/2, vpSize.Y/2)
        local bestDist, bestHead = math.huge, nil

        for _, obj in ipairs(getAllSuspects()) do
            local head = obj:FindFirstChild("Head")
            if head then
                local dist3D = (head.Position - hrp.Position).Magnitude
                if dist3D <= Settings.SilentAimDist then
                    local sp, onScreen = worldToScreen(head.Position)
                    if onScreen then
                        local d2 = (sp - center).Magnitude
                        if d2 <= Settings.SilentAimFOV and d2 < bestDist then
                            bestDist, bestHead = d2, head
                        end
                    end
                end
            end
        end

        if bestHead then
            -- Redirect camera toward the suspect head
            local lookAt = CFrame.lookAt(cam.CFrame.Position, bestHead.Position)
            cam.CFrame = lookAt
        end
    end

    -- ── WALKSPEED re-apply ─────────────────────────────────────
    if hum and hum.WalkSpeed ~= Settings.WalkSpeed and not Settings.Fly then
        hum.WalkSpeed = Settings.WalkSpeed
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
    hookChar(char)
    if Settings.Fly then
        disableFly()
        task.wait(0.1)
        enableFly()
    end
    local h = char:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed = Settings.WalkSpeed end
end)

-- ───────────────────────────────────────────────────────────────
-- READY
-- ───────────────────────────────────────────────────────────────
Rayfield:Notify({
    Title    = T("WindowTitle"),
    Content  = T("Loaded"),
    Duration = 4,
})

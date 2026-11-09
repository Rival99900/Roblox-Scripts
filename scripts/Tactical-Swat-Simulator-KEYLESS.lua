--[[
    ================================================================
    Tactical SWAT Hub — Tactical: Swat Simulator
    Created by Rival960 with the help of Claude
    Version: 1.1.7 | Languages: 21 | Rayfield UI | PC + Mobile
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
        RapidFireRate    = "Rapid Fire — Fire Rate (RPM)",
        RapidFireRateDesc= "ShootRate sent to ACS. Values above the game's own fire-rate cap may be ignored.",
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
        NoRecoil         = "No Recoil",
        NoRecoilDesc     = "Remove all weapon recoil (ACS API required)",
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
        CreditsContent   = "Created by Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.7 — Weapons tab restored | custom fire rate | live ammo freeze | recoil fields | instant reload | wallbang",
        Loaded           = "Hub loaded! Tactical advantage enabled.",
    },
    FR = {
        RapidFireRate    = "Tir rapide — Cadence (tr/min)",
        RapidFireRateDesc= "ShootRate envoyé à ACS. Les valeurs au-dessus du plafond du jeu peuvent être ignorées.",
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
        NoRecoil         = "Sans recul",
        NoRecoilDesc     = "Supprimer le recul des armes (API ACS requise)",
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
        CreditsContent   = "Créé par Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.7 — gel des munitions réelles | vrais champs de recul | rechargement instantané",
        Loaded           = "Hub chargé ! Avantage tactique activé.",
    },
    DE = {
        RapidFireRate    = "Schnellfeuer — Feuerrate (RPM)",
        RapidFireRateDesc= "An ACS gesendete ShootRate. Werte über der Obergrenze des Spiels werden evtl. ignoriert.",
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
        NoRecoil         = "Kein Rückstoß",
        NoRecoilDesc     = "Waffenrückstoß entfernen (ACS API erforderlich)",
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
        CreditsContent   = "Erstellt von Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.7 — echtes Munitions-Einfrieren | echte Rückstoßfelder | Sofort-Nachladen",
        Loaded           = "Hub geladen! Taktischer Vorteil aktiviert.",
    },
    ES = {
        RapidFireRate    = "Tiro rápido — Cadencia (RPM)",
        RapidFireRateDesc= "ShootRate enviado a ACS. Los valores por encima del límite del juego pueden ignorarse.",
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
        NoRecoil         = "Sin retroceso",
        NoRecoilDesc     = "Eliminar el retroceso del arma (requiere ACS API)",
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
        CreditsContent   = "Creado por Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.7 — congelar munición real | campos de retroceso reales | recarga instantánea",
        Loaded           = "¡Hub cargado! Ventaja táctica activada.",
    },
    PT = {
        RapidFireRate    = "Tiro rápido — Cadência (RPM)",
        RapidFireRateDesc= "ShootRate enviado ao ACS. Valores acima do limite do jogo podem ser ignorados.",
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
        NoRecoil         = "Sem recuo",
        NoRecoilDesc     = "Remover recuo da arma (requer ACS API)",
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
        CreditsContent   = "Criado por Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.7 — congelar munição real | campos de recuo reais | recarga instantânea",
        Loaded           = "Hub carregado! Vantagem tática ativada.",
    },
    RU = {
        RapidFireRate    = "Быстрый огонь — Скорострельность (выстр/мин)",
        RapidFireRateDesc= "ShootRate передаётся в ACS. Значения выше игрового лимита могут игнорироваться.",
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
        NoRecoil         = "Без отдачи",
        NoRecoilDesc     = "Убрать отдачу оружия (требуется ACS API)",
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
        CreditsContent   = "Создано Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.7 — заморозка реальных патронов | реальные поля отдачи | мгновенная перезарядка",
        Loaded           = "Hub загружен! Тактическое преимущество активировано.",
    },
    IT = {
        RapidFireRate    = "Fuoco rapido — Cadenza (RPM)",
        RapidFireRateDesc= "ShootRate inviato ad ACS. I valori oltre il limite del gioco possono essere ignorati.",
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
        NoRecoil         = "Nessun rinculo",
        NoRecoilDesc     = "Rimuovere il rinculo dell'arma (richiede ACS API)",
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
        CreditsContent   = "Creato da Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.7 — blocco munizioni reali | campi rinculo reali | ricarica istantanea",
        Loaded           = "Hub caricato! Vantaggio tattico attivato.",
    },
    NL = {
        RapidFireRate    = "Snelvuur — Vuursnelheid (RPM)",
        RapidFireRateDesc= "ShootRate naar ACS. Waarden boven de limiet van het spel worden mogelijk genegeerd.",
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
        NoRecoil         = "Geen terugslag",
        NoRecoilDesc     = "Wapenrugslag verwijderen (ACS API vereist)",
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
        CreditsContent   = "Gemaakt door Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.7 — echte munitie bevriezen | echte terugslagvelden | direct herladen",
        Loaded           = "Hub geladen! Tactisch voordeel geactiveerd.",
    },
    PL = {
        RapidFireRate    = "Szybki ogień — Szybkostrzelność (RPM)",
        RapidFireRateDesc= "ShootRate wysyłane do ACS. Wartości powyżej limitu gry mogą być ignorowane.",
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
        NoRecoil         = "Brak odrzutu",
        NoRecoilDesc     = "Usuń odrzut broni (wymaga ACS API)",
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
        CreditsContent   = "Stworzone przez Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.7 — blokada realnej amunicji | prawdziwe pola odrzutu | natychmiastowe przeładowanie",
        Loaded           = "Hub załadowany! Taktyczna przewaga aktywowana.",
    },
    ZH = {
        RapidFireRate    = "速射 — 射速 (发/分)",
        RapidFireRateDesc= "ShootRate 会发送给 ACS。高于游戏自身上限的数值可能被忽略。",
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
        NoRecoil         = "无后坐力",
        NoRecoilDesc     = "消除所有武器后坐力（需要 ACS API）",
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
        CreditsContent   = "由 Rival960 创建\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.7 — 真实弹药冻结 | 真实后坐力字段 | 瞬间换弹",
        Loaded           = "Hub已加载！战术优势已激活。",
    },
    JA = {
        RapidFireRate    = "速射 — 発射速度 (RPM)",
        RapidFireRateDesc= "ShootRate を ACS に送信します。ゲーム側の上限を超える値は無視される場合があります。",
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
        NoRecoil         = "リコイルなし",
        NoRecoilDesc     = "武器のリコイルをすべて除去（ACS API が必要）",
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
        CreditsContent   = "Rival960 作\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.7 — 実弾薬の固定 | 実際のリコイル項目 | 即時リロード",
        Loaded           = "Hub読み込み完了！タクティカル優位性が有効化されました。",
    },
    TR = {
        RapidFireRate    = "Hızlı Ateş — Ateş Hızı (RPM)",
        RapidFireRateDesc= "ACS'ye gönderilen ShootRate. Oyunun kendi sınırının üzerindeki değerler yok sayılabilir.",
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
        NoRecoil         = "Geri tepme yok",
        NoRecoilDesc     = "Silah geri tepmesini kaldır (ACS API gerekli)",
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
        CreditsContent   = "Rival960 tarafından\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.7 — gerçek mermi dondurma | gerçek geri tepme alanları | anında şarjör",
        Loaded           = "Hub yüklendi! Taktik avantaj aktif.",
    },
    KO = {
        RapidFireRate    = "연사 — 발사 속도 (RPM)",
        RapidFireRateDesc= "ShootRate가 ACS로 전송됩니다. 게임 자체 한도를 넘는 값은 무시될 수 있습니다.",
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
        NoRecoil         = "무반동",
        NoRecoilDesc     = "모든 무기 반동 제거 (ACS API 필요)",
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
        CreditsContent   = "Rival960 제작\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.7 — 실제 탄약 고정 | 실제 반동 필드 | 즉시 재장전",
        Loaded           = "허브 로드 완료! 전술적 이점 활성화.",
    },
    AR = {
        RapidFireRate    = "إطلاق سريع — معدل الإطلاق (RPM)",
        RapidFireRateDesc= "يُرسل ShootRate إلى ACS. قد يتم تجاهل القيم التي تتجاوز حد اللعبة.",
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
        NoRecoil         = "بدون ارتداد",
        NoRecoilDesc     = "إزالة ارتداد السلاح (يتطلب ACS API)",
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
        CreditsContent   = "أنشأه Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.7 — تجميد الذخيرة الفعلية | حقول الارتداد الحقيقية | إعادة تحميل فورية",
        Loaded           = "تم تحميل الهاب! تم تفعيل الميزة التكتيكية.",
    },
    VI = {
        RapidFireRate    = "Bắn nhanh — Tốc độ bắn (RPM)",
        RapidFireRateDesc= "ShootRate được gửi tới ACS. Giá trị vượt giới hạn của game có thể bị bỏ qua.",
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
        NoRecoil         = "Không giật",
        NoRecoilDesc     = "Loại bỏ độ giật súng (yêu cầu ACS API)",
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
        CreditsContent   = "Tạo bởi Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.7 — đóng băng đạn thật | trường giật thật | nạp đạn tức thì",
        Loaded           = "Hub đã tải! Lợi thế chiến thuật được kích hoạt.",
    },
    SV = {
        RapidFireRate    = "Snabbeld — Eldhastighet (RPM)",
        RapidFireRateDesc= "ShootRate skickas till ACS. Värden över spelets egen gräns kan ignoreras.",
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
        NoRecoil         = "Inget rekyl",
        NoRecoilDesc     = "Ta bort vapenrekyl (ACS API krävs)",
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
        CreditsContent   = "Skapad av Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.7 — frys riktig ammunition | riktiga rekylfält | omedelbar omladdning",
        Loaded           = "Hub laddad! Taktisk fördel aktiverad.",
    },
    EL = {
        RapidFireRate    = "Γρήγορο πυρ — Ρυθμός βολής (RPM)",
        RapidFireRateDesc= "Το ShootRate στέλνεται στο ACS. Τιμές πάνω από το όριο του παιχνιδιού μπορεί να αγνοηθούν.",
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
        NoRecoil         = "Χωρίς αντίδραση",
        NoRecoilDesc     = "Αφαίρεση αντίδρασης όπλου (απαιτείται ACS API)",
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
        CreditsContent   = "Δημιουργήθηκε από τον Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.7 — πάγωμα πραγματικών πυρομαχικών | πραγματικά πεδία ανάκρουσης | άμεση επαναφόρτωση",
        Loaded           = "Hub φορτώθηκε! Τακτικό πλεονέκτημα ενεργοποιήθηκε.",
    },
    RO = {
        RapidFireRate    = "Foc rapid — Cadență (RPM)",
        RapidFireRateDesc= "ShootRate este trimis către ACS. Valorile peste limita jocului pot fi ignorate.",
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
        NoRecoil         = "Fără recul",
        NoRecoilDesc     = "Elimina reculul armei (necesită ACS API)",
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
        CreditsContent   = "Creat de Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.7 — înghețare muniție reală | câmpuri reale de recul | reîncărcare instantanée",
        Loaded           = "Hub încărcat! Avantaj tactic activat.",
    },
    UK = {
        RapidFireRate    = "Швидкий вогонь — Швидкострільність (постр/хв)",
        RapidFireRateDesc= "ShootRate передається в ACS. Значення вище ігрового ліміту можуть ігноруватися.",
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
        NoRecoil         = "Без віддачі",
        NoRecoilDesc     = "Прибрати віддачу зброї (потрібен ACS API)",
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
        CreditsContent   = "Створено Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.7 — заморозка реальних патронів | реальні поля віддачі | миттєва перезарядка",
        Loaded           = "Hub завантажено! Тактичну перевагу активовано.",
    },
    CS = {
        RapidFireRate    = "Rychlá palba — Kadence (RPM)",
        RapidFireRateDesc= "ShootRate se odesílá do ACS. Hodnoty nad limitem hry mohou být ignorovány.",
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
        NoRecoil         = "Bez zpětného rázu",
        NoRecoilDesc     = "Odstraň zpětný ráz zbraně (vyžaduje ACS API)",
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
        CreditsContent   = "Vytvořil Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.7 — zmrazení skutečné munice | skutečná pole zpětného rázu | okamžité přebití",
        Loaded           = "Hub načten! Taktická výhoda aktivována.",
    },
    DA = {
        RapidFireRate    = "Hurtigskyd — Skudhastighed (RPM)",
        RapidFireRateDesc= "ShootRate sendes til ACS. Værdier over spillets egen grænse kan blive ignoreret.",
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
        NoRecoil         = "Ingen rekyl",
        NoRecoilDesc     = "Fjern våbenrekyl (kræver ACS API)",
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
        CreditsContent   = "Oprettet af Rival960\nDiscord: rival960\nGitHub: Rival99900\nYouTube: rival9607\n\nv1.1.7 — frys rigtig ammunition | rigtige rekylfelter | øjeblikkelig genladning",
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
    RapidFireRate   = 1200,
    Wallbang        = false,
    NoRecoil        = false,
    _freezeTargets  = nil,
    _origRecoil     = nil,
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
-- ACS INFRASTRUCTURE
-- Resolver and write paths restored from v1.1.5 — the build where
-- Infinite Ammo and Rapid Fire were confirmed working in game.
-- v1.1.6 replaced this with a global closure scan that ran again on
-- every tool change, which is what killed the whole Weapons tab, so
-- the rule here is: ONE global scan at most, then cache it, and every
-- per-tick path only touches the already-cached table.
-- ───────────────────────────────────────────────────────────────
local _acsCache    = {func=nil, idx=nil, tbl=nil, origin=nil, toolKey=nil}
local _nonLethalUV = nil
local _acsEvents   = nil   -- Events folder that holds the Reload remote

-- Saved originals so every toggle restores the exact ACS values.
local _savedRecoil = {}    -- [tbl][key] = number | {min,max}
local _savedDamage = {}    -- [tbl][key] = number | boolean | {min,max}
local _savedShoot  = {}    -- [tbl]     = original ShootRate

local function _isNum(v)
    return type(v) == "number" and v == v and v ~= math.huge and v ~= -math.huge
end

local function _isNumPair(v)
    return type(v) == "table" and _isNum(v[1]) and _isNum(v[2])
end

local function getEquippedTool()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Tool") or nil
end

local function _saveInto(store, tbl, key)
    if type(tbl) ~= "table" then return end
    local bucket = store[tbl]
    if not bucket then bucket = {}; store[tbl] = bucket end
    if bucket[key] ~= nil then return end
    local v = tbl[key]
    if type(v) == "table" then
        bucket[key] = {v[1], v[2]}
    else
        bucket[key] = v
    end
end

-- Push the mutated table back into the closure upvalue so ACS reads it.
-- Harmless when the table came from a ModuleScript (func is nil).
local function _writeCfg(cfg)
    if type(cfg) ~= "table" then return false end
    -- Only the table the cached upvalue actually holds may be pushed back:
    -- setupvalue() with a ModuleScript table would overwrite the ACS
    -- config upvalue with the wrong table. Module tables need no write.
    if cfg ~= _acsCache.tbl then return false end
    local f, i = _acsCache.func, _acsCache.idx
    if f and i and debug and debug.setupvalue then
        pcall(debug.setupvalue, f, i, cfg)
    end
    return true
end

local function _restoreStore(store)
    local n = 0
    for tbl, bucket in pairs(store) do
        if type(tbl) == "table" then
            for key, orig in pairs(bucket) do
                if type(orig) == "table" then
                    local cur = tbl[key]
                    if type(cur) == "table" then
                        cur[1] = orig[1]; cur[2] = orig[2]
                    else
                        tbl[key] = {orig[1], orig[2]}
                    end
                else
                    tbl[key] = orig
                end
                n = n + 1
            end
            _writeCfg(tbl)
        end
    end
    for k in pairs(store) do store[k] = nil end
    return n
end

-- Per-weapon ModuleScripts (ACS keeps Settings/Config here on some
-- versions). require() returns the same table ACS already cached, and
-- it is cached per tool here so it costs one walk per equip.
local _modCache = {tool=nil, list=nil}
local function getToolSettingsTables()
    local tool = getEquippedTool()
    if not tool then return {} end
    if _modCache.tool == tool and _modCache.list then return _modCache.list end
    local list = {}
    local ok, desc = pcall(function() return tool:GetDescendants() end)
    if ok and desc then
        for _, d in ipairs(desc) do
            if d:IsA("ModuleScript") then
                local n = d.Name
                if n == "Settings" or n == "Config" or n == "GunSettings"
                    or n == "WeaponSettings" or n == "WeaponConfig" then
                    local okR, mod = pcall(require, d)
                    if okR and type(mod) == "table" then list[#list+1] = mod end
                end
            end
        end
    end
    _modCache = {tool=tool, list=list}
    return list
end

-- Scan upvalues of f (and one level of function upvalues) for ACS config.
-- Same criteria as v1.1.5: a table carrying ShootRate + BulletPenetration.
local function _matchACS(f)
    if type(f) ~= "function" then return false end
    if not (debug and debug.getupvalue) then return false end
    -- Direct upvalue scan
    for i = 1, 35 do
        local ok, uv = pcall(debug.getupvalue, f, i)
        if ok and type(uv) == "table"
            and rawget(uv, "ShootRate") ~= nil
            and rawget(uv, "BulletPenetration") ~= nil then
            _acsCache = {func=f, idx=i, tbl=uv, origin="closure", toolKey=""}
            local ok9, uv9 = pcall(debug.getupvalue, f, 9)
            if ok9 and type(uv9) == "table" then _nonLethalUV = uv9 end
            return true
        end
    end
    -- One level of recursion: scan function-type upvalues
    for i = 1, 35 do
        local ok, uv = pcall(debug.getupvalue, f, i)
        if ok and type(uv) == "function" then
            for j = 1, 35 do
                local ok3, uv3 = pcall(debug.getupvalue, uv, j)
                if ok3 and type(uv3) == "table"
                    and rawget(uv3, "ShootRate") ~= nil
                    and rawget(uv3, "BulletPenetration") ~= nil then
                    _acsCache = {func=uv, idx=j, tbl=uv3, origin="closure", toolKey=""}
                    local ok9, uv9 = pcall(debug.getupvalue, uv, 9)
                    if ok9 and type(uv9) == "table" then _nonLethalUV = uv9 end
                    return true
                end
            end
        end
    end
    return false
end

local function getACSConfig()
    -- A resolution coming from a per-weapon ModuleScript is dropped when
    -- the equipped weapon changes. A resolution coming from a closure is
    -- kept, exactly like v1.1.5: re-scanning getgc() on every equip is
    -- what froze the client.
    local tool = getEquippedTool()
    local tk = tool and tool.Name or ""
    if _acsCache.tbl and _acsCache.origin == "module" and tk ~= _acsCache.toolKey then
        _acsCache = {func=nil, idx=nil, tbl=nil, origin=nil, toolKey=nil}
    end
    if _acsCache.tbl then return _acsCache.func, _acsCache.idx, _acsCache.tbl end
    if not (debug and debug.getupvalue) then return nil end

    -- METHOD A: getgc() — scan all live Lua closures (Volt/Delta/Real/Fluxus)
    if getgc then
        local ok, objs = pcall(getgc, true)
        if ok and objs then
            for _, obj in ipairs(objs) do
                if type(obj) == "function" then
                    if _matchACS(obj) then
                        print("[Hub] ACS config resolved (closure)")
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
                        print("[Hub] ACS config resolved (scriptclosures)")
                        return _acsCache.func, _acsCache.idx, _acsCache.tbl
                    end
                end
            end
        end
    end

    -- METHOD C: getconnections on known events (fallback)
    if getconnections then
        local char2 = LocalPlayer.Character
        local tool2 = char2 and char2:FindFirstChildOfClass("Tool")
        local evs   = {}
        if tool2 then evs[#evs+1] = tool2.Activated end
        local ok2, mouse = pcall(function() return LocalPlayer:GetMouse() end)
        if ok2 and mouse then evs[#evs+1] = mouse.Button1Down end
        evs[#evs+1] = UserInputService.InputBegan
        for _, ev in ipairs(evs) do
            local ok3, conns = pcall(getconnections, ev)
            if ok3 and conns then
                for _, conn in ipairs(conns) do
                    local f; pcall(function() f = conn.Function end)
                    if _matchACS(f) then
                        print("[Hub] ACS config resolved (connection)")
                        return _acsCache.func, _acsCache.idx, _acsCache.tbl
                    end
                end
            end
        end
    end

    -- METHOD D: the equipped tool's own Settings ModuleScript
    for _, t in ipairs(getToolSettingsTables()) do
        if rawget(t, "ShootRate") ~= nil and rawget(t, "BulletPenetration") ~= nil then
            _acsCache = {func=nil, idx=nil, tbl=t, origin="module", toolKey=tk}
            print("[Hub] ACS config resolved (tool module)")
            return nil, nil, t
        end
    end

    return nil
end

local function setACSValue(key, value)
    local f, i, cfg = getACSConfig()
    if not f or not cfg then return false end
    return pcall(function()
        cfg[key] = value
        if debug and debug.setupvalue then debug.setupvalue(f, i, cfg) end
    end)
end

-- Events folder is found by name once and then cached: never by a fixed
-- upvalue index, which changes when ACS rebuilds its closures.
local function getEventsFolder()
    if _acsEvents and _acsEvents.Parent then return _acsEvents end
    _acsEvents = nil
    local found
    pcall(function()
        local n = 0
        for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
            n = n + 1
            if n > 1500 then break end
            if (d.Name == "Events" or d.Name == "Eventos")
                and d:FindFirstChild("Reload") then
                found = d
                break
            end
        end
    end)
    _acsEvents = found
    return found
end

-- Non-lethal check: returns true if the equipped tool should not receive
-- damage/fire-rate overrides (Candy Zapper, Taser, Beanbag Shotgun).
-- Uses _nonLethalUV (upvalue [9]) cached alongside the config.
local function isNonLethal()
    local tool = getEquippedTool()
    if not tool then return false end
    local name = tool.Name
    local NL = {["Candy Zapper"]=true, ["Taser"]=true, ["Beanbag Shotgun"]=true}
    if NL[name] then return true end
    if _nonLethalUV and _nonLethalUV[name] then return true end
    return false
end

-- ───────────────────────────────────────────────────────────────
-- LIVE AMMO COUNTERS
-- The settings table is not the only place ammo lives: the equipped
-- tool can also carry ValueBase counters. Both are resolved here, and
-- only for the EQUIPPED tool so stowed weapons are left alone.
-- ───────────────────────────────────────────────────────────────
local _AMMO_NAMES = {
    Ammo=true, AmmoInGun=true, AmmoInMag=true, CurrentAmmo=true,
    Magazine=true, Clip=true, StoredAmmo=true, ReserveAmmo=true, AmmoReserve=true,
}
local _RESERVE_NAMES = {StoredAmmo=true, ReserveAmmo=true, AmmoReserve=true}
local _CAP_NAMES     = {MaxAmmo=true, MagSize=true, MagazineSize=true}

local function getToolValueObjects(names)
    local out = {}
    local tool = getEquippedTool()
    if not tool then return out end
    local ok, desc = pcall(function() return tool:GetDescendants() end)
    if ok and desc then
        for _, d in ipairs(desc) do
            if d:IsA("ValueBase") and names[d.Name] and _isNum(d.Value) then
                out[#out+1] = d
            end
        end
    end
    return out
end

local function getMagCapacity(cfg)
    local cap
    for _, obj in ipairs(getToolValueObjects(_CAP_NAMES)) do
        if _isNum(obj.Value) and obj.Value >= 1 then cap = obj.Value; break end
    end
    if not cap and type(cfg) == "table" then
        if _isNum(rawget(cfg, "MagSize")) then cap = cfg.MagSize
        elseif _isNum(rawget(cfg, "Ammo")) then cap = cfg.Ammo end
    end
    if not cap then
        local tool = getEquippedTool()
        if tool then
            local ok, attr = pcall(function() return tool:GetAttribute("Ammo") end)
            if ok and _isNum(attr) and attr >= 1 then cap = attr end
        end
    end
    if not cap or cap < 1 then cap = 30 end
    if cap > 999 then cap = 999 end
    return math.floor(cap)
end

-- ───────────────────────────────────────────────────────────────
-- RAPID FIRE — per-weapon ShootRate with restore
-- ───────────────────────────────────────────────────────────────
local function applyShootRate(rate)
    local f, i, cfg = getACSConfig()
    if not cfg then return false end
    if not _isNum(rate) then rate = 1200 end
    if _savedShoot[cfg] == nil then
        _savedShoot[cfg] = _isNum(rawget(cfg, "ShootRate")) and cfg.ShootRate or 750
    end
    cfg.ShootRate = rate
    _writeCfg(cfg)
    return true
end

local function restoreShootRate()
    local n = 0
    for cfg, orig in pairs(_savedShoot) do
        if type(cfg) == "table" and _isNum(orig) then
            cfg.ShootRate = orig
            _writeCfg(cfg)
            n = n + 1
        end
    end
    _savedShoot = {}
    return n
end

-- ───────────────────────────────────────────────────────────────
-- NO RECOIL — zero every recoil-ish field of the cached tables
-- ───────────────────────────────────────────────────────────────
local _RECOIL_HINTS = {"recoil", "punch", "camshake", "impact"}

local function _keyMatches(key, hints)
    if type(key) ~= "string" then return false end
    local k = string.lower(key)
    if string.find(k, "reduction", 1, true) or string.find(k, "mult", 1, true) then
        return false   -- multipliers/reductions: zeroing them would invert the effect
    end
    for i = 1, #hints do
        if string.find(k, hints[i], 1, true) then return true end
    end
    return false
end

local function _zeroRecoilOn(tbl, count)
    if type(tbl) ~= "table" then return count end
    for key, v in pairs(tbl) do
        if _keyMatches(key, _RECOIL_HINTS) then
            if _isNum(v) and v ~= 0 then
                _saveInto(_savedRecoil, tbl, key)
                tbl[key] = 0
                count = count + 1
            elseif _isNumPair(v) and (v[1] ~= 0 or v[2] ~= 0) then
                _saveInto(_savedRecoil, tbl, key)
                v[1], v[2] = 0, 0
                count = count + 1
            end
        end
    end
    return count
end

local function applyNoRecoil()
    local f, i, cfg = getACSConfig()
    local n = 0
    if cfg then
        n = _zeroRecoilOn(cfg, n)
        if type(cfg.__MagBase) == "table" then n = _zeroRecoilOn(cfg.__MagBase, n) end
        _writeCfg(cfg)
    end
    for _, t in ipairs(getToolSettingsTables()) do
        n = _zeroRecoilOn(t, n)
    end
    return n
end

local function restoreNoRecoil()
    return _restoreStore(_savedRecoil)
end

-- ───────────────────────────────────────────────────────────────
-- WALLBANG + ONE SHOT — max penetration, max damage, ignore armour
-- ───────────────────────────────────────────────────────────────
local _DAMAGE_HINTS = {"damage", "dano", "dmg"}
local _PIERCE_HINTS = {"penetration", "pierce"}

local function _boostWallbangOn(tbl, count)
    if type(tbl) ~= "table" then return count end
    for key, v in pairs(tbl) do
        if type(key) == "string" then
            local k = string.lower(key)
            if _keyMatches(key, _PIERCE_HINTS) then
                if _isNum(v) and v < 100 then
                    _saveInto(_savedDamage, tbl, key)
                    tbl[key] = 100
                    count = count + 1
                end
            elseif k == "ignoreprotection" or k == "ignorearmor"
                or k == "ignoreresistance" or k == "ignorevest" then
                if v ~= true then
                    _saveInto(_savedDamage, tbl, key)
                    tbl[key] = true
                    count = count + 1
                end
            elseif _keyMatches(key, _DAMAGE_HINTS) then
                if _isNum(v) and v < 9999 then
                    _saveInto(_savedDamage, tbl, key)
                    tbl[key] = 9999
                    count = count + 1
                elseif _isNumPair(v) and (v[1] < 9999 or v[2] < 9999) then
                    _saveInto(_savedDamage, tbl, key)
                    v[1], v[2] = 9999, 9999
                    count = count + 1
                end
            end
        end
    end
    return count
end

local function applyWallbangStats()
    local f, i, cfg = getACSConfig()
    local n = 0
    if cfg then
        n = _boostWallbangOn(cfg, n)
        _writeCfg(cfg)
    end
    for _, t in ipairs(getToolSettingsTables()) do
        n = _boostWallbangOn(t, n)
    end
    return n
end

local function restoreWallbangStats()
    return _restoreStore(_savedDamage)
end

-- ───────────────────────────────────────────────────────────────
-- FAST RELOAD — refill the real magazine and fire the Reload remote
-- ───────────────────────────────────────────────────────────────
local function fastReload()
    local f, i, cfg = getACSConfig()
    local changed, cap = 0, getMagCapacity(cfg)
    if cfg then
        cfg.Ammo       = cap
        cfg.AmmoInGun  = cap
        cfg.StoredAmmo = math.huge
        pcall(function() cfg.Jammed = false end)
        pcall(function() cfg.Emperrado = false end)
        if type(cfg.__MagBase) == "table" then
            cfg.__MagBase.Ammo      = cap
            cfg.__MagBase.AmmoInGun = cap
        end
        _writeCfg(cfg)
        changed = changed + 1
    end
    -- ValueBase counters carried by the equipped tool
    for _, obj in ipairs(getToolValueObjects(_AMMO_NAMES)) do
        local target = _RESERVE_NAMES[obj.Name] and 99999 or cap
        if obj.Value ~= target then
            local ok = pcall(function() obj.Value = target end)
            if ok then changed = changed + 1 end
        end
    end
    -- ACS reload remote, resolved by child name
    local remoteState = "none"
    local folder = getEventsFolder()
    if folder then
        local reload = folder:FindFirstChild("Reload")
        if reload then
            local okFire = pcall(function() reload:FireServer() end)
            remoteState = okFire and "fired" or "error"
        else
            remoteState = "missing"
        end
    end
    return changed, cap, remoteState
end

-- ───────────────────────────────────────────────────────────────
-- FREEZE AMMO — hold every live ammo counter at its current value
-- ───────────────────────────────────────────────────────────────
local _freezeTargets = nil
local _freezeConn    = nil

local function buildFreezeTargets()
    local out = {tool = getEquippedTool()}
    for _, obj in ipairs(getToolValueObjects(_AMMO_NAMES)) do
        if _isNum(obj.Value) then
            out[#out+1] = {obj = obj, value = obj.Value}
        end
    end
    local f, i, cfg = getACSConfig()
    if cfg then
        for name in pairs(_AMMO_NAMES) do
            local v = rawget(cfg, name)
            if _isNum(v) then out[#out+1] = {tbl = cfg, key = name, value = v} end
        end
        if type(cfg.__MagBase) == "table" then
            for name in pairs(_AMMO_NAMES) do
                local v = rawget(cfg.__MagBase, name)
                if _isNum(v) then
                    out[#out+1] = {tbl = cfg.__MagBase, key = name, value = v}
                end
            end
        end
    end
    return out
end

local function freezeTick()
    local t = _freezeTargets
    if type(t) ~= "table" then
        -- Targets were dropped (respawn) while the toggle is still ON:
        -- rebuild them instead of silently stopping the freeze.
        if not Settings.FreezeAmmo then return end
        _freezeTargets = buildFreezeTargets()
        t = _freezeTargets
        if type(t) ~= "table" then return end
    end
    if t.tool ~= getEquippedTool() then
        _freezeTargets = buildFreezeTargets()
        t = _freezeTargets
        if type(t) ~= "table" then return end
    end
    local dirty = nil
    for k = 1, #t do
        local e = t[k]
        if e.obj then
            if e.obj.Parent and e.obj.Value ~= e.value then
                pcall(function() e.obj.Value = e.value end)
            end
        elseif e.tbl then
            if e.tbl[e.key] ~= e.value then
                e.tbl[e.key] = e.value
                dirty = e.tbl
            end
        end
    end
    if dirty then _writeCfg(dirty) end
end

-- ───────────────────────────────────────────────────────────────
-- CACHE INVALIDATION / FULL RESTORE
-- Called on respawn and script unload only. Never on tool change:
-- that is what turned every equip into a full getgc() sweep.
-- ───────────────────────────────────────────────────────────────
local function invalidateACSState()
    _acsCache  = {func=nil, idx=nil, tbl=nil, origin=nil, toolKey=nil}
    _nonLethalUV = nil
    _acsEvents   = nil
    _modCache    = {tool=nil, list=nil}
    _freezeTargets = nil
end

local function restoreAllACS()
    Settings.FreezeAmmo = false
    Settings.RapidFire  = false
    Settings.NoRecoil   = false
    Settings.Wallbang   = false

    if _freezeConn then
        _freezeConn:Disconnect()
        _freezeConn = nil
    end
    _freezeTargets = nil

    restoreShootRate()
    restoreNoRecoil()
    restoreWallbangStats()
end

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

-- a) Infinite Ammo — proven path from v1.1.5, do not change the shape
TabWeapons:CreateToggle({
    Name         = T("InfiniteAmmo"),
    CurrentValue = Settings.InfiniteAmmo,
    Flag         = "InfiniteAmmo",
    Callback     = function(v)
        Settings.InfiniteAmmo = v
        if v then
            task.spawn(function()
                while Settings.InfiniteAmmo do
                    local f, i, cfg = getACSConfig()
                    if cfg then
                        cfg.Ammo       = 99999
                        cfg.AmmoInGun  = 99999
                        cfg.StoredAmmo = math.huge
                        if type(cfg.__MagBase) == "table" then
                            cfg.__MagBase.Ammo      = 999
                            cfg.__MagBase.AmmoInGun = 999
                        end
                        if f and debug and debug.setupvalue then
                            pcall(debug.setupvalue, f, i, cfg)
                        end
                    else
                        Rayfield:Notify({Title="Weapons", Content="Fire your weapon once to activate", Duration=4})
                        Settings.InfiniteAmmo = false
                        break
                    end
                    task.wait(0.3)
                end
            end)
        end
    end,
})

-- b) Freeze Ammo — holds the live counters at the value they had on ON
TabWeapons:CreateToggle({
    Name         = T("FreezeAmmo"),
    Description  = T("FreezeAmmoDesc"),
    CurrentValue = Settings.FreezeAmmo,
    Flag         = "FreezeAmmo",
    Callback     = function(v)
        Settings.FreezeAmmo = v
        if v then
            local okB, n = pcall(function()
                _freezeTargets = buildFreezeTargets()
                return #_freezeTargets
            end)
            if not okB then n = 0 end
            if _freezeConn then
                _freezeConn:Disconnect()
                _freezeConn = nil
            end
            -- Heartbeat, not a 0.1s loop: ACS decrements ammo per shot,
            -- so the counter has to be put back before the next frame.
            _freezeConn = RunService.Heartbeat:Connect(freezeTick)
            print(string.format("[Hub] Freeze Ammo: holding %d live counter(s)", n))
            if n == 0 then
                warn("[Hub] Freeze Ammo: no live counter resolved — equip a weapon and fire once")
                Rayfield:Notify({Title=T("FreezeAmmo"), Content="Fire your weapon once to activate", Duration=3})
            end
        else
            if _freezeConn then
                _freezeConn:Disconnect()
                _freezeConn = nil
            end
            _freezeTargets = nil
        end
    end,
})

TabWeapons:CreateDivider()

-- c) Fast Reload (one-shot button)
TabWeapons:CreateButton({
    Name     = T("FastReload"),
    Callback = function()
        local okF, changed, cap, remoteState = pcall(fastReload)
        if not okF then
            warn("[Hub] Fast Reload failed: " .. tostring(changed))
            Rayfield:Notify({Title = T("FastReload"), Content = "Reload failed — see console", Duration = 3})
            return
        end
        changed     = changed or 0
        cap         = cap or 0
        remoteState = remoteState or "none"
        print(string.format("[Hub] Fast Reload: %d counter(s) refilled to %d, remote=%s",
            changed, cap, remoteState))
        if changed > 0 or remoteState ~= "none" then
            Rayfield:Notify({Title = T("FastReload"), Content = "✓ Reloaded!", Duration = 2})
        else
            warn("[Hub] Fast Reload: no live counter and no Events.Reload remote")
            Rayfield:Notify({Title = T("FastReload"), Content = "Fire your weapon once to activate", Duration = 3})
        end
    end,
})

TabWeapons:CreateDivider()

-- d) Rapid Fire — rate is user-editable, slider just below
TabWeapons:CreateToggle({
    Name         = T("RapidFire"),
    Description  = T("RapidFireDesc"),
    CurrentValue = Settings.RapidFire,
    Flag         = "RapidFire",
    Callback     = function(v)
        Settings.RapidFire = v
        if v then
            task.spawn(function()
                local warned = false
                while Settings.RapidFire do
                    if not isNonLethal() then
                        local okA, applied = pcall(applyShootRate, Settings.RapidFireRate)
                        if not okA then applied = false end
                        if not applied then
                            if not warned then
                                warned = true
                                warn("[Hub] Rapid Fire: ACS config not resolved — equip a weapon and fire once")
                                Rayfield:Notify({Title="Weapons", Content="Fire your weapon once to activate", Duration=4})
                            end
                            Settings.RapidFire = false
                            break
                        end
                    end
                    task.wait(0.3)
                end
                restoreShootRate()
            end)
        else
            restoreShootRate()
        end
    end,
})

TabWeapons:CreateSlider({
    Name         = T("RapidFireRate"),
    Description  = T("RapidFireRateDesc"),
    Range        = {100, 3000},
    Increment    = 50,
    CurrentValue = Settings.RapidFireRate,
    Flag         = "RapidFireRate",
    Callback     = function(v)
        Settings.RapidFireRate = v
        -- Apply instantly while Rapid Fire is ON
        if Settings.RapidFire and not isNonLethal() then
            pcall(applyShootRate, v)
        end
    end,
})

TabWeapons:CreateDivider()

-- e) Wallbang + One Shot
TabWeapons:CreateToggle({
    Name         = T("Wallbang"),
    Description  = T("WallbangDesc"),
    CurrentValue = Settings.Wallbang,
    Flag         = "Wallbang",
    Callback     = function(v)
        Settings.Wallbang = v
        if v then
            task.spawn(function()
                local warned, lastCount = false, -1
                while Settings.Wallbang do
                    if not isNonLethal() then
                        local okW, entries = pcall(applyWallbangStats)
                        if not okW then entries = 0 end
                        if entries ~= lastCount then
                            lastCount = entries
                            print(string.format("[Hub] Wallbang: %d damage/penetration field(s) boosted", entries))
                        end
                        if entries == 0 and not warned then
                            warned = true
                            warn("[Hub] Wallbang: no damage field found in the ACS tables")
                            Rayfield:Notify({Title="Weapons", Content="Fire your weapon once to activate", Duration=4})
                        end

                        -- Direct suspect kill pass (client-side only: server-owned
                        -- NPCs may ignore it, this is a best-effort extra)
                        for _, obj in ipairs(Workspace:GetChildren()) do
                            if isSuspect(obj) then
                                local hum = obj:FindFirstChildOfClass("Humanoid")
                                if hum and hum.Health > 0 then
                                    pcall(function() hum.Health = 0 end)
                                end
                            end
                        end
                    end
                    task.wait(0.3)
                end
                restoreWallbangStats()
            end)
        else
            restoreWallbangStats()
        end
    end,
})

-- f) NoRecoil toggle
TabWeapons:CreateToggle({
    Name         = T("NoRecoil"),
    Description  = T("NoRecoilDesc"),
    CurrentValue = Settings.NoRecoil,
    Flag         = "NoRecoil",
    Callback     = function(v)
        Settings.NoRecoil = v
        if v then
            task.spawn(function()
                local lastCount = -1
                while Settings.NoRecoil do
                    local okN, entries = pcall(applyNoRecoil)
                    if not okN then entries = 0 end
                    if entries ~= lastCount then
                        lastCount = entries
                        print(string.format("[Hub] No Recoil: neutralising %d recoil field(s)", entries))
                        if entries == 0 then
                            warn("[Hub] No Recoil: no recoil field found in the ACS tables")
                        end
                    end
                    task.wait(0.2)
                end
                restoreNoRecoil()
            end)
        else
            restoreNoRecoil()
        end
    end,
})

-- g) Wall Check (one-shot raycast button)
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
                        local dir = (sHRP.Position - myHRP.Position)
                        local okR, result = pcall(function()
                            return Workspace:Raycast(myHRP.Position, dir, params)
                        end)
                        if not okR then result = nil end
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
        pcall(function()
            hum.JumpPower  = Settings.JumpPower
            hum.JumpHeight = Settings.JumpPower * 0.14
        end)
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

    -- ── INFINITE JUMP sustain — re-jump while Space is held mid-air ──
    if Settings.InfJump then
        local hInfJ = getHum()
        if hInfJ then
            local _, held = pcall(function()
                return UserInputService:IsKeyDown(Enum.KeyCode.Space)
            end)
            if held then
                pcall(function() hInfJ.JumpPower  = Settings.JumpPower end)
                pcall(function() hInfJ.JumpHeight = Settings.JumpPower * 0.14 end)
                local st = hInfJ:GetState()
                if st == Enum.HumanoidStateType.Freefall
                    or st == Enum.HumanoidStateType.Jumping then
                    hInfJ:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end
    end
end)

-- ───────────────────────────────────────────────────────────────
-- INFINITE JUMP — global JumpRequest connection
-- ───────────────────────────────────────────────────────────────
UserInputService.JumpRequest:Connect(function()
    if not Settings.InfJump then return end
    local h = getHum()
    if not h then return end
    pcall(function() h.JumpPower  = Settings.JumpPower end)
    pcall(function() h.JumpHeight = Settings.JumpPower * 0.14 end)
    h:ChangeState(Enum.HumanoidStateType.Jumping)
end)

-- ───────────────────────────────────────────────────────────────
-- ON RESPAWN
-- ACS rebuilds its closures on respawn, so the cache is dropped there.
-- NOT on every tool change: v1.1.6 invalidated on equip, which forced a
-- full getgc() sweep each time a weapon was drawn and froze the client.
-- ───────────────────────────────────────────────────────────────
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    invalidateACSState()
    createOverlayUI()  -- rebuild overlay buttons after respawn
    if Settings.Fly then
        disableFly()
        task.wait(0.1)
        enableFly()
    end
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

-- ───────────────────────────────────────────────────────────────
-- UNLOAD SAFETY — restore every modified ACS value
-- (toggling OFF already restores; this covers teleports/closing and
--  exposes a manual cleanup for executor unload hooks)
-- ───────────────────────────────────────────────────────────────
pcall(function()
    LocalPlayer.OnTeleport:Connect(function() restoreAllACS() end)
end)
pcall(function()
    game:BindToClose(function() restoreAllACS() end)
end)
if getgenv then
    pcall(function() getgenv().TacticalSwatHub_Restore = restoreAllACS end)
end

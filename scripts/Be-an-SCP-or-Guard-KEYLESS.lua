--[[
    ================================================================
    ADMIN PANEL — Be an SCP or Guard (Fully Fixed & Expanded)
    Created by Rival960 with the help of AI
    Languages: 21 Languages | Rayfield UI
    ================================================================
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

-- -----------------------------------------------------------------
-- 1. MULTILINGUAL SYSTEMS (21 LANGUAGES)
-- -----------------------------------------------------------------
local CurrentLang = "EN"

local Translations = {
    EN = {
        WindowTitle = "SCP vs Guard Hub",
        TabHome = "Home",
        TabVision = "Vision & ESP",
        TabMovement = "Movement & Fly",
        TabCombat = "Combat & Silent Aim",
        TabDoors = "Doors Control",
        TabTools = "Tools & Visuals",
        ESPDynamic = "Dynamic Enemy ESP (Strict Team Filter)",
        TPClosest = "TP to Closest Enemy",
        Fly = "Fly (PC & Mobile)",
        FlySpeed = "Fly Speed",
        NoClip = "NoClip (Walk through walls)",
        WalkSpeed = "WalkSpeed",
        SilentAim = "Balanced Silent Aim (Weapon Fire Trigger)",
        SilentAimDist = "Silent Aim Max Distance",
        SilentAimFOV = "Silent Aim FOV Size",
        FreezeAmmo = "Freeze Ammo (Infinite)",
        Fullbright = "Fullbright (No Darkness)",
        AntiBan = "Anti-Ban Protection",
        HitboxToggle = "Enable Clean Hitboxes",
        HitboxSize = "Hitbox Size (Up to 10x)",
        OpenAllDoors = "Open All Doors",
        CloseAllDoors = "Close All Doors",
        CreditsTitle = "Creator & Credits",
        CreditsContent = "Discord: rival960\nGitHub: Rival99900\nYouTube: rival9607",
        LangSelect = "Select Language",
        Loaded = "Hub Loaded Successfully!"
    },
    FR = {
        WindowTitle = "SCP vs Guard Hub",
        TabHome = "Accueil",
        TabVision = "Vision & ESP",
        TabMovement = "Mouvements & Vol",
        TabCombat = "Combat & Silent Aim",
        TabDoors = "Contrôle des Portes",
        TabTools = "Outils & Visuels",
        ESPDynamic = "ESP Ennemis Dynamique (Filtre Strict)",
        TPClosest = "TP vers l'Ennemi le plus proche",
        Fly = "Voler (PC & Mobile)",
        FlySpeed = "Vitesse de Vol",
        NoClip = "NoClip (Traverser les murs)",
        WalkSpeed = "Vitesse de marche",
        SilentAim = "Silent Aim Équilibré (Sur Bouton de Tir)",
        SilentAimDist = "Portée Max Silent Aim",
        SilentAimFOV = "Taille du FOV Silent Aim",
        FreezeAmmo = "Freeze Munitions (Infini)",
        Fullbright = "Fullbright (Supprimer l'obscurité)",
        AntiBan = "Protection Anti-Ban",
        HitboxToggle = "Activer les Hitboxes Propres",
        HitboxSize = "Taille Hitbox (Jusqu'à 10x)",
        OpenAllDoors = "Ouvrir Toutes les Portes",
        CloseAllDoors = "Fermer Toutes les Portes",
        CreditsTitle = "Créateur & Crédits",
        CreditsContent = "Discord : rival960\nGitHub : Rival99900\nYouTube : rival9607",
        LangSelect = "Sélectionner la langue",
        Loaded = "Hub chargé avec succès !"
    },
    DE = {
        WindowTitle = "SCP vs Guard Hub",
        TabHome = "Startseite",
        TabVision = "Sicht & ESP",
        TabMovement = "Bewegung & Flug",
        TabCombat = "Kampf & Silent Aim",
        TabDoors = "Türsteuerung",
        TabTools = "Werkzeuge & Visuals",
        ESPDynamic = "Dynamisches Gegner-ESP",
        TPClosest = "TP zum nächsten Ziel",
        Fly = "Fliegen (PC & Mobile)",
        FlySpeed = "Fluggeschwindigkeit",
        NoClip = "NoClip (Durch Wände gehen)",
        WalkSpeed = "Gehgeschwindigkeit",
        SilentAim = "Ausgeglichenes Silent Aim",
        SilentAimDist = "Silent Aim Max. Distanz",
        SilentAimFOV = "Silent Aim FOV Größe",
        FreezeAmmo = "Munition einfrieren",
        Fullbright = "Fullbright (Keine Finsternis)",
        AntiBan = "Anti-Ban Schutz",
        HitboxToggle = "Saubere Hitboxes aktivieren",
        HitboxSize = "Hitbox-Größe (bis 10x)",
        OpenAllDoors = "Alle Türen öffnen",
        CloseAllDoors = "Alle Türen schließen",
        CreditsTitle = "Ersteller & Credits",
        CreditsContent = "Discord: rival960\nGitHub: Rival99900\nYouTube: rival9607",
        LangSelect = "Sprache auswählen",
        Loaded = "Hub erfolgreich geladen!"
    },
    ES = {
        WindowTitle = "SCP vs Guard Hub",
        TabHome = "Inicio",
        TabVision = "Visión y ESP",
        TabMovement = "Movimiento y Vuelo",
        TabCombat = "Combate y Silent Aim",
        TabDoors = "Control de Puertas",
        TabTools = "Herramientas",
        ESPDynamic = "ESP Enemigos Dinámico",
        TPClosest = "TP al Enemigo más cercano",
        Fly = "Volar (PC y Móvil)",
        FlySpeed = "Velocidad de vuelo",
        NoClip = "NoClip (Atravesar paredes)",
        WalkSpeed = "Velocidad al caminar",
        SilentAim = "Silent Aim Equilibrado",
        SilentAimDist = "Distancia Máx Silent Aim",
        SilentAimFOV = "Tamaño FOV Silent Aim",
        FreezeAmmo = "Congelar Munición",
        Fullbright = "Fullbright (Sin oscuridad)",
        AntiBan = "Protección Anti-Ban",
        HitboxToggle = "Activar Hitboxes Limpias",
        HitboxSize = "Tamaño Hitbox (Hasta 10x)",
        OpenAllDoors = "Abrir Todas las Puertas",
        CloseAllDoors = "Cerrar Todas las Puertas",
        CreditsTitle = "Creador y Créditos",
        CreditsContent = "Discord: rival960\nGitHub: Rival99900\nYouTube: rival9607",
        LangSelect = "Seleccionar Idioma",
        Loaded = "¡Hub cargado con éxito!"
    },
    PT = {
        WindowTitle = "SCP vs Guard Hub",
        TabHome = "Início",
        TabVision = "Visão & ESP",
        TabMovement = "Movimento & Voo",
        TabCombat = "Combate & Silent Aim",
        TabDoors = "Controle de Portas",
        TabTools = "Ferramentas & UI",
        ESPDynamic = "ESP de Inimigos Dinâmico",
        TPClosest = "TP para o Inimigo mais próximo",
        Fly = "Voar (PC & Celular)",
        FlySpeed = "Velocidade de Voo",
        NoClip = "NoClip (Atravessar paredes)",
        WalkSpeed = "Velocidade de Caminhada",
        SilentAim = "Silent Aim Equilibrado",
        SilentAimDist = "Distância Máx Silent Aim",
        SilentAimFOV = "Tamanho do FOV Silent Aim",
        FreezeAmmo = "Congelar Munição",
        Fullbright = "Fullbright (Sem Escuridão)",
        AntiBan = "Proteção Anti-Ban",
        HitboxToggle = "Ativar Hitboxes Limpas",
        HitboxSize = "Tamanho da Hitbox (Até 10x)",
        OpenAllDoors = "Abrir Todas as Portas",
        CloseAllDoors = "Fechar Todas as Portas",
        CreditsTitle = "Criador & Créditos",
        CreditsContent = "Discord: rival960\nGitHub: Rival99900\nYouTube: rival9607",
        LangSelect = "Selecionar Idioma",
        Loaded = "Hub carregado com sucesso!"
    },
    RU = {
        WindowTitle = "SCP vs Guard Hub",
        TabHome = "Главная",
        TabVision = "Зрение и ESP",
        TabMovement = "Движение и Полет",
        TabCombat = "Бой и Silent Aim",
        TabDoors = "Управление дверями",
        TabTools = "Инструменты",
        ESPDynamic = "Динамический ESP врагов",
        TPClosest = "ТП к ближайшему врагу",
        Fly = "Полет (ПК и Телефон)",
        FlySpeed = "Скорость полета",
        NoClip = "NoClip (Ходьба сквозь стены)",
        WalkSpeed = "Скорость бега",
        SilentAim = "Сбалансированный Silent Aim",
        SilentAimDist = "Макс. дистанция Silent Aim",
        SilentAimFOV = "Размер FOV Silent Aim",
        FreezeAmmo = "Заморозка патронов",
        Fullbright = "Fullbright (Без темноты)",
        AntiBan = "Защита от банов",
        HitboxToggle = "Включить чистые хитбоксы",
        HitboxSize = "Размер хитбокса (до 10x)",
        OpenAllDoors = "Открыть все двери",
        CloseAllDoors = "Закрыть все двери",
        CreditsTitle = "Создатель и кредиты",
        CreditsContent = "Discord: rival960\nGitHub: Rival99900\nYouTube: rival9607",
        LangSelect = "Выберите язык",
        Loaded = "Скрипт успешно загружен!"
    },
    IT = {
        WindowTitle = "SCP vs Guard Hub",
        TabHome = "Home",
        TabVision = "Visione & ESP",
        TabMovement = "Movimento & Volo",
        TabCombat = "Combattimento & Silent Aim",
        TabDoors = "Controllo Porte",
        TabTools = "Strumenti",
        ESPDynamic = "ESP Nemici Dinamico",
        TPClosest = "TP al Nemico più vicino",
        Fly = "Vola (PC & Cellulare)",
        FlySpeed = "Velocità di volo",
        NoClip = "NoClip (Attraversa i muri)",
        WalkSpeed = "Velocità camminata",
        SilentAim = "Silent Aim Bilanciato",
        SilentAimDist = "Distanza Max Silent Aim",
        SilentAimFOV = "Dimensione FOV Silent Aim",
        FreezeAmmo = "Congela Munizioni",
        Fullbright = "Fullbright (Senza buio)",
        AntiBan = "Protezione Anti-Ban",
        HitboxToggle = "Attiva Hitbox Pulite",
        HitboxSize = "Dimensione Hitbox (Fino a 10x)",
        OpenAllDoors = "Apri Tutte le Porte",
        CloseAllDoors = "Chiudi Tutte le Porte",
        CreditsTitle = "Creatore & Crediti",
        CreditsContent = "Discord: rival960\nGitHub: Rival99900\nYouTube: rival9607",
        LangSelect = "Seleziona Lingua",
        Loaded = "Hub caricato con successo!"
    },
    NL = {
        WindowTitle = "SCP vs Guard Hub",
        TabHome = "Home",
        TabVision = "Vision & ESP",
        TabMovement = "Beweging & Vlucht",
        TabCombat = "Gevecht & Silent Aim",
        TabDoors = "Deurbeheer",
        TabTools = "Tools & UI",
        ESPDynamic = "Dynamisch Vijand ESP",
        TPClosest = "TP naar dichtstbijzijnde vijand",
        Fly = "Vliegen (PC & Mobiel)",
        FlySpeed = "Vliegsnelheid",
        NoClip = "NoClip (Door muren lopen)",
        WalkSpeed = "Loopssnelheid",
        SilentAim = "Gebalanceerd Silent Aim",
        SilentAimDist = "Silent Aim Max Afstand",
        SilentAimFOV = "Silent Aim FOV",
        FreezeAmmo = "Bevries Munitie",
        Fullbright = "Fullbright (Geen duisternis)",
        AntiBan = "Anti-Ban Bescherming",
        HitboxToggle = "Schone Hitboxes Inschakelen",
        HitboxSize = "Hitbox Grootte (Tot 10x)",
        OpenAllDoors = "Open Alle Deuren",
        CloseAllDoors = "Sluit Alle Deuren",
        CreditsTitle = "Maker & Credits",
        CreditsContent = "Discord: rival960\nGitHub: Rival99900\nYouTube: rival9607",
        LangSelect = "Selecteer Taal",
        Loaded = "Hub succesvol geladen!"
    },
    PL = {
        WindowTitle = "SCP vs Guard Hub",
        TabHome = "Start",
        TabVision = "Wizja i ESP",
        TabMovement = "Ruch i Lot",
        TabCombat = "Walka i Silent Aim",
        TabDoors = "Kontrola Drzwi",
        TabTools = "Narzędzia",
        ESPDynamic = "Dynamiczne ESP Wrogów",
        TPClosest = "TP do najbliższego wroga",
        Fly = "Lot (PC i Telefon)",
        FlySpeed = "Prędkość lotu",
        NoClip = "NoClip (Przechodzenie przez ściany)",
        WalkSpeed = "Prędkość chodu",
        SilentAim = "Zrównoważony Silent Aim",
        SilentAimDist = "Maks. dystans Silent Aim",
        SilentAimFOV = "Rozmiar FOV Silent Aim",
        FreezeAmmo = "Zamroź Amunicję",
        Fullbright = "Fullbright (Bez ciemności)",
        AntiBan = "Ochrona Anti-Ban",
        HitboxToggle = "Włącz czyste hitboxy",
        HitboxSize = "Rozmiar Hitboxa (do 10x)",
        OpenAllDoors = "Otwórz Wszystkie Drzwi",
        CloseAllDoors = "Zamknij Wszystkie Drzwi",
        CreditsTitle = "Twórca i Kredyty",
        CreditsContent = "Discord: rival960\nGitHub: Rival99900\nYouTube: rival9607",
        LangSelect = "Wybierz Język",
        Loaded = "Pomyślnie załadowano Hub!"
    },
    ZH = {
        WindowTitle = "SCP vs Guard Hub",
        TabHome = "主页",
        TabVision = "透视与ESP",
        TabMovement = "移动与飞行",
        TabCombat = "战斗与无声自瞄",
        TabDoors = "大门控制",
        TabTools = "工具与视觉",
        ESPDynamic = "动态敌方透视 (严格队伍过滤)",
        TPClosest = "传送到最近的敌人",
        Fly = "飞行 (电脑与手机)",
        FlySpeed = "飞行速度",
        NoClip = "穿墙 (NoClip)",
        WalkSpeed = "移动速度",
        SilentAim = "平衡无声自瞄 (开火键触发)",
        SilentAimDist = "自瞄最大距离",
        SilentAimFOV = "自瞄视野范围",
        FreezeAmmo = "无限子弹",
        Fullbright = "全局全亮",
        AntiBan = "防封禁保护",
        HitboxToggle = "开启整洁判定箱",
        HitboxSize = "判定箱大小 (最高10倍)",
        OpenAllDoors = "打开所有大门",
        CloseAllDoors = "关闭所有大门",
        CreditsTitle = "作者与鸣谢",
        CreditsContent = "Discord: rival960\nGitHub: Rival99900\nYouTube: rival9607",
        LangSelect = "选择语言",
        Loaded = "脚本加载成功！"
    },
    JA = {
        WindowTitle = "SCP vs Guard Hub",
        TabHome = "ホーム",
        TabVision = "ビジョン & ESP",
        TabMovement = "移動 & 飛行",
        TabCombat = "戦闘 & サイレントエイム",
        TabDoors = "ドア制御",
        TabTools = "ツール & UI",
        ESPDynamic = "ダイナミック敵ESP",
        TPClosest = "最寄りの敵へテレポート",
        Fly = "飛行 (PC & モバイル)",
        FlySpeed = "飛行速度",
        NoClip = "ノークリップ (壁抜け)",
        WalkSpeed = "歩行速度",
        SilentAim = "バランス型サイレントエイム",
        SilentAimDist = "最大距離",
        SilentAimFOV = "視野サイズ",
        FreezeAmmo = "弾薬無限",
        Fullbright = "フルブライト (暗闇なし)",
        AntiBan = "アンチバン保護",
        HitboxToggle = "クリーンヒットボックス有効化",
        HitboxSize = "ヒットボックスサイズ (最大10x)",
        OpenAllDoors = "すべてのドアを開く",
        CloseAllDoors = "すべてのドアを閉じる",
        CreditsTitle = "制作者 & クレジット",
        CreditsContent = "Discord: rival960\nGitHub: Rival99900\nYouTube: rival9607",
        LangSelect = "言語を選択",
        Loaded = "ハブの読み込みに成功しました！"
    },
    TR = {
        WindowTitle = "SCP vs Guard Hub",
        TabHome = "Ana Sayfa",
        TabVision = "Görüş & ESP",
        TabMovement = "Hareket & Uçuş",
        TabCombat = "Savaş & Silent Aim",
        TabDoors = "Kapı Kontrolü",
        TabTools = "Araçlar",
        ESPDynamic = "Dinamik Düşman ESP",
        TPClosest = "En Yakın Düşmana TP",
        Fly = "Uçuş (PC & Mobil)",
        FlySpeed = "Uçuş Hızı",
        NoClip = "NoClip (Duvarlardan Geçme)",
        WalkSpeed = "Yürüme Hızı",
        SilentAim = "Dengelenmiş Silent Aim",
        SilentAimDist = "Maks. Mesafe",
        SilentAimFOV = "Görüş Açısı",
        FreezeAmmo = "Mühimmatı Dondur",
        Fullbright = "Fullbright (Karanlığı Kaldır)",
        AntiBan = "Ban Koruması",
        HitboxToggle = "Temiz Hitbox'ları Etkinleştir",
        HitboxSize = "Hitbox Boyutu (10x'e kadar)",
        OpenAllDoors = "Tüm Kapıları Aç",
        CloseAllDoors = "Tüm Kapıları Kapat",
        CreditsTitle = "Yapımcı ve Krediler",
        CreditsContent = "Discord: rival960\nGitHub: Rival99900\nYouTube: rival9607",
        LangSelect = "Dil Seçin",
        Loaded = "Hub Başarıyla Yüklendi!"
    },
    KO = {
        WindowTitle = "SCP vs Guard Hub",
        TabHome = "홈",
        TabVision = "비전 & ESP",
        TabMovement = "이동 & 비행",
        TabCombat = "전투 & 사일런트 에임",
        TabDoors = "문 제어",
        TabTools = "도구 & 비주얼",
        ESPDynamic = "동적 적 ESP (엄격한 팀 필터)",
        TPClosest = "가장 가까운 적에게 텔레포트",
        Fly = "비행 (PC 및 모바일)",
        FlySpeed = "비행 속도",
        NoClip = "노클립 (벽 통과)",
        WalkSpeed = "이동 속도",
        SilentAim = "밸런스형 사일런트 에임",
        SilentAimDist = "최대 거리",
        SilentAimFOV = "FOV 크기",
        FreezeAmmo = "탄약 무한",
        Fullbright = "풀브라이트 (어둠 제거)",
        AntiBan = "밴 방지 보호",
        HitboxToggle = "깔끔한 히트박스 켜기",
        HitboxSize = "히트박스 크기 (최대 10배)",
        OpenAllDoors = "모든 문 열기",
        CloseAllDoors = "모든 문 닫기",
        CreditsTitle = "제작자 및 크레딧",
        CreditsContent = "Discord: rival960\nGitHub: Rival99900\nYouTube: rival9607",
        LangSelect = "언어 선택",
        Loaded = "허브가 성공적으로 로드되었습니다!"
    },
    AR = {
        WindowTitle = "SCP vs Guard Hub",
        TabHome = "الرئيسية",
        TabVision = "الرؤية و ESP",
        TabMovement = "الحركة والطيران",
        TabCombat = "القتال والتصويب الصامت",
        TabDoors = "تحكم الأبواب",
        TabTools = "الأدوات والمظهر",
        ESPDynamic = "ESP الأعداء الديناميكي",
        TPClosest = "الانتقال لأقرب عدو",
        Fly = "طيران (كمبيوتر وموبايل)",
        FlySpeed = "سرعة الطيران",
        NoClip = "NoClip (مرور عبر الجدران)",
        WalkSpeed = "سرعة المشي",
        SilentAim = "Silent Aim متوازن",
        SilentAimDist = "أقصى مسافة",
        SilentAimFOV = "حجم FOV",
        FreezeAmmo = "تجميد الذخيرة",
        Fullbright = "إضاءة كاملة",
        AntiBan = "حماية من الحظر",
        HitboxToggle = "تفعيل Hitbox النظيفة",
        HitboxSize = "حجم Hitbox (حتى 10x)",
        OpenAllDoors = "فتح جميع الأبواب",
        CloseAllDoors = "إغلاق جميع الأبواب",
        CreditsTitle = "المطور والاعتمادات",
        CreditsContent = "Discord: rival960\nGitHub: Rival99900\nYouTube: rival9607",
        LangSelect = "اختر اللغة",
        Loaded = "تم تحميل القائمة بنجاح!"
    },
    VI = {
        WindowTitle = "SCP vs Guard Hub",
        TabHome = "Trang chủ",
        TabVision = "Tầm nhìn & ESP",
        TabMovement = "Di chuyển & Bay",
        TabCombat = "Chiến đấu & Silent Aim",
        TabDoors = "Điều khiển cửa",
        TabTools = "Công cụ & Giao diện",
        ESPDynamic = "ESP Kẻ địch động",
        TPClosest = "Dịch chuyển đến kẻ địch gần nhất",
        Fly = "Bay (PC & Di động)",
        FlySpeed = "Tốc độ bay",
        NoClip = "NoClip (Đi xuyên tường)",
        WalkSpeed = "Tốc độ đi bộ",
        SilentAim = "Silent Aim Cân bằng",
        SilentAimDist = "Khoảng cách tối đa",
        SilentAimFOV = "Kích thước FOV",
        FreezeAmmo = "Đóng băng đạn",
        Fullbright = "Sáng toàn bộ",
        AntiBan = "Bảo vệ chống ban",
        HitboxToggle = "Bật Hitbox sạch",
        HitboxSize = "Kích thước Hitbox (Lên đến 10x)",
        OpenAllDoors = "Mở tất cả cửa",
        CloseAllDoors = "Đóng tất cả cửa",
        CreditsTitle = "Tác giả & Tín dụng",
        CreditsContent = "Discord: rival960\nGitHub: Rival99900\nYouTube: rival9607",
        LangSelect = "Chọn ngôn ngữ",
        Loaded = "Đã tải Hub thành công!"
    },
    SV = {
        WindowTitle = "SCP vs Guard Hub",
        TabHome = "Hem",
        TabVision = "Vision & ESP",
        TabMovement = "Rörelse & Flyg",
        TabCombat = "Strid & Silent Aim",
        TabDoors = "Dörrkontroll",
        TabTools = "Verktyg",
        ESPDynamic = "Dynamisk Fiende-ESP",
        TPClosest = "TP till närmaste fiende",
        Fly = "Flyga (PC & Mobil)",
        FlySpeed = "Flyghastighet",
        NoClip = "NoClip (Gå genom väggar)",
        WalkSpeed = "Gånghastighet",
        SilentAim = "Balanserat Silent Aim",
        SilentAimDist = "Max avstånd",
        SilentAimFOV = "FOV storlek",
        FreezeAmmo = "Frys ammunition",
        Fullbright = "Fullbright (Inget mörker)",
        AntiBan = "Anti-Ban Skydd",
        HitboxToggle = "Aktivera rena Hitboxes",
        HitboxSize = "Hitbox Storlek (Upp till 10x)",
        OpenAllDoors = "Öppna alla dörrar",
        CloseAllDoors = "Stäng alla dörrar",
        CreditsTitle = "Skapare & Credits",
        CreditsContent = "Discord: rival960\nGitHub: Rival99900\nYouTube: rival9607",
        LangSelect = "Välj språk",
        Loaded = "Hubb laddad framgångsrikt!"
    },
    EL = {
        WindowTitle = "SCP vs Guard Hub",
        TabHome = "Аρχική",
        TabVision = "Όραση & ESP",
        TabMovement = "Κίνηση & Πτήση",
        TabCombat = "Μάχη & Silent Aim",
        TabDoors = "Έλεγχος Πορτών",
        TabTools = "Εργαλεία",
        ESPDynamic = "Δυναμικό ESP Εχθρών",
        TPClosest = "TP στον πλησιέστερο εχθρό",
        Fly = "Πτήση (PC & Κινητό)",
        FlySpeed = "Ταχύτητα πτήσης",
        NoClip = "NoClip (Δίοδος από τοίχους)",
        WalkSpeed = "Ταχύτητα περπατήματος",
        SilentAim = "Ισορροπημένο Silent Aim",
        SilentAimDist = "Μέγιστη απόσταση",
        SilentAimFOV = "Μέγεθος FOV",
        FreezeAmmo = "Παγοποίηση πυρομαχικών",
        Fullbright = "Fullbright (Χωρίς σκοτάδι)",
        AntiBan = "Προστασία Anti-Ban",
        HitboxToggle = "Ενεργοποίηση καθαρών Hitboxes",
        HitboxSize = "Мέγεθος Hitbox (Έως 10x)",
        OpenAllDoors = "Άνοιγμα όλων των θυρών",
        CloseAllDoors = "Κλείσιμο όλων των θυρών",
        CreditsTitle = "Δημιουργός & Συντελεστές",
        CreditsContent = "Discord: rival960\nGitHub: Rival99900\nYouTube: rival9607",
        LangSelect = "Επιλογή γλώσσας",
        Loaded = "Το Hub φορτώθηκε επιτυχώς!"
    },
    RO = {
        WindowTitle = "SCP vs Guard Hub",
        TabHome = "Acasă",
        TabVision = "Viziune & ESP",
        TabMovement = "Mișcare & Zbor",
        TabCombat = "Luptă & Silent Aim",
        TabDoors = "Control Uși",
        TabTools = "Unelte",
        ESPDynamic = "ESP Inamici Dinamic",
        TPClosest = "TP la cel mai apropiat inamic",
        Fly = "Zbor (PC & Mobil)",
        FlySpeed = "Viteză Zbor",
        NoClip = "NoClip (Treci prin pereți)",
        WalkSpeed = "Viteză Mers",
        SilentAim = "Silent Aim Echilibrat",
        SilentAimDist = "Distanță Maximă",
        SilentAimFOV = "Dimensiune FOV",
        FreezeAmmo = "Înghețare Muniție",
        Fullbright = "Fullbright (Fără întuneric)",
        AntiBan = "Protecție Anti-Ban",
        HitboxToggle = "Activează Hitbox-uri Curate",
        HitboxSize = "Dimensiune Hitbox (Până la 10x)",
        OpenAllDoors = "Deschide Toate Ușile",
        CloseAllDoors = "Închide Toate Ușile",
        CreditsTitle = "Creator & Credite",
        CreditsContent = "Discord: rival960\nGitHub: Rival99900\nYouTube: rival9607",
        LangSelect = "Selectează Limba",
        Loaded = "Hub încărcat cu succes!"
    },
    UK = {
        WindowTitle = "SCP vs Guard Hub",
        TabHome = "Головна",
        TabVision = "Зріст та ESP",
        TabMovement = "Рух та Політ",
        TabCombat = "Бій та Silent Aim",
        TabDoors = "Керування дверима",
        TabTools = "Інструменти",
        ESPDynamic = "Динамічний ESP ворогів",
        TPClosest = "ТП до найближчого ворога",
        Fly = "Політ (ПК та Телефон)",
        FlySpeed = "Швидкість польоту",
        NoClip = "NoClip (Ходьба крізь стіни)",
        WalkSpeed = "Швидкість ходьби",
        SilentAim = "Збалансований Silent Aim",
        SilentAimDist = "Макс. дистанція",
        SilentAimFOV = "Розмір FOV",
        FreezeAmmo = "Заморозка патронів",
        Fullbright = "Fullbright (Без темряви)",
        AntiBan = "Захист від банів",
        HitboxToggle = "Увімкнути чисті хитбокси",
        HitboxSize = "Розмір хитбокса (до 10x)",
        OpenAllDoors = "Відчинити всі двері",
        CloseAllDoors = "Зачинити всі двері",
        CreditsTitle = "Створювач і Кредити",
        CreditsContent = "Discord: rival960\nGitHub: Rival99900\nYouTube: rival9607",
        LangSelect = "Виберіть мову",
        Loaded = "Хаб успішно завантажено!"
    },
    CS = {
        WindowTitle = "SCP vs Guard Hub",
        TabHome = "Domů",
        TabVision = "Vize & ESP",
        TabMovement = "Pohyb & Let",
        TabCombat = "Boj & Silent Aim",
        TabDoors = "Ovládání dveří",
        TabTools = "Nástroje",
        ESPDynamic = "Dynamické ESP nepřátel",
        TPClosest = "TP k nejbližšímu nepříteli",
        Fly = "Letět (PC & Mobil)",
        FlySpeed = "Rychlost letu",
        NoClip = "NoClip (Procházení zdmi)",
        WalkSpeed = "Rychlost chůze",
        SilentAim = "Vyvážené Silent Aim",
        SilentAimDist = "Max vzdálenost",
        SilentAimFOV = "Velikost FOV",
        FreezeAmmo = "Zmrazit munici",
        Fullbright = "Fullbright (Bez tmy)",
        AntiBan = "Anti-Ban Ochrana",
        HitboxToggle = "Povolit čisté hitboxy",
        HitboxSize = "Velikost Hitboxu (Až 10x)",
        OpenAllDoors = "Otevřít všechny dveře",
        CloseAllDoors = "Zavřít všechny dveře",
        CreditsTitle = "Tvůrce a Kredity",
        CreditsContent = "Discord: rival960\nGitHub: Rival99900\nYouTube: rival9607",
        LangSelect = "Vybrat jazyk",
        Loaded = "Hub úspěšně načten!"
    },
    DA = {
        WindowTitle = "SCP vs Guard Hub",
        TabHome = "Hjem",
        TabVision = "Syn & ESP",
        TabMovement = "Bevægelse & Flyvning",
        TabCombat = "Kamp & Silent Aim",
        TabDoors = "Dørkontrol",
        TabTools = "Værktøjer",
        ESPDynamic = "Dynamisk Fjende-ESP",
        TPClosest = "TP til nærmeste fjende",
        Fly = "Flyv (PC & Mobil)",
        FlySpeed = "Flyvehastighed",
        NoClip = "NoClip (Gå gennem vægge)",
        WalkSpeed = "Gåhastighet",
        SilentAim = "Balanceret Silent Aim",
        SilentAimDist = "Maks afstand",
        SilentAimFOV = "FOV størrelse",
        FreezeAmmo = "Frys ammunition",
        Fullbright = "Fullbright (Ingen mørke)",
        AntiBan = "Anti-Ban Beskyttelse",
        HitboxToggle = "Aktiver rene Hitboxes",
        HitboxSize = "Hitbox Størrelse (Op til 10x)",
        OpenAllDoors = "Åbn alle døre",
        CloseAllDoors = "Luk alle døre",
        CreditsTitle = "Skaber & Credits",
        CreditsContent = "Discord: rival960\nGitHub: Rival99900\nYouTube: rival9607",
        LangSelect = "Vælg sprog",
        Loaded = "Hub indlæst succesfuldt!"
    }
}

local function T(key)
    return Translations[CurrentLang][key] or Translations["EN"][key] or key
end

-- -----------------------------------------------------------------
-- 2. RAYFIELD UI LOADING
-- -----------------------------------------------------------------
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)

if not success or not Rayfield then return end

local Window = Rayfield:CreateWindow({
    Name = T("WindowTitle"),
    LoadingTitle = "Loading System...",
    LoadingSubtitle = "Created by Rival960 & AI",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

-- -----------------------------------------------------------------
-- 3. CONFIGURATION & STATES
-- -----------------------------------------------------------------
local Settings = {
    ESP_Dynamic = true,
    Fly = false,
    FlySpeed = 50,
    NoClip = false,
    Fullbright = false,
    SilentAim = false,
    SilentAimMaxDist = 120,
    SilentAimFov = 60,
    FreezeAmmo = true,
    AntiBan = true,
    Hitbox_Enabled = false,
    HitboxSize = 2,
    WalkSpeed = 16,
}

local FlyBodyVel, FlyBodyGyro
local Camera = Workspace.CurrentCamera
local isWeaponFiring = false

local GunShotEvent = nil
pcall(function()
    GunShotEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("GunShot", 3)
end)

local BroadcastBanEvent = nil
pcall(function()
    BroadcastBanEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("BroadcastBan", 3)
end)

local function MakeBulletBuffer()
    local bytes = {1, 104, 86, 27, 195, 24, 68, 51, 194, 109, 193, 173, 195, 200, 137, 25, 195, 68, 105, 50, 194, 244, 233, 172, 195}
    local str = string.char(table.unpack(bytes))
    if buffer and buffer.fromstring then
        return buffer.fromstring(str)
    end
    return str
end

local function isPlayerSCP(player)
    if not player or not player.Character then return false end
    local team = player.Team
    if team and (team.Name:lower():find("scp") or team.Name:lower():find("containment") or team.Name:lower():find("anomaly")) then 
        return true 
    end
    local pName = player.Name:lower()
    local cName = player.Character.Name:lower()
    if pName:find("scp") or cName:find("scp") or pName:find("045") or pName:find("173") or pName:find("096") or pName:find("106") or pName:find("939") or pName:find("049") or pName:find("682") or pName:find("457") then
        return true
    end
    for _, child in pairs(player.Character:GetChildren()) do
        if child.Name:lower():find("scp") or child.Name:lower():find("045") or child.Name:lower():find("457") then
            return true
        end
    end
    return false
end

-- Strict Enemy Function (Ensures teammates are never targeted or impacted)
local function isEnemy(player)
    if not player or player == LocalPlayer or not player.Character then return false end
    local localIsSCP = isPlayerSCP(LocalPlayer)
    local targetIsSCP = isPlayerSCP(player)
    return localIsSCP ~= targetIsSCP
end

-- Track Tool Activation for Official Game Shoot Button (PC & Mobile)
local function setupToolTracking(char)
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            child.Activated:Connect(function()
                isWeaponFiring = true
                task.delay(0.2, function() isWeaponFiring = false end)
            end)
        end
    end)
    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool then
        currentTool.Activated:Connect(function()
            isWeaponFiring = true
            task.delay(0.2, function() isWeaponFiring = false end)
        end)
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        hum.WalkSpeed = Settings.WalkSpeed
    end
    setupToolTracking(char)
end)

if LocalPlayer.Character then
    setupToolTracking(LocalPlayer.Character)
end

-- -----------------------------------------------------------------
-- 4. ANTI-BAN PROTECTION
-- -----------------------------------------------------------------
if BroadcastBanEvent then
    BroadcastBanEvent.OnClientEvent:Connect(function(username, reason)
        if Settings.AntiBan then
            if username == LocalPlayer.Name or username == LocalPlayer.DisplayName then
                print("[Anti-Ban] Ban attempt blocked!")
            end
        end
    end)
end

-- -----------------------------------------------------------------
-- 5. DOORS CONTROL
-- -----------------------------------------------------------------
local function OperateDoors(openState)
    local count = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local name = obj.Name:lower()
        if name:find("door") or name:find("gate") or name:find("porte") or name:find("checkpoint") then
            pcall(function()
                local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
                if prompt then
                    fireproximityprompt(prompt)
                    count = count + 1
                end
                local cd = obj:FindFirstChildOfClass("ClickDetector")
                if cd then
                    fireclickdetector(cd)
                    count = count + 1
                end
                local remote = obj:FindFirstChildWhichIsA("RemoteEvent") or obj:FindFirstChildWhichIsA("RemoteFunction")
                if remote then
                    remote:FireServer(openState)
                    count = count + 1
                end
                for _, child in ipairs(obj:GetDescendants()) do
                    if child:IsA("ProximityPrompt") then
                        fireproximityprompt(child)
                        count = count + 1
                    elseif child:IsA("ClickDetector") then
                        fireclickdetector(child)
                        count = count + 1
                    elseif child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                        child:FireServer(openState)
                        count = count + 1
                    end
                end
            end)
        end
    end
    local msg = openState and ("Doors opened ("..count..")") or ("Doors closed ("..count..")")
    Rayfield:Notify({Title = "Doors Control", Content = msg, Duration = 2})
end

-- -----------------------------------------------------------------
-- 6. TABS CREATION
-- -----------------------------------------------------------------
local TabHome = Window:CreateTab(T("TabHome"), 4483362458)
local TabMain = Window:CreateTab(T("TabVision"), 4483362458)
local TabMovement = Window:CreateTab(T("TabMovement"), 4483362458)
local TabCombat = Window:CreateTab(T("TabCombat"), 4483362458)
local TabDoors = Window:CreateTab(T("TabDoors"), 4483362458)
local TabTools = Window:CreateTab(T("TabTools"), 4483362458)

-- --- HOME / CREDITS ---
TabHome:CreateParagraph({
    Title = T("CreditsTitle"),
    Content = T("CreditsContent")
})

-- --- ESP ---
TabMain:CreateToggle({
    Name = T("ESPDynamic"),
    CurrentValue = true,
    Flag = "ESP_Dynamic_Toggle",
    Callback = function(Value)
        Settings.ESP_Dynamic = Value
        if not Value then
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character then
                    if p.Character:FindFirstChild("DynamicEnemyESP") then p.Character.DynamicEnemyESP:Destroy() end
                    if p.Character:FindFirstChild("Head") and p.Character.Head:FindFirstChild("ESPInfoTag") then
                        p.Character.Head.ESPInfoTag:Destroy()
                    end
                end
            end
        end
    end,
})

TabMain:CreateButton({
    Name = T("TPClosest"),
    Callback = function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local hrp = char.HumanoidRootPart
        
        local target, minDist = nil, math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if isEnemy(p) and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local dist = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        target = p.Character.HumanoidRootPart
                    end
                end
            end
        end
        if target then
            hrp.CFrame = target.CFrame * CFrame.new(0, 0, 3)
            Rayfield:Notify({Title = "Teleport", Content = "TP successful!", Duration = 2})
        else
            Rayfield:Notify({Title = "Teleport", Content = "No enemy found nearby.", Duration = 2})
        end
    end,
})

-- --- MOVEMENT ---
TabMovement:CreateToggle({
    Name = T("Fly"),
    CurrentValue = false,
    Flag = "Fly_Toggle",
    Callback = function(Value)
        Settings.Fly = Value
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        
        if Value then
            if not hrp then return end
            FlyBodyVel = Instance.new("BodyVelocity")
            FlyBodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            FlyBodyVel.Velocity = Vector3.zero
            FlyBodyVel.Parent = hrp
            
            FlyBodyGyro = Instance.new("BodyGyro")
            FlyBodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            FlyBodyGyro.CFrame = hrp.CFrame
            FlyBodyGyro.Parent = hrp
        else
            if FlyBodyVel then FlyBodyVel:Destroy() end
            if FlyBodyGyro then FlyBodyGyro:Destroy() end
        end
    end,
})

TabMovement:CreateSlider({
    Name = T("FlySpeed"),
    Range = {10, 300},
    Increment = 5,
    Suffix = "studs/s",
    CurrentValue = 50,
    Flag = "FlySpeed_Slider",
    Callback = function(Value)
        Settings.FlySpeed = Value
    end,
})

TabMovement:CreateToggle({
    Name = T("NoClip"),
    CurrentValue = false,
    Flag = "NoClip_Toggle",
    Callback = function(Value)
        Settings.NoClip = Value
        local char = LocalPlayer.Character
        if not Value and char then
            local validBodyParts = {
                ["Head"] = true, ["Torso"] = true, ["UpperTorso"] = true, ["LowerTorso"] = true,
                ["LeftArm"] = true, ["RightArm"] = true, ["LeftLeg"] = true, ["RightLeg"] = true,
                ["LeftUpperArm"] = true, ["LeftLowerArm"] = true, ["LeftHand"] = true,
                ["RightUpperArm"] = true, ["RightLowerArm"] = true, ["RightHand"] = true,
                ["LeftUpperLeg"] = true, ["LeftLowerLeg"] = true, ["LeftFoot"] = true,
                ["RightUpperLeg"] = true, ["RightLowerLeg"] = true, ["RightFoot"] = true
            }
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    if validBodyParts[part.Name] then
                        part.CanCollide = true
                    elseif part.Name == "HumanoidRootPart" then
                        part.CanCollide = false
                    end
                end
            end
        end
    end,
})

TabMovement:CreateSlider({
    Name = T("WalkSpeed"),
    Range = {16, 250},
    Increment = 1,
    Suffix = "speed",
    CurrentValue = 16,
    Flag = "Speed_Slider",
    Callback = function(Value)
        Settings.WalkSpeed = Value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = Value
        end
    end,
})

-- --- COMBAT & SILENT AIM ---
TabCombat:CreateToggle({
    Name = T("SilentAim"),
    CurrentValue = false,
    Flag = "SilentAim_Toggle",
    Callback = function(Value)
        Settings.SilentAim = Value
    end,
})

TabCombat:CreateSlider({
    Name = T("SilentAimDist"),
    Range = {20, 300},
    Increment = 10,
    Suffix = "studs",
    CurrentValue = 120,
    Flag = "SilentAimDist_Slider",
    Callback = function(Value)
        Settings.SilentAimMaxDist = Value
    end,
})

TabCombat:CreateSlider({
    Name = T("SilentAimFOV"),
    Range = {10, 200},
    Increment = 5,
    Suffix = "px",
    CurrentValue = 60,
    Flag = "SilentAimFOV_Slider",
    Callback = function(Value)
        Settings.SilentAimFov = Value
    end,
})

TabCombat:CreateToggle({
    Name = T("FreezeAmmo"),
    CurrentValue = true,
    Flag = "FreezeAmmo_Toggle",
    Callback = function(Value)
        Settings.FreezeAmmo = Value
    end,
})

TabCombat:CreateToggle({
    Name = T("AntiBan"),
    CurrentValue = true,
    Flag = "AntiBan_Toggle",
    Callback = function(Value)
        Settings.AntiBan = Value
    end,
})

TabCombat:CreateToggle({
    Name = T("HitboxToggle"),
    CurrentValue = false,
    Flag = "Hitbox_Toggle",
    Callback = function(Value)
        Settings.Hitbox_Enabled = Value
        if not Value then
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = p.Character.HumanoidRootPart
                    hrp.Size = Vector3.new(2, 2, 1)
                    hrp.Transparency = 1
                    hrp.CanCollide = false
                end
            end
        end
    end,
})

TabCombat:CreateSlider({
    Name = T("HitboxSize"),
    Range = {2, 10},
    Increment = 1,
    Suffix = "x",
    CurrentValue = 2,
    Flag = "Hitbox_Slider",
    Callback = function(Value)
        Settings.HitboxSize = Value
    end,
})

-- --- DOORS ---
TabDoors:CreateButton({
    Name = T("OpenAllDoors"),
    Callback = function()
        OperateDoors(true)
    end,
})

TabDoors:CreateButton({
    Name = T("CloseAllDoors"),
    Callback = function()
        OperateDoors(false)
    end,
})

-- --- TOOLS & VISUALS ---
TabTools:CreateToggle({
    Name = T("Fullbright"),
    CurrentValue = false,
    Flag = "Fullbright_Toggle",
    Callback = function(Value)
        Settings.Fullbright = Value
        if Value then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = false
        else
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
        end
    end,
})

TabTools:CreateDropdown({
    Name = T("LangSelect"),
    Options = {"English", "Français", "Deutsch", "Español", "Português", "Русский", "Italiano", "Nederlands", "Polski", "中文", "日本語", "Türkçe", "한국어", "العربية", "Tiếng Việt", "Svenska", "Ελληνικά", "Română", "Українська", "Čeština", "Dansk"},
    CurrentOption = "Français",
    Flag = "LangDropdown",
    Callback = function(Option)
        local mapping = {
            ["English"] = "EN", ["Français"] = "FR", ["Deutsch"] = "DE", ["Español"] = "ES",
            ["Português"] = "PT", ["Русский"] = "RU", ["Italiano"] = "IT", ["Nederlands"] = "NL",
            ["Polski"] = "PL", ["中文"] = "ZH", ["日本語"] = "JA", ["Türkçe"] = "TR",
            ["한국어"] = "KO", ["العربية"] = "AR", ["Tiếng Việt"] = "VI", ["Svenska"] = "SV",
            ["Ελληνικά"] = "EL", ["Română"] = "RO", ["Українська"] = "UK", ["Čeština"] = "CS", ["Dansk"] = "DA"
        }
        if mapping[Option] then
            CurrentLang = mapping[Option]
            Rayfield:Notify({Title = "Language", Content = "Language changed. Re-execute script to apply.", Duration = 3})
        end
    end,
})

-- -----------------------------------------------------------------
-- 7. EVENTS & MAIN LOOP (RENDERSTEPPED - OPTIMIZED)
-- -----------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local localIsSCP = isPlayerSCP(LocalPlayer)

    -- Universal Fly
    if Settings.Fly and hrp and FlyBodyVel and FlyBodyGyro then
        local moveDir = Vector3.zero
        if humanoid and humanoid.MoveDirection.Magnitude > 0 then
            moveDir = humanoid.MoveDirection
        end
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.Up) then moveDir = moveDir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.Down) then moveDir = moveDir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.Left) then moveDir = moveDir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) or UserInputService:IsKeyDown(Enum.KeyCode.Right) then moveDir = moveDir + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

        FlyBodyVel.Velocity = moveDir * Settings.FlySpeed
        FlyBodyGyro.CFrame = Camera.CFrame
    end

    -- NoClip
    if Settings.NoClip then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    -- Freeze Ammo (Optimized to target strictly ammunition without breaking weapon charging states)
    if Settings.FreezeAmmo then
        if GunShotEvent then
            pcall(function()
                firesignal(GunShotEvent.OnClientEvent, "ammo", 999, 999)
            end)
        end
        local equippedTool = char:FindFirstChildOfClass("Tool")
        if equippedTool then
            for _, desc in pairs(equippedTool:GetDescendants()) do
                if desc:IsA("IntValue") or desc:IsA("NumberValue") then
                    local n = desc.Name:lower()
                    if n == "ammo" or n == "mag" or n == "clip" or n == "storedammo" or n == "currentammo" then
                        desc.Value = 999
                    end
                end
            end
        end
    end

    -- Clean Hitboxes (Safe scaling of HumanoidRootPart without freezing custom SCP rigs)
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local enemy = isEnemy(p)
            local targetHrp = p.Character.HumanoidRootPart
            
            if Settings.Hitbox_Enabled and Settings.HitboxSize > 2 and enemy then
                pcall(function()
                    targetHrp.Size = Vector3.new(Settings.HitboxSize * 2, Settings.HitboxSize * 2, Settings.HitboxSize * 2)
                    targetHrp.Transparency = 0.5
                    targetHrp.CanCollide = false
                end)
            else
                pcall(function()
                    targetHrp.Size = Vector3.new(2, 2, 1)
                    targetHrp.Transparency = 1
                    targetHrp.CanCollide = true
                end)
            end
        end
    end

    -- Strict Team ESP & Info Tags (Ensures teammates never get highlighted)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local enemy = isEnemy(p)
            local head = p.Character:FindFirstChild("Head")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            
            if Settings.ESP_Dynamic and enemy then
                if not p.Character:FindFirstChild("DynamicEnemyESP") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "DynamicEnemyESP"
                    hl.FillColor = localIsSCP and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(255, 30, 30)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.35
                    hl.Parent = p.Character
                end

                if head and hum then
                    local bb = head:FindFirstChild("ESPInfoTag")
                    if not bb then
                        bb = Instance.new("BillboardGui")
                        bb.Name = "ESPInfoTag"
                        bb.Size = UDim2.new(0, 200, 0, 50)
                        bb.StudsOffset = Vector3.new(0, 2.5, 0)
                        bb.AlwaysOnTop = true
                        bb.Parent = head
                        
                        local txt = Instance.new("TextLabel")
                        txt.Name = "InfoText"
                        txt.Size = UDim2.new(1, 0, 1, 0)
                        txt.BackgroundTransparency = 1
                        txt.TextColor3 = Color3.fromRGB(255, 255, 255)
                        txt.TextStrokeTransparency = 0
                        txt.TextSize = 13
                        txt.Font = Enum.Font.GothamBold
                        txt.Parent = bb
                    end
                    local txt = bb:FindFirstChild("InfoText")
                    if txt then
                        local isTargetSCP = isPlayerSCP(p)
                        local role = isTargetSCP and "[SCP]" or "[Human]"
                        txt.Text = string.format("%s %s\nHP: %d/%d", role, p.Name, math.floor(hum.Health), math.floor(hum.MaxHealth))
                    end
                end
            else
                if p.Character:FindFirstChild("DynamicEnemyESP") then
                    p.Character.DynamicEnemyESP:Destroy()
                end
                if head and head:FindFirstChild("ESPInfoTag") then
                    head.ESPInfoTag:Destroy()
                end
            end
        end
    end

    -- Balanced Silent Aim (Triggered instantly on official weapon fire button with smooth FOV targeting)
    if Settings.SilentAim and hrp and GunShotEvent and isWeaponFiring then
        local targetP, targetHead = nil, nil
        local minDist = Settings.SilentAimFov
        local mousePos = UserInputService:GetMouseLocation()

        for _, p in pairs(Players:GetPlayers()) do
            if isEnemy(p) and p.Character then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local head = p.Character:FindFirstChild("Head")
                local targetHrp = p.Character:FindFirstChild("HumanoidRootPart")

                if hum and hum.Health > 0 and head and targetHrp then
                    local worldDist = (targetHrp.Position - hrp.Position).Magnitude
                    if worldDist <= Settings.SilentAimMaxDist then
                        local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                        if onScreen then
                            local screenDist = (Vector2.new(headPos.X, headPos.Y) - mousePos).Magnitude
                            if screenDist < minDist then
                                minDist = screenDist
                                targetP = p
                                targetHead = head
                            end
                        end
                    end
                end
            end
        end

        if targetP and targetHead then
            pcall(function()
                local bullet = MakeBulletBuffer()
                GunShotEvent:FireServer("shoot", bullet, {targetP}, {targetHead})
            end)
        end
    end
end)

Rayfield:Notify({
    Title = "Hub Loaded",
    Content = T("Loaded"),
    Duration = 3
})

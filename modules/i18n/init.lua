-- =============================================================================
-- X08 Hub — Multi-Language & Auto-Localization Engine (12 Languages)
-- Architecture: Object-Oriented Programming (OOP)
-- Standard: Zero-Cost, Pure Lua 5.1, Prometheus AST Compatible
-- Features:
--  - Multi-Source Auto-Detection (RobloxLocaleId, SystemLocaleId, LocalPlayer, Geo-Region)
--  - 12 Languages: EN, ID, ES, PT, RU, FR, DE, VI, TL, JA, KO, ZH-CN
--  - O(1) Case-Insensitive Translation Lookup
--  - Dynamic Translation Registration (RegisterTranslations)
--  - Global Singleton Helper: _G.X08_I18n, _G.X08_T
-- =============================================================================

local X08I18n = {}
X08I18n.__index = X08I18n

local I18N_LANG_NAMES = {
    ["auto"] = "Auto (System)",
    ["en"] = "English",
    ["id"] = "Bahasa Indonesia",
    ["es"] = "Español",
    ["pt"] = "Português",
    ["ru"] = "Русский",
    ["fr"] = "Français",
    ["de"] = "Deutsch",
    ["vi"] = "Tiếng Việt",
    ["tl"] = "Tagalog",
    ["ja"] = "日本語",
    ["ko"] = "한국어",
    ["zh-CN"] = "简体中文"
}

local I18N_NAME_TO_CODE = {
    ["Auto (System)"] = "auto",
    ["English"] = "en",
    ["Bahasa Indonesia"] = "id",
    ["Español"] = "es",
    ["Português"] = "pt",
    ["Русский"] = "ru",
    ["Français"] = "fr",
    ["Deutsch"] = "de",
    ["Tiếng Việt"] = "vi",
    ["Tagalog"] = "tl",
    ["日本語"] = "ja",
    ["한국어"] = "ko",
    ["简体中文"] = "zh-CN"
}

local I18N_LANG_INDEX = {
    ["en"] = 1,
    ["id"] = 2,
    ["es"] = 3,
    ["pt"] = 4,
    ["ru"] = 5,
    ["fr"] = 6,
    ["de"] = 7,
    ["vi"] = 8,
    ["tl"] = 9,
    ["ja"] = 10,
    ["ko"] = 11,
    ["zh-CN"] = 12
}

local I18N_RAW = {
    { "Settings", "Pengaturan", "Ajustes", "Configurações", "Настройки", "Paramètres", "Einstellungen", "Cài đặt", "Mga Setting", "設定", "설정", "设置" },
    { "Movement", "Pergerakan", "Movimiento", "Movimento", "Движение", "Mouvement", "Bewegung", "Di chuyển", "Pagkilos", "移動", "이동", "移动" },
    { "Combat", "Pertempuran", "Combate", "Combate", "Бой", "Combat", "Kampf", "Chiến đấu", "Labanan", "戦闘", "전투", "战斗" },
    { "Visuals", "Visual", "Visuales", "Visuais", "Визуалы", "Visuels", "Visuelles", "Hình ảnh", "Mga Visual", "視覚効果", "비주얼", "视觉" },
    { "Teleport", "Teleportasi", "Teletransporte", "Teletransporte", "Телепорт", "Téléportation", "Teleport", "Dịch chuyển", "Teleport", "テレポート", "순간이동", "传送" },
    { "Teleports", "Teleportasi", "Teletransportes", "Teletransportes", "Телепорты", "Téléportations", "Teleporte", "Dịch chuyển", "Mga Teleport", "テレポート一覧", "순간이동 목록", "传送列表" },
    { "Puzzles", "Teka-Teki", "Puzzles", "Enigmas", "Головоломки", "Énigmes", "Rätsel", "Câu đố", "Mga Palaisipan", "パズル", "퍼즐", "解谜" },
    { "Stats", "Statistik", "Estadísticas", "Estatísticas", "Статистика", "Statistiques", "Statistiken", "Thống kê", "Mga Estadistika", "ステータス", "통계", "统计" },
    { "Session", "Sesi", "Sesión", "Sessão", "Сессия", "Session", "Sitzung", "Phiên chơi", "Sesyon", "セッション", "세션", "会话" },
    { "System", "Sistem", "Sistema", "Sistema", "Система", "Système", "System", "Hệ thống", "Sistema", "システム", "시스템", "系统" },
    { "Dev", "Pengembang", "Desarrollador", "Desenvolvedor", "Разработка", "Développeur", "Entwickler", "Nhà phát triển", "Tagabuo", "開発", "개발자", "开发者" },
    { "Main", "Utama", "Principal", "Principal", "Главная", "Principal", "Hauptmenü", "Chính", "Pangunahin", "メイン", "메인", "主要" },
    { "World", "Dunia", "Mundo", "Mundo", "Мир", "Monde", "Welt", "Thế giới", "Mundo", "ワールド", "월드", "世界" },
    { "Player", "Pemain", "Jugador", "Jogador", "Игрок", "Joueur", "Spieler", "Người chơi", "Manlalaro", "プレイヤー", "플레이어", "玩家" },
    { "Utilities", "Utilitas", "Utilidades", "Utilitários", "Утилиты", "Utilitaires", "Dienstprogramme", "Tiện ích", "Mga Gamit", "ユーティリティ", "유틸リティ", "实用工具" },
    { "Misc", "Lainnya", "Varios", "Diversos", "Разное", "Divers", "Sonstiges", "Khác", "Iba pa", "その他", "기타", "杂项" },
    { "Info", "Informasi", "Información", "Informação", "Информация", "Informations", "Information", "Thông tin", "Impormasyon", "情報", "정보", "信息" },
    { "Information", "Informasi", "Información", "Informação", "Информация", "Informations", "Information", "Thông tin", "Impormasyon", "情報", "정보", "信息" },
    { "Farming", "Auto Farm", "Farmeo", "Farm", "Фарм", "Farming", "Farmen", "Cày cuốc", "Pagsasaka", "ファーム", "파밍", "刷取" },
    { "Raid", "Serbuan (Raid)", "Incursión", "Incursão", "Рейд", "Raid", "Raid", "Đột kích", "Raid", "レイド", "레이드", "突袭" },
    { "Dungeon", "Penjara Bawah Tanah (Dungeon)", "Mazmorra", "Masmorra", "Подземелье", "Donjon", "Dungeon", "Phó bản", "Dungeon", "ダンジョン", "던전", "地下城" },
    { "Shop", "Toko", "Tienda", "Loja", "Магазин", "Boutique", "Shop", "Cửa hàng", "Tindahan", "ショップ", "상점", "商店" },
    { "Inventory", "Inventaris", "Inventario", "Inventário", "Инвентарь", "Inventaire", "Inventar", "Túi đồ", "Imbentaryo", "インベントリ", "인벤토리", "物品栏" },
    { "Theme & Interface", "Tema & Antarmuka", "Tema e Interfaz", "Tema e Interface", "Тема и интерфейс", "Thème et Interface", "Design & Benutzeroberfläche", "Giao diện & Chủ đề", "Tema at Interface", "テーマとインターフェース", "테마 및 인터페이스", "主题与界面" },
    { "Universal Exploit Suite", "Universal Exploit Suite", "Suite de Exploits Universales", "Suite Universal de Exploits", "Универсальный Набор Эксплойтов", "Suite d'Exploits Universelle", "Universelle Exploit-Suite", "Bộ Công cụ Khai thác Chung", "Pangkalahatang Exploit Suite", "ユニバーサルエクスプロイトスイート", "유니버설 익스플로잇 스위트", "通用功能套件" },
    { "Configurations", "Konfigurasi", "Configuraciones", "Configurações", "Конфигурации", "Configurations", "Konfigurationen", "Cấu hình", "Mga Konpigurasyon", "コンフィグ", "환경설정", "配置管理" },
    { "Cache & Updates", "Cache & Pembaruan", "Caché y Actualizaciones", "Cache e Atualizações", "Кэш и Обновления", "Cache et Mises à jour", "Cache & Aktualisierungen", "Bộ nhớ đệm & Cập nhật", "Cache at Mga Update", "キャッシュと更新", "캐시 및 업데이트", "缓存与更新" },
    { "Hub Session", "Sesi Hub", "Sesión del Hub", "Sessão do Hub", "Сессия Хаба", "Session du Hub", "Hub-Sitzung", "Phiên Hub", "Sesyon ng Hub", "ハブセッション", "허브 세션", "Hub会话" },
    { "Game Module Status & Recovery", "Status & Pemulihan Modul Game", "Estado y Recuperación de Módulo", "Status e Recuperação de Módulo", "Статус и Восстановление Модуля", "État et Récupération du Module", "Modulstatus & Wiederherstellung", "Trạng thái & Khôi phục Mô-đun", "Katayuan at Pagbawi ng Modyul", "モジュール状態と復旧", "게임 모듈 상태 및 복구", "游戏模块状态与恢复" },
    { "Auto Defense", "Pertahanan Otomatis", "Defensa Automática", "Defesa Automática", "Авто-Защита", "Défense Automatique", "Automatische Verteidigung", "Tự động Phòng thủ", "Awtomatikong Depensa", "自動防衛", "자동 방어", "自动防御" },
    { "Values", "Nilai Atribut", "Valores", "Valores", "Значения", "Valeurs", "Werte", "Giá trị", "Mga Halaga", "数値設定", "수치 설정", "数值设置" },
    { "ESP", "ESP", "ESP", "ESP", "ESP", "ESP", "ESP", "ESP", "ESP", "ESP", "ESP", "ESP透视" },
    { "Character", "Karakter", "Personaje", "Personagem", "Персонаж", "Personnage", "Charakter", "Nhân vật", "Karakter", "キャラクター", "캐릭터", "角色" },
    { "Physics", "Fisika", "Física", "Física", "Физика", "Physique", "Physik", "Vật lý", "Pisika", "物理", "물리", "物理" },
    { "Chams", "Chams (Siluet)", "Chams", "Chams", "Чамсы", "Chams", "Chams", "Chams", "Chams", "透過発光 (Chams)", "실루엣 (Chams)", "高亮透视 (Chams)" },
    { "Tracers", "Garis Pelacak (Tracers)", "Trazadores", "Linhas Guia", "Трейсеры", "Traceurs", "Tracers", "Đường kẻ (Tracers)", "Mga Linya (Tracers)", "トレーサー線", "추적선 (Tracers)", "追踪射线" },
    { "Waypoints", "Titik Arah (Waypoints)", "Puntos de Ruta", "Pontos de Passagem", "Точки Маршрута", "Points de Passage", "Wegpunkte", "Điểm định hướng", "Mga Waypoint", "ウェイポイント", "웨이포인트", "路标点" },
    { "Server", "Server", "Servidor", "Servidor", "Сервер", "Serveur", "Server", "Máy chủ", "Server", "サーバー", "서버", "服务器" },
    { "Local Player", "Pemain Lokal", "Jugador Local", "Jogador Local", "Локальный Игрок", "Joueur Local", "Lokaler Spieler", "Người chơi Hiện tại", "Lokal na Manlalaro", "ローカルプレイヤー", "로컬 플레이어", "本地玩家" },
    { "Target", "Target", "Objetivo", "Alvo", "Цель", "Cible", "Ziel", "Mục tiêu", "Target", "ターゲット", "타겟", "目标" },
    { "Aimbot", "Aimbot Otomatis", "Aimbot", "Aimbot", "Аимбот", "Aimbot", "Aimbot", "Aimbot", "Aimbot", "エイムボット", "에임봇", "自动瞄准" },
    { "Hitbox", "Ukuran Hitbox", "Hitbox", "Hitbox", "Хитбокс", "Hitbox", "Hitbox", "Hitbox", "Hitbox", "ヒットボックス", "히트박스", "判定范围" },
    { "Kill Aura", "Kill Aura", "Kill Aura", "Kill Aura", "Килл-Аура", "Aura de Mort", "Kill-Aura", "Vùng tiêu diệt (Kill Aura)", "Kill Aura", "キルオーラ", "킬 오라", "杀戮光环" },
    { "Silent Aim", "Silent Aim", "Apuntado Silencioso", "Mira Silenciosa", "Тихий Аим", "Visée Silencieuse", "Silent-Aim", "Ngắm ẩn (Silent Aim)", "Tahimik na Aim", "サイレントエイム", "사일런트 에임", "无感锁头 (Silent Aim)" },
    { "Automation", "Otomatisasi", "Automatización", "Automação", "Автоматизация", "Automatisation", "Automatisierung", "Tự động hóa", "Awtomasyon", "自動化", "자동화", "自动化" },
    { "General", "Umum", "General", "Geral", "Общие", "Général", "Allgemein", "Chung", "Pangkalahatan", "一般", "일반", "常规" },
    { "Visual Settings", "Pengaturan Visual", "Ajustes Visuales", "Configurações Visuais", "Настройки Визуалов", "Paramètres Visuels", "Visuelle Einstellungen", "Cài đặt hình ảnh", "Mga Setting ng Visual", "視覚設定", "시각 설정", "视觉设置" },
    { "Toggle UI Keybind", "Tombol Buka/Tutup UI", "Tecla del Menú UI", "Tecla do Menu UI", "Клавиша Меню UI", "Touche du Menu UI", "UI-Menütaste", "Phím tắt Menu UI", "Keybind ng UI Menu", "UI開閉キーバインド", "UI 메뉴 키바인드", "UI菜单快捷键" },
    { "Load Universal Features", "Muat Fitur Universal", "Cargar Funciones Universales", "Carregar Recursos Universais", "Загрузить Универсальные Функции", "Charger les Fonctions Universelles", "Universelle Funktionen laden", "Tải Tính năng Chung", "I-load ang Universal Features", "ユニバーサル機能を読み込む", "유니버설 기능 불러오기", "加载通用功能" },
    { "Clear Local Cache & Force Update", "Hapus Cache Lokal & Paksa Pembaruan", "Limpiar Caché y Forzar Actualización", "Limpar Cache e Forçar Atualização", "Очистить Кэш и Принудительно Обновить", "Vider le Cache et Forcer la Mise à jour", "Lokalen Cache leeren & Update erzwingen", "Xóa Bộ nhớ đệm & Bắt buộc Cập nhật", "I-clear ang Lokal na Cache at I-update", "ローカルキャッシュ消去＆強制更新", "로컬 캐시 삭제 및 강제 업데이트", "清除本地缓存并强制更新" },
    { "Unload Hub", "Tutup & Hapus Hub", "Descargar Hub", "Descarregar Hub", "Выгрузить Хаб", "Décharger le Hub", "Hub entladen", "Đóng & Hủy Hub", "I-unload ang Hub", "ハブをアンロード", "허브 언로드", "卸载Hub" },
    { "Fly", "Terbang", "Volar", "Voar", "Полёт", "Voler", "Fliegen", "Bay", "Lumipad", "飛行 (Fly)", "비행 (Fly)", "飞行 (Fly)" },
    { "Noclip", "Tembus Dinding (Noclip)", "Atravesar Paredes", "Atravessar Paredes", "Сквозь Стены", "Passe-Muraille", "Durch Wände gehen", "Xuyên tường (Noclip)", "Tumatagos sa Pader", "壁抜け (Noclip)", "벽 뚫기 (Noclip)", "穿墙 (Noclip)" },
    { "WalkSpeed", "Kecepatan Jalan", "Velocidad de Movimiento", "Velocidade de Movimento", "Скорость Ходьбы", "Vitesse de Marche", "Laufgeschwindigkeit", "Tốc độ di chuyển", "Bilis ng Lakad", "移動速度", "이동 속도", "移动速度" },
    { "Speed", "Kecepatan", "Velocidad", "Velocidade", "Скорость", "Vitesse", "Geschwindigkeit", "Tốc độ", "Bilis", "スピード", "스피드", "速度" },
    { "JumpPower", "Kekuatan Lompat", "Potencia de Salto", "Força de Pulo", "Сила Прыжка", "Puissance de Saut", "Sprungkraft", "Lực nhảy", "Lakas ng Talon", "ジャンプ力", "도약력", "跳跃力" },
    { "Infinite Jump", "Lompatan Tak Terbatas", "Salto Infinito", "Pulo Infinito", "Бесконечный Прыжок", "Saut Infini", "Unendlicher Sprung", "Nhảy vô hạn", "Walang-hanggang Talon", "無限ジャンプ", "무한 점프", "无限跳跃" },
    { "Infinite Stamina", "Stamina Tak Terbatas", "Estamina Infinita", "Stamina Infinita", "Бесконечная Выносливость", "Endurance Infinie", "Unendliche Ausdauer", "Thể lực vô hạn", "Walang-hanggang Stamina", "無限スタミナ", "무한 스태미나", "无限体力" },
    { "God Mode", "Mode Kebal (God Mode)", "Modo Invencible", "Modo Deus", "Режим Бога", "Mode Dieu", "Unverwundbarkeit", "Chế độ Bất tử", "God Mode", "無敵モード (God Mode)", "무적 모드 (God Mode)", "无敌模式 (God Mode)" },
    { "Invisibility", "Menghilang (Tak Terlihat)", "Invisibilidad", "Invisibilidade", "Невидимость", "Invisibilité", "Unsichtbarkeit", "Tàng hình", "Hindi Nakikita", "不可視化 (Invisibility)", "투명화 (Invisibility)", "隐身模式" },
    { "Instant Interact", "Interaksi Instan", "Interacción Instantánea", "Interação Instantânea", "Мгновенное Взаимодействие", "Interaction Instantanée", "Sofortige Interaktion", "Tương tác tức thì", "Agad na Pakikipag-ugnayan", "即時インタラクト", "즉시 상호작용", "即时交互" },
    { "No Cooldown", "Tanpa Cooldown", "Sin Cooldown", "Sem Cooldown", "Без Кулдауна", "Sans Temps de Recharge", "Keine Abklingzeit", "Không hồi chiêu", "Walang Cooldown", "クールダウン無効", "クールダウン 제거", "无冷却时间" },
    { "Auto Attack", "Serangan Otomatis", "Ataque Automático", "Ataque Automático", "Авто-Атака", "Attaque Automatique", "Automatischer Angriff", "Tự động tấn công", "Awtomatikong Pag-atake", "自動攻撃", "자동 공격", "自动攻击" },
    { "Auto Clicker", "Klik Otomatis", "Auto Clicker", "Auto Clicker", "Авто-Кликер", "Auto Clicker", "Auto-Klicker", "Tự động nhấp chuột", "Auto Clicker", "オートクリッカー", "오토 클릭커", "自动连点器" },
    { "Auto Parry", "Tangkisan Otomatis (Auto Parry)", "Parry Automático", "Parry Automático", "Авто-Парирование", "Parade Automatique", "Automatisches Parieren", "Tự động đỡ đòn (Auto Parry)", "Awtomatikong Parry", "自動パリィ", "자동 패링", "自动格挡 (Auto Parry)" },
    { "Auto Dodge", "Menghindar Otomatis (Auto Dodge)", "Esquiva Automática", "Esquiva Automática", "Авто-Уклонение", "Esquive Automatique", "Automatisches Ausweichen", "Tự động né tránh", "Awtomatikong Pag-iwas", "自動回避", "자동 회피", "自动闪避" },
    { "Auto Block", "Blokir Otomatis", "Bloqueo Automático", "Bloqueio Automático", "Авто-Блок", "Blocage Automatique", "Automatischer Block", "Tự động chắn đòn", "Awtomatikong Pagharang", "自動ブロック", "자동 방어", "自动格挡" },
    { "Hitbox Expander", "Perbesar Ukuran Hitbox", "Expansor de Hitbox", "Expandir Hitbox", "Расширитель Хитбоксов", "Agrandisseur de Hitbox", "Hitbox-Vergrößerung", "Mở rộng Hitbox", "Palakihin ang Hitbox", "ヒットボックス拡張", "피격 판정 확대", "扩大判定框" },
    { "Triggerbot", "Triggerbot Otomatis", "Triggerbot Automático", "Triggerbot Automático", "Авто-Триггербот", "Triggerbot Automatique", "Automatischer Triggerbot", "Tự động bắn (Triggerbot)", "Awtomatikong Triggerbot", "オートトリガーボット", "오토 트리거봇", "自动扳机" },
    { "Aim Assist", "Bantuan Bidikan (Aim Assist)", "Asistencia de Apuntado", "Assistência de Mira", "Помощь в Прицеливании", "Aide à la Visée", "Zielhilfe", "Hỗ trợ ngắm bắn", "Tulong sa Pag-asinta", "エイムアシスト", "조준 보조", "辅助瞄准" },
    { "Master ESP", "Aktifkan Master ESP", "ESP Maestro", "ESP Mestre", "Основной ESP", "ESP Principal", "Haupt-ESP", "ESP Tổng", "Pangunahing ESP", "マスターESP", "마스터 ESP", "总控ESP" },
    { "Box ESP", "Kotak ESP", "Caja ESP", "Caixa ESP", "Боксы ESP", "Boîtes ESP", "Box-ESP", "Khung ESP", "Kahon ESP", "ボックスESP", "상자 ESP", "方框ESP" },
    { "Name ESP", "Nama ESP", "Nombre ESP", "Nome ESP", "Имена ESP", "Noms ESP", "Namen-ESP", "Tên ESP", "Pangalan ESP", "ネームESP", "이름 ESP", "名称ESP" },
    { "Distance ESP", "Jarak ESP", "Distancia ESP", "Distância ESP", "Дистанция ESP", "Distance ESP", "Distanz-ESP", "Khoảng cách ESP", "Layo ESP", "距離ESP", "거리 ESP", "距离ESP" },
    { "Health ESP", "Darah ESP", "Salud ESP", "Vida ESP", "Здоровье ESP", "Santé ESP", "Gesundheits-ESP", "Máu ESP", "Buhay ESP", "体力ESP", "체력 ESP", "血量ESP" },
    { "Fullbright", "Cahaya Maksimal (Fullbright)", "Brillo Máximo", "Brilho Máximo", "Максимальная Яркость", "Luminosité Maximale", "Maximale Helligkeit", "Độ sáng tối đa", "Maliwanag Lahat", "全方位高輝度 (Fullbright)", "최대 밝기", "全局高亮 (Fullbright)" },
    { "No Fog", "Hilangkan Kabut", "Quitar Niebla", "Remover Neblina", "Убрать Туман", "Supprimer le Brouillard", "Nebel entfernen", "Xóa sương mù", "Alisin ang Ulap", "霧除去 (No Fog)", "안개 제거", "去雾效果" },
    { "Anti AFK", "Anti AFK (Cegah Kick)", "Anti AFK", "Anti AFK", "Анти-АФК", "Anti-AFK", "Anti-AFK", "Chống AFK", "Anti-AFK", "AFK防止", "자리비움 방지 (안티 AFK)", "防挂机踢出" },
    { "FPS Boost", "Tingkatkan FPS", "Aumentar FPS", "Melhorar FPS", "Улучшить FPS", "Booster les FPS", "FPS-Optimierung", "Tăng tốc FPS", "Pabilisin ang FPS", "FPS向上", "FPS 향상", "提升帧率" },
    { "Rejoin Server", "Masuk Ulang Server", "Reunirse al Servidor", "Reentrar no Servidor", "Перезайти на Сервер", "Rejoindre le Serveur", "Server wieder betreten", "Vào lại máy chủ", "Sumali Ulit sa Server", "サーバー再接続", "서버 재접속", "重新连接服务器" },
    { "Server Hop", "Pindah Server (Server Hop)", "Cambiar de Servidor", "Trocar de Servidor", "Сменить Сервер", "Changer de Serveur", "Server wechseln", "Chuyển máy chủ", "Lumipat ng Server", "別サーバーへ移動", "다른 서버로 이동", "换服 (Server Hop)" },
    { "Teleport to Spawn", "Teleport ke Spawn", "Teletransportar al Spawn", "Teleportar para o Spawn", "Телепорт на Спавн", "Téléportation au Spawn", "Zum Spawn teleportieren", "Dịch chuyển về điểm hồi sinh", "Mag-teleport sa Spawn", "リスポーン地点へテレポート", "스폰 지점으로 순간이동", "传送到出生点" },
    { "Teleport to Safezone", "Teleport ke Zona Aman", "Teletransportar a Zona Segura", "Teleportar para Zona Segura", "Телепорт в Безопасную Зону", "Téléportation en Zone Sûre", "Zur Schutzzone teleportieren", "Dịch chuyển tới vùng an toàn", "Mag-teleport sa Ligtas na Lugar", "安全地帯へテレポート", "안전 지대로 순간이동", "传送到安全区" },
    { "Auto Win Flow", "Selesaikan Flow Otomatis", "Auto Ganar Flow", "Auto Vencer Flow", "Авто-Победа Flow", "Victoire Auto Flow", "Auto-Gewinn Flow", "Tự động giải Flow", "Auto Win Flow", "Flow自動クリア", "Flow 자동 완료", "自动破解Flow" },
    { "Auto Win Connect", "Selesaikan Connect Otomatis", "Auto Ganar Connect", "Auto Vencer Connect", "Авто-Победа Connect", "Victoire Auto Connect", "Auto-Gewinn Connect", "Tự động giải Connect", "Auto Win Connect", "Connect自動クリア", "Connect 자동 완료", "自动破解Connect" },
    { "Auto Win Lock", "Selesaikan Lock Otomatis", "Auto Ganar Lock", "Auto Vencer Lock", "Авто-Победа Lock", "Victoire Auto Lock", "Auto-Gewinn Lock", "Tự động giải Lock", "Auto Win Lock", "Lock自動クリア", "Lock 자동 완료", "自动破解Lock" },
    { "Auto Solve Gear Minigame", "Selesaikan Gear Otomatis", "Resolver Minijuego de Engranajes", "Resolver Minijogo de Engrenagens", "Авто-Решение Шестерёнок", "Résoudre Engrenages Auto", "Zahnrad-Minispiel lösen", "Tự động giải Bánh răng", "Auto Solve Gear Minigame", "ギアパズル自動解決", "기어 미니게임 자동 해결", "自动解齿轮小游戏" },
    { "Avoid Killer (Smart Raycast)", "Hindari Killer (Smart Raycast)", "Evitar Asesino (Raycast Inteligente)", "Evitar Assassino (Raycast Inteligente)", "Избегать Убийцу (Умный Raycast)", "Éviter le Tueur (Raycast Intelligent)", "Mörder ausweichen (Smart Raycast)", "Tránh Sát nhân (Raycast Thông minh)", "Iwasan ang Killer (Smart Raycast)", "キラー回避 (スマートRaycast)", "살인마 회피 (스마트 Raycast)", "智能避开杀手 (Raycast)" },
    { "Instant Objective Interact", "Interaksi Objektif Instan", "Interacción Instantánea de Objetivo", "Interação Instantânea com Objetivo", "Мгновенный Интеракт с Целями", "Interaction Instantanée d'Objectif", "Sofortige Ziel-Interaktion", "Tương tác Mục tiêu Tức thì", "Agad na Pakikipag-ugnayan sa Layunin", "目標オブジェクト即時インタラクト", "목표 즉시 상호작용", "瞬间完成目标互动" },
    { "Press key to change menu open/close keybind", "Tekan tombol untuk mengubah keybind buka/tutup menu", "Presiona la tecla para cambiar la combinación de teclas del menú", "Pressione a tecla para alterar a tecla de abrir/fechar o menu", "Нажмите клавишу, чтобы изменить горячую клавишу меню", "Appuyez sur une touche pour changer le raccourci du menu", "Taste drücken, um den UI-Menü-Hotkry zu ändern", "Nhấn phím để đổi phím tắt mở/đóng menu", "Pindutin ang pindutan upang baguhin ang keybind ng menu", "メニュー開閉キーバインドを変更するにはキーを押してください", "메뉴 열기/닫기 단축키를 변경하려면 키를 누르세요", "按下按键修改菜单打开/关闭快捷键" },
    { "Load Universal module (Fly, Noclip, ESP, Speed, Waypoints, etc) into the hub on-demand.", "Muat modul Universal (Fly, Noclip, ESP, Speed, Waypoints, dll) ke dalam hub secara on-demand.", "Cargar módulo Universal (Fly, Noclip, ESP, Speed, Waypoints, etc) en el hub a pedido.", "Carregar o módulo Universal (Fly, Noclip, ESP, Speed, Waypoints, etc) no hub sob demanda.", "Загрузить Универсальный модуль (Fly, Noclip, ESP, Speed, Waypoints и др.) по запросу.", "Charger le module universel (Fly, Noclip, ESP, Speed, Waypoints, etc.) à la demande.", "Universelles Modul (Fly, Noclip, ESP, Speed, Waypoints usw.) bei Bedarf in den Hub laden.", "Tải mô-đun Chung (Bay, Xuyên tường, ESP, Tốc độ, v.v.) vào hub theo yêu cầu.", "I-load ang Universal module (Fly, Noclip, ESP, Speed, Waypoints, atbp) on-demand.", "ハブにユニバーサルモジュール (飛行、壁抜け、ESP、速度、ウェイポイント等) をオンデマンドで読み込みます。", "요청 시 허브에 유니버설 모듈 (비행, 벽 뚫기, ESP, 속도, 웨이포인트 등)을 불러옵니다.", "按需将通用功能模块 (飞行、穿墙、ESP、加速、路标点等) 加载到Hub中。" },
    { "Purge all local cache to force downloading latest module versions from server.", "Hapus seluruh cache lokal agar modul selalu mengunduh versi terbaru dari server.", "Borrar toda la caché local para forzar la descarga de las últimas versiones del servidor.", "Limpar todo o cache local para forçar o download das versões mais recentes do servidor.", "Очистить весь локальный кэш для принудительной загрузки свежих версий с сервера.", "Vider tout le cache local pour forcer le téléchargement des dernières versions du serveur.", "Gesamten lokalen Cache leeren, um die neuesten Modulversionen vom Server zu erzwingen.", "Xóa toàn bộ bộ nhớ đệm cục bộ để bắt buộc tải phiên bản mới nhất từ máy chủ.", "I-clear ang buong lokal na cache upang piliting i-download ang pinakabagong bersyon.", "すべてのローカルキャッシュを消去し、サーバーから最新モジュールを強制取得します。", "모든 로컬 캐시를 삭제하여 서버에서 최신 모듈 버전을 강제로 다운로드합니다.", "清除所有本地缓存以强制从服务器下载最新模块版本。" },
    { "Close interface and clean up all X08 Hub resources.", "Tutup interface dan bersihkan seluruh resource X08 Hub.", "Cerrar la interfaz y limpiar todos los recursos de X08 Hub.", "Fechar a interface e limpar todos os recursos do X08 Hub.", "Закрыть интерфейс и очистить все ресурсы X08 Hub.", "Fermer l'interface et nettoyer toutes les ressources de X08 Hub.", "Benutzeroberfläche schließen und alle Ressourcen von X08 Hub bereinigen.", "Đóng giao diện và dọn dẹp toàn bộ tài nguyên của X08 Hub.", "Isara ang interface at linisin ang lahat ng resources ng X08 Hub.", "インターフェースを閉じて、X08 Hubのすべてのリソースを解放します。", "인터페이스를 닫고 모든 X08 Hub 리소스를 정리합니다.", "关闭界面并清理所有X08 Hub资源。" },
    { "Interface Language", "Bahasa Antarmuka", "Idioma de la Interfaz", "Idioma da Interface", "Язык Интерфейса", "Langue de l'Interface", "Sprache der Benutzeroberfläche", "Ngôn ngữ Giao diện", "Wika ng Interface", "インターフェース言語", "인터페이스 언어", "界面语言" },
    { "Select interface display language", "Pilih bahasa tampilan untuk menu X08 Hub", "Seleccionar el idioma de visualización del menú", "Selecione o idioma de exibição do menu", "Выберите язык отображения меню X08 Hub", "Sélectionnez la langue d'affichage du menu", "Wählen Sie die Anzeigesprache für das Menü", "Chọn ngôn ngữ hiển thị cho menu X08 Hub", "Pumili ng wika para sa menu ng X08 Hub", "X08 Hubメニューの表示言語を選択", "X08 Hub 메뉴 표시 언어 선택", "选择X08 Hub菜单显示语言" },
    { "Language successfully updated to: ", "Bahasa berhasil diperbarui ke: ", "Idioma actualizado con éxito a: ", "Idioma atualizado com sucesso para: ", "Язык успешно обновлен на: ", "Langue mise à jour avec succès en : ", "Sprache erfolgreich aktualisiert auf: ", "Ngôn ngữ đã được cập nhật thành: ", "Matagumpay na na-update ang wika sa: ", "言語を次へ更新しました: ", "언어가 다음으로 업데이트되었습니다: ", "语言已成功更新为: " },
    { "System language detected: ", "Bahasa sistem terdeteksi: ", "Idioma del sistema detectado: ", "Idioma do sistema detectado: ", "Обнаружен язык системы: ", "Langue du système détectée : ", "Systemsprache erkannt: ", "Đã phát hiện ngôn ngữ hệ thống: ", "Natukoy ang wika ng sistema: ", "システム言語を検出: ", "감지된 시스템 언어: ", "检测到系统语言: " },
    { "All local cache cleared. Hub will fetch latest versions.", "Seluruh cache lokal telah dibersihkan. Hub akan selalu mengambil versi terbaru dari server.", "Toda la caché local ha sido borrada.", "Todo o cache local foi limpo.", "Локальный кэш очищен. Хаб загрузит свежие версии.", "Tout le cache local a été vidé.", "Lokaler Cache geleert. Hub lädt die neuesten Versionen.", "Đã xóa sạch bộ nhớ đệm cục bộ.", "Nalinis na ang lahat ng lokal na cache.", "ローカルキャッシュをすべて消去しました。", "모든 로컬 캐시가 삭제되었습니다.", "本地缓存已全部清除，Hub将拉取最新版本。" },
    { "Universal module is already active in Hub!", "Modul Universal sudah aktif di dalam Hub!", "¡El módulo Universal ya está activo en el Hub!", "O módulo Universal já está ativo no Hub!", "Универсальный модуль уже активен в Хабе!", "Le module Universel est déjà actif dans le Hub !", "Das Universal-Modul ist bereits im Hub aktiv!", "Mô-đun Chung đã hoạt động trong Hub!", "Aktibo na ang Universal module sa Hub!", "ユニバーサルモジュールはすでにアクティブです！", "유니버설 모듈이 이미 허브에서 활성화되어 있습니다!", "通用功能模块已在Hub中处于激活状态！" },
    { "Universal Utilities", "Utilitas Universal", "Utilidades Universales", "Utilitários Universais", "Универсальные Утилиты", "Utilitaires Universels", "Universelle Dienstprogramme", "Tiện ích Chung", "Pangkalahatang Gamit", "ユニバーサルユーティリティ", "유니버설 유틸리티", "通用实用工具" },
    { "Info & Profil", "Info & Profil", "Información y Perfil", "Informações e Perfil", "Информация и Профиль", "Info et Profil", "Info & Profil", "Thông tin & Hồ sơ", "Impormasyon at Profile", "情報＆プロフィール", "정보 및 프로필", "信息与个人资料" },
    { "Visuals & ESP", "Visual & ESP", "Visuales y ESP", "Visuais e ESP", "Визуалы и ESP", "Visuels et ESP", "Visuelles & ESP", "Hình ảnh & ESP", "Visual at ESP", "視覚効果＆ESP", "비주얼 및 ESP", "视觉与ESP透视" },
    { "Dev Tools", "Alat Pengembang", "Herramientas de Desarrollador", "Ferramentas de Desenvolvedor", "Инструменты Разработчика", "Outils Développeur", "Entwickler-Tools", "Công cụ Nhà phát triển", "Mga Gamit ng Tagabuo", "開発ツール", "개발자 도구", "开发者工具" },
    { "Latest Update", "Pembaruan Terkini", "Última Actualización", "Última Atualização", "Последнее Обновление", "Dernière Mise à Jour", "Neuestes Update", "Cập nhật mới nhất", "Pinakabagong Update", "最新の更新", "최신 업데이트", "最新更新" },
    { "Profil Pemain", "Profil Pemain", "Perfil del Jugador", "Perfil do Jogador", "Профиль Игрока", "Profil du Joueur", "Spielerprofil", "Hồ sơ người chơi", "Profile ng Manlalaro", "プレイヤープロフィール", "플레이어 프로필", "玩家资料" },
    { "Informasi Map & Server", "Informasi Map & Server", "Información del Mapa y Servidor", "Informações do Mapa e Servidor", "Информация о Карте и Сервере", "Infos Carte et Serveur", "Karten- & Server-Info", "Thông tin Bản đồ & Máy chủ", "Impormasyon ng Mapa at Server", "マップ＆サーバー情報", "맵 및 서버 정보", "地图与服务器信息" },
    { "Player & Account Inspector", "Pemeriksa Pemain & Akun", "Inspector de Jugador y Cuenta", "Inspetor de Jogador e Conta", "Инспектор Игрока и Аккаунта", "Inspecteur de Joueur et Compte", "Spieler- & Konto-Inspektor", "Kiểm tra Người chơi & Tài khoản", "Tagasuri ng Manlalaro at Account", "プレイヤー＆アカウント検査", "플레이어 및 계정 검사기", "玩家与账户查看器" },
    { "Aimbot & Camera Lock", "Aimbot & Pengunci Kamera", "Aimbot y Bloqueo de Cámara", "Aimbot e Trava de Câmera", "Аимбот и Захват Камеры", "Aimbot et Verrouillage Caméra", "Aimbot & Kamera-Lock", "Tự động ngắm & Khóa Camera", "Aimbot at Camera Lock", "エイムボット＆カメラロック", "에임봇 및 카메라 고정", "自瞄与镜头锁定" },
    { "Hitbox & Serangan", "Hitbox & Serangan", "Hitbox y Ataque", "Hitbox e Ataque", "Хитбокс и Атака", "Hitbox et Attaque", "Hitbox & Angriff", "Hitbox & Tấn công", "Hitbox at Pag-atake", "ヒットボックス＆攻撃", "피격 판정 및 공격", "判定框与攻击" },
    { "Filter Target Hitbox", "Filter Target Hitbox", "Filtro de Objetivo de Hitbox", "Filtro de Alvo da Hitbox", "Фильтр Целей Хитбокса", "Filtre de Cible Hitbox", "Hitbox-Zielfilter", "Bộ lọc Mục tiêu Hitbox", "Filter ng Target Hitbox", "ヒットボックス対象フィルター", "피격 판정 대상 필터", "判定目标过滤" },
    { "Hit Detection & Damage Feedback", "Deteksi Hit & Umpan Balik Damage", "Detección de Impacto y Daño", "Detecção de Impacto e Dano", "Регистрация Попаданий и Урона", "Détection des Tirs et Dégâts", "Treffererkennung & Schadens-Feedback", "Nhận diện trúng đạn & Phản hồi sát thương", "Hit Detection at Damage Feedback", "ヒット判定＆ダメージ通知", "피격 판정 및 데미지 피드백", "命中检测与伤害反馈" },
    { "Anti-Aim & Desync Engine (HvH)", "Anti-Aim & Desync Engine (HvH)", "Motor Anti-Aim y Desync (HvH)", "Motor Anti-Aim e Desync (HvH)", "Анти-Аим и Десинк Движок (HvH)", "Moteur Anti-Aim et Desync (HvH)", "Anti-Aim & Desync-Engine (HvH)", "Động cơ Chống ngắm & Lệch hình (HvH)", "Anti-Aim at Desync Engine (HvH)", "アンチエイム＆同期ズレ (HvH)", "안티에임 및 비동기 엔진 (HvH)", "反自瞄与模型不同步 (HvH)" },
    { "Proteksi & Utility", "Proteksi & Utility", "Protección y Utilidades", "Proteção e Utilitários", "Защита и Утилиты", "Protection et Utilitaires", "Schutz & Dienstprogramme", "Bảo vệ & Tiện ích", "Proteksyon at Gamit", "防御＆ユーティリティ", "방어 및 유틸리티", "保护与实用功能" },
    { "Lompatan & Gravitasi", "Lompatan & Gravitasi", "Salto y Gravedad", "Salto e Gravidade", "Прыжки и Гравитация", "Saut et Gravité", "Sprung & Schwerkraft", "Nhảy & Trọng lực", "Talon at Grabidad", "ジャンプ＆重力", "점프 및 중력", "跳跃与重力" },
    { "Mode Terbang", "Mode Terbang", "Modo de Vuelo", "Modo de Voo", "Режим Полёта", "Mode Vol", "Flugmodus", "Chế độ Bay", "Mode ng Paglipad", "飛行モード", "비행 모드", "飞行模式" },
    { "Mobilitas Khusus", "Mobilitas Khusus", "Movilidad Especial", "Mobilidade Especial", "Особая Мобильность", "Mobilité Spéciale", "Spezielle Mobilität", "Di chuyển Đặc biệt", "Espesyal na Pagkilos", "特殊移動能力", "특수 이동", "特殊机动能力" },
    { "Kustomisasi Animasi Karakter", "Kustomisasi Animasi Karakter", "Personalización de Animaciones", "Personalização de Animações", "Кастомизация Анимаций", "Personnalisation des Animations", "Charakter-Animations-Anpassung", "Tùy chỉnh Hoạt ảnh Nhân vật", "Pag-customize ng Animasyon", "アニメーション変更", "캐릭터 애니메이션 커스텀", "角色动作动画自定义" },
    { "Ukuran Karakter (Resizer)", "Ukuran Karakter (Resizer)", "Tamaño del Personaje (Resizer)", "Tamanho do Personagem (Resizer)", "Размер Персонажа (Ресайзер)", "Taille du Personnage (Resizer)", "Charaktergröße (Resizer)", "Kích thước Nhân vật (Đổi cỡ)", "Laki ng Karakter (Resizer)", "キャラクターサイズ変更", "캐릭터 크기 조절 (Resizer)", "角色体型大小调整" },
    { "ESP (Visuals)", "ESP (Visual)", "ESP (Visuales)", "ESP (Visuais)", "ESP (Визуалы)", "ESP (Visuels)", "ESP (Visuell)", "ESP (Hình ảnh)", "ESP (Mga Visual)", "ESP (視覚効果)", "ESP (비주얼)", "ESP (视觉透视)" },
    { "Filter, Performa & Jarak ESP", "Filter, Performa & Jarak ESP", "Filtro, Rendimiento y Distancia ESP", "Filtro, Desempenho e Distância ESP", "Фильтры, Производительность и Дальность ESP", "Filtres, Performance et Distance ESP", "ESP-Filter, Leistung & Distanz", "Bộ lọc, Hiệu năng & Tầm xa ESP", "Filter, Bilis at Layo ng ESP", "ESPフィルター・性能・描画距離", "ESP 필터, 성능 및 거리", "ESP过滤、性能与渲染距离" },
    { "Kustomisasi Warna & Properti ESP", "Kustomisasi Warna & Properti ESP", "Colores y Propiedades de ESP", "Cores e Propriedades de ESP", "Цвета и Параметры ESP", "Couleurs et Propriétés ESP", "Farbanpassung & ESP-Eigenschaften", "Tùy biến Màu sắc & Thuộc tính ESP", "Kulay at Katangian ng ESP", "ESPカラー＆プロパティ設定", "ESP 색상 및 속성 설정", "ESP颜色与显示属性" },
    { "Radar & Sensor Horor", "Radar & Sensor Horor", "Radar y Sensor de Terror", "Radar e Sensor de Terror", "Радар и Сенсор Монстров", "Radar et Détecteur d'Horreur", "Radar & Horror-Sensor", "Radar & Cảm biến Kinh dị", "Radar at Horror Sensor", "レーダー＆ホラーセンサー", "레이더 및 공포 감지 센서", "雷达与怪物感应器" },
    { "Efek Kamera & Horor Sinematik", "Efek Kamera & Horor Sinematik", "Efectos de Cámara y Terror Cinemático", "Efeitos de Câmera e Terror Cinemático", "Эффекты Камеры и Кинематографичный Хоррор", "Effets Caméra et Horreur Cinématique", "Kamera-Effekte & Kinoreifer Horror", "Hiệu ứng Camera & Điện ảnh Kinh dị", "Camera Effects at Sinematikong Horror", "カメラ効果＆シネマティックホラー", "카메라 효과 및 시네마틱 호러", "镜头特效与电影级恐怖" },
    { "Kamera & Lingkungan Dunia", "Kamera & Lingkungan Dunia", "Cámara y Entorno del Mundo", "Câmera e Ambiente do Mundo", "Камера и Окружающий Мир", "Caméra et Environnement", "Kamera & Weltumgebung", "Camera & Môi trường Thế giới", "Camera at Kapaligiran", "カメラ＆ワールド環境", "카메라 및 월드 환경", "镜头与世界环境" },
    { "Kosmetik Karakter (Effects)", "Kosmetik Karakter (Effects)", "Cosméticos del Personaje (Efectos)", "Cosméticos do Personagem (Efeitos)", "Косметика Персонажа (Эффекты)", "Cosmétiques du Personnage (Effets)", "Charakter-Kosmetik (Effekte)", "Hiệu ứng Trang trí Nhân vật", "Mga Effect ng Karakter", "キャラクター外見エフェクト", "캐릭터 외형 효과 (이펙트)", "角色特效装饰" },
    { "Rasio Layar & Pencahayaan Lanjut", "Rasio Layar & Pencahayaan Lanjut", "Relación de Aspecto e Iluminación Avanzada", "Proporção de Tela e Iluminação Avançada", "Соотношение Сторон и Освещение", "Format d'Image et Éclairage Avancé", "Bildformat & Erweiterte Beleuchtung", "Tỉ lệ màn hình & Ánh sáng nâng cao", "Rasyo ng Screen at Ilaw", "画面アスペクト比＆高度な照明", "화면 비율 및 고급 조명", "屏幕比例与高级光影" },
    { "Optimasi Render", "Optimasi Render", "Optimización de Renderizado", "Otimização de Renderização", "Оптимизация Рендеринга", "Optimisation du Rendu", "Rendering-Optimierung", "Tối ưu hóa hiển thị", "Pag-optimize ng Render", "描画最適化", "렌더링 최적화", "渲染性能优化" },
    { "Sistem Waypoint", "Sistem Waypoint", "Sistema de Waypoints", "Sistema de Waypoints", "Система Точек (Вейпоинты)", "Système de Waypoints", "Wegpunkt-System", "Hệ thống Điểm định hướng", "Sistema ng Waypoint", "ウェイポイントシステム", "웨이포인트 시스템", "路标点系统" },
    { "Teleport Pemain", "Teleport Pemain", "Teletransporte a Jugador", "Teletransporte para Jogador", "Телепорт к Игрокам", "Téléportation Joueur", "Spieler-Teleport", "Dịch chuyển tới Người chơi", "Mag-teleport sa Manlalaro", "プレイヤーへテレポート", "플레이어 순간이동", "玩家传送" },
    { "Interaksi & Troll", "Interaksi & Troll", "Interacción y Bromas", "Interação e Pegadinhas", "Взаимодействие и Троллинг", "Interaction et Troll", "Interaktion & Troll", "Tương tác & Trêu chọc", "Pakikipag-ugnayan at Troll", "インタラクト＆おふざけ", "상호작용 및 트롤링", "互动与娱乐恶搞" },
    { "Eksplorasi Dunia", "Eksplorasi Dunia", "Exploración del Mundo", "Exploração do Mundo", "Исследование Мира", "Exploration du Monde", "Welterkundung", "Khám phá Thế giới", "Paggagalugad ng Mundo", "ワールド探索", "월드 탐험", "世界探索" },
    { "Sistem & Keamanan", "Sistem & Keamanan", "Sistema y Seguridad", "Sistema e Segurança", "Система и Безопасность", "Système et Sécurité", "System & Sicherheit", "Hệ thống & An toàn", "Sistema at Seguridad", "システム＆セキュリティ", "시스템 및 보안", "系统与安全" },
    { "Manajemen Server & Karakter", "Manajemen Server & Karakter", "Gestión de Servidor y Personaje", "Gerenciamento de Servidor e Personagem", "Управление Сервером и Персонажем", "Gestion Serveur et Personnage", "Server- & Charakter-Verwaltung", "Quản lý Máy chủ & Nhân vật", "Pamamahala ng Server at Karakter", "サーバー＆キャラクター管理", "서버 및 캐릭터 관리", "服务器与角色管理" },
    { "Control Menu", "Menu Kontrol", "Menú de Control", "Menu de Controle", "Панель Управления", "Menu de Contrôle", "Steuerungsmenü", "Menu Điều khiển", "Menu ng Kontrol", "コントロールメニュー", "제어 메뉴", "控制菜单" },
    { "Server Remote Explorer & Invoker", "Server Remote Explorer & Invoker", "Explorador e Invocador de Remotes", "Explorador e Invocador de Remotes", "Обозреватель и Вызов Серверных Remotes", "Explorateur et Exécuteur de Remotes", "Server-Remote-Explorer & Invoker", "Khám phá & Kích hoạt Remote Máy chủ", "Server Remote Explorer at Invoker", "サーバーRemote探索＆実行ツール", "서버 리모트 탐색기 및 실행기", "服务器Remote事件浏览器与触发器" },
    { "Script Discovery & Inspector", "Penemuan & Pemeriksa Skrip", "Descubrimiento e Inspección de Scripts", "Descoberta e Inspeção de Scripts", "Поиск и Анализ Скриптов", "Découverte et Inspection de Scripts", "Skript-Erkennung & Inspektor", "Dò tìm & Phân tích Kịch bản", "Pagsusuri ng mga Script", "スクリプト検出＆インスペクター", "스크립트 탐색 및 검사기", "脚本发现与检查器" },
    { "Bunny Hop (Bhop)", "Bunny Hop (Bhop)", "Bunny Hop (Bhop)", "Bunny Hop (Bhop)", "Банни-Хоп (Bhop)", "Bunny Hop (Bhop)", "Bunny-Hop (Bhop)", "Nhảy liên tục (Bhop)", "Bunny Hop (Bhop)", "バニーホップ (Bhop)", "버니합 (Bhop)", "连跳 (Bunny Hop)" },
    { "Spider Climb (Wall Climb)", "Spider Climb (Panjat Dinding)", "Escalar Paredes (Spider Climb)", "Escalar Paredes (Spider Climb)", "Лазание по Стенам (Spider Climb)", "Grimper aux Murs (Spider Climb)", "Wandklettern (Spider Climb)", "Bò leo tường (Spider Climb)", "Umakyat sa Pader (Spider Climb)", "壁登り (Spider Climb)", "벽 타기 (Spider Climb)", "爬墙 (Spider Climb)" },
    { "Air Walk (Pijakan Udara Melayang)", "Air Walk (Pijakan Udara Melayang)", "Caminar por el Aire", "Caminhar no Ar", "Ходьба по Воздуху (Air Walk)", "Marcher dans les Airs", "Luftlauf (Air Walk)", "Bước đi trên không (Air Walk)", "Lakad sa Hangin", "空中歩行 (Air Walk)", "공중 걷기 (Air Walk)", "空中漫步 (Air Walk)" },
    { "Auto-Walk (Otomatis Maju)", "Auto-Walk (Otomatis Maju)", "Caminata Automática", "Caminhada Automática", "Авто-Ходьба Вперёд", "Marche Automatique", "Automatisches Laufen", "Tự động bước tới", "Awtomatikong Lakad", "自動前進 (Auto-Walk)", "자동 걷기 (오토 워크)", "自动前行 (Auto-Walk)" },
    { "Swim in Air (Berenang di Udara)", "Swim in Air (Berenang di Udara)", "Nadar en el Aire", "Nadar no Ar", "Плавание в Воздухе", "Nager dans l'Air", "In der Luft schwimmen", "Bơi trên không", "Lumangoy sa Hangin", "空中遊泳", "공중 수영", "空中游动" },
    { "Ghost Desync (Bodi Palsu ForceField)", "Ghost Desync (Bodi Palsu ForceField)", "Desincronización Fantasma", "Desync Fantasma", "Призрачный Десинк", "Desync Fantôme", "Geister-Desync", "Bóng ma Lệch hình", "Ghost Desync", "ゴーストデシンク", "고스트 비동기", "幽灵模型不同步" },
    { "Fast Auto-Clicker (Cursor/Screen)", "Fast Auto-Clicker (Kursor/Layar)", "Auto-Clicker Rápido (Cursor/Pantalla)", "Auto-Clicker Rápido (Cursor/Tela)", "Быстрый Авто-Кликер (Курсор/Экран)", "Auto-Clicker Rapide", "Schneller Auto-Klicker", "Tự động nhấp siêu tốc", "Mabilis na Auto-Clicker", "高速オートクリッカー", "초고속 오토 클릭커", "高速屏幕连点器" },
    { "Damage Hitlogs Notification (Notifikasi Hit & Damage)", "Notifikasi Hit & Damage", "Notificaciones de Daño", "Notificações de Dano", "Логи Попаданий и Урона", "Journal des Dégâts", "Schadens-Benachrichtigungen", "Thông báo Đánh trúng & Sát thương", "Notipikasyon ng Damage", "ヒット＆ダメージログ通知", "피격 및 데미지 로그 알림", "命中与伤害提示" },
    { "Desync / Anti-Aim (CFrame & Velocity Spoof)", "Desync / Anti-Aim", "Desync / Anti-Aim", "Desync / Anti-Aim", "Десинк / Анти-Аим", "Desync / Anti-Aim", "Desync / Anti-Aim", "Lệch hình / Chống ngắm", "Desync / Anti-Aim", "同期ズレ＆アンチエイム", "비동기 및 안티에임", "模型不同步与反自瞄" },
    { "Freeze Desync (Physics Network Standstill)", "Freeze Desync (Hentikan Jaringan Fisika)", "Congelar Desincronización", "Congelar Desync", "Заморозка Десинка", "Geler la Désynchronisation", "Freeze-Desync", "Đóng băng Lệch hình", "Freeze Desync", "フリーズデシンク", "정지 비동기", "静止模型不同步" },
    { "Godmode (Kebal Kematian, Health Lock & Killbrick)", "Godmode (Kebal Kematian)", "Modo Dios (Invencibilidad)", "Modo Deus (Invencível)", "Режим Бога (Неуязвимость)", "Mode Dieu (Invulnérable)", "Gottmodus (Unverwundbarkeit)", "Bất tử hoàn toàn", "Godmode (Walang Kamatayan)", "完全無敵モード", "갓모드 (완전 무적)", "无敌不死模式" },
    { "Killbrick Shield (Kebal Part Mematikan)", "Killbrick Shield (Kebal Part Mematikan)", "Escudo contra Killbrick", "Escudo contra Killbrick", "Защита от Киллбриков", "Bouclier Anti-Killbrick", "Killbrick-Schild", "Kháng khối sát thương (Killbrick)", "Kalasag laban sa Killbrick", "即死ブロック無効化", "킬브릭 방어막", "即死方块护盾" },
    { "Anti-Fling Shield (Kebal Tabrakan Pemain)", "Anti-Fling Shield (Kebal Tabrakan)", "Escudo Anti-Fling", "Escudo Anti-Fling", "Анти-Флинг Щит", "Bouclier Anti-Fling", "Anti-Fling-Schild", "Khiên chống văng (Anti-Fling)", "Anti-Fling Shield", "衝突吹き飛ばし防止 (Anti-Fling)", "충돌 튕김 방지 실드", "防碰撞击飞护盾 (Anti-Fling)" },
    { "Auto-Dodge (Refleks Lompat & Menghindar Serangan)", "Auto-Dodge (Menghindar Otomatis)", "Esquiva Automática", "Esquiva Automática", "Авто-Уклонение от Атак", "Esquive Automatique", "Automatisches Ausweichen", "Tự động né đòn phản xạ", "Awtomatikong Pag-iwas", "反射回避 (Auto-Dodge)", "자동 회피 반사", "自动闪避反击" },
    { "Anti-Ragdoll (Kebal Jatuh / Knockdown)", "Anti-Ragdoll (Kebal Jatuh)", "Anti-Ragdoll (Sin Caídas)", "Anti-Ragdoll (Sem Quedas)", "Анти-Регдолл (Без Падений)", "Anti-Ragdoll", "Anti-Ragdoll (Kein Umfallen)", "Chống ngã gục (Anti-Ragdoll)", "Anti-Ragdoll", "転倒防止 (Anti-Ragdoll)", "낙하 기절 방지 (안티 래그돌)", "防倒地软瘫 (Anti-Ragdoll)" },
    { "No Fall Damage (Kebal Jatuh)", "No Fall Damage (Kebal Jatuh)", "Sin Daño por Caída", "Sem Dano de Queda", "Без Урона от Падения", "Sans Dégâts de Chute", "Kein Fallschaden", "Miễn sát thương rơi", "Walang Fall Damage", "落下ダメージ無効", "낙하 피해 면제", "免除跌落伤害" },
    { "Night Vision (Penglihatan Malam)", "Night Vision (Penglihatan Malam)", "Visión Nocturna", "Visão Noturna", "Ночное Видение", "Vision Nocturne", "Nachtsicht", "Nhìn trong đêm (Night Vision)", "Paningin sa Gabi", "暗視ゴーグル (Night Vision)", "야간 투시경", "夜视模式" },
    { "Head Bobbing (Kamera Bergoyang Saat Berjalan)", "Goyangan Kamera (Head Bobbing)", "Balanceo de Cabeza", "Balanço de Cabeça", "Покачивание Камеры", "Balancement de la Tête", "Kopfbewegung beim Gehen", "Rung lắc đầu khi đi", "Pag-ugoy ng Kamera", "歩行時カメラ揺れ", "보행 시 카메라 흔들림", "步行镜头摇晃" },
    { "Camera Shake (Guncangan Kamera)", "Guncangan Kamera", "Vibración de Cámara", "Tremor de Câmera", "Тряска Камеры", "Secousses de la Caméra", "Kamera-Erschütterung", "Rung chuyển màn hình", "Panginginig ng Kamera", "画面の激しい揺れ", "화면 흔들림 효과", "镜头剧烈震动" },
    { "Camera Flashlight (Senter Realistis)", "Senter Realistis", "Linterna de Cámara", "Lanterna da Câmera", "Фонарик Камеры", "Lampe Torche de la Caméra", "Kamera-Taschenlampe", "Đèn pin Camera chân thực", "Flashlight ng Kamera", "カメラライト (懐中電灯)", "카메라 손전등", "镜头手电筒光源" },
    { "X-Ray Vision", "Penglihatan Tembus Pandang (X-Ray)", "Visión de Rayos X", "Visão Raio-X", "Рентгеновское Зрение", "Vision Rayons X", "Röntgenblick (X-Ray)", "Mắt thần xuyên thấu (X-Ray)", "X-Ray Vision", "X線透過透視 (X-Ray)", "엑스레이 투시", "透视透光 (X-Ray)" },
    { "Rainbow Character (Siklus Warna Pelangi)", "Karakter Warna Pelangi", "Personaje Arcoíris", "Personagem Arco-Íris", "Радужный Персонаж", "Personnage Arc-en-Ciel", "Regenbogen-Charakter", "Nhân vật phát sáng 7 màu", "Bahagharing Karakter", "レインボーカラーボディ", "무지개빛 캐릭터", "彩虹炫彩人物" },
    { "Rainbow Trail (Ekor Jejak Pelangi)", "Jejak Warna Pelangi", "Rastro Arcoíris", "Rastro Arco-Íris", "Радужный След", "Traînée Arc-en-Ciel", "Regenbogen-Schweif", "Vệt sáng cầu vồng", "Bahagharing Bakas", "レインボートレイル", "무지개 궤적", "彩虹拖尾轨迹" },
    { "Click TP (Ctrl + LClick)", "Teleport Klik (Ctrl + Klik)", "Teletransporte por Clic", "Teletransporte por Clique", "Клик-Телепорт (Ctrl + ЛКМ)", "Clic Téléportation", "Klick-Teleport (Ctrl + Klick)", "Dịch chuyển bằng Chuột (Ctrl + Click)", "Click TP", "クリックテレポート (Ctrl+左クリック)", "클릭 순간이동 (Ctrl + 클릭)", "鼠标点击传送 (Ctrl+左键)" },
    { "Multi-Target SkidFling (Lempar Pemain ke Langit)", "SkidFling (Lempar Pemain)", "SkidFling (Lanzar Jugadores)", "SkidFling (Lançar Jogadores)", "SkidFling (Запуск Игроков в Небо)", "SkidFling Multi-Cible", "Multi-Target SkidFling", "Hất tung người chơi lên trời", "SkidFling (Ihagis ang Manlalaro)", "他プレイヤー吹き飛ばし (SkidFling)", "플레이어 상공으로 날려버리기 (SkidFling)", "弹飞发射玩家上天 (SkidFling)" },
    { "Spinbot (Beyblade Mode)", "Spinbot (Putar Cepat)", "Spinbot (Modo Beyblade)", "Spinbot (Modo Beyblade)", "Спинбот (Режим Бэйблэйд)", "Spinbot (Mode Toupie)", "Spinbot (Beyblade-Modus)", "Quay tròn điên cuồng (Spinbot)", "Spinbot", "高速回転 (Spinbot)", "초고속 회전 (스핀봇)", "陀螺高速旋转 (Spinbot)" },
    { "Walk Fling (NextFling - Tabrak Pemain)", "Walk Fling (Tabrak Pemain)", "Walk Fling (Golpear Jugadores)", "Walk Fling (Bater em Jogadores)", "Walk Fling (Сбивать Игроков)", "Walk Fling", "Walk-Fling (Spieler wegrammen)", "Va chạm hất tung người chơi", "Walk Fling", "接触吹き飛ばし (Walk Fling)", "보행 충돌 날리기 (Walk Fling)", "移动碰撞击飞 (Walk Fling)" },
    { "BTools (Ctrl+Klik Hapus, Alt+Klik TP)", "BTools (Alat Konstruksi)", "BTools (Herramientas de Construcción)", "BTools (Ferramentas de Construção)", "BTools (Инструменты Строителя)", "BTools (Outils de Construction)", "BTools (Bauwerkzeuge)", "BTools (Xóa & Di chuyển Khối)", "BTools", "建築・削除ツール (BTools)", "건축/삭제 도구 (BTools)", "建筑与删除工具 (BTools)" },
    { "Freeze NPCs (Bekukan Seluruh Bot & Monster di Map)", "Bekukan Seluruh Bot & Monster", "Congelar NPCs y Monstruos", "Congelar NPCs e Monstros", "Заморозить Всех NPC и Монстров", "Geler Tous les PNJ et Monstres", "NPCs & Monster einfrieren", "Đóng băng toàn bộ NPC & Quái vật", "I-freeze ang mga NPC", "全NPC＆モンスター停止", "모든 NPC 및 몬스터 정지", "定格全图NPC与怪物" },
    { "Coin & Pickup Magnet (Penarik Item/Koin)", "Magnet Koin & Item", "Imán de Monedas e Ítems", "Ímã de Moedas e Itens", "Магнит Монет и Предметов", "Aimant à Pièces et Objets", "Münzen- & Gegenstands-Magnet", "Hút tiền & Vật phẩm (Magnet)", "Magnet ng Barya at Gamit", "コイン＆ドロップ品磁石吸引", "코인 및 아이템 자석 흡입", "金币与掉落物自动吸附" },
    { "Walk on Water", "Berjalan di Atas Air", "Caminar sobre el Agua", "Caminhar sobre a Água", "Хождение по Воде", "Marcher sur l'Eau", "Auf Wasser gehen", "Đi trên mặt nước", "Lumakad sa Tubig", "水上歩行", "물 위 걷기", "水上行走" },
    { "Anti-Void", "Cegah Jatuh ke Void", "Anti-Vacío (Anti-Void)", "Anti-Vazio (Anti-Void)", "Анти-Бездна (Anti-Void)", "Anti-Vide (Anti-Void)", "Anti-Void (Schutz vor Abgrund)", "Chống rơi xuống Vực thẳm", "Anti-Void", "奈落落下防止 (Anti-Void)", "낙하 방지 (안티 보이드)", "防坠入虚空 (Anti-Void)" },
    { "Anti-Kick Protection (Bypass Game Kick)", "Proteksi Anti-Kick", "Protección Anti-Kick", "Proteção Anti-Kick", "Анти-Кик Защита", "Protection Anti-Expulsion", "Anti-Kick-Schutz", "Chống bị Đá khỏi phòng (Anti-Kick)", "Proteksyon laban sa Kick", "キック防止プロテクション", "강퇴 방지 보호 (안티 킥)", "防踢出游戏保护 (Anti-Kick)" },
    { "Auto-Rejoin on Kick / Disconnect", "Masuk Ulang Otomatis saat Disconnect", "Reconexión Automática", "Reconectar Automaticamente", "Авто-Переподключение при Вылете", "Reconnexion Auto en cas de Déconnexion", "Automatischer Reconnect bei Kick", "Tự động kết nối lại khi mất mạng", "Auto-Rejoin kapag Na-kick", "回線切断時自動再接続", "강퇴/연결 끊김 시 자동 재접속", "掉线/被踢自动重连" },
    { "FPS & Speed HUD Overlay", "HUD Tampilan FPS & Kecepatan", "Superposición de FPS y Velocidad", "HUD de FPS e Velocidade", "HUD Панель FPS и Скорости", "Affichage Tête Haute FPS et Vitesse", "FPS- & Geschwindigkeits-HUD", "Lớp phủ Hiển thị FPS & Tốc độ", "FPS at Speed HUD", "FPS＆速度リアルタイム表示HUD", "FPS 및 이동속도 HUD 표시", "帧率与移速实时显示HUD" },
    { "Chat Spy (Pantau Semua Pesan Pemain)", "Pantau Chat (Chat Spy)", "Espía de Chat (Chat Spy)", "Espião de Chat (Chat Spy)", "Шпион Чата (Chat Spy)", "Espion de Chat", "Chat-Spion (Chat Spy)", "Theo dõi tin nhắn ẩn (Chat Spy)", "Chat Spy", "全チャット盗聴 (Chat Spy)", "모든 채팅 감시 (챗 스파이)", "全局聊天窥探 (Chat Spy)" },
    { "Powerful Anti-AFK", "Anti-AFK Ekstra Kuat", "Anti-AFK Avanzado", "Anti-AFK Poderoso", "Мощный Анти-АФК", "Anti-AFK Puissant", "Leistungsstarkes Anti-AFK", "Chống treo máy cực mạnh (Anti-AFK)", "Mabisang Anti-AFK", "強力AFK防止機能", "강력한 자리비움 방지", "强力防止挂机掉线" },
    { "Pindai Semua Server Remotes", "Pindai Semua Server Remotes", "Escanear Todos los Remotes", "Escanear Todos os Remotes", "Сканировать Все Серверные Remotes", "Scanner Tous les Remotes Serveur", "Alle Server-Remotes scannen", "Quét toàn bộ Remote Máy chủ", "I-scan Lahat ng Remotes", "全サーバーRemoteをスキャン", "모든 서버 리모트 검색", "扫描全部服务器Remote" },
    { "Pindai Semua Skrip Game (Client & Module)", "Pindai Semua Skrip Game", "Escanear Todos los Scripts del Juego", "Escanear Todos os Scripts do Jogo", "Сканировать Все Скрипты Игры", "Scanner Tous les Scripts du Jeu", "Alle Spielskripte scannen", "Quét toàn bộ Kịch bản Game", "I-scan Lahat ng Script ng Laro", "クライアント＆モジュールスクリプト検索", "모든 게임 스크립트 검색", "扫描客户端与模块脚本" },
    { "Save Posisi Saat Ini", "Simpan Posisi Saat Ini", "Guardar Posición Actual", "Salvar Posição Atual", "Сохранить Текущую Позицию", "Sauvegarder la Position Actuelle", "Aktuelle Position speichern", "Lưu tọa độ hiện tại", "I-save ang Kasalukuyang Posisyon", "現在位置を保存", "현재 위치 저장", "保存当前坐标点" },
    { "Hapus Posisi Terpilih", "Hapus Posisi Terpilih", "Eliminar Posición Seleccionada", "Excluir Posição Selecionada", "Удалить Выбранную Позицию", "Supprimer la Position Sélectionnée", "Ausgewählte Position löschen", "Xóa tọa độ đã chọn", "Tanggalin ang Napiling Posisyon", "選択位置を削除", "선택한 위치 삭제", "删除选中的坐标点" },
    { "Teleport Sekali", "Teleport Sekali", "Teletransportar Una Vez", "Teletransportar Uma Vez", "Однократный Телепорт", "Téléporter Une Fois", "Einmal teleportieren", "Dịch chuyển 1 lần", "Mag-teleport Nang Minsan", "1回テレポート", "1회 순간이동", "单次传送" },
    { "Auto-Teleport ke Posisi Terpilih", "Auto-Teleport ke Posisi Terpilih", "Teletransporte Automático a Posición", "Teletransporte Automático para Posição", "Авто-Телепорт к Позиции", "Téléportation Auto vers la Position", "Auto-Teleport zur ausgewählten Position", "Tự động dịch chuyển lặp lại", "Auto-Teleport sa Napiling Posisyon", "指定位置へループ自動テレポート", "선택한 위치로 자동 순간이동 반복", "循环自动传送到目标点" },
    { "Teleport ke Pemain", "Teleport ke Pemain", "Teletransportar al Jugador", "Teletransportar para o Jogador", "Телепорт к Игроку", "Téléporter vers le Joueur", "Zum Spieler teleportieren", "Dịch chuyển tới người chơi", "Mag-teleport sa Manlalaro", "対象プレイヤーへテレポート", "해당 플레이어에게 순간이동", "传送到指定玩家" },
    { "Mulai Spectate", "Mulai Spectate", "Comenzar Espectador", "Iniciar Espectador", "Начать Наблюдение", "Commencer à Observer", "Zuschauer-Modus starten", "Bắt đầu Theo dõi (Spectate)", "Simulan ang Panonood", "観戦モード開始", "관전 시작", "开始观战" },
    { "Follow Player (Auto-Walk Mengikuti Pemain)", "Ikuti Pemain (Follow Player)", "Seguir Jugador", "Seguir Jogador", "Следовать за Игроком", "Suivre le Joueur", "Spieler folgen", "Tự động bám đuôi người chơi", "Sundan ang Manlalaro", "自動追尾歩行 (Follow Player)", "플레이어 자동 추적", "自动跟随玩家走动" },
    { "Respawn Karakter", "Respawn Karakter", "Reaparecer Personaje", "Renascer Personagem", "Возродить Персонажа", "Faire Réapparaître le Personnage", "Charakter respawnen", "Hồi sinh lại nhân vật", "Muling Buhayin ang Karakter", "キャラクターをリスポーン", "캐릭터 리스폰", "角色重生" },
    { "Kill Character", "Bunuh Karakter (Reset)", "Eliminar Personaje", "Eliminar Personagem", "Самоубийство Персонажа", "Tuer le Personnage", "Charakter eliminieren", "Tự hủy nhân vật", "Patayin ang Karakter", "自爆 (リセット)", "캐릭터 자살 (리셋)", "角色自绝重置" },
    { "Destroy GUI", "Hancurkan & Tutup GUI", "Destruir GUI", "Destruir GUI", "Закрыть и Удалить GUI", "Détruire l'Interface", "GUI zerstören", "Đóng và Hủy GUI", "Wasakin ang GUI", "GUI破棄・終了", "GUI 파괴 및 종료", "销毁并关闭GUI" },
    { "2D Box ESP", "2D Box ESP", "ESP Caja 2D", "ESP Caixa 2D", "2D Боксы ESP", "ESP Boîte 2D", "2D-Box-ESP", "ESP Khung 2D", "2D Kahon ESP", "2DボックスESP", "2D 박스 ESP", "2D方框ESP" },
    { "3D Box ESP (Bounding Wireframe)", "3D Box ESP (Bounding Wireframe)", "ESP Caja 3D (Wireframe)", "ESP Caixa 3D (Wireframe)", "3D Боксы ESP (Wireframe)", "ESP Boîte 3D (Wireframe)", "3D-Box-ESP (Wireframe)", "ESP Khung 3D (Wireframe)", "3D Kahon ESP (Wireframe)", "3DボックスESP (Wireframe)", "3D 박스 ESP (와이어프레임)", "3D立体方框ESP (线框)" },
    { "3D Audio Sonar (Visualizer Suara)", "3D Audio Sonar (Visualizer Suara)", "Sonar de Audio 3D (Visualizador)", "Sonar de Áudio 3D (Visualizador)", "3D Аудио Сонар (Визуализатор)", "Sonar Audio 3D (Visualiseur)", "3D-Audio-Sonar (Visualizer)", "Sonar Âm thanh 3D (Hiển thị sóng âm)", "3D Audio Sonar (Visualizer ng Tunog)", "3Dオーディオソナー (音響可視化)", "3D 오디오 소나 (사운드 시각화)", "3D音频声呐 (声音可视化)" },
    { "Chams ESP", "Chams ESP", "Chams ESP", "Chams ESP", "Чамсы ESP", "Chams ESP", "Chams ESP", "Chams ESP (Hình bóng)", "Chams ESP", "透過発光ESP (Chams)", "실루엣 ESP (Chams)", "发光透视ESP (Chams)" },
    { "Chams Always On Top (Tembus Dinding)", "Chams Always On Top (Tembus Dinding)", "Chams Siempre Encima (Atravesar Paredes)", "Chams Sempre no Topo (Atravessar Paredes)", "Чамсы Поверх Стен", "Chams Toujours au Premier Plan", "Chams Immer im Vordergrund", "Chams Luôn hiển thị xuyên tường", "Chams Laging Nasa Ibabaw (Tagos Pader)", "Chams常時最前面表示 (壁透過)", "Chams 항상 위 (벽 뚫고 보기)", "Chams置顶透视 (穿墙可见)" },
    { "Fill Transparency Chams", "Fill Transparency Chams", "Transparencia de Relleno Chams", "Transparência de Preenchimento Chams", "Прозрачность Заливки Чамсов", "Transparence du Remplissage Chams", "Chams-Fülltransparenz", "Độ trong suốt ruột Chams", "Transparency ng Laman ng Chams", "Chams内部の透明度", "Chams 채우기 투명도", "Chams填充透明度" },
    { "Outline Transparency Chams", "Outline Transparency Chams", "Transparencia del Borde Chams", "Transparência do Contorno Chams", "Прозрачность Контура Чамсов", "Transparence du Contour Chams", "Chams-Konturtransparenz", "Độ trong suốt viền Chams", "Transparency ng Balangkas ng Chams", "Chams輪郭の透明度", "Chams 외곽선 투명도", "Chams轮廓透明度" },
    { "Health Bar ESP", "Health Bar ESP", "Barra de Vida ESP", "Barra de Vida ESP", "Полоска Здоровья ESP", "Barre de Vie ESP", "Lebensbalken-ESP", "Thanh máu ESP", "Buhay Bar ESP", "ヘルスバーESP", "체력바 ESP", "血条ESP" },
    { "Player ESP Boxes", "Player ESP Boxes", "Cajas ESP de Jugadores", "Caixas ESP de Jogadores", "Боксы ESP Игроков", "Boîtes ESP des Joueurs", "Spieler-Boxen-ESP", "Hộp ESP Người chơi", "Kahon ESP ng Manlalaro", "プレイヤーボックスESP", "플레이어 상자 ESP", "玩家方框ESP" },
    { "Player ESP Names", "Player ESP Names", "Nombres ESP de Jugadores", "Nomes ESP de Jogadores", "Имена ESP Игроков", "Noms ESP des Joueurs", "Spieler-Namen-ESP", "Tên ESP Người chơi", "Pangalan ESP ng Manlalaro", "プレイヤーネームESP", "플레이어 이름 ESP", "玩家名字ESP" },
    { "Player ESP Tracers", "Player ESP Tracers", "Trazadores ESP de Jugadores", "Linhas Guia ESP de Jogadores", "Трейсеры ESP Игроков", "Traceurs ESP des Joueurs", "Spieler-Tracers-ESP", "Tia chỉ đường ESP Người chơi", "Tracers ESP ng Manlalaro", "プレイヤートレーサー線ESP", "플레이어 추적선 ESP", "玩家射线ESP" },
    { "Skeleton ESP", "Skeleton ESP", "Esqueleto ESP", "Esqueleto ESP", "Скелеты ESP", "Squelette ESP", "Skelett-ESP", "Khung xương ESP", "Kalansay ESP", "ボーンESP (スケルトン)", "골격 ESP (스켈레톤)", "骨骼ESP" },
    { "Off-Screen Arrow (Panah Arah Musuh)", "Off-Screen Arrow (Panah Arah Musuh)", "Flechas Fuera de Pantalla (Enemigos)", "Setas Fora da Tela (Inimigos)", "Стрелки Вне Экрана (Враги)", "Flèche Hors-Écran (Ennemis)", "Pfeile außerhalb des Bildschirms", "Mũi tên chỉ hướng ngoài màn hình", "Palaso sa Labas ng Screen (Direksyon ng Kaaway)", "画面外インジケーター矢印", "화면 밖 적 방향 화살표", "屏幕外敌方方向箭头" },
    { "Auto-LOD ESP (Hemat FPS Jarak Jauh)", "Auto-LOD ESP (Hemat FPS Jarak Jauh)", "Auto-LOD ESP (Ahorro de FPS)", "Auto-LOD ESP (Economizar FPS)", "Авто-LOD ESP (Экономия FPS)", "Auto-LOD ESP (Économie de FPS)", "Auto-LOD-ESP (FPS-Schonung)", "Auto-LOD ESP (Tiết kiệm FPS từ xa)", "Auto-LOD ESP (Pagtitipid ng FPS)", "自動LOD ESP (遠距離FPS節約)", "자동 LOD ESP (원거리 FPS 절약)", "自动LOD ESP (远距离省帧率)" },
    { "Batas Jarak Dekat LOD (studs)", "Batas Jarak Dekat LOD (studs)", "Límite Distancia Cercana LOD (studs)", "Limite Distância Próxima LOD (studs)", "Ближняя Дистанция LOD (стадс)", "Distance Courte LOD (studs)", "LOD-Nahdistanzgrenze (Studs)", "Khoảng cách LOD gần (studs)", "Hangganan ng Malapit na LOD (studs)", "LOD近距離しきい値 (studs)", "LOD 근거리 임계값 (studs)", "LOD近距离阈值 (studs)" },
    { "Jarak Maksimal ESP (studs)", "Jarak Maksimal ESP (studs)", "Distancia Máxima ESP (studs)", "Distância Máxima ESP (studs)", "Максимальная Дистанция ESP (стадс)", "Distance Maximale ESP (studs)", "Maximale ESP-Distanz (Studs)", "Khoảng cách tối đa ESP (studs)", "Pinakamalayong Distansya ng ESP (studs)", "ESP最大描画距離 (studs)", "ESP 최대 거리 (studs)", "ESP最大距离 (studs)" },
    { "Occlusion Check (Sembunyikan Terhalang Tembok)", "Occlusion Check (Sembunyikan Terhalang Tembok)", "Verificación de Oclusión (Ocultar tras Paredes)", "Verificação de Oclusão (Ocultar Atrás de Paredes)", "Проверка Окклюзии (Скрывать за Стенами)", "Vérification d'Occlusion (Masquer derrière les Murs)", "Verdeckungstest (Hinter Wänden verbergen)", "Kiểm tra bị chắn (Ẩn khi sau tường)", "Pagsusuri sa Harang (Itago Likod ng Pader)", "遮蔽チェック (壁裏の非表示)", "차폐 검사 (벽 뒤 숨기기)", "遮挡检查 (隐藏墙后目标)" },
    { "Frekuensi Raycast Occlusion (frames)", "Frekuensi Raycast Occlusion (frames)", "Frecuencia de Raycast de Oclusión (cuadros)", "Frequência de Raycast de Oclusão (quadros)", "Частота Окклюзии Raycast (кадры)", "Fréquence Raycast Occlusion (images)", "Raycast-Verdeckungsintervall (Frames)", "Tần suất Raycast bị chắn (frames)", "Dalas ng Raycast sa Harang (frames)", "遮蔽Raycast更新頻度 (フレーム)", "차폐 Raycast 빈도 (프레임)", "遮挡射线检测频率 (帧)" },
    { "Ukuran Teks Label ESP", "Ukuran Teks Label ESP", "Tamaño de Texto ESP", "Tamanho do Texto ESP", "Размер Текста ESP", "Taille du Texte ESP", "ESP-Textgröße", "Cỡ chữ nhãn ESP", "Laki ng Teksto ng ESP", "ESPテキストフォントサイズ", "ESP 텍스트 글꼴 크기", "ESP文本字体大小" },
    { "Team Check ESP (Hanya Musuh)", "Team Check ESP (Hanya Musuh)", "Filtro de Equipo ESP (Solo Enemigos)", "Filtro de Time ESP (Apenas Inimigos)", "Проверка Команды ESP (Только Враги)", "Vérification d'Équipe ESP (Ennemis Uniquement)", "Team-Filter-ESP (Nur Feinde)", "Lọc Đội ESP (Chỉ hiển thị Kẻ địch)", "Pagsusuri ng Team sa ESP (Kaaway Lamang)", "ESPチームチェック (敵のみ)", "ESP 팀 확인 (적군만)", "ESP队伍判定 (仅敌人)" },
    { "Tampilkan Jarak pada Label [m]", "Tampilkan Jarak pada Label [m]", "Mostrar Distancia en Etiqueta [m]", "Mostrar Distância na Etiqueta [m]", "Показывать Дистанцию в Метрах [м]", "Afficher la Distance sur le Label [m]", "Distanz auf Beschriftung anzeigen [m]", "Hiển thị khoảng cách trên nhãn [m]", "Ipakita ang Layo sa Label [m]", "ラベルに距離を表示 [m]", "라벨에 거리 표시 [m]", "在标签上显示距离 [m]" },
    { "Tracer Origin", "Tracer Origin", "Origen del Trazador", "Origem da Linha Guia", "Начало Трейсера", "Origine du Traceur", "Tracer-Ursprung", "Gốc tia chỉ đường", "Pinagmulan ng Tracer", "トレーサーの起点", "추적선 시작 위치", "射线起点位置" },
    { "Entity & Monster Radar", "Entity & Monster Radar", "Radar de Entidades y Monstruos", "Radar de Entidades e Monstros", "Радар Сущностей и Монстров", "Radar d'Entités et Monstres", "Entitäten- & Monster-Radar", "Radar Thực thể & Quái vật", "Radar ng Halimaw at Nilalang", "モンスター＆エンティティレーダー", "몬스터 및 엔티티 레이더", "怪物与实体雷达" },
    { "Item & Objective Radar", "Item & Objective Radar", "Radar de Objetos y Objetivos", "Radar de Itens e Objetivos", "Радар Предметов и Задач", "Radar d'Objets et d'Objectifs", "Gegenstands- & Ziel-Radar", "Radar Vật phẩm & Mục tiêu", "Radar ng Gamit at Layunin", "アイテム＆目標オブジェクトレーダー", "아이템 및 미션 목표 레이더", "物品与任务目标雷达" },
    { "Crosshair Overlay (Bidik Presisi Layar)", "Crosshair Overlay (Bidik Presisi Layar)", "Mira en Pantalla (Precisión)", "Mira na Tela (Precisão)", "Прицел Поверх Экрана (Точность)", "Réticule à l'Écran (Précision)", "Fadenkreuz-Overlay (Präzision)", "Tâm ngắm màn hình (Ngắm chuẩn xác)", "Asintahan sa Gitna ng Screen (Presisyon)", "画面中央クロスヘア照準器", "화면 중앙 크로스헤어 조준선", "屏幕中心准星十字" },
    { "Speed Lines (Efek Garis Kecepatan)", "Speed Lines (Efek Garis Kecepatan)", "Líneas de Velocidad (Efecto)", "Linhas de Velocidade (Efeito)", "Линии Скорости (Эффект)", "Lignes de Vitesse (Effet)", "Geschwindigkeitsstreifen-Effekt", "Vạch tốc độ (Hiệu ứng di chuyển nhanh)", "Mga Linya ng Bilis (Epekto)", "スピードライン (速度演出効果)", "스피드 라인 (속도 효과)", "速度特效线条" },
    { "Grenade Trajectory (Prediksi Lintasan Granat)", "Grenade Trajectory (Prediksi Lintasan Granat)", "Trayectoria de Granadas (Predicción)", "Trajetória de Granadas (Previsão)", "Траектория Гранат (Прогноз)", "Trajectoire de Grenade (Prédiction)", "Granaten-Flugbahn (Vorhersage)", "Quỹ đạo lựu đạn (Dự đoán đường bay)", "Direksyon ng Granada (Pagtantiya)", "グレネード投擲軌道予測", "수류탄 궤적 예측", "投掷物投掷轨迹预测" },
    { "Tampilkan Lintasan Selalu (Tanpa Granat)", "Tampilkan Lintasan Selalu (Tanpa Granat)", "Mostrar Trayectoria Siempre (Sin Granada)", "Mostrar Trajetória Sempre (Sem Granada)", "Показывать Траекторию Всегда (Без Гранаты)", "Toujours Afficher la Trajectoire", "Flugbahn immer anzeigen (ohne Granate)", "Luôn hiển thị đường ngắm (Kể cả không cầm)", "Palaging Ipakita ang Daanan (Kahit Walang Granada)", "常に軌道を表示 (非所持時も有効)", "궤적 항상 표시 (수류탄 미소지 시에도)", "始终显示投掷轨迹" },
    { "Clear Fog (Hapus Kabut Map)", "Clear Fog (Hapus Kabut Map)", "Quitar Niebla del Mapa", "Remover Neblina do Mapa", "Удалить Туман с Карты", "Supprimer le Brouillard de la Carte", "Kartennebel entfernen", "Xóa sương mù trên bản đồ", "Alisin ang Ulap sa Mapa", "マップの霧を除去 (クリアフォグ)", "맵 안개 제거 (클리어 포그)", "清除全图迷雾 (Clear Fog)" },
    { "Clear Fog, Blur & Atmosphere (Hapus Kabut & Blur)", "Clear Fog, Blur & Atmosphere (Hapus Kabut & Blur)", "Quitar Niebla, Desenfoque y Atmósfera", "Remover Neblina, Desfoque e Atmosfera", "Удалить Туман, Размытие и Атмосферу", "Supprimer Brouillard, Flou et Atmosphère", "Nebel, Unschärfe & Atmosphäre entfernen", "Xóa sạch sương mù, mờ nét & khí quyển", "Alisin ang Ulap, Labo at Atmospera", "霧・ブラー・大気エフェクト全解除", "안개, 블러, 대기 효과 전체 제거", "去除全图迷雾、模糊与大气层" },
    { "Atmosphere Density Changer (Kerapatan Kabut)", "Atmosphere Density Changer (Kerapatan Kabut)", "Densidad de Atmósfera (Niebla)", "Densidade da Atmosfera (Neblina)", "Плотность Атмосферы (Туман)", "Densité de l'Atmosphère (Brouillard)", "Atmosphärendichte (Nebel)", "Điều chỉnh mật độ khí quyển", "Bilis at Kapal ng Atmospera (Ulap)", "大気密度スライダー (霧の濃さ)", "대기 밀도 조절 (안개 밀도)", "大气密度调节 (雾气浓度)" },
    { "Bloom Effect Enhancer (Cahaya Sinematik)", "Bloom Effect Enhancer (Cahaya Sinematik)", "Efecto Bloom (Luz Cinemática)", "Efeito Bloom (Luz Cinemática)", "Усилитель Bloom (Кинематографичный Свет)", "Effet Bloom (Lumière Cinématique)", "Bloom-Effekt (Filmreifes Leuchten)", "Hiệu ứng lóa sáng điện ảnh (Bloom)", "Epekto ng Bloom (Pelikulang Liwanag)", "ブルーム効果強化 (シネマティック発光)", "블룸 효과 강화 (영화 같은 광원)", "泛光效果增强 (电影级光效)" },
    { "Auto Day/Night Cycle (Siklus Siang Malam)", "Auto Day/Night Cycle (Siklus Siang Malam)", "Ciclo Día/Noche Automático", "Ciclo Dia/Noite Automático", "Авто-Смена Дня и Ночи", "Cycle Jour/Nuit Automatique", "Automatischer Tag-/Nacht-Zyklus", "Tự động đổi chu kỳ ngày và đêm", "Awtomatikong Siklo ng Araw at Gabi", "自動昼夜サイクル", "자동 주야간 순환 사이클", "自动昼夜时间循环" },
    { "Lock Jam Dunia (Custom Time)", "Lock Jam Dunia (Custom Time)", "Fijar Hora del Mundo (Personalizada)", "Travar Hora do Mundo (Personalizada)", "Зафиксировать Время Мира", "Verrouiller l'Heure du Monde", "Weltzeit sperren (Benutzerdefiniert)", "Khóa thời gian trong thế giới (Tùy chọn)", "I-lock ang Oras ng Mundo", "ワールド時間固定 (カスタムタイム)", "월드 시간 고정 (사용자 지정 시간)", "锁定世界时间 (自定义小时)" },
    { "Aspect Ratio Scaler (Ubah Rasio Layar)", "Aspect Ratio Scaler (Ubah Rasio Layar)", "Escalador de Relación de Aspecto", "Ajustar Proporção de Tela", "Масштабирование Соотношения Сторон", "Ajuster le Format d'Écran", "Seitenverhältnis anpassen", "Tùy biến tỉ lệ khung hình màn hình", "Pampabago ng Hugis ng Screen (Aspect Ratio)", "画面アスペクト比スケール変更", "화면 종횡비 스케일러", "画面长宽比调节 (拉伸/宽屏)" },
    { "FPS Boost (Low Graphics)", "FPS Boost (Low Graphics)", "Mejora de FPS (Gráficos Bajos)", "Aumentar FPS (Gráficos Baixos)", "Повышение FPS (Низкая Графика)", "Boost FPS (Graphismes Bas)", "FPS-Boost (Niedrige Grafik)", "Tăng tốc FPS (Đồ họa tối thiểu)", "Pampabilis ng FPS (Mababang Graphics)", "FPSブースト (低グラフィック最適化)", "FPS 부스트 (저사양 그래픽)", "帧率提升 (极简画质)" },
    { "Optimasi FPS Boost (Low Graphics)", "Optimasi FPS Boost (Low Graphics)", "Optimización FPS (Gráficos Bajos)", "Otimização de FPS (Gráficos Baixos)", "Оптимизация FPS (Низкая Графика)", "Optimisation FPS (Graphismes Bas)", "FPS-Optimierung (Niedrige Grafik)", "Tối ưu hóa FPS (Đồ họa siêu nhẹ)", "Pampataas ng FPS (Mababang Graphics)", "FPSブースト最適化 (低負荷)", "FPS 부스트 최적화 (저사양)", "极速帧率优化 (极低画质)" },
    { "Unlock Max Zoom", "Unlock Max Zoom", "Desbloquear Zoom Máximo", "Desbloquear Zoom Máximo", "Разблокировать Максимальный Зум", "Débloquer le Zoom Maximum", "Maximalen Zoom freischalten", "Mở khóa khoảng cách thu phóng tối đa", "I-unlock ang Pinakamalayong Zoom", "カメラ最大ズーム解除", "카메라 최대 줌 잠금 해제", "解锁相机超远视角限制" },
    { "Freecam", "Freecam", "Cámara Libre", "Câmera Livre", "Свободная Камера", "Caméra Libre", "Freie Kamera (Freecam)", "Góc quay camera tự do (Freecam)", "Malayang Kamera (Freecam)", "フリーカメラ (Freecam)", "자유 카메라 (Freecam)", "自由航拍摄像机 (Freecam)" },
    { "Ghost Mode (Transparansi Tubuh Hantu)", "Ghost Mode (Transparansi Tubuh Hantu)", "Modo Fantasma (Cuerpo Transparente)", "Modo Fantasma (Corpo Transparente)", "Режим Призрака (Прозрачность)", "Mode Fantôme (Corps Transparent)", "Geistermodus (Transparenter Körper)", "Chế độ ma (Thân hình trong suốt)", "Anyong Multo (Malinaw na Katawan)", "ゴーストモード (半透明アバター)", "고스트 모드 (반투명 유령 바디)", "幽灵半透明隐匿模式" },
    { "Superhero Landing (Shockwave & Guncangan Kamera)", "Superhero Landing (Shockwave & Guncangan Kamera)", "Aterrizaje de Superhéroe (Onda Expansiva)", "Pouso de Super-Herói (Onda de Choque)", "Приземление Супергероя (Ударная Волна)", "Atterrissage de Super-Héros (Onde de Choc)", "Superhelden-Landung (Schockwelle)", "Đáp đất siêu anh hùng (Sóng chấn động)", "Superhero Landing (Yanig at Lindol)", "スーパーヒーロー着地 (衝撃波＆画面揺れ)", "슈퍼히어로 착지 (충격파 및 화면 흔들림)", "英雄登场砸地 (冲击波与震动)" },
    { "Aimbot Target Part", "Aimbot Target Part", "Parte Objetivo del Aimbot", "Parte Alvo do Aimbot", "Целевая Часть Тела Аимбота", "Partie Cible de l'Aimbot", "Aimbot-Zielkörperteil", "Bộ phận mục tiêu Aimbot", "Bahagi ng Katawan na Aasintahin", "エイムボット対象部位", "에임봇 타겟 부위", "自瞄锁定位 (头/躯干)" },
    { "Mode Target Aimbot", "Mode Target Aimbot", "Modo de Objetivo del Aimbot", "Modo de Alvo do Aimbot", "Режим Выбора Цели Аимбота", "Mode de Ciblage de l'Aimbot", "Aimbot-Zielmodus", "Chế độ mục tiêu Aimbot", "Uri ng Pagpili ng Target ng Aimbot", "エイムボット優先ターゲット方式", "에임봇 타겟 선정 방식", "自瞄目标判定模式" },
    { "Tampilkan Lingkaran FOV", "Tampilkan Lingkaran FOV", "Mostrar Círculo FOV", "Mostrar Círculo FOV", "Показать Круг FOV", "Afficher le Cercle FOV", "FOV-Kreis anzeigen", "Hiển thị vòng tròn tầm nhìn FOV", "Ipakita ang Bilog ng FOV", "FOVサークルを表示", "FOV 원 표시", "显示视野FOV瞄准范围圆圈" },
    { "Wall Check (Hanya yang Terlihat)", "Wall Check (Hanya yang Terlihat)", "Comprobación de Pared (Solo Visibles)", "Verificação de Parede (Apenas Visíveis)", "Проверка Стен (Только Видимые)", "Vérification de Mur (Visibles Uniquement)", "Wandprüfung (Nur sichtbare Ziele)", "Kiểm tra tường (Chỉ ngắm mục tiêu thấy được)", "Suriin ang Pader (Kitang Kaaway Lamang)", "壁チェック (視界内の敵のみ)", "벽 관통 방지 (시야 내 대상만)", "掩体验证 (仅锁定可见目标)" },
    { "Team Check (Hanya Musuh)", "Team Check (Hanya Musuh)", "Comprobación de Equipo (Solo Enemigos)", "Verificação de Time (Apenas Inimigos)", "Проверка Команды (Только Враги)", "Vérification d'Équipe (Ennemis Uniquement)", "Team-Filter (Nur Feinde)", "Kiểm tra Đội (Chỉ nhắm Kẻ địch)", "Suriin ang Grupo (Kaaway Lamang)", "チームチェック (敵チームのみ)", "팀 확인 (적군만 타겟팅)", "队伍检查 (仅锁定敌方)" },
    { "Target Termasuk NPCs / Dummies", "Target Termasuk NPCs / Dummies", "Incluir NPCs y Muñecos de Práctica", "Incluir NPCs e Bonecos de Teste", "Включать NPC и Манекены", "Inclure PNJ et Mannequins", "NPCs & Dummies einbeziehen", "Bao gồm cả NPC và Hình nhân", "Isama ang mga NPC at Dummy", "NPCやダミー人形をターゲットに含める", "NPC 및 더미 포함 타겟팅", "包含NPC与假人目标" },
    { "Target Players", "Target Players", "Apuntar a Jugadores", "Mirar em Jogadores", "Целиться в Игроков", "Cibler les Joueurs", "Spieler ins Visier nehmen", "Nhắm vào người chơi", "Targetin ang mga Manlalaro", "プレイヤーを対象にする", "플레이어 타겟팅", "锁定玩家目标" },
    { "Target NPCs / Dummies", "Target NPCs / Dummies", "Apuntar a NPCs / Muñecos", "Mirar em NPCs / Bonecos", "Целиться в NPC / Манекены", "Cibler les PNJ / Mannequins", "NPCs / Dummies anvisieren", "Nhắm vào NPC / Hình nhân", "Targetin ang NPC / Dummies", "NPC / ダミーを対象にする", "NPC / 더미 타겟팅", "锁定NPC/假人目标" },
    { "Highlight Target (Glow Merah)", "Highlight Target (Glow Merah)", "Resaltar Objetivo (Brillo Rojo)", "Destacar Alvo (Brilho Vermelho)", "Подсветка Цели (Красное Свечение)", "Mettre en Valeur la Cible (Lueur Rouge)", "Ziel hervorheben (Rotes Leuchten)", "Làm nổi bật mục tiêu (Viền đỏ)", "Palitawin ang Target (Pulang Liwanag)", "ターゲット強調表示 (赤色発光)", "타겟 하이라이트 (빨간색 발광)", "高亮锁定目标 (红色发光)" },
    { "Triggerbot (Auto-Shoot saat Bidikan Pas)", "Triggerbot (Auto-Shoot saat Bidikan Pas)", "Triggerbot (Disparo Automático)", "Triggerbot (Disparo Automático)", "Триггербот (Авто-Выстрел при Наведении)", "Triggerbot (Tir Automatique)", "Triggerbot (Automatischer Schuss)", "Triggerbot (Tự động nổ súng khi đúng tâm)", "Triggerbot (Kusang Paputok Kapag Nakatutok)", "トリガーボット (照準一致時に自動発砲)", "트리거봇 (조준점 일치 시 자동 발사)", "自动扳机 (准星瞄准时自动开火)" },
    { "Auto Crouch on Shoot (Tunduk saat Menembak)", "Auto Crouch on Shoot (Tunduk saat Menembak)", "Agacharse Automáticamente al Disparar", "Abaixar Automaticamente ao Atirar", "Авто-Приседание при Выстреле", "S'accroupir Automatiquement en Tirant", "Automatisches Ducken beim Schießen", "Tự động ngồi xuống khi khai hỏa", "Kusang Yumukod Habang Bumabari", "射撃時自動しゃがみ (被弾面積最小化)", "사격 시 자동 웅크리기", "开枪自动下蹲 (降低受击面积)" },
    { "Stop Move on Shoot (Akurasi Maksimal / Zero Spread)", "Stop Move on Shoot (Akurasi Maksimal / Zero Spread)", "Detener Movimiento al Disparar (Cero Dispersión)", "Parar Movimento ao Atirar (Precisão Máxima)", "Остановка при Выстреле (Максимальная Точность)", "Arrêt du Mouvement au Tir (Zéro Dispersion)", "Bewegungsstopp beim Schuss (Maximale Präzision)", "Dừng bước khi bắn (Độ chính xác 100%)", "Huminto Habang Bumabari (Presisyong Walang Sabog)", "射撃時自動静止 (ブレゼロ・最大精度)", "사격 시 자동 정지 (탄퍼짐 0% 극대화)", "开枪瞬间急停 (零弹道扩散)" },
    { "Jiggle Peek (Auto Strafe Sudut Tembak)", "Jiggle Peek (Auto Strafe Sudut Tembak)", "Jiggle Peek (Ametrallamiento de Esquina)", "Jiggle Peek (Passos Rápidos na Esquina)", "Джиггл Пик (Быстрое Выглядывание)", "Jiggle Peek (Mouvement Rapide d'Angle)", "Jiggle Peek (Schnelles Schulterblick-Strafing)", "Jiggle Peek (Nhấp nhả góc bắn liên tục)", "Jiggle Peek (Mabilis na Silip sa Sulok)", "ジグルピーク (遮蔽物からの反復顔出し射撃)", "지글 픽 (코너 빠른 와리가리 사격)", "小幅探头射击 (Jiggle Peek)" },
    { "Punch Force Multiplier (Super Knockback Lawan)", "Punch Force Multiplier (Super Knockback Lawan)", "Multiplicador de Golpe (Super Empuje)", "Multiplicador de Soco (Super Repulsão)", "Множитель Силы Удара (Супер-Отброс)", "Multiplicateur de Coup de Poing (Super Éjection)", "Schlagkraft-Multiplikator (Extremer Rückstoß)", "Hệ số lực đấm (Đánh bay đối thủ cực mạnh)", "Lakas ng Suntok Multiplier (Super Talsik)", "パンチ威力倍率 (超ノックバック吹っ飛ばし)", "펀치 위력 배율 (슈퍼 넉백 날리기)", "重拳击退倍率 (超强击飞击退)" },
    { "Target Limb Hitbox", "Target Limb Hitbox", "Extremidad Objetivo de Hitbox", "Membro Alvo da Hitbox", "Целевая Конечность Хитбокса", "Membre Cible de la Hitbox", "Hitbox-Zielgliedmaße", "Chi cơ thể mục tiêu của Hitbox", "Bahagi ng Katawan ng Hitbox", "ヒットボックス拡大部位", "히트박스 확장 부위", "判定范围扩展肢体" },
    { "Transparansi Hitbox", "Transparansi Hitbox", "Transparencia de Hitbox", "Transparência da Hitbox", "Прозрачность Хитбокса", "Transparence de la Hitbox", "Hitbox-Transparenz", "Độ mờ của Hitbox", "Transparency ng Hitbox", "ヒットボックスの透明度", "히트박스 투명도", "判定框透明度" },
    { "Hitbox Collisions (Tabrakan Fisik)", "Hitbox Collisions (Tabrakan Fisik)", "Colisiones de Hitbox (Física)", "Colisão de Hitbox (Física)", "Коллизия Хитбокса (Физика)", "Collisions de Hitbox (Physique)", "Hitbox-Kollision (Physik)", "Va chạm vật lý Hitbox", "Banggaan ng Hitbox (Pisikal)", "ヒットボックスの物理衝突判定", "히트박스 물리 충돌 판정", "判定框物理碰撞体积" },
    { "Proximity Shrink (Kecilkan Hitbox Jarak Dekat)", "Proximity Shrink (Kecilkan Hitbox Jarak Dekat)", "Encogimiento por Proximidad (Cerca)", "Encolhimento por Proximidade (Perto)", "Уменьшение вблизи (Снижение Хитбокса)", "Rétrécissement de Proximité", "Näherungsschrumpfung (Nahkampf-Schutz)", "Thu nhỏ Hitbox khi ở khoảng cách gần", "Paliitin ang Hitbox Kapag Malapit", "近接時自動縮小 (至近距離の判定保護)", "근접 시 히트박스 자동 축소", "近距自适应缩小 (防止贴脸卡模)" },
    { "Hitbox Displace / Offset (Bypass Hitbox)", "Hitbox Displace / Offset (Bypass Hitbox)", "Desplazamiento de Hitbox (Bypass)", "Deslocamento de Hitbox (Bypass)", "Смещение Хитбокса (Обход Защиты)", "Décalage de Hitbox (Contournement)", "Hitbox-Versatz (Bypass)", "Dịch chuyển vị trí Hitbox (Vượt mặt chống gian lận)", "Offset ng Hitbox (Bypass)", "ヒットボックス位置オフセット (Bypass)", "히트박스 위치 오프셋 (우회)", "判定框错位位移 (绕过检测)" },
    { "ForceField Check (Abaikan Pemain Kebal)", "ForceField Check (Abaikan Pemain Kebal)", "Ignorar Jugadores con ForceField (Invencibles)", "Ignorar Jogadores com ForceField (Invulneráveis)", "Проверка ForceField (Игнорировать Неуязвимых)", "Vérifier le Champ de Force (Ignorer Invulnérables)", "Schutzschild-Filter (Unverwundbare ignorieren)", "Bỏ qua người chơi đang bất tử ForceField", "Pagsusuri sa ForceField (Huwag Pansinin ang May Nga-baluti)", "無敵シールドチェック (ForceField除外)", "무적 실드 체크 (포스필드 플레이어 제외)", "无敌力场过滤 (忽略刚复活玩家)" },
    { "Mode Filter Tim & Pemain", "Mode Filter Tim & Pemain", "Modo de Filtro de Equipo y Jugadores", "Modo de Filtro de Time e Jogadores", "Режим Фильтрации Команд и Игроков", "Mode de Filtrage d'Équipe et Joueurs", "Team- & Spieler-Filtermodus", "Chế độ lọc Đội & Người chơi", "Paraan ng Pagsala sa Grupo at Manlalaro", "チーム・プレイヤー選別フィルター方式", "팀 및 플레이어 필터 모드", "队伍与玩家过滤筛选模式" },
    { "Whitelist Teams", "Whitelist Teams", "Equipos Permitidos (Whitelist)", "Times Permitidos (Whitelist)", "Белый Список Команд", "Liste Blanche des Équipes", "Erlaubte Teams (Whitelist)", "Đội ngũ được miễn trừ (Whitelist)", "Listahan ng Ligtas na Grupo", "ホワイトリスト登録チーム", "화이트리스트 팀", "队伍白名单" },
    { "Blacklist Teams", "Blacklist Teams", "Equipos Bloqueados (Blacklist)", "Times Bloqueados (Blacklist)", "Чёрный Список Команд", "Liste Noire des Équipes", "Blockierte Teams (Blacklist)", "Đội ngũ bị chặn (Blacklist)", "Listahan ng Bawal na Grupo", "ブラックリスト登録チーム", "블랙리스트 팀", "队伍黑名单" },
    { "Whitelist Players", "Whitelist Players", "Jugadores Permitidos (Whitelist)", "Jogadores Permitidos (Whitelist)", "Белый Список Игроков", "Liste Blanche des Joueurs", "Erlaubte Spieler (Whitelist)", "Người chơi được miễn trừ (Whitelist)", "Listahan ng Ligtas na Manlalaro", "ホワイトリスト登録プレイヤー", "화이트리스트 플레이어", "玩家白名单" },
    { "Blacklist Players", "Blacklist Players", "Jugadores Bloqueados (Blacklist)", "Jogadores Bloqueados (Blacklist)", "Чёрный Список Игроков", "Liste Noire des Joueurs", "Blockierte Spieler (Blacklist)", "Người chơi bị chặn (Blacklist)", "Listahan ng Bawal na Manlalaro", "ブラックリスト登録プレイヤー", "블랙리스트 플레이어", "玩家黑名单" },
    { "Desync Visualizer (Wireframe Hitbox Bayangan)", "Desync Visualizer (Wireframe Hitbox Bayangan)", "Visualizador de Desync (Hitbox Fantasma)", "Visualizador de Desync (Hitbox Fantasma)", "Визуализатор Десинка (Призрачный Хитбокс)", "Visualiseur de Désynchronisation (Hitbox Fantôme)", "Desync-Visualisierer (Geister-Hitbox)", "Hiển thị vị trí Desync (Khung hitbox bóng ma)", "Tagakita ng Desync (Aninong Hitbox)", "デシンク可視化 (サーバー側の幻影ヒットボックス)", "디싱크 시각화 (서버 측 허상 히트박스)", "反自瞄虚位可视化 (幽灵假体线框)" },
    { "Desync Random Position Jitter", "Desync Random Position Jitter", "Jitter Aleatorio de Posición Desync", "Jitter Aleatório de Posição Desync", "Случайный Джиттер Позиции Десинка", "Jitter Aléatoire de Position Désynchronisée", "Zufälliger Desync-Positions-Jitter", "Rung lắc ngẫu nhiên vị trí Desync", "Random na Panginginig ng Posisyon sa Desync", "デシンク座標ランダムジッター", "디싱크 무작위 위치 지터", "虚位坐标随机抖动" },
    { "Desync Random Rotation Jitter", "Desync Random Rotation Jitter", "Jitter Aleatorio de Rotación Desync", "Jitter Aleatório de Rotação Desync", "Случайный Джиттер Вращения Десинка", "Jitter Aléatoire de Rotation Désynchronisée", "Zufälliger Desync-Rotations-Jitter", "Xoay góc ngẫu nhiên Desync", "Random na Pag-ikot ng Desync", "デシンク回転ランダムジッター", "디싱크 무작위 회전 지터", "虚位朝向随机旋转" },
    { "Lag Simulator / Network Jitter (Palsukan Koneksi Patah-Patah)", "Lag Simulator / Network Jitter (Palsukan Koneksi Patah-Patah)", "Simulador de Lag / Jitter de Red", "Simulador de Lag / Jitter de Rede", "Симулятор Лагов / Сетевой Джиттер", "Simulateur de Lag / Jitter Réseau", "Lag-Simulator / Netzwerk-Jitter", "Mô phỏng mạng giật lag giả lập", "Panggaya ng Lag sa Network (Sirang Koneksyon)", "ラグシミュレーター (偽装ネットワーク遅延)", "랙 시뮬레이터 (네트워크 지터 모의)", "模拟网络卡顿/丢包 (伪装瞬移跳帧)" },
    { "Fly Mode (Terbang)", "Fly Mode (Terbang)", "Modo de Vuelo (Volar)", "Modo de Voo (Voar)", "Режим Полёта", "Mode Vol", "Flugmodus", "Chế độ bay lượn (Fly)", "Lumipad (Fly Mode)", "飛行モード (Fly)", "비행 모드 (Fly)", "自由飞行模式 (Fly)" },
    { "Vehicle Fly", "Vehicle Fly", "Vuelo de Vehículos", "Voo de Veículos", "Полёт на Транспорте", "Vol en Véhicule", "Fahrzeug-Flug", "Bay phương tiện cơ giới", "Lumipad Gamit ang Sasakyan", "乗り物飛行モード", "차량 탑승 비행", "载具空中飞行" },
    { "Noclip (Tembus Dinding)", "Noclip (Tembus Dinding)", "Atravesar Paredes (Noclip)", "Atravessar Paredes (Noclip)", "Сквозь Стены (Ноуклип)", "Passe-Muraille (Noclip)", "Durch Wände gehen (Noclip)", "Đi xuyên tường (Noclip)", "Tumatagos sa Pader (Noclip)", "壁すり抜け (Noclip)", "벽 뚫고 이동 (Noclip)", "穿墙透体模式 (Noclip)" },
    { "Air Walk (Pijakan Melayang)", "Air Walk (Pijakan Melayang)", "Caminar por el Aire", "Andar no Ar", "Хождение по Воздуху", "Marcher dans les Airs", "Luftlaufen (Air Walk)", "Đi bộ trên không khí (Air Walk)", "Lumakad sa Hangin", "空中歩行 (エアウォーク)", "공중 걷기 (에어워크)", "空中漫步 (踏空而行)" },
    { "Air-Strafing (Manuver di Udara)", "Air-Strafing (Manuver di Udara)", "Maniobras en el Aire (Air-Strafe)", "Manobras no Ar (Air-Strafe)", "Маневрирование в Воздухе (Air-Strafe)", "Manoeuvre Aérienne (Air-Strafe)", "Luftmanöver (Air-Strafe)", "Đổi hướng linh hoạt trên không (Air-Strafe)", "Pag-iwas sa Hangin (Air-Strafe)", "空中ストレイフ移動 (Air-Strafe)", "공중 스트레이프 기동", "空中转向机动 (Air-Strafe)" },
    { "Spider Climb (Merayap Dinding)", "Spider Climb (Merayap Dinding)", "Escalar Paredes como Araña", "Escalar Paredes como Aranha", "Лазание по Стенам (Паук)", "Escalade Murale (Araignée)", "Spinnen-Klettern an Wänden", "Bò leo tường như nhện", "Umakyat sa Pader na Parang Gagamba", "スパイダークライム (壁面よじ登り)", "스파이더 클라이밍 (벽 타기)", "蜘蛛爬墙 (垂直走壁)" },
    { "True Wall Walker", "True Wall Walker", "Caminar por Paredes Verdadero", "Caminhar por Paredes Real", "Настоящий Ходок по Стенам", "Véritable Marcheur de Mur", "Echtes Wandlaufen", "Đi bộ trên tường thực tế", "Tunay na Lakad sa Pader", "完全重力無視・壁歩行 (Wall Walker)", "진정한 벽면 보행 (월 워커)", "反重力壁面贴行" },
    { "Blink Dash (Tekan Q untuk Teleport Maju)", "Blink Dash (Tekan Q untuk Teleport Maju)", "Blink Dash (Pulsa Q para Teleportarse)", "Blink Dash (Pressione Q para Avançar)", "Блинк Дэш (Нажмите Q для Рывка)", "Blink Dash (Appuyez sur Q pour Avancer)", "Blink Dash (Q drücken für Teleport-Sprint)", "Blink Dash (Nhấn Q dịch chuyển vọt tới trước)", "Blink Dash (Pindutin ang Q para Lumundag Paharap)", "ブリンクダッシュ (Qキーで前方瞬間移動)", "블링크 대시 (Q 키로 전방 순간이동)", "瞬移闪击 (按Q键向前瞬间位移)" },
    { "Trigger Blink Dash Sekarang", "Trigger Blink Dash Sekarang", "Activar Blink Dash Ahora", "Ativar Blink Dash Agora", "Активировать Блинк Дэш Сейчас", "Déclencher Blink Dash Maintenant", "Blink Dash jetzt auslösen", "Kích hoạt lướt Blink Dash ngay", "Gawin ang Blink Dash Ngayon", "今すぐブリンクダッシュを実行", "지금 블링크 대시 실행", "立即触发向前瞬移闪击" },
    { "Walkspeed Type", "Walkspeed Type", "Tipo de Velocidad de Movimiento", "Tipo de Velocidade de Movimento", "Тип Скорости Передвижения", "Type de Vitesse de Marche", "Laufgeschwindigkeits-Typ", "Kiểu tốc độ di chuyển", "Uri ng Bilis ng Paglakad", "移動速度加速方式", "이동 속도 적용 방식", "移速加成模式" },
    { "Infinite Jump (Lompat Tanpa Batas)", "Infinite Jump (Lompat Tanpa Batas)", "Salto Infinito (Sin Límites)", "Pulo Infinito (Sem Limites)", "Бесконечные Прыжки", "Saut Infini (Sans Limites)", "Unendlicher Sprung (Kein Limit)", "Nhảy vô hạn trên không", "Walang-katapusang Pagtalon", "無限ジャンプ (空中無限跳躍)", "무한 연속 점프", "空中无限连跳" },
    { "Infinite Stamina (Stamina & Energi 100%)", "Infinite Stamina (Stamina & Energi 100%)", "Estamina Infinita (Energía 100%)", "Stamina Infinita (Energia 100%)", "Бесконечная Выносливость (100%)", "Endurance Infinie (100%)", "Unendliche Ausdauer (100%)", "Thể lực vô tận (Năng lượng 100%)", "Walang-hanggang Stamina (100% Lakas)", "無限スタミナ (スタミナ常時100%)", "무한 스태미나 (항상 100%)", "无限体力 (耐力体力永满)" },
    { "Anti-Fling Shield (Kebal Pentalan Pemain)", "Anti-Fling Shield (Kebal Pentalan Pemain)", "Escudo Anti-Fling (Inmune a Empujes)", "Escudo Anti-Fling (Imune a Arremessos)", "Анти-Флинг Щит (Защита от Толкания)", "Bouclier Anti-Fling (Immunisé aux Projections)", "Anti-Fling-Schild (Schutz vor Spielerschubsern)", "Khiên chống bị đẩy văng (Anti-Fling)", "Panangga Laban sa Pagpapatalsik (Anti-Fling)", "アンチフリングシールド (他人の突進吹っ飛ばし無効化)", "안티 플링 실드 (타 플레이어 충돌 날리기 무효화)", "防击飞护盾 (免疫其他玩家碰撞弹飞)" },
    { "Walk Fling (Tabrak untuk Lempar)", "Walk Fling (Tabrak untuk Lempar)", "Walk Fling (Colisionar para Lanzar)", "Walk Fling (Trombar para Arremessar)", "Флинг при Ходьбе (Толкать Игроков)", "Walk Fling (Percuter pour Projeter)", "Walk-Fling (Beim Vorbeigehen wegschleudern)", "Chạm để hất văng đối phương (Walk Fling)", "Banggain para Tumalsik (Walk Fling)", "ウォークフリング (接触した相手を超高速で吹っ飛ばす)", "워크 플링 (부딪혀서 상대방 날려버리기)", "走动撞飞 (碰撞瞬间弹飞目标)" },
    { "Walk Fling Power", "Walk Fling Power", "Potencia de Walk Fling", "Força de Walk Fling", "Сила Флинга", "Puissance de Walk Fling", "Walk-Fling-Kraft", "Lực hất văng Walk Fling", "Lakas ng Walk Fling", "ウォークフリング吹っ飛ばし威力", "워크 플링 위력", "碰撞弹飞力量倍率" },
    { "Skip Friends (Abaikan Teman Saat Fling)", "Skip Friends (Abaikan Teman Saat Fling)", "Ignorar Amigos al Lanzar (Fling)", "Ignorar Amigos ao Arremessar (Fling)", "Пропускать Друзей при Флинге", "Ignorer les Amis lors du Fling", "Freunde beim Fling verschonen", "Bỏ qua bạn bè khi hất văng", "Huwag Damayin ang mga Kaibigan sa Fling", "フレンドをフリング対象から除外", "친구는 플링 대상에서 제외", "避开好友 (撞飞时保护好友)" },
    { "Pilih Target Fling", "Pilih Target Fling", "Seleccionar Objetivo de Fling", "Selecionar Alvo de Fling", "Выбрать Цель для Флинга", "Choisir la Cible de Fling", "Fling-Ziel wählen", "Chọn mục tiêu cần hất văng", "Piliin ang Target na Ihahagis", "吹っ飛ばす対象プレイヤーを選択", "날려버릴 타겟 선택", "选择弹飞目标玩家" },
    { "Auto-Wipe Attributes (Bypass Stun / Slow Debuff)", "Auto-Wipe Attributes (Bypass Stun / Slow Debuff)", "Limpiar Atributos Auto (Anular Stun/Lentitud)", "Limpar Atributos Auto (Anular Stun/Lentidão)", "Авто-Очистка Атрибутов (Снятие Стана/Замедления)", "Nettoyage Auto des Attributs (Anti-Étourdissement)", "Automatische Attribut-Bereinigung (Gegen Stun/Slow)", "Tự động xóa hiệu ứng bất lợi (Xóa choáng / làm chậm)", "Kusang Alisin ang Masamang Epekto (Tanggal Stun/Bagal)", "デバフ自動消去 (スタン・減速効果バイパス)", "디버프 자동 해제 (기절/이동감소 무효화)", "自动清除负面状态 (解除眩晕/减速)" },
    { "Wipe Game Restrictions & Attributes", "Wipe Game Restrictions & Attributes", "Eliminar Restricciones y Atributos", "Eliminar Restrições e Atributos", "Снять Ограничения и Атрибуты Игры", "Supprimer les Restrictions et Attributs du Jeu", "Spielbeschränkungen & Attribute bereinigen", "Dọn dẹp mọi giới hạn & thuộc tính trò chơi", "Burahin ang mga Limitasyon at Katangian ng Laro", "ゲームの制限・属性を即時リセット", "게임 내 제한 및 디버프 속성 강제 제거", "瞬间清除游戏限制与阻碍属性" },
    { "Auto-Interact (Proximity Aura)", "Auto-Interact (Proximity Aura)", "Interacción Automática (Aura)", "Interação Automática (Aura)", "Авто-Взаимодействие (Аура)", "Interaction Automatique (Aura)", "Automatische Interaktion (Aura)", "Tự động tương tác (Hào quang xung quanh)", "Kusang Makipag-ugnayan (Proximity Aura)", "自動インタラクト (接近時自動実行オーラ)", "자동 상호작용 (접근 감지 오라)", "自动交互光环 (靠近自动触发)" },
    { "Instant Proximity Prompt", "Instant Proximity Prompt", "Interacción Inmediata de Proximidad", "Interação Imediata de Proximidade", "Мгновенные Подсказки Взаимодействия", "Interaction Instantanée sans Délai", "Sofortige Proximity-Prompt-Interaktion", "Nhấn tương tác tức thì (Không cần giữ phím)", "Agad na Pindot sa Aksyon (Walang Hintayan)", "長押し不要・即時インタラクト (Instant Prompt)", "홀드 불필요 즉시 상호작용 (인스턴트 프롬프트)", "长按免等待秒速互动 (Instant Prompt)" },
    { "Nama Posisi", "Nama Posisi", "Nombre de la Posición", "Nome da Posição", "Название Точки", "Nom de la Position", "Positionsname", "Tên vị trí", "Pangalan ng Lugar", "保存地点名", "위치 이름", "路标点名称" },
    { "Daftar Posisi Tersimpan", "Daftar Posisi Tersimpan", "Lista de Posiciones Guardadas", "Lista de Posições Salvas", "Список Сохранённых Точек", "Liste des Positions Enregistrées", "Gespeicherte Positionen", "Danh sách vị trí đã lưu", "Listahan ng mga Naitabing Lugar", "保存済みテレポート地点リスト", "저장된 위치 목록", "已保存的路标点列表" },
    { "Shortcut: Teleport ke Posisi", "Shortcut: Teleport ke Posisi", "Acceso Rápido: Teleport a Posición", "Atalho: Teleportar para Posição", "Быстрый Телепорт на Точку", "Raccourci : Téléportation vers Position", "Shortcut: Zur Position teleportieren", "Phím tắt: Dịch chuyển tới vị trí", "Shortcut: Mag-teleport sa Lugar", "ショートカット: 地点へテレポート", "단축키: 해당 위치로 순간이동", "快捷键: 传送到目标地点" },
    { "Pilih Pemain", "Pilih Pemain", "Seleccionar Jugador", "Selecionar Jogador", "Выбрать Игрока", "Sélectionner un Joueur", "Spieler auswählen", "Chọn người chơi", "Pumili ng Manlalaro", "プレイヤーを選択", "플레이어 선택", "选择目标玩家" },
    { "Pilih Pemain untuk Diikuti", "Pilih Pemain untuk Diikuti", "Seleccionar Jugador para Seguir", "Selecionar Jogador para Seguir", "Выбрать Игрока для Следования", "Sélectionner un Joueur à Suivre", "Spieler zum Folgen wählen", "Chọn người chơi cần bám đuôi", "Piliin ang Manlalarong Susundan", "自動追従するプレイヤーを選択", "따라갈 플레이어 선택", "选择自动跟随的玩家" },
    { "Pilih Pemain untuk Spectate", "Pilih Pemain untuk Spectate", "Seleccionar Jugador para Espectear", "Selecionar Jogador para Assistir", "Выбрать Игрока для Наблюдения", "Sélectionner un Joueur à Observer", "Spieler zum Zuschauen wählen", "Chọn người chơi để theo dõi góc nhìn", "Piliin ang Manlalarong Papanoorin", "観戦するプレイヤーを選択", "관전할 플레이어 선택", "选择旁观视角的玩家" },
    { "Periksa Akun Pemain", "Periksa Akun Pemain", "Inspeccionar Cuenta del Jugador", "Inspecionar Conta do Jogador", "Проверить Аккаунт Игрока", "Inspecter le Compte du Joueur", "Spielerkonto untersuchen", "Kiểm tra thông tin tài khoản người chơi", "Suriin ang Account ng Manlalaro", "プレイヤーアカウント情報を調査", "플레이어 계정 정보 조회", "查询玩家账号资料" },
    { "Print Koordinat Posisi Saat Ini (Cek Konsol F9)", "Print Koordinat Posisi Saat Ini (Cek Konsol F9)", "Imprimir Coordenadas Actuales (Consola F9)", "Imprimir Coordenadas Atuais (Console F9)", "Вывести Координаты в Консоль (F9)", "Afficher Coordonnées Actuelles (Console F9)", "Aktuelle Koordinaten drucken (F9-Konsole)", "In tọa độ hiện tại ra bảng điều khiển (F9)", "I-print ang Kasalukuyang Coordinates (Pindutin ang F9)", "現在の座標をコンソールに出力 (F9キーで確認)", "현재 위치 좌표 출력 (F9 콘솔 확인)", "打印当前坐标到控制台 (按F9查看)" },
    { "Load Dark Dex V3 (Bypassed)", "Load Dark Dex V3 (Bypassed)", "Cargar Dark Dex V3 (Bypassed)", "Carregar Dark Dex V3 (Bypassed)", "Загрузить Dark Dex V3 (Ободходной)", "Charger Dark Dex V3 (Contourné)", "Dark Dex V3 laden (Bypassed)", "Tải Dark Dex V3 (Bỏ qua bảo vệ)", "Buksan ang Dark Dex V3 (Bypassed)", "Dark Dex V3エクスプローラー読込", "Dark Dex V3 탐색기 실행", "加载Dark Dex V3资产探测器" },
    { "Load SimpleSpy (Remote Spy)", "Load SimpleSpy (Remote Spy)", "Cargar SimpleSpy (Remote Spy)", "Carregar SimpleSpy (Remote Spy)", "Загрузить SimpleSpy (Шпион Remote)", "Charger SimpleSpy (Espion Remote)", "SimpleSpy laden (Remote-Spion)", "Tải SimpleSpy (Bắt gói tin mạng)", "Buksan ang SimpleSpy (Remote Spy)", "SimpleSpy (通信パケット監視) を読込", "SimpleSpy (패킷 모니터링) 실행", "加载SimpleSpy数据包监听器" },
    { "Load Infinite Yield", "Load Infinite Yield", "Cargar Infinite Yield", "Carregar Infinite Yield", "Загрузить Infinite Yield", "Charger Infinite Yield", "Infinite Yield laden", "Tải Infinite Yield", "Buksan ang Infinite Yield", "Infinite Yieldコマンドツールを読込", "Infinite Yield 커맨드 바 실행", "加载Infinite Yield综合指令面板" },
    { "Execute Cobalt (Network Spy)", "Execute Cobalt (Network Spy)", "Ejecutar Cobalt (Network Spy)", "Executar Cobalt (Network Spy)", "Запустить Cobalt (Шпион Сети)", "Exécuter Cobalt (Espion Réseau)", "Cobalt ausführen (Netzwerk-Spion)", "Khởi chạy Cobalt (Giám sát mạng)", "Patakbuhin ang Cobalt (Network Spy)", "Cobalt (高度ネットワーク解析) を実行", "Cobalt (고급 네트워크 패킷 분석) 실행", "运行Cobalt网络数据包高级分析器" },
    { "Developer Heavy Tools (External)", "Developer Heavy Tools (External)", "Herramientas Pesadas de Desarrollador (Externas)", "Ferramentas Pesadas de Desenvolvedor (Externas)", "Тяжёлые Инструменты Разработчика (Внешние)", "Outils Développeur Lourds (Externes)", "Schwere Entwickler-Tools (Extern)", "Bộ công cụ nhà phát triển chuyên sâu (Ngoại vi)", "Mabibigat na Gamit ng Developer (Panlabas)", "外部高度開発ツール群", "전문가용 외부 개발자 도구 모음", "重型高级开发套件 (外部拓展)" },
    { "Dump Info Skrip (Salin & Cetak Console)", "Dump Info Skrip (Salin & Cetak Console)", "Volcar Info de Script (Copiar y Consola)", "Dump Info do Script (Copiar e Console)", "Дамп Информации о Скрипте (Копировать)", "Dump Info du Script (Copier & Console)", "Script-Info dumpen (Kopieren & Konsole)", "Trích xuất thông tin tập lệnh (Sao chép & F9)", "I-dump ang Impormasyon ng Script (Kopyahin)", "スクリプト情報をダンプ (コピー＆コンソール表示)", "스크립트 정보 덤프 (복사 및 콘솔 출력)", "转储脚本详情 (复制并打印至控制台)" },
    { "Game Architecture Dossier (Logbook Intel)", "Game Architecture Dossier (Logbook Intel)", "Dossier de Arquitectura del Juego", "Dossiê de Arquitetura do Jogo", "Досье Архитектуры Игры (Аналитика)", "Dossier d'Architecture du Jeu (Intel)", "Spielarchitektur-Dossier (Intel-Logbuch)", "Hồ sơ kiến trúc trò chơi (Nhật ký phân tích)", "Dossier ng Arkitektura ng Laro", "ゲームアーキテクチャ・ドキュメント (内部解析録)", "게임 구조 분석 보고서 (로그북 인텔)", "游戏内部架构档案 (情报日志)" },
    { "Kompilasi & Salin Lengkap Logbook Dossier", "Kompilasi & Salin Lengkap Logbook Dossier", "Compilar y Copiar Dossier Completo", "Compilar e Copiar Dossiê Completo", "Скомпилировать и Скопировать Полное Досье", "Compiler et Copier le Dossier Complet", "Vollständiges Dossier kompilieren & kopieren", "Biên dịch và sao chép toàn bộ hồ sơ", "I-compile at Kopyahin ang Buong Dossier", "完全な解析ドキュメントを生成・コピー", "전체 분석 보고서 컴파일 및 클립보드 복사", "生成并复制完整游戏架构档案" },
    { "Salin Executable Command Remote", "Salin Executable Command Remote", "Copiar Comando Ejecutable de Remote", "Copiar Comando Executável de Remote", "Скопировать Команду Вызова Remote", "Copier la Commande Exécutable du Remote", "Ausführbaren Remote-Befehl kopieren", "Sao chép lệnh gọi Remote thực thi", "Kopyahin ang Executable Command ng Remote", "Remote実行用Luaコードをクリップボードにコピー", "실행 가능한 Remote 호출 코드 복사", "复制可直接运行的Remote调用代码" },
    { "Salin Log Chat ke Clipboard", "Salin Log Chat ke Clipboard", "Copiar Registro de Chat al Portapapeles", "Copiar Histórico de Chat para Área de Transferência", "Скопировать Лог Чата в Буфер Обмена", "Copier l'Historique du Chat", "Chat-Protokoll in die Zwischenablage kopieren", "Sao chép toàn bộ tin nhắn chat vào bộ nhớ tạm", "Kopyahin ang Log ng Chat sa Clipboard", "チャットログをクリップボードにコピー", "채팅 로그 전체를 클립보드에 복사", "复制所有聊天记录到剪贴板" },
    { "Dapatkan Info Map (Place ID)", "Dapatkan Info Map (Place ID)", "Obtener Info del Mapa (Place ID)", "Obter Informações do Mapa (Place ID)", "Получить Информацию о Карте (Place ID)", "Obtenir les Infos de la Carte (Place ID)", "Karteninfo abrufen (Place ID)", "Lấy thông tin bản đồ (Place ID)", "Kunin ang Info ng Mapa (Place ID)", "マップ情報・Place IDを取得", "맵 정보 및 Place ID 조회", "获取地图信息 (Place ID)" },
    { "Fire Remote (Parameter Kosong)", "Fire Remote (Parameter Kosong)", "Disparar Remote (Sin Parámetros)", "Disparar Remote (Parâmetros Vazios)", "Вызвать Remote (Без Параметров)", "Déclencher Remote (Paramètres Vides)", "Remote auslösen (Leere Parameter)", "Kích hoạt Remote (Không có tham số)", "Paganahin ang Remote (Walang Laman)", "Remote発火 (引数なし)", "Remote 호출 (빈 파라미터)", "发送Remote (空参数)" },
    { "Fire Remote (Arg: LocalPlayer)", "Fire Remote (Arg: LocalPlayer)", "Disparar Remote (Arg: LocalPlayer)", "Disparar Remote (Arg: LocalPlayer)", "Вызвать Remote (Арг: LocalPlayer)", "Déclencher Remote (Arg: LocalPlayer)", "Remote auslösen (Arg: LocalPlayer)", "Kích hoạt Remote (Tham số: Người chơi hiện tại)", "Paganahin ang Remote (Arg: LocalPlayer)", "Remote発火 (引数: 自分自身)", "Remote 호출 (인수: 로컬플레이어)", "发送Remote (参数: 本地玩家)" },
    { "Fire Remote (Arg: Angka 100)", "Fire Remote (Arg: Angka 100)", "Disparar Remote (Arg: Número 100)", "Disparar Remote (Arg: Número 100)", "Вызвать Remote (Арг: Число 100)", "Déclencher Remote (Arg: Nombre 100)", "Remote auslösen (Arg: Zahl 100)", "Kích hoạt Remote (Tham số: Số 100)", "Paganahin ang Remote (Arg: Numerong 100)", "Remote発火 (引数: 数値100)", "Remote 호출 (인수: 숫자 100)", "发送Remote (参数: 数值100)" },
    { "Fire Remote (Arg: String 'Claim')", "Fire Remote (Arg: String 'Claim')", "Disparar Remote (Arg: Texto 'Claim')", "Disparar Remote (Arg: Texto 'Claim')", "Вызвать Remote (Арг: Строка 'Claim')", "Déclencher Remote (Arg: Texte 'Claim')", "Remote auslösen (Arg: String 'Claim')", "Kích hoạt Remote (Tham số: Chuỗi 'Claim')", "Paganahin ang Remote (Arg: Textong 'Claim')", "Remote発火 (引数: 文字列 'Claim')", "Remote 호출 (인수: 문자열 'Claim')", "发送Remote (参数: 字符串'Claim')" },
    { "Auto-Spam Remote (Loop Fire 60x/dtk)", "Auto-Spam Remote (Loop Fire 60x/dtk)", "Spam Automático de Remote (60x/seg)", "Spam Automático de Remote (60x/seg)", "Авто-Спам Remote (Цикл 60 раз/сек)", "Spam Automatique du Remote (60x/sec)", "Automatischer Remote-Spam (60x/s)", "Tự động gửi Remote liên tục (60 lần/giây)", "Walang-tigil na Pagpasa ng Remote (60x/seg)", "Remote自動スパム送信 (毎秒60回連射)", "Remote 자동 연타 전송 (초당 60회)", "高频轰炸发送Remote (每秒60次)" },
    { "<  Remote Sebelumnya", "<  Remote Sebelumnya", "<  Remote Anterior", "<  Remote Anterior", "<  Предыдущий Remote", "<  Remote Précédent", "<  Vorheriger Remote", "<  Remote Trước", "<  Naunang Remote", "<  前のRemote", "<  이전 Remote", "<  上一个Remote" },
    { "Remote Selanjutnya  >", "Remote Selanjutnya  >", "Siguiente Remote  >", "Próximo Remote  >", "Следующий Remote  >", "Remote Suivant  >", "Nächster Remote  >", "Remote Tiếp theo  >", "Susunod na Remote  >", "次のRemote  >", "다음 Remote  >", "下一个Remote  >" },
    { "<  Skrip Sebelumnya", "<  Skrip Sebelumnya", "<  Script Anterior", "<  Script Anterior", "<  Предыдущий Скрипт", "<  Script Précédent", "<  Vorheriges Skript", "<  Tập lệnh Trước", "<  Naunang Script", "<  前のスクリプト", "<  이전 스크립트", "<  上一个脚本" },
    { "Skrip Selanjutnya  >", "Skrip Selanjutnya  >", "Siguiente Script  >", "Próximo Script  >", "Следующий Скрипт  >", "Script Suivant  >", "Nächstes Skript  >", "Tập lệnh Tiếp theo  >", "Susunod na Script  >", "次のスクリプト  >", "다음 스크립트  >", "下一个脚本  >" },
    { "Toggle Status Skrip (Aktif / Nonaktif)", "Toggle Status Skrip (Aktif / Nonaktif)", "Cambiar Estado de Script (Activo / Inactivo)", "Alternar Status do Script (Ativo / Inativo)", "Переключить Состояние Скрипта", "Basculer l'État du Script (Actif / Inactif)", "Skriptstatus umschalten (Aktiv / Inaktiv)", "Chuyển đổi trạng thái tập lệnh (Bật / Tắt)", "Baguhin ang Katayuan ng Script (Bukas / Sarado)", "スクリプト実行状態切替 (有効/無効)", "스크립트 활성화 상태 토글 (켜짐/꺼짐)", "切换脚本运行状态 (启用/禁用)" },
    { "Inject OP Gun (999k Dmg, Inf Ammo)", "Inject OP Gun (999k Dmg, Inf Ammo)", "Inyectar Arma OP (999k Daño, Munición Inf)", "Injetar Arma OP (999k Dano, Munição Inf)", "Создать OP Оружие (999k Урона, Беск. Патроны)", "Injecter Arme OP (999k Dégâts, Munitions Inf)", "OP-Waffe injizieren (999k Schaden, Inf Munition)", "Tiêm vũ khí siêu mạnh (999k Sát thương, Vô hạn đạn)", "Maglagay ng Malakas na Baril (999k Bawas, Walang Ubos na Bala)", "チート武器を生成 (999kダメージ・無限弾薬)", "OP 무기 생성 (999k 데미지, 무한 탄약)", "注入全能重火力武器 (99万伤害+无限子弹)" },
    { "Catalog Animation Pack", "Catalog Animation Pack", "Paquete de Animaciones del Catálogo", "Pacote de Animações do Catálogo", "Набор Анимаций из Каталога", "Pack d'Animations du Catalogue", "Katalog-Animationspaket", "Gói hoạt ảnh từ danh mục", "Koleksyon ng Galaw mula sa Katalogo", "公式カタログアニメーションパック", "카탈로그 모션 애니메이션 팩", "商城官方动作动画包" },
    { "Terapkan Animation Pack", "Terapkan Animation Pack", "Aplicar Paquete de Animaciones", "Aplicar Pacote de Animações", "Применить Набор Анимаций", "Appliquer le Pack d'Animations", "Animationspaket anwenden", "Áp dụng gói hoạt ảnh", "Gamitin ang Animation Pack", "アニメーションパックを適用", "애니메이션 팩 적용", "应用动画动作包" },
    { "Putar Animasi Kustom", "Putar Animasi Kustom", "Reproducir Animación Personalizada", "Reproduzir Animação Personalizada", "Воспроизвести Пользовательскую Анимацию", "Jouer l'Animation Personnalisée", "Benutzerdefinierte Animation abspielen", "Phát hoạt ảnh tùy chỉnh", "I-play ang Custom na Galaw", "カスタムアニメーションを再生", "사용자 지정 애니메이션 재생", "播放自定义动画" },
    { "Hentikan Animasi Kustom", "Hentikan Animasi Kustom", "Detener Animación Personalizada", "Parar Animação Personalizada", "Остановить Пользовательскую Анимацию", "Arrêter l'Animation Personnalisée", "Benutzerdefinierte Animation stoppen", "Dừng hoạt ảnh tùy chỉnh", "Itigil ang Custom na Galaw", "カスタムアニメーションを停止", "사용자 지정 애니메이션 중지", "停止自定义动画" },
    { "Reset Ukuran Karakter (1.0)", "Reset Ukuran Karakter (1.0)", "Restablecer Tamaño de Personaje (1.0)", "Redefinir Tamanho do Personagem (1.0)", "Сбросить Размер Персонажа (1.0)", "Réinitialiser la Taille du Personnage (1.0)", "Charaktergröße zurücksetzen (1.0)", "Đặt lại kích cỡ nhân vật về mặc định (1.0)", "Ibalik sa Normal ang Laki ng Karakter (1.0)", "アバターサイズを通常(1.0)にリセット", "캐릭터 크기 기본값(1.0)으로 초기화", "恢复角色体型大小为默认 (1.0)" },
    { "Pergerakan & Karakter", "Pergerakan & Karakter", "Movimiento y Personaje", "Movimento e Personagem", "Движение и Персонаж", "Mouvement et Personnage", "Bewegung & Charakter", "Di chuyển & Nhân vật", "Pagkilos at Karakter", "移動＆アバター機能", "이동 및 캐릭터 설정", "移动与角色机能" },
    { "Visual & Dunia", "Visual & Dunia", "Visuales y Mundo", "Visuais e Mundo", "Визуалы и Мир", "Visuels et Monde", "Visuelles & Welt", "Hình ảnh & Thế giới", "Visual at Mundo", "視覚効果＆ワールド環境", "비주얼 및 월드 환경", "视觉与游戏世界" },
    { "Mode Lanjutan (Full Exploit Suite)", "Mode Lanjutan (Full Exploit Suite)", "Modo Avanzado (Suite Completa de Exploits)", "Modo Avançado (Suite Completa de Exploits)", "Продвинутый Режим (Полный Набор)", "Mode Avancé (Suite d'Exploits Complète)", "Erweiterter Modus (Vollständige Exploit-Suite)", "Chế độ Nâng cao (Toàn bộ bộ công cụ khai thác)", "Mataas na Antas (Buong Exploit Suite)", "上級モード (フル・エクスプロイトスイート)", "고급 모드 (전체 익스플로잇 스위트)", "高级模式 (完整通用功能套件)" },
    { "Buka Full Universal Tabs (Combat, Dev, dll)", "Buka Full Universal Tabs (Combat, Dev, dll)", "Abrir Todas las Pestañas Universales (Combat, Dev, etc)", "Abrir Todas as Abas Universais (Combat, Dev, etc)", "Открыть Все Универсальные Вкладки (Combat, Dev и др.)", "Ouvrir Tous les Onglets Universels (Combat, Dev, etc.)", "Alle Universal-Tabs öffnen (Kampf, Dev, etc.)", "Mở đầy đủ các Tab Chung (Chiến đấu, Nhà phát triển, v.v.)", "Buksan ang Lahat ng Tab (Labanan, Dev, atbp)", "全ユニバーサルタブを展開 (Combat, Dev等)", "전체 유니버설 탭 열기 (전투, 개발자 등)", "展开完整通用标签页 (战斗、开发等)" },
    { "Refresh Data Update", "Refresh Data Update", "Actualizar Datos de Registro", "Atualizar Dados de Registro", "Обновить Данные Патча", "Rafraîchir les Données de Mise à Jour", "Aktualisierungsdaten neu laden", "Làm mới dữ liệu cập nhật", "I-refresh ang Data ng Update", "アップデート情報を更新", "업데이트 정보 새로고침", "刷新更新日志数据" },
    { "Server Hop (Ping Tercepat / Lowest Ping)", "Server Hop (Ping Tercepat / Lowest Ping)", "Cambiar de Servidor (Menor Ping)", "Trocar de Servidor (Menor Ping)", "Сменить Сервер (Минимальный Пинг)", "Changer de Serveur (Ping le plus bas)", "Server wechseln (Niedrigster Ping)", "Chuyển máy chủ (Ping thấp nhất)", "Lumipat ng Server (Pinakamababang Ping)", "最速サーバーへ移動 (最小Ping)", "최저 핑 서버로 이동 (Lowest Ping)", "换服 (切换至最低延迟服务器)" },
    { "Server Hop (Smallest Server)", "Server Hop (Smallest Server)", "Cambiar de Servidor (Menos Jugadores)", "Trocar de Servidor (Menos Jogadores)", "Сменить Сервер (Меньше Игроков)", "Changer de Serveur (Serveur le plus petit)", "Server wechseln (Wenigste Spieler)", "Chuyển máy chủ (Ít người nhất)", "Lumipat ng Server (Kakaunting Manlalaro)", "過疎サーバーへ移動 (最少人数)", "최소 인원 서버로 이동 (Smallest Server)", "换服 (切换至人最少服务器)" },
    { "Enable ESP (Master)", "Enable ESP (Master)", "Activar ESP (Maestro)", "Ativar ESP (Mestre)", "Включить ESP (Главный)", "Activer l'ESP (Principal)", "ESP aktivieren (Hauptschalter)", "Bật ESP (Tổng)", "I-on ang ESP (Master)", "マスターESPを有効化", "마스터 ESP 활성화", "启用总控透视 (Master ESP)" },
    { "Stop All", "Hentikan Semua", "Detener Todo", "Parar Tudo", "Остановить Всё", "Tout Arrêter", "Alles stoppen", "Dừng tất cả", "Itigil Lahat", "すべて停止", "모두 중지", "停止所有任务" },
    { "Session & Info", "Sesi & Info", "Sesión e Información", "Sessão e Informações", "Сессия и Информация", "Session et Infos", "Sitzung & Info", "Phiên & Thông tin", "Sesyon at Impormasyon", "セッション＆情報", "세션 및 정보", "会话与运行信息" },
    { "Auto Rebirth", "Auto Rebirth", "Rebirth Automático", "Rebirth Automático", "Авто-Перерождение", "Renaissance Auto", "Automatisches Rebirth", "Tự động tái sinh (Rebirth)", "Kusang Rebirth", "自動リバース (転生)", "자동 환생 (리버스)", "自动转生 (Rebirth)" },
    { "Auto Farm Wins", "Auto Farm Kemenangan (Wins)", "Auto Farm Victorias", "Auto Farm Vitórias", "Авто-Фарм Побед", "Auto Farm Victoires", "Auto-Farm Siege", "Tự động cày trận thắng (Wins)", "Kusang Mag-farm ng Panalo", "自動勝利ファーム (Wins)", "자동 승리 파밍 (Wins)", "自动刷胜利数 (Wins)" },
    { "Auto Farm Rebirth", "Auto Farm Rebirth", "Auto Farm Rebirth", "Auto Farm Rebirth", "Авто-Фарм Перерождений", "Auto Farm Renaissance", "Auto-Farm Rebirth", "Tự động cày tái sinh", "Kusang Mag-farm ng Rebirth", "自動リバース周回ファーム", "자동 환생 파밍", "自动转生刷取" },
    { "Auto Sell All", "Auto Jual Semua", "Vender Todo Automático", "Vender Tudo Automático", "Авто-Продажа Всего", "Tout Vendre Automatiquement", "Alles automatisch verkaufen", "Tự động bán tất cả", "Kusang Ibenta Lahat", "自動全売却 (Auto Sell All)", "전체 자동 판매", "自动出售全部物品" },
    { "Auto Collect Gems", "Auto Ambil Gems", "Recoger Gemas Automático", "Coletar Gemas Automático", "Авто-Сбор Самоцветов", "Collecter les Gemmes Auto", "Edelsteine automatisch sammeln", "Tự động thu thập Ngọc (Gems)", "Kusang Kunin ang mga Gem", "ジェム自動回収", "보석(Gems) 자동 수집", "自动拾取宝石 (Gems)" },
    { "Auto Run (SafeZone Navigation)", "Auto Lari ke SafeZone", "Correr a Zona Segura Auto", "Correr para Zona Segura Auto", "Авто-Бег в Безопасную Зону", "Course Auto vers Zone Sûre", "Automatischer Lauf zur Schutzzone", "Tự động chạy về vùng an toàn", "Kusang Tumakbo sa Ligtas na Lugar", "安全地帯へ自動退避 (SafeZone)", "안전지대로 자동 이동 (SafeZone)", "受到威胁自动跑向安全区" },
    { "Auto Revive Downed Teammates", "Auto Bangkitkan Rekan Sekamar/Tim", "Revivir Compañeros Caídos Auto", "Reviver Aliados Caídos Auto", "Авто-Воскрешение Союзников", "Réanimer Coéquipiers à Terre Auto", "Gefallene Teamkollegen wiederbeleben", "Tự động cứu đồng đội bị gục", "Kusang Buhayin ang Bumagsak na Kakampi", "ダウンした味方を自動蘇生", "다운된 팀원 자동 부활", "自动救援倒地队友" },
    { "Materials ESP", "Materials ESP", "ESP de Materiales", "ESP de Materiais", "ESP Материалов", "ESP des Matériaux", "Materialien-ESP", "ESP Nguyên liệu", "ESP ng Materyales", "素材アイテムESP", "재료 아이템 ESP", "素材原料透视ESP" },
    { "NPC ESP", "NPC ESP", "ESP de NPCs", "ESP de NPCs", "ESP NPC", "ESP des PNJ", "NPC-ESP", "ESP NPC", "ESP ng NPC", "NPC ESP", "NPC ESP", "NPC透视ESP" },
    { "Aktifkan ESP Materials", "Aktifkan ESP Materials", "Activar ESP de Materiales", "Ativar ESP de Materiais", "Включить ESP Материалов", "Activer l'ESP des Matériaux", "Materialien-ESP aktivieren", "Bật ESP Nguyên liệu", "I-on ang ESP ng Materyales", "素材ESPを有効化", "재료 ESP 켜기", "启用素材透视ESP" },
    { "Aktifkan ESP NPC", "Aktifkan ESP NPC", "Activar ESP de NPC", "Ativar ESP de NPC", "Включить ESP NPC", "Activer l'ESP des PNJ", "NPC-ESP aktivieren", "Bật ESP NPC", "I-on ang ESP ng NPC", "NPC ESPを有効化", "NPC ESP 켜기", "启用NPC透视ESP" },
    { "Pilih Material (Multi)", "Pilih Material (Multi)", "Seleccionar Materiales (Múltiple)", "Selecionar Materiais (Múltiplo)", "Выбрать Материалы (Несколько)", "Sélectionner Matériaux (Multi)", "Materialien auswählen (Multi)", "Chọn nguyên liệu (Nhiều mục)", "Pumili ng Materyales (Maramihan)", "表示素材を選択 (複数選択可)", "표시할 재료 선택 (다중 선택)", "选择透视素材 (多选)" },
    { "Pilih NPC (Multi)", "Pilih NPC (Multi)", "Seleccionar NPCs (Múltiple)", "Selecionar NPCs (Múltiplo)", "Выбрать NPC (Несколько)", "Sélectionner PNJ (Multi)", "NPCs auswählen (Multi)", "Chọn NPC (Nhiều mục)", "Pumili ng NPC (Maramihan)", "表示NPCを選択 (複数選択可)", "표시할 NPC 선택 (다중 선택)", "选择透视NPC (多选)" },
    { "Fullbright (Pencahayaan Terang)", "Fullbright (Pencahayaan Terang)", "Brillo Máximo (Iluminación Clara)", "Brilho Máximo (Iluminação Clara)", "Полная Яркость (Яркое Освещение)", "Pleine Luminosité (Éclairage Clair)", "Volle Helligkeit (Helle Beleuchtung)", "Độ sáng tối đa (Chiếu sáng rõ nét)", "Maliwanag Lahat (Maliwanag na Ilaw)", "常時最高輝度 (暗所完全除去)", "최대 밝기 (선명한 조명)", "全局高亮 (超亮夜视照明)" },
    { "Fire Remote (Arg: String ", "Fire Remote (Arg: String ", "Disparar Remote (Arg: Texto ", "Disparar Remote (Arg: Texto ", "Вызвать Remote (Арг: Строка ", "Déclencher Remote (Arg: Texte ", "Remote auslösen (Arg: String ", "Kích hoạt Remote (Tham số: Chuỗi ", "Paganahin ang Remote (Arg: Texto ", "Remote発火 (引数: 文字列 ", "Remote 호출 (인수: 문자열 ", "发送Remote (参数: 字符串 " },
    { "Pilih Pulau Tujuan", "Pilih Pulau Tujuan", "Seleccionar Isla de Destino", "Selecionar Ilha de Destino", "Выбрать Остров Назначения", "Sélectionner l'Île de Destination", "Zielinsel auswählen", "Chọn hòn đảo đích", "Pumili ng Pupuntahang Isla", "テレポート先の島を選択", "목적지 섬 선택", "选择目的地岛屿" },
    { "Illegal Soccer", "Illegal Soccer", "Fútbol Ilegal (Illegal Soccer)", "Futebol Ilegal (Illegal Soccer)", "Нелегальный Футбол (Illegal Soccer)", "Football Illégal (Illegal Soccer)", "Illegaler Fußball (Illegal Soccer)", "Bóng đá Bất hợp pháp (Illegal Soccer)", "Illegal na Soccer", "イリーガルサッカー (Illegal Soccer)", "일리걸 사커 (Illegal Soccer)", "非法足球 (Illegal Soccer)" },
    { "⚡ Stamina & Sprint Exploits", "⚡ Stamina & Sprint Exploits", "⚡ Exploits de Estamina y Sprint", "⚡ Exploits de Estamina e Corrida", "⚡ Эксплойты Выносливости и Спринта", "⚡ Exploits d'Endurance et de Sprint", "⚡ Ausdauer- & Sprint-Exploits", "⚡ Khai thác Thể lực & Chạy nhanh", "⚡ Exploits sa Stamina at Takbo", "⚡ スタミナ＆ダッシュ機能", "⚡ 스태미나 및 질주 기능", "⚡ 体力与冲刺增强" },
    { "ℹ️ Status & Diagnostics", "ℹ️ Status & Diagnostik", "ℹ️ Estado y Diagnóstico", "ℹ️ Status e Diagnósticos", "ℹ️ Статус и Диагностика", "ℹ️ Statut et Diagnostics", "ℹ️ Status & Diagnose", "ℹ️ Trạng thái & Chẩn đoán", "ℹ️ Katayuan at Pagsusuri", "ℹ️ ステータス＆診断情報", "ℹ️ 상태 및 진단 정보", "ℹ️ 状态与诊断信息" },
    { "Manajemen Skrip", "Manajemen Skrip", "Gestión de Scripts", "Gerenciamento de Scripts", "Управление Скриптом", "Gestion des Scripts", "Skriptverwaltung", "Quản lý Tập lệnh", "Pamamahala ng Script", "スクリプト管理", "스크립트 관리", "脚本管理" },
    { "Unlimited Stamina (HasUnlimitedStamina)", "Stamina Tak Terbatas (HasUnlimitedStamina)", "Estamina Ilimitada (HasUnlimitedStamina)", "Stamina Ilimitada (HasUnlimitedStamina)", "Бесконечная Выносливость (HasUnlimitedStamina)", "Endurance Illimitée (HasUnlimitedStamina)", "Unendliche Ausdauer (HasUnlimitedStamina)", "Thể lực vô hạn (HasUnlimitedStamina)", "Walang-hanggang Stamina (HasUnlimitedStamina)", "無限スタミナ (HasUnlimitedStamina)", "무한 스태미나 (HasUnlimitedStamina)", "无限体力 (HasUnlimitedStamina)" },
    { "Re-Hook Sprint Module", "Pasang Ulang Hook Sprint", "Reenganchar Módulo de Sprint", "Reenganchar Módulo de Corrida", "Переподключить Хук Спринта", "Rerecrocheter Module de Sprint", "Sprint-Modul neu hooken", "Gắn lại Hook Mô-đun Chạy nhanh", "Ikabit Muli ang Sprint Hook", "ダッシュモジュールを再フック", "질주 모듈 재후킹", "重新挂钩冲刺模块" },
    { "Status Modul & Hook", "Status Modul & Hook", "Estado del Módulo y Hook", "Status do Módulo e Hook", "Статус Модуля и Хука", "Statut du Module et Hook", "Modul- & Hook-Status", "Trạng thái Mô-đun & Hook", "Katayuan ng Modyul at Hook", "モジュール＆フック状態", "모듈 및 후크 상태", "模块与Hook状态" },
    { "Unload Illegal Soccer Script", "Tutup & Hapus Skrip Illegal Soccer", "Descargar Script de Illegal Soccer", "Descarregar Script de Illegal Soccer", "Выгрузить Скрипт Illegal Soccer", "Décharger le Script d'Illegal Soccer", "Illegal Soccer Skript entladen", "Hủy tập lệnh Illegal Soccer", "I-unload ang Script ng Illegal Soccer", "Illegal Soccerスクリプトをアンロード", "Illegal Soccer 스크립트 언로드", "卸载Illegal Soccer脚本" },
    { "Fatal Baboons", "Fatal Baboons", "Fatal Baboons", "Fatal Baboons", "Fatal Baboons", "Fatal Baboons", "Fatal Baboons", "Fatal Baboons", "Fatal Baboons", "Fatal Baboons", "Fatal Baboons", "Fatal Baboons" },
    { "Unload Fatal Baboons Script", "Tutup & Hapus Skrip Fatal Baboons", "Descargar Script de Fatal Baboons", "Descarregar Script de Fatal Baboons", "Выгрузить Скрипт Fatal Baboons", "Décharger le Script de Fatal Baboons", "Fatal Baboons Skript entladen", "Hủy tập lệnh Fatal Baboons", "I-unload ang Script ng Fatal Baboons", "Fatal Baboonsスクリプトをアンロード", "Fatal Baboons 스크립트 언로드", "卸载Fatal Baboons脚本" },
    { "Maintenance", "Pemeliharaan", "Mantenimiento", "Manutenção", "Обслуживание", "Maintenance", "Wartung", "Bảo trì", "Pagpapanatili", "メンテナンス", "유지보수", "维护中" },
    { "Maintenance Status", "Status Pemeliharaan", "Estado de Mantenimiento", "Status de Manutenção", "Статус Обслуживания", "État de la Maintenance", "Wartungsstatus", "Trạng thái Bảo trì", "Katayuan ng Pagpapanatili", "メンテナンス状況", "유지보수 상태", "维护状态" },
    { "Alternative: Universal Features", "Alternatif: Fitur Universal", "Alternativa: Funciones Universales", "Alternativa: Recursos Universais", "Альтернатива: Универсальные Функции", "Alternative: Fonctions Universelles", "Alternative: Universelle Funktionen", "Thay thế: Tính năng Chung", "Alternatibo: Pangkalahatang Tampok", "代替: ユニバーサル機能", "대체: 유니버설 기능", "备选: 通用功能" },
    { "Open Universal Exploit Suite", "Buka Fitur Universal Exploit", "Abrir Suite de Exploits Universales", "Abrir Suite Universal de Exploits", "Открыть Универсальный Набор Эксплойтов", "Ouvrir la Suite d'Exploits Universelle", "Universelle Exploit-Suite Öffnen", "Mở Bộ Công cụ Khai thác Chung", "Buksan ang Universal Exploit Suite", "ユニバーサルエクスプロイトスイートを開く", "유니버설 익스플로잇 스위트 열기", "打开通用功能套件" },
    { "Account Safety Priority #1", "Keamanan Akun Prioritas #1", "Seguridad de Cuenta Prioridad #1", "Segurança da Conta Prioridade #1", "Безопасность Аккаунта Приоритет #1", "Sécurité du Compte Priorité #1", "Kontosicherheit Priorität #1", "An toàn Tài khoản Ưu tiên #1", "Kaligtasan ng Account Priyoridad #1", "アカウントの安全最優先 #1", "계정 보안 최우선 #1", "账号安全第一优先级" },
    { "Use Universal Features", "Gunakan Fitur Universal", "Usar Funciones Universales", "Usar Recursos Universais", "Использовать Универсальные Функции", "Utiliser les Fonctions Universelles", "Universelle Funktionen Verwenden", "Sử dụng Tính năng Chung", "Gamitin ang Pangkalahatang Tampok", "ユニバーサル機能を使用", "유니버설 기능 사용", "使用通用功能" },
    { "Status & Telemetry", "Status & Telemetri", "Estado y Telemetría", "Status e Telemetria", "Статус и Телеметрия", "Statut et Télémétrie", "Status & Telemetrie", "Trạng thái & Đo từ xa", "Katayuan at Telemetriya", "ステータス＆テレメトリ", "상태 및 텔레메트리", "状态与遥测" },
    { "Internet Cafe Automation", "Automasi Warnet", "Automatización de Cibercafé", "Automação de Lan House", "Автоматизация Интернет-Кафе", "Automatisation Cybercafé", "Internetcafé-Automatisierung", "Tự động hóa Quán Net", "Awtomasyon ng Internet Cafe", "ネットカフェ自動化", "PC방 자동화", "网吧自动化" },
    { "Auto Farm Gift", "Auto Farm Hadiah", "Auto Farm Regalos", "Auto Farm Presentes", "Авто-Фарм Подарков", "Farm Auto de Cadeaux", "Auto-Farm Geschenke", "Tự động Nhận Quà", "Auto Farm Regalo", "ギフト自動回収 (Auto Farm)", "선물 자동 파밍", "自动收集礼物" },
    { "Auto Open / Close Cafe", "Auto Buka / Tutup Warnet", "Auto Abrir / Cerrar Cibercafé", "Auto Abrir / Fechar Lan House", "Авто Открытие / Закрытие Кафе", "Ouverture / Fermeture Auto Cybercafé", "Café automatisch öffnen / schließen", "Tự động Mở / Đóng Quán Net", "Auto Bukas / Sara ng Cafe", "ネットカフェ自動開店/閉店", "PC방 자동 개점/폐점", "自动开启/关闭网吧" },
    { "Access Operator Desk", "Akses Operator Desk", "Acceso al Mostrador de Operador", "Acessar Balcão do Operador", "Доступ к Стойке Оператора", "Accéder au Bureau de l'Opérateur", "Zugriff auf Betreiberpult", "Truy cập Bàn Điều hành", "I-access ang Operator Desk", "オペレーターデスクにアクセス", "운영자 데스크 접속", "访问管理员电脑前台" },
    { "Cafe Status", "Status Warnet", "Estado del Cibercafé", "Status da Lan House", "Статус Интернет-Кафе", "Statut du Cybercafé", "Internetcafé-Status", "Trạng thái Quán Net", "Katayuan ng Cafe", "ネットカフェ状態", "PC방 상태", "网吧状态" },
    { "Match Telemetry & Status", "Telemetri & Status Match", "Telemetría y Estado de Partida", "Telemetria e Status da Partida", "Телеметрия и Статус Матча", "Télémétrie et Statut de Partie", "Match-Telemetrie & Status", "Đo từ xa & Trạng thái Trận", "Telemetriya at Katayuan ng Laban", "マッチ状態＆テレメトリ", "매치 상태 및 텔레메트리", "比赛遥测与状态" },
    { "Runner Automation", "Otomatisasi Runner (Pelari)", "Automatización de Corredor", "Automação de Corredor", "Автоматизация Бегуна", "Automatisation Coureur", "Läufer-Automatisierung", "Tự động hóa Người chạy", "Awtomasyon ng Runner", "ランナー自動化", "러너 자동화", "逃亡者自动化" },
    { "Catcher Automation", "Otomatisasi Catcher (Pemburu)", "Automatización de Cazador", "Automação de Caçador", "Автоматизация Ловца", "Automatisation Attrapeur", "Fänger-Automatisierung", "Tự động hóa Thợ săn", "Awtomasyon ng Catcher", "キャッチャー自動化", "추적자 자동화", "追捕者自动化" },
    { "Visual & Hitbox Aids", "Alat Bantu Visual & Hitbox", "Ayudas Visuales y Hitbox", "Auxílios Visuais e Hitbox", "Визуальные Помощники и Хитбокс", "Aides Visuelles et Hitbox", "Visuelle Hilfen & Hitbox", "Hỗ trợ Hình ảnh & Hitbox", "Mga Tulong sa Visual at Hitbox", "視覚＆ヒットボックス支援", "시각 및 히트박스 보조", "视觉透视与判定辅助" },
    { "Lobby & Rewards Automation", "Automasi Lobby & Hadiah", "Automatización de Sala y Recompensas", "Automação de Lobby e Recompensas", "Автоматизация Лобби и Наград", "Automatisation Lobby et Récompenses", "Lobby- & Belohnungs-Automatisierung", "Tự động sảnh & Phần thưởng", "Awtomasyon ng Lobby at Premyo", "ロビー＆報酬自動化", "로비 및 보상 자동화", "大厅与奖励自动化" },
    { "Daily Spin Wheel", "Roda Hadiah (Daily Spin Wheel)", "Ruleta Diaria de Premios", "Roleta de Recompensas Diária", "Колесо Ежедневных Призов", "Roue des Récompenses Quotidienne", "Tägliches Glücksrad", "Vòng quay May mắn Hàng ngày", "Pang-araw-araw na Spin Wheel", "デイリールーレット報酬", "일일 룰렛 보상", "每日幸运转盘" },
    { "Journey Pass Season Rewards", "Hadiah Musim (Journey Pass)", "Recompensas de Pase de Temporada", "Recompensas de Passe de Temporada", "Сезонные Награды (Journey Pass)", "Récompenses du Pass de Saison", "Saison-Pass-Belohnungen", "Phần thưởng Mùa (Journey Pass)", "Mga Premyo ng Season Pass", "シーズンパス報酬 (Journey Pass)", "시즌 패스 보상 (Journey Pass)", "赛季通行证奖励 (Journey Pass)" },
    { "Auto Map Voting", "Voting Map Otomatis", "Votación Automática de Mapa", "Votação Automática de Mapa", "Авто-Голосование за Карту", "Vote Auto de la Carte", "Automatische Kartenabstimmung", "Tự động Bầu chọn Bản đồ", "Awtomatikong Boto sa Mapa", "マップ自動投票", "지도 자동 투표", "自动投票地图" },
    { "Materials ESP", "ESP Material", "ESP de Materiales", "ESP de Materiais", "ESP Материалов", "ESP Matériaux", "Materialien-ESP", "ESP Vật liệu", "Materials ESP", "素材ESP", "재료 ESP", "材料物资ESP" },
    { "NPC ESP", "ESP NPC", "ESP de NPCs", "ESP de NPCs", "ESP NPC", "ESP PNJ", "NPC-ESP", "ESP NPC", "NPC ESP", "NPC ESP", "NPC ESP", "NPC透视ESP" },
    { "Auto Revive Teammates", "Auto Revive Rekan Tim", "Auto Revivir Compañeros", "Auto Reviver Companheiros", "Авто-Оживление Союзников", "Réanimation Auto des Équipiers", "Teammitglieder automatisch wiederbeleben", "Tự động cứu đồng đội ngã", "Awtomatikong Buhayin ang Kasama", "倒れた味方を自動蘇生", "쓰러진 팀원 자동 부활", "自动救援倒地队友" },
    { "Auto Collect Gems", "Ambil Gem Otomatis", "Auto Recolectar Gemas", "Auto Coletar Gemas", "Авто-Сбор Самоцветов", "Collecte Auto de Gemmes", "Edelsteine automatisch sammeln", "Tự động Nhặt Đá quý", "Awtomatikong Kolektahin ang Gems", "ジェム自動収集", "보석 자동 수집", "自动收集宝石" },
    { "Auto Rebirth", "Rebirth Otomatis", "Renacimiento Automático", "Renascimento Automático", "Авто-Перерождение", "Renaissance Auto (Rebirth)", "Automatischer Rebirth", "Tự động Tái sinh (Rebirth)", "Awtomatikong Rebirth", "自動転生 (Rebirth)", "자동 환생 (리버스)", "自动转生 (Rebirth)" },
    { "Auto Sell All", "Jual Semua Otomatis", "Vender Todo Automáticamente", "Vender Tudo Automaticamente", "Авто-Продажа Всего", "Vente Auto de Tout", "Alles automatisch verkaufen", "Tự động Bán tất cả", "Awtomatikong Ibenta Lahat", "全アイテム自動売却", "모든 アイテム 자동 판매", "自动出售全部物品" },
    { "Auto Cast & Reel", "Auto Lempar & Gulung Pancing", "Auto Lanzar y Recoger Caña", "Auto Lançar e Recolher Vara", "Авто-Заброс и Подсечка", "Lancer et Moulinet Auto", "Automatisches Auswerfen & Einholen", "Tự động Quăng & Kéo cần câu", "Auto Hagis at Hila ng Bingwit", "釣り糸自動キャスト＆巻き取り", "낚시대 자동 캐스팅 및 릴링", "自动抛竿与收线" },
    { "Auto Magnet", "Magnet Otomatis", "Imán Automático", "Ímã Automático", "Авто-Магнит", "Aimant Auto", "Automatischer Magnet", "Hút đồ Tự động", "Awtomatikong Magnet", "自動マグネット吸引", "자동 자석 흡입", "自动吸附磁铁" },
    { "Economy & Rebirth", "Ekonomi & Rebirth", "Economía y Renacimiento", "Economia e Renascimento", "Экономика и Перерождения", "Économie et Renaissance", "Wirtschaft & Rebirth", "Kinh tế & Tái sinh", "Ekonomiya at Rebirth", "経済＆転生", "경제 및 환생", "经济与转生系统" },
    { "Bed ESP & Destroyer", "ESP Ranjang & Penghancur", "ESP y Destructor de Camas", "ESP e Destruidor de Camas", "ESP и Уничтожитель Кроватей", "ESP et Destructeur de Lits", "Betten-ESP & Zerstörer", "ESP & Phá Giường", "Bed ESP at Destroyer", "ベッドESP＆自動破壊", "침대 ESP 및 파괴기", "床位透视与自动拆床" },
    { "Combat Aura (Killaura)", "Combat Aura (Killaura)", "Aura de Combate (Killaura)", "Aura de Combate (Killaura)", "Боевая Аура (Киллаура)", "Aura de Combat (Killaura)", "Kampf-Aura (Killaura)", "Hào quang Chiến đấu (Killaura)", "Combat Aura (Killaura)", "戦闘オーラ (Kill Aura)", "전투 오라 (킬오라)", "杀戮光环 (Killaura)" },
    { "Resource Magnet", "Magnet Sumber Daya", "Imán de Recursos", "Ímã de Recursos", "Магнит Ресурсов", "Aimant à Ressources", "Ressourcen-Magnet", "Hút Tài nguyên", "Magnet ng Yaman", "リソース磁石吸引", "자원 자석 흡입", "资源物资磁吸" },
    { "Combat & Weapon Engine", "Engine Tempur & Senjata", "Motor de Combate y Armas", "Motor de Combate e Armas", "Движок Боя и Оружия", "Moteur de Combat et d'Armes", "Kampf- & Waffen-Engine", "Động cơ Chiến đấu & Vũ khí", "Combat at Weapon Engine", "戦闘＆武器エンジン", "전투 및 무기 엔진", "战斗与武器强化引擎" },
    { "Enemy Visuals & ESP", "Visual & ESP (Khusus Musuh)", "Visuales y ESP (Solo Enemigos)", "Visuais e ESP (Apenas Inimigos)", "Визуалы и ESP (Только Враги)", "Visuels et ESP (Ennemis Uniquement)", "Visuelles & ESP (Nur Feinde)", "Hình ảnh & ESP (Chỉ Kẻ địch)", "Mga Visual at ESP (Kaaway Lamang)", "敵専用視覚効果＆ESP", "적 전용 비주얼 및 ESP", "敌人专属视觉与ESP透视" },
}
local I18N_MAP = {}
for i = 1, #I18N_RAW do
    local row = I18N_RAW[i]
    for c = 1, #row do
        local val = row[c]
        if type(val) == "string" and val ~= "" then
            I18N_MAP[val] = row
            I18N_MAP[string.lower(val)] = row
        end
    end
end

-- Constructor
function X08I18n.new(options)
    local self = setmetatable({}, X08I18n)
    self.Preference = "auto"
    self.SystemLanguage = "en"
    self.CurrentLanguage = "en"
    self.CustomMap = {}
    self:Init()
    return self
end

function X08I18n:NormalizeLocale(locStr)
    if type(locStr) ~= "string" or #locStr < 2 then return "en" end
    local lower = string.lower(locStr)
    if string.find(lower, "^id") then return "id" end
    if string.find(lower, "^es") then return "es" end
    if string.find(lower, "^pt") then return "pt" end
    if string.find(lower, "^ru") or string.find(lower, "^uk") or string.find(lower, "^be") or string.find(lower, "^kk") then return "ru" end
    if string.find(lower, "^fr") then return "fr" end
    if string.find(lower, "^de") then return "de" end
    if string.find(lower, "^vi") then return "vi" end
    if string.find(lower, "^tl") or string.find(lower, "^fil") then return "tl" end
    if string.find(lower, "^ja") then return "ja" end
    if string.find(lower, "^ko") then return "ko" end
    if string.find(lower, "^zh") then return "zh-CN" end
    return "en"
end

function X08I18n:MapCountryToLocale(country)
    if type(country) ~= "string" or #country ~= 2 then return nil end
    local c = string.upper(country)
    if c == "ID" then return "id" end
    if c == "BR" or c == "PT" or c == "AO" or c == "MZ" then return "pt" end
    if c == "ES" or c == "MX" or c == "AR" or c == "CO" or c == "CL" or c == "PE" or c == "VE" or c == "EC" or c == "GT" or c == "CU" or c == "BO" or c == "DO" or c == "HN" or c == "PY" or c == "SV" or c == "NI" or c == "CR" or c == "PR" or c == "PA" or c == "UY" or c == "GQ" then return "es" end
    if c == "RU" or c == "UA" or c == "BY" or c == "KZ" or c == "UZ" or c == "KG" or c == "TJ" then return "ru" end
    if c == "FR" or c == "BE" or c == "CH" or c == "SN" or c == "CI" or c == "CD" or c == "CM" or c == "MG" then return "fr" end
    if c == "DE" or c == "AT" or c == "LI" then return "de" end
    if c == "VN" then return "vi" end
    if c == "PH" then return "tl" end
    if c == "JP" then return "ja" end
    if c == "KR" or c == "KP" then return "ko" end
    if c == "CN" or c == "TW" or c == "HK" or c == "MO" or c == "SG" then return "zh-CN" end
    return nil
end

function X08I18n:DetectLocale()
    local detected = nil

    -- Sumber 1: LocalizationService.RobloxLocaleId
    pcall(function()
        local loc = game:GetService("LocalizationService")
        if loc then
            local rId = loc.RobloxLocaleId
            if type(rId) == "string" and #rId >= 2 then
                local norm = self:NormalizeLocale(rId)
                if norm and norm ~= "en" then
                    detected = norm
                    return
                end
            end
        end
    end)
    if detected then return detected end

    -- Sumber 2: LocalizationService.SystemLocaleId
    pcall(function()
        local loc = game:GetService("LocalizationService")
        if loc then
            local sId = loc.SystemLocaleId
            if type(sId) == "string" and #sId >= 2 then
                local norm = self:NormalizeLocale(sId)
                if norm and norm ~= "en" then
                    detected = norm
                    return
                end
            end
        end
    end)
    if detected then return detected end

    -- Sumber 3: LocalPlayer.LocaleId (properti pemain)
    pcall(function()
        local players = game:GetService("Players")
        local lp = players and players.LocalPlayer
        if lp then
            local pLocale = lp.LocaleId
            if type(pLocale) == "string" and #pLocale >= 2 then
                local norm = self:NormalizeLocale(pLocale)
                if norm and norm ~= "en" then
                    detected = norm
                    return
                end
            end
        end
    end)
    if detected then return detected end

    -- Sumber 4: Geo-Region Country Code (Fallback pintar jika locale ter-lock ke "en")
    pcall(function()
        local loc = game:GetService("LocalizationService")
        local players = game:GetService("Players")
        local lp = players and players.LocalPlayer
        if loc and lp and type(loc.GetCountryRegionForPlayerAsync) == "function" then
            local country = loc:GetCountryRegionForPlayerAsync(lp)
            local mapped = self:MapCountryToLocale(country)
            if mapped then
                detected = mapped
                return
            end
        end
    end)
    if detected then return detected end

    return "en"
end

function X08I18n:Init()
    self.SystemLanguage = self:DetectLocale()
    local saved = "auto"
    if type(readfile) == "function" and type(isfile) == "function" then
        pcall(function()
            if isfile("X08Hub/language.txt") then
                local raw = readfile("X08Hub/language.txt")
                if type(raw) == "string" and #raw > 0 then
                    local clean = string.gsub(raw, "%s+", "")
                    if I18N_NAME_TO_CODE[clean] then
                        saved = I18N_NAME_TO_CODE[clean]
                    elseif I18N_LANG_NAMES[clean] then
                        saved = clean
                    end
                end
            end
        end)
    end
    self:ApplyLanguage(saved)
end

function X08I18n:ApplyLanguage(pref)
    self.Preference = pref or "auto"
    if self.Preference == "auto" then
        self.CurrentLanguage = self.SystemLanguage or self:DetectLocale()
    else
        self.CurrentLanguage = self.Preference
    end
    if not self.CurrentLanguage or self.CurrentLanguage == "" then
        self.CurrentLanguage = "en"
    end
end

function X08I18n:SetPreference(val)
    local code = I18N_NAME_TO_CODE[val] or val
    if not I18N_LANG_NAMES[code] then code = "auto" end
    self:ApplyLanguage(code)
    if type(writefile) == "function" then
        pcall(function()
            if type(isfolder) == "function" and not isfolder("X08Hub") then
                makefolder("X08Hub")
            end
            writefile("X08Hub/language.txt", code)
        end)
    end
end

function X08I18n:GetPreference()
    return self.Preference or "auto"
end

function X08I18n:GetDisplayName()
    if self.Preference == "auto" then
        return "Auto (System)"
    end
    return I18N_LANG_NAMES[self.Preference] or "Auto (System)"
end

function X08I18n:GetLanguageName(code)
    return I18N_LANG_NAMES[code or self.CurrentLanguage] or "English"
end

function X08I18n:GetAvailableLanguages()
    return {
        "Auto (System)",
        "English",
        "Bahasa Indonesia",
        "Español",
        "Português",
        "Русский",
        "Français",
        "Deutsch",
        "Tiếng Việt",
        "Tagalog",
        "日本語",
        "한국어",
        "简体中文"
    }
end

function X08I18n:RegisterTranslations(newRows)
    if type(newRows) ~= "table" then return end
    for _, row in ipairs(newRows) do
        if type(row) == "table" and #row >= 1 then
            for c = 1, #row do
                local val = row[c]
                if type(val) == "string" and val ~= "" then
                    self.CustomMap[val] = row
                    self.CustomMap[string.lower(val)] = row
                end
            end
        end
    end
end

function X08I18n:Translate(text)
    if type(text) ~= "string" or text == "" then return text end
    local lang = self.CurrentLanguage or "en"
    local idx = I18N_LANG_INDEX[lang] or 1

    -- 1. Direct O(1) Lookup
    local row = self.CustomMap[text] or self.CustomMap[string.lower(text)] or I18N_MAP[text] or I18N_MAP[string.lower(text)]
    if row then
        return row[idx] or row[1] or text
    end

    -- 2. Normalisasi Prefix/Suffix Emojis & Simbol
    -- Contoh: "🎯 Combat & Weapon Engine", "⚡ Automasi Warnet", "🎁 Daily Rewards"
    local pfx, core, sfx = string.match(text, "^([^%w%z]*)(.-)([%s%p%z]*)$")
    if core and core ~= "" and core ~= text then
        local coreRow = self.CustomMap[core] or self.CustomMap[string.lower(core)] or I18N_MAP[core] or I18N_MAP[string.lower(core)]
        if coreRow then
            local transCore = coreRow[idx] or coreRow[1] or core
            return (pfx or "") .. transCore .. (sfx or "")
        end
    end

    -- 3. Normalisasi Penjelasan dalam Kurung jika ada
    -- Contoh: "Otomatisasi Runner (Pelari)" -> base "Otomatisasi Runner"
    local base, paren = string.match(text, "^(.-)%s*(%b())$")
    if base and base ~= "" then
        local baseRow = self.CustomMap[base] or self.CustomMap[string.lower(base)] or I18N_MAP[base] or I18N_MAP[string.lower(base)]
        if baseRow then
            local transBase = baseRow[idx] or baseRow[1] or base
            return transBase .. " " .. paren
        end
    end

    return text
end

-- Inisialisasi default singleton instance
local defaultInstance = X08I18n.new()
_G.X08_I18n = defaultInstance
_G.X08_T = function(str)
    return defaultInstance:Translate(str)
end

return X08I18n

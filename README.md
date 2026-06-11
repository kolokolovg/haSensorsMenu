# haSensorsMenu

macOS приложение для строки меню, отображающее датчики температуры, влажности и переключатели из Home Assistant.

## Возможности

- Отображение температуры и влажности из настроенных комнат
- Интерактивные переключатели (`light.*`, `switch.*`) — клик отправляет toggle в Home Assistant
- Два стиля отображения комнат: Compact (две строки) и One Line (всё в одной строке)
- Настройка комнат и переключателей через окно настроек
- Сортировка элементов с помощью кнопок ▲/▼ в настройках
- Настраиваемый интервал опроса (10–300 секунд)
- Русский и English интерфейс

## Требования

- macOS 14.0+
- Сервер Home Assistant с REST API

## Установка

1. Скачайте последний релиз из [Releases](https://github.com/gleb/haSensorsMenu/releases)
2. Перетащите `haSensorsMenu.app` в `/Applications`
3. Запустите приложение — появится иконка в строке меню
4. При первом запуске откроется окно настроек

## Настройка

### Подключение к Home Assistant

Вкладка **Connection** в настройках:

| Поле | Описание | Пример |
|------|----------|--------|
| **Server Address** | URL сервера HA c `/api/states` | `https://ha.example.com/api/states` |
| **Access Token** | Long-lived токен (Профиль → Токены) | `eyJhbGciOiJIU...` |
| **API Base URL** | Базовый URL API (заполняется автоматически) | `https://ha.example.com/api` |
| **Poll Interval** | Частота обновления данных | `60 sec` |

### Добавление комнат

1. Вкладка **Rooms**
2. Нажмите **Add**
3. Укажите название комнаты и entity_id датчиков температуры и влажности

### Добавление переключателей

1. Вкладка **Switches**
2. Нажмите **Add**
3. Укажите название и entity_id (например, `light.zal_fonar` или `switch.pere`)

Работает для любых сущностей Home Assistant, поддерживающих сервис `toggle` (`light.*`, `switch.*`, `fan.*`, `cover.*` и т.д.).

### Стиль отображения

Вкладка **Appearance** — выбор между Compact и One Line для карточек комнат. Превью обновляется в реальном времени.

## Сборка из исходников

```bash
git clone https://github.com/gleb/haSensorsMenu.git
cd haSensorsMenu
open haSensorsMenu.xcodeproj
```

Выберите схему **haSensorsMenu** и нажмите `Cmd+R`.  
Сборка через Xcode 16+.

## Локализация

Поддерживаются русский и английский языки. Язык переключается во вкладке Language без перезапуска.

Файлы локализации: `en.lproj/Localizable.strings`, `ru.lproj/Localizable.strings`.

Чтобы добавить новый язык:
1. Создайте `<code>.lproj/Localizable.strings`
2. Локализуйте все ключи
3. Добавьте язык в `LanguageSettingsView.swift`

## Структура проекта

```
haSensorsMenu/
├── haSensorsMenu.xcodeproj/     # Проект Xcode
├── LICENSE                      # MIT License
├── README.md
└── haSensorsMenu/
    ├── HASensorsApp.swift       # @main точка входа
    ├── Models.swift              # Модели данных
    ├── HASensorStore.swift       # Сеть, опрос HA, toggle
    ├── SettingsManager.swift     # Persistence (UserDefaults)
    ├── StatusBarManager.swift    # Иконка и попап меню
    ├── SettingsWindowManager.swift # Окно настроек
    ├── BundleExtension.swift     # Runtime локализация (L10n)
    ├── MenuContentView.swift     # Основное вью меню
    ├── RoomView.swift            # Карточка комнаты
    ├── SwitchRowView.swift       # Строка переключателя
    ├── RoomsSettingsView.swift   # Настройки комнат (+ Add/Edit)
    ├── SwitchesSettingsView.swift # Настройки переключателей
    ├── ConnectionSettingsView.swift # Настройки подключения
    ├── AppearanceSettingsView.swift # Настройки внешнего вида
    ├── LanguageSettingsView.swift # Настройки языка
    ├── SettingsView.swift        # Основное вью настроек (табы)
    ├── en.lproj/                 # Английская локализация
    └── ru.lproj/                 # Русская локализация
```

## Лицензия

MIT License — см. [LICENSE](LICENSE).

---

# haSensorsMenu

A macOS menu bar app that displays temperature, humidity sensors and interactive switches from Home Assistant.

## Features

- Temperature and humidity display for configured rooms
- Interactive switches (`light.*`, `switch.*`) — click sends a toggle command to Home Assistant
- Two room display styles: Compact (two-line) and One Line (all in one row)
- Room and switch configuration via a settings window
- Reorder items with ▲/▼ buttons in settings
- Configurable polling interval (10–300 seconds)
- English and Russian interface

## Requirements

- macOS 14.0+
- Home Assistant server with REST API

## Installation

1. Download the latest release from [Releases](https://github.com/gleb/haSensorsMenu/releases)
2. Drag `haSensorsMenu.app` to `/Applications`
3. Launch the app — the menu bar icon will appear
4. The settings window opens on first launch

## Configuration

### Connection settings

**Connection** tab:

| Field | Description | Example |
|-------|-------------|---------|
| **Server Address** | HA server URL with `/api/states` | `https://ha.example.com/api/states` |
| **Access Token** | Long-lived token (Profile → Tokens) | `eyJhbGciOiJIU...` |
| **API Base URL** | Base API URL (auto-filled) | `https://ha.example.com/api` |
| **Poll Interval** | Data refresh rate | `60 sec` |

### Adding rooms

1. Go to the **Rooms** tab
2. Click **Add**
3. Enter a room name, temperature sensor entity_id, and humidity sensor entity_id

### Adding switches

1. Go to the **Switches** tab
2. Click **Add**
3. Enter a name and entity_id (e.g. `light.zal_fonar` or `switch.pere`)

Works with any Home Assistant entity that supports the `toggle` service (`light.*`, `switch.*`, `fan.*`, `cover.*`, etc.).

### Display style

The **Appearance** tab lets you choose between Compact and One Line room cards. The preview updates in real time.

## Building from source

```bash
git clone https://github.com/gleb/haSensorsMenu.git
cd haSensorsMenu
open haSensorsMenu.xcodeproj
```

Select the **haSensorsMenu** scheme and press `Cmd+R`.  
Build with Xcode 16+.

## Localization

Russian and English are supported. Language can be switched in the Language tab without restarting.

Localization files: `en.lproj/Localizable.strings`, `ru.lproj/Localizable.strings`.

To add a new language:
1. Create `<code>.lproj/Localizable.strings`
2. Translate all keys
3. Add the language in `LanguageSettingsView.swift`

## Project structure

```
haSensorsMenu/
├── haSensorsMenu.xcodeproj/     # Xcode project
├── LICENSE                      # MIT License
├── README.md
└── haSensorsMenu/
    ├── HASensorsApp.swift       # @main entry point
    ├── Models.swift              # Data models
    ├── HASensorStore.swift       # Networking, polling, toggle
    ├── SettingsManager.swift     # Persistence (UserDefaults)
    ├── StatusBarManager.swift    # Menu bar icon & popover
    ├── SettingsWindowManager.swift # Settings window
    ├── BundleExtension.swift     # Runtime localization (L10n)
    ├── MenuContentView.swift     # Main popover content
    ├── RoomView.swift            # Room card view
    ├── SwitchRowView.swift       # Switch toggle row
    ├── RoomsSettingsView.swift   # Room settings (+ Add/Edit)
    ├── SwitchesSettingsView.swift # Switch settings
    ├── ConnectionSettingsView.swift # Connection settings
    ├── AppearanceSettingsView.swift # Appearance settings
    ├── LanguageSettingsView.swift # Language settings
    ├── SettingsView.swift        # Main settings view (tabs)
    ├── en.lproj/                 # English localization
    └── ru.lproj/                 # Russian localization
```

## License

MIT License — see [LICENSE](LICENSE).

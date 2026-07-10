# AGENTS.md — haSensorsMenu

## Описание

macOS menu bar app for Home Assistant: displays temperature, humidity, switches, and UPS input voltage from HA REST API.

## Архитектура

MV-ish: SwiftUI + AppKit (NSStatusItem, NSPopover). 
`ObservableObject` + `@Published` for state, Combine for persistence.

## Как добавить новый сенсор

1. **Models.swift** — persistence model + display model
2. **SettingsManager.swift** — `@Published var`, save/load UserDefaults, observer
3. **HASensorStore.swift** — `@Published var`, fetch + rebuild, optional alert logic
4. **View файлы** — отображение в popover/status bar
5. **SettingsView** + новая вкладка настроек
6. **en.lproj / ru.lproj** — локализация

## Конвенции

- `L10n("key")` — runtime локализация (LanguageManager)
- `@MainActor` на `HASensorStore`
- `UserDefaults` для persistence, auto-save через Combine `dropFirst().sink`
- Обращаться к HA через `fetchSensor(id:token:apiBaseURL:)`
- Новые сущности UPS:
  - `UPSConfig` — Codable, UserDefaults key `"ha_ups_config"`
  - `UPSDisplayData` — вычисляемые `voltageValue`, `isOutOfRange`
  - Unused iCloud, no CoreData
- Alamofire отсутствует — только `URLSession`
- GitHub token is NOT stored in code
- `VoltageHistoryManager` — JSON-логирование в Application Support
- Swift Charts для `VoltageGraphView`

## Файлы

| Файл | Назначение |
|------|------------|
| `HASensorsApp.swift` | @main, AppDelegate, UNUserNotificationCenter delegate |
| `Models.swift` | HASensor, HAAttributes, RoomConfig, HASwitchConfig, UPSConfig, RoomDisplayData, HASwitchDisplayData, UPSDisplayData |
| `HASensorStore.swift` | @MainActor ObservableObject: polling, fetch, toggle, alerts |
| `SettingsManager.swift` | Persistence: UserDefaults + Combine auto-save |
| `StatusBarManager.swift` | NSStatusItem (house.fill + voltage), NSPopover |
| `NotificationManager.swift` | UNUserNotificationCenter: voltage alerts |
| `LanguageManager.swift` | Runtime localization (L10n) |
| `MenuContentView.swift` | SwiftUI popover layout |
| `RoomView.swift` | Room card (compact / oneLine) |
| `SwitchRowView.swift` | Switch toggle row |
| `UPSSettingsView.swift` | UPS settings form |
| `RoomsSettingsView.swift` | Room settings |
| `AddRoomView.swift` | Add room form |
| `EditRoomView.swift` | Edit room form |
| `RoomRow.swift` | Room row in settings list |
| `SwitchesSettingsView.swift` | Switch settings |
| `ConnectionSettingsView.swift` | Connection settings |
| `AppearanceSettingsView.swift` | Appearance settings |
| `LanguageSettingsView.swift` | Language settings |
| `SettingsView.swift` | Tabbed settings (connection, rooms, switches, ups, language, appearance) |
| `VoltageGraphView.swift` | Voltage chart (Swift Charts) |
| `VoltageHistoryManager.swift` | Voltage & alert history persistence |
| `AlertHistoryView.swift` | Alert history window content |
| `AlertHistoryWindowManager.swift` | NSWindow for AlertHistoryView |

## Сборка

```bash
xcodebuild -project haSensorsMenu.xcodeproj -scheme haSensorsMenu build
```

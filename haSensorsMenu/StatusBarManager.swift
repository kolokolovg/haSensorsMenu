import SwiftUI
import AppKit
import Combine

final class StatusBarManager {
    private let statusItem: NSStatusItem
    private var popover: NSPopover!
    private var cancellables = Set<AnyCancellable>()
    private let store: HASensorStore
    private let settings: SettingsManager

    init(store: HASensorStore, settings: SettingsManager) {
        self.store = store
        self.settings = settings
        
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.statusItem.button?.image = NSImage(systemSymbolName: "house.fill", accessibilityDescription: "HA Климат")
        self.statusItem.button?.image?.isTemplate = true
        
        // Создаем Popover
        self.popover = NSPopover()
        self.popover.contentSize = NSSize(width: 280, height: 0)
        self.popover.behavior = .transient
        self.popover.animates = true
        
        updatePopoverContent()
        
        // Обработчик клика на иконку
        self.statusItem.button?.action = #selector(togglePopover(_:))
        self.statusItem.button?.target = self
        
        // Обновляем иконку при изменении данных
        store.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateIcon()
            }
        }.store(in: &cancellables)
    }
    
    @objc private func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            popover.performClose(sender)
        } else if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
    
    private func updatePopoverContent() {
        let swiftUIView = MenuContentView(store: store)
        let hostingView = NSHostingController(rootView: swiftUIView)
        popover.contentViewController = hostingView
    }
    
    private func updateIcon() {
        let symbol = store.isUpdating ? "arrow.triangle.2.circlepath" : "house.fill"
        statusItem.button?.image = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)
        statusItem.button?.image?.isTemplate = true
    }
}

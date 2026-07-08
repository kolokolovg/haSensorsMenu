import SwiftUI
import AppKit

class AlertHistoryWindowManager {
    static let shared = AlertHistoryWindowManager()

    private var window: NSWindow?

    func open(historyManager: VoltageHistoryManager) {
        NSApp.activate(ignoringOtherApps: true)

        if window == nil {
            let newWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 360, height: 300),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )

            newWindow.title = L10n("alert_history_title")
            newWindow.level = .floating
            newWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            newWindow.isReleasedWhenClosed = false

            let hostingController = NSHostingController(rootView: AlertHistoryView(historyManager: historyManager))
            newWindow.contentView = hostingController.view

            newWindow.center()
            self.window = newWindow
        }

        window?.makeKeyAndOrderFront(nil)
        window?.orderFrontRegardless()
    }

    func close() {
        window?.close()
    }
}

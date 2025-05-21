import SwiftUI
import AppKit

@main
struct MonkeyTypeApp: App {
    private let defaultWidth: CGFloat = 900
    private let defaultHeight: CGFloat = 600
    private let minWidth: CGFloat = 800
    private let minHeight: CGFloat = 500
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: minWidth, minHeight: minHeight)
                .preferredColorScheme(.dark)
        }
        .windowStyle(.hiddenTitleBar) 
        .defaultSize(width: defaultWidth, height: defaultHeight)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) { }
            
            CommandGroup(after: .appSettings) {
                Button("Restart Test") {
                    NotificationCenter.default.post(name: .restartTest, object: nil)
                }
                .keyboardShortcut("r", modifiers: .command)
                
                Button("Show Settings") {
                    NotificationCenter.default.post(name: .showSettings, object: nil)
                }
                .keyboardShortcut(",", modifiers: .command)
            }
            
            CommandMenu("Test Mode") {
                Button("Time Test") {
                    NotificationCenter.default.post(name: .switchTestMode, object: nil, userInfo: ["mode": "time"])
                }
                .keyboardShortcut("1", modifiers: .command)
                
                Button("Words Test") {
                    NotificationCenter.default.post(name: .switchTestMode, object: nil, userInfo: ["mode": "words"])
                }
                .keyboardShortcut("2", modifiers: .command)
                
                Button("Quote Test") {
                    NotificationCenter.default.post(name: .switchTestMode, object: nil, userInfo: ["mode": "quote"])
                }
                .keyboardShortcut("3", modifiers: .command)
                
                Button("Zen Mode") {
                    NotificationCenter.default.post(name: .switchTestMode, object: nil, userInfo: ["mode": "zen"])
                }
                .keyboardShortcut("4", modifiers: .command)
                
                Divider()
                
                Button("Cancel Test") {
                    NotificationCenter.default.post(name: .cancelTest, object: nil)
                }
                .keyboardShortcut(.escape, modifiers: [])
            }
        }
    }
}

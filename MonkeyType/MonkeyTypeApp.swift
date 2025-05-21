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
            // Remove New Window command
            CommandGroup(replacing: .newItem) { }
            
            // Add custom commands to app menu
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
            
            CommandMenu("View") {
                Button("Toggle Live WPM") {
                    NotificationCenter.default.post(name: .toggleLiveWPM, object: nil)
                }
                .keyboardShortcut("w", modifiers: .command)
                
                Button("Toggle Live Accuracy") {
                    NotificationCenter.default.post(name: .toggleLiveAccuracy, object: nil)
                }
                .keyboardShortcut("a", modifiers: .command)
                
                Button("Toggle Keyboard") {
                    NotificationCenter.default.post(name: .toggleKeyboard, object: nil)
                }
                .keyboardShortcut("k", modifiers: .command)
                
                Divider()
                
                Button("Enter Full Screen") {
                    if let window = NSApplication.shared.windows.first {
                        window.toggleFullScreen(nil)
                    }
                }
                .keyboardShortcut("f", modifiers: [.command, .control])
            }
        }
    }
}

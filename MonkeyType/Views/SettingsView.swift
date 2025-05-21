import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: Settings
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Test") {
                    Toggle("Show Live WPM", isOn: $settings.showLiveWPM)
                    Toggle("Show Live Accuracy", isOn: $settings.showLiveAccuracy)
                    Toggle("Sound Effects", isOn: $settings.soundEnabled)
                    Toggle("Smooth Cursor", isOn: $settings.smoothCursor)
                    Toggle("Show Keyboard", isOn: $settings.showKeyboard)
                }
                
                Section("Appearance") {
                    Picker("Font Family", selection: $settings.fontFamily) {
                        Text("JetBrains Mono").tag("JetBrains Mono")
                        Text("Source Code Pro").tag("Source Code Pro")
                        Text("Fira Code").tag("Fira Code")
                        Text("Roboto Mono").tag("Roboto Mono")
                    }
                    
                    Stepper("Font Size: \(settings.fontSize)", value: $settings.fontSize, in: 12...24)
                    
                    NavigationLink("Theme") {
                        ThemePicker(selectedTheme: $settings.theme)
                            .navigationTitle("Theme")
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
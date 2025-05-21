import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: Settings
    @Environment(\.dismiss) var dismiss
    @State private var showingThemePicker = false
    @State private var selectedTab = "Test"
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom header
            HStack {
                Text("Settings")
                    .font(.title2)
                    .foregroundColor(settings.theme.colors.text)
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
            }
            .padding()
            
            // Settings content
            ScrollView {
                Form {
                    Section("Test") {
                        Toggle("Show Live WPM", isOn: $settings.showLiveWPM)
                        Toggle("Show Live Accuracy", isOn: $settings.showLiveAccuracy)
                    }
                    
                    Section("Keyboard") {
                        Toggle("Show Keyboard", isOn: $settings.showKeyboard)
                        
                        if settings.showKeyboard {
                            Picker("Layout", selection: $settings.layout) {
                                ForEach(Settings.Layout.allCases, id: \.self) { layout in
                                    Text(layout.description)
                                        .tag(layout)
                                }
                            }
                            
                            Stepper("Height: \(settings.keyboardHeight)", value: $settings.keyboardHeight, in: 60...120)
                            
                            HStack {
                                Text("Opacity")
                                Slider(value: $settings.keyboardOpacity, in: 0.1...1.0)
                            }
                            
                            // Preview
                            KeyboardView(
                                settings: settings,
                                pressedKeys: []
                            )
                            .frame(height: 120)
                            .padding(.vertical)
                        }
                    }
                    
                    Section("Cursor") {
                        Picker("Caret Style", selection: $settings.caretStyle) {
                            ForEach(Settings.CaretStyle.allCases, id: \.self) { style in
                                Text(style.description)
                                    .tag(style)
                            }
                        }
                        
                        if settings.caretStyle != .off {
                            Toggle("Smooth Cursor", isOn: $settings.smoothCursor)
                        }
                    }
                    
                    Section("Behavior") {
                        Toggle("Smooth Line Scroll", isOn: $settings.smoothLineScroll)
                        Toggle("Sound Effects", isOn: $settings.soundEnabled)
                        
                        if settings.soundEnabled {
                            HStack {
                                Text("Volume")
                                Slider(value: $settings.soundVolume, in: 0...1)
                            }
                        }
                    }
                    
                    Section("Appearance") {
                        Picker("Font Family", selection: $settings.fontFamily) {
                            Text("JetBrains Mono").tag("JetBrains Mono")
                            Text("Source Code Pro").tag("Source Code Pro")
                            Text("Fira Code").tag("Fira Code")
                            Text("Roboto Mono").tag("Roboto Mono")
                        }
                        
                        Stepper("Font Size: \(settings.fontSize)", value: $settings.fontSize, in: 12...24)
                        
                        Button("Theme") {
                            showingThemePicker = true
                        }
                    }
                    
                    Section("Language") {
                        Picker("Type", selection: $settings.languageGroup) {
                            ForEach(Settings.LanguageGroup.allCases, id: \.self) { group in
                                Text(group.description)
                                    .tag(group)
                            }
                        }
                        
                        if settings.languageGroup == .code {
                            Picker("Language", selection: $settings.language) {
                                ForEach(Settings.codeLanguages.sorted(by: { $0.value < $1.value }), id: \.key) { key, value in
                                    Text(value)
                                        .tag(key)
                                }
                            }
                        } else if settings.languageGroup == .english {
                            Picker("Wordlist", selection: $settings.language) {
                                Text("English").tag("english")
                                Text("English 1k").tag("english_1k")
                                Text("English 10k").tag("english_10k")
                            }
                            
                            if settings.testMode == .quote {
                                Picker("Quote Length", selection: $settings.quoteLength) {
                                    ForEach(Settings.QuoteLength.allCases, id: \.self) { length in
                                        Text(length.description)
                                            .tag(length)
                                    }
                                }
                            }
                        }
                    }
                }
                .formStyle(.grouped)
            }
        }
        .frame(width: 500, height: 600)
        .background(settings.theme.colors.background)
        .tint(settings.theme.colors.accent)
        .sheet(isPresented: $showingThemePicker) {
            ThemePicker(selectedTheme: $settings.theme)
        }
    }
}

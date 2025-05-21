import SwiftUI

struct CustomTextView: View {
    @ObservedObject var settings: Settings
    @Environment(\.dismiss) var dismiss
    @State private var tempText: String
    @State private var tempName: String
    
    init(settings: Settings) {
        self.settings = settings
        _tempText = State(initialValue: settings.customText)
        _tempName = State(initialValue: settings.customTextName)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Custom Text")
                    .font(.title2)
                    .foregroundColor(settings.theme.colors.text)
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
            }
            .padding()
            
            // Content
            VStack(spacing: 20) {
                TextField("Name", text: $tempName)
                    .textFieldStyle(.roundedBorder)
                    .foregroundColor(settings.theme.colors.text)
                
                TextEditor(text: $tempText)
                    .font(.system(.body, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .background(settings.theme.colors.background.opacity(0.3))
                    .cornerRadius(8)
                    .frame(maxHeight: .infinity)
                
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(settings.theme.colors.text)
                    
                    Button("Save") {
                        settings.customText = tempText
                        settings.customTextName = tempName
                        settings.customTextVisible = true
                        UserDefaults.standard.set(tempText, forKey: "customText")
                        UserDefaults.standard.set(tempName, forKey: "customTextName")
                        UserDefaults.standard.set(true, forKey: "customTextVisible")
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(settings.theme.colors.accent)
                    .disabled(tempText.isEmpty)
                }
            }
            .padding()
        }
        .frame(width: 500, height: 400)
        .background(settings.theme.colors.background)
    }
}

import SwiftUI

struct CustomTextView: View {
    @ObservedObject var settings: Settings
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Custom Text")
                .font(.title2)
            
            TextField("Name", text: $settings.customTextName)
                .textFieldStyle(.roundedBorder)
            
            TextEditor(text: $settings.customText)
                .font(.system(.body, design: .monospaced))
                .frame(height: 200)
                .cornerRadius(8)
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                
                Button("Save") {
                    settings.customTextVisible = true
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 500)
    }
}
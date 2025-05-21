import SwiftUI

struct ThemePicker: View {
    @Binding var selectedTheme: Settings.Theme
    @Environment(\.dismiss) var dismiss
    
    let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 16)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Theme")
                    .font(.title2)
                    .foregroundColor(selectedTheme.colors.text)
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
            }
            .padding()
            
            // Themes grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(Settings.themes, id: \.name) { theme in
                        ThemePreview(theme: theme, isSelected: theme == selectedTheme)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    selectedTheme = theme
                                }
                                dismiss()
                            }
                    }
                }
                .padding()
            }
        }
        .background(selectedTheme.colors.background)
        .frame(width: 600, height: 400)
    }
}

struct ThemePreview: View {
    let theme: Settings.Theme
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.colors.background)
                .overlay {
                    VStack(spacing: 4) {
                        Text("abc")
                            .foregroundColor(theme.colors.text)
                        Text("xyz")
                            .foregroundColor(theme.colors.subtext)
                    }
                    .font(.system(.body, design: .monospaced))
                }
                .frame(height: 80)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(isSelected ? theme.colors.accent : .clear, lineWidth: 2)
                }
                .animation(.easeInOut(duration: 0.2), value: isSelected)
            
            Text(theme.name.capitalized)
                .font(.caption)
        }
        .contentShape(Rectangle())
    }
}

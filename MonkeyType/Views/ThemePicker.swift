import SwiftUI

struct ThemePicker: View {
    @Binding var selectedTheme: Settings.Theme
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 150, maximum: 200))
            ], spacing: 16) {
                ForEach(Settings.Theme.allCases, id: \.self) { theme in
                    ThemePreview(theme: theme, isSelected: theme == selectedTheme)
                        .onTapGesture {
                            selectedTheme = theme
                        }
                }
            }
            .padding()
        }
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
            
            Text(theme.rawValue.capitalized)
                .font(.caption)
        }
    }
}
import SwiftUI

struct KeyboardView: View {
    @ObservedObject var settings: Settings
    let pressedKeys: Set<String>
    
    private func getLayoutKeys() -> [[String]] {
        switch settings.layout {
        case .qwerty:
            return [
                ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
                ["a", "s", "d", "f", "g", "h", "j", "k", "l", ";"],
                ["z", "x", "c", "v", "b", "n", "m", ",", ".", "/"]
            ]
        case .dvorak:
            return [
                ["'", ",", ".", "p", "y", "f", "g", "c", "r", "l"],
                ["a", "o", "e", "u", "i", "d", "h", "t", "n", "s"],
                [";", "q", "j", "k", "x", "b", "m", "w", "v", "z"]
            ]
        case .colemak:
            return [
                ["q", "w", "f", "p", "g", "j", "l", "u", "y", ";"],
                ["a", "r", "s", "t", "d", "h", "n", "e", "i", "o"],
                ["z", "x", "c", "v", "b", "k", "m", ",", ".", "/"]
            ]
        // Add other layouts as needed
        default:
            return [
                ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
                ["a", "s", "d", "f", "g", "h", "j", "k", "l", ";"],
                ["z", "x", "c", "v", "b", "n", "m", ",", ".", "/"]
            ]
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            ForEach(getLayoutKeys(), id: \.description) { row in
                HStack(spacing: 4) {
                    ForEach(row, id: \.self) { key in
                        Text(key.uppercased())
                            .frame(width: 32, height: 32)
                            .background(pressedKeys.contains(key) ? settings.theme.colors.accent : settings.theme.colors.background)
                            .foregroundColor(pressedKeys.contains(key) ? settings.theme.colors.background : settings.theme.colors.text)
                            .cornerRadius(4)
                    }
                }
            }
        }
        .padding()
        .background(settings.theme.colors.background.opacity(settings.keyboardOpacity))
        .cornerRadius(8)
        .frame(height: CGFloat(settings.keyboardHeight))
    }
}
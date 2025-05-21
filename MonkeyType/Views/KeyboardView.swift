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
        case .workman:
            return [
                ["q", "d", "r", "w", "b", "j", "f", "u", "p", ";"],
                ["a", "s", "h", "t", "g", "y", "n", "e", "o", "i"],
                ["z", "x", "m", "c", "v", "k", "l", ",", ".", "/"]
            ]
        case .colemak_dh:
            return [
                ["q", "w", "f", "p", "b", "j", "l", "u", "y", ";"],
                ["a", "r", "s", "t", "g", "m", "n", "e", "i", "o"],
                ["z", "x", "c", "d", "v", "k", "h", ",", ".", "/"]
            ]
        case .beakl15:
            return [
                ["q", "h", "o", "u", "x", "g", "c", "r", "f", "z"],
                ["y", "i", "e", "a", ".", "d", "s", "t", "n", "b"],
                ["j", "/", ",", "k", "'", "w", "m", "l", "p", "v"]
            ]
        case .norman:
            return [
                ["q", "w", "d", "f", "k", "j", "u", "r", "l", ";"],
                ["a", "s", "e", "t", "g", "y", "n", "i", "o", "h"],
                ["z", "x", "c", "v", "b", "p", "m", ",", ".", "/"]
            ]
        case .semimak:
            return [
                ["f", "l", "h", "v", "z", "q", "w", "u", "o", "y"],
                ["s", "r", "n", "t", "k", "c", "d", "e", "a", "i"],
                ["x", "j", "b", "m", "g", "p", ",", ".", "/", "'"]
            ]
        case .colemak_dhk:
            return [
                ["q", "w", "f", "p", "b", "j", "l", "u", "y", ";"],
                ["a", "r", "s", "t", "g", "k", "n", "e", "i", "o"],
                ["z", "x", "c", "d", "v", "m", "h", ",", ".", "/"]
            ]
        case .mtgap:
            return [
                ["y", "p", "o", "u", "j", "k", "d", "l", "c", "w"],
                ["i", "n", "e", "a", ",", "m", "h", "t", "s", "r"],
                ["q", "z", "/", ",", ".", "b", "f", "g", "v", "x"]
            ]
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            ForEach(getLayoutKeys(), id: \.description) { row in
                HStack(spacing: 4) {
                    ForEach(row, id: \.self) { key in
                        Text(key.uppercased())
                            .font(.system(.body, design: .monospaced))
                            .frame(width: 32, height: 32)
                            .background(
                                pressedKeys.contains(key) ? 
                                settings.theme.colors.accent : 
                                settings.theme.colors.background.opacity(0.3)
                            )
                            .foregroundColor(
                                pressedKeys.contains(key) ? 
                                settings.theme.colors.background : 
                                settings.theme.colors.text
                            )
                            .cornerRadius(4)
                            .animation(.spring(response: 0.15, dampingFraction: 0.4), value: pressedKeys.contains(key))
                            .shadow(color: settings.theme.colors.accent.opacity(0.2), radius: pressedKeys.contains(key) ? 4 : 0)
                    }
                }
            }
        }
        .padding()
        .background(settings.theme.colors.background.opacity(settings.keyboardOpacity))
        .cornerRadius(8)
        .frame(height: CGFloat(settings.keyboardHeight))
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

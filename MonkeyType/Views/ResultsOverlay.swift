import SwiftUI

struct ResultsOverlay: View {
    let result: TypingTestModel.TestResult
    let theme: Settings.Theme
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            // Stats Grid
            HStack(spacing: 40) {
                StatItem(title: "wpm", value: String(format: "%.0f", result.wpm), color: theme.colors.text)
                StatItem(title: "acc", value: String(format: "%.1f%%", result.accuracy), color: theme.colors.text)
                StatItem(title: "raw", value: String(format: "%.0f", result.rawWpm), color: theme.colors.text)
                if result.elapsedTime >= 1 {
                    StatItem(title: "time", value: "\(Int(result.elapsedTime))s", color: theme.colors.text)
                }
                StatItem(title: "char", value: "\(result.totalChars)", color: theme.colors.text)
            }
            
            // WPM Graph
            VStack(alignment: .leading, spacing: 8) {
                Text("wpm history")
                    .font(.caption)
                    .foregroundColor(theme.colors.subtext)
                
                WPMGraph(
                    values: result.wpmHistory,
                    maxValue: max(result.wpmHistory.max() ?? 100, 100),
                    color: theme.colors.text,
                    showTooltip: false
                )
                .frame(height: 60)
            }
            
            // Most Missed Keys
            if !result.mostMissedKeys.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("most missed")
                        .font(.caption)
                        .foregroundColor(theme.colors.subtext)
                    
                    HStack(spacing: 15) {
                        ForEach(result.mostMissedKeys.prefix(5), id: \.0) { key, count in
                            VStack {
                                Text(String(key))
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(theme.colors.text)
                                Text("\(count)")
                                    .font(.caption)
                                    .foregroundColor(theme.colors.subtext)
                            }
                            .frame(width: 40, height: 40)
                            .background(theme.colors.background.opacity(0.3))
                            .cornerRadius(6)
                        }
                    }
                }
            }
            
            // Consistency Score
            VStack(alignment: .leading, spacing: 8) {
                Text("consistency")
                    .font(.caption)
                    .foregroundColor(theme.colors.subtext)
                
                Text(String(format: "%.1f%%", result.consistencyPercent))
                    .font(.system(.title2, design: .monospaced))
                    .foregroundColor(theme.colors.text)
            }
            
            // Buttons
            HStack(spacing: 20) {
                Button("restart test") {
                    NotificationCenter.default.post(name: .restartTest, object: nil)
                    dismiss()
                }
                .keyboardShortcut(.tab, modifiers: [])
                
                Button("close") {
                    dismiss()
                }
                .keyboardShortcut(.escape, modifiers: [])
            }
            .buttonStyle(.bordered)
            .tint(theme.colors.accent)
        }
        .padding(40)
        .background(theme.colors.background)
        .cornerRadius(12)
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(color.opacity(0.7))
            Text(value)
                .font(.system(.title2, design: .monospaced))
                .foregroundColor(color)
        }
    }
}
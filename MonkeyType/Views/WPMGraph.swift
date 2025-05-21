import SwiftUI

struct WPMGraph: View {
    let values: [Double]
    let maxValue: Double
    let color: Color
    let showTooltip: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                // Grid lines
                ForEach(0...4, id: \.self) { i in
                    let y = geometry.size.height * CGFloat(i) / 4
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                    .stroke(color.opacity(0.1), lineWidth: 1)
                }
                
                // Graph lines
                Path { path in
                    guard !values.isEmpty else { return }
                    
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let step = width / CGFloat(max(1, values.count - 1))
                    
                    let points = values.enumerated().map { index, value in
                        CGPoint(
                            x: CGFloat(index) * step,
                            y: height - (CGFloat(value) / CGFloat(maxValue)) * height
                        )
                    }
                    
                    path.move(to: points[0])
                    for point in points.dropFirst() {
                        path.addLine(to: point)
                    }
                }
                .stroke(color, lineWidth: 2)
                
                // Latest value tooltip
                if showTooltip, let lastValue = values.last {
                    Text(String(format: "%.0f", lastValue))
                        .font(.caption)
                        .foregroundColor(color)
                        .position(
                            x: geometry.size.width,
                            y: geometry.size.height - (CGFloat(lastValue) / CGFloat(maxValue)) * geometry.size.height
                        )
                }
            }
        }
    }
}

struct WPMHistory: View {
    let wpm: Double
    let rawWpm: Double
    let accuracy: Double
    let time: TimeInterval
    let wpmHistory: [Double]
    let rawWpmHistory: [Double]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 40) {
                VStack(alignment: .leading) {
                    Text("wpm")
                        .font(.caption)
                        .opacity(0.7)
                    Text(String(format: "%.0f", wpm))
                        .font(.title)
                }
                
                VStack(alignment: .leading) {
                    Text("raw")
                        .font(.caption)
                        .opacity(0.7)
                    Text(String(format: "%.0f", rawWpm))
                        .font(.title)
                }
                
                VStack(alignment: .leading) {
                    Text("acc")
                        .font(.caption)
                        .opacity(0.7)
                    Text(String(format: "%.1f%%", accuracy))
                        .font(.title)
                }
                
                VStack(alignment: .leading) {
                    Text("time")
                        .font(.caption)
                        .opacity(0.7)
                    Text(String(format: "%.0fs", time))
                        .font(.title)
                }
            }
            
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("wpm")
                        .font(.caption)
                        .opacity(0.7)
                    WPMGraph(
                        values: wpmHistory,
                        maxValue: max(wpmHistory.max() ?? 100, 100),
                        color: .white,
                        showTooltip: false
                    )
                    .frame(height: 50)
                }
                
                VStack(alignment: .leading) {
                    Text("raw")
                        .font(.caption)
                        .opacity(0.7)
                    WPMGraph(
                        values: rawWpmHistory,
                        maxValue: max(rawWpmHistory.max() ?? 100, 100),
                        color: .white.opacity(0.5),
                        showTooltip: false
                    )
                    .frame(height: 50)
                }
            }
        }
        .padding()
        .frame(width: 500)
    }
}

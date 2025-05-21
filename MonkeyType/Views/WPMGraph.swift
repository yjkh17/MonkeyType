import SwiftUI

struct WPMGraph: View {
    let values: [Double]
    let maxValue: Double
    let color: Color
    let showTooltip: Bool
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                guard !values.isEmpty else { return }
                
                let width = geometry.size.width
                let height = geometry.size.height
                let step = width / CGFloat(values.count - 1)
                
                var points = values.enumerated().map { index, value in
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
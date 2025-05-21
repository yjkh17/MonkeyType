import SwiftUI

struct SmoothCursor: View {
    let position: CGPoint
    let color: Color
    let style: Settings.CaretStyle
    let height: CGFloat
    
    @State private var currentPosition: CGPoint = .zero
    
    var body: some View {
        Group {
            switch style {
            case .block:
                Rectangle()
                    .fill(color)
                    .frame(width: 2, height: height)
            case .outline:
                Rectangle()
                    .stroke(color, lineWidth: 1)
                    .frame(width: 2, height: height)
            case .underline:
                Rectangle()
                    .fill(color)
                    .frame(width: 10, height: 2)
            case .smooth:
                Rectangle()
                    .fill(color)
                    .frame(width: 2, height: height)
            case .off:
                EmptyView()
            }
        }
        .position(currentPosition)
        .animation(.interactiveSpring(response: 0.1, dampingFraction: 0.8), value: position)
        .onChange(of: position) { _, newPosition in
            currentPosition = newPosition
        }
    }
}

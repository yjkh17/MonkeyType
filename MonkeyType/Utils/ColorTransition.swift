import SwiftUI

extension Color {
    func blend(with color: Color, percentage: Double) -> Color {
        let percent = max(0, min(1, percentage))
        return self.opacity(1 - percent) + color.opacity(percent)
    }
    
    static func + (lhs: Color, rhs: Color) -> Color {
        let uiColor1 = UIColor(lhs)
        let uiColor2 = UIColor(rhs)
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        uiColor1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        uiColor2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return Color(
            red: Double(r1 + r2) / 2,
            green: Double(g1 + g2) / 2,
            blue: Double(b1 + b2) / 2,
            opacity: Double(a1 + a2) / 2
        )
    }
}
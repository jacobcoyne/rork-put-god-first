import SwiftUI

struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: 0, y: h * 0.7))
        path.addQuadCurve(to: CGPoint(x: w * 0.2, y: h * 0.35), control: CGPoint(x: w * 0.05, y: h * 0.4))
        path.addQuadCurve(to: CGPoint(x: w * 0.4, y: h * 0.15), control: CGPoint(x: w * 0.28, y: h * 0.1))
        path.addQuadCurve(to: CGPoint(x: w * 0.6, y: h * 0.08), control: CGPoint(x: w * 0.5, y: 0))
        path.addQuadCurve(to: CGPoint(x: w * 0.8, y: h * 0.3), control: CGPoint(x: w * 0.72, y: h * 0.05))
        path.addQuadCurve(to: CGPoint(x: w, y: h * 0.65), control: CGPoint(x: w * 0.95, y: h * 0.35))
        path.addQuadCurve(to: CGPoint(x: w * 0.8, y: h), control: CGPoint(x: w, y: h))
        path.addLine(to: CGPoint(x: w * 0.2, y: h))
        path.addQuadCurve(to: CGPoint(x: 0, y: h * 0.7), control: CGPoint(x: 0, y: h))
        path.closeSubpath()
        return path
    }
}

struct LuminousCrossShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let armW = w * 0.22
        let cx = w / 2
        let crossbar = h * 0.38
        let r: CGFloat = armW * 0.35
        path.move(to: CGPoint(x: cx - armW, y: 0 + r))
        path.addQuadCurve(to: CGPoint(x: cx - armW + r, y: 0), control: CGPoint(x: cx - armW, y: 0))
        path.addLine(to: CGPoint(x: cx + armW - r, y: 0))
        path.addQuadCurve(to: CGPoint(x: cx + armW, y: 0 + r), control: CGPoint(x: cx + armW, y: 0))
        path.addLine(to: CGPoint(x: cx + armW, y: crossbar - armW))
        path.addLine(to: CGPoint(x: w - r, y: crossbar - armW))
        path.addQuadCurve(to: CGPoint(x: w, y: crossbar - armW + r), control: CGPoint(x: w, y: crossbar - armW))
        path.addLine(to: CGPoint(x: w, y: crossbar + armW - r))
        path.addQuadCurve(to: CGPoint(x: w - r, y: crossbar + armW), control: CGPoint(x: w, y: crossbar + armW))
        path.addLine(to: CGPoint(x: cx + armW, y: crossbar + armW))
        path.addLine(to: CGPoint(x: cx + armW, y: h - r))
        path.addQuadCurve(to: CGPoint(x: cx + armW - r, y: h), control: CGPoint(x: cx + armW, y: h))
        path.addLine(to: CGPoint(x: cx - armW + r, y: h))
        path.addQuadCurve(to: CGPoint(x: cx - armW, y: h - r), control: CGPoint(x: cx - armW, y: h))
        path.addLine(to: CGPoint(x: cx - armW, y: crossbar + armW))
        path.addLine(to: CGPoint(x: 0 + r, y: crossbar + armW))
        path.addQuadCurve(to: CGPoint(x: 0, y: crossbar + armW - r), control: CGPoint(x: 0, y: crossbar + armW))
        path.addLine(to: CGPoint(x: 0, y: crossbar - armW + r))
        path.addQuadCurve(to: CGPoint(x: 0 + r, y: crossbar - armW), control: CGPoint(x: 0, y: crossbar - armW))
        path.addLine(to: CGPoint(x: cx - armW, y: crossbar - armW))
        path.addLine(to: CGPoint(x: cx - armW, y: 0 + r))
        path.closeSubpath()
        return path
    }
}

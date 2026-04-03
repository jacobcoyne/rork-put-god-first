import SwiftUI

struct LaunchAnimationView: View {
    let onFinished: () -> Void

    @State private var shieldScale: CGFloat = 0.3
    @State private var shieldOpacity: Double = 0
    @State private var shieldRotationY: Double = -30

    @State private var glowOpacity: Double = 0
    @State private var bgGlowOpacity: Double = 0
    @State private var shineSweep: Double = -0.5

    @State private var sparksVisible: Bool = false
    @State private var sparkBurst: CGFloat = 0

    @State private var flashOpacity: Double = 0
    @State private var raysOpacity: Double = 0
    @State private var raysRotation: Double = 0

    @State private var titleOpacity: Double = 0
    @State private var titleOffset: CGFloat = 14
    @State private var subtitleOpacity: Double = 0

    @State private var finalOpacity: Double = 1

    private let deepVoid = Color(red: 0.02, green: 0.01, blue: 0.06)
    private let divinePurple = Color(red: 0.12, green: 0.05, blue: 0.25)
    private let icyBlue = Color(red: 0.55, green: 0.78, blue: 1.0)
    private let icyPurple = Color(red: 0.58, green: 0.45, blue: 0.98)
    private let crystalBlue = Color(red: 0.35, green: 0.58, blue: 0.95)
    private let frostWhite = Color(red: 0.90, green: 0.95, blue: 1.0)
    private let electricCyan = Color(red: 0.3, green: 0.9, blue: 1.0)
    private let hotBlue = Color(red: 0.2, green: 0.6, blue: 1.0)

    private let sparkData: [(angle: Double, dist: CGFloat, size: CGFloat)] = [
        (0, 95, 3), (45, 105, 2.5), (90, 90, 3), (135, 100, 2.5),
        (180, 98, 3), (225, 92, 2.5), (270, 102, 3), (315, 96, 2.5)
    ]

    var body: some View {
        ZStack {
            background
            ambientGlow
            lightRays
            sparkParticles
            shieldImage
            screenFlash
            titleGroup
        }
        .opacity(finalOpacity)
        .ignoresSafeArea()
        .task { await runAnimation() }
    }

    private var background: some View {
        ZStack {
            deepVoid.ignoresSafeArea()
            LinearGradient(
                colors: [divinePurple.opacity(0.3), Color(red: 0.04, green: 0.02, blue: 0.14), deepVoid],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            Ellipse()
                .fill(RadialGradient(colors: [divinePurple.opacity(0.2), .clear], center: .center, startRadius: 20, endRadius: 180))
                .frame(width: 350, height: 260)
                .offset(x: 50, y: -160)
                .allowsHitTesting(false)
        }
    }

    private var ambientGlow: some View {
        RadialGradient(colors: [icyPurple.opacity(0.3), crystalBlue.opacity(0.12), .clear], center: .center, startRadius: 10, endRadius: 280)
            .scaleEffect(1.2)
            .opacity(bgGlowOpacity)
            .offset(y: -40)
            .ignoresSafeArea()
            .allowsHitTesting(false)
    }

    private var lightRays: some View {
        ForEach(0..<6, id: \.self) { i in
            RoundedRectangle(cornerRadius: 1)
                .fill(LinearGradient(colors: [electricCyan.opacity(0.3), icyBlue.opacity(0.1), .clear], startPoint: .bottom, endPoint: .top))
                .frame(width: i % 2 == 0 ? 2.5 : 1.5, height: i % 2 == 0 ? 220 : 150)
                .rotationEffect(.degrees(Double(i) * 60 + raysRotation))
                .opacity(raysOpacity)
                .offset(y: -40)
        }
    }

    private var sparkParticles: some View {
        ForEach(0..<sparkData.count, id: \.self) { i in
            let rad = sparkData[i].angle * .pi / 180.0
            let dist = sparkData[i].dist + sparkBurst * 50
            let colors: [Color] = [electricCyan, icyBlue, frostWhite, .white, hotBlue, icyPurple]
            Circle()
                .fill(colors[i % colors.count])
                .frame(width: sparkData[i].size, height: sparkData[i].size)
                .shadow(color: colors[i % colors.count].opacity(0.8), radius: 4)
                .offset(x: cos(rad) * dist, y: sin(rad) * dist - 40)
                .opacity(sparksVisible ? 1.0 : 0)
                .scaleEffect(sparksVisible ? 1.2 : 0.3)
        }
    }

    private var shieldImage: some View {
        Image("ShieldLogo")
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 190, height: 215)
            .overlay(
                LinearGradient(
                    colors: [.clear, .clear, electricCyan.opacity(0.45), .white.opacity(0.3), .clear, .clear],
                    startPoint: UnitPoint(x: shineSweep - 0.3, y: 0),
                    endPoint: UnitPoint(x: shineSweep + 0.3, y: 1)
                )
                .mask(
                    Image("ShieldLogo")
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                )
                .blendMode(.screen)
                .allowsHitTesting(false)
            )
            .shadow(color: electricCyan.opacity(glowOpacity * 0.7), radius: 20)
            .shadow(color: icyPurple.opacity(glowOpacity * 0.3), radius: 35)
            .scaleEffect(shieldScale)
            .rotation3DEffect(.degrees(shieldRotationY), axis: (x: 0, y: 1, z: 0))
            .offset(y: -40)
            .opacity(shieldOpacity)
    }

    private var screenFlash: some View {
        Color.white
            .opacity(flashOpacity)
            .ignoresSafeArea()
            .allowsHitTesting(false)
    }

    private var titleGroup: some View {
        VStack(spacing: 8) {
            Spacer()
            Text("Put God First")
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundStyle(LinearGradient(colors: [frostWhite, electricCyan, .white], startPoint: .leading, endPoint: .trailing))
                .shadow(color: electricCyan.opacity(0.7), radius: 14)
            Text("Your shield against doomscrolling")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(electricCyan.opacity(0.6))
                .opacity(subtitleOpacity)
            Spacer().frame(height: 120)
        }
        .opacity(titleOpacity)
        .offset(y: titleOffset)
    }

    private func runAnimation() async {
        try? await Task.sleep(for: .milliseconds(100))

        withAnimation(.easeOut(duration: 0.04)) { flashOpacity = 0.4 }
        try? await Task.sleep(for: .milliseconds(40))
        withAnimation(.easeOut(duration: 0.12)) { flashOpacity = 0 }

        withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
            shieldScale = 1.0
            shieldRotationY = 0
            shieldOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.3)) {
            glowOpacity = 1
            bgGlowOpacity = 1
        }

        try? await Task.sleep(for: .milliseconds(150))

        withAnimation(.easeOut(duration: 0.3)) {
            sparksVisible = true
            sparkBurst = 0.7
        }

        withAnimation(.easeInOut(duration: 0.6).delay(0.05)) { shineSweep = 1.5 }
        withAnimation(.easeOut(duration: 0.4).delay(0.1)) { raysOpacity = 0.25 }
        withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) { raysRotation = 360 }

        try? await Task.sleep(for: .milliseconds(350))

        withAnimation(.easeOut(duration: 0.25)) {
            sparksVisible = false
            sparkBurst = 0
        }

        withAnimation(.easeOut(duration: 0.35)) { titleOpacity = 1; titleOffset = 0 }
        try? await Task.sleep(for: .milliseconds(150))
        withAnimation(.easeOut(duration: 0.3)) { subtitleOpacity = 1 }

        try? await Task.sleep(for: .milliseconds(650))

        withAnimation(.easeIn(duration: 0.4)) { finalOpacity = 0 }
        try? await Task.sleep(for: .milliseconds(450))
        onFinished()
    }
}

struct LightningBoltShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: w * 0.4, y: 0))
        path.addLine(to: CGPoint(x: w * 0.15, y: h * 0.35))
        path.addLine(to: CGPoint(x: w * 0.45, y: h * 0.35))
        path.addLine(to: CGPoint(x: w * 0.2, y: h * 0.65))
        path.addLine(to: CGPoint(x: w * 0.5, y: h * 0.65))
        path.addLine(to: CGPoint(x: w * 0.25, y: h))
        path.addLine(to: CGPoint(x: w * 0.75, y: h * 0.55))
        path.addLine(to: CGPoint(x: w * 0.5, y: h * 0.55))
        path.addLine(to: CGPoint(x: w * 0.8, y: h * 0.25))
        path.addLine(to: CGPoint(x: w * 0.55, y: h * 0.25))
        path.addLine(to: CGPoint(x: w * 0.7, y: 0))
        path.closeSubpath()
        return path
    }
}

import SwiftUI

struct SacredCrossHeader: View {
    @State private var haloBreath: Bool = false
    @State private var raysRotation: Double = 0
    @State private var innerGlow: Bool = false
    @State private var particlesFloat: [Bool] = Array(repeating: false, count: 6)

    private let gold = Color(red: 1.0, green: 0.82, blue: 0.42)
    private let warmAmber = Color(red: 1.0, green: 0.68, blue: 0.28)
    private let cream = Color(red: 1.0, green: 0.92, blue: 0.78)

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [gold.opacity(haloBreath ? 0.22 : 0.08), warmAmber.opacity(0.06), Color.clear],
                        center: .center, startRadius: 8, endRadius: 70
                    )
                )
                .frame(width: 140, height: 140)
                .scaleEffect(haloBreath ? 1.08 : 0.94)

            ForEach(0..<8, id: \.self) { i in
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [gold.opacity(0.3), Color.clear],
                            startPoint: .center,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 80, height: 1.5)
                    .blur(radius: 3)
                    .rotationEffect(.degrees(Double(i) * 45 + raysRotation))
            }

            ForEach(0..<6, id: \.self) { i in
                let angles: [Double] = [30, 90, 150, 210, 270, 330]
                let distances: [CGFloat] = [42, 50, 38, 46, 52, 40]
                Circle()
                    .fill(cream.opacity(0.7))
                    .frame(width: 2.5, height: 2.5)
                    .offset(
                        x: cos(angles[i] * .pi / 180) * distances[i],
                        y: sin(angles[i] * .pi / 180) * distances[i] + (particlesFloat[i] ? -18 : 0)
                    )
                    .opacity(particlesFloat[i] ? 0 : 0.8)
            }

            ZStack {
                Image(systemName: "cross.fill")
                    .font(.system(size: 42, weight: .regular))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, cream, gold],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: gold.opacity(innerGlow ? 0.8 : 0.3), radius: innerGlow ? 18 : 8)
                    .shadow(color: .white.opacity(0.4), radius: 4)

                Image(systemName: "cross.fill")
                    .font(.system(size: 42, weight: .regular))
                    .foregroundStyle(gold.opacity(innerGlow ? 0.2 : 0.05))
                    .blur(radius: 12)
                    .scaleEffect(1.4)
            }
        }
        .frame(width: 140, height: 140)
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                haloBreath = true
                innerGlow = true
            }
            withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                raysRotation = 360
            }
            for i in 0..<6 {
                withAnimation(
                    .easeInOut(duration: Double.random(in: 2.5...4.0))
                    .repeatForever(autoreverses: true)
                    .delay(Double(i) * 0.3)
                ) {
                    particlesFloat[i] = true
                }
            }
        }
    }
}

struct SacredSunriseHeader: View {
    @State private var glowPulse: Bool = false
    @State private var raysExpand: Bool = false

    private let peach = Color(red: 1.0, green: 0.55, blue: 0.35)
    private let coral = Color(red: 0.95, green: 0.4, blue: 0.35)
    private let warmWhite = Color(red: 1.0, green: 0.92, blue: 0.82)

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [peach.opacity(glowPulse ? 0.25 : 0.1), coral.opacity(0.08), Color.clear],
                        center: .center, startRadius: 5, endRadius: 65
                    )
                )
                .frame(width: 130, height: 130)
                .scaleEffect(glowPulse ? 1.1 : 0.95)

            ForEach(0..<12, id: \.self) { i in
                let angle = Double(i) * 30
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [peach.opacity(0.5), coral.opacity(0.2), Color.clear],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: 2, height: raysExpand ? 28 : 16)
                    .offset(y: -(raysExpand ? 44 : 36))
                    .rotationEffect(.degrees(angle))
                    .blur(radius: 1)
            }

            Circle()
                .fill(
                    RadialGradient(
                        colors: [warmWhite, peach, coral],
                        center: .center,
                        startRadius: 2,
                        endRadius: 22
                    )
                )
                .frame(width: 44, height: 44)
                .shadow(color: peach.opacity(0.6), radius: 15)
                .shadow(color: coral.opacity(0.3), radius: 6)

            Image(systemName: "cross.fill")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white.opacity(0.9))
                .shadow(color: peach.opacity(0.5), radius: 4)
        }
        .frame(width: 130, height: 130)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                glowPulse = true
                raysExpand = true
            }
        }
    }
}

struct SacredChurchHeader: View {
    @State private var windowGlow: Bool = false
    @State private var haloBreath: Bool = false
    @State private var windowShift: Bool = false

    private let stainedBlue = Color(red: 0.25, green: 0.45, blue: 0.9)
    private let stainedRose = Color(red: 0.85, green: 0.35, blue: 0.5)
    private let stainedGold = Color(red: 0.95, green: 0.75, blue: 0.25)
    private let deepPurple = Color(red: 0.45, green: 0.25, blue: 0.7)

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            deepPurple.opacity(haloBreath ? 0.18 : 0.06),
                            stainedBlue.opacity(haloBreath ? 0.1 : 0.03),
                            stainedRose.opacity(haloBreath ? 0.06 : 0.01),
                            Color.clear
                        ],
                        center: .center, startRadius: 10, endRadius: 70
                    )
                )
                .frame(width: 140, height: 140)
                .scaleEffect(haloBreath ? 1.06 : 0.96)

            ForEach(0..<6, id: \.self) { i in
                let colors: [Color] = [stainedBlue, stainedRose, stainedGold, deepPurple, stainedBlue, stainedRose]
                let offX: [CGFloat] = [-18, 18, -10, 10, -22, 22]
                let offY: [CGFloat] = [-24, -24, -10, -10, 4, 4]
                Circle()
                    .fill(colors[i].opacity(windowGlow ? 0.25 : 0.06))
                    .frame(width: windowShift ? 8 : 5, height: windowShift ? 8 : 5)
                    .blur(radius: 3)
                    .offset(x: offX[i], y: offY[i])
            }

            ZStack {
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 38))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                deepPurple,
                                Color(red: 0.4, green: 0.3, blue: 0.6)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: stainedBlue.opacity(windowGlow ? 0.5 : 0.15), radius: windowGlow ? 14 : 6)
                    .shadow(color: stainedRose.opacity(windowGlow ? 0.3 : 0.08), radius: windowGlow ? 10 : 3)

                Image(systemName: "cross.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [stainedGold, stainedRose],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: stainedGold.opacity(windowGlow ? 0.8 : 0.3), radius: windowGlow ? 8 : 3)
                    .offset(y: -30)
            }
        }
        .frame(width: 140, height: 140)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) {
                windowGlow = true
                haloBreath = true
            }
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
                windowShift = true
            }
        }
    }
}

struct SacredDoveHeader: View {
    @State private var doveFloat: Bool = false
    @State private var glowPulse: Bool = false
    @State private var wingSpread: Bool = false
    @State private var featherDrift: [Bool] = Array(repeating: false, count: 5)

    private let skyBlue = Color(red: 0.45, green: 0.7, blue: 1.0)
    private let iceWhite = Color(red: 0.9, green: 0.95, blue: 1.0)
    private let silver = Color(red: 0.78, green: 0.82, blue: 0.9)

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [skyBlue.opacity(glowPulse ? 0.2 : 0.06), iceWhite.opacity(0.06), Color.clear],
                        center: .center, startRadius: 8, endRadius: 65
                    )
                )
                .frame(width: 130, height: 130)
                .scaleEffect(glowPulse ? 1.08 : 0.95)

            ForEach(0..<5, id: \.self) { i in
                let offsets: [(CGFloat, CGFloat)] = [(-24, 12), (26, 8), (-12, -18), (18, -14), (2, 22)]
                let sizes: [CGFloat] = [2.5, 3, 2, 3, 2]
                Circle()
                    .fill(iceWhite.opacity(0.6))
                    .frame(width: sizes[i], height: sizes[i])
                    .offset(
                        x: offsets[i].0,
                        y: offsets[i].1 + (featherDrift[i] ? -14 : 0)
                    )
                    .opacity(featherDrift[i] ? 0.2 : 0.7)
            }

            ZStack {
                Image(systemName: "bird.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, iceWhite, skyBlue.opacity(0.5)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: skyBlue.opacity(glowPulse ? 0.5 : 0.2), radius: glowPulse ? 14 : 6)
                    .shadow(color: .white.opacity(0.4), radius: 4)
                    .offset(y: doveFloat ? -4 : 4)
                    .scaleEffect(x: wingSpread ? 1.05 : 0.97, y: wingSpread ? 0.97 : 1.03)

                Image(systemName: "bird.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(skyBlue.opacity(glowPulse ? 0.15 : 0.04))
                    .blur(radius: 10)
                    .scaleEffect(1.3)
                    .offset(y: doveFloat ? -4 : 4)
            }
        }
        .frame(width: 130, height: 130)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                doveFloat = true
                glowPulse = true
            }
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                wingSpread = true
            }
            for i in 0..<5 {
                withAnimation(
                    .easeInOut(duration: Double.random(in: 2.0...3.5))
                    .repeatForever(autoreverses: true)
                    .delay(Double(i) * 0.3)
                ) {
                    featherDrift[i] = true
                }
            }
        }
    }
}

struct SacredBellHeader: View {
    @State private var ringPulse: Bool = false
    @State private var bellSwing: Bool = false
    @State private var glowPulse: Bool = false

    private let holyRed = Color(red: 0.85, green: 0.18, blue: 0.15)
    private let deepCrimson = Color(red: 0.65, green: 0.1, blue: 0.08)
    private let warmRose = Color(red: 0.95, green: 0.3, blue: 0.25)

    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [holyRed.opacity(ringPulse ? (0.35 - Double(i) * 0.08) : 0.05), warmRose.opacity(ringPulse ? 0.18 : 0.02)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: CGFloat(2 - i) + 0.5
                    )
                    .frame(
                        width: CGFloat(70 + i * 28),
                        height: CGFloat(70 + i * 28)
                    )
                    .scaleEffect(ringPulse ? 1.12 : 0.92)
                    .blur(radius: CGFloat(i) + 1)
            }

            Circle()
                .fill(
                    RadialGradient(
                        colors: [holyRed.opacity(glowPulse ? 0.22 : 0.06), warmRose.opacity(0.06), Color.clear],
                        center: .center, startRadius: 5, endRadius: 55
                    )
                )
                .frame(width: 110, height: 110)

            Image(systemName: "bell.and.waves.left.and.right.fill")
                .font(.system(size: 40))
                .foregroundStyle(
                    LinearGradient(
                        colors: [warmRose, holyRed, deepCrimson],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: holyRed.opacity(glowPulse ? 0.7 : 0.2), radius: glowPulse ? 14 : 5)
                .shadow(color: warmRose.opacity(glowPulse ? 0.4 : 0.1), radius: 8)
                .rotationEffect(.degrees(bellSwing ? 5 : -5))

            Image(systemName: "cross.fill")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white.opacity(0.85))
                .offset(y: -24)
        }
        .frame(width: 130, height: 130)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                ringPulse = true
                glowPulse = true
            }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                bellSwing = true
            }
        }
    }
}

struct SacredLightHeader: View {
    @State private var burstPulse: Bool = false
    @State private var raysRotate: Double = 0
    @State private var sparklePhase: Bool = false

    private let coolWhite = Color(red: 0.92, green: 0.94, blue: 1.0)
    private let softViolet = Color(red: 0.7, green: 0.6, blue: 1.0)
    private let etherealBlue = Color(red: 0.55, green: 0.7, blue: 1.0)

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [coolWhite.opacity(burstPulse ? 0.3 : 0.1), softViolet.opacity(0.08), Color.clear],
                        center: .center, startRadius: 5, endRadius: 70
                    )
                )
                .frame(width: 140, height: 140)
                .scaleEffect(burstPulse ? 1.1 : 0.92)

            ForEach(0..<6, id: \.self) { i in
                let angle = Double(i) * 60 + raysRotate
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [softViolet.opacity(0.5), etherealBlue.opacity(0.2), Color.clear],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: 2.5, height: burstPulse ? 35 : 22)
                    .offset(y: -38)
                    .rotationEffect(.degrees(angle))
                    .blur(radius: 2)
            }

            ForEach(0..<4, id: \.self) { i in
                let colors: [Color] = [softViolet, etherealBlue, coolWhite, softViolet]
                Image(systemName: "sparkle")
                    .font(.system(size: CGFloat([8, 6, 9, 7][i])))
                    .foregroundStyle(colors[i].opacity(sparklePhase ? 0.9 : 0.3))
                    .offset(
                        x: CGFloat([-22, 24, -18, 20][i]),
                        y: CGFloat([-20, -16, 18, 22][i])
                    )
                    .scaleEffect(sparklePhase ? 1.2 : 0.7)
            }

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.white, coolWhite, softViolet.opacity(0.5)],
                            center: .center, startRadius: 2, endRadius: 18
                        )
                    )
                    .frame(width: 36, height: 36)
                    .shadow(color: softViolet.opacity(0.5), radius: 10)
                    .shadow(color: etherealBlue.opacity(0.3), radius: 6)

                Image(systemName: "cross.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.85))
            }
        }
        .frame(width: 140, height: 140)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) {
                burstPulse = true
                sparklePhase = true
            }
            withAnimation(.linear(duration: 25).repeatForever(autoreverses: false)) {
                raysRotate = 360
            }
        }
    }
}

struct SacredFlameHeader: View {
    @State private var flameBreath: Bool = false
    @State private var innerGlow: Bool = false
    @State private var embers: [Bool] = Array(repeating: false, count: 6)

    private let gold = Color(red: 1.0, green: 0.82, blue: 0.42)
    private let amber = Color(red: 1.0, green: 0.68, blue: 0.28)
    private let holyRed = Color(red: 0.9, green: 0.3, blue: 0.2)
    private let deepCrimson = Color(red: 0.7, green: 0.15, blue: 0.1)

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [holyRed.opacity(flameBreath ? 0.18 : 0.05), amber.opacity(0.06), Color.clear],
                        center: .center, startRadius: 8, endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)
                .scaleEffect(flameBreath ? 1.08 : 0.94)

            ForEach(0..<6, id: \.self) { i in
                let offX: [CGFloat] = [-14, 16, -8, 12, -18, 10]
                let colors: [Color] = [gold, amber, holyRed, gold, amber, holyRed]
                Circle()
                    .fill(colors[i])
                    .frame(width: CGFloat([3, 2.5, 2, 3, 2, 2.5][i]))
                    .offset(
                        x: offX[i],
                        y: embers[i] ? -50 : 10
                    )
                    .opacity(embers[i] ? 0 : 0.6)
                    .blur(radius: 1)
            }

            Image(systemName: "flame.fill")
                .font(.system(size: 44))
                .foregroundStyle(
                    LinearGradient(
                        colors: [gold, amber, holyRed, deepCrimson],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: amber.opacity(innerGlow ? 0.7 : 0.2), radius: innerGlow ? 16 : 6)
                .shadow(color: holyRed.opacity(innerGlow ? 0.4 : 0.1), radius: 10)
                .shadow(color: .white.opacity(0.2), radius: 3)
                .scaleEffect(y: flameBreath ? 1.06 : 0.96)

            Image(systemName: "flame.fill")
                .font(.system(size: 44))
                .foregroundStyle(.white.opacity(flameBreath ? 0.15 : 0))
                .blur(radius: 6)
                .scaleEffect(1.2)
        }
        .frame(width: 120, height: 120)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                flameBreath = true
                innerGlow = true
            }
            for i in 0..<6 {
                withAnimation(
                    .easeOut(duration: Double.random(in: 1.5...3.0))
                    .repeatForever(autoreverses: false)
                    .delay(Double(i) * 0.3)
                ) {
                    embers[i] = true
                }
            }
        }
    }
}

struct SacredPrayerHandsHeader: View {
    @State private var haloGlow: Bool = false
    @State private var raysRotation: Double = 0
    @State private var handsFloat: Bool = false
    @State private var innerPulse: Bool = false
    @State private var sparklePhase: [Bool] = Array(repeating: false, count: 8)
    @State private var lightBeams: Bool = false
    @State private var ringExpand: [CGFloat] = [0.5, 0.5, 0.5]
    @State private var ringOpacity: [Double] = [0, 0, 0]

    private let roseGold = Color(red: 0.92, green: 0.68, blue: 0.62)
    private let softLavender = Color(red: 0.72, green: 0.58, blue: 0.88)
    private let warmPink = Color(red: 0.95, green: 0.55, blue: 0.6)
    private let divineCream = Color(red: 1.0, green: 0.92, blue: 0.82)
    private let holyWhite = Color(red: 0.98, green: 0.96, blue: 1.0)

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            softLavender.opacity(haloGlow ? 0.2 : 0.06),
                            roseGold.opacity(haloGlow ? 0.1 : 0.03),
                            Color.clear
                        ],
                        center: .center, startRadius: 8, endRadius: 75
                    )
                )
                .frame(width: 150, height: 150)
                .scaleEffect(haloGlow ? 1.08 : 0.95)

            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                roseGold.opacity(0.3),
                                softLavender.opacity(0.2),
                                warmPink.opacity(0.1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: CGFloat(2.5 - Double(i) * 0.5)
                    )
                    .frame(
                        width: CGFloat(70 + i * 30),
                        height: CGFloat(70 + i * 30)
                    )
                    .scaleEffect(ringExpand[i])
                    .opacity(ringOpacity[i])
                    .blur(radius: CGFloat(i) * 1.5 + 1)
            }

            ForEach(0..<7, id: \.self) { i in
                let angle = -90.0 + Double(i) * 30.0
                let rad = angle * .pi / 180
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                divineCream.opacity(lightBeams ? 0.35 : 0.08),
                                roseGold.opacity(lightBeams ? 0.15 : 0.02),
                                Color.clear
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: 2, height: lightBeams ? 40 : 18)
                    .offset(y: -(lightBeams ? 48 : 34))
                    .rotationEffect(.degrees(angle))
                    .blur(radius: 2)
            }

            ForEach(0..<8, id: \.self) { i in
                let sparkleX: [CGFloat] = [-28, 30, -20, 24, -32, 26, -14, 18]
                let sparkleY: [CGFloat] = [-30, -26, -12, -18, 8, 4, 22, 18]
                let sparkleColors: [Color] = [roseGold, softLavender, warmPink, divineCream, roseGold, softLavender, warmPink, holyWhite]
                let sizes: [CGFloat] = [6, 7, 5, 8, 5, 6, 7, 5]

                Image(systemName: "sparkle")
                    .font(.system(size: sizes[i]))
                    .foregroundStyle(sparkleColors[i].opacity(sparklePhase[i] ? 0.85 : 0.15))
                    .offset(x: sparkleX[i], y: sparkleY[i])
                    .scaleEffect(sparklePhase[i] ? 1.3 : 0.6)
            }

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                holyWhite.opacity(innerPulse ? 0.4 : 0.15),
                                roseGold.opacity(innerPulse ? 0.2 : 0.06),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 5,
                            endRadius: 35
                        )
                    )
                    .frame(width: 70, height: 70)
                    .scaleEffect(innerPulse ? 1.1 : 0.95)

                Image(systemName: "hands.sparkles.fill")
                    .font(.system(size: 42))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [holyWhite, roseGold, softLavender],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: roseGold.opacity(haloGlow ? 0.6 : 0.2), radius: haloGlow ? 16 : 6)
                    .shadow(color: softLavender.opacity(haloGlow ? 0.4 : 0.1), radius: 10)
                    .shadow(color: .white.opacity(0.3), radius: 4)
                    .offset(y: handsFloat ? -3 : 3)

                Image(systemName: "hands.sparkles.fill")
                    .font(.system(size: 42))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [roseGold.opacity(0.15), softLavender.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .blur(radius: 14)
                    .scaleEffect(1.4)
                    .offset(y: handsFloat ? -3 : 3)
            }
        }
        .frame(width: 150, height: 150)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) {
                haloGlow = true
                innerPulse = true
            }
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                handsFloat = true
                lightBeams = true
            }
            for i in 0..<3 {
                withAnimation(.easeOut(duration: 1.5).delay(Double(i) * 0.2)) {
                    ringExpand[i] = 1.0
                    ringOpacity[i] = Double(3 - i) / 5.0
                }
            }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(1.5)) {
                ringExpand = [1.08, 1.06, 1.04]
            }
            for i in 0..<8 {
                withAnimation(
                    .easeInOut(duration: Double.random(in: 1.5...3.0))
                    .repeatForever(autoreverses: true)
                    .delay(Double(i) * 0.2)
                ) {
                    sparklePhase[i] = true
                }
            }
        }
    }
}

struct SacredPricingFlame: View {
    @State private var flameBreath: Bool = false
    @State private var innerGlow: Bool = false
    @State private var outerFlicker: Bool = false
    @State private var embers: [Bool] = Array(repeating: false, count: 8)
    @State private var ringsExpand: Bool = false

    private let gold = Color(red: 1.0, green: 0.82, blue: 0.42)
    private let amber = Color(red: 1.0, green: 0.68, blue: 0.28)
    private let holyRed = Color(red: 0.9, green: 0.3, blue: 0.2)
    private let deepCrimson = Color(red: 0.7, green: 0.15, blue: 0.1)
    private let cream = Color(red: 1.0, green: 0.92, blue: 0.78)

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            amber.opacity(innerGlow ? 0.25 : 0.08),
                            holyRed.opacity(innerGlow ? 0.12 : 0.03),
                            Color.clear
                        ],
                        center: .center, startRadius: 10, endRadius: 80
                    )
                )
                .frame(width: 140, height: 140)
                .scaleEffect(innerGlow ? 1.08 : 0.94)

            ForEach(0..<2, id: \.self) { i in
                Circle()
                    .strokeBorder(
                        amber.opacity(ringsExpand ? (0.2 - Double(i) * 0.06) : 0.03),
                        lineWidth: CGFloat(2 - i) + 0.5
                    )
                    .frame(
                        width: CGFloat(80 + i * 30),
                        height: CGFloat(80 + i * 30)
                    )
                    .scaleEffect(ringsExpand ? 1.1 : 0.9)
                    .blur(radius: CGFloat(i) * 2 + 1)
            }

            ForEach(0..<8, id: \.self) { i in
                let offX: [CGFloat] = [-16, 18, -10, 14, -20, 12, -6, 8]
                let colors: [Color] = [gold, amber, holyRed, gold, amber, cream, holyRed, gold]
                Circle()
                    .fill(colors[i])
                    .frame(width: CGFloat([3, 2.5, 2, 3.5, 2, 3, 2.5, 2][i]))
                    .offset(
                        x: offX[i],
                        y: embers[i] ? -65 : 12
                    )
                    .opacity(embers[i] ? 0 : 0.7)
                    .blur(radius: 0.5)
            }

            ZStack {
                Image(systemName: "flame.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [cream, gold, amber, holyRed, deepCrimson],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: amber.opacity(innerGlow ? 0.8 : 0.3), radius: innerGlow ? 22 : 8)
                    .shadow(color: holyRed.opacity(innerGlow ? 0.5 : 0.15), radius: 14)
                    .shadow(color: .white.opacity(0.3), radius: 4)
                    .scaleEffect(y: flameBreath ? 1.08 : 0.94)
                    .scaleEffect(x: outerFlicker ? 1.02 : 0.98)

                Image(systemName: "flame.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white.opacity(0.2), cream.opacity(0.1), Color.clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                    .blur(radius: 4)
                    .scaleEffect(y: flameBreath ? 1.08 : 0.94)

                Image(systemName: "flame.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(amber.opacity(innerGlow ? 0.12 : 0.03))
                    .blur(radius: 18)
                    .scaleEffect(1.5)
            }
        }
        .frame(width: 140, height: 100)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                flameBreath = true
                innerGlow = true
            }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                outerFlicker = true
            }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                ringsExpand = true
            }
            for i in 0..<8 {
                withAnimation(
                    .easeOut(duration: Double.random(in: 1.2...2.5))
                    .repeatForever(autoreverses: false)
                    .delay(Double(i) * 0.2)
                ) {
                    embers[i] = true
                }
            }
        }
    }
}

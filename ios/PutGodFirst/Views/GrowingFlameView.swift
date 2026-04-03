import SwiftUI

struct GrowingFlameView: View {
    var progress: Double
    var size: CGFloat = 130

    @State private var breathe: Bool = false
    @State private var wobble: Bool = false
    @State private var innerPulse: Bool = false
    @State private var sparkle: Bool = false

    private let brightYellow = Color(red: 1.0, green: 0.95, blue: 0.35)
    private let warmYellow = Color(red: 1.0, green: 0.82, blue: 0.12)
    private let deepOrange = Color(red: 1.0, green: 0.55, blue: 0.0)
    private let hotOrange = Color(red: 1.0, green: 0.42, blue: 0.0)
    private let fireRed = Color(red: 0.92, green: 0.22, blue: 0.05)
    private let deepRed = Color(red: 0.75, green: 0.12, blue: 0.02)
    private let whiteHot = Color(red: 1.0, green: 1.0, blue: 0.85)

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    private var flameScale: CGFloat {
        let p = clampedProgress
        if p < 0.05 { return 0.08 }
        if p < 0.15 { return 0.08 + CGFloat((p - 0.05) / 0.10) * 0.17 }
        if p < 0.5 { return 0.25 + CGFloat((p - 0.15) / 0.35) * 0.35 }
        return 0.6 + CGFloat((p - 0.5) / 0.5) * 0.4
    }

    private var glowIntensity: Double {
        clampedProgress
    }

    private var emberCount: Int {
        if clampedProgress < 0.15 { return 0 }
        if clampedProgress < 0.4 { return 2 }
        if clampedProgress < 0.7 { return 4 }
        return 6
    }

    private var showInnerFlame: Bool {
        clampedProgress > 0.2
    }

    private var showTip: Bool {
        clampedProgress > 0.4
    }

    private var showCore: Bool {
        clampedProgress > 0.6
    }

    var body: some View {
        ZStack {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            deepOrange.opacity(glowIntensity * (breathe ? 0.35 : 0.15)),
                            fireRed.opacity(glowIntensity * (breathe ? 0.15 : 0.05)),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.7
                    )
                )
                .frame(width: size * 1.6, height: size * 1.4)
                .offset(y: size * 0.1)
                .opacity(clampedProgress > 0.05 ? 1 : 0)

            if clampedProgress < 0.15 {
                sparkView
            }

            if clampedProgress >= 0.15 {
                ForEach(0..<emberCount, id: \.self) { i in
                    FloatingEmber(index: i, flameSize: size * flameScale)
                }
            }

            if clampedProgress >= 0.05 {
                ZStack {
                    FlameBodyShape()
                        .fill(
                            LinearGradient(
                                stops: [
                                    .init(color: fireRed, location: 0.0),
                                    .init(color: deepRed, location: 0.15),
                                    .init(color: fireRed, location: 0.4),
                                    .init(color: hotOrange, location: 0.65),
                                    .init(color: deepOrange.opacity(0.8), location: 1.0),
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: size * 0.82, height: size * 1.08)
                        .shadow(color: fireRed.opacity(0.5 * glowIntensity), radius: 14)
                        .shadow(color: deepOrange.opacity(0.3 * glowIntensity), radius: 8)

                    if showInnerFlame {
                        FlameInnerShape()
                            .fill(
                                LinearGradient(
                                    stops: [
                                        .init(color: hotOrange, location: 0.0),
                                        .init(color: deepOrange, location: 0.3),
                                        .init(color: warmYellow.opacity(0.9), location: 0.6),
                                        .init(color: deepOrange.opacity(0.5), location: 1.0),
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: size * 0.62, height: size * 0.85)
                            .offset(y: size * 0.08)
                            .transition(.opacity)
                    }

                    if showTip {
                        FlameTipShape()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        brightYellow,
                                        warmYellow,
                                        deepOrange.opacity(0)
                                    ],
                                    center: UnitPoint(x: 0.5, y: 0.7),
                                    startRadius: 0,
                                    endRadius: size * 0.2
                                )
                            )
                            .frame(width: size * 0.42, height: size * 0.58)
                            .offset(y: size * 0.16)
                            .transition(.opacity)
                    }

                    if showCore {
                        Ellipse()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        whiteHot,
                                        brightYellow.opacity(innerPulse ? 0.9 : 0.6),
                                        warmYellow.opacity(0)
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: size * 0.1
                                )
                            )
                            .frame(width: size * 0.2, height: size * 0.16)
                            .offset(y: size * 0.32)

                        Ellipse()
                            .fill(whiteHot.opacity(innerPulse ? 0.5 : 0.2))
                            .frame(width: size * 0.08, height: size * 0.06)
                            .offset(y: size * 0.34)
                            .blur(radius: 1)
                    }
                }
                .scaleEffect(flameScale)
                .scaleEffect(y: breathe ? 1.06 : 0.95)
                .scaleEffect(x: wobble ? 0.97 : 1.03)
                .rotationEffect(.degrees(wobble ? 1.5 : -1.5))
                .animation(.easeInOut(duration: 0.6), value: clampedProgress > 0.2)
                .animation(.easeInOut(duration: 0.6), value: clampedProgress > 0.4)
                .animation(.easeInOut(duration: 0.6), value: clampedProgress > 0.6)
            }
        }
        .frame(width: size * 1.4, height: size * 1.6)
        .animation(.easeInOut(duration: 1.0), value: flameScale)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                breathe = true
            }
            withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true).delay(0.15)) {
                wobble = true
            }
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true).delay(0.3)) {
                innerPulse = true
            }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                sparkle = true
            }
        }
    }

    private var sparkView: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            brightYellow.opacity(sparkle ? 0.9 : 0.4),
                            warmYellow.opacity(sparkle ? 0.5 : 0.2),
                            deepOrange.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 18
                    )
                )
                .frame(width: 36, height: 36)
                .scaleEffect(sparkle ? 1.3 : 0.8)

            Circle()
                .fill(whiteHot)
                .frame(width: 6, height: 6)
                .shadow(color: brightYellow, radius: 8)
                .shadow(color: warmYellow.opacity(0.6), radius: 16)
                .scaleEffect(sparkle ? 1.2 : 0.7)

            ForEach(0..<4, id: \.self) { i in
                let angles: [Double] = [0, 90, 180, 270]
                let lengths: [CGFloat] = [12, 8, 14, 10]
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [brightYellow, Color.clear],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: 1.5, height: sparkle ? lengths[i] : lengths[i] * 0.5)
                    .offset(y: -(sparkle ? 14 : 8))
                    .rotationEffect(.degrees(angles[i] + (sparkle ? 15 : -15)))
                    .opacity(sparkle ? 0.8 : 0.3)
            }
        }
        .offset(y: size * 0.2)
    }
}

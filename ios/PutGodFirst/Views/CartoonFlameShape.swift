import SwiftUI

struct FlameBodyShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()

        path.move(to: CGPoint(x: w * 0.50, y: h * 0.96))

        path.addCurve(
            to: CGPoint(x: w * 0.92, y: h * 0.52),
            control1: CGPoint(x: w * 0.78, y: h * 0.98),
            control2: CGPoint(x: w * 1.05, y: h * 0.72)
        )

        path.addCurve(
            to: CGPoint(x: w * 0.72, y: h * 0.18),
            control1: CGPoint(x: w * 0.85, y: h * 0.38),
            control2: CGPoint(x: w * 0.80, y: h * 0.26)
        )

        path.addCurve(
            to: CGPoint(x: w * 0.50, y: h * 0.0),
            control1: CGPoint(x: w * 0.62, y: h * 0.08),
            control2: CGPoint(x: w * 0.54, y: h * 0.01)
        )

        path.addCurve(
            to: CGPoint(x: w * 0.28, y: h * 0.18),
            control1: CGPoint(x: w * 0.46, y: h * 0.01),
            control2: CGPoint(x: w * 0.38, y: h * 0.08)
        )

        path.addCurve(
            to: CGPoint(x: w * 0.08, y: h * 0.52),
            control1: CGPoint(x: w * 0.20, y: h * 0.26),
            control2: CGPoint(x: w * 0.15, y: h * 0.38)
        )

        path.addCurve(
            to: CGPoint(x: w * 0.50, y: h * 0.96),
            control1: CGPoint(x: w * -0.05, y: h * 0.72),
            control2: CGPoint(x: w * 0.22, y: h * 0.98)
        )

        path.closeSubpath()
        return path
    }
}

struct FlameInnerShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()

        path.move(to: CGPoint(x: w * 0.50, y: h * 0.95))

        path.addCurve(
            to: CGPoint(x: w * 0.82, y: h * 0.50),
            control1: CGPoint(x: w * 0.72, y: h * 0.95),
            control2: CGPoint(x: w * 0.88, y: h * 0.72)
        )

        path.addCurve(
            to: CGPoint(x: w * 0.50, y: h * 0.0),
            control1: CGPoint(x: w * 0.76, y: h * 0.30),
            control2: CGPoint(x: w * 0.58, y: h * 0.06)
        )

        path.addCurve(
            to: CGPoint(x: w * 0.18, y: h * 0.50),
            control1: CGPoint(x: w * 0.42, y: h * 0.06),
            control2: CGPoint(x: w * 0.24, y: h * 0.30)
        )

        path.addCurve(
            to: CGPoint(x: w * 0.50, y: h * 0.95),
            control1: CGPoint(x: w * 0.12, y: h * 0.72),
            control2: CGPoint(x: w * 0.28, y: h * 0.95)
        )

        path.closeSubpath()
        return path
    }
}

struct FlameTipShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()

        path.move(to: CGPoint(x: w * 0.50, y: h * 0.92))

        path.addCurve(
            to: CGPoint(x: w * 0.68, y: h * 0.55),
            control1: CGPoint(x: w * 0.64, y: h * 0.90),
            control2: CGPoint(x: w * 0.72, y: h * 0.72)
        )

        path.addCurve(
            to: CGPoint(x: w * 0.50, y: h * 0.0),
            control1: CGPoint(x: w * 0.64, y: h * 0.35),
            control2: CGPoint(x: w * 0.55, y: h * 0.10)
        )

        path.addCurve(
            to: CGPoint(x: w * 0.32, y: h * 0.55),
            control1: CGPoint(x: w * 0.45, y: h * 0.10),
            control2: CGPoint(x: w * 0.36, y: h * 0.35)
        )

        path.addCurve(
            to: CGPoint(x: w * 0.50, y: h * 0.92),
            control1: CGPoint(x: w * 0.28, y: h * 0.72),
            control2: CGPoint(x: w * 0.36, y: h * 0.90)
        )

        path.closeSubpath()
        return path
    }
}

struct FloatingEmber: View {
    let index: Int
    let flameSize: CGFloat
    @State private var float: Bool = false

    private var xOffset: CGFloat { [-14, 16, -5, 10, -18, 8][index % 6] }
    private var particleSize: CGFloat { [8, 6, 5, 7, 4, 6][index % 6] }
    private var delay: Double { [0.0, 0.4, 0.9, 0.2, 0.7, 1.2][index % 6] }
    private var duration: Double { [1.4, 1.1, 1.6, 1.3, 1.0, 1.5][index % 6] }

    private var colors: [Color] {
        let all: [[Color]] = [
            [Color(red: 1.0, green: 0.85, blue: 0.2), Color(red: 1.0, green: 0.65, blue: 0.0).opacity(0.3)],
            [Color(red: 1.0, green: 0.5, blue: 0.05), Color(red: 1.0, green: 0.35, blue: 0.0).opacity(0.3)],
            [Color(red: 1.0, green: 0.75, blue: 0.1), Color(red: 1.0, green: 0.55, blue: 0.0).opacity(0.2)],
            [Color(red: 1.0, green: 0.9, blue: 0.3), Color.clear],
            [Color(red: 1.0, green: 0.6, blue: 0.08), Color.clear],
            [Color(red: 1.0, green: 0.8, blue: 0.15), Color.clear],
        ]
        return all[index % 6]
    }

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: colors + [Color.clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: particleSize * 0.6
                )
            )
            .frame(width: particleSize, height: particleSize)
            .offset(
                x: xOffset,
                y: float ? -flameSize * 0.82 : -flameSize * 0.3
            )
            .opacity(float ? 0 : 0.9)
            .onAppear {
                withAnimation(
                    .easeOut(duration: duration)
                    .repeatForever(autoreverses: false)
                    .delay(delay)
                ) {
                    float = true
                }
            }
    }
}

struct RealisticFlameView: View {
    var size: CGFloat = 130
    @State private var breathe: Bool = false
    @State private var wobble: Bool = false
    @State private var innerPulse: Bool = false
    @State private var appeared: Bool = false

    private let brightYellow = Color(red: 1.0, green: 0.95, blue: 0.35)
    private let warmYellow = Color(red: 1.0, green: 0.82, blue: 0.12)
    private let deepOrange = Color(red: 1.0, green: 0.55, blue: 0.0)
    private let hotOrange = Color(red: 1.0, green: 0.42, blue: 0.0)
    private let fireRed = Color(red: 0.92, green: 0.22, blue: 0.05)
    private let deepRed = Color(red: 0.75, green: 0.12, blue: 0.02)
    private let whiteHot = Color(red: 1.0, green: 1.0, blue: 0.85)

    var body: some View {
        ZStack {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            deepOrange.opacity(breathe ? 0.3 : 0.15),
                            fireRed.opacity(breathe ? 0.12 : 0.04),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.65
                    )
                )
                .frame(width: size * 1.4, height: size * 1.2)
                .offset(y: size * 0.1)

            ForEach(0..<6, id: \.self) { i in
                FloatingEmber(index: i, flameSize: size)
            }

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
                    .shadow(color: fireRed.opacity(0.5), radius: 14)
                    .shadow(color: deepOrange.opacity(0.3), radius: 8)

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
            .scaleEffect(y: breathe ? 1.06 : 0.95)
            .scaleEffect(x: wobble ? 0.97 : 1.03)
            .rotationEffect(.degrees(wobble ? 1.5 : -1.5))
        }
        .frame(width: size * 1.4, height: size * 1.6)
        .scaleEffect(appeared ? 1 : 0.01)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                appeared = true
            }
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                breathe = true
            }
            withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true).delay(0.15)) {
                wobble = true
            }
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true).delay(0.3)) {
                innerPulse = true
            }
        }
    }
}

struct EmojiFlameView: View {
    var size: CGFloat = 130
    var body: some View {
        RealisticFlameView(size: size)
    }
}

struct AnimatedFlameView: View {
    var body: some View {
        RealisticFlameView()
    }
}

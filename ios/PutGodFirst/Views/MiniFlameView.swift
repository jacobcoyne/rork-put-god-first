import SwiftUI

struct MiniFlameView: View {
    var size: CGFloat = 28
    @State private var breathe: Bool = false
    @State private var flicker: Bool = false

    private let brightYellow = Color(red: 1.0, green: 0.95, blue: 0.35)
    private let warmOrange = Color(red: 1.0, green: 0.65, blue: 0.0)
    private let hotOrange = Color(red: 1.0, green: 0.42, blue: 0.0)
    private let fireRed = Color(red: 0.92, green: 0.22, blue: 0.05)

    var body: some View {
        ZStack {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            warmOrange.opacity(0.4),
                            fireRed.opacity(0.15),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.6
                    )
                )
                .frame(width: size * 1.2, height: size * 1.0)
                .offset(y: size * 0.05)

            FlameBodyShape()
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: fireRed, location: 0.0),
                            .init(color: hotOrange, location: 0.4),
                            .init(color: warmOrange.opacity(0.7), location: 1.0),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size * 0.65, height: size * 0.85)
                .shadow(color: fireRed.opacity(0.4), radius: 3)

            FlameInnerShape()
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: hotOrange, location: 0.0),
                            .init(color: warmOrange, location: 0.5),
                            .init(color: brightYellow.opacity(0.8), location: 1.0),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size * 0.45, height: size * 0.6)
                .offset(y: size * 0.08)

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            brightYellow,
                            warmOrange.opacity(0),
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.12
                    )
                )
                .frame(width: size * 0.22, height: size * 0.16)
                .offset(y: size * 0.22)
        }
        .scaleEffect(y: breathe ? 1.08 : 0.92)
        .scaleEffect(x: flicker ? 0.95 : 1.05)
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                breathe = true
            }
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true).delay(0.1)) {
                flicker = true
            }
        }
    }
}

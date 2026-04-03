import SwiftUI

struct GlassyBrainView: View {
    @State private var pulseScale: CGFloat = 1.0
    @State private var glowIntensity: Double = 0.4
    @State private var orbFloat: CGFloat = 0
    @State private var neuronPulse: [Bool] = Array(repeating: false, count: 6)

    private let glassBlue = Color(red: 0.45, green: 0.65, blue: 1.0)
    private let glassCyan = Color(red: 0.3, green: 0.85, blue: 0.95)
    private let glassPurple = Color(red: 0.6, green: 0.4, blue: 1.0)

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            glassCyan.opacity(glowIntensity * 0.2),
                            glassBlue.opacity(glowIntensity * 0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)
                .scaleEffect(pulseScale)

            ForEach(0..<6, id: \.self) { i in
                let angles: [Double] = [30, 90, 150, 210, 270, 330]
                let radii: [CGFloat] = [42, 48, 44, 46, 50, 43]
                let sizes: [CGFloat] = [3, 2.5, 2, 3.5, 2, 2.5]
                Circle()
                    .fill(glassCyan.opacity(neuronPulse[i] ? 0.5 : 0.12))
                    .frame(width: sizes[i] + (neuronPulse[i] ? 3 : 0), height: sizes[i] + (neuronPulse[i] ? 3 : 0))
                    .offset(
                        x: cos(angles[i] * .pi / 180) * radii[i],
                        y: sin(angles[i] * .pi / 180) * radii[i] + orbFloat
                    )
            }

            Image(systemName: "brain.head.profile")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            glassBlue.opacity(0.7),
                            glassCyan.opacity(0.6),
                            glassPurple.opacity(0.5)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: glassBlue.opacity(0.3), radius: 12)
                .shadow(color: glassCyan.opacity(0.15), radius: 20)
                .offset(y: orbFloat)
        }
        .frame(width: 120, height: 120)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) {
                pulseScale = 1.08
                glowIntensity = 0.6
            }
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                orbFloat = -6
            }
            for i in 0..<6 {
                withAnimation(
                    .easeInOut(duration: 1.4)
                    .repeatForever(autoreverses: true)
                    .delay(Double(i) * 0.4)
                ) {
                    neuronPulse[i] = true
                }
            }
        }
    }
}

import SwiftUI

struct DeclarationExpandedSheet: View {
    let declaration: DailyDeclaration
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var appear: Bool = false
    @State private var glowPhase: Bool = false

    private var isDark: Bool { colorScheme == .dark }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        isDark ? Color(red: 0.06, green: 0.04, blue: 0.14) : Color(red: 0.98, green: 0.95, blue: 0.92),
                        isDark ? Color(red: 0.08, green: 0.05, blue: 0.18) : Color(red: 0.96, green: 0.92, blue: 0.90),
                        isDark ? Color(red: 0.06, green: 0.04, blue: 0.14) : Color(red: 0.97, green: 0.94, blue: 0.91)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 28) {
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Theme.dawnGold.opacity(glowPhase ? 0.25 : 0.10),
                                            Theme.dawnAmber.opacity(glowPhase ? 0.12 : 0.04),
                                            .clear
                                        ],
                                        center: .center,
                                        startRadius: 10,
                                        endRadius: 100
                                    )
                                )
                                .frame(width: 200, height: 200)

                            Image(systemName: "sparkles")
                                .font(.system(size: 44))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Theme.dawnGold, Theme.dawnAmber],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .scaleEffect(appear ? 1 : 0.6)
                                .opacity(appear ? 1 : 0)
                        }

                        VStack(spacing: 6) {
                            Text("TODAY\u{2019}S DECLARATION")
                                .font(.system(size: 11, weight: .heavy))
                                .tracking(2)
                                .foregroundStyle(Theme.dawnAmber)

                            Text(declaration.reference)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(Theme.dawnGold)
                        }
                        .opacity(appear ? 1 : 0)

                        Text("\u{201C}\(declaration.text)\u{201D}")
                            .font(.system(size: 24, weight: .medium, design: .serif))
                            .foregroundStyle(isDark ? .white.opacity(0.9) : Theme.textPrimary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(8)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 20)
                            .opacity(appear ? 1 : 0)
                            .offset(y: appear ? 0 : 16)

                        Text("Speak this over your life today.")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(isDark ? .white.opacity(0.4) : Theme.textSecondary)
                            .opacity(appear ? 1 : 0)
                    }

                    Spacer()

                    Button {
                        dismiss()
                    } label: {
                        Text("Amen")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(isDark ? .black : .white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                Capsule().fill(
                                    LinearGradient(
                                        colors: [Theme.dawnGold, Theme.dawnAmber],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            )
                            .shadow(color: Theme.dawnGold.opacity(0.3), radius: 12, y: 6)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    .opacity(appear ? 1 : 0)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(isDark ? .white.opacity(0.3) : Theme.textSecondary.opacity(0.4))
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) { appear = true }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) { glowPhase = true }
        }
        .presentationDetents([.large])
    }
}

import SwiftUI

struct ShareableBadgeView: View {
    let milestone: BadgeMilestone
    let currentStreak: Int
    let totalDays: Int
    let userName: String

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                AsyncImage(url: URL(string: milestone.imageURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    default:
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Theme.logoGradient)
                            .overlay {
                                Image(systemName: "shield.checkered")
                                    .font(.system(size: 50))
                                    .foregroundStyle(.white)
                            }
                    }
                }
                .frame(width: 160, height: 160)

                VStack(spacing: 6) {
                    Text(milestone.title.uppercased())
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .tracking(2)

                    Text(milestone.subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.top, 32)
            .padding(.horizontal, 24)

            Spacer().frame(height: 24)

            HStack(spacing: 24) {
                statPill(value: "\(currentStreak)", label: "Streak")
                statPill(value: "\(totalDays)", label: "Days")
                statPill(value: "\(milestone.daysRequired)", label: "Goal")
            }
            .padding(.horizontal, 20)

            Spacer().frame(height: 20)

            if !userName.isEmpty {
                Text(userName)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }

            HStack(spacing: 6) {
                Image(systemName: "shield.fill")
                    .font(.system(size: 11))
                Text("God First")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white.opacity(0.5))
            .padding(.top, 4)
            .padding(.bottom, 24)
        }
        .frame(width: 320)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.08, green: 0.06, blue: 0.22),
                            Color(red: 0.14, green: 0.10, blue: 0.36),
                            Color(red: 0.22, green: 0.14, blue: 0.48)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .strokeBorder(
                            LinearGradient(
                                colors: [.white.opacity(0.2), .white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }

    private func statPill(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.white.opacity(0.08))
        )
    }
}

struct BadgeDetailSheet: View {
    let milestone: BadgeMilestone
    let isUnlocked: Bool
    let currentStreak: Int
    let totalDays: Int
    let userName: String
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet: Bool = false
    @State private var renderedImage: UIImage?
    @State private var pulseAnimation: Bool = false
    @State private var shineOffset: CGFloat = -200

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    ZStack {
                        if isUnlocked {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [Theme.logoBlue.opacity(0.3), .clear],
                                        center: .center,
                                        startRadius: 20,
                                        endRadius: 120
                                    )
                                )
                                .frame(width: 240, height: 240)
                                .scaleEffect(pulseAnimation ? 1.1 : 0.9)
                                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: pulseAnimation)
                        }

                        AsyncImage(url: URL(string: milestone.imageURL)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                            default:
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Theme.logoGradient)
                                    .overlay {
                                        Image(systemName: "shield.checkered")
                                            .font(.system(size: 60))
                                            .foregroundStyle(.white)
                                    }
                            }
                        }
                        .frame(width: 180, height: 180)
                        .saturation(isUnlocked ? 1.0 : 0.0)
                        .opacity(isUnlocked ? 1.0 : 0.4)

                        if !isUnlocked {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(Theme.textSecondary.opacity(0.5))
                        }
                    }

                    VStack(spacing: 8) {
                        Text(milestone.title)
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)

                        Text("\(milestone.daysRequired) Day Cross Shield")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Theme.logoBlue)

                        Text(milestone.subtitle)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }

                    if isUnlocked {
                        Button {
                            generateShareImage()
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Share with Friends")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Theme.logoGradient)
                            )
                        }
                        .padding(.horizontal, 24)
                        .sensoryFeedback(.impact(weight: .medium), trigger: showShareSheet)
                    } else {
                        let progress = min(Double(totalDays) / Double(milestone.daysRequired), 1.0)
                        let remaining = max(milestone.daysRequired - totalDays, 0)

                        VStack(spacing: 12) {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Theme.textSecondary.opacity(0.12))
                                    Capsule()
                                        .fill(Theme.logoGradient)
                                        .frame(width: geo.size.width * progress)
                                }
                            }
                            .frame(height: 10)
                            .clipShape(Capsule())
                            .padding(.horizontal, 24)

                            Text("\(remaining) days to go")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            .background(Theme.bg)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Theme.textSecondary.opacity(0.4))
                    }
                }
            }
        }
        .onAppear {
            pulseAnimation = true
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = renderedImage {
                ShareSheetView(items: [image, milestone.shareMessage])
            }
        }
    }

    @MainActor
    private func generateShareImage() {
        let shareView = ShareableBadgeView(
            milestone: milestone,
            currentStreak: currentStreak,
            totalDays: totalDays,
            userName: userName
        )
        let renderer = ImageRenderer(content: shareView)
        renderer.scale = 3.0
        if let uiImage = renderer.uiImage {
            renderedImage = uiImage
            showShareSheet = true
        }
    }
}

struct ShareSheetView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

import SwiftUI

struct ScreenTimeBibleScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var phase: ScanPhase = .ready
    @State private var capturedImage: UIImage?
    @State private var showCamera: Bool = false
    @State private var emojiFloat: CGFloat = 0
    @State private var analyzingDots: Int = 1
    @State private var dotTimer: Timer?
    @State private var shakeAmount: CGFloat = 0
    @State private var confettiPieces: [ConfettiPiece] = (0..<45).map { _ in
        ConfettiPiece(
            x: CGFloat.random(in: 0...1),
            y: CGFloat.random(in: -0.3...0.0),
            size: CGFloat.random(in: 4...10),
            color: [Color.red, .orange, .yellow, .green, .blue, .purple, .pink, .mint, .cyan, .indigo].randomElement()!,
            rotation: Double.random(in: 0...360),
            velocity: CGFloat.random(in: 0.3...0.8)
        )
    }
    @State private var confettiOffset: CGFloat = 0
    @State private var confettiVisible: Bool = false
    @State private var sunScale: CGFloat = 0.3
    @State private var textOpacity: Double = 0
    @State private var buttonOpacity: Double = 0

    var onUnlocked: (() -> Void)?

    private enum ScanPhase {
        case ready
        case analyzing
        case failed
        case success
    }

    private var isDark: Bool { colorScheme == .dark }

    var body: some View {
        NavigationStack {
            ZStack {
                warmBackground

                switch phase {
                case .ready:
                    readyView
                        .transition(.opacity)
                case .analyzing:
                    analyzingView
                        .transition(.opacity)
                case .failed:
                    failedView
                        .transition(.opacity)
                case .success:
                    successView
                        .transition(.opacity)
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.85), value: phase)
            .toolbar {
                if phase != .success {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showCamera) {
                CameraPickerView { image in
                    capturedImage = image
                    handleBiblePhoto(image)
                }
            }
        }
    }

    private var readyView: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 48)

            VStack(spacing: 8) {
                Text("Show Your Bible")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)

                Text("Take a photo of your open Bible to unlock")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)

            Spacer().frame(height: 28)

            cameraViewfinder
                .padding(.horizontal, 24)

            Spacer().frame(height: 24)

            instructionPills

            Spacer()

            Button {
                showCamera = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 18))
                    Text("Take Photo")
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [Theme.logoBlue, Theme.logoIndigo],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(.rect(cornerRadius: 28))
                .shadow(color: Theme.logoBlue.opacity(0.3), radius: 12, y: 5)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 50)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                emojiFloat = -8
            }
        }
    }

    private var analyzingView: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 48)

            VStack(spacing: 8) {
                Text("Analyzing Photo")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)

                HStack(spacing: 4) {
                    Text("Checking for Bible text")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                    Text(String(repeating: ".", count: analyzingDots))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)

            Spacer().frame(height: 32)

            verifyingViewfinder
                .padding(.horizontal, 24)

            Spacer()

            ProgressView()
                .controlSize(.large)
                .tint(Theme.logoBlue)
                .padding(.bottom, 50)
        }
        .onAppear {
            analyzingDots = 1
            dotTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                Task { @MainActor in
                    analyzingDots = (analyzingDots % 3) + 1
                }
            }
        }
        .onDisappear {
            dotTimer?.invalidate()
            dotTimer = nil
        }
    }

    private var failedView: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 60)

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Theme.coral.opacity(isDark ? 0.15 : 0.1))
                        .frame(width: 90, height: 90)
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(Theme.coral)
                        .modifier(ShakeModifier(amount: shakeAmount))
                }

                VStack(spacing: 8) {
                    Text("Bible Not Detected")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)

                    Text("Make sure your Bible is open with\nvisible text and good lighting")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }

                VStack(spacing: 10) {
                    tipRow(icon: "book.open.fill", text: "Open your Bible to any page")
                    tipRow(icon: "light.max", text: "Make sure there's good lighting")
                    tipRow(icon: "text.viewfinder", text: "Keep the text visible and clear")
                }
                .padding(.top, 8)

                Button {
                    withAnimation { phase = .ready }
                    capturedImage = nil
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 16))
                        Text("Try Again")
                            .font(.system(size: 17, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [Theme.logoBlue, Theme.logoIndigo],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(.rect(cornerRadius: 28))
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .onAppear {
            withAnimation(.default) {
                shakeAmount = 10
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                shakeAmount = 0
            }
        }
    }

    private var successView: some View {
        ZStack {
            warmBackground

            confettiLayer

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Theme.successEmerald.opacity(0.25),
                                    Theme.successEmerald.opacity(0.08),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 90
                            )
                        )
                        .frame(width: 180, height: 180)

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Theme.successEmerald.opacity(0.2), Theme.mint.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)

                    Image(systemName: "lock.open.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(Theme.successEmerald)
                }
                .scaleEffect(sunScale)

                Spacer().frame(height: 32)

                VStack(spacing: 12) {
                    Text("Apps Unlocked!")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)

                    Text("Thanks for keeping God first.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                }
                .opacity(textOpacity)

                Spacer()

                Button {
                    onUnlocked?()
                    dismiss()
                } label: {
                    Text("Continue")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [Theme.successEmerald, Theme.mint],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(.rect(cornerRadius: 28))
                }
                .opacity(buttonOpacity)
                .padding(.horizontal, 24)

                Spacer().frame(height: 50)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                sunScale = 1.0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                textOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.6)) {
                buttonOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.3)) {
                confettiVisible = true
            }
            withAnimation(.linear(duration: 3.0)) {
                confettiOffset = 800
            }
        }
        .sensoryFeedback(.success, trigger: confettiVisible)
    }

    private var instructionPills: some View {
        HStack(spacing: 8) {
            instructionChip(number: "1", text: "Open Bible")
            instructionChip(number: "2", text: "Take Photo")
            instructionChip(number: "3", text: "Unlocked!")
        }
        .padding(.horizontal, 24)
    }

    private func instructionChip(number: String, text: String) -> some View {
        HStack(spacing: 6) {
            Text(number)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 20, height: 20)
                .background(Circle().fill(Theme.logoBlue))
            Text(text)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            Capsule().fill(isDark ? Color.white.opacity(0.06) : Color(.secondarySystemGroupedBackground))
        )
    }

    private func tipRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Theme.logoBlue)
                .frame(width: 24)
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
            Spacer()
        }
    }

    private var cameraViewfinder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(isDark ? Color(.tertiarySystemGroupedBackground) : Color(.secondarySystemGroupedBackground))

            VStack {
                HStack {
                    ScanCorner(rotation: 0)
                    Spacer()
                    ScanCorner(rotation: 90)
                }
                Spacer()
                HStack {
                    ScanCorner(rotation: 270)
                    Spacer()
                    ScanCorner(rotation: 180)
                }
            }
            .padding(20)

            VStack(spacing: 14) {
                Image(systemName: "book.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Theme.textSecondary.opacity(0.3))
                    .offset(y: emojiFloat)

                Text("Point camera at your open Bible")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 280)
    }

    private var verifyingViewfinder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(isDark ? Color(.tertiarySystemGroupedBackground) : Color(.secondarySystemGroupedBackground))

            if let img = capturedImage {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .blur(radius: 12)
                    .clipShape(.rect(cornerRadius: 24))
                    .allowsHitTesting(false)
            }

            Color.black.opacity(0.4)
                .clipShape(.rect(cornerRadius: 24))

            VStack(spacing: 16) {
                ProgressView()
                    .controlSize(.large)
                    .tint(.white)

                Text("Verifying Bible...")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 280)
    }

    private var confettiLayer: some View {
        GeometryReader { geo in
            ForEach(confettiPieces.indices, id: \.self) { i in
                let piece = confettiPieces[i]
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(piece.color)
                    .frame(width: piece.size, height: piece.size * 1.5)
                    .rotationEffect(.degrees(piece.rotation + confettiOffset * 0.3))
                    .position(
                        x: piece.x * geo.size.width,
                        y: piece.y * geo.size.height + confettiOffset * piece.velocity
                    )
                    .opacity(confettiVisible ? (confettiOffset < 600 ? 1.0 : max(0.0, 1.0 - Double(confettiOffset - 600) / 200.0)) : 0.0)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private var warmBackground: some View {
        if isDark {
            Color(.systemBackground)
                .ignoresSafeArea()
        } else {
            LinearGradient(
                colors: [
                    Color(red: 0.99, green: 0.98, blue: 0.96),
                    Color(red: 0.97, green: 0.96, blue: 0.94)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }

    private func handleBiblePhoto(_ image: UIImage) {
        withAnimation { phase = .analyzing }
        Task {
            let result = await BibleDetectionService.shared.detectBible(in: image)
            dotTimer?.invalidate()
            dotTimer = nil
            if result.isBible {
                ScreenTimeService.shared.clearManualFocusLock()
                ScriptureUnlockService.shared.unlockAppsWithScripture()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    phase = .success
                }
            } else {
                withAnimation { phase = .failed }
            }
        }
    }
}

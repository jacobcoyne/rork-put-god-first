import SwiftUI

struct BiblePhotoUnlockView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showCamera: Bool = false
    @State private var capturedImage: UIImage?
    @State private var isAnalyzing: Bool = false
    @State private var analysisResult: AnalysisResult?
    @State private var pulseGlow: Bool = false
    @State private var scanLineOffset: CGFloat = 0

    var onUnlocked: (() -> Void)?

    private enum AnalysisResult {
        case success(confidence: Double)
        case failure(message: String)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.04, green: 0.03, blue: 0.12),
                        Color(red: 0.06, green: 0.04, blue: 0.18),
                        Color(red: 0.04, green: 0.03, blue: 0.12)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer().frame(height: 16)

                    headerSection

                    Spacer().frame(height: 28)

                    if let image = capturedImage {
                        capturedImageSection(image)
                    } else {
                        instructionSection
                    }

                    Spacer()

                    if let result = analysisResult {
                        resultSection(result)
                        Spacer().frame(height: 16)
                    }

                    actionButton

                    Spacer().frame(height: 24)
                }
                .padding(.horizontal, 24)

                if isAnalyzing {
                    analyzingOverlay
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .fullScreenCover(isPresented: $showCamera) {
                CameraPickerView { image in
                    capturedImage = image
                    analyzeImage(image)
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Theme.dawnGold.opacity(pulseGlow ? 0.25 : 0.1), .clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 50
                        )
                    )
                    .frame(width: 80, height: 80)

                Image(systemName: "book.and.wreath")
                    .font(.system(size: 36))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.dawnGold, Theme.dawnAmber],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: Theme.dawnGold.opacity(0.4), radius: 8)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    pulseGlow = true
                }
            }

            Spacer().frame(height: 12)

            Text("Open Bible Challenge")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
            Text("Take a photo of your open Bible")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))
        }
        .multilineTextAlignment(.center)
    }

    private var instructionSection: some View {
        VStack(spacing: 18) {
            VStack(spacing: 14) {
                instructionRow(icon: "1.circle.fill", text: "Open your physical Bible to any page", color: Theme.dawnGold)
                instructionRow(icon: "2.circle.fill", text: "Make sure text is visible and readable", color: Theme.dawnAmber)
                instructionRow(icon: "3.circle.fill", text: "Take a clear, well-lit photo", color: Theme.dawnPeach)
            }
            .padding(20)
            .background(Color.white.opacity(0.06))
            .clipShape(.rect(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
            )

            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.dawnGold.opacity(0.7))
                Text("Tip: Good lighting helps with detection accuracy")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
    }

    private func instructionRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(color)
                .frame(width: 28)
            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white.opacity(0.85))
            Spacer()
        }
    }

    private func capturedImageSection(_ image: UIImage) -> some View {
        VStack(spacing: 14) {
            Color.clear
                .frame(height: 220)
                .overlay {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .allowsHitTesting(false)
                }
                .clipShape(.rect(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            resultBorderColor,
                            lineWidth: 2
                        )
                )

            if analysisResult == nil && !isAnalyzing {
                Button {
                    capturedImage = nil
                    analysisResult = nil
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 13))
                        Text("Retake Photo")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(.white.opacity(0.5))
                }
            }
        }
    }

    private var resultBorderColor: Color {
        switch analysisResult {
        case .success: return Theme.successEmerald.opacity(0.6)
        case .failure: return Theme.coral.opacity(0.6)
        case nil: return Color.white.opacity(0.1)
        }
    }

    private func resultSection(_ result: AnalysisResult) -> some View {
        Group {
            switch result {
            case .success(let confidence):
                VStack(spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(Theme.successEmerald)
                        Text("Bible Detected!")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Theme.successEmerald)
                    }
                    Text("Confidence: \(Int(confidence * 100))%")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                    Text("Great job opening God\u{2019}s Word!")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(Theme.successEmerald.opacity(0.1))
                .clipShape(.rect(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Theme.successEmerald.opacity(0.25), lineWidth: 1)
                )

            case .failure(let message):
                VStack(spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(Theme.coral)
                        Text("Not Detected")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Theme.coral)
                    }
                    Text(message)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(Theme.coral.opacity(0.1))
                .clipShape(.rect(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Theme.coral.opacity(0.25), lineWidth: 1)
                )
            }
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }

    private var actionButton: some View {
        Group {
            switch analysisResult {
            case .success:
                Button {
                    ScreenTimeLimitService.shared.unlockWithChallenge()
                    onUnlocked?()
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "lock.open.fill")
                            .font(.system(size: 18))
                        Text("Unlock My Apps")
                            .font(.system(size: 17, weight: .bold))
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [Theme.successEmerald, Theme.successEmeraldLight],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(.rect(cornerRadius: 28))
                    .shadow(color: Theme.successEmerald.opacity(0.4), radius: 12)
                }

            case .failure:
                VStack(spacing: 12) {
                    Button {
                        capturedImage = nil
                        analysisResult = nil
                        showCamera = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 18))
                            Text("Try Again")
                                .font(.system(size: 17, weight: .bold))
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(.white)
                        .clipShape(.rect(cornerRadius: 28))
                    }
                }

            case nil:
                Button {
                    showCamera = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 18))
                        Text("Take Photo")
                            .font(.system(size: 17, weight: .bold))
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(.white)
                    .clipShape(.rect(cornerRadius: 28))
                }
            }
        }
    }

    private var analyzingOverlay: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Theme.dawnGold.opacity(0.2), .clear],
                                center: .center,
                                startRadius: 10,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)

                    Image(systemName: "text.viewfinder")
                        .font(.system(size: 44))
                        .foregroundStyle(Theme.dawnGold)
                        .symbolEffect(.pulse, options: .repeating)
                }

                Text("Analyzing your Bible...")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)

                Text("Scanning for scripture text")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
    }

    private func analyzeImage(_ image: UIImage) {
        isAnalyzing = true
        analysisResult = nil

        Task {
            let result = await BibleDetectionService.shared.detectBible(in: image)

            try? await Task.sleep(for: .seconds(1.5))

            await MainActor.run {
                isAnalyzing = false
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    if result.isBible && result.confidence >= 0.50 {
                        analysisResult = .success(confidence: result.confidence)
                        let gen = UINotificationFeedbackGenerator()
                        gen.notificationOccurred(.success)
                    } else if result.isBible {
                        analysisResult = .failure(message: "We detected some text but couldn\u{2019}t confirm it\u{2019}s a Bible. Confidence: \(Int(result.confidence * 100))%. Try a clearer photo with more visible scripture text.")
                        let gen = UINotificationFeedbackGenerator()
                        gen.notificationOccurred(.warning)
                    } else {
                        analysisResult = .failure(message: "Couldn\u{2019}t detect Bible text. Make sure the pages are open with clear, readable text visible.")
                        let gen = UINotificationFeedbackGenerator()
                        gen.notificationOccurred(.error)
                    }
                }
            }
        }
    }
}

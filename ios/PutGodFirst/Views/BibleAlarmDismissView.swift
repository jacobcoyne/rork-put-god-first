import SwiftUI

struct BibleAlarmDismissView: View {
    @Bindable var alarmVM: BibleAlarmViewModel
    @State private var pulsePhase: Bool = false
    @State private var shakeAmount: CGFloat = 0
    @State private var emojiFloat: CGFloat = 0
    @State private var analyzingDots: Int = 0
    @State private var dotTimer: Timer?

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            switch alarmVM.dismissPhase {
            case .missionSelect, .scanBible:
                scanBibleView
                    .transition(.opacity)
            case .reciteVerse:
                VerseRecitationView(alarmVM: alarmVM)
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
            case .success:
                EmptyView()
            }

            if alarmVM.showSuccessCelebration {
                AlarmSuccessView(alarmVM: alarmVM)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: alarmVM.dismissPhase)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: alarmVM.showSuccessCelebration)
        .sheet(isPresented: $alarmVM.showCamera) {
            CameraPickerView { image in
                alarmVM.verifyPhoto(image)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                emojiFloat = -8
            }
        }
    }

    private var scanBibleView: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 60)

            VStack(spacing: 4) {
                HStack(spacing: 0) {
                    Text("Take a photo of your ")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color(.label))
                    Text("OPEN Bible")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color(.label))
                        .underline(true, color: Color(.label))
                }
                Text("to turn off your alarm")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color(.label))
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)

            Spacer().frame(height: 32)

            if let result = alarmVM.verificationResult {
                scanResultSection(result)
                    .padding(.horizontal, 24)
                Spacer()
            } else if alarmVM.isVerifying {
                verifyingViewfinder
                    .padding(.horizontal, 24)
                Spacer()
                captureButton(disabled: true, analyzing: true)
                    .padding(.bottom, 50)
            } else {
                cameraViewfinder
                    .padding(.horizontal, 24)
                Spacer()
                captureButton(disabled: false, analyzing: false)
                    .padding(.bottom, 50)
            }

            #if targetEnvironment(simulator)
            Text("In the simulator, pick a photo of a Bible.")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .padding(.bottom, 8)
            #endif
        }
    }

    private var cameraViewfinder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.tertiarySystemGroupedBackground))

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

            VStack(spacing: 12) {
                Image(systemName: "book.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.tertiary)
                    .offset(y: emojiFloat)

                Text("Point camera at your OPEN Bible")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
    }

    private var verifyingViewfinder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.tertiarySystemGroupedBackground))

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

            Color.black.opacity(0.3)
                .clipShape(.rect(cornerRadius: 24))
                .blur(radius: 2)

            VStack(spacing: 16) {
                HStack(spacing: 8) {
                    Image(systemName: "alarm.fill")
                        .font(.system(size: 20, weight: .medium))
                    Text("God First")
                        .font(.system(size: 24, weight: .bold))
                }
                .foregroundStyle(.white)

                Spacer().frame(height: 20)

                HStack(spacing: 4) {
                    Text("Analyzing Book")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                    Text(String(repeating: " •", count: analyzingDots))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
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

    private func captureButton(disabled: Bool, analyzing: Bool) -> some View {
        Button {
            alarmVM.showCamera = true
        } label: {
            ZStack {
                Circle()
                    .strokeBorder(Color(.label).opacity(disabled ? 0.15 : 0.4), lineWidth: 4)
                    .frame(width: 78, height: 78)

                if analyzing {
                    Circle()
                        .fill(Color(.label).opacity(0.08))
                        .frame(width: 62, height: 62)
                    ProgressView()
                        .controlSize(.regular)
                        .tint(Color(.label))
                } else {
                    Circle()
                        .fill(Color(.label).opacity(0.06))
                        .frame(width: 62, height: 62)
                    Image(systemName: "camera.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color(.label).opacity(0.6))
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(disabled)
    }

    private func scanResultSection(_ result: VerificationResult) -> some View {
        VStack(spacing: 20) {
            switch result {
            case .success:
                EmptyView()

            case .failure:
                VStack(spacing: 16) {
                    Spacer().frame(height: 40)

                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 52))
                        .foregroundStyle(.red)
                        .modifier(ShakeModifier(amount: shakeAmount))

                    Text("Bible Not Detected")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color(.label))

                    Text("Take a clear photo of your OPEN Bible\nwith visible text")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Button {
                        alarmVM.retryCapture()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 16))
                            Text("Try Again")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(.label))
                        .clipShape(.rect(cornerRadius: 28))
                    }
                    .padding(.top, 8)
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
        }
    }
}

struct ScanCorner: View {
    let rotation: Double

    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 32))
            path.addLine(to: CGPoint(x: 0, y: 8))
            path.addQuadCurve(to: CGPoint(x: 8, y: 0), control: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 32, y: 0))
        }
        .stroke(Color(.label).opacity(0.5), lineWidth: 3.5)
        .frame(width: 32, height: 32)
        .rotationEffect(.degrees(rotation))
    }
}

struct ViewfinderCorner: View {
    let rotation: Double

    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 28))
            path.addLine(to: CGPoint(x: 0, y: 6))
            path.addQuadCurve(to: CGPoint(x: 6, y: 0), control: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 28, y: 0))
        }
        .stroke(Color(.label).opacity(0.4), lineWidth: 3)
        .frame(width: 28, height: 28)
        .rotationEffect(.degrees(rotation))
    }
}

struct CornerBracket: View {
    let rotation: Double

    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 16))
            path.addLine(to: CGPoint(x: 0, y: 4))
            path.addQuadCurve(to: CGPoint(x: 4, y: 0), control: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 16, y: 0))
        }
        .stroke(Color(.label).opacity(0.35), lineWidth: 2.5)
        .frame(width: 16, height: 16)
        .rotationEffect(.degrees(rotation))
    }
}

struct ShakeModifier: GeometryEffect {
    var amount: CGFloat
    var animatableData: CGFloat {
        get { amount }
        set { amount = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let offset = amount * sin(amount * .pi * 2)
        return ProjectionTransform(CGAffineTransform(translationX: offset, y: 0))
    }
}

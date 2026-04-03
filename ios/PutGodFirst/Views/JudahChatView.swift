import SwiftUI

struct GuideChatView: View {
    var presentedAsSheet: Bool = false
    @State private var viewModel = GuideChatViewModel()
    @FocusState private var isInputFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    private var isDark: Bool { colorScheme == .dark }

    private let topicCards: [(icon: String, title: String, subtitle: String, color: Color, prompt: String)] = [
        ("sun.max.fill", "Morning With God", "Start your day right", Color(red: 0.95, green: 0.88, blue: 0.72), "Give me a short morning devotional to start my day with God. Include a verse and a prayer."),
        ("heart.fill", "I'm Going Through It", "Find comfort right now", Color(red: 0.88, green: 0.78, blue: 0.82), "I'm going through a hard season. What does God say about pain, and can you pray with me?"),
        ("hands.sparkles.fill", "Pray With Me", "Guided prayer for today", Color(red: 0.82, green: 0.82, blue: 0.95), "Guide me through a meaningful prayer right now for whatever I'm facing today."),
        ("figure.mind.and.body", "Anxiety & Worry", "Peace in the chaos", Color(red: 0.78, green: 0.88, blue: 0.85), "I'm feeling anxious. What does the Bible say about worry, fear, and trusting God?"),
        ("person.2.fill", "Relationship Advice", "Biblical wisdom for love", Color(red: 0.85, green: 0.82, blue: 0.95), "I need godly advice about my relationships. What does the Bible teach about love, forgiveness, and boundaries?"),
        ("cross.fill", "Explain the Gospel", "Salvation made clear", Color(red: 0.95, green: 0.85, blue: 0.80), "Explain the Gospel to me simply. What does it mean to be saved and how do I grow in faith?"),
        ("briefcase.fill", "Faith at Work", "Honor God 9 to 5", Color(red: 0.82, green: 0.90, blue: 0.82), "How do I live out my faith at work? Give me practical ways to honor God in my career."),
        ("dollarsign.circle.fill", "Money & Stewardship", "Biblical finances", Color(red: 0.88, green: 0.85, blue: 0.78), "What does the Bible say about money, tithing, debt, and being a good steward?"),
        ("shield.fill", "Spiritual Warfare", "Stand firm in faith", Color(red: 0.90, green: 0.80, blue: 0.85), "I feel spiritually attacked. What does the Bible teach about spiritual warfare and how to fight back?"),
        ("moon.stars.fill", "Can't Sleep", "Rest in His presence", Color(red: 0.78, green: 0.80, blue: 0.92), "I can't sleep and my mind is racing. Give me peaceful scriptures and a bedtime prayer."),
        ("person.fill.questionmark", "Finding My Purpose", "Why am I here?", Color(red: 0.85, green: 0.88, blue: 0.78), "I feel lost and don't know my purpose. What does God say about the plans He has for me?"),
        ("arrow.triangle.2.circlepath", "Breaking Bad Habits", "Freedom in Christ", Color(red: 0.92, green: 0.82, blue: 0.78), "I keep falling into the same sin. How do I break free and find victory through Christ?")
    ]

    private let quickReplySuggestions: [[String]] = [
        ["Tell me more", "Can you give me a verse for that?", "How do I apply this?"],
        ["Pray with me about this", "What else does the Bible say?", "That's helpful, thank you"],
        ["I'm struggling with this", "Can you explain further?", "Give me a practical step"],
        ["How do I share this with others?", "What's a good devotional on this?", "Help me memorize this verse"],
        ["I need more encouragement", "What would Jesus do?", "How do I stay consistent?"]
    ]

    private var currentQuickReplies: [String] {
        let index = max(0, viewModel.messages.count - 2) % quickReplySuggestions.count
        return quickReplySuggestions[index]
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                if viewModel.messages.count <= 1 {
                    homeScreen
                } else {
                    chatScreen
                }

                VStack(spacing: 0) {
                    if viewModel.messages.count > 1 && !viewModel.isLoading && !viewModel.showRetry {
                        suggestionChips
                    }
                    floatingInputBar
                }
            }
            .background(chatBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.messages.count > 1 {
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                viewModel.clearChat()
                            }
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 15, weight: .semibold))
                                Text("Topics")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundStyle(Theme.icePurple)
                        }
                    } else if presentedAsSheet {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.secondary)
                                .frame(width: 32, height: 32)
                                .background(Circle().fill(Color(.tertiarySystemFill)))
                        }
                    } else {
                        HStack(spacing: 8) {
                            Image("GuideLogo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 26, height: 26)
                                .clipShape(Circle())
                            Text("Guide")
                                .font(.system(size: 20, weight: .bold))
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.messages.count > 1 && presentedAsSheet {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.secondary)
                                .frame(width: 32, height: 32)
                                .background(Circle().fill(Color(.tertiarySystemFill)))
                        }
                    }
                }
            }
        }
    }

    // MARK: - Home Screen

    private var homeScreen: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                topicsGrid
                    .padding(.top, 12)

                Spacer().frame(height: 80)
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: - Topics Grid

    private let gridColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    @State private var showAllTopics: Bool = false

    private var visibleTopics: [(icon: String, title: String, subtitle: String, color: Color, prompt: String)] {
        showAllTopics ? topicCards : Array(topicCards.prefix(6))
    }

    private var topicsGrid: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Explore Topics")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        showAllTopics.toggle()
                    }
                } label: {
                    Text(showAllTopics ? "SHOW LESS" : "VIEW ALL")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(Theme.textSecondary)
                        .tracking(0.5)
                }
            }
            .padding(.horizontal, 16)

            LazyVGrid(columns: gridColumns, spacing: 12) {
                ForEach(Array(visibleTopics.enumerated()), id: \.offset) { index, topic in
                    Button {
                        viewModel.inputText = topic.prompt
                        viewModel.sendMessage()
                    } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(topic.title)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(isDark ? .white : Color(red: 0.15, green: 0.15, blue: 0.20))
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)

                            Text(topic.subtitle)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(isDark ? .white.opacity(0.75) : Color(red: 0.35, green: 0.35, blue: 0.40))
                                .multilineTextAlignment(.leading)

                            Spacer()

                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(isDark ? .white.opacity(0.7) : Color(red: 0.35, green: 0.35, blue: 0.40))
                                .padding(6)
                                .background(
                                    Circle().fill(isDark ? Color.white.opacity(0.12) : Color.black.opacity(0.06))
                                )
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(isDark ? Color(red: 0.12, green: 0.12, blue: 0.18) : topic.color.opacity(0.45))
                                if isDark {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    topic.color.opacity(0.55),
                                                    topic.color.opacity(0.25),
                                                    Color(red: 0.45, green: 0.30, blue: 0.85).opacity(0.20)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(
                                            RadialGradient(
                                                colors: [
                                                    topic.color.opacity(0.35),
                                                    .clear
                                                ],
                                                center: .topLeading,
                                                startRadius: 5,
                                                endRadius: 140
                                            )
                                        )
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [
                                                    topic.color.opacity(0.6),
                                                    topic.color.opacity(0.15),
                                                    Color(red: 0.55, green: 0.40, blue: 0.95).opacity(0.25)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 0.8
                                        )
                                }
                            }
                        )
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Suggestion Chips (in-conversation quick replies)

    private var suggestionChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(currentQuickReplies, id: \.self) { suggestion in
                    Button {
                        viewModel.inputText = suggestion
                        viewModel.sendMessage()
                    } label: {
                        Text(suggestion)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(isDark ? .white.opacity(0.8) : Theme.textPrimary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(
                                Capsule()
                                    .fill(isDark ? Color.white.opacity(0.08) : Color(.systemBackground))
                                    .overlay(
                                        Capsule()
                                            .strokeBorder(Color(.separator).opacity(0.2), lineWidth: 0.5)
                                    )
                            )
                    }
                    .disabled(viewModel.isLoading)
                }
            }
        }
        .contentMargins(.horizontal, 14)
        .padding(.bottom, 4)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: viewModel.messages.count)
    }

    // MARK: - Chat Screen

    private var chatScreen: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.messages) { message in
                        GuideMessageRow(message: message)
                            .id(message.id)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    if viewModel.isLoading {
                        loadingRow
                            .id("typing")
                            .transition(.opacity)
                    }

                    if viewModel.showRetry {
                        retryRow
                            .id("retry")
                    }

                    Color.clear.frame(height: 120).id("bottom")
                }
                .padding(.bottom, 8)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: viewModel.messages.count) { _, _ in
                withAnimation(.easeOut(duration: 0.25)) {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
            .onChange(of: viewModel.isLoading) { _, _ in
                withAnimation(.easeOut(duration: 0.25)) {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
        }
    }

    private var loadingRow: some View {
        HStack(alignment: .top, spacing: 10) {
            GuideAvatarSmall()

            HStack(spacing: 0) {
                GuideTypingDots()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemBackground).opacity(0.7))
            .clipShape(.rect(cornerRadius: 18, style: .continuous))

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }

    private var retryRow: some View {
        VStack(spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.circle")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                Text(viewModel.errorMessage ?? "Something went wrong")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }

            Button {
                viewModel.retry()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Try again")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 9)
                .background(Theme.icePurple.gradient)
                .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    // MARK: - Floating Input Bar

    private var floatingInputBar: some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom, spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.dawnGold, Theme.dawnAmber],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 28, height: 28)
                    .padding(.bottom, 5)

                TextField("Ask a question...", text: $viewModel.inputText, axis: .vertical)
                    .lineLimit(1...6)
                    .focused($isInputFocused)
                    .textFieldStyle(.plain)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .padding(.vertical, 8)
                    .onSubmit {
                        viewModel.sendMessage()
                    }

                Button {
                    viewModel.sendMessage()
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 30, height: 30)
                        .background(
                            Circle().fill(
                                canSend
                                    ? AnyShapeStyle(Theme.primaryGradient)
                                    : AnyShapeStyle(Color(.tertiaryLabel))
                            )
                        )
                }
                .disabled(!canSend)
                .padding(.bottom, 3)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(isDark ? Color(.secondarySystemBackground) : .white)
                    .shadow(color: .black.opacity(isDark ? 0.35 : 0.08), radius: 12, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(Color(.separator).opacity(0.15), lineWidth: 0.5)
                    )
            )
            .padding(.horizontal, 14)
            .padding(.bottom, 8)
        }
        .sensoryFeedback(.impact(flexibility: .soft), trigger: viewModel.messages.count)
    }

    private var canSend: Bool {
        !viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !viewModel.isLoading
    }

    // MARK: - Background

    private var chatBackground: some View {
        Group {
            if isDark {
                Color(.systemBackground)
            } else {
                LinearGradient(
                    colors: [
                        Color(red: 0.99, green: 0.98, blue: 0.96),
                        Color(red: 0.97, green: 0.96, blue: 0.94)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
    }
}

struct GuideMessageRow: View {
    let message: ChatMessage
    @Environment(\.colorScheme) private var colorScheme

    private var isUser: Bool { message.role == .user }

    var body: some View {
        if isUser {
            userMessage
        } else {
            assistantMessage
        }
    }

    private var userMessage: some View {
        HStack {
            Spacer(minLength: 56)
            Text(message.content)
                .font(.body)
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(
                        colors: [Theme.icePurple, Theme.icePurple.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(ChatBubbleShape(isUser: true))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }

    private var assistantMessage: some View {
        HStack(alignment: .top, spacing: 8) {
            GuideAvatarSmall()

            VStack(alignment: .leading, spacing: 0) {
                Text(message.content)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(3)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        Color(.secondarySystemBackground).opacity(colorScheme == .dark ? 0.5 : 0.7)
                    )
                    .clipShape(ChatBubbleShape(isUser: false))
            }

            Spacer(minLength: 32)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}

struct ChatBubbleShape: Shape {
    let isUser: Bool

    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = 18
        let tailRadius: CGFloat = 6

        if isUser {
            var path = Path()
            path.move(to: CGPoint(x: rect.minX + radius, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
            path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius),
                        radius: radius, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - tailRadius))
            path.addArc(center: CGPoint(x: rect.maxX - tailRadius, y: rect.maxY - tailRadius),
                        radius: tailRadius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
            path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
            path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius),
                        radius: radius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
            path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.minY + radius),
                        radius: radius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
            return path
        } else {
            var path = Path()
            path.move(to: CGPoint(x: rect.minX + tailRadius, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
            path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius),
                        radius: radius, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
            path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius),
                        radius: radius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
            path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
            path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius),
                        radius: radius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tailRadius))
            path.addArc(center: CGPoint(x: rect.minX + tailRadius, y: rect.minY + tailRadius),
                        radius: tailRadius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
            return path
        }
    }
}

struct GuideAvatarSmall: View {
    var body: some View {
        Image("GuideLogo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 28, height: 28)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [Theme.icePurple.opacity(0.4), Theme.iceBlue.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
    }
}

struct GuideLogoAnimated: View {
    let size: CGFloat
    @State private var glowPhase: Bool = false
    @State private var floatPhase: Bool = false

    var body: some View {
        Image("GuideLogo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .clipShape(Circle())
            .offset(y: floatPhase ? -3 : 3)
            .onAppear {
                withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                    glowPhase = true
                }
                withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                    floatPhase = true
                }
            }
    }
}

struct GuideTypingDots: View {
    @State private var animating: Bool = false

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Theme.icePurple.opacity(0.6))
                    .frame(width: 7, height: 7)
                    .scaleEffect(animating ? 1.0 : 0.5)
                    .opacity(animating ? 1.0 : 0.3)
                    .animation(
                        .easeInOut(duration: 0.5)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.18),
                        value: animating
                    )
            }
        }
        .onAppear {
            animating = true
        }
    }
}

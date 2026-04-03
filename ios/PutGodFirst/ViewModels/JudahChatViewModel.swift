import SwiftUI
import Observation

@Observable
final class GuideChatViewModel {
    var messages: [ChatMessage] = []
    var inputText: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    var showRetry: Bool = false

    private let chatService = GuideChatService.shared

    init() {
        let hour = Calendar.current.component(.hour, from: Date())
        let greeting: String
        if hour < 12 {
            greeting = "Good morning! I hope your day is starting with peace."
        } else if hour < 17 {
            greeting = "Good afternoon! I\u{2019}m glad you\u{2019}re here."
        } else {
            greeting = "Good evening! What a blessing to connect with you."
        }
        messages.append(ChatMessage(role: .assistant, content: "\(greeting) I\u{2019}m your God First Guide \u{2014} ask me anything about Scripture, faith, prayer, or whatever\u{2019}s on your heart."))
    }

    func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isLoading else { return }

        let userMessage = ChatMessage(role: .user, content: text)
        messages.append(userMessage)
        inputText = ""
        isLoading = true
        errorMessage = nil
        showRetry = false

        Task {
            do {
                let response = try await chatService.sendMessageWithRetry(messages: messages)
                let assistantMessage = ChatMessage(role: .assistant, content: response)
                messages.append(assistantMessage)
                showRetry = false
            } catch {
                errorMessage = error.localizedDescription
                showRetry = true
            }
            isLoading = false
        }
    }

    func retry() {
        guard !isLoading else { return }
        showRetry = false
        errorMessage = nil
        isLoading = true

        Task {
            do {
                let response = try await chatService.sendMessageWithRetry(messages: messages)
                let assistantMessage = ChatMessage(role: .assistant, content: response)
                messages.append(assistantMessage)
                showRetry = false
            } catch {
                errorMessage = error.localizedDescription
                showRetry = true
            }
            isLoading = false
        }
    }

    func clearChat() {
        messages.removeAll()
        let hour = Calendar.current.component(.hour, from: Date())
        let greeting = hour < 12 ? "Fresh start!" : hour < 17 ? "Welcome back!" : "Glad you\u{2019}re here."
        messages.append(ChatMessage(role: .assistant, content: "\(greeting) What would you like to explore? I\u{2019}m here to walk with you through Scripture, prayer, or anything on your heart."))
        errorMessage = nil
        showRetry = false
    }
}

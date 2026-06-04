//
//  AskPCChatView.swift
//  PC
//
//  Created by somil jain on 08/05/26.
//

#if canImport(FoundationModels)
    import FoundationModels
    import SwiftUI

    struct PCMessage: Identifiable {
        let id = UUID()
        let role: Role
        var text: String

        enum Role { case user, assistant }
    }

    @available(iOS 26.0, *)
    struct AskPCChatView: View {
        @Binding var selectedTab: String

        @State private var messages: [PCMessage] = [
            PCMessage(role: .assistant,
                      text: "Hi! I'm your PC assistant powered by Apple Intelligence. Ask me anything about competitive programming — algorithms, editorials, time complexity, or code reviews!"),
        ]
        @State private var inputText: String = ""
        @State private var isThinking = false
        @FocusState private var isInputFocused: Bool

        @State private var session: LanguageModelSession?
        @State private var unavailableReason: String?
        @State private var currentTask: Task<Void, Never>?

        var body: some View {
            NavigationStack {
                VStack(spacing: 0) {
                    headerBadge
                    if let reason = unavailableReason {
                        Text(reason)
                            .font(.system(size: 12))
                            .foregroundColor(.onSurfaceVariant)
                            .padding(.bottom, 6)
                    }
                    Divider()
                    messagesScrollView
                    Divider()
                    inputBar
                }
                .background(Color.background)
                .navigationTitle("Ask PC")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Done") { selectedTab = "home" }
                            .foregroundColor(.primaryContainer)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            messages = [messages[0]]
                            session = nil
                        } label: {
                            Image(systemName: "trash").foregroundColor(.onSurfaceVariant)
                        }
                    }
                }
            }
            .onAppear { initSession() }
        }

        private var headerBadge: some View {
            HStack(spacing: 6) {
                Image(systemName: "sparkles").font(.system(size: 11, weight: .bold))
                Text("Apple Intelligence · On-Device")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(0.5)
            }
            .foregroundColor(.primaryContainer)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(Color.primaryContainer.opacity(0.12))
            .clipShape(Capsule())
            .padding(.top, 4)
            .padding(.bottom, 8)
        }

        private var messagesScrollView: some View {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(messages) { message in
                            MessageBubble(message: message).id(message.id)
                        }
                        if isThinking { ThinkingBubble().id("thinking") }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .onChange(of: messages.count) { _ in
                    withAnimation {
                        proxy.scrollTo(messages.last?.id ?? UUID(), anchor: .bottom)
                    }
                }
                .onChange(of: isThinking) { _ in
                    withAnimation { proxy.scrollTo("thinking", anchor: .bottom) }
                }
            }
        }

        private var inputBar: some View {
            HStack(spacing: 10) {
                TextField("Ask about algorithms, editorials…", text: $inputText, axis: .vertical)
                    .lineLimit(1 ... 4)
                    .font(.system(size: 15))
                    .foregroundColor(.onSurface)
                    .focused($isInputFocused)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.surfaceContainerHigh)
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                Button {
                    isThinking ? stopGeneration() : sendMessage()
                } label: {
                    Image(systemName: isThinking ? "stop.fill" : "arrow.up")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 36, height: 36)
                        .background(
                            isThinking ? Color.red.opacity(0.85) :
                                (trimmedInput.isEmpty ? Color.surfaceContainerHigh : Color.primaryContainer)
                        )
                        .clipShape(Circle())
                }
                .disabled(trimmedInput.isEmpty && !isThinking)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.background)
        }

        private var trimmedInput: String {
            inputText.trimmingCharacters(in: .whitespaces)
        }

        private var canSendMessage: Bool {
            !isThinking && !trimmedInput.isEmpty
        }

        private func initSession() {
            switch SystemLanguageModel.default.availability {
            case .available:
                session = LanguageModelSession(instructions: """
                You are PC Assistant, an expert competitive programmer helping users \
                of the Programming Club app. You explain algorithms, data structures, \
                time/space complexity, and editorial solutions clearly and concisely. \
                Keep responses focused and formatted for mobile reading.
                """)
                unavailableReason = nil
            case .unavailable(.deviceNotEligible):
                session = nil
                unavailableReason = "This device isn't eligible for Apple Intelligence."
            case .unavailable(.appleIntelligenceNotEnabled):
                session = nil
                unavailableReason = "Apple Intelligence is turned off. Enable it in Settings."
            case let .unavailable(other):
                session = nil
                unavailableReason = "Model unavailable: \(other)"
            }
        }

        private func ensureSession() {
            if session == nil { initSession() }
        }

        private func stopGeneration() {
            currentTask?.cancel()
        }

        private func sendMessage() {
            guard canSendMessage else { return }
            let trimmed = trimmedInput
            if messages.count > 30 { session = nil }
            ensureSession()
            guard let session else { showUnavailableMessage(); return }
            appendUserMessage(trimmed)
            currentTask = Task { await generateResponse(using: session, prompt: trimmed) }
        }

        private func showUnavailableMessage() {
            messages.append(PCMessage(role: .assistant,
                                      text: unavailableReason ?? "Apple Intelligence isn't available on this device."))
            inputText = ""
            isInputFocused = false
        }

        private func appendUserMessage(_ text: String) {
            messages.append(PCMessage(role: .user, text: text))
            inputText = ""
            isInputFocused = false
            isThinking = true
        }

        private func generateResponse(using session: LanguageModelSession, prompt: String) async {
            do {
                let response = try await session.respond(to: prompt)
                await MainActor.run {
                    isThinking = false
                    messages.append(PCMessage(role: .assistant, text: response.content))
                }
            } catch is CancellationError {
                await handleCancellation()
            } catch let genError as LanguageModelSession.GenerationError {
                await handleGenerationError(genError)
            } catch {
                await handleGenericError(error)
            }
            await MainActor.run { currentTask = nil }
        }

        private func handleCancellation() async {
            await MainActor.run {
                isThinking = false
                messages.append(PCMessage(role: .assistant, text: "Generation cancelled."))
            }
        }

        private func handleGenerationError(_ error: LanguageModelSession.GenerationError) async {
            let friendly: String
            switch error {
            case .exceededContextWindowSize:
                friendly = "This conversation got too long. I'll start a fresh session."
                await MainActor.run { session = nil }
            default:
                friendly = "Generation failed. Please try again."
            }
            await MainActor.run {
                isThinking = false
                messages.append(PCMessage(role: .assistant, text: friendly))
            }
        }

        private func handleGenericError(_ error: Error) async {
            await MainActor.run {
                isThinking = false
                messages.append(PCMessage(role: .assistant,
                                          text: "Something went wrong: \(error.localizedDescription)"))
            }
        }
    }

    private struct MessageBubble: View {
        let message: PCMessage

        var isUser: Bool {
            message.role == .user
        }

        var body: some View {
            HStack(alignment: .bottom, spacing: 8) {
                if isUser { Spacer(minLength: 40) }

                if !isUser {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.primaryContainer)
                        .frame(width: 28, height: 28)
                        .background(Color.primaryContainer.opacity(0.15))
                        .clipShape(Circle())
                }

                Text(message.text)
                    .font(.system(size: 15))
                    .foregroundColor(isUser ? .black : .onSurface)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(isUser ? Color.primaryContainer : Color.surfaceContainerHigh)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)

                if isUser { Spacer().frame(width: 0) }
            }
        }
    }

    private struct ThinkingBubble: View {
        @State private var phase = 0

        var body: some View {
            HStack(alignment: .bottom, spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.primaryContainer)
                    .frame(width: 28, height: 28)
                    .background(Color.primaryContainer.opacity(0.15))
                    .clipShape(Circle())

                HStack(spacing: 5) {
                    ForEach(0 ..< 3, id: \.self) { index in
                        Circle()
                            .frame(width: 7, height: 7)
                            .foregroundColor(.onSurfaceVariant)
                            .scaleEffect(phase == index ? 1.3 : 0.8)
                            .animation(
                                .easeInOut(duration: 0.4)
                                    .repeatForever()
                                    .delay(Double(index) * 0.15),
                                value: phase
                            )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.surfaceContainerHigh)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                Spacer()
            }
            .onAppear { phase = 2 }
        }
    }

    @available(iOS 26.0, *)
    #Preview {
        AskPCChatView(selectedTab: .constant("askpc"))
    }

#endif

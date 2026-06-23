//
//  ChatViewModel.swift
//  fviu
//
//  Created by lilit on 22.06.26.
//

//
//  ChatViewModel.swift
//  fviu
//
//  Created by lilit on 22.06.26.
//
import Combine
import Foundation
import os

@MainActor
final class ChatViewModel: ObservableObject, Sendable {
    private let logger = Logger(subsystem: "com.chat", category: "ChatViewModel")

    private let fetchChatsUseCase: FetchChatsUseCase
    private let sendMessageUseCase: SendMessageUseCase
    private var chatID: String = ""

    @Published var showBottomSheet = false
    @Published var messages: [ChatMessage] = []
    @Published var isAiThinking = false
    @Published var error: String?
    @Published var chats: [DolaChatItem] = []
    @Published var isLoadingChats = false

    init(fetchChatsUseCase: FetchChatsUseCase, sendMessageUseCase: SendMessageUseCase) {
        self.fetchChatsUseCase = fetchChatsUseCase
        self.sendMessageUseCase = sendMessageUseCase
    }

    private static let isoFormatters: [DateFormatter] = {
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ss'Z'",
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
        ]
        return formats.map { format in
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            formatter.dateFormat = format
            return formatter
        }
    }()

    func initializeChat(chatID: String) {
        self.chatID = chatID
    }

    func loadChats() async {
        isLoadingChats = true
        do {
            chats = try await fetchChatsUseCase.execute()
        } catch {
            self.error = error.localizedDescription
        }
        isLoadingChats = false
    }
    
    func cleanChat(){
        messages = []
    }

    func sendMessage(_ text: String) async {
        guard !text.isEmpty else { return }
        guard !chatID.isEmpty else {
            error = "No chat ID initialized"
            return
        }

        messages.append(ChatMessage(text: text, isFromCurrentUser: true))
        isAiThinking = true
        error = nil

        do {
            let response = try await sendMessageUseCase.execute(chatID: chatID, text: text)
            messages.append(ChatMessage(text: response, isFromCurrentUser: false))
        } catch {
            self.error = error.localizedDescription
        }
        isAiThinking = false
    }

    var groupedChats: [Date: [DolaChatItem]] {
        let calendar = Calendar.current
        var grouped: [Date: [DolaChatItem]] = [:]
        for chat in chats {
            if let date = parseISO8601Date(chat.updated_at) {
                let dateOnly = calendar.startOfDay(for: date)
                grouped[dateOnly, default: []].append(chat)
            }
        }
        return grouped
    }

    func parseISO8601Date(_ dateString: String) -> Date? {
        for formatter in Self.isoFormatters {
            if let date = formatter.date(from: dateString) { return date }
        }
        return nil
    }

    func dateLabel(_ date: Date) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        if calendar.isDate(date, inSameDayAs: today) {
            return "Today"
        } else if calendar.isDate(date, inSameDayAs: yesterday) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d"
            return formatter.string(from: date)
        }
    }

    func formatTime(_ dateString: String) -> String {
        guard let date = ISO8601DateFormatter().date(from: dateString) else {
            return ""
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

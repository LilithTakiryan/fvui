//
//  ViewModel.swift
//  fviu
//
//  Created by lilit on 19.06.26.
//
import Foundation
import Combine
import os


@MainActor
final class ChatViewModel: ObservableObject, Sendable {
    private let logger = Logger(subsystem: "com.chat", category: "ViewModel")
    @Published var showBottomSheet: Bool = true

    var todayDateString: String {
        Date().formatted(date: .abbreviated, time: .omitted)
    }
    
    var customTodayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.YYYY"
        return formatter.string(from: Date())
    }
    
    @Published var messages: [ChatMessage] = []
    @Published var isAiThinking = false
    @Published var error: String?
    
    @Published var chats: [DolaChatItem] = []
    @Published var isLoadingChats = false
    
    private let networkService: ChatNetworkService
    private var chatID: String = ""
    
    init(networkService: ChatNetworkService = DolaNetworkService()) {
        self.networkService = networkService
        self.logger.info("✅ ChatViewModel initialized")
    }
    
    func initializeChat(chatID: String) {
        self.chatID = chatID
        self.logger.info("📍 Chat ID set to: \(chatID)")
    }
    
    func loadChats() async {
        isLoadingChats = true
        do {
            chats = try await networkService.fetchChats()
            self.logger.info("✅ Loaded \(self.chats.count) chats")
        } catch {
            self.error = error.localizedDescription
            self.logger.error("❌ Failed to load chats: \(error.localizedDescription)")
        }
        isLoadingChats = false
    }
    
    func sendMessage(_ text: String) async {
        guard !text.isEmpty else {
            self.logger.warning("⚠️ Empty message text")
            return
        }
        guard !chatID.isEmpty else {
            self.logger.error("❌ Chat ID is empty!")
            self.error = "No chat ID initialized"
            return
        }
        
        self.logger.info("📝 User sent: '\(text)'")
        
        let userMessage = ChatMessage(text: text, isFromCurrentUser: true)
        messages.append(userMessage)
        self.logger.info("📌 Messages count: \(self.messages.count)")
        
        isAiThinking = true
        error = nil
        
        do {
            self.logger.info("⏳ Waiting for AI response...")
            let response = try await networkService.sendMessage(text, chatID: chatID)
            
            let aiMessage = ChatMessage(text: response, isFromCurrentUser: false)
            messages.append(aiMessage)
            
            self.logger.info("✅ AI responded. Total messages: \(self.messages.count)")
        } catch {
            self.error = error.localizedDescription
            self.logger.error("❌ Error: \(error.localizedDescription)")
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
    
    // NEW: Custom date parser
     func parseISO8601Date(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        // Try different formats
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'",  // With microseconds
            "yyyy-MM-dd'T'HH:mm:ss'Z'",          // Without microseconds
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"       // With milliseconds
        ]
        
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) {
                return date
            }
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


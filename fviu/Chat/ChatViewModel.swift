//
//  ViewModel.swift
//  fviu
//
//  Created by lilit on 19.06.26.
//
import Foundation
import Observation

import Foundation
import Observation
import os

@MainActor
@Observable
final class ChatViewModel: Sendable {
    private let logger = Logger(subsystem: "com.chat", category: "ViewModel")
    
    // Existing
    var todayDateString: String {
        Date().formatted(date: .abbreviated, time: .omitted)
    }
    
    var customTodayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.YYYY"
        return formatter.string(from: Date())
    }
    
    // API Logic
    var messages: [ChatMessage] = []
    var isAiThinking = false
    var error: String?
    
    private let networkService: ChatNetworkService
    private var chatID: String = ""
    
    init(networkService: ChatNetworkService = DolaNetworkService()) {
        self.networkService = networkService
        self.logger.info(" ChatViewModel initialized")
    }
    
    func initializeChat(chatID: String) {
        self.chatID = chatID
        self.logger.info(" Chat ID set to: \(chatID)")
    }
    
    func sendMessage(_ text: String) async {
        guard !text.isEmpty else {
            self.logger.warning(" Empty message text")
            return
        }
        guard !chatID.isEmpty else {
            self.logger.error(" Chat ID is empty!")
            self.error = "No chat ID initialized"
            return
        }
        
        self.logger.info("📝 User sent: '\(text)'")
        
        // Add user message
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
            
            self.logger.info("AI responded. Total messages: \(self.messages.count)")
        } catch {
            self.error = error.localizedDescription
            self.logger.error(" Error: \(error.localizedDescription)")
        }
        
        isAiThinking = false
    }
}

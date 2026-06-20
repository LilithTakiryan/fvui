//
//  ChatNetworkService.swift
//  fviu
//
//  Created by lilit on 19.06.26.
//
import Foundation
import os

protocol ChatNetworkService: Sendable {
    func sendMessage(_ text: String, chatID: String) async throws -> String
    func fetchMessages(chatID: String) async throws -> [ChatMessage]
    func fetchChats() async throws -> [DolaChatItem] 
}

let BEARER_TOKEN = Bundle.main.object(forInfoDictionaryKey: "BearerToken") as? String ?? ""

final class DolaNetworkService: ChatNetworkService {
    private let baseURL = URL(string: "https://nebulaapps.site/dola")!
    private let bearerToken = BEARER_TOKEN
    private let userID = "test_user"
    private let appID = "com.test.test"
    private let logger = Logger(subsystem: "com.chat", category: "Network")
    
    func sendMessage(_ text: String, chatID: String) async throws -> String {
        var url = baseURL.appendingPathComponent("dola/chats/\(chatID)/messages")
        url.append(queryItems: [
            URLQueryItem(name: "user_id", value: userID),
            URLQueryItem(name: "app_id", value: appID)
        ])
        
        self.logger.info(" Sending message to \(url.absoluteString)")
        self.logger.info("Message: \(text)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(self.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String?] = [
            "message": text,
            "persona_id": nil,
            "additional_prompt": nil
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        self.logger.info(" Request body: \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "")")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            self.logger.info(" Response status: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
            self.logger.info(" Response data: \(String(data: data, encoding: .utf8) ?? "")")
            
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                self.logger.error("HTTP Error: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                throw NSError(domain: "API Error", code: -1)
            }
            
            let decoded = try JSONDecoder().decode([String: String].self, from: data)
            let reply = decoded["assistant_message"] ?? "No response"
            
            self.logger.info(" AI Reply: \(reply)")
            return reply
        } catch {
            self.logger.error("Error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func fetchChats() async throws -> [DolaChatItem] {
        var url = baseURL.appendingPathComponent("dola/chats")
        url.append(queryItems: [
            URLQueryItem(name: "user_id", value: userID),
            URLQueryItem(name: "app_id", value: appID),
            URLQueryItem(name: "limit", value: "50")
        ])
        
        self.logger.info("📋 Fetching chats list")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(self.bearerToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let jsonString = String(data: data, encoding: .utf8) {
            self.logger.info("Response: \(jsonString)")
        }
        
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            self.logger.error(" Failed to fetch chats")
            throw NSError(domain: "API Error", code: -1)
        }
        
        do {
            let chats = try JSONDecoder().decode([DolaChatItem].self, from: data)
            self.logger.info("Fetched \(chats.count) chats")
            return chats
        } catch {
            self.logger.error("Decode error: \(error.localizedDescription)")
            throw error
        }
    }
        
        func fetchMessages(chatID: String) async throws -> [ChatMessage] {
            var url = baseURL.appendingPathComponent("dola/chats/\(chatID)/messages")
            url.append(queryItems: [
                URLQueryItem(name: "user_id", value: userID),
                URLQueryItem(name: "app_id", value: appID),
                URLQueryItem(name: "limit", value: "50")
            ])
            
            self.logger.info(" Fetching messages for chat: \(chatID)")
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(self.bearerToken)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                self.logger.error(" Failed to fetch messages")
                throw NSError(domain: "API Error", code: -1)
            }
            
            let messages = try JSONDecoder().decode([DolaMessageItem].self, from: data)
            self.logger.info(" Fetched \(messages.count) messages")
            
            return messages.map { msg in
                ChatMessage(
                    text: msg.content,
                    isFromCurrentUser: msg.role == "user"
                )
            }
        }
    }

    

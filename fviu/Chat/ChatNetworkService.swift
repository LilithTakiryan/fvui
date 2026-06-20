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
}


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
        print("bearerToken: \(bearerToken)")
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
}


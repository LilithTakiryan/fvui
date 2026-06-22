//
//  ChatEndpoint.swift
//  fviu
//
//  Created by lilit on 22.06.26.
//

import Foundation
import Combine
import os

enum ChatEndpoint: Endpoint {
    case chats(limit: Int?)
    case messages(chatID: String, limit: Int?)
    case send(chatID: String, text: String)

    func makeRequest() throws -> URLRequest {
        let path: String
        switch self {
        case .chats: path = "/dola/chats"
        case .messages(let id, _), .send(let id, _):
            path = "/dola/chats/\(id)/messages"
        }

        var components = URLComponents(string: "\(API.baseURL)\(path)")!
        var queryItems = API.defaultQueryItems
        
        if let limit = extractLimit() {
            queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        components.queryItems = queryItems

        var request = URLRequest(url: components.url!)
        if case .send(_, let text) = self {
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let payload: [String: Any?] = ["message": text, "persona_id": nil, "additional_prompt": nil]
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        }
        return request
    }

    private func extractLimit() -> Int? {
        switch self {
        case .chats(let limit): return limit
        case .messages(_, let limit): return limit
        default: return nil
        }
    }
}

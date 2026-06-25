//
//  ChatEndpoint.swift
//  fviu
//
//  Created by lilit on 22.06.26.
//

import Combine
import Foundation
import os

enum ChatEndpoint: IEndpoint {
    case chats(limit: Int?)
    case messages(chatID: String, limit: Int?)
    case send(chatID: String, text: String)

    func makeRequest() throws -> URLRequest {
        let (path, httpMethod, queryItems, headers, body) = try configureEndpoint()

        var components = URLComponents(string: "\(APIconstants.baseURL)\(path)")!
        components.queryItems = APIconstants.defaultQueryItems + queryItems

        var request = URLRequest(url: components.url!)
        request.httpMethod = httpMethod

        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        request.httpBody = body

        return request
    }

    private func configureEndpoint() throws -> (path: String, method: String, queryItems: [URLQueryItem], headers: [String: String], body: Data?) {
        switch self {
        case let .chats(limit):
            var queryItems: [URLQueryItem] = []
            if let limit = limit {
                queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
            }
            return ("/dola/chats", "GET", queryItems, [:], nil)

        case let .messages(id, limit):
            var queryItems: [URLQueryItem] = []
            if let limit = limit {
                queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
            }
            return ("/dola/chats/\(id)/messages", "GET", queryItems, [:], nil)

        case let .send(id, text):
            struct Payload: Encodable {
                let message: String
                let persona_id: String?
                let additional_prompt: String?
            }
            let payload = Payload(message: text, persona_id: nil, additional_prompt: nil)
            let body = try JSONEncoder().encode(payload)
            let headers = ["Content-Type": "application/json"]
            return ("/dola/chats/\(id)/messages", "POST", [], headers, body)
        }
    }
}

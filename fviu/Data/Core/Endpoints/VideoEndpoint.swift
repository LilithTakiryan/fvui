//
//  VideoEndpoint.swift
//  fviu
//
//  Created by lilit on 22.06.26.
//

import Combine
import Foundation
import os

enum VideoEndpoint: IEndpoint {
    case generate(String)
    case status(Int)

    func makeRequest() throws -> URLRequest {
        let path: String
        switch self {
        case .generate: path = "/pixverse/api/v1/text2video"
        case .status: path = "/pixverse/api/v1/status"
        }

        var components = URLComponents(string: "\(API.baseURL)\(path)")!
        var queryItems = API.defaultQueryItems
        if case let .status(id) = self {
            queryItems.append(URLQueryItem(name: "id", value: String(id)))
        }
        components.queryItems = queryItems

        var request = URLRequest(url: components.url!)
        if case let .generate(prompt) = self {
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            let body = "prompt=\(prompt.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
            request.httpBody = body.data(using: .utf8)
        }
        return request
    }
}

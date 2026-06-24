//
//  VideoEndpoint.swift
//  fviu
//
//  Created by lilit on 22.06.26.
//

import Combine
import Foundation
import os

enum Text2VideoEndpoint: IEndpoint {
    case generate(String)
    case status(Int)

    func makeRequest() throws -> URLRequest {
        let path: String
        switch self {
        case .generate: path = "\(APIconstants.baseVideo)text2video"
        case .status: path = "\(APIconstants.baseVideo)status"
        }

        var components = URLComponents(string: "\(APIconstants.baseURL)\(path)")!
        var queryItems = APIconstants.defaultQueryItems
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

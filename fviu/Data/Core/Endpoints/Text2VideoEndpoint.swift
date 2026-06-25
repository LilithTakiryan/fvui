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
    case template

    func makeRequest() throws -> URLRequest {
        let (path, httpMethod, headers, body) = try configureEndpoint()

        var components = URLComponents(string: "\(APIconstants.baseURL)\(path)")!
        var queryItems = APIconstants.defaultQueryItems

        if case let .status(id) = self {
            queryItems.append(URLQueryItem(name: "id", value: String(id)))
        }
        components.queryItems = queryItems

        var request = URLRequest(url: components.url!)
        request.httpMethod = httpMethod
        
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        request.httpBody = body

        return request
    }

    private func configureEndpoint() throws -> (path: String, method: String, headers: [String: String], body: Data?) {
        switch self {
        case let .generate(prompt):
            let path = "\(APIconstants.baseVideo)text2video"
            let body = "prompt=\(prompt.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
                .data(using: .utf8)
            let headers = ["Content-Type": "application/x-www-form-urlencoded"]
            return (path, "POST", headers, body)

        case .status:
            let path = "\(APIconstants.baseVideo)status"
            return (path, "GET", [:], nil)
            
        case .template:
                let path = "\(APIconstants.baseVideo)get_templates/\(APIconstants.appId)"
                return (path, "GET", [:], nil)
            }
    }
}


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
    case getTemplates
    case template2video( templateId: Int, imageData: Data, duration: Int?, quality: String?)

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
            
        case .getTemplates:
            let path = "\(APIconstants.baseVideo)get_templates/\(APIconstants.appId)"
            return (path, "GET", [:], nil)
            
        case let .template2video(templateId, imageData, duration, quality):
            let allowedCharacters = CharacterSet.urlQueryAllowed
            let encodedUserId = APIconstants.TokenProvider.payment.rawValue.addingPercentEncoding(
                withAllowedCharacters: allowedCharacters
            ) ?? ""
            let encodedAppId = APIconstants.appId.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? ""
            
            let path = "\(APIconstants.baseVideo)template2video?user_id=\(encodedUserId)&app_id=\(encodedAppId)"
            
            let boundary = "Boundary-\(UUID().uuidString)"
            var body = Data()
            
            func appendTextField(named name: String, value: String) {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
                body.append("\(value)\r\n".data(using: .utf8)!)
            }
            
            appendTextField(named: "template_id", value: String(templateId))
            
            if let duration = duration {
                appendTextField(named: "duration", value: String(duration))
            }
            
            if let quality = quality {
                appendTextField(named: "quality", value: quality)
            }
            
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
            
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            
            let headers = [
                "Content-Type": "multipart/form-data; boundary=\(boundary)"
            ]
            
            return (path, "POST", headers, body)
        }
    }
}


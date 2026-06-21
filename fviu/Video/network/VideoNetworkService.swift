//
//  VideoNetworkService.swift
//  fviu
//
//  Created by lilit on 21.06.26.
//

import Foundation
import os

protocol VideoNetworkService: Sendable {
    func generateVideo(prompt: String) async throws -> Int
    func getStatus(videoID: Int) async throws -> VideoStatusResponse
}

final class PixverseNetworkService: VideoNetworkService {
    private let baseURL = URL(string: "https://nebulaapps.site/pixverse")!
    private let bearerToken: String
    private let userID = "test_user"
    private let appID = "com.test.test"
    private let logger = Logger(subsystem: "com.video", category: "Network")

    init() {
        guard let token = Bundle.main.object(forInfoDictionaryKey: "BearerToken") as? String else {
            fatalError("Bearer Token missing")
        }
        bearerToken = token
    }

    func getStatus(videoID: Int) async throws -> VideoStatusResponse {
        var url = baseURL.appendingPathComponent("api/v1/status")
        url.append(queryItems: [
            URLQueryItem(name: "id", value: String(videoID)),
            URLQueryItem(name: "user_id", value: userID),
            URLQueryItem(name: "app_id", value: appID),
        ])

        var request = URLRequest(url: url)
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        let status = try JSONDecoder().decode(VideoStatusResponse.self, from: data)

        logger.info("Status: \(status.status)")
        return status
    }

    func generateVideo(prompt: String) async throws -> Int {
        var url = baseURL.appendingPathComponent("api/v1/text2video")
        url.append(queryItems: [
            URLQueryItem(name: "user_id", value: userID),
            URLQueryItem(name: "app_id", value: appID),
        ])

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        // Build form body
        let encodedPrompt = prompt.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let body = "prompt=\(encodedPrompt)"

        request.httpBody = body.data(using: .utf8)

        logger.info("Request body: \(body)")

        let (data, response) = try await URLSession.shared.data(for: request)

        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
        logger.info("Response status: \(statusCode)")

        if let responseString = String(data: data, encoding: .utf8) {
            logger.info("Response body: \(responseString)")
        }

        guard let http = response as? HTTPURLResponse, http.statusCode == 201 else {
            logger.error("Generation failed: \(statusCode)")
            throw NSError(domain: "API Error", code: statusCode)
        }

        let decoded = try JSONDecoder().decode(Text2VideoResponse.self, from: data)
        logger.info("Video generation started: \(decoded.video_id)")
        return decoded.video_id
    }
}

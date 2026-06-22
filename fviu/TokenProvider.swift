//
//  TokenProvider.swift
//  fviu
//
//  Created by lilit on 22.06.26.
//


import Foundation
import Combine
import os

// MARK: - Core Protocols & Configuration

protocol TokenProvider {
    var token: String { get }
}

struct DefaultTokenProvider: TokenProvider {
    let token: String
}

enum NetworkError: Error {
    case invalidResponse
    case http(Int)
    case decoding
}

protocol Endpoint {
    func makeRequest() throws -> URLRequest
}

struct API {
    static let baseURL = "https://nebulaapps.site"
    static let defaultQueryItems = [
        URLQueryItem(name: "user_id", value: "test_user"),
        URLQueryItem(name: "app_id", value: "com.test.test")
    ]
    
    static var bundleToken: String {
        Bundle.main.object(forInfoDictionaryKey: "BearerToken") as? String ?? ""
    }
}

// MARK: - API Client

protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint, response: T.Type) async throws -> T
    func request(_ endpoint: Endpoint) async throws
}

final class APIClient: APIClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let tokenProvider: TokenProvider
    private let logger = Logger(subsystem: "com.app.network", category: "APIClient")

    init(session: URLSession = .shared, decoder: JSONDecoder = .init(), tokenProvider: TokenProvider) {
        self.session = session
        self.decoder = decoder
        self.tokenProvider = tokenProvider
    }

    private func performRequest(_ endpoint: Endpoint) async throws -> (Data, URLResponse) {
        var request = try endpoint.makeRequest()
        request.setValue("Bearer \(tokenProvider.token)", forHTTPHeaderField: "Authorization")

        logger.info("Sending request to: \(request.url?.absoluteString ?? "Unknown URL")")
        let (data, response) = try await session.data(for: request)
        try validate(response, data: data)
        return (data, response)
    }

    func request<T: Decodable>(_ endpoint: Endpoint, response: T.Type) async throws -> T {
        let (data, _) = try await performRequest(endpoint)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            logger.error("Decoding error: \(error.localizedDescription)")
            throw NetworkError.decoding
        }
    }

    func request(_ endpoint: Endpoint) async throws {
        _ = try await performRequest(endpoint)
    }

    private func validate(_ response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else { throw NetworkError.invalidResponse }
        guard 200...299 ~= http.statusCode else {
            logger.error("HTTP Error Status: \(http.statusCode), Response Payload: \(String(data: data, encoding: .utf8) ?? "")")
            throw NetworkError.http(http.statusCode)
        }
    }
}

// MARK: - Application Models

struct DolaChatItem: Identifiable, Decodable {
    let id: String
    let title: String?
    let persona_id: Int?
    let updated_at: String
    let last_message_preview: String?

    enum CodingKeys: String, CodingKey {
        case id = "chat_id"
        case title, persona_id, updated_at, last_message_preview
    }
}

struct DolaMessageItem: Decodable {
    let role: String
    let content: String
    let created_at: String
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isFromCurrentUser: Bool
}

struct Text2VideoResponse: Decodable {
    let video_id: Int
    let detail: String
}

struct VideoStatusResponse: Decodable {
    let video_id: Int?
    let status: String
    let video_url: String?
    let error: String?
}
// MARK: - Chat Endpoint

enum ChatEndpoint: Endpoint {
    case chats(limit: Int?)
    case messages(chatID: String, limit: Int?)
    case send(chatID: String, text: String)

    func makeRequest() throws -> URLRequest {
        let path: String
        switch self {
        case .chats:
            path = "/dola/chats"
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

// MARK: - Video Endpoint

enum VideoEndpoint: Endpoint {
    case generate(String)
    case status(Int)

    func makeRequest() throws -> URLRequest {
        let path: String
        switch self {
        case .generate: path = "/pixverse/api/v1/text2video"
        case .status:   path = "/pixverse/api/v1/status"
        }

        var components = URLComponents(string: "\(API.baseURL)\(path)")!
        var queryItems = API.defaultQueryItems
        if case .status(let id) = self {
            queryItems.append(URLQueryItem(name: "id", value: String(id)))
        }
        components.queryItems = queryItems

        var request = URLRequest(url: components.url!)
        if case .generate(let prompt) = self {
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            let body = "prompt=\(prompt.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
            request.httpBody = body.data(using: .utf8)
        }
        return request
    }
}
// MARK: - Services Refactored to delegate to APIClient

protocol ChatNetworkService: Sendable {
    func sendMessage(_ text: String, chatID: String) async throws -> String
    func fetchMessages(chatID: String) async throws -> [ChatMessage]
    func fetchChats() async throws -> [DolaChatItem]
}

final class DolaNetworkService: ChatNetworkService {
    private let api: APIClientProtocol

    init(api: APIClientProtocol = APIClient(tokenProvider: DefaultTokenProvider(token: API.bundleToken))) {
        self.api = api
    }

    func sendMessage(_ text: String, chatID: String) async throws -> String {
        let payload = try await api.request(ChatEndpoint.send(chatID: chatID, text: text), response: [String: String].self)
        return payload["assistant_message"] ?? "No response"
    }

    func fetchChats() async throws -> [DolaChatItem] {
        try await api.request(ChatEndpoint.chats(limit: 50), response: [DolaChatItem].self)
    }

    func fetchMessages(chatID: String) async throws -> [ChatMessage] {
        let items = try await api.request(ChatEndpoint.messages(chatID: chatID, limit: 50), response: [DolaMessageItem].self)
        return items.map { ChatMessage(text: $0.content, isFromCurrentUser: $0.role == "user") }
    }
}

protocol VideoNetworkService: Sendable {
    func generateVideo(prompt: String) async throws -> Int
    func getStatus(videoID: Int) async throws -> VideoStatusResponse
}

final class PixverseNetworkService: VideoNetworkService {
    private let api: APIClientProtocol

    init(api: APIClientProtocol = APIClient(tokenProvider: DefaultTokenProvider(token: API.bundleToken))) {
        self.api = api
    }

    func getStatus(videoID: Int) async throws -> VideoStatusResponse {
        try await api.request(VideoEndpoint.status(videoID), response: VideoStatusResponse.self)
    }

    func generateVideo(prompt: String) async throws -> Int {
        let result = try await api.request(VideoEndpoint.generate(prompt), response: Text2VideoResponse.self)
        return result.video_id
    }
}

// MARK: - Clean Domain Data Mapping

protocol ChatRepository {
    func chats() async throws -> [DolaChatItem]
    func messages(chatID: String) async throws -> [ChatMessage]
    func send(chatID: String, text: String) async throws -> String
}

final class ChatRepositoryImpl: ChatRepository {
    private let service: ChatNetworkService
    init(service: ChatNetworkService) { self.service = service }

    func chats() async throws -> [DolaChatItem] { try await service.fetchChats() }
    func messages(chatID: String) async throws -> [ChatMessage] { try await service.fetchMessages(chatID: chatID) }
    func send(chatID: String, text: String) async throws -> String { try await service.sendMessage(text, chatID: chatID) }
}

protocol VideoRepository {
    func generate(prompt: String) async throws -> Int
    func status(id: Int) async throws -> VideoStatusResponse
}

final class VideoRepositoryImpl: VideoRepository {
    private let service: VideoNetworkService
    init(service: VideoNetworkService) { self.service = service }

    func generate(prompt: String) async throws -> Int { try await service.generateVideo(prompt: prompt) }
    func status(id: Int) async throws -> VideoStatusResponse { try await service.getStatus(videoID: id) }
}
// MARK: - Chat View Model

@MainActor
final class ChatViewModel: ObservableObject, Sendable {
    private let logger = Logger(subsystem: "com.chat", category: "ViewModel")
    private let networkService: ChatNetworkService
    private var chatID: String = ""

    @Published var showBottomSheet = false
    @Published var messages: [ChatMessage] = []
    @Published var isAiThinking = false
    @Published var error: String?
    @Published var chats: [DolaChatItem] = []
    @Published var isLoadingChats = false

    // Avoid expensive layout / loop allocations by reusing static formatters
    private static let isoFormatters: [DateFormatter] = {
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ss'Z'",
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        ]
        return formats.map { format in
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            formatter.dateFormat = format
            return formatter
        }
    }()

    init(networkService: ChatNetworkService = DolaNetworkService()) {
        self.networkService = networkService
        logger.info("✅ ChatViewModel initialized")
    }

    func initializeChat(chatID: String) {
        self.chatID = chatID
    }

    func loadChats() async {
        isLoadingChats = true
        do {
            chats = try await networkService.fetchChats()
        } catch {
            self.error = error.localizedDescription
        }
        isLoadingChats = false
    }

    func sendMessage(_ text: String) async {
        guard !text.isEmpty else { return }
        guard !chatID.isEmpty else {
            error = "No chat ID initialized"
            return
        }

        messages.append(ChatMessage(text: text, isFromCurrentUser: true))
        isAiThinking = true
        error = nil

        do {
            let response = try await networkService.sendMessage(text, chatID: chatID)
            messages.append(ChatMessage(text: response, isFromCurrentUser: false))
        } catch {
            self.error = error.localizedDescription
        }
        isAiThinking = false
    }

    var groupedChats: [Date: [DolaChatItem]] {
        let calendar = Calendar.current
        var grouped: [Date: [DolaChatItem]] = [:]
        for chat in chats {
            if let date = parseISO8601Date(chat.updated_at) {
                let dateOnly = calendar.startOfDay(for: date)
                grouped[dateOnly, default: []].append(chat)
            }
        }
        return grouped
    }

    func parseISO8601Date(_ dateString: String) -> Date? {
        for formatter in Self.isoFormatters {
            if let date = formatter.date(from: dateString) { return date }
        }
        return nil
    }

    func dateLabel(_ date: Date) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        if calendar.isDate(date, inSameDayAs: today) {
            return "Today"
        } else if calendar.isDate(date, inSameDayAs: yesterday) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d"
            return formatter.string(from: date)
        }
    }
}

// MARK: - Video View Model

import AVKit

@MainActor
final class VideoViewModel: ObservableObject {
    private let networkService: VideoNetworkService

    @Published var prompt = ""
    @Published var videoID = 0
    @Published var status: VideoStatusResponse?
    @Published var error: String?
    @Published var isGenerating = false
    @Published var progress: Double = 0
    @Published var isDownloading = false
    @Published var localVideoURL: URL?
    @Published var player: AVPlayer?

    init(networkService: VideoNetworkService = PixverseNetworkService()) {
        self.networkService = networkService
    }

    func generateVideo(prompt: String) async {
        guard !prompt.isEmpty else { return }
        self.prompt = prompt
        isGenerating = true
        error = nil
        progress = 0

        do {
            videoID = try await networkService.generateVideo(prompt: prompt)
            await pollStatus()
        } catch {
            self.error = error.localizedDescription
            isGenerating = false
        }
    }

    private func pollStatus() async {
        var attempts = 0
        let maxAttempts = 120

        while attempts < maxAttempts, isGenerating {
            do {
                let response = try await networkService.getStatus(videoID: videoID)
                status = response
                
                switch response.status.lowercased() {
                case "completed":
                    progress = 1.0
                    isGenerating = false
                    if let urlString = response.video_url, let url = URL(string: urlString) {
                        player = AVPlayer(url: url)
                    }
                    return
                case "failed":
                    error = response.error ?? "Generation failed"
                    isGenerating = false
                    return
                case "processing": progress = 0.7
                case "pending":    progress = 0.3
                default:           progress = 0.3
                }

                if Task.isCancelled { isGenerating = false; return }
                try await Task.sleep(nanoseconds: 1_000_000_000)
                attempts += 1
            } catch {
                if Task.isCancelled { isGenerating = false; return }
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                attempts += 1
            }
        }
        if attempts >= maxAttempts {
            error = "Timeout"
            isGenerating = false
        }
    }

    func downloadVideo() async {
        guard let remoteURL = status?.video_url else {
            error = "No video URL available"
            return
        }
        isDownloading = true
        error = nil

        do {
            guard let url = URL(string: remoteURL) else { throw NetworkError.invalidResponse }
            let (tempFileURL, response) = try await URLSession.shared.download(from: url)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { throw NetworkError.invalidResponse }

            let fileManager = FileManager.default
            let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let savedURL = documentsPath.appendingPathComponent("video_\(Int(Date().timeIntervalSince1970)).mp4")

            try fileManager.moveItem(at: tempFileURL, to: savedURL)
            localVideoURL = savedURL
            isDownloading = false
        } catch {
            self.error = "Download failed: \(error.localizedDescription)"
            isDownloading = false
        }
    }
}

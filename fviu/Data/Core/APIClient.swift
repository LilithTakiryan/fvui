//
//  Api.swift
//  fviu
//
//  Created by lilit on 22.06.26.
//

import Combine
import Foundation
import os

final class APIClient: IAPIClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let tokenProvider: API.TokenProvider
    private let logger = Logger(subsystem: "com.app.network", category: "APIClient")

    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = .init(),
        tokenProvider: API.TokenProvider = .bearer
    ) {
        self.session = session
        self.decoder = decoder
        self.tokenProvider = tokenProvider
    }

    private func performRequest(_ endpoint: IEndpoint) async throws -> (Data, URLResponse) {
        var request = try endpoint.makeRequest()

        request.setValue("Bearer \(tokenProvider.value)", forHTTPHeaderField: "Authorization")

        logger.info("Sending request to: \(request.url?.absoluteString ?? "Unknown URL")")
        let (data, response) = try await session.data(for: request)
        try validate(response, data: data)
        return (data, response)
    }

    func request<T: Decodable>(_ endpoint: IEndpoint, response _: T.Type) async throws -> T {
        let (data, _) = try await performRequest(endpoint)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            logger.error("Decoding error: \(error.localizedDescription)")
            throw NetworkError.decoding
        }
    }

    func request(_ endpoint: IEndpoint) async throws {
        _ = try await performRequest(endpoint)
    }

    private func validate(_ response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else { throw NetworkError.invalidResponse }
        guard 200 ... 299 ~= http.statusCode else {
            logger.error("HTTP Error Status: \(http.statusCode), Response Payload: \(String(data: data, encoding: .utf8) ?? "")")
            throw NetworkError.http(http.statusCode)
        }
    }
}

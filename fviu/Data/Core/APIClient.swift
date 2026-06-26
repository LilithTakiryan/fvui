//
//  Api.swift
//  fviu
//
//  Created by lilit on 22.06.26.
//

import Combine
import Foundation
import os

protocol IAPIClient {
    func request<T: Decodable>(_ endpoint: IEndpoint, response: T.Type) async throws -> T
}

final class APIClient: IAPIClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let tokenProvider: APIconstants.TokenProvider
    private let logger = Logger(subsystem: "com.app.network", category: "APIClient")

    init(
            session: URLSession = .shared,
            decoder: JSONDecoder = .init(),
            tokenProvider: APIconstants.TokenProvider = .bearer
        ) {
            self.session = session
            self.tokenProvider = tokenProvider
            
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            self.decoder = decoder
        }

    func request<T: Decodable>(_ endpoint: IEndpoint, response: T.Type) async throws -> T {
        let request = try prepareRequest(endpoint)
        let (data, _) = try await session.data(for: request)
        print(String(data: data, encoding: .utf8)!)
        return try decodeResponse(data, as: T.self)
    }

    private func prepareRequest(_ endpoint: IEndpoint) throws -> URLRequest {
        var request = try endpoint.makeRequest()
        request.setValue("Bearer \(tokenProvider.value)", forHTTPHeaderField: "Authorization")
        logger.info("Sending request to: \(request.url?.absoluteString ?? "Unknown URL")")
        return request
    }

    private func decodeResponse<T: Decodable>(_ data: Data, as type: T.Type) throws -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            logger.error("Decoding error: \(error.localizedDescription)")
            print(error)
            throw NetworkError.decoding
        }
    }

    private func validate(_ response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else { throw NetworkError.invalidResponse }
        guard 200 ... 299 ~= http.statusCode else {
            logger.error("HTTP Error Status: \(http.statusCode), Response Payload: \(String(data: data, encoding: .utf8) ?? "")")
            throw NetworkError.http(http.statusCode)
        }
    }
}



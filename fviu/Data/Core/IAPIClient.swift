//
//  IAPIClient.swift
//  fviu
//
//  Created by lilit on 24.06.26.
//

protocol IAPIClient {
    func request<T: Decodable>(_ endpoint: IEndpoint, response: T.Type) async throws -> T
    func request(_ endpoint: IEndpoint) async throws
}

//
//  NetworkError.swift
//  fviu
//
//  Created by lilit on 22.06.26.
//

enum NetworkError: Error {
    case invalidResponse
    case http(Int)
    case decoding
}

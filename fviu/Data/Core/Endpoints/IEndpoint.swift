//
//  IEndpoint.swift
//  fviu
//
//  Created by lilit on 24.06.26.
//
import Foundation

protocol IEndpoint {
    func makeRequest() throws -> URLRequest
}

//
//  API.swift
//  fviu
//
//  Created by lilit on 24.06.26.
//
import Foundation

enum API {
    static let baseURL = "https://nebulaapps.site"
    static let defaultQueryItems = [
        URLQueryItem(name: "user_id", value: "test_user"),
        URLQueryItem(name: "app_id", value: "com.test.test"),
    ]

    enum TokenProvider: String {
        case bearer = "BearerToken"
        case payment = "PaymentToken"

        var value: String {
            Bundle.main.object(forInfoDictionaryKey: rawValue) as? String ?? ""
        }
    }
}

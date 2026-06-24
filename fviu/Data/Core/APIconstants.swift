//
//  API.swift
//  fviu
//
//  Created by lilit on 24.06.26.
//
import Foundation

enum APIconstants {
    static let baseURL = "https://nebulaapps.site"
    static let appId = "com.test.test"
    static let baseVideo = "/pixverse/api/v1/"
    static let defaultQueryItems = [
        URLQueryItem(name: "user_id", value: APIconstants.TokenProvider.payment.value),
        URLQueryItem(name: "app_id", value: appId),
    ]

    enum TokenProvider: String {
        case bearer = "BearerToken"
        case payment = "PaymentToken"

        var value: String {
            Bundle.main.object(forInfoDictionaryKey: rawValue) as? String ?? ""
        }
    }
}

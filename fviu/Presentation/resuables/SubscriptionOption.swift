//
//  SubscriptionOption.swift
//  fviu
//
//  Created by lilit on 18.06.26.
//


import SwiftUI
import Foundation
struct SubscriptionOption: Identifiable {
    let id = UUID()
    let duration: String
    let weeklyPrice: String
    let fullPrice: String
    let discountBadge: String?
}







//
//  ChatMessage.swift
//  fviu
//
//  Created by lilit on 22.06.26.
//

import Foundation

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isFromCurrentUser: Bool
}

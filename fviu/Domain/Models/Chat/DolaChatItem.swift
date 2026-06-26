//
//  DolaChatItem.swift
//  fviu
//
//  Created by lilit on 22.06.26.
//

struct DolaChatItem: Identifiable, Decodable {
    let chatId: String
    let title: String?
    let personaId: Int?
    let updatedAt: String
    let lastMessagePreview: String?
    
    var id: String { chatId }  // For Identifiable
}

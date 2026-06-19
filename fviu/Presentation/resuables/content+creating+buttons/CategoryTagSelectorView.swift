//
//  CategoryTagSelectorView.swift
//  fviu
//
//  Created by lilit on 19.06.26.
//


import SwiftUI

struct CategoryTagSelectorView: View {
    
    let categories = ["Popular", "Funny", "Sad", "Trends"]
    @State private var selectedCategory: String = "Popular"
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedCategory = category
                        }
                    }) {
                        Text(category)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(
                                Group {
                                    if selectedCategory == category {
                                       
                                        Capsule()
                                            .fill(ChatChatUIConfig.Colors.brandGradient)
                                    } else {
                                        Capsule()
                                            .fill(ChatChatUIConfig.Dropdown.buttonBackground)
                                    }
                                }
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .background(ChatChatUIConfig.Colors.backgroundDeep)
    }
}

#Preview {
    ZStack {
        ChatChatUIConfig.Colors.backgroundDeep.ignoresSafeArea()
        
        VStack {
            CategoryTagSelectorView()
        }
    }
}

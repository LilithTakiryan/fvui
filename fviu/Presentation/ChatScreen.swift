//
//  ChatScreen.swift
//  fviu
//
//  Created by lilit on 19.06.26.
//
import SwiftUI

#Preview {
    ChatScreen()
}

struct ChatScreen: View {
    @State private var viewModel = ChatViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.05, blue: 0.08)
                .ignoresSafeArea()
            
            ScrollView {
                VStack {
                  
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(Color(red: 0.11, green: 0.09, blue: 0.13), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            
            ToolbarItem(placement: .principal) {
                HStack(spacing: 12) {
                    Image(.chatIcon)
                        .resizable()
                        .frame(width: 32, height: 32)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("AI Chat")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text(viewModel.customTodayString)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
              
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ChatHistoryScreen()) {
                    Image(.history)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                }
            }
        }
    }
}


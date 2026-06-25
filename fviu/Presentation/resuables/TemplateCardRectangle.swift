//
//  TemplateCard.swift
//  fviu
//
//  Created by lilit on 25.06.26.
//
import SwiftUI
import AVKit


import AVKit
import SwiftUI

struct TemplateCardRectangle: View {
    let template: VideoTemplateResponse
    @State private var player: AVPlayer?

    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                if let player = player {
                    VideoPlayer(player: player)
                        .disabled(true)
                        .scaleEffect(2.5)
                        .frame(height: 232)
                        .clipShape(RoundedRectangle(cornerRadius: CustomConstants.CornerRadius.radius))
                } else {
                    
                    RoundedRectangle(cornerRadius: CustomConstants.CornerRadius.radius)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 232)
                }
            }
            .overlay(alignment: .bottom) {
                Text(template.name)
                    .font(CustomConstants.Typography.regular16)
                    .foregroundColor(.white)
                    .shadow(radius: 3)
                    .padding(.bottom, 12)
            }
        }
        .onAppear {
            guard let url = URL(string: template.previewSmall) else { return }
            let player = AVPlayer(url: url)
            self.player = player
            player.isMuted = true
            player.play()
            
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem,
                queue: .main
            ) { _ in
                player.seek(to: .zero)
                player.play()
            }
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
}

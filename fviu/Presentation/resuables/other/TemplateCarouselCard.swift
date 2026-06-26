//
//  TemplateCarouselCard.swift
//  fviu
//
//  Created by lilit on 26.06.26.
//
import SwiftUI
import AVKit

struct TemplateCarouselCard: View {
    let template: VideoTemplateResponse
    let isSelected: Bool
    @State private var player: AVPlayer?
    
    var body: some View {
            ZStack {
                if let player = player {
                    VideoPlayer(player: player)
                        .disabled(true)
                        .allowsHitTesting(false)
                        .scaleEffect(16/9, anchor: .center)
                        .frame(width: 331)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 331)
                        .overlay(
                            ProgressView()
                                .tint(.white)
                        )
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: CustomConstants.CornerRadius.radius))
            .overlay(
                RoundedRectangle(cornerRadius: CustomConstants.CornerRadius.radius)
                    .strokeBorder(
                        isSelected ? Color.blue : Color.clear,
                        lineWidth: 1
                    )
            )
        .contentShape(Rectangle())
        .onAppear {
            loadPreview()
        }
        .onChange(of: isSelected) { selected in
            if selected {
                player?.play()
            } else {
                player?.pause()
            }
        }
        .onChange(of: template.id) { _ in
            player?.pause()
            player = nil
            loadPreview()
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
    
    private func loadPreview() {
        Task { @MainActor in
            guard let url = URL(string: template.previewSmall) else { return }
            let asset = AVAsset(url: url)
            let playerItem = AVPlayerItem(asset: asset)
            
            self.player = AVPlayer(playerItem: playerItem)
            if isSelected {
                player?.play()
            }
        }
    }
}

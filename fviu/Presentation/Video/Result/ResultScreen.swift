//
//  ResultScreen.swift
//  fviu
//
//  Created by lilit on 23.06.26.
//

import SwiftUI
import AVKit

struct ResultScreen: View {
    let url: URL
    let prompt: String
    @State private var player: AVPlayer
    @StateObject private var viewModel = DependencyContainer.shared.makeVideoViewModel()
    @State private var showAlertVideoDownloaded = false
    @State private var cachedVideoURL: URL?
    
    
    init(url: URL, prompt: String) {
        self.url = url
        self.prompt = prompt
        _player = State(initialValue: AVPlayer(url: url))
    }
    
    var body: some View {
        VStack(spacing: 16) {
            VideoPlayer(player: player)
                .scaleEffect(1.15)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: CustomConstants.CornerRadius.radius)
                )
                .onAppear {
                    player.play()
                }
                .onDisappear {
                    player.pause()
                }
            
            HStack(spacing: 12) {
                videoActionButtons(for: url)
            }
            Spacer()
        }
        .padding(16)
        .onChange(of: viewModel.localVideoURL) { newValue in
            if newValue != nil {
                showAlertVideoDownloaded = true
            }
        }
        .overlay {
            if showAlertVideoDownloaded {
                VideoSavedAlert(
                    showAlertVideoDownloaded: showAlertVideoDownloaded
                )
            }
        }
        .overlay(alignment: .topTrailing){
            ReplaceButton(
                action: { Task {
                    await viewModel.generateVideo(prompt: viewModel.prompt)
                }
                })
            .padding(16)
        }
        .onDisappear {
            viewModel.clearCache()
        }
        
    }
    
    
    
    @ViewBuilder
    private func videoActionButtons(for url: URL) -> some View {
        HStack(spacing: 12) {
            Button(action: {
                Task { await shareVideo() }
            }) {
                Text(.buttonShare)
            }
            .buttonStyle(CustomCapsuleButtonStyle(
                background: CustomConstants.Colors.receiverBubbleBg,
                verticalPadding: CustomConstants.Sizes.mainButtonVerticalPadding + 4
            ))
            
            Button(action: {
                Task { await viewModel.downloadVideo(from: url) }
            }) {
                if viewModel.isDownloading {
                    ProgressView().tint(.white)
                } else {
                    Text(.buttonDownload)
                }
            }
            .buttonStyle(CustomCapsuleButtonStyle(
                background: CustomConstants.Colors.brandGradient,
                verticalPadding: CustomConstants.Sizes.mainButtonVerticalPadding,
                isScaled: true
            ))
            .disabled(viewModel.isDownloading)
        }
    }
    
    private func shareVideo() async {
        do {
            let fileURL = try await viewModel.getCachedVideoURL(from: url)
            
            let activityVC = UIActivityViewController(
                activityItems: [fileURL],
                applicationActivities: nil
            )
            
            activityVC.excludedActivityTypes = [
                .print,
                .assignToContact,
                .saveToCameraRoll,
                .addToReadingList
            ]
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
        } catch {
            viewModel.error = "Failed to prepare video for sharing"
        }
    }
}

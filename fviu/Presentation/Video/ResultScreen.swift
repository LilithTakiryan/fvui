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
    @State private var player: AVPlayer
    @StateObject private var viewModel = DependencyContainer.shared.makeVideoViewModel()
    @State private var showAlertVideoDownloaded = false
    @State private var cachedVideoURL: URL?

    init(url: URL) {
        self.url = url
        _player = State(initialValue: AVPlayer(url: url))
    }

    var body: some View {
        VStack(spacing: 16) {
            VideoPlayer(player: player)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            
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
            .padding(.horizontal)
            .padding(.bottom, 8)
            
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
                VStack(spacing: 12) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(CustomConstants.Colors.brandGradient)
                    
                    Text(.alertVideoSaved)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: 200)
                .padding(24)
                .background(Color.black.opacity(0.8))
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .transition(.scale.combined(with: .opacity))
                .task {
                    try? await Task.sleep(nanoseconds: 2_500_000_000)
                    withAnimation {
                        showAlertVideoDownloaded = false
                    }
                }
            }
        }
        .overlay(alignment: .topTrailing){
            ReplaceButton(action: {})
        }
        .onDisappear {
            viewModel.clearCache()
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

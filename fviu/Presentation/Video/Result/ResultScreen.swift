//
//  ResultScreen.swift
//  fviu
//
//  Created by lilit on 23.06.26.
//

import AVKit
import SwiftUI

struct ResultScreen: View {
    @ObservedObject var viewModel: VideoViewModel
    @State private var player: AVPlayer
    @State private var showAlertVideoDownloaded = false

    init(viewModel: VideoViewModel) {
        self.viewModel = viewModel
        if let url = viewModel.completedVideoURL {
            _player = State(initialValue: AVPlayer(url: url))
        } else {
            _player = State(initialValue: AVPlayer())
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            VideoPlayer(player: player)
                .scaleEffect(1.15)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(
                    RoundedRectangle(cornerRadius: CustomConstants.CornerRadius.radius)
                )
                .onAppear {
                    player.play()
                }
                .onDisappear {
                    player.pause()
                }

            HStack(spacing: 12) {
                if let url = viewModel.completedVideoURL {
                    videoActionButtons(for: url)
                }
            }
            Spacer()
        }
        .padding(16)
        .navigationTitle("Result")
        .onChange(of: viewModel.localVideoURL) { newValue in
            if newValue != nil {
                showAlertVideoDownloaded = true
            }
        }
        .onChange(of: viewModel.localVideoURL) { newValue in
            if newValue != nil {
                withAnimation {
                    showAlertVideoDownloaded = true
                }

                Task {
                    try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                    withAnimation {
                        showAlertVideoDownloaded = false
                    }
                }
            }
        }
        .overlay(alignment: .topTrailing) {
            ReplaceButton(action: {
                Task {
                    await viewModel.generateVideo(prompt: viewModel.prompt)
                }
            })
            .padding(16)
        }
        .onDisappear {
            viewModel.clearCache()
        }
    }

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
        guard let url = viewModel.completedVideoURL else { return }
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
                .addToReadingList,
            ]

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController
            {
                rootVC.present(activityVC, animated: true)
            }
        } catch {
            viewModel.error = "Failed to prepare video for sharing"
        }
    }
}

//
//  VideoGeneratorScreen.swift
//  fviu
//
//  Created by lilit on 21.06.26.
//

import AVFoundation
import AVKit
import Photos
import SwiftUI

#Preview {
    VideoGeneratorScreen()
}

struct VideoGeneratorScreen: View {
    @StateObject private var viewModel = VideoViewModel()
    @State private var inputText = ""
    @State private var showPermissionAlert = false
    @Environment(\.dismiss) var dismiss
    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 16) {
                if viewModel.isGenerating {
                    GeneratingView()
                } else if let status = viewModel.status,
                          status.status.lowercased() == "completed",
                          let urlString = status.video_url,
                          let url = URL(string: urlString)
                {
                    VStack(spacing: 16) {
                        VideoPlayer(player: AVPlayer(url: url))
                            .frame(height: 300)
                            .cornerRadius(12)

                        HStack(spacing: 12) {
                            Button(action: {
                                if let urlString = viewModel.status?.video_url, let videoURL = URL(string: urlString) {
                                    shareVideo(url: videoURL)
                                }
                            }) {
                                Text("Share")
                            }
                            .buttonStyle(CustomCapsuleButtonStyle(
                                background: ChatChatUIConfig.Colors.receiverBubbleBg,
                                verticalPadding: ChatChatUIConfig.Sizes.mainButtonVerticalPadding + 4
                            ))

                            Button(action: {
                                Task {
                                    await viewModel.downloadVideo()
                                }
                            }) {
                                if viewModel.isDownloading {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .tint(.white)
                                } else {
                                    Text("Download")
                                }
                            }
                            .buttonStyle(CustomCapsuleButtonStyle(
                                background: ChatChatUIConfig.Colors.brandGradient,
                                verticalPadding: ChatChatUIConfig.Sizes.mainButtonVerticalPadding,
                                isScaled: true
                            ))
                            .disabled(viewModel.isDownloading)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)

                        if viewModel.localVideoURL != nil {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Saved to Files")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                            .padding(12)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                        }

                        Spacer()
                    }
                    .padding(16)
                } else {
                    VStack(spacing: 16) {
                        Text("Create AI Video")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        TextEditor(text: $inputText)
                            .frame(minHeight: 120)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .foregroundColor(.white)
                            .cornerRadius(8)

                        if let error = viewModel.error {
                            HStack {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.red)
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                            .padding(12)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                        }

                        Button(action: {
                            Task { await checkPhotoPermission() }
                        }) {
                            Text("Generate Video")
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .disabled(inputText.isEmpty || viewModel.isGenerating)

                        Spacer()
                    }
                    .padding(16)
                }
            }
        }
        .navigationTitle("Result")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Photo Access Required", isPresented: $showPermissionAlert) {
            Button("Open Settings", action: openCurrentAppSettings)
            Button("Cancel", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("Enable photo access in Settings to create videos")
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                checkPhotoPermissionOnReturn()
            }
        }
    }

    private func checkPhotoPermission() async {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)

        switch status {
        case .authorized, .limited:
            await viewModel.generateVideo(prompt: inputText)
        case .denied, .restricted:
            showPermissionAlert = true
        case .notDetermined:
            await requestPhotoPermission()
        @unknown default:
            await viewModel.generateVideo(prompt: inputText)
        }
    }

    private func requestPhotoPermission() async {
        let newStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)

        if newStatus == .authorized || newStatus == .limited {
            await viewModel.generateVideo(prompt: inputText)
        } else {
            showPermissionAlert = true
        }
    }

    private func checkPhotoPermissionOnReturn() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if status == .authorized || status == .limited {
            Task { await viewModel.generateVideo(prompt: inputText) }
            showPermissionAlert = false
        }
    }

    private func shareVideo(url: URL) {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController
        else {
            return
        }

        rootViewController.present(activityVC, animated: true)
    }

    private func openCurrentAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
        }
    }
}

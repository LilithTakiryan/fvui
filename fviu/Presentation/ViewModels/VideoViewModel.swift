//
//  VideoViewModel.swift
//  fviu
//
//  Created by lilit on 22.06.26.
//


//
//  VideoViewModel.swift
//  fviu
//
//  Created by lilit on 22.06.26.
//

import Combine
import AVKit
import os

@MainActor
final class VideoViewModel: ObservableObject {
    private let generateVideoUseCase: GenerateVideoUseCase
    private let getVideoStatusUseCase: GetVideoStatusUseCase

    @Published var prompt = ""
    @Published var videoID = 0
    @Published var status: VideoStatusResponse?
    @Published var error: String?
    @Published var isGenerating = false
    @Published var progress: Double = 0
    @Published var isDownloading = false
    @Published var localVideoURL: URL?
    @Published var player: AVPlayer?

    init(generateVideoUseCase: GenerateVideoUseCase, getVideoStatusUseCase: GetVideoStatusUseCase) {
            self.generateVideoUseCase = generateVideoUseCase
            self.getVideoStatusUseCase = getVideoStatusUseCase
        }

    func generateVideo(prompt: String) async {
        guard !prompt.isEmpty else { return }
        self.prompt = prompt
        isGenerating = true
        error = nil
        progress = 0

        do {
            videoID = try await generateVideoUseCase.execute(prompt: prompt)
            await pollStatus()
        } catch {
            self.error = error.localizedDescription
            isGenerating = false
        }
    }

    private func pollStatus() async {
        var attempts = 0
        let maxAttempts = 120

        while attempts < maxAttempts, isGenerating {
            do {
                let response = try await getVideoStatusUseCase.execute(id: videoID)
                status = response
                
                switch response.status.lowercased() {
                case "completed":
                    progress = 1.0
                    isGenerating = false
                    if let urlString = response.video_url, let url = URL(string: urlString) {
                        player = AVPlayer(url: url)
                    }
                    return
                case "failed":
                    error = response.error ?? "Generation failed"
                    isGenerating = false
                    return
                case "processing": progress = 0.7
                case "pending":    progress = 0.3
                default:           progress = 0.3
                }

                if Task.isCancelled { isGenerating = false; return }
                try await Task.sleep(nanoseconds: 1_000_000_000)
                attempts += 1
            } catch {
                if Task.isCancelled { isGenerating = false; return }
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                attempts += 1
            }
        }
        if attempts >= maxAttempts {
            error = "Timeout"
            isGenerating = false
        }
    }

    func downloadVideo() async {
        guard let remoteURL = status?.video_url else {
            error = "No video URL available"
            return
        }
        isDownloading = true
        error = nil

        do {
            guard let url = URL(string: remoteURL) else { throw NetworkError.invalidResponse }
            let (tempFileURL, response) = try await URLSession.shared.download(from: url)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { throw NetworkError.invalidResponse }

            let fileManager = FileManager.default
            let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let savedURL = documentsPath.appendingPathComponent("video_\(Int(Date().timeIntervalSince1970)).mp4")

            try fileManager.moveItem(at: tempFileURL, to: savedURL)
            localVideoURL = savedURL
            isDownloading = false
        } catch {
            self.error = "Download failed: \(error.localizedDescription)"
            isDownloading = false
        }
    }
}

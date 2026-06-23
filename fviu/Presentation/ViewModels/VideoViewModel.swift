//
//  VideoViewModel.swift
//  fviu
//
//  Created by lilit on 23.06.26.
//


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

import AVKit
import Combine
import os
import Photos

@MainActor
final class VideoViewModel: ObservableObject {
    private let generateVideoUseCase: GenerateVideoUseCase
    private let getVideoStatusUseCase: GetVideoStatusUseCase
    private let logger = Logger(subsystem: "com.video", category: "VideoViewModel")

    @Published var prompt = ""
    @Published var videoID = 0
    @Published var status: VideoStatusResponse?
    @Published var error: String?
    @Published var isGenerating = false
    @Published var progress: Double = 0
    @Published var isDownloading = false
    @Published var localVideoURL: URL?
    @Published var player: AVPlayer?
    @Published var shouldShowGenerating = false


    init(generateVideoUseCase: GenerateVideoUseCase, getVideoStatusUseCase: GetVideoStatusUseCase) {
        self.generateVideoUseCase = generateVideoUseCase
        self.getVideoStatusUseCase = getVideoStatusUseCase
    }

    func generateVideo(prompt: String) async {
        guard !prompt.isEmpty else { return }
        self.prompt = prompt
        isGenerating = true
        shouldShowGenerating = true 
        error = nil
        progress = 0
        status = nil
        
        try? await Task.sleep(nanoseconds: 100_000_000)
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
                    shouldShowGenerating = false
                    if let urlString = response.video_url, let url = URL(string: urlString) {
                        player = AVPlayer(url: url)
                    }
                    return
                case "failed":
                    error = response.error ?? "Generation failed"
                    isGenerating = false
                    return
                case "processing": progress = 0.7
                case "pending": progress = 0.3
                default: progress = 0.3
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


    func downloadVideo(from remoteURL: URL) async {
        isDownloading = true
        error = nil
        
        do {
            let (tempFileURL, response) = try await URLSession.shared.download(from: remoteURL)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                throw NetworkError.invalidResponse
            }

            let fileManager = FileManager.default
            let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let savedURL = documentsPath.appendingPathComponent("video_\(Int(Date().timeIntervalSince1970)).mp4")
            
            try fileManager.copyItem(at: tempFileURL, to: savedURL)
            
            let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            guard status == .authorized || status == .limited else {
                error = "Photo library permission required"
                isDownloading = false
                return
            }

            try await PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: savedURL)
            }
            
            localVideoURL = savedURL
            isDownloading = false
            logger.debug("saved video to Photos: \(savedURL.path)")
        } catch {
            self.error = "Download failed: \(error.localizedDescription)"
            logger.error("Failed to download video: \(error.localizedDescription)")
            isDownloading = false
        }
    }
    func getCachedVideoURL(from remoteURL: URL) async throws -> URL {
        let fileManager = FileManager.default
        let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let cachedURL = cacheDir.appendingPathComponent("video_cache.mp4")
        
        if fileManager.fileExists(atPath: cachedURL.path) {
            return cachedURL
        }
        
        let (tempFileURL, response) = try await URLSession.shared.download(from: remoteURL)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        try fileManager.moveItem(at: tempFileURL, to: cachedURL)
        
        try fileManager.setAttributes([.protectionKey: FileProtectionType.none], ofItemAtPath: cachedURL.path)
        
        logger.debug("cached video to: \(cachedURL.path)")
        return cachedURL
    }
    func clearCache() {
        let fileManager = FileManager.default
        let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let cachedURL = cacheDir.appendingPathComponent("video_cache.mp4")
        
        try? fileManager.removeItem(at: cachedURL)
        logger.debug("cleared cache")
    }
}

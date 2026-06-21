//
//  VideoViewModel.swift
//  fviu
//
//  Created by lilit on 21.06.26.
//


import Foundation
import Combine
import os
import AVKit
import AVFoundation

@MainActor
final class VideoViewModel: ObservableObject { 
    private let networkService: VideoNetworkService
    
    @Published var prompt: String = ""
    @Published var videoID: Int = 0
    @Published var status: VideoStatusResponse?
    @Published var error: String?
    
    @Published var isGenerating = false
    @Published var progress: Double = 0
    @Published var isDownloading = false
    @Published var localVideoURL: URL?
    @Published var player: AVPlayer?
    
    init(networkService: VideoNetworkService = PixverseNetworkService()) {
        self.networkService = networkService
    }
    
    func reset() {
        prompt = ""
        videoID = 0
        status = nil
        error = nil
        isGenerating = false
        progress = 0
        isDownloading = false
        localVideoURL = nil
    }
    private func pollStatus() async {
            var attempts = 0
            let maxAttempts = 120
            
            while attempts < maxAttempts && isGenerating {
                do {
                    let response = try await networkService.getStatus(videoID: videoID)
                    status = response
                    
                    switch response.status.lowercased() {
                    case "completed":
                        progress = 1.0
                        isGenerating = false
                        print(" Video ready: \(response.video_url ?? "no URL")")
                
                        if let urlString = response.video_url, let url = URL(
                            string: urlString
                        )
                        {
                            self.player = AVPlayer(url: url)
                        }
                        return
                        
                    case "failed":
                        error = response.error ?? "Generation failed"
                        isGenerating = false
                        return
                        
                    case "processing":
                        progress = 0.7
                    case "pending":
                        progress = 0.3
                    default:
                        progress = 0.3
                    }
                    
                    if Task.isCancelled { isGenerating = false; return }
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                    attempts += 1
                    
                } catch {
                    print(" Polling failed on attempt \(attempts): \(error)")
                    
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

    func generateVideo(prompt: String) async {
        guard !prompt.isEmpty else {
            print("Empty prompt")
            return
        }
        
        self.prompt = prompt
        isGenerating = true
        error = nil
        progress = 0
        
        do {
            print(" Generating: \(prompt)")
            videoID = try await networkService.generateVideo(prompt: prompt)
            
            await pollStatus()
        } catch {
            self.error = error.localizedDescription
            print("Error: \(error.localizedDescription)")
            isGenerating = false
        }
    }
    
    
    func downloadVideo() async {
        guard let remoteURL = status?.video_url else {
            self.error = "No video URL available"
            return
        }
        
        isDownloading = true
        error = nil
        
        do {
            guard let url = URL(string: remoteURL) else {
                throw NSError(domain: "Invalid URL", code: -1)
            }
            
            let (tempFileURL, response) = try await URLSession.shared.download(from: url)
            
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                throw NSError(domain: "Download failed", code: -1)
            }
            
            let fileManager = FileManager.default
            let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = "video_\(Int(Date().timeIntervalSince1970)).mp4"
            let savedURL = documentsPath.appendingPathComponent(fileName)
            
            try fileManager.moveItem(at: tempFileURL, to: savedURL)
            
            self.localVideoURL = savedURL
            print(" Video saved: \(savedURL.path)")
            isDownloading = false
            
        } catch {
            self.error = "Download failed: \(error.localizedDescription)"
            print(error)
            isDownloading = false
        }
    }

    
}

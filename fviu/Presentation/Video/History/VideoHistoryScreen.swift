//
//  VideoHistoryScreen.swift
//  fviu
//
//  Created by lilit on 23.06.26.
//

import AVKit
import SwiftUI

struct VideoHistoryScreen: View {
    @StateObject private var viewModel = DependencyContainer.shared.makeVideoViewModel()
    @State private var selectedVideoURL: URL?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else if viewModel.savedVideos.isEmpty {
                NoContentYet(icon: .image, title: "No videos yet", description: "Create your first video to see it here")
            } else {
                historyGridView
            }
        }
        .navigationTitle("AI Video History")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchSavedVideos()
        }
        .sheet(item: Binding(
            get: { selectedVideoURL.map { IdentifiableURL(url: $0) } },
            set: { selectedVideoURL = $0?.url }
        )) { item in
            VideoPlayerPresentationView(url: item.url)
        }
    }

    private var historyGridView: some View {
        ScrollView {
            HStack(alignment: .top, spacing: 12) {
                VStack(spacing: 12) {
                    ForEach(Array(leftColumnItems.enumerated()), id: \.element.id) { index, item in
                        gridCell(for: item, height: getHeight(for: index, isLeft: true))
                    }
                }

                VStack(spacing: 12) {
                    ForEach(Array(rightColumnItems.enumerated()), id: \.element.id) { index, item in
                        gridCell(for: item, height: getHeight(for: index, isLeft: false))
                    }
                }
            }
            .padding(16)
        }
    }

    private var leftColumnItems: [VideoHistoryItem] {
        viewModel.savedVideos.enumerated().filter { $0.offset % 2 == 0 }.map { $0.element }
    }

    private var rightColumnItems: [VideoHistoryItem] {
        viewModel.savedVideos.enumerated().filter { $0.offset % 2 != 0 }.map { $0.element }
    }

    private func getHeight(for index: Int, isLeft _: some Any) -> CGFloat {
        if index % 2 == 0 {
            return 260
        } else {
            return 180
        }
    }

    private func gridCell(for item: VideoHistoryItem, height: CGFloat) -> some View {
        Button(action: { selectedVideoURL = item.url }) {
            ZStack {
                if let thumbnail = item.thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: height)
                        .clipped()
                } else {
                    Color(.systemGray6)
                        .frame(height: height)
                    Image(systemName: "play.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
    }
}

struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}

struct VideoPlayerPresentationView: View {
    let url: URL
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VideoPlayer(player: AVPlayer(url: url))
                .ignoresSafeArea()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

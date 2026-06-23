//
//  DependencyContainer.swift
//  fviu
//
//  Created by lilit on 22.06.26.
//

import Foundation

final class DependencyContainer: Sendable {
    static let shared = DependencyContainer()
    private var cachedVideoViewModel: VideoViewModel?
    private var cachedChatViewModel: ChatViewModel?

    let apiClient = APIClient()

    private init() {}

    @MainActor
    func makeChatViewModel() -> ChatViewModel {
        if let existing = cachedChatViewModel {
            return existing
        }
        
        let service = DolaNetworkService(api: apiClient)
        let repository = ChatRepositoryImpl(service: service)
        
        let viewModel = ChatViewModel(
            fetchChatsUseCase: FetchChatsUseCase(repo: repository),
            sendMessageUseCase: SendMessageUseCase(repo: repository)
        )
        
        self.cachedChatViewModel = viewModel
        return viewModel
    }


    @MainActor
    func makeVideoViewModel() -> VideoViewModel {
        if let existing = cachedVideoViewModel {
            return existing
        }
        
        let service = PixverseNetworkService(api: apiClient)
        let repository = VideoRepositoryImpl(service: service)
        
        let viewModel = VideoViewModel(
            generateVideoUseCase: GenerateVideoUseCase(repo: repository),
            getVideoStatusUseCase: GetVideoStatusUseCase(repo: repository)
        )
        
        self.cachedVideoViewModel = viewModel
        return viewModel
    }
}

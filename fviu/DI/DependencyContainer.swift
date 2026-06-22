//
//  DependencyContainer.swift
//  fviu
//
//  Created by lilit on 22.06.26.
//


import Foundation


final class DependencyContainer: Sendable {
    static let shared = DependencyContainer()
    let apiClient = APIClient()

    private init() {}
    
    @MainActor
    func makeChatViewModel() -> ChatViewModel {
        let service = DolaNetworkService(api: apiClient)
        let repository = ChatRepositoryImpl(service: service)
        
        return ChatViewModel(
            fetchChatsUseCase: FetchChatsUseCase(repo: repository),
            sendMessageUseCase: SendMessageUseCase(repo: repository)
        )
    }
    
    @MainActor
    func makeVideoViewModel() -> VideoViewModel {
        let service = PixverseNetworkService(api: apiClient)
        let repository = VideoRepositoryImpl(service: service)
        
        return VideoViewModel(
            generateVideoUseCase: GenerateVideoUseCase(repo: repository),
            getVideoStatusUseCase: GetVideoStatusUseCase(repo: repository)
        )
    }
}

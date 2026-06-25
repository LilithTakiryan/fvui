//
//  Template2VideoScreen.swift
//  fviu
//
//  Created by lilit on 25.06.26.
//
import PhotosUI
import SwiftUI
import AVKit

struct SelectedTemplateScreen: View {
    let selectedTemplate: VideoTemplateResponse
    @State private var ratio = "16:9"
    @State private var quality = "720p"
    @State private var imageButtonState: GradientBorderPlusButton.ButtonState = .empty
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var player: AVPlayer?

    var body: some View {
        VStack(alignment: .leading) {
            VideoPlayer(player: player)
                .disabled(true)
                .scaleEffect(2.5)
                .frame(height: 331)
                .clipShape(RoundedRectangle(cornerRadius: CustomConstants.CornerRadius.radius))
                .padding(10)
                .onAppear {
                    guard let url = URL(string: selectedTemplate.previewSmall) else { return }
                    let player = AVPlayer(url: url)
                    self.player = player
                    player.isMuted = true
                    player.play()
                    
                    NotificationCenter.default.addObserver(
                        forName: .AVPlayerItemDidPlayToEndTime,
                        object: player.currentItem,
                        queue: .main
                    ) { _ in
                        player.seek(to: .zero)
                        player.play()
                    }
                }
                .onDisappear {
                    player?.pause()
                    player = nil
                }
            
            PhotosPicker(
                selection: $selectedPhotoItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                GradientBorderPlusButton(
                    state: imageButtonState,
                    action: {},
                    onRemove: {
                        selectedPhotoItem = nil
                        imageButtonState = .empty
                    }
                )
            }
            .buttonStyle(.plain)
        
            MediaSettingsSelectorView(selectedRatio: $ratio, selectedQuality: $quality)
            Button(action: {
//                    Task { await checkPhotoPermission() }
                print("generate")
            }) {
                Text(.labelGenerateVideo)
            }
            .buttonStyle(CustomCapsuleButtonStyle(
                background: selectedPhotoItem == nil ? CustomConstants.Colors.brandGradientDisabled : CustomConstants.Colors.brandGradient,
                verticalPadding: CustomConstants.Sizes.mainButtonVerticalPadding,
                isScaled: true
            ))
            .disabled(selectedPhotoItem == nil)
        }
        .onChange(of: selectedPhotoItem) { newItem in
            guard let newItem = newItem else { return }
            
            imageButtonState = .loading
            
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    
                    await MainActor.run {
                        withAnimation(.easeInOut) {
                            imageButtonState = .filled(image: Image(uiImage: uiImage))
                        }
                    }
                } else {
                    await MainActor.run { imageButtonState = .empty }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(selectedTemplate.name)

    }
}





//struct TemplatesScreen: View {
//    @StateObject private var viewModel = DependencyContainer.shared.makeVideoViewModel()
//    @State private var showPermissionAlert = false
//    @Environment(\.dismiss) var dismiss
//    @Environment(\.scenePhase) var scenePhase
//
//
//    var body: some View {
//        VStack{
//
//        }
//        .onAppear {
//            Task {
//                await viewModel.getTemplates()
//            }
//        }
//        .toolbarBackground(Color(red: 0.11, green: 0.09, blue: 0.13), for: .navigationBar)
//        .toolbarBackground(.visible, for: .navigationBar)
//        .toolbarColorScheme(.dark, for: .navigationBar)
//        .toolbar {
//            ToolbarItem(placement: .principal) {
//                HStack(spacing: 12) {
//                    Image(.chatIcon)
//                        .resizable()
//                        .frame(width: 32, height: 32)
//
//                    VStack(alignment: .leading, spacing: 2) {
//                        Text("AI Video")
//                            .font(.system(size: 20, weight: .semibold))
//                            .foregroundColor(.white)
//                    }
//                }
//                .frame(maxWidth: .infinity, alignment: .leading)
//            }
//            ToolbarItem(placement: .navigationBarTrailing) {
//                NavigationLink(destination: VideoHistoryScreen()) {
//                    Image(.history)
//                        .resizable()
//                        .frame(width: 24, height: 24)
//                        .foregroundColor(.white)
//                }
//            }
//        }
//        .navigationBarTitleDisplayMode(.inline)
//        .navigationDestination(isPresented: $viewModel.navigateToResult) {
//            ResultScreen(viewModel: viewModel)
//        }
//        .alert(.warningPhotoAccessRequired, isPresented: $showPermissionAlert) {
//            Button(.buttonOpenSettings, action: openCurrentAppSettings)
//            Button(.buttonCancel, role: .cancel) {
//                dismiss()
//            }
//        } message: {
//            Text(.warningEnablePhotoAccess)
//        }
//        .onChange(of: scenePhase) { newPhase in
//            if newPhase == .active {
//                checkPhotoPermissionOnReturn()
//            }
//        }
//
//    }
//
//
//
//
//    private func checkPhotoPermission() async {
//        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
//
//        switch status {
//        case .authorized, .limited:
//            print("generate video todo")
////            await viewModel.generateVideo(prompt: inputText)
//        case .denied, .restricted:
//            showPermissionAlert = true
//        case .notDetermined:
//            await requestPhotoPermission()
//        @unknown default:
//            print("default case")
////            await viewModel.generateVideo(prompt: inputText)
//        }
//    }
//
//    private func requestPhotoPermission() async {
//        let newStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
//
//        if newStatus == .authorized || newStatus == .limited {
////            await viewModel.generateVideo(prompt: inputText)
//        } else {
//            showPermissionAlert = true
//        }
//    }
//
//    private func checkPhotoPermissionOnReturn() {
//        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
//        if status == .authorized || status == .limited {
////            Task { await viewModel.generateVideo(prompt: inputText) }
//            print("checkPhotoPermissionOnReturn generate video todo")
//            showPermissionAlert = false
//        }
//    }
//
//    private func openCurrentAppSettings() {
//        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
//        if UIApplication.shared.canOpenURL(settingsUrl) {
//            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
//        }
//    }
//}

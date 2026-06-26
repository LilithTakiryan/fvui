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
    @StateObject private var viewModel = DependencyContainer.shared.makeVideoViewModel()
    let initialTemplate: VideoTemplateResponse
    @State private var currentTemplate: VideoTemplateResponse
    @State private var ratio = "16:9"
    @State private var quality = "720p"
    @State private var imageButtonState: GradientBorderPlusButton.ButtonState = .empty
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var player: AVPlayer?
    @State private var playbackObserver: NSObjectProtocol?

    init(initialTemplate: VideoTemplateResponse) {
        self.initialTemplate = initialTemplate
        _currentTemplate = State(initialValue: initialTemplate)
    }

    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            ScrollViewReader { scrollProxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack() {
                        ForEach(viewModel.templates, id: \.id) { template in
                            TemplateCarouselCard(
                                template: template,
                                isSelected: template.id == currentTemplate.id
                            )
                            .id(String(template.id))
                            .onTapGesture {
                                withAnimation {
                                    currentTemplate = template
                                    scrollProxy.scrollTo(String(template.id), anchor: .center)
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(height: 331)
                }
                .onAppear {
                    scrollProxy.scrollTo(String(initialTemplate.id), anchor: .center)
                    loadPreview(for: initialTemplate)
                }
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
                Task {
                    guard let item = selectedPhotoItem,
                          let data = try? await item.loadTransferable(type: Data.self) else { return }
                    
                    let inputModel = TemplateVideoInputModel(
                        templateId: currentTemplate.id,
                        imageData: data,
                        duration: nil,
                        quality: quality
                    )
                    
                    await viewModel.template2Video(with: inputModel)
                }
            }) {
                Text(.labelGenerateVideo)
            }
            
            .buttonStyle(CustomCapsuleButtonStyle(
                background: selectedPhotoItem == nil ? CustomConstants.Colors.brandGradientDisabled : CustomConstants.Colors.brandGradient,
                verticalPadding: CustomConstants.Sizes.mainButtonVerticalPadding,
                isScaled: true
            ))
            .disabled(selectedPhotoItem == nil)
            Spacer()

        }
        .padding(.horizontal, 16)
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
        .onChange(of: currentTemplate.id) { _ in
            loadPreview(for: currentTemplate)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(currentTemplate.name)
        .onDisappear {
            cleanupPlayer()
        }
    }
    
    private func loadPreview(for template: VideoTemplateResponse) {
        cleanupPlayer()
        
        guard let url = URL(string: template.previewSmall) else { return }
        
        Task { @MainActor in
            let newPlayer = AVPlayer(url: url)
            self.player = newPlayer
            newPlayer.isMuted = true
            newPlayer.seek(to: .zero)
            newPlayer.play()
            
            let observer = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: newPlayer.currentItem,
                queue: .main
            ) { [weak newPlayer] _ in
                newPlayer?.seek(to: .zero)
                newPlayer?.play()
            }
            self.playbackObserver = observer
        }
    }
    
    private func cleanupPlayer() {
        player?.pause()
        
        if let observer = playbackObserver {
            NotificationCenter.default.removeObserver(observer)
            playbackObserver = nil
        }
        
        player = nil
    }
}


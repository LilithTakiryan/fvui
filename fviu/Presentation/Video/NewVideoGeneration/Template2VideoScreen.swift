//
//  Template2VideoScreen.swift
//  fviu
//
//  Created by lilit on 25.06.26.
//

import SwiftUI

struct Template2VideoScreen: View {
    let templateId: Int64
    
    var body: some View {
        Text("Template2VideoScreen \(templateId)")
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

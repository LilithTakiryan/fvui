//
//  VideoSavedAlert.swift
//  fviu
//
//  Created by lilit on 23.06.26.
//
import SwiftUI

#Preview {
    VideoSavedAlert(showAlertVideoDownloaded: true)
}

struct VideoSavedAlert: View {
    @State var showAlertVideoDownloaded: Bool
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(CustomConstants.Colors.brandGradient)

            Text(.alertVideoSaved)
                .font(CustomConstants.Typography.regular16)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: 200)
        .padding(24)
        .background(Color.black.opacity(0.8))
        .background(.ultraThinMaterial)
        .cornerRadius(CustomConstants.CornerRadius.radius)
        .transition(.scale.combined(with: .opacity))
        .task {
            try? await Task.sleep(nanoseconds: 2_500_000_000) // 2.5 seconds
            withAnimation {
                showAlertVideoDownloaded = false
            }
        }
    }
}

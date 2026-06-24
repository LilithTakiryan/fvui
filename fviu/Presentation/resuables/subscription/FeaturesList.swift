//
//  FeaturesList.swift
//  fviu
//
//  Created by lilit on 24.06.26.
//

import SwiftUI

struct FeaturesList: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            FeatureRow(icon: .sparkles, title: "Get results in seconds")
            FeatureRow(icon: .edit, title: "Turn any text into better writing")
            FeatureRow(icon: .text, title: "Simplify complex information")
            FeatureRow(icon: .image, title: "Create content with AI templates")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
    }
}
struct FeatureRow: View {
    let icon: ImageResource
    let title: String

    var body: some View {
        HStack(spacing: 12) {
            Image(icon)
                .renderingMode(.original)
                .resizable()
                .frame(width: 20, height: 20)

            Text(title)
                .font(CustomConstants.Typography.medium16)
                .foregroundColor(.white)
        }
    }
}

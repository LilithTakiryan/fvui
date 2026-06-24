//
//  GeneratingView.swift
//  fviu
//
//  Created by lilit on 19.06.26.
//

import SwiftUI

#Preview {
    GeneratingView()
}

struct GeneratingView: View {
    var body: some View {
        VStack {
            Image(.generating)
            Text("Generating...")
                .font(CustomConstants.Typography.semiBold20)
                .foregroundStyle(Color.white)
            Text("We’re creating the best result for you")
                .font(CustomConstants.Typography.regular16)
                .foregroundStyle(.secondary)
        }
    }
}

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
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Color.white)
            Text("We’re creating the best result for you")
                .font(.system(size: 16, weight: .light))
                .foregroundStyle(.secondary)
        }
    }
}

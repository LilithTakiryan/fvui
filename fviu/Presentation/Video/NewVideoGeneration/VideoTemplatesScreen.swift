//
//  TemplatesScreen.swift
//  fviu
//
//  Created by lilit on 25.06.26.
//

import SwiftUI

#Preview {
    TemplatesScreen()
}

struct TemplatesScreen: View {
    @StateObject private var viewModel = DependencyContainer.shared.makeVideoViewModel()

    var body: some View {
        VStack{
            
        }
        .onAppear {
            Task {
                await viewModel.getTemplates()
            }
        }
    }
}

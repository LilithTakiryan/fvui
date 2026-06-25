//
//  TemplatesScreen.swift
//  fviu
//
//  Created by lilit on 25.06.26.
//
import AVFoundation
import AVKit
import Photos
import SwiftUI

#Preview {
    TemplatesScreen()
}

struct TemplatesScreen: View {
    @StateObject private var viewModel = DependencyContainer.shared.makeVideoViewModel()
    @State private var selectedCategory: String = ""
    @Environment(\.dismiss) var dismiss
    @State private var selectedTemplate = VideoTemplateResponse?.none
    @State private var showDetail = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]


    var dynamicCategories: [String] {
        let items = Array(Set(viewModel.templates.map { $0.category })).sorted()
        return items.isEmpty ? ["Popular"] : items
    }

    var filteredTemplates: [VideoTemplateResponse] {
        if selectedCategory.isEmpty { return viewModel.templates }
        return viewModel.templates.filter { $0.category == selectedCategory }
    }

    var body: some View {
        VStack(spacing: 0) {
            CategoryTagSelectorView(categories: dynamicCategories, selectedCategory: $selectedCategory)
                .padding(.vertical, 12)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(filteredTemplates, id: \.id) { template in
                        TemplateCardRectangle(template: template)
                            .onTapGesture {
                                selectedTemplate = template
                                showDetail = true
                            }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
        }
        .toolbarBackground(Color(red: 0.11, green: 0.09, blue: 0.13), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 12) {
                    Image(.chatIcon)
                        .resizable()
                        .frame(width: 32, height: 32)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("AI Video")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: VideoHistoryScreen()) {
                    Image(.history)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showDetail) {
            if let selectedTemplate = selectedTemplate {
                SelectedTemplateScreen(selectedTemplate: selectedTemplate)
            }
        }
        .background(CustomConstants.Colors.backgroundDeep.ignoresSafeArea())
        .onAppear {
            Task {
                await viewModel.getTemplates()
                if let firstCategory = dynamicCategories.first {
                    selectedCategory = firstCategory
                }
            }
        }
    }
}

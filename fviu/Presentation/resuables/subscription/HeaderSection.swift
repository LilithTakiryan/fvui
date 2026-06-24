//
//  HeaderSection.swift
//  fviu
//
//  Created by lilit on 24.06.26.
//

import SwiftUI


struct HeaderSection: View {
    var body: some View {
        Text("Create anything you want")
            .foregroundColor(.white)
            .font(CustomConstants.Typography.bold34)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 8)
    }
}

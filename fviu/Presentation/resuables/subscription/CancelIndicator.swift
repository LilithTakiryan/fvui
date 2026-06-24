//
//  CancelIndicator.swift
//  fviu
//
//  Created by lilit on 24.06.26.
//

import SwiftUI

struct CancelIndicator: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "clock.arrow.circlepath")
            Text("Cancel anytime")
                .font(.custom("SF Pro Display", size: 14))
        }
        .font(.system(size: 15, weight: .medium))
        .foregroundColor(CustomConstants.Paywall.subTextColor)
    }
}

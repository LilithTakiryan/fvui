//
//  DropdownOption.swift
//  fviu
//
//  Created by lilit on 19.06.26.
//

import SwiftUI

//struct MediaSettingsSelectorView_Previews: PreviewProvider {
//    @State private var ratio = "16:9"
//        @State private var quality = "720p"
//    static var previews: some View {
//       MediaSettingsSelectorView(selectedRatio: $ratio, selectedQuality: $quality)    }
//}

struct DropdownOption: Identifiable, Equatable {
    let id = UUID()
    let label: String
    var icon: AnyView? = nil

    static func == (lhs: DropdownOption, rhs: DropdownOption) -> Bool {
        lhs.label == rhs.label
    }
}

struct DropdownRow: View {
    let option: DropdownOption
    let isSelected: Bool

    var body: some View {
        HStack {
            if isSelected {
                Text(option.label)
                    .font(.system(size: CustomConstants.Sizes.mainButtonFontSize, weight: .semibold))
                    .foregroundStyle(CustomConstants.Colors.brandGradient)
            } else {
                Text(option.label)
                    .font(.system(size: CustomConstants.Sizes.mainButtonFontSize, weight: .regular))
                    .foregroundColor(.white)
            }

            Spacer()

            if let icon = option.icon {
                icon
                    .foregroundStyle(
                        isSelected
                            ? AnyShapeStyle(CustomConstants.Colors.brandGradient)
                            : AnyShapeStyle(Color.white)
                    )
                    .opacity(isSelected ? 1.0 : 0.8)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, CustomConstants.Sizes.mainButtonVerticalPadding + 2)
        .background(CustomConstants.Dropdown.panelBackground)
    }
}

struct MediaSettingsSelectorView: View {
    @Binding  var selectedRatio: String
    @Binding  var selectedQuality: String

    @State private var showRatioDropdown: Bool = false
    @State private var showQualityDropdown: Bool = false

    var ratioOptions: [DropdownOption] {
        [
            DropdownOption(label: "16:9", icon: AnyView(RoundedRectangle(cornerRadius: 3).stroke(lineWidth: 2).frame(width: 24, height: 14))),
            DropdownOption(label: "9:16", icon: AnyView(RoundedRectangle(cornerRadius: CustomConstants.CornerRadius.radius).stroke(lineWidth: 2).frame(width: 14, height: 24))),
            DropdownOption(label: "1:1", icon: AnyView(RoundedRectangle(cornerRadius: 3).stroke(lineWidth: 2).frame(width: 18, height: 18))),
        ]
    }

    let qualityOptions = [
        DropdownOption(label: "540p"),
        DropdownOption(label: "720p"),
        DropdownOption(label: "1080p"),
        DropdownOption(label: "4K"),
    ]

    var body: some View {
        ZStack {
            CustomConstants.Colors.backgroundDeep.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 8) {
                    if showRatioDropdown {
                        VStack(spacing: 0) {
                            ForEach(ratioOptions) { option in
                                Button(action: {
                                    selectedRatio = option.label
                                    withAnimation { showRatioDropdown = false }
                                }) {
                                    DropdownRow(option: option, isSelected: selectedRatio == option.label)
                                }
                                if option != ratioOptions.last {
                                    Divider().background(CustomConstants.Paywall.inactiveBorderColor.opacity(0.4))
                                }
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: CustomConstants.Dropdown.cornerRadius))
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            showRatioDropdown.toggle()
                            if showRatioDropdown { showQualityDropdown = false }
                        }
                    }) {
                        HStack {
                            Text("Format")
                                .font(.system(size: CustomConstants.Sizes.mainButtonFontSize, weight: .medium))
                                .foregroundColor(CustomConstants.Paywall.subTextColor)
                            Spacer()
                            Text(selectedRatio)
                                .font(.system(size: CustomConstants.Sizes.mainButtonFontSize, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, CustomConstants.Sizes.mainButtonVerticalPadding + 4)
                        .background(Capsule().fill(CustomConstants.Dropdown.buttonBackground))
                    }
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 8) {
                    if showQualityDropdown {
                        VStack(spacing: 0) {
                            ForEach(qualityOptions) { option in
                                Button(action: {
                                    selectedQuality = option.label
                                    withAnimation { showQualityDropdown = false }
                                }) {
                                    DropdownRow(option: option, isSelected: selectedQuality == option.label)
                                }
                                if option != qualityOptions.last {
                                    Divider().background(CustomConstants.Paywall.inactiveBorderColor.opacity(0.4))
                                }
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: CustomConstants.Dropdown.cornerRadius))
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            showQualityDropdown.toggle()
                            if showQualityDropdown { showRatioDropdown = false }
                        }
                    }) {
                        HStack {
                            Text("Quality")
                                .font(.system(size: CustomConstants.Sizes.mainButtonFontSize, weight: .medium))
                                .foregroundColor(CustomConstants.Paywall.subTextColor)
                            Spacer()

                            if selectedQuality == "720p" {
                                Text(selectedQuality)
                                    .font(.system(size: CustomConstants.Sizes.mainButtonFontSize, weight: .semibold))
                                    .foregroundStyle(CustomConstants.Colors.brandGradient)
                            } else {
                                Text(selectedQuality)
                                    .font(.system(size: CustomConstants.Sizes.mainButtonFontSize, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, CustomConstants.Sizes.mainButtonVerticalPadding + 4)
                        .background(Capsule().fill(CustomConstants.Dropdown.buttonBackground))
                    }
                }
                .frame(maxWidth: .infinity)

                Spacer()
            }
        }
    }
}

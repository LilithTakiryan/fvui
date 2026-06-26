//
//  VideoHistoryItem.swift
//  fviu
//
//  Created by lilit on 26.06.26.
//

import Foundation
import SwiftUI

struct VideoHistoryItem: Identifiable {
    let id = UUID()
    let url: URL
    let thumbnail: UIImage?
}

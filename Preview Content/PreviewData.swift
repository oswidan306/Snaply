//
//  PreviewData.swift
//  Snaply
//
//  Created by Omar Swidan on 12/15/24.
//

import SwiftUI
import UIKit

extension DiaryViewModel {
    static var preview: DiaryViewModel {
        let viewModel = DiaryViewModel()
        if let image = UIImage(systemName: "photo") {
            viewModel.addNewPhoto(image)
        }
        return viewModel
    }
} 
//
//  PreviewData.swift
//  Snaply
//
//  Created by Omar Swidan on 12/15/24.
//

import SwiftUI
import UIKit

struct PreviewData {
    static let containerWidth: CGFloat = UIScreen.main.bounds.width - 32
    
    static let viewModel: DiaryViewModel = {
        let vm = DiaryViewModel(containerWidth: containerWidth)
        if let image = UIImage(systemName: "photo") {
            vm.addNewPhoto(image)
        }
        return vm
    }()
    
    static let photoEntry = Models.PhotoEntry(
        photo: UIImage(systemName: "photo") ?? UIImage()
    )
    
    static let textOverlay = Models.TextOverlay(
        text: "Sample Text",
        position: CGPoint(x: 0.5, y: 0.5),
        style: Models.TextStyle(),
        color: .white
    )
} 
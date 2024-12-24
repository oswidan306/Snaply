//
//  PhotoPickerView.swift
//  Snaply
//
//  Created by Omar Swidan on 12/15/24.
//

import SwiftUI
import PhotosUI
import UIKit

struct PhotoPickerView: View {
    @Binding var selectedItem: PhotosPickerItem?
    let containerWidth: CGFloat
    
    var body: some View {
        PhotosPicker(selection: $selectedItem,
                    matching: .images) {
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "#FBFBFB"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10]))
                            .foregroundColor(.gray.opacity(0.3))
                    )
                    .frame(width: containerWidth)
                    .frame(height: UIScreen.main.bounds.height * 0.64)
                
                VStack(spacing: 8) {
                    Image(systemName: "camera")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                    
                    Text("Add media")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(width: containerWidth)
        .frame(height: UIScreen.main.bounds.height * 0.64)
    }
} 

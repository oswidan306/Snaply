//
//  PhotoPickerView.swift
//  Snaply
//
//  Created by Omar Swidan on 12/15/24.
//

import SwiftUI
import PhotosUI

struct PhotoPickerView: View {
    @Binding var selectedItem: PhotosPickerItem?
    
    var body: some View {
        VStack {
            Spacer()
            
            PhotosPicker(selection: $selectedItem,
                        matching: .images) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "#FFFFFF"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10]))
                                .foregroundColor(.gray.opacity(0.3))
                        )
                        .frame(height: UIScreen.main.bounds.height * 0.68)
                        .padding(.horizontal, 16)
                    
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
            
            Spacer()
        }
    }
} 

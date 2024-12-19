//
//  ColorSelectorView.swift
//  Snaply
//
//  Created by Omar Swidan on 12/15/24.
//

import SwiftUI

struct ColorSelectorView: View {
    @ObservedObject var viewModel: DiaryViewModel
    let circleSize: CGFloat = 16
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(viewModel.availableColors, id: \.self) { color in
                Circle()
                    .fill(color)
                    .frame(width: circleSize, height: circleSize)
                    .overlay(
                        Circle()
                            .stroke(Color.gray.opacity(0.8), lineWidth: viewModel.selectedColor == color ? 2 : 0)
                    )
                    .onTapGesture {
                        viewModel.selectedColor = color
                    }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(
            Capsule()
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 4)
        )
    }
}


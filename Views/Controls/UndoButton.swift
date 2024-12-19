//
//  UndoButton.swift
//  Snaply
//
//  Created by Omar Swidan on 12/15/24.
//

import SwiftUI

struct UndoButton: View {
    @ObservedObject var viewModel: DiaryViewModel
    
    var body: some View {
        Button(action: {
            viewModel.undo()
        }) {
            Image("undo_icon")
                .resizable()
                .frame(width: 28, height: 28)
                .foregroundColor(.black)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
        }
        .disabled(!viewModel.hasEdits())
        .background(
            Capsule()
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 4)
        )
    }
} 
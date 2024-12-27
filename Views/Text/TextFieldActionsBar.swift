//
//  TextFieldActionsBar.swift
//  Snaply
//
//  Created by Omar Swidan on 12/15/24.
//

import SwiftUI

struct TextFieldActionsBar: View {
    let viewModel: DiaryViewModel
    let overlayId: UUID
    @Binding var fontSize: CGFloat
    @Binding var selectedFont: Models.FontStyle
    @Binding var textColor: Color
    @Binding var activeTextId: UUID?
    
    var body: some View {
        HStack(spacing: 12) {
            // Font size controls
            Button(action: { 
                fontSize = max(12, fontSize - 2)
                viewModel.updateTextOverlayStyle(id: overlayId, fontSize: fontSize)
            }) {
                Image(systemName: "textformat.size.smaller")
                    .foregroundColor(.black)
            }
            
            Button(action: { 
                fontSize = min(72, fontSize + 2)
                viewModel.updateTextOverlayStyle(id: overlayId, fontSize: fontSize)
            }) {
                Image(systemName: "textformat.size.larger")
                    .foregroundColor(.black)
            }
            
            // Font style controls
            Button(action: { 
                selectedFont = .regular
                viewModel.updateTextOverlayStyle(id: overlayId, fontStyle: selectedFont)
            }) {
                Image(systemName: "textformat")
                    .foregroundColor(.black)
            }
            Button(action: { 
                selectedFont = .bold
                viewModel.updateTextOverlayStyle(id: overlayId, fontStyle: selectedFont)
            }) {
                Image(systemName: "bold")
                    .foregroundColor(.black)
            }
            Button(action: { 
                selectedFont = .italic
                viewModel.updateTextOverlayStyle(id: overlayId, fontStyle: selectedFont)
            }) {
                Image(systemName: "italic")
                    .foregroundColor(.black)
            }
            
            // Color picker
            ColorPicker("", selection: $textColor)
                .frame(width: 24)
                .onChange(of: textColor) { newColor in
                    viewModel.updateTextOverlayStyle(id: overlayId, color: newColor)
                }
            
            // Delete button
            Button(action: {
                viewModel.deleteTextOverlay(id: overlayId)
                activeTextId = nil
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: activeTextId)
    }
}


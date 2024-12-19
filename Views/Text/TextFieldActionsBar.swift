//
//  TextFieldActionsBar.swift
//  Snaply
//
//  Created by Omar Swidan on 12/15/24.
//

import SwiftUI

struct TextFieldActionsBar: View {
    @ObservedObject var viewModel: DiaryViewModel
    let overlayId: UUID
    @Binding var fontSize: CGFloat
    @Binding var selectedFont: FontStyle
    @Binding var textColor: Color
    @Binding var activeTextId: UUID?
    @State private var showingColorPicker = false
    
    let commonSizes: [CGFloat] = [12, 14, 16, 18, 20, 24, 30, 36, 48]
    let colors: [Color] = [
        .white, .black, .blue, .green, .red, .purple,
        Color(red: 1.0, green: 0.7, blue: 0.9), .yellow, .orange
    ]
    
    var body: some View {
        ZStack(alignment: .top) {
            // Main action bar
            HStack(spacing: 16) {
                // Color selector
                colorButton
                
                // Font style menu
                fontStyleMenu
                
                // Font size menu
                fontSizeMenu
                
                // Duplicate button
                duplicateButton
                
                // Delete button
                deleteButton
            }
            .frame(width: 220)
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background(
                Capsule()
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 4)
            )
            
            // Color picker popup
            if showingColorPicker {
                colorPickerPopup
            }
        }
    }
    
    // MARK: - View Components
    
    private var colorButton: some View {
        Circle()
            .fill(textColor)
            .frame(width: 20, height: 20)
            .overlay(
                Circle()
                    .stroke(Color.gray.opacity(0.8), lineWidth: 1)
            )
            .onTapGesture {
                showingColorPicker.toggle()
            }
    }
    
    private var fontStyleMenu: some View {
        Menu {
            ForEach(FontStyle.allCases, id: \.self) { style in
                Button(action: {
                    selectedFont = style
                    viewModel.updateTextOverlayStyle(id: overlayId, fontStyle: style)
                }) {
                    Text(style.rawValue)
                        .font(style.font(size: 16))
                }
            }
        } label: {
            Image(systemName: "textformat")
                .font(.system(size: 22))
                .foregroundColor(.black)
        }
    }
    
    private var fontSizeMenu: some View {
        Menu {
            ForEach(commonSizes, id: \.self) { size in
                Button(action: {
                    fontSize = size
                    viewModel.updateTextOverlayStyle(id: overlayId, fontSize: size)
                }) {
                    Text("\(Int(size))")
                }
            }
        } label: {
            Text("\(Int(fontSize))")
                .font(.system(size: 18))
                .foregroundColor(.black)
        }
    }
    
    private var duplicateButton: some View {
        Button(action: {
            let newId = viewModel.duplicateTextOverlay(id: overlayId)
            activeTextId = newId
        }) {
            Image(systemName: "plus.square.on.square")
                .font(.system(size: 22))
                .foregroundColor(.black)
        }
    }
    
    private var deleteButton: some View {
        Button(action: {
            viewModel.deleteTextOverlay(id: overlayId)
        }) {
            Image(systemName: "trash")
                .font(.system(size: 22))
                .foregroundColor(.red)
        }
    }
    
    private var colorPickerPopup: some View {
        HStack(spacing: 12) {
            ForEach(colors, id: \.self) { color in
                Circle()
                    .fill(color)
                    .frame(width: 16, height: 16)
                    .overlay(
                        Circle()
                            .stroke(Color.gray.opacity(0.8), lineWidth: color == textColor ? 2 : 0)
                    )
                    .onTapGesture {
                        textColor = color
                        viewModel.updateTextOverlayStyle(id: overlayId, color: color)
                        showingColorPicker = false
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
        .offset(y: -40)
    }
}


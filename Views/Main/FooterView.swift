//
//  FooterView.swift
//  Snaply
//
//  Created by Omar Swidan on 12/15/24.
//

import SwiftUI
import PhotosUI
import Snaply

struct FooterView: View {
    @ObservedObject var viewModel: DiaryViewModel
    @Binding var activeTextId: UUID?
    @Binding var isTyping: Bool
    @Binding var showingEmotionPicker: Bool
    @Binding var selectedItem: PhotosPickerItem?
    
    var body: some View {
        VStack(spacing: 16) {
            if viewModel.currentEntry != nil {
                // Color picker for drawing mode
                if viewModel.isDrawing {
                    ColorSelectorView(viewModel: viewModel)
                        .padding(.bottom, 12)
                }
                
                // Action buttons
                HStack(spacing: 20) {
                    // Left side - fixed width container for undo
                    HStack {
                        if viewModel.hasEdits() {
                            UndoButton(viewModel: viewModel)
                        }
                    }
                    .frame(width: 60, alignment: .leading)  // Fixed width container
                    
                    Spacer()
                    
                    // Main action buttons
                    HStack(spacing: 20) {
                        Button(action: {
                            viewModel.isDrawing = false
                            viewModel.addTextOverlay()
                        }) {
                            Image("text_icon")
                                .resizable()
                                .frame(width: 28, height: 28)
                                .foregroundColor(.black)
                        }
                        .disabled(viewModel.currentEntry == nil)
                        
                        Button(action: {
                            viewModel.isDrawing.toggle()
                            if viewModel.isDrawing {
                                isTyping = false
                                activeTextId = nil
                            }
                        }) {
                            Image("scribble_icon")
                                .resizable()
                                .frame(width: 28, height: 28)
                                .foregroundColor(viewModel.isDrawing ? .blue : .black)
                        }
                        .disabled(viewModel.currentEntry == nil)
                        
                        Button(action: {
                            showingEmotionPicker.toggle()
                            if showingEmotionPicker {
                                viewModel.isDrawing = false
                            }
                        }) {
                            Image("emotions_icon")
                                .resizable()
                                .frame(width: 28, height: 28)
                                .foregroundColor(showingEmotionPicker ? .blue : .black)
                        }
                        .disabled(viewModel.currentEntry == nil)
                    }
                    .frame(width: 140)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 10)
                    .background(
                        Capsule()
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 4)
                    )
                    
                    Spacer()
                    
                    // Right side - fixed width container for replace
                    HStack {
                        if viewModel.currentEntry != nil {
                            PhotosPicker(selection: $selectedItem) {
                                Image("replace_icon")
                                    .resizable()
                                    .frame(width: 28, height: 28)
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                            }
                            .background(
                                Capsule()
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.1), radius: 4)
                            )
                        }
                    }
                    .frame(width: 60, alignment: .trailing)  // Fixed width container
                }
                .padding(.horizontal)
            } else {
                // Show Past button when no image is selected
                PastButton {
                    // Add navigation action here
                }
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 16)
    }
}


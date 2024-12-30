//
//  FooterView.swift
//  Snaply
//
//  Created by Omar Swidan on 12/15/24.
//

import SwiftUI
import PhotosUI

struct FooterView: View {
    @ObservedObject var viewModel: DiaryViewModel
    @Binding var activeTextId: UUID?
    @Binding var isTyping: Bool
    @Binding var selectedItem: PhotosPickerItem?
    @State private var textButtonTapped = false
    
    var body: some View {
        VStack(spacing: 16) {
            if viewModel.currentEntry != nil {
                // Color picker for drawing mode - only show when not actively drawing
                if viewModel.isDrawing && viewModel.currentLine == nil && !viewModel.isShowingDiary {
                    ColorSelectorView(viewModel: viewModel)
                        .padding(.bottom, 4)
                }
                
                // All action buttons in a single HStack
                HStack(spacing: 0) {
                    if viewModel.hasEdits() {
                        UndoButton(viewModel: viewModel)
                            .buttonStyle(FlashingButtonStyle(isFlashing: .constant(false)))
                    } else {
                        Color.clear.frame(width: 48, height: 44)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if viewModel.isShowingDiary {
                            viewModel.toggleDiary()
                            // Wait for animation to complete before adding text
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                viewModel.isDrawing = false
                                viewModel.addTextOverlay()
                                textButtonTapped = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    textButtonTapped = false
                                }
                            }
                        } else {
                            viewModel.isDrawing = false
                            viewModel.addTextOverlay()
                            textButtonTapped = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                textButtonTapped = false
                            }
                        }
                    }) {
                        Image("text_icon")
                            .renderingMode(.template)
                            .resizable()
                    }
                    .buttonStyle(FlashingButtonStyle(isFlashing: $textButtonTapped))
                    .disabled(viewModel.currentEntry == nil)
                    
                    Spacer()
                    
                    Button(action: {
                        if viewModel.isShowingDiary {
                            viewModel.toggleDiary()
                            // Wait for animation to complete before toggling drawing
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                viewModel.isDrawing.toggle()
                                if viewModel.isDrawing {
                                    isTyping = false
                                    activeTextId = nil
                                }
                            }
                        } else {
                            viewModel.isDrawing.toggle()
                            if viewModel.isDrawing {
                                isTyping = false
                                activeTextId = nil
                            }
                        }
                    }) {
                        Image("scribble_icon")
                            .renderingMode(.template)
                            .resizable()
                    }
                    .buttonStyle(FlashingButtonStyle(isFlashing: .constant(false), isActive: viewModel.isDrawing))
                    .disabled(viewModel.currentEntry == nil)
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.toggleDiary()
                    }) {
                        Image("note_icon")
                            .renderingMode(.template)
                            .resizable()
                    }
                    .buttonStyle(FlashingButtonStyle(isFlashing: .constant(false), isActive: viewModel.isShowingDiary))
                    .disabled(viewModel.currentEntry == nil)
                    
                    Spacer()
                    
                    if viewModel.isShowingDiary {
                        Button(action: {
                            viewModel.toggleDiary()
                            // Wait for flip animation to complete before showing picker
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                // Programmatically trigger the photo picker
                                Task { @MainActor in
                                    selectedItem = nil
                                }
                            }
                        }) {
                            Image("replace_icon")
                                .renderingMode(.template)
                                .resizable()
                        }
                        .buttonStyle(FlashingButtonStyle(isFlashing: .constant(false)))
                    } else {
                        PhotosPicker(selection: $selectedItem) {
                            Image("replace_icon")
                                .renderingMode(.template)
                                .resizable()
                        }
                        .buttonStyle(FlashingButtonStyle(isFlashing: .constant(false)))
                    }
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
            } else {
                // Show Past button when no image is selected
                PastButton {
                    // Add navigation action here
                }
            }
        }
        .padding(.vertical, 16)
    }
}

struct FlashingButtonStyle: ButtonStyle {
    @Binding var isFlashing: Bool
    var isActive: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 28, height: 28)
            .foregroundColor(.white)
            .padding([.horizontal], 10)
            .padding([.vertical], 10)
            .background(
                Capsule()
                    .fill(configuration.isPressed || isFlashing || isActive ? Color.blue : Color.black.opacity(0.3))
            )
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
            .animation(.easeInOut(duration: 0.2), value: isFlashing)
    }
}


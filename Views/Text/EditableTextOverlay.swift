//
//  EditableTextOverlay.swift
//  Snaply
//
//  Created by Omar Swidan on 12/15/24.
//

import SwiftUI

struct EditableTextOverlay: View {
    @ObservedObject var viewModel: DiaryViewModel
    let overlay: Models.TextOverlay
    let containerWidth: CGFloat
    @Binding var activeTextId: UUID?
    @Binding var isTyping: Bool
    @State private var editingText: String
    @State private var fontSize: CGFloat
    @State private var selectedFont: Models.FontStyle
    @State private var textColor: Color
    @State private var offset: CGSize = .zero
    
    private var isActive: Bool {
        activeTextId == overlay.id
    }
    
    init(viewModel: DiaryViewModel,
         overlay: Models.TextOverlay,
         containerWidth: CGFloat,
         activeTextId: Binding<UUID?>,
         isTyping: Binding<Bool>) {
        self.viewModel = viewModel
        self.overlay = overlay
        self.containerWidth = containerWidth
        self._activeTextId = activeTextId
        self._isTyping = isTyping
        self._editingText = State(initialValue: overlay.text)
        self._fontSize = State(initialValue: overlay.style.fontSize)
        self._selectedFont = State(initialValue: overlay.style.fontStyle)
        self._textColor = State(initialValue: overlay.color)
    }
    
    var body: some View {
        Group {
            if isActive && isTyping {
                editableTextField
            } else {
                staticTextField
            }
        }
        .offset(offset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    offset = value.translation
                }
                .onEnded { value in
                    let newPosition = CGPoint(
                        x: overlay.position.x + value.translation.width,
                        y: overlay.position.y + value.translation.height
                    )
                    
                    // Constrain to photo bounds
                    let boundedX = max(0, min(newPosition.x, containerWidth))
                    let boundedY = max(0, min(newPosition.y, UIScreen.main.bounds.height * 0.7))
                    
                    offset = .zero
                    viewModel.updatePosition(
                        CGPoint(x: boundedX, y: boundedY),
                        for: overlay.id,
                        in: viewModel.photoFrame
                    )
                }
        )
        .position(overlay.position)
    }
    
    private var editableTextField: some View {
        TextField("Enter text", text: $editingText, axis: .vertical)
            .font(selectedFont.font(size: fontSize))
            .foregroundColor(textColor)
            .multilineTextAlignment(.center)
            .frame(width: overlay.width)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.blue, lineWidth: 2)
            )
            .onSubmit {
                submitText()
            }
    }
    
    private var staticTextField: some View {
        Text(overlay.text)
            .font(selectedFont.font(size: fontSize))
            .foregroundColor(textColor)
            .multilineTextAlignment(.center)
            .frame(width: overlay.width)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                Group {
                    if isActive {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.blue, lineWidth: 2)
                            .overlay(
                                ResizeHandles(width: overlay.width) { newWidth in
                                    viewModel.updateTextOverlayWidth(id: overlay.id, width: newWidth)
                                }
                            )
                    }
                }
            )
            .onTapGesture {
                activeTextId = overlay.id
                isTyping = false
            }
            .onTapGesture(count: 2) {
                activeTextId = overlay.id
                isTyping = true
            }
    }
    
    private func submitText() {
        viewModel.updateTextOverlay(id: overlay.id, text: editingText)
        isTyping = false
    }
}

// Separate view for resize handles
private struct ResizeHandles: View {
    let width: CGFloat
    let onResize: (CGFloat) -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // Left handle
            ResizeHandle()
                .frame(width: 12, height: 12)
                .offset(x: 6) // Move right by half width
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let change = -value.translation.width
                            let newWidth = width + change
                            let constrainedWidth = min(max(100, newWidth), UIScreen.main.bounds.width - 40)
                            onResize(constrainedWidth)
                        }
                )
            
            Spacer()
            
            // Right handle
            ResizeHandle()
                .frame(width: 12, height: 12)
                .offset(x: -6) // Move left by half width
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let change = value.translation.width
                            let newWidth = width + change
                            let constrainedWidth = min(max(100, newWidth), UIScreen.main.bounds.width - 40)
                            onResize(constrainedWidth)
                        }
                )
        }
        .frame(width: width)
    }
} 
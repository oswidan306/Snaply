//
//  EditableTextOverlay.swift
//  Snaply
//
//  Created by Omar Swidan on 12/15/24.
//

import SwiftUI
import UIKit

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
    @State private var position: CGPoint
    @FocusState private var isFocused: Bool
    @State private var dragOffset: CGSize = .zero
    @State private var lastTapTime: Date = Date()
    private let doubleTapInterval: TimeInterval = 0.3
    
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
        
        // Initialize position with the overlay's stored position
        self._position = State(initialValue: overlay.position)
    }
    
    private var absolutePosition: CGPoint {
        let frame = viewModel.photoFrame
        guard frame.width > 0, frame.height > 0 else {
            print("Warning: Invalid photo frame: \(frame)")
            return .zero
        }
        let pos = viewModel.convertToAbsolutePosition(position, in: frame)
        print("Converting relative pos \(position) to absolute pos \(pos) in frame \(frame)")
        return pos
    }
    
    private func constrainPosition(_ proposedAbsolutePosition: CGPoint, in frame: CGRect) -> CGPoint {
        let halfWidth = overlay.width / 2
        let halfHeight = fontSize * 1.5 / 2
        
        let constrainedX = min(
            frame.maxX - halfWidth,
            max(frame.minX + halfWidth, proposedAbsolutePosition.x)
        )
        let constrainedY = min(
            frame.maxY - halfHeight,
            max(frame.minY + halfHeight, proposedAbsolutePosition.y)
        )
        
        return viewModel.convertToRelativePosition(
            CGPoint(x: constrainedX, y: constrainedY),
            in: frame
        )
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Main text content
            ZStack {
                if isTyping {
                    TextField("Enter text", text: $editingText)
                        .font(selectedFont == .regular ? .system(size: fontSize) :
                                selectedFont == .bold ? .system(size: fontSize, weight: .bold) :
                                    .system(size: fontSize).italic())
                        .foregroundColor(textColor)
                        .multilineTextAlignment(.center)
                        .frame(width: overlay.width)
                        .focused($isFocused)
                } else {
                    Text(editingText)
                        .font(selectedFont == .regular ? .system(size: fontSize) :
                                selectedFont == .bold ? .system(size: fontSize, weight: .bold) :
                                    .system(size: fontSize).italic())
                        .foregroundColor(textColor)
                        .multilineTextAlignment(.center)
                        .frame(width: overlay.width)
                }
            }
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
            
            // Actions Bar (only show when active and not typing)
            if isActive && !isTyping {
                HStack(spacing: 12) {
                    // Font size controls
                    FontSizeControls(fontSize: $fontSize)
                    
                    // Font style controls
                    FontStyleControls(fontStyle: $selectedFont)
                    
                    // Color picker
                    ColorPicker("", selection: $textColor)
                        .frame(width: 24)
                    
                    // Delete button
                    Button(action: {
                        viewModel.deleteTextOverlay(id: overlay.id)
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
                .offset(y: -50)  // Move above the text field
            }
        }
        .frame(width: overlay.width, height: fontSize * 1.5)
        .position(
            x: absolutePosition.x + dragOffset.width,
            y: absolutePosition.y + dragOffset.height
        )
        .gesture(
            DragGesture(minimumDistance: 3)
                .onChanged { value in
                    if isActive && !isTyping {
                        dragOffset = value.translation
                    }
                }
                .onEnded { value in
                    if isActive && !isTyping {
                        let frame = viewModel.photoFrame
                        guard frame.width > 0, frame.height > 0 else {
                            print("Warning: Invalid photo frame during drag end: \(frame)")
                            return
                        }
                        
                        let finalAbsolutePosition = CGPoint(
                            x: absolutePosition.x + value.translation.width,
                            y: absolutePosition.y + value.translation.height
                        )
                        
                        // Convert the final position to relative coordinates
                        let finalRelativePosition = viewModel.convertToRelativePosition(finalAbsolutePosition, in: frame)
                        
                        print("Drag ended: translation: \(value.translation)")
                        print("Final absolute position: \(finalAbsolutePosition)")
                        print("Final relative position: \(finalRelativePosition)")
                        
                        // Update the local position and clear drag offset
                        position = finalRelativePosition
                        dragOffset = .zero
                        
                        // Update the view model with the new position
                        viewModel.updateTextOverlay(
                            id: overlay.id,
                            position: finalRelativePosition
                        )
                    }
                }
        )
        .onTapGesture(count: 1) {
            // Single tap - just select for dragging
            activeTextId = overlay.id
            isTyping = false
            isFocused = false
        }
        .onTapGesture(count: 2) {
            // Double tap - enter typing mode
            activeTextId = overlay.id
            isTyping = true
            isFocused = true
        }
        .onChange(of: editingText) { newValue in
            viewModel.updateTextOverlay(
                id: overlay.id,
                text: newValue
            )
        }
        .onChange(of: isTyping) { newValue in
            isFocused = newValue
        }
        .onChange(of: overlay.position) { newPosition in
            position = newPosition
        }
    }
}

// Helper Views
private struct ResizeHandle: View {
    var body: some View {
        Circle()
            .fill(Color.blue.opacity(0.5))
            .frame(width: 20, height: 20)
    }
}

private struct ResizeHandles: View {
    let width: CGFloat
    let onResize: (CGFloat) -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // Left handle
            ResizeHandle()
                .offset(x: -10)
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
                .offset(x: 10)
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

// Helper Views for the action bar
private struct FontSizeControls: View {
    @Binding var fontSize: CGFloat
    
    var body: some View {
        HStack {
            Button(action: { fontSize = max(12, fontSize - 2) }) {
                Image(systemName: "textformat.size.smaller")
                    .foregroundColor(.black)
            }
            Button(action: { fontSize = min(72, fontSize + 2) }) {
                Image(systemName: "textformat.size.larger")
                    .foregroundColor(.black)
            }
        }
    }
}

private struct FontStyleControls: View {
    @Binding var fontStyle: Models.FontStyle
    
    var body: some View {
        HStack {
            Button(action: { fontStyle = .regular }) {
                Image(systemName: "textformat")
                    .foregroundColor(.black)
            }
            Button(action: { fontStyle = .bold }) {
                Image(systemName: "bold")
                    .foregroundColor(.black)
            }
            Button(action: { fontStyle = .italic }) {
                Image(systemName: "italic")
                    .foregroundColor(.black)
            }
        }
    }
} 
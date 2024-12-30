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
    @State private var textHeight: CGFloat = 0
    @State private var selectedFontFamily: Models.FontFamily
    
    // Add a namespace for our coordinate space
    private let photoCanvasSpace = "photoCanvas"
    
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
        self._textColor = State(initialValue: overlay.color == .black ? .white : overlay.color)
        
        // Initialize position with the overlay's stored position
        self._position = State(initialValue: overlay.position)
        self._selectedFontFamily = State(initialValue: overlay.style.fontFamily)
    }
    
    private var absolutePosition: CGPoint {
        let frame = viewModel.photoFrame
        guard frame.width > 0, frame.height > 0 else {
            print("Warning: Invalid photo frame: \(frame)")
            return .zero
        }
        
        // Convert relative position to absolute
        var pos = viewModel.convertToAbsolutePosition(position, in: frame)
        
        // Apply constraints immediately to prevent out-of-bounds positions
        let halfWidth = overlay.width / 2
        let halfHeight = textHeight / 2
        
        // Constrain X position
        pos.x = min(
            frame.maxX - halfWidth,
            max(frame.minX + halfWidth, pos.x)
        )
        
        // Constrain Y position
        pos.y = min(
            frame.maxY - halfHeight,
            max(frame.minY + halfHeight, pos.y)
        )
        
        return pos
    }
    
    private func constrainPosition(_ proposedAbsolutePosition: CGPoint, in frame: CGRect) -> CGPoint {
        let halfHeight = textHeight / 2
        let halfWidth = overlay.width / 2
        
        // Constrain X position
        let constrainedX = min(
            frame.maxX - halfWidth,
            max(frame.minX + halfWidth, proposedAbsolutePosition.x)
        )
        
        // Constrain Y position
        let constrainedY = min(
            frame.maxY - halfHeight,
            max(frame.minY + halfHeight, proposedAbsolutePosition.y)
        )
        
        return viewModel.convertToRelativePosition(
            CGPoint(x: constrainedX, y: constrainedY),
            in: frame
        )
    }
    
    private func fontFor(_ family: Models.FontFamily) -> Font {
        let baseFont = Font.custom(family.fontName, size: fontSize)
        
        switch selectedFont {
        case .bold:
            return baseFont.bold()
        case .italic:
            return baseFont.italic()
        default:
            return baseFont
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Main text content
            ZStack {
                if isTyping {
                    TextField("Enter text", text: $editingText, axis: .vertical)
                        .font(fontFor(selectedFontFamily))
                        .foregroundColor(textColor)
                        .multilineTextAlignment(.center)
                        .lineLimit(5)
                        .frame(width: overlay.width)
                        .focused($isFocused)
                        .background(
                            GeometryReader { geo in
                                Color.clear.onAppear {
                                    textHeight = geo.size.height
                                }
                                .onChange(of: geo.size.height) { newHeight in
                                    textHeight = newHeight
                                }
                            }
                        )
                } else {
                    Text(editingText)
                        .font(fontFor(selectedFontFamily))
                        .foregroundColor(textColor)
                        .multilineTextAlignment(.center)
                        .lineLimit(5)
                        .lineSpacing(8)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(width: overlay.width)
                        .background(
                            GeometryReader { geo in
                                Color.clear.onAppear {
                                    textHeight = geo.size.height
                                }
                                .onChange(of: geo.size.height) { newHeight in
                                    textHeight = newHeight
                                }
                            }
                        )
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
                    // Font size control
                    FontSizeControls(fontSize: $fontSize)
                    
                    // Font style controls
                    Button(action: { 
                        selectedFont = .bold 
                        viewModel.updateTextOverlayStyle(id: overlay.id, fontStyle: .bold)
                    }) {
                        Image(systemName: "bold")
                            .foregroundColor(selectedFont == .bold ? .blue : .black)
                    }
                    
                    Button(action: { 
                        selectedFont = .italic
                        viewModel.updateTextOverlayStyle(id: overlay.id, fontStyle: .italic)
                    }) {
                        Image(systemName: "italic")
                            .foregroundColor(selectedFont == .italic ? .blue : .black)
                    }
                    
                    // Font family picker
                    Menu {
                        ForEach(Models.FontFamily.allCases, id: \.self) { family in
                            Button(action: {
                                selectedFontFamily = family
                                viewModel.updateTextOverlayStyle(
                                    id: overlay.id,
                                    fontFamily: family
                                )
                            }) {
                                if selectedFontFamily == family {
                                    Label(family.rawValue, systemImage: "checkmark")
                                } else {
                                    Text(family.rawValue)
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "textformat")
                            .foregroundColor(.black)
                    }
                    
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
                .frame(width: 200)  // Fixed width for action bar
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                )
                .position(x: overlay.width / 2, y: -25)  // Center above text field
            }
        }
        .frame(width: overlay.width, height: textHeight)
        .position(
            x: absolutePosition.x + dragOffset.width,
            y: absolutePosition.y + dragOffset.height
        )
        .gesture(
            DragGesture(coordinateSpace: .named(photoCanvasSpace)) // Specify coordinate space
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
                        
                        let proposedAbsolutePosition = CGPoint(
                            x: absolutePosition.x + value.translation.width,
                            y: absolutePosition.y + value.translation.height
                        )
                        
                        // Constrain the position within bounds
                        let constrainedRelativePosition = constrainPosition(proposedAbsolutePosition, in: frame)
                        
                        // Update the local position and clear drag offset
                        position = constrainedRelativePosition
                        dragOffset = .zero
                        
                        // Update the view model with the new position
                        viewModel.updateTextOverlay(
                            id: overlay.id,
                            position: constrainedRelativePosition
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
        .onChange(of: editingText) { oldValue, newValue in
            viewModel.updateTextOverlay(
                id: overlay.id,
                text: newValue
            )
        }
        .onChange(of: isTyping) { oldValue, newValue in
            isFocused = newValue
        }
        .onChange(of: overlay.position) { oldPosition, newPosition in
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
    private let fontSizes: [CGFloat] = [12, 14, 16, 18, 20, 24, 28, 32, 36, 40, 48, 56, 64]
    
    var body: some View {
        Menu {
            ForEach(fontSizes, id: \.self) { size in
                Button(action: { fontSize = size }) {
                    if fontSize == size {
                        Label("\(Int(size))pt", systemImage: "checkmark")
                    } else {
                        Text("\(Int(size))pt")
                    }
                }
            }
        } label: {
            Text("\(Int(fontSize))")
                .font(.system(size: 14, weight: .medium))
                .frame(minWidth: 24) // Ensure minimum width for two digits
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.black.opacity(0.5), lineWidth: 1)
                )
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
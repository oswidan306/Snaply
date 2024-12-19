//
//  EditableTextOverlay.swift
//  Snaply
//
//  Created by Omar Swidan on 12/15/24.
//

import SwiftUI

struct EditableTextOverlay: View {
    @ObservedObject var viewModel: DiaryViewModel
    let overlay: TextOverlay
    @Binding var activeTextId: UUID?
    @Binding var isTyping: Bool
    @State private var editingText: String
    @State private var fontSize: CGFloat
    @State private var selectedFont: FontStyle
    @State private var textColor: Color
    
    init(viewModel: DiaryViewModel,
         overlay: TextOverlay,
         activeTextId: Binding<UUID?>,
         isTyping: Binding<Bool>) {
        self.viewModel = viewModel
        self.overlay = overlay
        self._activeTextId = activeTextId
        self._isTyping = isTyping
        self._editingText = State(initialValue: overlay.text)
        self._fontSize = State(initialValue: overlay.style.fontSize)
        self._selectedFont = State(initialValue: overlay.style.fontStyle)
        self._textColor = State(initialValue: overlay.color)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            if activeTextId == overlay.id && isTyping {
                editableTextField
            } else {
                staticTextField
            }
            
            // Show action bar when text is selected but not being edited
            if activeTextId == overlay.id && !isTyping {
                TextFieldActionsBar(
                    viewModel: viewModel,
                    overlayId: overlay.id,
                    fontSize: $fontSize,
                    selectedFont: $selectedFont,
                    textColor: $textColor,
                    activeTextId: $activeTextId
                )
                .offset(y: -52)
            }
        }
    }
    
    private var editableTextField: some View {
        TextField("Enter text", text: $editingText, axis: .vertical)
            .font(selectedFont.font(size: fontSize))
            .foregroundColor(textColor)
            .shadow(color: .black, radius: 2)
            .frame(width: overlay.width)
            .lineLimit(5)
            .multilineTextAlignment(.center)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.blue.opacity(0.5), lineWidth: 2)
            )
            .position(
                viewModel.getActualPosition(for: overlay.id, in: viewModel.photoFrame)
            )
            .onSubmit {
                submitText()
            }
            .onChange(of: isTyping) { newValue in
                if !newValue {
                    submitText()
                }
            }
    }
    
    private var staticTextField: some View {
        Text(overlay.text)
            .font(selectedFont.font(size: fontSize))
            .foregroundColor(textColor)
            .shadow(color: .black, radius: 2)
            .frame(width: overlay.width)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.center)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(activeTextId == overlay.id ? Color.blue.opacity(0.5) : Color.clear,
                           lineWidth: 2)
            )
            .position(
                viewModel.getActualPosition(for: overlay.id, in: viewModel.photoFrame)
            )
            .gesture(dragGesture)
            .overlay(
                Group {
                    if activeTextId == overlay.id {
                        resizeHandles
                    }
                }
            )
            .onTapGesture {
                activeTextId = overlay.id
                editingText = overlay.text
                isTyping = false
            }
            .onTapGesture(count: 2) {
                withAnimation {
                    activeTextId = overlay.id
                    editingText = overlay.text
                    isTyping = true
                }
            }
    }
    
    private var resizeHandles: some View {
        GeometryReader { geo in
            HStack {
                // Left handle
                ResizeHandle()
                    .offset(x: -3)
                    .position(x: 0, y: geo.size.height / 2)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let change = -value.translation.width
                                let newWidth = overlay.width + change
                                let constrainedWidth = min(max(100, newWidth), viewModel.photoFrame.width - 40)
                                viewModel.updateTextOverlayWidth(id: overlay.id, width: constrainedWidth)
                            }
                    )
                
                Spacer()
                
                // Right handle
                ResizeHandle()
                    .offset(x: 3)
                    .position(x: geo.size.width, y: geo.size.height / 2)
                    .gesture(
                        DragGesture(coordinateSpace: .global)
                            .onChanged { value in
                                let startX = geo.frame(in: .global).maxX
                                let dragX = value.location.x
                                let newWidth = overlay.width + (dragX - startX)
                                let constrainedWidth = min(max(100, newWidth), viewModel.photoFrame.width - 40)
                                viewModel.updateTextOverlayWidth(id: overlay.id, width: constrainedWidth)
                            }
                    )
            }
        }
    }
    
    private var dragGesture: some Gesture {
        DragGesture(coordinateSpace: .local)
            .onChanged { value in
                let clampedPosition = clampPosition(
                    value.location,
                    in: viewModel.photoFrame,
                    textWidth: overlay.width
                )
                viewModel.updatePosition(
                    clampedPosition,
                    for: overlay.id,
                    in: viewModel.photoFrame
                )
            }
    }
    
    private func submitText() {
        viewModel.updateTextOverlay(id: overlay.id, text: editingText)
        isTyping = false
    }
    
    private func clampPosition(_ position: CGPoint, in frame: CGRect, textWidth: CGFloat) -> CGPoint {
        return CGPoint(
            x: min(max(position.x, textWidth/2 + 20), frame.width - textWidth/2 - 20),
            y: min(max(position.y, 20), frame.height - 20)
        )
    }
} 
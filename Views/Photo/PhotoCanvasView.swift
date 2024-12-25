//
//  PhotoCanvasView.swift
//  Snaply
//
//  Created by Omar Swidan on 12/15/24.
//

import SwiftUI
import PhotosUI

struct PhotoCanvasView: View {
    @ObservedObject var viewModel: DiaryViewModel
    @Binding var activeTextId: UUID?
    @Binding var isTyping: Bool
    @Binding var showingEmotionPicker: Bool
    @Binding var selectedItem: PhotosPickerItem?
    let containerWidth: CGFloat
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if let currentEntry = viewModel.currentEntry {
                // Text overlays layer
                ZStack {
                    // Base photo layer with fixed height
                    Image(uiImage: currentEntry.photo)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: containerWidth)
                        .frame(height: UIScreen.main.bounds.height * 0.7)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .background(
                            GeometryReader { geo in
                                Color.clear.preference(
                                    key: FramePreferenceKey.self,
                                    value: geo.frame(in: .local)
                                )
                            }
                        )
                    
                    // Text overlays layer in a fixed size container
                    ForEach(currentEntry.textOverlays) { overlay in
                        EditableTextOverlay(
                            viewModel: viewModel,
                            overlay: overlay,
                            containerWidth: containerWidth,
                            activeTextId: $activeTextId,
                            isTyping: $isTyping
                        )
                        .frame(width: containerWidth)
                        .frame(height: UIScreen.main.bounds.height * 0.7)
                    }
                }
                .frame(width: containerWidth)
                .frame(height: UIScreen.main.bounds.height * 0.7)
                .padding(.horizontal, 16)
                
                // Drawing paths layer
                ForEach(currentEntry.drawingPaths) { path in
                    Path { p in
                        guard let first = path.points.first else { return }
                        p.move(to: first)
                        for point in path.points.dropFirst() {
                            p.addLine(to: point)
                        }
                    }
                    .stroke(path.color, lineWidth: path.lineWidth)
                }
                
                // Current drawing path if in drawing mode
                if viewModel.isDrawing, let currentLine = viewModel.currentLine {
                    Path { path in
                        guard let first = currentLine.points.first else { return }
                        path.move(to: first)
                        for point in currentLine.points.dropFirst() {
                            path.addLine(to: point)
                        }
                    }
                    .stroke(viewModel.selectedColor, lineWidth: 3)
                }
                
                // Action Bar Overlay
                if let activeId = activeTextId, !isTyping,
                   let activeOverlay = currentEntry.textOverlays.first(where: { $0.id == activeId }) {
                    VStack {
                        TextFieldActionsBar(
                            viewModel: viewModel,
                            overlayId: activeId,
                            fontSize: .constant(activeOverlay.style.fontSize),
                            selectedFont: .constant(activeOverlay.style.fontStyle),
                            textColor: .constant(activeOverlay.color),
                            activeTextId: $activeTextId
                        )
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        Spacer()
                    }
                }
                
                // Footer overlay - position it inside the photo's bounds
                FooterView(
                    viewModel: viewModel,
                    activeTextId: $activeTextId,
                    isTyping: $isTyping,
                    showingEmotionPicker: $showingEmotionPicker,
                    selectedItem: $selectedItem
                )
                .padding(.horizontal, 16)
            }
        }
        .frame(height: UIScreen.main.bounds.height * 0.7)
        .contentShape(Rectangle())
        .gesture(
            viewModel.isDrawing ?
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let point = value.location
                    if viewModel.currentLine == nil {
                        viewModel.currentLine = Models.DrawingPath(points: [point], color: viewModel.selectedColor)
                    } else {
                        viewModel.currentLine?.points.append(point)
                    }
                }
                .onEnded { _ in
                    if let line = viewModel.currentLine {
                        viewModel.addDrawingPath(line)
                        viewModel.currentLine = nil
                    }
                }
            : nil
        )
        .onTapGesture {
            if isTyping && activeTextId != nil {
                viewModel.updateTextOverlay(
                    id: activeTextId!,
                    text: viewModel.currentEntry?.textOverlays.first(where: { $0.id == activeTextId })?.text ?? ""
                )
                isTyping = false
            }
            activeTextId = nil
        }
        .onPreferenceChange(FramePreferenceKey.self) { frame in
            viewModel.photoFrame = frame
        }
    }
}


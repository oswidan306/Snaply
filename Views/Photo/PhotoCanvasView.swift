//
//  PhotoCanvasView.swift
//  Snaply
//
//  Created by Omar Swidan on 12/15/24.
//

import SwiftUI

struct PhotoCanvasView: View {
    @ObservedObject var viewModel: DiaryViewModel
    @Binding var activeTextId: UUID?
    @Binding var isTyping: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base photo layer
                if let currentEntry = viewModel.currentEntry {
                    Image(uiImage: currentEntry.photo)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width - 32)
                        .frame(height: UIScreen.main.bounds.height * 0.7)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 16)
                        .background(
                            GeometryReader { geo in
                                Color.clear.preference(
                                    key: FramePreferenceKey.self,
                                    value: geo.frame(in: .local)
                                )
                            }
                        )
                    
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
                    
                    // Text overlays layer
                    ForEach(currentEntry.textOverlays) { overlay in
                        EditableTextOverlay(
                            viewModel: viewModel,
                            overlay: overlay,
                            activeTextId: $activeTextId,
                            isTyping: $isTyping
                        )
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
                }
            }
            .contentShape(Rectangle())
            .gesture(
                viewModel.isDrawing ?
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let point = value.location
                        if viewModel.currentLine == nil {
                            viewModel.currentLine = DrawingPath(points: [point], color: viewModel.selectedColor)
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
        .frame(height: UIScreen.main.bounds.height * 0.7)
    }
}


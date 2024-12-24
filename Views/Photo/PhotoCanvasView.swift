import SwiftUI

struct PhotoCanvasView: View {
    @ObservedObject var viewModel: DiaryViewModel
    @Binding var activeTextId: UUID?
    @Binding var isTyping: Bool
    let containerWidth: CGFloat
    
    var body: some View {
        let height = UIScreen.main.bounds.height * 0.64
        
        ZStack(alignment: .center) {
            if let currentEntry = viewModel.currentEntry {
                // Image layer
                Image(uiImage: currentEntry.photo)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: containerWidth, maxHeight: height)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Overlay content
                ZStack(alignment: .center) {
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
                    
                    // Current drawing path
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
                .frame(maxWidth: containerWidth, maxHeight: height)
            }
        }
        .frame(width: containerWidth, height: height)
    }
}

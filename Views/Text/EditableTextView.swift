import SwiftUI
import UIKit

struct EditableTextView: View {
    @ObservedObject var viewModel: DiaryViewModel
    let overlay: Models.TextOverlay
    @Binding var activeTextId: UUID?
    @Binding var isTyping: Bool
    
    // Local state for text editing
    @State private var localText: String
    @State private var fontSize: CGFloat
    @State private var fontStyle: Models.FontStyle
    @State private var textColor: Color
    @State private var width: CGFloat
    @State private var position: CGPoint
    
    init(viewModel: DiaryViewModel, overlay: Models.TextOverlay, activeTextId: Binding<UUID?>, isTyping: Binding<Bool>) {
        self.viewModel = viewModel
        self.overlay = overlay
        self._activeTextId = activeTextId
        self._isTyping = isTyping
        
        // Initialize state values
        _localText = State(initialValue: overlay.text)
        _fontSize = State(initialValue: overlay.style.fontSize)
        _fontStyle = State(initialValue: overlay.style.fontStyle)
        _textColor = State(initialValue: overlay.color)
        _width = State(initialValue: overlay.width)
        _position = State(initialValue: overlay.position)
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Text Field
            TextField("Enter text", text: $localText)
                .font(fontStyle == .regular ? .system(size: fontSize) : 
                      fontStyle == .bold ? .system(size: fontSize, weight: .bold) :
                      .system(size: fontSize).italic())
                .foregroundColor(textColor)
                .frame(width: width)
                .position(position)
                .disabled(!isTyping)
                .onTapGesture {
                    if activeTextId == overlay.id {
                        isTyping = true
                    } else {
                        activeTextId = overlay.id
                    }
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if !isTyping {
                                position = CGPoint(
                                    x: position.x + value.translation.width,
                                    y: position.y + value.translation.height
                                )
                            }
                        }
                        .onEnded { _ in
                            updateOverlay()
                        }
                )
            
            // Actions Bar (only show when active and not typing)
            if activeTextId == overlay.id && !isTyping {
                HStack(spacing: 12) {
                    // Font size controls
                    FontSizeControls(fontSize: $fontSize)
                    
                    // Font style controls
                    FontStyleControls(fontStyle: $fontStyle)
                    
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
                .position(x: position.x, y: max(50, position.y - 60))
            }
            
            // Resize handle (only show when active)
            if activeTextId == overlay.id {
                Circle()
                    .fill(Color.blue.opacity(0.5))
                    .frame(width: 20, height: 20)
                    .position(x: position.x + width/2, y: position.y)
                    .gesture(DragGesture()
                        .onChanged { value in
                            width = max(100, width + value.translation.width)
                        }
                    )
            }
        }
        .onChange(of: fontSize) { _ in updateOverlay() }
        .onChange(of: fontStyle) { _ in updateOverlay() }
        .onChange(of: textColor) { _ in updateOverlay() }
        .onChange(of: localText) { _ in updateOverlay() }
    }
    
    private func updateOverlay() {
        viewModel.updateTextOverlay(
            id: overlay.id,
            text: localText,
            position: position,
            style: Models.TextStyle(fontSize: fontSize, fontStyle: fontStyle),
            color: textColor,
            width: width
        )
    }
}

// Helper Views
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
import SwiftUI
import PhotosUI

struct AddEntryView: View {
    @ObservedObject var viewModel: DiaryViewModel
    @Binding var selectedItem: PhotosPickerItem?
    @State private var activeTextId: UUID?
    @State private var isTyping: Bool = false
    
    var body: some View {
        Group {
            if let _ = viewModel.currentEntry {
                PhotoCanvasView(
                    viewModel: viewModel,
                    activeTextId: $activeTextId,
                    isTyping: $isTyping,
                    selectedItem: $selectedItem,
                    containerWidth: UIScreen.main.bounds.width - 32
                )
            } else {
                PhotoPickerView(
                    selectedItem: $selectedItem,
                    containerWidth: UIScreen.main.bounds.width - 32
                )
            }
        }
        .padding(.top, 12)
    }
} 
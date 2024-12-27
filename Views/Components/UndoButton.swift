import SwiftUI

struct UndoButton: View {
    @ObservedObject var viewModel: DiaryViewModel
    
    var body: some View {
        Button(action: {
            viewModel.undo()
        }) {
            Image(systemName: "arrow.uturn.backward")
                .resizable()
                .frame(width: 28, height: 28)
                .foregroundColor(.white)
                .padding([.horizontal], 10)
                .padding([.vertical], 8)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.3))
                )
        }
        .disabled(!viewModel.hasEdits())
    }
}

#Preview {
    UndoButton(viewModel: PreviewData.viewModel)
} 

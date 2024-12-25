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
                .foregroundColor(.black)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
        }
        .disabled(!viewModel.hasEdits())
        .background(
            Capsule()
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 4)
        )
    }
}

#Preview {
    UndoButton(viewModel: PreviewData.viewModel)
} 

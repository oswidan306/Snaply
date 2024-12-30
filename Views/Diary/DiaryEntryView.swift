import SwiftUI

struct DiaryEntryView: View {
    @ObservedObject var viewModel: DiaryViewModel
    let containerWidth: CGFloat
    
    var body: some View {
        VStack {
            TextEditor(text: Binding(
                get: { viewModel.currentEntry?.diaryText ?? "" },
                set: { viewModel.updateDiaryText($0) }
            ))
            .font(.system(size: 16))
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: containerWidth)
        .frame(height: UIScreen.main.bounds.height * 0.7)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 10)
        .rotation3DEffect(
            .degrees(180),
            axis: (x: 0.0, y: 1.0, z: 0.0)
        )
    }
} 
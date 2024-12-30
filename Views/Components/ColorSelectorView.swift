import SwiftUI

struct ColorSelectorView: View {
    @ObservedObject var viewModel: DiaryViewModel
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(viewModel.availableColors, id: \.self) { color in
                Circle()
                    .fill(color)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: viewModel.selectedColor == color ? 2 : 0)
                    )
                    .onTapGesture {
                        viewModel.selectedColor = color
                    }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.3))
        .cornerRadius(20)
    }
} 
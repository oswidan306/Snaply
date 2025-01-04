import SwiftUI

struct EmotionTagView: View {
    let emotion: Emotion
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(emotion.emoji)
                Text(emotion.name)
                    .font(.system(size: 14))
            }
            .padding(.horizontal, 12)
            .frame(height: 32)
            .background(isSelected ? Color.black.opacity(0.8) : Color.gray.opacity(0.1))
            .foregroundColor(isSelected ? .white : .black)
            .cornerRadius(16)
        }
    }
} 
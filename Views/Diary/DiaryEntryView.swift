import SwiftUI

struct DiaryEntryView: View {
    @ObservedObject var viewModel: DiaryViewModel
    let containerWidth: CGFloat
    private let fontSize: CGFloat = 16
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title field
            PlaceholderTextEditor(
                placeholder: "Title",
                text: Binding(
                    get: { viewModel.currentEntry?.diaryTitle ?? "" },
                    set: { viewModel.updateDiaryTitle($0) }
                ),
                font: .system(size: fontSize + 4, weight: .medium)
            )
            .padding(.horizontal)
            .padding(.top, 20)
            
            // Emotions
            ZStack(alignment: .leading) {
                // Scrolling emotions
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.emotions) { emotion in
                            EmotionTagView(
                                emotion: emotion,
                                isSelected: emotion.isSelected,
                                action: {
                                    viewModel.toggleEmotion(emotion)
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .frame(height: 32)
                }
                .frame(height: 32)
                
                // Left fade
                LinearGradient(
                    gradient: Gradient(colors: [.white, .white.opacity(0)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 20)
                .allowsHitTesting(false)
                
                // Right fade
                LinearGradient(
                    gradient: Gradient(colors: [.white.opacity(0), .white]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 20)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .allowsHitTesting(false)
            }
            .frame(height: 32)
            .padding(.top, 12)
            
            // Main diary text
            TextEditor(text: Binding(
                get: { viewModel.currentEntry?.diaryText ?? "" },
                set: { viewModel.updateDiaryText($0) }
            ))
            .font(.system(size: fontSize))
            .foregroundColor(.gray.opacity(0.96))
            .lineSpacing((fontSize * 1.2) - (fontSize * 1.33))
            .padding(.horizontal)
            .padding(.top, 8)
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

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct PlaceholderTextEditor: View {
    let placeholder: String
    @Binding var text: String
    let font: Font
    
    var body: some View {
        VStack(spacing: 0) {
            TextField(placeholder, text: $text, axis: .vertical)
                .font(font)
                .textFieldStyle(.plain)
                .lineLimit(1...3)
                .padding(.horizontal, 5)
                .frame(minHeight: 35)
                .fixedSize(horizontal: false, vertical: true)
            
            Divider()
                .background(Color.gray.opacity(0.15))
        }
    }
}

// Add this extension to help calculate text height
extension String {
    func size(withFont font: Font) -> CGSize {
        let uiFont = font.toUIFont() ?? .systemFont(ofSize: 16)
        let attributes = [NSAttributedString.Key.font: uiFont]
        let size = (self as NSString).boundingRect(
            with: CGSize(width: UIScreen.main.bounds.width - 60, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        ).size
        return size
    }
}

// Add this extension to convert SwiftUI Font to UIFont
extension Font {
    func toUIFont() -> UIFont? {
        let fontName = String(describing: self)
        if fontName.contains("size:") {
            let sizeString = fontName.components(separatedBy: "size: ")[1]
            let size = CGFloat(Double(sizeString) ?? 16)
            return .systemFont(ofSize: size)
        }
        return .systemFont(ofSize: 16)
    }
} 
import SwiftUI
import UIKit

struct DiaryEntryView: View {
    @ObservedObject var viewModel: DiaryViewModel
    let containerWidth: CGFloat
    private let fontSize: CGFloat = 16
    @Environment(\.dismiss) private var dismiss
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Fixed header section
            VStack(alignment: .leading, spacing: 8) {
                // Title and emotions row
                HStack(spacing: 8) {
                    // Title field
                    PlaceholderTextEditor(
                        placeholder: "Title",
                        text: Binding(
                            get: { viewModel.currentEntry?.diaryTitle ?? "" },
                            set: { viewModel.updateDiaryTitle($0) }
                        ),
                        font: .system(size: fontSize + 4, weight: .medium)
                    )
                    
                    // Emotion picker button
                    Button(action: { viewModel.toggleEmotionPicker() }) {
                        Image("emotions_icon")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28, height: 28)
                            .foregroundColor(.gray.opacity(0.8))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .overlay(
                    VStack {
                        Spacer()
                        Divider()
                            .background(Color.gray.opacity(0.15))
                            .padding(.horizontal)
                    }
                )
                
                // Selected emotions (emoji only)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.emotions.filter { $0.isSelected }) { emotion in
                            Text(emotion.emoji)
                                .font(.system(size: 20))  // Adjust emoji size as needed
                        }
                    }
                }
                .padding(.horizontal)
                
                // Emotion picker overlay (when active)
                if viewModel.isShowingEmotionPicker {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.emotions) { emotion in
                                EmotionTagView(
                                    emotion: emotion,
                                    isSelected: emotion.isSelected,
                                    action: { 
                                        viewModel.toggleEmotion(emotion)
                                        // Auto close when 3 emotions are selected
                                        if viewModel.selectedEmotionsCount >= 3 {
                                            viewModel.toggleEmotionPicker()
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            
            // Scrollable content section
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    PlaceholderTextEditor2(
                        placeholder: "Reflection",
                        text: Binding(
                            get: { viewModel.currentEntry?.diaryText ?? "" },
                            set: { viewModel.updateDiaryText($0) }
                        ),
                        font: .system(size: fontSize)
                    )
                    .id("textEditor")
                    .font(.system(size: fontSize))
                    .foregroundColor(.gray.opacity(0.9))
                    .lineSpacing((fontSize * 1.2) - (fontSize * 1.33))
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.height * 0.7 - (keyboardHeight > 0 ? 340 : 80))  // Adjust height based on keyboard
                    .background(
                        GeometryReader { geo in
                            Color.clear.preference(
                                key: ViewOffsetKey.self,
                                value: geo.frame(in: .named("scroll")).maxY
                            )
                        }
                    )
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ViewOffsetKey.self) { maxY in
                    if maxY > (UIScreen.main.bounds.height * 0.7 - 92) {
                        withAnimation {
                            proxy.scrollTo("textEditor", anchor: .bottom)
                        }
                    }
                }
                .overlay(
                    VStack {
                        Spacer()
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0),
                                .white
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 92)
                    }
                )
            }
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
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.height > 50 {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                     to: nil,
                                                     from: nil,
                                                     for: nil)
                    }
                }
        )
        .onAppear {
            setupKeyboardNotifications()
        }
        .onDisappear {
            removeKeyboardNotifications()
        }
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                self.keyboardHeight = keyboardFrame.height
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            self.keyboardHeight = 0
        }
    }
    
    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
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
        VStack(alignment: .leading, spacing: 0) {
            TextField(placeholder, text: $text, axis: .vertical)
                .font(font)
                .textFieldStyle(.plain)
                .lineLimit(1...3)
                .padding(.horizontal, 5)
                .frame(minHeight: 35)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct PlaceholderTextEditor2: View {
    let placeholder: String
    @Binding var text: String
    let font: Font
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.gray.opacity(0.5))
                    .font(font)
                    .padding(.horizontal, 5)
                    .padding(.top, 7)
            }
            
            TextEditor(text: $text)
                .font(font)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
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

// Add this struct for the preference key
struct ViewOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
} 

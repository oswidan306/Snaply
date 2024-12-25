import SwiftUI

public extension Models {
    public struct TextStyle {
        public var fontSize: CGFloat
        public var fontStyle: Models.FontStyle
        
        public init(fontSize: CGFloat = 24, fontStyle: Models.FontStyle = .regular) {
            self.fontSize = fontSize
            self.fontStyle = fontStyle
        }
    }
} 
import SwiftUI

public extension Models {
    public enum FontStyle: String, CaseIterable {
        case regular = "Regular"
        case bold = "Bold"
        case italic = "Italic"
        
        public func font(size: CGFloat) -> Font {
            switch self {
            case .regular:
                return .system(size: size)
            case .bold:
                return .system(size: size, weight: .bold)
            case .italic:
                return .system(size: size).italic()
            }
        }
    }
} 
import SwiftUI

public extension Models {
    enum FontStyle {
        case regular
        case bold
        case italic
        
        func font(size: CGFloat) -> Font {
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
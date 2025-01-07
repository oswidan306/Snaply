import SwiftUI

public enum Models {
    public enum FontStyle {
        case regular
        case bold
        case italic
    }
    
    public enum FontFamily: String, CaseIterable {
        case arial = "Arial"
        case timesNewRoman = "Times New Roman"
        case courier = "Courier"
        case snellRoundhand = "SnellRoundhand"
        
        public var fontName: String {
            switch self {
            case .arial: return "ArialMT"
            case .timesNewRoman: return "Times New Roman"
            case .courier: return "Courier"
            case .snellRoundhand: return "SnellRoundhand"
            }
        }
    }
    
    public struct TextStyle {
        public var fontSize: CGFloat
        public var fontStyle: FontStyle
        public var fontFamily: FontFamily
        
        public init(fontSize: CGFloat = 24, fontStyle: FontStyle = .regular, fontFamily: FontFamily = .arial) {
            self.fontSize = fontSize
            self.fontStyle = fontStyle
            self.fontFamily = fontFamily
        }
    }
    
    public struct TextOverlay: Identifiable {
        public let id: UUID
        public var text: String
        public var position: CGPoint
        public var style: TextStyle
        public var color: Color
        public var width: CGFloat
        
        public init(
            id: UUID = UUID(),
            text: String,
            position: CGPoint,
            style: TextStyle,
            color: Color,
            width: CGFloat = 200
        ) {
            self.id = id
            self.text = text
            self.position = position
            self.style = style
            self.color = color
            self.width = width
        }
    }
    
    public struct PhotoEntry: Identifiable {
        public let id: UUID
        public let photo: UIImage
        public var textOverlays: [TextOverlay]
        public var drawingPaths: [DrawingPath]
        public var emotions: [String]
        public var diaryText: String
        public var diaryTitle: String
        public var date: Date
        private var undoStack: [[TextOverlay]]
        
        public init(
            id: UUID = UUID(),
            photo: UIImage,
            textOverlays: [TextOverlay] = [],
            drawingPaths: [DrawingPath] = [],
            emotions: [String] = [],
            diaryText: String = "",
            diaryTitle: String = "",
            date: Date = Date()
        ) {
            self.id = id
            self.photo = photo
            self.textOverlays = textOverlays
            self.drawingPaths = drawingPaths
            self.emotions = emotions
            self.diaryText = diaryText
            self.diaryTitle = diaryTitle
            self.date = date
            self.undoStack = []
        }
        
        public mutating func saveState() {
            undoStack.append(textOverlays)
        }
        
        public mutating func undo() -> Bool {
            guard let previousState = undoStack.popLast() else { return false }
            textOverlays = previousState
            return true
        }
    }
    
    public struct DrawingPath: Identifiable {
        public let id: UUID
        public var points: [CGPoint]
        public var color: Color
        public var lineWidth: CGFloat
        
        public init(
            id: UUID = UUID(),
            points: [CGPoint],
            color: Color,
            lineWidth: CGFloat = 3
        ) {
            self.id = id
            self.points = points
            self.color = color
            self.lineWidth = lineWidth
        }
    }
} 
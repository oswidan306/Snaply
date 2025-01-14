import Foundation
import SwiftData
import SwiftUI

@Model
final class Item {
    var id: UUID
    var photo: Data?
    var text: String
    var title: String
    var emotions: [String]
    var timestamp: Date
    var lastModifiedAt: Date
    var textOverlays: [TextOverlay]
    var drawingPaths: [DrawingPath]
    
    init(
        id: UUID = UUID(),
        photo: Data? = nil,
        text: String = "",
        title: String = "",
        emotions: [String] = [],
        timestamp: Date = Date(),
        lastModifiedAt: Date = Date(),
        textOverlays: [TextOverlay] = [],
        drawingPaths: [DrawingPath] = []
    ) {
        self.id = id
        self.photo = photo
        self.text = text
        self.title = title
        self.emotions = emotions
        self.timestamp = timestamp
        self.lastModifiedAt = lastModifiedAt
        self.textOverlays = textOverlays
        self.drawingPaths = drawingPaths
    }
    
    // Helper method to update modification time
    func touch() {
        lastModifiedAt = Date()
    }
}

// MARK: - Supporting Types
@Model
final class TextOverlay {
    var id: UUID
    var text: String
    var position: CGPoint
    var storedColor: StorableColor
    var fontFamily: String
    var fontSize: Double
    var fontStyle: String
    
    init(
        id: UUID = UUID(),
        text: String,
        position: CGPoint,
        color: Color = .black,
        fontFamily: String = "Arial",
        fontSize: Double = 14,
        fontStyle: String = "regular"
    ) {
        self.id = id
        self.text = text
        self.position = position
        self.storedColor = StorableColor(color: color)
        self.fontFamily = fontFamily
        self.fontSize = fontSize
        self.fontStyle = fontStyle
    }
    
    var color: Color {
        get { storedColor.color }
        set { storedColor = StorableColor(color: newValue) }
    }
}

@Model
final class DrawingPath {
    var id: UUID
    var points: [CGPoint]
    var storedColor: StorableColor
    var lineWidth: Double
    
    init(
        id: UUID = UUID(),
        points: [CGPoint],
        color: Color = .black,
        lineWidth: Double = 2
    ) {
        self.id = id
        self.points = points
        self.storedColor = StorableColor(color: color)
        self.lineWidth = lineWidth
    }
    
    var color: Color {
        get { storedColor.color }
        set { storedColor = StorableColor(color: newValue) }
    }
} 
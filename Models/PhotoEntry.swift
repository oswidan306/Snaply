import SwiftUI

#if canImport(UIKit)
import UIKit
#else
import AppKit
typealias UIImage = NSImage
#endif

public extension Models {
    struct PhotoEntry: Identifiable {
        public let id: UUID
        public let photo: UIImage
        public var textOverlays: [TextOverlay]
        public var drawingPaths: [DrawingPath]
        public var emotions: [String]
        public var diaryText: String
        public var diaryTitle: String
        private var history: [(textOverlays: [TextOverlay], drawingPaths: [DrawingPath])]
        
        public init(
            id: UUID = UUID(),
            photo: UIImage,
            textOverlays: [TextOverlay] = [],
            drawingPaths: [DrawingPath] = [],
            emotions: [String] = [],
            diaryText: String = "",
            diaryTitle: String = ""
        ) {
            self.id = id
            self.photo = photo
            self.textOverlays = textOverlays
            self.drawingPaths = drawingPaths
            self.emotions = emotions
            self.diaryText = diaryText
            self.diaryTitle = diaryTitle
            self.history = []
        }
        
        mutating func saveState() {
            history.append((textOverlays: textOverlays, drawingPaths: drawingPaths))
        }
        
        mutating func undo() -> Bool {
            guard let previousState = history.popLast() else { return false }
            textOverlays = previousState.textOverlays
            drawingPaths = previousState.drawingPaths
            return true
        }
    }
}

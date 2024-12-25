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
        private var history: [[TextOverlay]]
        
        public init(
            id: UUID = UUID(),
            photo: UIImage,
            textOverlays: [TextOverlay] = [],
            drawingPaths: [DrawingPath] = [],
            emotions: [String] = []
        ) {
            self.id = id
            self.photo = photo
            self.textOverlays = textOverlays
            self.drawingPaths = drawingPaths
            self.emotions = emotions
            self.history = []
        }
        
        mutating func saveState() {
            history.append(textOverlays)
        }
        
        mutating func undo() -> Bool {
            guard let previousState = history.popLast() else { return false }
            textOverlays = previousState
            return true
        }
    }
}

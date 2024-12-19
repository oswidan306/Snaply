import Foundation
import SwiftUI


#if canImport(UIKit)
import UIKit
#else
import AppKit
typealias UIImage = NSImage
#endif

struct PhotoEntry: Identifiable, Hashable {
    let id: UUID
    let date: Date
    var photo: UIImage
    var emotions: [String]
    var textOverlays: [TextOverlay]
    var drawingData: Data?
    var previousStates: [PhotoEntry]
    var drawingPaths: [DrawingPath]
    
    init(id: UUID = UUID(),
         date: Date = Date(),
         photo: UIImage,
         emotions: [String] = [],
         textOverlays: [TextOverlay] = [],
         drawingPaths: [DrawingPath] = [],
         drawingData: Data? = nil,
         previousStates: [PhotoEntry] = []) {
        self.id = id
        self.date = date
        self.photo = photo
        self.emotions = emotions
        self.textOverlays = textOverlays
        self.drawingData = drawingData
        self.previousStates = previousStates
        self.drawingPaths = drawingPaths
    }
    
    mutating func saveState() {
        var stateCopy = self
        stateCopy.previousStates = []
        previousStates.append(stateCopy)
    }
    
    mutating func undo() -> Bool {
        guard let previousState = previousStates.popLast() else { return false }
        textOverlays = previousState.textOverlays
        emotions = previousState.emotions
        drawingData = previousState.drawingData
        drawingPaths = previousState.drawingPaths
        return true
    }
    
    static func == (lhs: PhotoEntry, rhs: PhotoEntry) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

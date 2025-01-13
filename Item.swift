import Foundation
import SwiftData

@Model
final class Item {
    var id: UUID
    var timestamp: Date
    var text: String
    var emotions: [String]
    
    init(timestamp: Date = Date(), text: String = "", emotions: [String] = []) {
        self.id = UUID()
        self.timestamp = timestamp
        self.text = text
        self.emotions = emotions
    }
} 

import Foundation
import CoreGraphics

struct CloudEntry: Codable {
    let id: String
    let text: String
    let title: String
    let emotions: [String]
    let photoURL: String?
    let timestamp: Date
    let textOverlays: [CloudTextOverlay]
    let drawingPaths: [CloudDrawingPath]
    
    struct CloudTextOverlay: Codable {
        let id: String
        let text: String
        let position: PointWrapper
        let color: CloudColor
        let fontFamily: String
        let fontSize: Double
        let fontStyle: String
    }
    
    struct CloudDrawingPath: Codable {
        let id: String
        let points: [PointWrapper]
        let color: CloudColor
        let lineWidth: Double
    }
    
    struct CloudColor: Codable {
        let red: Double
        let green: Double
        let blue: Double
        let opacity: Double
    }
    
    struct PointWrapper: Codable {
        let x: Double
        let y: Double
        
        init(point: CGPoint) {
            self.x = Double(point.x)
            self.y = Double(point.y)
        }
        
        var point: CGPoint {
            CGPoint(x: x, y: y)
        }
    }
}

// Extension to convert between CGPoint and PointWrapper
extension CGPoint {
    var wrapped: CloudEntry.PointWrapper {
        CloudEntry.PointWrapper(point: self)
    }
} 
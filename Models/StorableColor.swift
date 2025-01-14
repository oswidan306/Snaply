import SwiftUI
import SwiftData

@Model
final class StorableColor {
    var red: Double
    var green: Double
    var blue: Double
    var opacity: Double
    
    init(color: Color) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var opacity: CGFloat = 0
        
        UIColor(color).getRed(&red, green: &green, blue: &blue, alpha: &opacity)
        
        self.red = Double(red)
        self.green = Double(green)
        self.blue = Double(blue)
        self.opacity = Double(opacity)
    }
    
    var color: Color {
        Color(.displayP3, red: red, green: green, blue: blue, opacity: opacity)
    }
} 
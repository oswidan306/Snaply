//
//  TextOverlay.swift
//  Snaply
//
//  Created by Omar Swidan on 12/15/24.
//

import SwiftUI

struct TextOverlay: Identifiable {
    let id: UUID
    var text: String
    var position: CGPoint
    var style: TextFieldStyle
    var color: Color = .white
    var width: CGFloat = 200  // Default width
    
    init(id: UUID = UUID(),
         text: String = "Tap to edit",
         position: CGPoint,
         style: TextFieldStyle = TextFieldStyle(),
         color: Color = .white,
         width: CGFloat = 200) {
        self.id = id
        self.text = text
        self.position = position
        self.style = style
        self.color = color
        self.width = width
    }
}

struct TextFieldStyle {
    var fontSize: CGFloat = 24
    var fontStyle: FontStyle = .system
}

enum FontStyle: String, CaseIterable {
    case system = "SF Pro"
    case serif = "Times New Roman"
    case cursive = "Snell Roundhand"
    case mono = "Menlo"
    
    func font(size: CGFloat) -> Font {
        switch self {
        case .system:
            return .system(size: size)
        case .serif:
            return .custom(self.rawValue, size: size)
        case .cursive:
            return .custom(self.rawValue, size: size)
        case .mono:
            return .custom(self.rawValue, size: size)
        }
    }
}


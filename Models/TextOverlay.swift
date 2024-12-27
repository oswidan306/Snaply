//
//  TextOverlay.swift
//  Snaply
//
//  Created by Omar Swidan on 12/15/24.
//

import SwiftUI

public extension Models {
    struct TextStyle {
        var fontSize: CGFloat
        var fontStyle: FontStyle
        
        init(fontSize: CGFloat = 24, fontStyle: FontStyle = .regular) {
            self.fontSize = fontSize
            self.fontStyle = fontStyle
        }
    }
    
    struct TextOverlay: Identifiable {
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
}


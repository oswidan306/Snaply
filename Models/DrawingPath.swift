//
//  DrawingPath.swift
//  Snaply
//
//  Created by Omar Swidan on 12/15/24.
//

import SwiftUI

public extension Models {
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


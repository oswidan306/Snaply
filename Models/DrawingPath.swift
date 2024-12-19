//
//  DrawingPath.swift
//  Snaply
//
//  Created by Omar Swidan on 12/15/24.
//

import SwiftUI

struct DrawingPath: Identifiable {
    let id: UUID = UUID()
    var points: [CGPoint]
    var color: Color
    var lineWidth: CGFloat = 3
    
    init(points: [CGPoint], color: Color = .white) {
        self.points = points
        self.color = color
    }
}


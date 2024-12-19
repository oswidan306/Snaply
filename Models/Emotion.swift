//
//  Emotion.swift
//  Snaply
//
//  Created by Omar Swidan on 12/15/24.
//

import Foundation

struct Emotion: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let emoji: String
    var isSelected: Bool = false
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


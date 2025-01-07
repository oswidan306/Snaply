//
//  Emotion.swift
//  Snaply
//
//  Created by Omar Swidan on 12/15/24.
//

import SwiftUI

public struct Emotion: Identifiable {
    public let id = UUID()
    public let name: String
    public let emoji: String
    public var isSelected: Bool = false
}


//
//  DiaryViewModel.swift
//  Snaply
//
//  Created by Omar Swidan on 12/15/24.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#else
import AppKit
typealias UIImage = NSImage
#endif

class DiaryViewModel: ObservableObject {
    @Published var entries: [PhotoEntry] = []
    @Published var currentEntry: PhotoEntry?
    @Published var draggedOverlayPositions: [UUID: CGPoint] = [:]
    @Published var isDrawing = false
    @Published var currentLine: DrawingPath?
    @Published var drawingPaths: [DrawingPath] = []
    @Published var selectedColor: Color = .white
    @Published var emotions: [Emotion] = [
        Emotion(name: "Joy", emoji: "😊"),
        Emotion(name: "Love", emoji: "❤️"),
        Emotion(name: "Surprise", emoji: "😲"),
        Emotion(name: "Fear", emoji: "😨"),
        Emotion(name: "Anger", emoji: "😡"),
        Emotion(name: "Sadness", emoji: "😔"),
        Emotion(name: "Trust", emoji: "🤞"),
        Emotion(name: "Anxious", emoji: "🤔")
    ]
    
    let availableColors: [Color] = [
        .white, .black, .blue, .green, .red, .purple,
        Color(red: 1.0, green: 0.7, blue: 0.9),  // Lighter pink
        .yellow, .orange
    ]
    
    var photoFrame: CGRect = .zero
    
    var selectedEmotionsCount: Int {
        emotions.filter { $0.isSelected }.count
    }
    
    // MARK: - Photo Management
    
    func addNewPhoto(_ image: UIImage) {
        // Reset all emotion selections
        emotions.indices.forEach { emotions[$0].isSelected = false }
        
        let newEntry = PhotoEntry(photo: image)
        currentEntry = newEntry
        entries.append(newEntry)
    }
    
    func updateEntry(_ entry: PhotoEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
            if currentEntry?.id == entry.id {
                currentEntry = entry
                for overlay in entry.textOverlays {
                    if draggedOverlayPositions[overlay.id] == nil {
                        draggedOverlayPositions[overlay.id] = overlay.position
                    }
                }
            }
        }
    }
    
    // MARK: - Text Overlay Management
    
    func addTextOverlay() {
        guard var entry = currentEntry else { return }
        entry.saveState()
        let centerPosition = CGPoint(x: 0.5, y: 0.5)
        let newOverlay = TextOverlay(text: "Tap to edit", position: centerPosition)
        entry.textOverlays.append(newOverlay)
        updateEntry(entry)
    }
    
    func updateTextOverlay(id: UUID, text: String? = nil, position: CGPoint? = nil) {
        guard var entry = currentEntry else { return }
        if let index = entry.textOverlays.firstIndex(where: { $0.id == id }) {
            if let newText = text {
                entry.textOverlays[index].text = newText
            }
            if let newPosition = position {
                entry.textOverlays[index].position = newPosition
                draggedOverlayPositions[id] = newPosition
            }
            updateEntry(entry)
        }
    }
    
    func updateTextOverlayStyle(id: UUID, fontSize: CGFloat? = nil, fontStyle: FontStyle? = nil, color: Color? = nil) {
        guard var entry = currentEntry else { return }
        if let index = entry.textOverlays.firstIndex(where: { $0.id == id }) {
            entry.saveState()
            if let newSize = fontSize {
                entry.textOverlays[index].style.fontSize = newSize
            }
            if let newStyle = fontStyle {
                entry.textOverlays[index].style.fontStyle = newStyle
            }
            if let newColor = color {
                entry.textOverlays[index].color = newColor
            }
            updateEntry(entry)
        }
    }
    
    func updateTextOverlayWidth(id: UUID, width: CGFloat) {
        guard var entry = currentEntry else { return }
        if let index = entry.textOverlays.firstIndex(where: { $0.id == id }) {
            entry.textOverlays[index].width = width
            updateEntry(entry)
        }
    }
    
    func deleteTextOverlay(id: UUID) {
        guard var entry = currentEntry else { return }
        entry.saveState()
        entry.textOverlays.removeAll(where: { $0.id == id })
        draggedOverlayPositions.removeValue(forKey: id)
        updateEntry(entry)
    }
    
    func duplicateTextOverlay(id: UUID) -> UUID {
        guard var entry = currentEntry,
              let originalOverlay = entry.textOverlays.first(where: { $0.id == id }) else { return id }
        
        entry.saveState()
        let newPosition = CGPoint(
            x: originalOverlay.position.x + 0.05,
            y: originalOverlay.position.y + 0.05
        )
        let newId = UUID()
        let duplicateOverlay = TextOverlay(
            id: newId,
            text: originalOverlay.text,
            position: newPosition,
            style: originalOverlay.style,
            color: originalOverlay.color,
            width: originalOverlay.width
        )
        entry.textOverlays.append(duplicateOverlay)
        updateEntry(entry)
        return newId
    }
    
    // MARK: - Position Management
    
    func getActualPosition(for id: UUID, in frame: CGRect) -> CGPoint {
        let relativePosition = draggedOverlayPositions[id] ??
        currentEntry?.textOverlays.first(where: { $0.id == id })?.position ??
        CGPoint(x: 0.5, y: 0.5)
        
        return CGPoint(
            x: relativePosition.x * frame.width,
            y: relativePosition.y * frame.height
        )
    }
    
    func updatePosition(_ position: CGPoint, for id: UUID, in frame: CGRect) {
        let relativePosition = CGPoint(
            x: position.x / frame.width,
            y: position.y / frame.height
        )
        draggedOverlayPositions[id] = relativePosition
    }
    
    // MARK: - Drawing Management
    
    func addDrawingPath(_ path: DrawingPath) {
        saveState()
        let coloredPath = DrawingPath(points: path.points, color: selectedColor)
        drawingPaths.append(coloredPath)
        if let entry = currentEntry {
            var updatedEntry = entry
            updatedEntry.drawingPaths = drawingPaths
            updateEntry(updatedEntry)
        }
    }
    
    // MARK: - Emotion Management
    
    func toggleEmotion(_ emotion: Emotion) {
        if let index = emotions.firstIndex(where: { $0.id == emotion.id }) {
            if emotions[index].isSelected {
                emotions[index].isSelected = false
            } else if selectedEmotionsCount < 3 {
                emotions[index].isSelected = true
            }
            updateEmotions()
        }
    }
    
    func updateEmotions() {
        guard var entry = currentEntry else { return }
        entry.emotions = emotions.filter { $0.isSelected }.map { $0.name }
        updateEntry(entry)
    }
    
    // MARK: - Undo Management
    func hasEdits() -> Bool {
        guard let entry = currentEntry else { return false }
        return !entry.textOverlays.isEmpty || !entry.drawingPaths.isEmpty
    }
    
    func undo() {
        guard var entry = currentEntry else { return }
        if entry.undo() {
            let remainingPositions = entry.textOverlays.reduce(into: [UUID: CGPoint]()) { dict, overlay in
                dict[overlay.id] = draggedOverlayPositions[overlay.id] ?? overlay.position
            }
            draggedOverlayPositions = remainingPositions
            drawingPaths = entry.drawingPaths
            updateEntry(entry)
        }
    }
    
    private func saveState() {
        guard var entry = currentEntry else { return }
        entry.saveState()
        updateEntry(entry)
    }
}


//
//  DiaryViewModel.swift
//  Snaply
//
//  Created by Omar Swidan on 12/15/24.
//

import SwiftUI
import UIKit

#if canImport(UIKit)
import UIKit
#else
import AppKit
typealias UIImage = NSImage
#endif

public protocol DiaryViewModelProtocol: ObservableObject {
    var entries: [Models.PhotoEntry] { get set }
    var currentEntry: Models.PhotoEntry? { get set }
    // ... add other required properties and methods
}

public class DiaryViewModel: DiaryViewModelProtocol {
    @Published public var entries: [Models.PhotoEntry] = []
    @Published public var currentEntry: Models.PhotoEntry?
    @Published public var draggedOverlayPositions: [UUID: CGPoint] = [:]
    @Published public var isDrawing = false
    @Published public var currentLine: Models.DrawingPath?
    @Published public var drawingPaths: [Models.DrawingPath] = []
    @Published public var selectedColor: Color = .white
    @Published public var isShowingEmotionPicker: Bool = false
    @Published public var isShowingDiary: Bool = false
    @Published public var emotions: [Emotion] = [
        Emotion(name: "Joy", emoji: "😊"),
        Emotion(name: "Love", emoji: "❤️"),
        Emotion(name: "Excited", emoji: "🤩"),
        Emotion(name: "Peaceful", emoji: "😌"),
        Emotion(name: "Proud", emoji: "🥹"),
        Emotion(name: "Grateful", emoji: "🙏"),
        Emotion(name: "Anxious", emoji: "😰"),
        Emotion(name: "Sad", emoji: "😢"),
        Emotion(name: "Angry", emoji: "😠"),
        Emotion(name: "Confused", emoji: "🤔"),
        Emotion(name: "Tired", emoji: "😮‍💨"),
        Emotion(name: "Hopeful", emoji: "✨")
    ]
    
    @Published public var currentMonthYear: String = ""
    @Published public var entriesForCurrentMonth: [Models.PhotoEntry] = []
    private var currentDate = Date()
    
    public let availableColors: [Color] = [
        .white, .black, .blue, .green, .red, .purple,
        Color(red: 1.0, green: 0.7, blue: 0.9),  // Lighter pink
        .yellow, .orange
    ]
    
    public var photoFrame: CGRect = .zero
    
    private let containerWidth: CGFloat
    
    public init(containerWidth: CGFloat) {
        self.containerWidth = containerWidth
    }
    
    public var selectedEmotionsCount: Int {
        emotions.filter { $0.isSelected }.count
    }
    
    // MARK: - Photo Management
    
    public func addNewPhoto(_ image: UIImage) {
        let previousDiaryText = currentEntry?.diaryText ?? ""
        emotions.indices.forEach { emotions[$0].isSelected = false }
        let newEntry = Models.PhotoEntry(
            photo: image,
            diaryText: previousDiaryText
        )
        currentEntry = newEntry
        entries.append(newEntry)
    }
    
    public func updateEntry(_ entry: Models.PhotoEntry) {
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
    
    public func replaceCurrentPhoto(_ image: UIImage) {
        guard var entry = currentEntry else { return }
        let newEntry = Models.PhotoEntry(
            photo: image,
            textOverlays: entry.textOverlays,
            drawingPaths: entry.drawingPaths,
            emotions: entry.emotions,
            diaryText: entry.diaryText
        )
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = newEntry
        }
        currentEntry = newEntry
    }
    
    // MARK: - Text Overlay Management
    
    public func addTextOverlay() {
        guard var mutableEntry = currentEntry else { return }
        mutableEntry.saveState()
        
        // Calculate center position relative to the photo frame
        let centerPosition = CGPoint(
            x: 0.5,  // This gives us center horizontally (50%)
            y: 0.5   // This gives us center vertically (50%)
        )
        
        let newOverlay = Models.TextOverlay(
            text: "Enter text",
            position: centerPosition,
            style: Models.TextStyle(),
            color: .white,
            width: 200
        )
        
        mutableEntry.textOverlays.append(newOverlay)
        updateEntry(mutableEntry)
    }
    
    public func updateTextOverlay(
        id: UUID,
        text: String? = nil,
        position: CGPoint? = nil,
        style: Models.TextStyle? = nil,
        color: Color? = nil,
        width: CGFloat? = nil
    ) {
        guard var entry = currentEntry,
              let index = entry.textOverlays.firstIndex(where: { $0.id == id }) else { return }
        
        var overlay = entry.textOverlays[index]
        
        if let text = text {
            overlay.text = text
        }
        if let position = position {
            // Store the absolute position, not relative to the photo frame
            overlay.position = position
        }
        if let style = style {
            overlay.style = style
        }
        if let color = color {
            overlay.color = color
        }
        if let width = width {
            overlay.width = width
        }
        
        entry.textOverlays[index] = overlay
        updateEntry(entry)
    }
    
    public func updateTextOverlayStyle(
        id: UUID, 
        fontSize: CGFloat? = nil, 
        fontStyle: Models.FontStyle? = nil,
        fontFamily: Models.FontFamily? = nil,
        color: Color? = nil
    ) {
        guard var entry = currentEntry else { return }
        if let index = entry.textOverlays.firstIndex(where: { $0.id == id }) {
            entry.saveState()
            if let newSize = fontSize {
                entry.textOverlays[index].style.fontSize = newSize
            }
            if let newStyle = fontStyle {
                entry.textOverlays[index].style.fontStyle = newStyle
            }
            if let newFamily = fontFamily {
                entry.textOverlays[index].style.fontFamily = newFamily
            }
            if let newColor = color {
                entry.textOverlays[index].color = newColor
            }
            updateEntry(entry)
        }
    }
    
    public func updateTextOverlayWidth(id: UUID, width: CGFloat) {
        guard var entry = currentEntry else { return }
        if let index = entry.textOverlays.firstIndex(where: { $0.id == id }) {
            entry.textOverlays[index].width = width
            updateEntry(entry)
        }
    }
    
    public func deleteTextOverlay(id: UUID) {
        guard var entry = currentEntry else { return }
        entry.saveState()
        entry.textOverlays.removeAll(where: { $0.id == id })
        draggedOverlayPositions.removeValue(forKey: id)
        updateEntry(entry)
    }
    
    public func duplicateTextOverlay(id: UUID) -> UUID {
        guard var entry = currentEntry,
              let originalOverlay = entry.textOverlays.first(where: { $0.id == id }) else { return id }
        
        entry.saveState()
        let newPosition = CGPoint(
            x: originalOverlay.position.x + 0.05,
            y: originalOverlay.position.y + 0.05
        )
        let newId = UUID()
        let duplicateOverlay = Models.TextOverlay(
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
    
    // MARK: - Drawing Management
    
    public func addDrawingPath(_ path: Models.DrawingPath) {
        guard var entry = currentEntry else { return }
        entry.saveState()
        let coloredPath = Models.DrawingPath(points: path.points, color: selectedColor)
        drawingPaths.append(coloredPath)
        entry.drawingPaths = drawingPaths
        updateEntry(entry)
    }
    
    // MARK: - Position Management
    
    public func getActualPosition(for id: UUID, in frame: CGRect) -> CGPoint {
        let relativePosition = draggedOverlayPositions[id] ??
            currentEntry?.textOverlays.first(where: { $0.id == id })?.position ??
            CGPoint(x: 0.5, y: 0.5)
        
        // Simply multiply by frame dimensions since we're already accounting for minX/minY in the view
        return CGPoint(
            x: relativePosition.x * frame.width,
            y: relativePosition.y * frame.height
        )
    }
    
    public func convertToRelativePosition(_ absolutePosition: CGPoint, in frame: CGRect) -> CGPoint {
        // Convert absolute position to percentage (0.0 to 1.0)
        CGPoint(
            x: (absolutePosition.x - frame.minX) / frame.width,
            y: (absolutePosition.y - frame.minY) / frame.height
        )
    }
    
    public func convertToAbsolutePosition(_ relativePosition: CGPoint, in frame: CGRect) -> CGPoint {
        // Convert percentage position to absolute coordinates
        CGPoint(
            x: frame.minX + (relativePosition.x * frame.width),
            y: frame.minY + (relativePosition.y * frame.height)
        )
    }
    
    public func updatePosition(_ absolutePosition: CGPoint, for id: UUID, in frame: CGRect) {
        let relativePosition = convertToRelativePosition(absolutePosition, in: frame)
        updateTextOverlay(id: id, position: relativePosition)
    }
    
    // MARK: - Emotion Management
    
    public func toggleEmotion(_ emotion: Emotion) {
        if let index = emotions.firstIndex(where: { $0.id == emotion.id }) {
            if emotions[index].isSelected {
                emotions[index].isSelected = false
            } else if selectedEmotionsCount < 3 {
                emotions[index].isSelected = true
            }
            updateEmotions()
        }
    }
    
    public func updateEmotions() {
        guard var entry = currentEntry else { return }
        entry.emotions = emotions.filter { $0.isSelected }.map { $0.name }
        updateEntry(entry)
    }
    
    // MARK: - Undo Management
    
    public func hasEdits() -> Bool {
        guard let entry = currentEntry else { return false }
        return !entry.textOverlays.isEmpty || !entry.drawingPaths.isEmpty
    }
    
    public func undo() {
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
    
    public func updateDiaryText(_ text: String) {
        guard var entry = currentEntry else { return }
        entry.diaryText = text
        updateEntry(entry)
    }
    
    public func updateDiaryTitle(_ title: String) {
        guard var entry = currentEntry else { return }
        entry.diaryTitle = title
        updateEntry(entry)
    }
    
    public func toggleDiary() {
        if !isShowingEmotionPicker {
            withAnimation(.easeInOut(duration: 0.6)) {
                isShowingDiary.toggle()
            }
        }
    }
    
    public func toggleEmotionPicker() {
        withAnimation {
            isShowingEmotionPicker.toggle()
            isDrawing = false  // Always disable drawing when toggling emotions
        }
    }
    
    public func previousMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) {
            currentDate = newDate
            updateCurrentMonthYear()
            generateCalendarDays()
        }
    }
    
    public func nextMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) {
            currentDate = newDate
            updateCurrentMonthYear()
            generateCalendarDays()
        }
    }
    
    public func generateCalendarDays() {
        updateCurrentMonthYear()
        // Filter entries for current month
        let calendar = Calendar.current
        entriesForCurrentMonth = entries.filter { entry in
            calendar.isDate(entry.date, equalTo: currentDate, toGranularity: .month)
        }
    }
    
    private func updateCurrentMonthYear() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        currentMonthYear = formatter.string(from: currentDate)
    }
    
    public func selectDate(_ date: Date) {
        // Implement date selection logic here
        // This can be used to show entries for the selected date
    }
}


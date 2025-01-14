import SwiftData
import SwiftUI

@Model
final class DiaryEntry {
    var id: UUID
    var userId: String
    var photo: Data?
    var photoURL: String?
    var text: String
    var title: String
    var emotions: [String]
    var timestamp: Date
    var lastModifiedAt: Date
    var textOverlays: [TextOverlay]
    var drawingPaths: [DrawingPath]
    var syncStatus: SyncStatus
    var lastSyncedAt: Date?
    var pendingChanges: Bool
    
    init(
        id: UUID = UUID(),
        userId: String,
        photo: Data? = nil,
        photoURL: String? = nil,
        text: String = "",
        title: String = "",
        emotions: [String] = [],
        timestamp: Date = Date(),
        lastModifiedAt: Date = Date(),
        textOverlays: [TextOverlay] = [],
        drawingPaths: [DrawingPath] = [],
        syncStatus: SyncStatus = .pendingUpload,
        lastSyncedAt: Date? = nil,
        pendingChanges: Bool = true
    ) {
        self.id = id
        self.userId = userId
        self.photo = photo
        self.photoURL = photoURL
        self.text = text
        self.title = title
        self.emotions = emotions
        self.timestamp = timestamp
        self.lastModifiedAt = lastModifiedAt
        self.textOverlays = textOverlays
        self.drawingPaths = drawingPaths
        self.syncStatus = syncStatus
        self.lastSyncedAt = lastSyncedAt
        self.pendingChanges = pendingChanges
    }
    
    enum SyncStatus: String, Codable {
        case synced
        case pendingUpload
        case pendingDownload
        case conflict
        case error
    }
} 
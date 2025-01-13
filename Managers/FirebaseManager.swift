import Foundation
import FirebaseStorage
import FirebaseFirestore

class FirebaseManager {
    static let shared = FirebaseManager()
    private let storage = Storage.storage().reference()
    private let db = Firestore.firestore()
    
    // Upload photo and return URL
    func uploadPhoto(imageData: Data, entryId: String) async throws -> String {
        let photoRef = storage.child("photos/\(entryId)/photo.jpg")
        
        _ = try await photoRef.putDataAsync(imageData)
        let downloadURL = try await photoRef.downloadURL()
        return downloadURL.absoluteString
    }
    
    // Save diary entry to Firestore
    func saveDiaryEntry(entry: Item, photoURL: String?) async throws {
        let entryData: [String: Any] = [
            "text": entry.text,
            "date": entry.timestamp,
            "emotions": entry.emotions,
            "photoURL": photoURL ?? "",
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        try await db.collection("diaryEntries")
            .document(entry.id.uuidString)
            .setData(entryData)
    }
} 
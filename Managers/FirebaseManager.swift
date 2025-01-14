import Foundation
import FirebaseStorage
import FirebaseFirestore
import SwiftData

class FirebaseManager {
    static let shared = FirebaseManager()
    private let storage = Storage.storage().reference()
    private let db = Firestore.firestore()
    
    func uploadPhoto(imageData: Data, entryId: String) async throws -> String {
        print("📤 Starting photo upload for entry: \(entryId)")
        let photoRef = storage.child("photos/\(entryId)/photo.jpg")
        
        do {
            _ = try await photoRef.putDataAsync(imageData)
            let downloadURL = try await photoRef.downloadURL()
            print("✅ Photo upload successful. URL: \(downloadURL.absoluteString)")
            return downloadURL.absoluteString
        } catch {
            print("❌ Photo upload failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    func saveDiaryEntry(entry: DiaryEntry) async throws {
        print("💾 Saving diary entry to Firestore. ID: \(entry.id.uuidString)")
        let entryData: [String: Any] = [
            "id": entry.id.uuidString,
            "text": entry.text,
            "title": entry.title,
            "emotions": entry.emotions,
            "timestamp": entry.timestamp,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        print("📝 Entry data prepared: \(entryData)")
        
        do {
            try await db.collection("diaryEntries")
                .document(entry.id.uuidString)
                .setData(entryData)
            print("✅ Entry successfully saved to Firestore")
        } catch {
            print("❌ Failed to save entry: \(error.localizedDescription)")
            throw error
        }
    }
    
    func fetchDiaryEntries() async throws -> [DiaryEntry] {
        print("🔍 Fetching diary entries from Firestore")
        do {
            let snapshot = try await db.collection("diaryEntries").getDocuments()
            print("📚 Retrieved \(snapshot.documents.count) entries")
            
            return try snapshot.documents.compactMap { (document: QueryDocumentSnapshot) -> DiaryEntry? in
                let data = document.data()
                print("📄 Processing document: \(document.documentID)")
                
                guard 
                    let idString = data["id"] as? String,
                    let id = UUID(uuidString: idString),
                    let text = data["text"] as? String,
                    let title = data["title"] as? String,
                    let emotions = data["emotions"] as? [String],
                    let timestamp = (data["timestamp"] as? Timestamp)?.dateValue()
                else {
                    print("⚠️ Failed to parse document: \(document.documentID)")
                    return nil
                }
                
                return DiaryEntry(
                    id: id,
                    userId: "", // TODO: Add proper user ID
                    text: text,
                    title: title,
                    emotions: emotions,
                    timestamp: timestamp
                )
            }
        } catch {
            print("❌ Failed to fetch entries: \(error.localizedDescription)")
            throw error
        }
    }
    
    // Helper method to verify Firebase configuration
    func verifyConnection() {
        print("🔄 Verifying Firebase connection...")
        let testDocument = db.collection("_test_connection").document("test")
        
        Task {
            do {
                print("📝 Attempting to write test document...")
                try await testDocument.setData([
                    "timestamp": FieldValue.serverTimestamp(),
                    "testValue": "connection_test"
                ])
                
                print("📖 Attempting to read test document...")
                let snapshot = try await testDocument.getDocument()
                guard let data = snapshot.data() else {
                    print("⚠️ Test document exists but has no data")
                    return
                }
                print("📄 Test document data: \(data)")
                
                print("🗑️ Cleaning up test document...")
                try await testDocument.delete()
                print("✅ Firebase connection verified successfully")
            } catch {
                print("❌ Firebase connection test failed with error: \(error)")
                print("❌ Error details: \(error.localizedDescription)")
                let nsError = error as NSError
                print("❌ Error domain: \(nsError.domain)")
                print("❌ Error code: \(nsError.code)")
            }
        }
    }
    
    func uploadEntryWithAssets(_ entry: DiaryEntry) async throws {
        // Upload photo if changed
        var photoURL: String?
        if let photoData = entry.photo {
            photoURL = try await uploadPhoto(imageData: photoData, entryId: entry.id.uuidString)
        }
        
        // Convert overlays and paths to cloud format
        let textOverlaysData = entry.textOverlays.map { overlay in
            CloudEntry.CloudTextOverlay(
                id: overlay.id.uuidString,
                text: overlay.text,
                position: CloudEntry.PointWrapper(point: overlay.position),
                color: CloudEntry.CloudColor(
                    red: overlay.storedColor.red,
                    green: overlay.storedColor.green,
                    blue: overlay.storedColor.blue,
                    opacity: overlay.storedColor.opacity
                ),
                fontFamily: overlay.fontFamily,
                fontSize: overlay.fontSize,
                fontStyle: overlay.fontStyle
            )
        }
        
        let drawingPathsData = entry.drawingPaths.map { path in
            CloudEntry.CloudDrawingPath(
                id: path.id.uuidString,
                points: path.points.map { CloudEntry.PointWrapper(point: $0) },
                color: CloudEntry.CloudColor(
                    red: path.storedColor.red,
                    green: path.storedColor.green,
                    blue: path.storedColor.blue,
                    opacity: path.storedColor.opacity
                ),
                lineWidth: path.lineWidth
            )
        }
        
        let cloudEntry = CloudEntry(
            id: entry.id.uuidString,
            text: entry.text,
            title: entry.title,
            emotions: entry.emotions,
            photoURL: photoURL,
            timestamp: entry.timestamp,
            textOverlays: textOverlaysData,
            drawingPaths: drawingPathsData
        )
        
        // Save to Firestore
        try await saveCloudEntry(cloudEntry)
    }
    
    private func saveCloudEntry(_ entry: CloudEntry) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(entry)
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
        
        try await db.collection("diaryEntries")
            .document(entry.id)
            .setData(dict)
    }
    
    func fetchEntriesWithChanges(since date: Date) async throws -> [CloudEntry] {
        let snapshot = try await db.collection("diaryEntries")
            .whereField("timestamp", isGreaterThan: date)
            .getDocuments()
        
        return try snapshot.documents.compactMap { document in
            let data = try JSONSerialization.data(withJSONObject: document.data())
            return try JSONDecoder().decode(CloudEntry.self, from: data)
        }
    }
}
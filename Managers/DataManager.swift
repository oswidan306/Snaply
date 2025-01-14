import SwiftUI
import SwiftData

@MainActor
class DataManager: ObservableObject {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Local Storage Operations
    
    func saveDiaryEntry(_ entry: DiaryEntry) throws {
        modelContext.insert(entry)
        try modelContext.save()
    }
    
    func fetchLocalEntries() throws -> [DiaryEntry] {
        let descriptor = FetchDescriptor<DiaryEntry>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
} 
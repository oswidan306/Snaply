import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        print("🔥 Firebase configured")
        
        // Verify Firebase connection
        FirebaseManager.shared.verifyConnection()
        
        // Test write operation
        Task {
            do {
                let testEntry = DiaryEntry(
                    userId: "test_user",
                    text: "Test Entry",
                    title: "Test Title",
                    emotions: ["Test"],
                    timestamp: Date()
                )
                try await FirebaseManager.shared.saveDiaryEntry(entry: testEntry)
                print("✅ Test entry saved successfully")
                
                let entries = try await FirebaseManager.shared.fetchDiaryEntries()
                print("📚 Found \(entries.count) entries in database")
            } catch {
                print("❌ Test operations failed: \(error.localizedDescription)")
            }
        }
        
        return true
    }

    func testCompleteEntrySync() async {
        do {
            // Create test entry with all components
            let testEntry = DiaryEntry(
                userId: "test_user",
                text: "Test Entry",
                title: "Test Title",
                emotions: ["Happy", "Excited"],
                timestamp: Date()
            )
            
            // Add a text overlay
            let textOverlay = TextOverlay(
                text: "Test Overlay",
                position: CGPoint(x: 100, y: 100),
                color: .blue
            )
            testEntry.textOverlays.append(textOverlay)
            
            // Add a drawing path
            let drawingPath = DrawingPath(
                points: [CGPoint(x: 0, y: 0), CGPoint(x: 100, y: 100)],
                color: .red
            )
            testEntry.drawingPaths.append(drawingPath)
            
            // Test saving
            try await FirebaseManager.shared.uploadEntryWithAssets(testEntry)
            print("✅ Complete entry saved successfully")
            
            // Test fetching
            let remoteEntries = try await FirebaseManager.shared.fetchEntriesWithChanges(since: Date().addingTimeInterval(-3600))
            if let fetchedEntry = remoteEntries.first {
                print("✅ Complete entry fetched successfully")
                print("📝 Entry details:")
                print("- Title: \(fetchedEntry.title)")
                print("- Text overlays: \(fetchedEntry.textOverlays.count)")
                print("- Drawing paths: \(fetchedEntry.drawingPaths.count)")
            }
            
        } catch {
            print("❌ Test failed: \(error.localizedDescription)")
        }
    }
}

@main
struct NoviApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authManager = AuthenticationManager()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            DiaryEntry.self,
            TextOverlay.self,
            DrawingPath.self,
            StorableColor.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                GeometryReader { geometry in
                    ContentView(containerWidth: geometry.size.width - 32)
                }
                .modelContainer(sharedModelContainer)
            } else {
                SignInView()
            }
        }
    }
} 
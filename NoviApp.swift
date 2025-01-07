import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // Test Firebase connection
        let db = Firestore.firestore()
        db.collection("test").document("test").setData([
            "timestamp": FieldValue.serverTimestamp(),
            "message": "Firebase is connected!"
        ]) { err in
            if let err = err {
                print("Error writing to Firebase: \(err)")
            } else {
                print("Successfully connected to Firebase!")
            }
        }
        
        return true
    }
}

@main
struct NoviApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
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
            GeometryReader { geometry in
                ContentView(containerWidth: geometry.size.width - 32)
            }
        }
        .modelContainer(sharedModelContainer)
    }
} 
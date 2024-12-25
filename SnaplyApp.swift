//
//  SnaplyApp.swift
//  Snaply
//
//  Created by Omar Swidan on 12/15/24.
//

import SwiftUI
import SwiftData

@main
struct SnaplyApp: App {
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

//
//  PuzzleGame4App.swift
//  PuzzleGame4
//
//  Created by Dmitry Disson on 3/18/25.
//

import SwiftUI
// This is needed to access the LevelNavigator class
import Foundation

@main
struct PuzzleGame4App: App {
    let persistenceController = PersistenceController.shared
    
    // Access the shared navigator
    @StateObject private var levelNavigator = LevelNavigator.shared

    var body: some Scene {
        WindowGroup {
            ChooseLevelScreen()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                // Inject the environment object
                .environmentObject(levelNavigator)
        }
    }
}

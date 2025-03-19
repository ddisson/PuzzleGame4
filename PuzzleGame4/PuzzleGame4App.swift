//
//  PuzzleGame4App.swift
//  PuzzleGame4
//
//  Created by Dmitry Disson on 3/18/25.
//

import SwiftUI

@main
struct PuzzleGame4App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ChooseLevelScreen()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

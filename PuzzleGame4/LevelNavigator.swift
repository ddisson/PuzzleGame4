import SwiftUI

// A shared class to handle level navigation
class LevelNavigator: ObservableObject {
    static let shared = LevelNavigator()
    
    @Published var activeNavigationPath = NavigationPath()
    @Published var nextLevelToPlay: PuzzleLevel?
    
    func navigateToLevel(_ level: PuzzleLevel) {
        print("🔄 LevelNavigator: Navigating to level \(level.name)")
        
        // Reset path and add new level
        DispatchQueue.main.async {
            self.activeNavigationPath = NavigationPath()
            
            DispatchQueue.main.async {
                self.activeNavigationPath.append(level)
            }
        }
    }
}

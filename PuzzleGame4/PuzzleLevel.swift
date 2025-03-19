import Foundation
import UIKit

struct PuzzleLevel: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
    let gridRows: Int
    let gridColumns: Int
    let difficulty: Difficulty
    
    enum Difficulty {
        case easy
        case medium
        case hard
        
        var description: String {
            switch self {
            case .easy: return "Easy"
            case .medium: return "Medium"
            case .hard: return "Hard"
            }
        }
    }
    
    // Predefined levels
    static let allLevels = [
        PuzzleLevel(
            name: "Frozen",
            imageName: "anna_elza",
            gridRows: 2,
            gridColumns: 2,
            difficulty: .easy
        ),
        PuzzleLevel(
            name: "Peppa Doctor",
            imageName: "peppa_doctor",
            gridRows: 2,
            gridColumns: 3,
            difficulty: .medium
        ),
        PuzzleLevel(
            name: "Elza on Cat", 
            imageName: "elza_on_cat",
            gridRows: 3,
            gridColumns: 3,
            difficulty: .hard
        )
        // Additional levels can be added here
    ]
} 
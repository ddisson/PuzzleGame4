import Foundation
import UIKit

struct PuzzleLevel: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let imageName: String
    let gridRows: Int
    let gridColumns: Int
    let difficulty: Difficulty
    
    // Implement Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PuzzleLevel, rhs: PuzzleLevel) -> Bool {
        return lhs.id == rhs.id
    }
    
    enum Difficulty {
        case easy
        case medium
        case hard
        case hardcore
        
        var description: String {
            switch self {
            case .easy: return "Easy"
            case .medium: return "Medium"
            case .hard: return "Hard"
            case .hardcore: return "Hardcore"
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
        ),
        PuzzleLevel(
            name: "Totoro",
            imageName: "totoro",
            gridRows: 3,
            gridColumns: 3,
            difficulty: .hard
        ),
        PuzzleLevel(
            name: "Elza Surgeon",
            imageName: "elxa_surgeon",
            gridRows: 4,
            gridColumns: 3,
            difficulty: .hardcore
        )
        // Additional levels can be added here
    ]
} 
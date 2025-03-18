import SwiftUI
import UIKit

class PuzzleImageHelper {
    /// Generate puzzle pieces from an image
    /// - Parameters:
    ///   - imageName: The name of the image in Assets.xcassets
    ///   - gridSize: The size of the grid (e.g., 2 for a 2x2 puzzle)
    /// - Returns: An array of cropped UIImages representing puzzle pieces
    static func generatePuzzlePieces(from imageName: String, gridSize: Int) -> [[UIImage]] {
        guard let image = UIImage(named: imageName) else {
            print("Failed to load image: \(imageName)")
            return []
        }
        
        // Get the image dimensions
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        
        // Calculate piece dimensions
        let pieceWidth = imageWidth / CGFloat(gridSize)
        let pieceHeight = imageHeight / CGFloat(gridSize)
        
        var puzzlePieces: [[UIImage]] = Array(repeating: Array(repeating: UIImage(), count: gridSize), count: gridSize)
        
        // Slice the image into pieces
        for row in 0..<gridSize {
            for column in 0..<gridSize {
                let x = CGFloat(column) * pieceWidth
                let y = CGFloat(row) * pieceHeight
                
                let rect = CGRect(x: x, y: y, width: pieceWidth, height: pieceHeight)
                
                // Create a piece by cropping the original image
                if let cgImage = image.cgImage?.cropping(to: rect) {
                    let pieceImage = UIImage(cgImage: cgImage)
                    puzzlePieces[row][column] = pieceImage
                }
            }
        }
        
        return puzzlePieces
    }
    
    /// Creates a renderable Image from a UIImage
    static func imageFromUIImage(_ uiImage: UIImage) -> Image {
        return Image(uiImage: uiImage)
    }
    
    /// Generate a puzzle piece image name based on row and column
    static func pieceImageName(for imageName: String, row: Int, column: Int) -> String {
        return "\(imageName)_\(row)_\(column)"
    }
    
    /// Process and save all puzzle pieces to the app's document directory
    /// This can be used during development to prepare the assets
    static func processAndSavePuzzlePieces(from imageName: String, gridSize: Int) {
        let pieces = generatePuzzlePieces(from: imageName, gridSize: gridSize)
        
        for row in 0..<gridSize {
            for column in 0..<gridSize {
                let piece = pieces[row][column]
                
                // Get document directory path
                let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileName = "\(imageName)_\(row)_\(column).png"
                let fileURL = documentDirectory.appendingPathComponent(fileName)
                
                // Save image to file
                if let data = piece.pngData() {
                    try? data.write(to: fileURL)
                    print("Saved piece \(fileName) to \(fileURL)")
                }
            }
        }
    }
}

// A SwiftUI view that renders a puzzle piece from a UIImage
struct PuzzlePieceView: View {
    let uiImage: UIImage
    
    var body: some View {
        Image(uiImage: uiImage)
            .resizable()
            .scaledToFill()
    }
} 
import SwiftUI
import UIKit

struct PuzzleImageHelper {
    /// Generate puzzle pieces from an image
    /// - Parameters:
    ///   - imageName: The name of the image in Assets.xcassets
    ///   - gridSize: The size of the grid (e.g., 2 for a 2x2 puzzle)
    /// - Returns: An array of cropped UIImages representing puzzle pieces
    static func generatePuzzlePieces(from imageName: String, gridSize: Int) -> [[UIImage]] {
        return generatePuzzlePieces(from: imageName, gridRows: gridSize, gridColumns: gridSize)
    }
    
    /// Generate puzzle pieces from an image with different row and column counts
    /// - Parameters:
    ///   - imageName: The name of the image in Assets.xcassets
    ///   - gridRows: The number of rows in the grid
    ///   - gridColumns: The number of columns in the grid
    /// - Returns: An array of cropped UIImages representing puzzle pieces
    static func generatePuzzlePieces(from imageName: String, gridRows: Int, gridColumns: Int) -> [[UIImage]] {
        guard let originalImage = UIImage(named: imageName) else {
            fatalError("Image not found: \(imageName)")
        }
        
        // Create a context to draw the image
        let imageWidth = originalImage.size.width
        let imageHeight = originalImage.size.height
        
        // Calculate the size of each piece
        let pieceWidth = imageWidth / CGFloat(gridColumns)
        let pieceHeight = imageHeight / CGFloat(gridRows)
        
        var pieces = [[UIImage]]()
        
        for row in 0..<gridRows {
            var rowPieces = [UIImage]()
            
            for column in 0..<gridColumns {
                // Calculate the frame for this piece
                let rect = CGRect(
                    x: CGFloat(column) * pieceWidth,
                    y: CGFloat(row) * pieceHeight,
                    width: pieceWidth,
                    height: pieceHeight
                )
                
                // Render the piece
                let renderer = UIGraphicsImageRenderer(size: rect.size)
                let pieceImage = renderer.image { context in
                    // Crop the original image
                    originalImage.draw(at: CGPoint(x: -rect.origin.x, y: -rect.origin.y))
                }
                
                rowPieces.append(pieceImage)
            }
            
            pieces.append(rowPieces)
        }
        
        return pieces
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
        processAndSavePuzzlePieces(from: imageName, gridRows: gridSize, gridColumns: gridSize)
    }
    
    /// Process and save all puzzle pieces to the app's document directory with different row and column counts
    /// This can be used during development to prepare the assets
    static func processAndSavePuzzlePieces(from imageName: String, gridRows: Int, gridColumns: Int) {
        let pieces = generatePuzzlePieces(from: imageName, gridRows: gridRows, gridColumns: gridColumns)
        
        for row in 0..<gridRows {
            for column in 0..<gridColumns {
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
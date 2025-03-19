import SwiftUI
import UIKit

struct PuzzleImageHelper {
    /// Generate a 2D array of puzzle piece images from a single image
    /// - Parameters:
    ///   - imageName: The name of the source image in the asset catalog
    ///   - gridRows: Number of rows in the puzzle grid
    ///   - gridColumns: Number of columns in the puzzle grid
    /// - Returns: A 2D array of UIImages representing the puzzle pieces
    static func generatePuzzlePieces(
        from imageName: String,
        gridRows: Int,
        gridColumns: Int
    ) -> [[UIImage]] {
        // For backward compatibility
        guard let image = UIImage(named: imageName) else {
            return Array(repeating: Array(repeating: UIImage(), count: gridColumns), count: gridRows)
        }
        
        // Calculate each piece's size
        let pieceWidth = image.size.width / CGFloat(gridColumns)
        let pieceHeight = image.size.height / CGFloat(gridRows)
        
        var pieces = [[UIImage]]()
        
        // Generate the pieces
        for row in 0..<gridRows {
            var rowPieces = [UIImage]()
            
            for column in 0..<gridColumns {
                // Calculate the crop rectangle for this piece
                let x = CGFloat(column) * pieceWidth
                let y = CGFloat(row) * pieceHeight
                let rect = CGRect(x: x, y: y, width: pieceWidth, height: pieceHeight)
                
                // Create the cropped image
                if let cgImage = image.cgImage?.cropping(to: rect) {
                    let pieceImage = UIImage(cgImage: cgImage)
                    rowPieces.append(pieceImage)
                } else {
                    // Fallback to an empty image if cropping fails
                    rowPieces.append(UIImage())
                }
            }
            
            pieces.append(rowPieces)
        }
        
        return pieces
    }
    
    // For backward compatibility
    static func generatePuzzlePieces(from imageName: String, gridSize: Int) -> [[UIImage]] {
        return generatePuzzlePieces(from: imageName, gridRows: gridSize, gridColumns: gridSize)
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
    
    // For backward compatibility
    static func processAndSavePuzzlePieces(from imageName: String, gridSize: Int) {
        processAndSavePuzzlePieces(from: imageName, gridRows: gridSize, gridColumns: gridSize)
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
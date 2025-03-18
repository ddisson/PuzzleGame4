import SwiftUI

struct PuzzleSlicerView: View {
    var body: some View {
        VStack {
            Text("Puzzle Slicer Tool")
                .font(.title)
            
            Button("Generate Puzzle Pieces") {
                sliceImage()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
    
    func sliceImage() {
        guard let image = UIImage(named: "anna_elza") else {
            print("Failed to load image")
            return
        }
        
        let gridSize = 2 // 2x2 puzzle
        
        // Get the image dimensions
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        
        // Calculate piece dimensions
        let pieceWidth = imageWidth / CGFloat(gridSize)
        let pieceHeight = imageHeight / CGFloat(gridSize)
        
        // Slice the image into pieces
        for row in 0..<gridSize {
            for column in 0..<gridSize {
                let x = CGFloat(column) * pieceWidth
                let y = CGFloat(row) * pieceHeight
                
                let rect = CGRect(x: x, y: y, width: pieceWidth, height: pieceHeight)
                
                // Create a piece by cropping the original image
                if let cgImage = image.cgImage?.cropping(to: rect) {
                    let pieceImage = UIImage(cgImage: cgImage)
                    
                    // Save the piece to the document directory
                    savePuzzlePiece(pieceImage, row: row, column: column)
                }
            }
        }
        
        print("Puzzle pieces generated successfully!")
    }
    
    func savePuzzlePiece(_ image: UIImage, row: Int, column: Int) {
        // Get document directory path
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "anna_elza_\(row)_\(column).png"
        let fileURL = documentDirectory.appendingPathComponent(fileName)
        
        // Save image to file
        if let data = image.pngData() {
            try? data.write(to: fileURL)
            print("Saved piece \(fileName) to \(fileURL)")
        }
    }
}

struct PuzzleSlicerView_Previews: PreviewProvider {
    static var previews: some View {
        PuzzleSlicerView()
    }
} 
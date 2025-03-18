import SwiftUI

class PuzzleState: ObservableObject {
    @Published var puzzlePieces: [PuzzlePiece] = []
    @Published var puzzleCompleted = false
    
    func placePiece(at index: Int) {
        var newPieces = puzzlePieces
        newPieces[index].isPlaced = true
        puzzlePieces = newPieces
        
        // Check if all pieces are placed
        checkPuzzleCompletion()
    }
    
    func resetGame() {
        var newPieces = [PuzzlePiece]()
        for piece in puzzlePieces {
            var newPiece = piece
            newPiece.isPlaced = false
            newPieces.append(newPiece)
        }
        
        puzzlePieces = newPieces.shuffled()
        puzzleCompleted = false
    }
    
    private func checkPuzzleCompletion() {
        if puzzlePieces.allSatisfy({ $0.isPlaced }) {
            print("🎉 ALL PIECES PLACED! Puzzle completed.")
            puzzleCompleted = true
        }
    }
}

struct GameView: View {
    // MARK: - Properties
    @StateObject private var puzzleState = PuzzleState()
    @State private var draggedPieceIndex: Int? = nil
    @State private var dragOffset = CGSize.zero
    @State private var showFullImage = false
    @State private var gridCellPositions: [[(row: Int, column: Int, rect: CGRect)]] = []
    @State private var debugging = false
    
    // Grid configuration
    let gridSize = 2 // 2x2 puzzle
    let gridSpacing: CGFloat = 2
    let imageName = "anna_elza"
    
    // Get actual image aspect ratio from the asset
    var imageAspectRatio: CGFloat {
        if let uiImage = UIImage(named: imageName) {
            return uiImage.size.width / uiImage.size.height
        }
        return 1.5 // Default fallback
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width
            let availableHeight = geometry.size.height
            
            // Make grid cover 60% of screen width (increased from 45%)
            let gridWidth = availableWidth * 0.6
            let gridHeight = gridWidth / imageAspectRatio
            
            // Calculate cell dimensions
            let cellWidth = (gridWidth - CGFloat(gridSize - 1) * gridSpacing) / CGFloat(gridSize)
            let cellHeight = (gridHeight - CGFloat(gridSize - 1) * gridSpacing) / CGFloat(gridSize)
            
            HStack(alignment: .top, spacing: 10) {
                // MARK: Left Side - Puzzle Grid and smaller preview
                VStack(spacing: 15) {
                    // Full Image Preview (tappable) - at the top, 50% smaller
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: gridWidth * 0.3) // 50% smaller than previous
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .shadow(radius: 1)
                        .padding(.top, 10)
                        .onTapGesture {
                            showFullImage = true
                        }
                    
                    // Puzzle Grid
                    ZStack {
                        // Grid background
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white)
                            .shadow(radius: 2)
                        
                        // Grid cells
                        VStack(spacing: gridSpacing) {
                            ForEach(0..<gridSize, id: \.self) { row in
                                HStack(spacing: gridSpacing) {
                                    ForEach(0..<gridSize, id: \.self) { column in
                                        ZStack {
                                            // Grid cell background
                                            Rectangle()
                                                .strokeBorder(Color.gray.opacity(0.5), lineWidth: 1)
                                                .background(Rectangle().fill(Color.white))
                                                .frame(width: cellWidth, height: cellHeight)
                                                .overlay(
                                                    GeometryReader { cellGeo in
                                                        Color.clear
                                                            .onAppear {
                                                                // Save the cell position
                                                                let frame = cellGeo.frame(in: .global)
                                                                saveGridCellPosition(row: row, column: column, rect: frame)
                                                                if debugging {
                                                                    print("Cell \(row),\(column) has frame: \(frame)")
                                                                }
                                                            }
                                                    }
                                                )
                                            
                                            // Show placed pieces directly in the cell
                                            ForEach(puzzleState.puzzlePieces.indices, id: \.self) { index in
                                                if puzzleState.puzzlePieces[index].isPlaced && 
                                                   puzzleState.puzzlePieces[index].correctRow == row && 
                                                   puzzleState.puzzlePieces[index].correctColumn == column {
                                                    Image(uiImage: puzzleState.puzzlePieces[index].image)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: cellWidth, height: cellHeight)
                                                        .clipped() // Ensure it stays within bounds
                                                }
                                            }
                                        }
                                        .id("cell_\(row)_\(column)")
                                    }
                                }
                            }
                        }
                        .padding(gridSpacing)
                    }
                    .frame(width: gridWidth, height: gridHeight)
                }
                
                // MARK: Right Side - Unplaced Pieces
                VStack(spacing: 15) {
                    // Title for unplaced pieces
                    if debugging {
                        Text("Pieces")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    // Container for unplaced pieces
                    VStack(spacing: 20) {
                        ForEach(puzzleState.puzzlePieces.indices, id: \.self) { index in
                            if !puzzleState.puzzlePieces[index].isPlaced {
                                let piece = puzzleState.puzzlePieces[index]
                                
                                Image(uiImage: piece.image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: cellWidth, height: cellHeight)
                                    .clipped() // Ensure it stays within bounds
                                    .shadow(radius: 2)
                                    .offset(draggedPieceIndex == index ? dragOffset : .zero)
                                    .gesture(
                                        DragGesture(minimumDistance: 0, coordinateSpace: .global)
                                            .onChanged { value in
                                                draggedPieceIndex = index
                                                dragOffset = value.translation
                                                
                                                if debugging {
                                                    print("Dragging piece \(piece.correctRow),\(piece.correctColumn) at \(value.location)")
                                                }
                                            }
                                            .onEnded { value in
                                                if debugging {
                                                    print("Released piece \(piece.correctRow),\(piece.correctColumn) at \(value.location)")
                                                }
                                                
                                                checkForCorrectPlacement(
                                                    pieceIndex: index,
                                                    finalLocation: value.location,
                                                    cellWidth: cellWidth,
                                                    cellHeight: cellHeight
                                                )
                                            }
                                    )
                            }
                        }
                    }
                    .padding()
                    
                    Spacer() // Push pieces to the top
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .overlay(
                // Debug button - only visible if needed
                Group {
                    if debugging {
                        VStack {
                            HStack {
                                Spacer()
                                Button(action: {
                                    debugging.toggle()
                                    printGridCellPositions()
                                }) {
                                    Text("Debug")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(4)
                                        .background(Color.gray.opacity(0.5))
                                        .cornerRadius(4)
                                }
                                .opacity(0.7)
                            }
                            Spacer()
                        }
                        .padding(.top, 10)
                        .padding(.trailing, 10)
                    }
                }
            )
            .onAppear {
                // Initialize puzzle pieces
                initializeGridCellPositions()
                initializePuzzlePieces()
                
                // Initial debug printout after a small delay to ensure everything is laid out
                if debugging {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        printGridCellPositions()
                    }
                }
            }
            .fullScreenCover(isPresented: $showFullImage) {
                ZStack {
                    Color.black.opacity(0.9).edgesIgnoringSafeArea(.all)
                    
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .padding(20)
                    
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                showFullImage = false
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                                    .padding()
                            }
                        }
                        Spacer()
                    }
                }
                .onTapGesture {
                    showFullImage = false
                }
            }
            .alert(isPresented: $puzzleState.puzzleCompleted) {
                Alert(
                    title: Text("Puzzle Completed!"),
                    message: Text("Great job! You finished the puzzle."),
                    dismissButton: .default(Text("Play Again"), action: {
                        // Reset the game
                        puzzleState.resetGame()
                    })
                )
            }
        }
    }
    
    // MARK: - Methods
    
    private func initializeGridCellPositions() {
        gridCellPositions = Array(repeating: [], count: gridSize)
    }
    
    private func saveGridCellPosition(row: Int, column: Int, rect: CGRect) {
        // Make sure we have enough rows
        while gridCellPositions.count <= row {
            gridCellPositions.append([])
        }
        
        // Create a new entry for this cell
        let cellInfo = (row: row, column: column, rect: rect)
        
        // Add this cell to our collection
        if let existingIndex = gridCellPositions[row].firstIndex(where: { $0.column == column }) {
            // Update existing
            gridCellPositions[row][existingIndex] = cellInfo
        } else {
            // Add new
            gridCellPositions[row].append(cellInfo)
        }
    }
    
    private func printGridCellPositions() {
        print("====== GRID CELL POSITIONS ======")
        for row in 0..<gridCellPositions.count {
            for cellInfo in gridCellPositions[row] {
                print("Cell [\(cellInfo.row),\(cellInfo.column)]: \(cellInfo.rect)")
            }
        }
        print("================================")
    }
    
    private func checkForCorrectPlacement(pieceIndex: Int, finalLocation: CGPoint, cellWidth: CGFloat, cellHeight: CGFloat) {
        let piece = puzzleState.puzzlePieces[pieceIndex]
        
        print("Checking placement for piece \(piece.correctRow),\(piece.correctColumn) at \(finalLocation)")
        
        // Flag to track if placement succeeded
        var placed = false
        
        // Loop through grid cell positions to find where the piece was dropped
        for row in gridCellPositions {
            for cellInfo in row {
                let cellRect = cellInfo.rect
                
                // Make detection more forgiving by expanding the hit area
                let expandedRect = CGRect(
                    x: cellRect.origin.x - cellWidth * 0.2,
                    y: cellRect.origin.y - cellHeight * 0.2,
                    width: cellRect.width + cellWidth * 0.4,
                    height: cellRect.height + cellHeight * 0.4
                )
                
                // Check if this piece is dropped on any cell
                if expandedRect.contains(finalLocation) {
                    print("Piece dropped on cell \(cellInfo.row),\(cellInfo.column)")
                    
                    // Check if this is the correct cell for this piece
                    if cellInfo.row == piece.correctRow && cellInfo.column == piece.correctColumn {
                        print("✅ CORRECT PLACEMENT for piece \(piece.correctRow),\(piece.correctColumn)")
                        
                        // Update the piece state using the ObservableObject
                        puzzleState.placePiece(at: pieceIndex)
                        
                        // Reset drag state
                        draggedPieceIndex = nil
                        dragOffset = .zero
                        
                        placed = true
                        break
                    }
                }
            }
            
            if placed {
                break
            }
        }
        
        // If not placed, reset drag state
        if !placed {
            print("❌ Not placed correctly, returning to original position")
            
            // Reset drag with animation
            withAnimation(.spring()) {
                dragOffset = .zero
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                draggedPieceIndex = nil
            }
        }
    }
    
    private func initializePuzzlePieces() {
        // Generate puzzle pieces from the image
        let piecesImages = PuzzleImageHelper.generatePuzzlePieces(from: imageName, gridSize: gridSize)
        
        var pieces = [PuzzlePiece]()
        
        // Create PuzzlePiece models
        for row in 0..<gridSize {
            for column in 0..<gridSize {
                let piece = PuzzlePiece(
                    id: UUID(),
                    image: piecesImages[row][column],
                    correctRow: row,
                    correctColumn: column,
                    isPlaced: false
                )
                pieces.append(piece)
            }
        }
        
        // Shuffle the pieces
        puzzleState.puzzlePieces = pieces.shuffled()
    }
}

// MARK: - Puzzle Piece Model
struct PuzzlePiece: Identifiable, Equatable {
    let id: UUID
    let image: UIImage
    let correctRow: Int
    let correctColumn: Int
    var isPlaced: Bool
    
    static func == (lhs: PuzzlePiece, rhs: PuzzlePiece) -> Bool {
        return lhs.id == rhs.id
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
} 
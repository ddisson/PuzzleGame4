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
    @State private var debugging = true // Set to true to help debug placement issues
    @State private var gridInitialized = false // Flag to track if grid cells are initialized
    @Environment(\.presentationMode) var presentationMode
    
    // Level parameter for configurable puzzles
    var level: PuzzleLevel?
    
    // Grid configuration - gets values from level if provided
    var gridRows: Int {
        return level?.gridRows ?? 2
    }
    
    var gridColumns: Int {
        return level?.gridColumns ?? 2
    }
    
    var imageName: String {
        return level?.imageName ?? "anna_elza"
    }
    
    let gridSpacing: CGFloat = 2
    
    // Initializers for backward compatibility
    init() {
        // Default initializer with no level
        self.level = nil
    }
    
    init(level: PuzzleLevel) {
        // Level-specific initializer
        self.level = level
    }
    
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
            
            // Make grid cover 65% of screen width (increased by another 3% from 63%)
            let gridWidth = availableWidth * 0.65
            let gridHeight = gridWidth / imageAspectRatio
            
            // Calculate cell dimensions
            let cellWidth = (gridWidth - CGFloat(gridColumns - 1) * gridSpacing) / CGFloat(gridColumns)
            let cellHeight = (gridHeight - CGFloat(gridRows - 1) * gridSpacing) / CGFloat(gridRows)
            
            HStack(alignment: .top, spacing: 20) { // Increased spacing from 10 to 20 to move pieces right
                // MARK: Left Side - Puzzle Grid and smaller preview
                VStack(spacing: 15) {
                    // Level name and back button if we're in a level
                    if level != nil {
                        HStack {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "arrow.left")
                                    .foregroundColor(.blue)
                                Text("Back")
                                    .foregroundColor(.blue)
                            }
                            
                            Spacer()
                            
                            Text(level?.name ?? "Puzzle")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: {
                                puzzleState.resetGame()
                            }) {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Full Image Preview (tappable) - at the top, 50% smaller
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: gridWidth * 0.2) // Smaller: reduced from 0.3 to 0.2
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .shadow(radius: 1)
                        .padding(.top, level == nil ? 10 : 0)
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
                            ForEach(0..<gridRows, id: \.self) { row in
                                HStack(spacing: gridSpacing) {
                                    ForEach(0..<gridColumns, id: \.self) { column in
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
                                                                // Save the cell position using GeometryReader's frame in the proper coordinate space
                                                                let frame = cellGeo.frame(in: .named("gameSpace"))
                                                                saveGridCellPosition(row: row, column: column, rect: frame)
                                                                if debugging {
                                                                    print("Cell \(row),\(column) has frame: \(frame)")
                                                                }
                                                            }
                                                    }
                                                )
                                            
                                            // When debugging, show cell coordinates
                                            if debugging {
                                                Text("\(row),\(column)")
                                                    .font(.system(size: 10))
                                                    .foregroundColor(.gray.opacity(0.7))
                                            }
                                            
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
                                        .onAppear {
                                            // Mark this cell as initialized when it appears
                                            if row == gridRows - 1 && column == gridColumns - 1 {
                                                // Last cell has appeared, delay to ensure all cells are properly positioned
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                    gridInitialized = true
                                                    if debugging {
                                                        print("✅ GRID FULLY INITIALIZED")
                                                        printGridCellPositions()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(gridSpacing)
                    }
                    .frame(width: gridWidth, height: gridHeight)
                    .padding(.bottom, 40) // Add bottom padding to raise the grid up
                }
                
                // MARK: Right Side - Unplaced Pieces
                VStack(spacing: 15) {
                    // Title for unplaced pieces
                    if debugging {
                        Text("Pieces")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    // Grid initialization status
                    if debugging {
                        Text(gridInitialized ? "Grid Ready" : "Grid Initializing...")
                            .font(.caption)
                            .foregroundColor(gridInitialized ? .green : .red)
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
                                    .overlay(
                                        // When debugging, show piece coordinates
                                        Group {
                                            if debugging {
                                                Text("\(piece.correctRow),\(piece.correctColumn)")
                                                    .font(.system(size: 10))
                                                    .foregroundColor(.white)
                                                    .padding(2)
                                                    .background(Color.black.opacity(0.5))
                                            }
                                        }
                                    )
                                    .offset(draggedPieceIndex == index ? dragOffset : .zero)
                                    .gesture(
                                        DragGesture(minimumDistance: 0, coordinateSpace: .named("gameSpace"))
                                            .onChanged { value in
                                                draggedPieceIndex = index
                                                dragOffset = value.translation
                                                
                                                if debugging {
                                                    print("Dragging piece \(piece.correctRow),\(piece.correctColumn) at \(value.location)")
                                                }
                                            }
                                            .onEnded { value in
                                                // Only process placement if grid is initialized
                                                if !gridInitialized {
                                                    print("⚠️ Grid not yet initialized, cannot place piece")
                                                    withAnimation(.spring()) {
                                                        dragOffset = .zero
                                                    }
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                        draggedPieceIndex = nil
                                                    }
                                                    return
                                                }
                                                
                                                if debugging {
                                                    print("Released piece \(piece.correctRow),\(piece.correctColumn) at \(value.location)")
                                                    print("Final location: \(value.location)")
                                                    print("Piece has correctRow: \(piece.correctRow), correctColumn: \(piece.correctColumn)")
                                                }
                                                
                                                // Don't calculate the start position, just use the final location
                                                // which is in our consistent coordinate space
                                                
                                                // Attempt to place the piece directly instead of using the closest cell method
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
                    .padding(.leading, 15) // Add left padding to move pieces more to the right
                    .padding(.vertical)
                    
                    Spacer() // Push pieces to the top
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .coordinateSpace(name: "gameSpace") // Add a consistent coordinate space for the whole game view
            .navigationBarHidden(true) // Hide any navigation bar to prevent duplication
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
                
                // Delay piece initialization to ensure grid cells are ready
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    initializePuzzlePieces()
                }
                
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
        gridCellPositions = Array(repeating: [], count: gridRows)
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
    
    private func findClosestGridCell(to location: CGPoint) -> (row: Int, column: Int, distance: CGFloat)? {
        var closestCell: (row: Int, column: Int, distance: CGFloat)? = nil
        
        // Loop through all cells to find the closest one
        for row in 0..<gridCellPositions.count {
            for cellInfo in gridCellPositions[row] {
                let cellRect = cellInfo.rect
                let cellCenter = CGPoint(
                    x: cellRect.midX,
                    y: cellRect.midY
                )
                
                // Calculate distance to cell center
                let distance = sqrt(
                    pow(location.x - cellCenter.x, 2) +
                    pow(location.y - cellCenter.y, 2)
                )
                
                if debugging {
                    print("Distance from (\(location.x), \(location.y)) to cell [\(cellInfo.row),\(cellInfo.column)] center (\(cellCenter.x), \(cellCenter.y)): \(distance)")
                }
                
                // Update closest if this is closer or if we don't have a closest yet
                if closestCell == nil || distance < closestCell!.distance {
                    closestCell = (cellInfo.row, cellInfo.column, distance)
                }
            }
        }
        
        return closestCell
    }
    
    private func placePieceAtClosestCell(pieceIndex: Int, finalLocation: CGPoint, cellWidth: CGFloat, cellHeight: CGFloat) {
        let piece = puzzleState.puzzlePieces[pieceIndex]
        
        // Double-check we have grid cells to work with
        if gridCellPositions.isEmpty {
            print("⚠️ No grid cells initialized! Cannot check for placement.")
            resetDragState()
            return
        }
        
        // First, try to find if the piece is directly over a cell
        if let closestCell = findClosestGridCell(to: finalLocation) {
            if debugging {
                print("Closest cell to drop: [\(closestCell.row),\(closestCell.column)], distance: \(closestCell.distance)")
                print("Piece needs to go to: [\(piece.correctRow),\(piece.correctColumn)]")
            }
            
            // Check if this is the correct cell for this piece
            let isCorrectCell = closestCell.row == piece.correctRow && closestCell.column == piece.correctColumn
            
            // Add a very strict distance threshold - must be almost exactly on the center
            let maxAllowableDistance = max(cellWidth, cellHeight) * 0.01 // Only 5% of cell size
            let isCloseEnough = closestCell.distance < maxAllowableDistance
            
            if isCorrectCell && isCloseEnough {
                print("✅ CORRECT CELL MATCH! Placing piece \(piece.correctRow),\(piece.correctColumn)")
                
                // Update piece state
                placePieceDirectly(at: pieceIndex)
                return
            } else if isCorrectCell {
                print("❌ Correct cell but too far away, distance: \(closestCell.distance)")
            }
        }
        
        // If we get here, the piece was not placed correctly
        print("❌ Not placed correctly, returning to original position")
        resetDragState()
    }
    
    private func placePieceDirectly(at index: Int) {
        // Create a copy of the pieces array and update the piece
        puzzleState.placePiece(at: index)
        
        // Reset drag state
        resetDragState()
    }
    
    private func resetDragState() {
        // Reset drag with animation
        withAnimation(.spring()) {
            dragOffset = .zero
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            draggedPieceIndex = nil
        }
    }
    
    private func checkForCorrectPlacement(pieceIndex: Int, finalLocation: CGPoint, cellWidth: CGFloat, cellHeight: CGFloat) {
        let piece = puzzleState.puzzlePieces[pieceIndex]
        
        print("Checking placement for piece \(piece.correctRow),\(piece.correctColumn) at \(finalLocation)")
        
        // Double-check we have grid cells to work with
        if gridCellPositions.isEmpty {
            print("⚠️ No grid cells initialized! Cannot check for placement.")
            resetDragState()
            return
        }
        
        // Flag to track if placement succeeded
        var placed = false
        
        // Loop through grid cell positions to find where the piece was dropped
        for row in gridCellPositions {
            for cellInfo in row {
                let cellRect = cellInfo.rect
                
                // Make detection very strict - almost exact placement required
                let expandedRect = CGRect(
                    x: cellRect.origin.x - cellWidth * 0.01, // Very small hit area - only 2% expansion
                    y: cellRect.origin.y - cellHeight * 0.01,
                    width: cellRect.width + cellWidth * 0.02,
                    height: cellRect.height + cellHeight * 0.02
                )
                
                // Debug hit testing
                if debugging {
                    print("Testing cell [\(cellInfo.row),\(cellInfo.column)]")
                    print("Cell rect: \(cellRect)")
                    print("Expanded rect: \(expandedRect)")
                    print("Contains drop point? \(expandedRect.contains(finalLocation))")
                    
                    // Calculate and print distance to this cell's center
                    let cellCenter = CGPoint(x: cellRect.midX, y: cellRect.midY)
                    let distance = sqrt(
                        pow(finalLocation.x - cellCenter.x, 2) +
                        pow(finalLocation.y - cellCenter.y, 2)
                    )
                    print("Distance to center: \(distance)")
                }
                
                // Check if this is the correct cell for this piece AND it's within the expanded hit area
                if cellInfo.row == piece.correctRow && 
                   cellInfo.column == piece.correctColumn && 
                   expandedRect.contains(finalLocation) {
                    
                    print("✅ CORRECT CELL MATCH! Placing piece \(piece.correctRow),\(piece.correctColumn)")
                    
                    // Update piece state
                    puzzleState.placePiece(at: pieceIndex)
                    
                    placed = true
                    resetDragState()
                    return
                }
            }
        }
        
        // If not placed, reset drag state
        if !placed {
            print("❌ Not placed correctly, returning to original position")
            resetDragState()
        }
    }
    
    private func initializePuzzlePieces() {
        // Generate puzzle pieces from the image
        let piecesImages = PuzzleImageHelper.generatePuzzlePieces(
            from: imageName,
            gridRows: gridRows,
            gridColumns: gridColumns
        )
        
        var pieces = [PuzzlePiece]()
        
        // Create PuzzlePiece models
        for row in 0..<gridRows {
            for column in 0..<gridColumns {
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
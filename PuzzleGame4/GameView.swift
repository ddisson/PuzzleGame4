import SwiftUI

struct GameView: View {
    // MARK: - Properties
    @State private var puzzlePieces: [PuzzlePiece] = []
    @State private var draggedPieceIndex: Int? = nil
    @State private var dragOffset: CGSize = .zero
    @State private var showFullImage = false
    @State private var puzzleCompleted = false
    
    // Grid configuration
    let gridSize = 2 // 2x2 puzzle
    let gridSpacing: CGFloat = 2
    let imageName = "anna_elza"
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width
            let gridWidth = min(availableWidth * 0.6, geometry.size.height * 0.6)
            let pieceWidth = (gridWidth - CGFloat(gridSize - 1) * gridSpacing) / CGFloat(gridSize)
            let gridOriginX = (geometry.size.width - gridWidth) * 0.3
            let gridOriginY = (geometry.size.height - gridWidth) * 0.5
            
            ZStack {
                // Main content
                HStack(spacing: 20) {
                    // MARK: Left Side - Puzzle Grid and Full Image
                    VStack {
                        // Full Image Preview (tappable)
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: gridWidth, height: gridWidth * 0.6)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(radius: 3)
                            .onTapGesture {
                                showFullImage = true
                            }
                            .padding(.bottom)
                        
                        // Puzzle Grid
                        ZStack {
                            // Grid background
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .shadow(radius: 3)
                            
                            // Grid cells
                            VStack(spacing: gridSpacing) {
                                ForEach(0..<gridSize, id: \.self) { row in
                                    HStack(spacing: gridSpacing) {
                                        ForEach(0..<gridSize, id: \.self) { column in
                                            ZStack {
                                                // Grid cell background
                                                Rectangle()
                                                    .fill(Color.gray.opacity(0.3))
                                                    .frame(width: pieceWidth, height: pieceWidth)
                                                    .cornerRadius(4)
                                                
                                                // Show placed pieces
                                                ForEach(puzzlePieces.indices.filter { 
                                                    puzzlePieces[$0].isPlaced && 
                                                    puzzlePieces[$0].correctRow == row && 
                                                    puzzlePieces[$0].correctColumn == column 
                                                }, id: \.self) { index in
                                                    PuzzlePieceView(uiImage: puzzlePieces[index].image)
                                                        .frame(width: pieceWidth, height: pieceWidth)
                                                        .clipShape(Rectangle())
                                                }
                                            }
                                            .id("cell_\(row)_\(column)")
                                        }
                                    }
                                }
                            }
                            .padding(gridSpacing)
                        }
                        .frame(width: gridWidth, height: gridWidth)
                    }
                    .frame(width: gridWidth)
                    
                    // MARK: Right Side - Unplaced Pieces
                    ZStack {
                        // Background
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.15))
                        
                        // Unplaced pieces
                        VStack(spacing: 10) {
                            ForEach(puzzlePieces.indices.filter { !puzzlePieces[$0].isPlaced }, id: \.self) { index in
                                PuzzlePieceView(uiImage: puzzlePieces[index].image)
                                    .frame(width: pieceWidth, height: pieceWidth)
                                    .clipShape(Rectangle())
                                    .shadow(radius: 2)
                                    .offset(draggedPieceIndex == index ? dragOffset : .zero)
                                    .gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                draggedPieceIndex = index
                                                dragOffset = value.translation
                                            }
                                            .onEnded { value in
                                                // Get the final position of the drag
                                                let finalPosition = CGPoint(
                                                    x: value.location.x - value.startLocation.x + value.startLocation.x,
                                                    y: value.location.y - value.startLocation.y + value.startLocation.y
                                                )
                                                
                                                // Calculate if the piece is over a grid cell
                                                var placedSuccessfully = false
                                                
                                                // Check for each grid cell if the piece is over it
                                                for row in 0..<gridSize {
                                                    for column in 0..<gridSize {
                                                        let cellX = gridOriginX + CGFloat(column) * (pieceWidth + gridSpacing) + pieceWidth/2 + gridSpacing
                                                        let cellY = gridOriginY + CGFloat(row) * (pieceWidth + gridSpacing) + pieceWidth/2 + gridSpacing
                                                        
                                                        // Calculate distance between piece center and cell center
                                                        let distance = sqrt(
                                                            pow(finalPosition.x - cellX, 2) + 
                                                            pow(finalPosition.y - cellY, 2)
                                                        )
                                                        
                                                        // If distance is less than 70% of piece width, consider it a match
                                                        // (70% coverage approximately translates to distance being less than 30% of width)
                                                        let coverageThreshold = pieceWidth * 0.5
                                                        
                                                        if distance < coverageThreshold {
                                                            // Check if this is the correct position for the piece
                                                            if row == puzzlePieces[index].correctRow && 
                                                               column == puzzlePieces[index].correctColumn {
                                                                
                                                                // Place the piece
                                                                withAnimation(.spring()) {
                                                                    puzzlePieces[index].isPlaced = true
                                                                    dragOffset = .zero
                                                                }
                                                                
                                                                placedSuccessfully = true
                                                                
                                                                // Check if puzzle is complete
                                                                checkPuzzleCompletion()
                                                                break
                                                            }
                                                        }
                                                    }
                                                    
                                                    if placedSuccessfully {
                                                        break
                                                    }
                                                }
                                                
                                                if !placedSuccessfully {
                                                    // Return to original position with animation
                                                    withAnimation(.spring()) {
                                                        dragOffset = .zero
                                                    }
                                                }
                                                
                                                // Reset drag state
                                                if !placedSuccessfully {
                                                    draggedPieceIndex = nil
                                                }
                                            }
                                    )
                            }
                        }
                        .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: gridWidth)
                }
                .padding()
            }
            .onAppear {
                // Initialize puzzle pieces
                initializePuzzlePieces()
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
            .alert(isPresented: $puzzleCompleted) {
                Alert(
                    title: Text("Puzzle Completed!"),
                    message: Text("Great job! You finished the puzzle."),
                    dismissButton: .default(Text("Play Again"), action: {
                        // Reset the game
                        initializePuzzlePieces()
                    })
                )
            }
        }
    }
    
    // MARK: - Methods
    
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
                    isPlaced: false,
                    originalPosition: nil
                )
                pieces.append(piece)
            }
        }
        
        // Shuffle the pieces
        puzzlePieces = pieces.shuffled()
        puzzleCompleted = false
    }
    
    private func checkPuzzleCompletion() {
        if puzzlePieces.allSatisfy({ $0.isPlaced }) {
            // All pieces are placed, puzzle is complete!
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.puzzleCompleted = true
            }
        }
    }
}

// MARK: - Puzzle Piece Model
struct PuzzlePiece: Identifiable, Equatable {
    let id: UUID
    let image: UIImage
    let correctRow: Int
    let correctColumn: Int
    var isPlaced: Bool
    var originalPosition: CGPoint?
    
    static func == (lhs: PuzzlePiece, rhs: PuzzlePiece) -> Bool {
        return lhs.id == rhs.id
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
} 
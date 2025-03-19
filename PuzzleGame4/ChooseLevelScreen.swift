import SwiftUI

struct LevelCard: View {
    let level: PuzzleLevel
    
    var body: some View {
        VStack {
            // Image
            Image(level.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 120)
                .cornerRadius(8)
                .shadow(radius: 2)
            
            // Level name
            Text(level.name)
                .font(.headline)
                .padding(.top, 4)
            
            // Grid size
            Text("\(level.gridRows)×\(level.gridColumns) Puzzle")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // Difficulty
            Text(level.difficulty.description)
                .font(.caption)
                .foregroundColor(difficultyColor(for: level.difficulty))
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(difficultyColor(for: level.difficulty).opacity(0.1))
                .cornerRadius(4)
                .padding(.top, 2)
        }
        .padding()
        .frame(width: 180)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 1)
    }
    
    private func difficultyColor(for difficulty: PuzzleLevel.Difficulty) -> Color {
        switch difficulty {
        case .easy:
            return .green
        case .medium:
            return .orange
        case .hard:
            return .red
        }
    }
}

struct ChooseLevelScreen: View {
    @State private var selectedLevel: PuzzleLevel?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    // Game Title
                    Text("Puzzle Game")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 20)
                    
                    Text("Choose a level to play")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                    
                    // Level Grid
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 160), spacing: 20)
                    ], spacing: 20) {
                        ForEach(PuzzleLevel.allLevels) { level in
                            NavigationLink {
                                GameView(level: level)
                            } label: {
                                LevelCard(level: level)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 50)
            }
            .background(Color(UIColor.systemGray6))
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ChooseLevelScreen_Previews: PreviewProvider {
    static var previews: some View {
        ChooseLevelScreen()
    }
} 
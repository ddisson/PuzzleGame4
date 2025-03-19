import SwiftUI

struct ChooseLevelScreen: View {
    @State private var navigateToGame = false
    @State private var selectedLevel: PuzzleLevel?
    
    var body: some View {
        NavigationView {
            VStack {
                // Header
                Text("Puzzle Game")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 30)
                
                Text("Choose a level")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 30)
                
                // Level cards
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(PuzzleLevel.allLevels) { level in
                            Button(action: {
                                selectedLevel = level
                                navigateToGame = true
                            }) {
                                LevelCard(level: level)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Navigation link (hidden) for navigating to the game
                NavigationLink(
                    destination: GameView(),
                    isActive: $navigateToGame,
                    label: { EmptyView() }
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct LevelCard: View {
    let level: PuzzleLevel
    
    var body: some View {
        HStack {
            // Level preview image
            Image(level.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            // Level details
            VStack(alignment: .leading, spacing: 4) {
                Text(level.name)
                    .font(.headline)
                
                Text("Grid: \(level.gridRows)×\(level.gridColumns)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("Difficulty: \(level.difficulty.description)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.leading, 10)
            
            Spacer()
            
            // Play arrow
            Image(systemName: "play.circle.fill")
                .font(.system(size: 30))
                .foregroundColor(.blue)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

struct ChooseLevelScreen_Previews: PreviewProvider {
    static var previews: some View {
        ChooseLevelScreen()
    }
} 
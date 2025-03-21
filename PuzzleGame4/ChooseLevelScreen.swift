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
        case .hardcore:
            return .purple
        }
    }
}

struct ChooseLevelScreen: View {
    @StateObject private var levelNavigator = LevelNavigator.shared
    @State private var playNextLevelObserver: NSObjectProtocol?
    
    var body: some View {
        NavigationStack(path: $levelNavigator.activeNavigationPath) {
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
                            Button {
                                print("📱 Manual selection of level: \(level.name)")
                                levelNavigator.navigateToLevel(level)
                            } label: {
                                LevelCard(level: level)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 50)
            }
            .background(Color(UIColor.systemGray6))
            .navigationDestination(for: PuzzleLevel.self) { level in
                GameView(level: level)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            print("📱 ChooseLevelScreen appeared")
            setupNextLevelNotification()
        }
        .onDisappear {
            if let observer = playNextLevelObserver {
                NotificationCenter.default.removeObserver(observer)
                playNextLevelObserver = nil
            }
        }
    }
    
    private func setupNextLevelNotification() {
        // Clean up existing observer if it exists
        if let observer = playNextLevelObserver {
            NotificationCenter.default.removeObserver(observer)
            playNextLevelObserver = nil
        }
        
        // Add a fresh observer
        playNextLevelObserver = NotificationCenter.default.addObserver(
            forName: Notification.Name("PlayNextLevel"),
            object: nil,
            queue: .main
        ) { notification in
            if let level = notification.userInfo?["nextLevel"] as? PuzzleLevel {
                print("📱 ChooseLevelScreen received notification to play next level: \(level.name)")
                
                // Need to wait for the previous view to be dismissed
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    // Use our shared navigator
                    self.levelNavigator.navigateToLevel(level)
                }
            } else {
                print("⚠️ Received PlayNextLevel notification but couldn't extract level info")
            }
        }
    }
}

struct ChooseLevelScreen_Previews: PreviewProvider {
    static var previews: some View {
        ChooseLevelScreen()
    }
} 
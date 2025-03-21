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
    @State private var navigateToLevel: PuzzleLevel?
    @State private var playNextLevelObserver: NSObjectProtocol?
    
    var body: some View {
        NavigationStack {
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
                            NavigationLink(value: level) {
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
            .navigationBarHidden(true)
            .navigationDestination(for: PuzzleLevel.self) { level in
                GameView(level: level)
            }
        }
        .onAppear {
            setupNextLevelNotification()
        }
        .onDisappear {
            if let observer = playNextLevelObserver {
                NotificationCenter.default.removeObserver(observer)
            }
        }
    }
    
    private func setupNextLevelNotification() {
        // Make sure we don't add the observer multiple times
        if playNextLevelObserver == nil {
            playNextLevelObserver = NotificationCenter.default.addObserver(
                forName: Notification.Name("PlayNextLevel"),
                object: nil,
                queue: .main
            ) { notification in
                if let level = notification.userInfo?["nextLevel"] as? PuzzleLevel {
                    navigateToLevel = level
                    
                    // Recreate the navigation stack with the new level
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                            if let rootViewController = window.rootViewController {
                                // Create a new ChooseLevelScreen
                                let newChooseLevelScreen = ChooseLevelScreen()
                                
                                // Trigger navigation to the next level
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    newChooseLevelScreen.navigateToLevel = level
                                }
                                
                                // Reset the root view controller
                                let hostingController = UIHostingController(rootView: newChooseLevelScreen)
                                window.rootViewController = hostingController
                            }
                        }
                    }
                }
            }
        }
    }
}

struct ChooseLevelScreen_Previews: PreviewProvider {
    static var previews: some View {
        ChooseLevelScreen()
    }
} 
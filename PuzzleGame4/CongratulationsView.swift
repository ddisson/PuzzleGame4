import SwiftUI

struct CongratulationsView: View {
    let level: PuzzleLevel
    let onMenuTapped: () -> Void
    let onNextLevelTapped: () -> Void
    
    @State private var isImageAnimated = false
    @Environment(\.presentationMode) var presentationMode
    
    // Computed property to find the next level
    private var nextLevel: PuzzleLevel {
        if let currentIndex = PuzzleLevel.allLevels.firstIndex(where: { $0.id == level.id }) {
            let nextIndex = (currentIndex + 1) % PuzzleLevel.allLevels.count
            return PuzzleLevel.allLevels[nextIndex]
        }
        return PuzzleLevel.allLevels.first!
    }
    
    var body: some View {
        ZStack {
            // Background with fireworks
            Color.black.edgesIgnoringSafeArea(.all)
            FireworksView()
            
            // Content
            VStack(spacing: 30) {
                Spacer()
                
                // Completed puzzle image
                Image(level.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .cornerRadius(12)
                    .padding(.horizontal, 30)
                    .scaleEffect(isImageAnimated ? 1.0 : 0.5)
                    .opacity(isImageAnimated ? 1.0 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isImageAnimated)
                
                // Congratulations text
                Text("Well done, Sonya!")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
                    .shadow(color: .black, radius: 2, x: 0, y: 2)
                    .scaleEffect(isImageAnimated ? 1.0 : 0.8)
                    .opacity(isImageAnimated ? 1.0 : 0)
                    .animation(.easeInOut(duration: 0.8).delay(0.3), value: isImageAnimated)
                
                Spacer()
                
                // Navigation buttons
                HStack(spacing: 20) {
                    // Menu button
                    Button(action: onMenuTapped) {
                        HStack {
                            Image(systemName: "house.fill")
                            Text("Menu")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 25)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.8))
                        )
                    }
                    
                    // Next level button
                    Button(action: {
                        print("🎮 Next Level button pressed - current level: \(level.name), next level: \(nextLevel.name)")
                        
                        // First close the congratulations view
                        withAnimation {
                            isImageAnimated = false
                        }
                        
                        // Give time for the animation to complete
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            // Then call the provided closure to dismiss GameView
                            onNextLevelTapped()
                        }
                    }) {
                        HStack {
                            Text("Next Level")
                            Image(systemName: "arrow.right.circle.fill")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 25)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green.opacity(0.8))
                        )
                    }
                }
                .padding(.bottom, 50)
                .opacity(isImageAnimated ? 1.0 : 0)
                .animation(.easeIn.delay(0.8), value: isImageAnimated)
            }
        }
        .onAppear {
            // Debug - print bundle contents to see if audio files are included
            AudioManager.shared.debugPrintBundleContents()
            
            // First try to play a random sound from the VictorySounds folder
            let didPlayFromFolder = AudioManager.shared.playRandomSound(fromDirectory: "VictorySounds")
            
            // Only use fallback if the folder method failed
            if !didPlayFromFolder {
                let victoryFiles = ["GoodJob", "MolodecSonya", "SonyaWins", "gorditsya", "welldone"]
                if let randomSound = victoryFiles.randomElement() {
                    print("🎵 Falling back to direct file: \(randomSound)")
                    AudioManager.shared.playSound(named: randomSound)
                }
            }
            
            // Start animation sequence
            withAnimation {
                isImageAnimated = true
            }
        }
    }
}

struct CongratulationsView_Previews: PreviewProvider {
    static var previews: some View {
        CongratulationsView(
            level: PuzzleLevel.allLevels.first!, 
            onMenuTapped: {}, 
            onNextLevelTapped: {}
        )
    }
} 
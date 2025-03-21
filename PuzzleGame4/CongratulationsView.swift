import SwiftUI

struct CongratulationsView: View {
    let level: PuzzleLevel
    let onMenuTapped: () -> Void
    let onNextLevelTapped: () -> Void
    
    @State private var isImageAnimated = false
    
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
                    Button(action: onNextLevelTapped) {
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
            // Play victory sound
            AudioManager.shared.playSound(named: "victory_sound", fileExtension: "m4a")
            
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
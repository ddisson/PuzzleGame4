import SwiftUI
import Foundation

struct FireworkParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var color: Color
    var creationDate = Date()
    var lifetime: Double
    var size: CGFloat
    
    var opacity: Double {
        let age = Date().timeIntervalSince(creationDate)
        return max(0, 1 - (age / lifetime))
    }
    
    var scale: CGFloat {
        let age = Date().timeIntervalSince(creationDate)
        let progress = CGFloat(age / lifetime)
        return size * (1.0 + progress * 2)
    }
}

struct FireworksView: View {
    @State private var fireworks: [FireworkParticle] = []
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            ForEach(fireworks) { firework in
                Circle()
                    .fill(firework.color)
                    .frame(width: firework.scale, height: firework.scale)
                    .position(firework.position)
                    .opacity(firework.opacity)
            }
        }
        .onAppear {
            startFireworks()
        }
        .onDisappear {
            stopFireworks()
        }
    }
    
    private func startFireworks() {
        // Create initial fireworks
        createFirework()
        
        // Schedule timer to add new fireworks and clean up old ones
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            createFirework()
            cleanupExpiredFireworks()
        }
    }
    
    private func stopFireworks() {
        timer?.invalidate()
        timer = nil
    }
    
    private func createFirework() {
        // Create a new firework burst at a random position
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let position = CGPoint(
            x: CGFloat.random(in: screenWidth * 0.2...screenWidth * 0.8),
            y: CGFloat.random(in: screenHeight * 0.2...screenHeight * 0.8)
        )
        
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
        
        // Create 30-50 particles for each burst
        let particleCount = Int.random(in: 30...50)
        
        for _ in 0..<particleCount {
            let angle = Double.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 20...100)
            
            let particlePosition = CGPoint(
                x: position.x + CGFloat(Foundation.cos(angle)) * distance,
                y: position.y + CGFloat(Foundation.sin(angle)) * distance
            )
            
            let particle = FireworkParticle(
                position: particlePosition,
                color: colors.randomElement() ?? .yellow,
                lifetime: Double.random(in: 0.8...1.5),
                size: CGFloat.random(in: 2...6)
            )
            
            fireworks.append(particle)
        }
    }
    
    private func cleanupExpiredFireworks() {
        fireworks.removeAll { firework in
            Date().timeIntervalSince(firework.creationDate) > firework.lifetime
        }
    }
} 
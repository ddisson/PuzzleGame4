import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    private var audioPlayers: [URL: AVAudioPlayer] = [:]
    
    // Private initializer for singleton
    private init() {}
    
    func playSound(named filename: String, fileExtension: String = "mp3", volume: Float = 1.0) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: fileExtension) else {
            print("⚠️ Could not find sound file: \(filename).\(fileExtension)")
            return
        }
        
        if let player = audioPlayers[url] {
            player.volume = volume
            player.currentTime = 0
            player.play()
        } else {
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.volume = volume
                player.prepareToPlay()
                audioPlayers[url] = player
                player.play()
            } catch {
                print("⚠️ Could not create audio player for \(url): \(error.localizedDescription)")
            }
        }
    }
    
    func stopSound(named filename: String, fileExtension: String = "mp3") {
        guard let url = Bundle.main.url(forResource: filename, withExtension: fileExtension),
              let player = audioPlayers[url] else {
            return
        }
        
        player.stop()
    }
} 
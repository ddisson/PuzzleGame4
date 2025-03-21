import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    private var audioPlayers: [URL: AVAudioPlayer] = [:]
    
    // Store cached sound directories
    private var soundDirectories: [String: [URL]] = [:]
    
    // Private initializer for singleton
    private init() {}
    
    /// Play a specific sound file
    /// Returns true if the sound was successfully played, false otherwise
    @discardableResult
    func playSound(named filename: String, fileExtension: String = "m4a", volume: Float = 1.0) -> Bool {
        // Try multiple approaches to find the sound file
        var soundURL: URL? = nil
        
        // Approach 1: Look in the main bundle (standard approach)
        if let url = Bundle.main.url(forResource: filename, withExtension: fileExtension) {
            soundURL = url
            print("✅ Found sound file at: \(url.path)")
        }
        
        // Approach 2: Try looking in VictorySounds directory
        if soundURL == nil, let resourcePath = Bundle.main.resourcePath {
            let victorySoundsPath = resourcePath + "/VictorySounds"
            let potentialPath = victorySoundsPath + "/" + filename + "." + fileExtension
            let fileURL = URL(fileURLWithPath: potentialPath)
            
            if FileManager.default.fileExists(atPath: potentialPath) {
                soundURL = fileURL
                print("✅ Found sound file at: \(potentialPath)")
            }
        }
        
        // Approach 3: Look anywhere in the bundle
        if soundURL == nil, let resourcePath = Bundle.main.resourcePath {
            do {
                let fileManager = FileManager.default
                let items = try fileManager.contentsOfDirectory(atPath: resourcePath)
                
                let target = filename + "." + fileExtension
                if items.contains(target) {
                    let fullPath = resourcePath + "/" + target
                    soundURL = URL(fileURLWithPath: fullPath)
                    print("✅ Found sound file at root level: \(fullPath)")
                }
            } catch {
                print("⚠️ Error scanning resource path: \(error.localizedDescription)")
            }
        }
        
        // If we found a URL, play the sound
        if let url = soundURL {
            playSoundFromURL(url, volume: volume)
            return true
        } else {
            print("⚠️ Could not find sound file: \(filename).\(fileExtension) in any location")
            return false
        }
    }
    
    /// Play a random sound from a directory
    /// Returns true if a sound was successfully played, false otherwise
    @discardableResult
    func playRandomSound(fromDirectory directory: String, fileExtension: String = "m4a", volume: Float = 1.0) -> Bool {
        // Get all sound files in the directory
        let soundFiles = getSoundFilesInDirectory(directory, fileExtension: fileExtension)
        
        if soundFiles.isEmpty {
            print("⚠️ No sound files found in directory: \(directory)")
            return false
        }
        
        // Choose a random sound file
        if let randomSoundURL = soundFiles.randomElement() {
            print("🔊 Playing random sound: \(randomSoundURL.lastPathComponent)")
            playSoundFromURL(randomSoundURL, volume: volume)
            return true
        }
        
        return false
    }
    
    /// Get all sound files in a directory
    private func getSoundFilesInDirectory(_ directory: String, fileExtension: String) -> [URL] {
        // Check if we already cached this directory
        let cacheKey = "\(directory).\(fileExtension)"
        if let cachedFiles = soundDirectories[cacheKey], !cachedFiles.isEmpty {
            return cachedFiles
        }
        
        // Try multiple approaches to find the sound files
        var soundFiles: [URL] = []
        
        // Approach 1: Check if directory exists in bundle
        if let directoryURL = Bundle.main.resourceURL?.appendingPathComponent(directory) {
            do {
                let fileManager = FileManager.default
                
                // Check if directory exists
                var isDirectory: ObjCBool = false
                if fileManager.fileExists(atPath: directoryURL.path, isDirectory: &isDirectory), 
                   isDirectory.boolValue {
                    
                    // Get all files with matching extension
                    let directoryContents = try fileManager.contentsOfDirectory(at: directoryURL, 
                                                                          includingPropertiesForKeys: nil, 
                                                                          options: .skipsHiddenFiles)
                    soundFiles = directoryContents.filter { $0.pathExtension.lowercased() == fileExtension.lowercased() }
                    
                    if !soundFiles.isEmpty {
                        print("🎵 Found \(soundFiles.count) sound files in directory: \(directory)")
                        soundDirectories[cacheKey] = soundFiles
                        return soundFiles
                    }
                }
            } catch {
                print("⚠️ Error reading directory \(directory): \(error.localizedDescription)")
            }
        }
        
        // Approach 2: Look for individual sound files with the directory as a prefix
        let bundle = Bundle.main
        if let resourcePath = bundle.resourcePath {
            do {
                let fileManager = FileManager.default
                let items = try fileManager.contentsOfDirectory(atPath: resourcePath)
                
                // Filter for files that start with the directory name and have the right extension
                let matchingFiles = items.filter { 
                    let filename = ($0 as NSString).deletingPathExtension
                    let ext = ($0 as NSString).pathExtension.lowercased()
                    return filename.hasPrefix(directory) && ext == fileExtension.lowercased()
                }
                
                if !matchingFiles.isEmpty {
                    soundFiles = matchingFiles.map { resourcePath + "/" + $0 }.map { URL(fileURLWithPath: $0) }
                    print("🎵 Found \(soundFiles.count) sound files with prefix: \(directory)")
                    soundDirectories[cacheKey] = soundFiles
                    return soundFiles
                }
            } catch {
                print("⚠️ Error listing resource path: \(error.localizedDescription)")
            }
        }
        
        // Approach 3: Just look for any m4a files in the bundle
        if soundFiles.isEmpty && fileExtension.lowercased() == "m4a" {
            print("⚠️ Falling back to finding any .m4a files in the bundle")
            if let resourcePath = bundle.resourcePath {
                do {
                    let fileManager = FileManager.default
                    let items = try fileManager.contentsOfDirectory(atPath: resourcePath)
                    
                    // Filter for files that have the right extension
                    let matchingFiles = items.filter { ($0 as NSString).pathExtension.lowercased() == "m4a" }
                    
                    if !matchingFiles.isEmpty {
                        soundFiles = matchingFiles.map { resourcePath + "/" + $0 }.map { URL(fileURLWithPath: $0) }
                        print("🎵 Found \(soundFiles.count) .m4a files in bundle")
                        // Don't cache this as it's a fallback
                        return soundFiles
                    }
                } catch {
                    print("⚠️ Error listing resource path: \(error.localizedDescription)")
                }
            }
        }
        
        // If we got here, we couldn't find any sound files
        print("⚠️ No sound files found in directory: \(directory)")
        return []
    }
    
    /// Play sound from a URL
    private func playSoundFromURL(_ url: URL, volume: Float) {
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
    
    /// Stop a specific sound
    func stopSound(named filename: String, fileExtension: String = "m4a") {
        guard let url = Bundle.main.url(forResource: filename, withExtension: fileExtension),
              let player = audioPlayers[url] else {
            return
        }
        
        player.stop()
    }
    
    /// Debug method to print all resources in the bundle
    func debugPrintBundleContents() {
        guard let resourcePath = Bundle.main.resourcePath else {
            print("❌ Could not get resource path")
            return
        }
        
        print("📂 Bundle resource path: \(resourcePath)")
        
        do {
            let fileManager = FileManager.default
            let items = try fileManager.contentsOfDirectory(atPath: resourcePath)
            
            print("📄 Bundle contains \(items.count) files/directories:")
            for item in items.sorted() {
                let itemPath = resourcePath + "/" + item
                var isDir: ObjCBool = false
                if fileManager.fileExists(atPath: itemPath, isDirectory: &isDir) {
                    if isDir.boolValue {
                        print("  📁 \(item)/")
                        // List contents of directories
                        if let subItems = try? fileManager.contentsOfDirectory(atPath: itemPath) {
                            for subItem in subItems.sorted() {
                                print("    - \(subItem)")
                            }
                        }
                    } else {
                        print("  📄 \(item)")
                    }
                }
            }
            
            // Specifically look for audio files
            let audioFiles = items.filter { 
                let ext = ($0 as NSString).pathExtension.lowercased()
                return ext == "m4a" || ext == "mp3" || ext == "wav"
            }
            
            if !audioFiles.isEmpty {
                print("🔊 Found \(audioFiles.count) audio files:")
                for audioFile in audioFiles.sorted() {
                    print("  🎵 \(audioFile)")
                }
            } else {
                print("⚠️ No audio files found in the root bundle directory")
            }
            
        } catch {
            print("❌ Error listing bundle contents: \(error.localizedDescription)")
        }
    }
} 
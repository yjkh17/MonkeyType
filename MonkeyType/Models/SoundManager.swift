import Foundation
import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    private var players: [SoundType: AVAudioPlayer?] = [:]
    
    enum SoundType: CaseIterable {
        case keypress
        case error
        case complete
        
        var filename: String {
            switch self {
            case .keypress: return "click"
            case .error: return "error"
            case .complete: return "complete"
            }
        }
    }
    
    func loadSounds() {
        SoundType.allCases.forEach { type in
            guard let url = Bundle.main.url(forResource: type.filename, withExtension: "wav") else { return }
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                players[type] = player
            } catch {
                print("Failed to load sound: \(error)")
            }
        }
    }
    
    func playSound(_ type: SoundType) {
        guard let player = players[type] ?? nil else { return }
        player.stop()
        player.currentTime = 0
        player.volume = Float(UserDefaults.standard.double(forKey: "soundVolume"))
        player.play()
    }
    
    private init() {
        loadSounds()
    }
}

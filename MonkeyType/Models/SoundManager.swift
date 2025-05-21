import Foundation
import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    private var player: AVAudioPlayer?
    
    enum SoundType {
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
    
    func playSound(_ type: SoundType) {
        guard let url = Bundle.main.url(forResource: type.filename, withExtension: "wav") else { return }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Failed to play sound: \(error)")
        }
    }
}
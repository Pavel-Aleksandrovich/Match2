import Foundation
import AudioToolbox

enum SoundType: String {
    case click = "clickSound"
    case win = "winSound"
    case lose = "loseSound"
}

enum SoundManager {
    
    static func play(_ type: SoundType) {
        if let soundURL = Bundle.main.url(forResource: type.rawValue, withExtension: "mp3") {
            var soundID: SystemSoundID = 0
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &soundID)
            AudioServicesPlaySystemSound(soundID)
        } else {
            print("Sound not found")
        }
    }
}

import AVFoundation
import Foundation
import SpriteKit

class AudioSettingsManager {
    
    //MARK: - Properties
    
    private static let soundEnabledKey = "isSoundEnabled"
    private static let musicEnabledKey = "isMusicEnabled"
    
    private static let defaultSoundEnabled = true
    private static let defaultMusicEnabled = true
    
    private var musicPlayer: AVAudioPlayer?
    private var soundPlayer: AVAudioPlayer?
    private var currentTrack: String?

    static let shared = AudioSettingsManager()
    
    private init() { }
    
    var isSoundEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: AudioSettingsManager.soundEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: AudioSettingsManager.soundEnabledKey)
        }
    }
    
    var isMusicEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: AudioSettingsManager.musicEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: AudioSettingsManager.musicEnabledKey)
            updateMusicState()
        }
    }
    
    // MARK: - Setups
    
    func initializeDefaultSettings() {
        if UserDefaults.standard.object(forKey: AudioSettingsManager.soundEnabledKey) == nil {
            isSoundEnabled = AudioSettingsManager.defaultSoundEnabled
        }
        if UserDefaults.standard.object(forKey: AudioSettingsManager.musicEnabledKey) == nil {
            isMusicEnabled = AudioSettingsManager.defaultMusicEnabled
        }
    }
    
    // MARK: - `Music`
    
    func playBackgroundMusic(fileName: String) {
        guard isMusicEnabled else { return }

        if currentTrack == fileName, musicPlayer?.isPlaying == true {
            return
        }

        stopBackgroundMusic()
        
        if let musicURL = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
            do {
                musicPlayer = try AVAudioPlayer(contentsOf: musicURL)
                musicPlayer?.numberOfLoops = -1
                musicPlayer?.play()
                currentTrack = fileName
            } catch {
                print("Error playing background music: \(error)")
            }
        }
    }
    
    func stopBackgroundMusic() {
        musicPlayer?.stop()
        currentTrack = nil
    }
    
    func pauseBackgroundMusic() {
        musicPlayer?.pause()
    }
    
    func updateMusicState() {
        if isMusicEnabled {
            musicPlayer?.play()
        } else {
            stopBackgroundMusic()
        }
    }
    
    // MARK: - Sound

    func playGameSound(fileName: String, in scene: SKScene) {
        guard isSoundEnabled else { return }

        let soundAction = SKAction.playSoundFileNamed(fileName, waitForCompletion: false)
        scene.run(soundAction)
    }
    
}


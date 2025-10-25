//
//  AudioManager.swift
//  N1021erwtywrewth
//
//  Created by Agent on 24.10.2025.
//

import AVFoundation
import UIKit
import Combine

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    @Published var musicEnabled: Bool = true
    @Published var sfxEnabled: Bool = true
    @Published var hapticsEnabled: Bool = true
    
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    
    private init() {
        setupAudio()
    }
    
    private func setupAudio() {
        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        
        if let engine = audioEngine, let player = playerNode {
            engine.attach(player)
            engine.connect(player, to: engine.mainMixerNode, format: nil)
            
            do {
                try engine.start()
            } catch {
                print("Audio engine failed to start: \(error)")
            }
        }
    }
    
    // MARK: - Sound Effects
    func playCorrectSound() {
        guard sfxEnabled else { return }
        playTone(frequency: 800, duration: 0.1)
        if hapticsEnabled {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
    
    func playIncorrectSound() {
        guard sfxEnabled else { return }
        playTone(frequency: 200, duration: 0.15)
        if hapticsEnabled {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
    
    func playComboSound() {
        guard sfxEnabled else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let frequencies: [Float] = [523, 659, 784, 1047]
            for freq in frequencies {
                self?.playTone(frequency: freq, duration: 0.08)
                Thread.sleep(forTimeInterval: 0.08)
            }
        }
        if hapticsEnabled {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
    
    func playJarSealSound() {
        guard sfxEnabled else { return }
        playTone(frequency: 600, duration: 0.12)
    }
    
    func playUISound() {
        guard sfxEnabled else { return }
        playTone(frequency: 400, duration: 0.05)
        if hapticsEnabled {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    func playTwistSound() {
        guard sfxEnabled else { return }
        playTone(frequency: 700, duration: 0.2)
        if hapticsEnabled {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        }
    }
    
    // MARK: - Haptics
    func playLightHaptic() {
        guard hapticsEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func playMediumHaptic() {
        guard hapticsEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    func playHeavyHaptic() {
        guard hapticsEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    // MARK: - Tone Generation
    private func playTone(frequency: Float, duration: TimeInterval) {
        guard let engine = audioEngine, let player = playerNode else { return }
        
        let sampleRate = 44100.0
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: engine.mainMixerNode.outputFormat(forBus: 0), frameCapacity: frameCount) else {
            return
        }
        
        buffer.frameLength = frameCount
        
        let channels = Int(buffer.format.channelCount)
        guard let floatData = buffer.floatChannelData else { return }
        
        for frame in 0..<Int(frameCount) {
            let value = sin(2.0 * Float.pi * frequency * Float(frame) / Float(sampleRate))
            let envelope = Float(frame) / Float(frameCount)
            let dampedValue = value * (1.0 - envelope) * 0.3
            
            for channel in 0..<channels {
                floatData[channel][frame] = dampedValue
            }
        }
        
        player.scheduleBuffer(buffer, completionHandler: nil)
        
        if !player.isPlaying {
            player.play()
        }
    }
}

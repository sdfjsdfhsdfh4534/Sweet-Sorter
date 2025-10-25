//
//  SettingsViewModel.swift
//  N1021erwtywrewth
//
//  Created by Agent on 24.10.2025.
//

import Foundation
import SwiftUI
import Combine

class SettingsViewModel: ObservableObject {
    @Published var settings: GameSettings {
        didSet {
            saveSettings()
        }
    }
    
    private let audioManager = AudioManager.shared
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "gameSettings"),
           let settings = try? JSONDecoder().decode(GameSettings.self, from: data) {
            self.settings = settings
        } else {
            self.settings = GameSettings()
        }
        
        syncAudioManager()
    }
    
    func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: "gameSettings")
        }
        syncAudioManager()
    }
    
    private func syncAudioManager() {
        audioManager.musicEnabled = settings.musicEnabled
        audioManager.sfxEnabled = settings.sfxEnabled
        audioManager.hapticsEnabled = settings.hapticsEnabled
    }
}

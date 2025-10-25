//
//  GameViewModel.swift
//  N1021erwtywrewth
//
//  Created by Agent on 24.10.2025.
//

import Foundation
import SwiftUI
import Combine

enum GameState {
    case menu
    case playing
    case paused
    case gameOver
}

class GameViewModel: ObservableObject {
    @Published var gameState: GameState = .menu
    @Published var currentMode: GameMode = .classic
    @Published var roundConfig: RoundConfig = RoundConfig.fallback()
    @Published var candies: [Candy] = []
    @Published var stats: GameStats = GameStats()
    @Published var timeRemaining: TimeInterval = 70
    @Published var lives: Int = 3
    @Published var showExplanation: Bool = false
    @Published var explanationText: String = ""
    @Published var lastDroppedCandy: Candy?
    @Published var lastDroppedJar: Jar?
    @Published var showTwist: Bool = false
    @Published var twistMessage: String = ""
    @Published var complexity: Int = 3
    @Published var mimiNote: String = ""
    
    private var timer: Timer?
    private var twistTimer: Timer?
    private var candySpawnTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private let audioManager = AudioManager.shared
    
    var settings: GameSettings {
        get {
            if let data = UserDefaults.standard.data(forKey: "gameSettings"),
               let settings = try? JSONDecoder().decode(GameSettings.self, from: data) {
                return settings
            }
            return GameSettings()
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: "gameSettings")
            }
        }
    }
    
    var records: GameRecords {
        get {
            if let data = UserDefaults.standard.data(forKey: "gameRecords"),
               let records = try? JSONDecoder().decode(GameRecords.self, from: data) {
                return records
            }
            return GameRecords()
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: "gameRecords")
            }
        }
    }
    
    // MARK: - Game Control
    func startGame(mode: GameMode) {
        currentMode = mode
        gameState = .playing
        resetStats()
        
        lives = mode.initialLives ?? 999
        timeRemaining = mode.duration ?? 0
        
        let jarCount = complexity <= 3 ? 2 : (complexity <= 6 ? 3 : 4)
        
        roundConfig = RoundConfig.fallback()
        startRound()
    }
    
    private func startRound() {
        candies.removeAll()
        spawnCandies()
        
        if currentMode.duration != nil {
            startTimer()
        }
        
        if let twist = roundConfig.twist, let whenSeconds = twist.whenSeconds {
            scheduleTwist(at: whenSeconds)
        }
        
        startCandySpawning()
    }
    
    func pauseGame() {
        guard gameState == .playing else { return }
        gameState = .paused
        stopTimers()
    }
    
    func resumeGame() {
        guard gameState == .paused else { return }
        gameState = .playing
        
        if currentMode.duration != nil {
            startTimer()
        }
        startCandySpawning()
    }
    
    func restartGame() {
        stopTimers()
        startGame(mode: currentMode)
    }
    
    func quitToMenu() {
        stopTimers()
        gameState = .menu
        candies.removeAll()
    }
    
    func endGame() {
        stopTimers()
        gameState = .gameOver
        
        var updatedRecords = records
        updatedRecords.updateBest(mode: currentMode, score: stats.score)
        updatedRecords.totalRounds += 1
        updatedRecords.totalCorrectDrops += stats.correctDrops
        updatedRecords.totalIncorrectDrops += stats.incorrectDrops
        updatedRecords.longestStreak = max(updatedRecords.longestStreak, stats.maxStreak)
        records = updatedRecords
        
        // Генерируем заметку Мими
        generateMimiNote()
        
        // Генерируем новые правила для следующего раунда
        generateNewRound()
    }
    
    // MARK: - Candy Management
    func dropCandy(_ candy: Candy, into jar: Jar) {
        print("Attempting to drop candy: \(candy.color.rawValue) \(candy.shape.rawValue) into jar: \(jar.label)")
        print("Game state: \(gameState)")
        
        guard gameState == .playing else { 
            print("Game not in playing state, drop cancelled")
            return 
        }
        
        let dropTime = Date().timeIntervalSince(candy.spawnTime)
        stats.totalDropTime += dropTime
        stats.dropCount += 1
        
        let isCorrect = RuleEngine.evaluate(candy: candy, rule: jar.rule)
        print("Rule evaluation result: \(isCorrect)")
        
        if isCorrect {
            handleCorrectDrop(candy: candy, jar: jar, dropTime: dropTime)
        } else {
            handleIncorrectDrop(candy: candy, jar: jar)
        }
        
        candies.removeAll { $0.id == candy.id }
        lastDroppedCandy = candy
        lastDroppedJar = jar
        
        if candies.isEmpty && gameState == .playing {
            spawnCandies()
        }
    }
    
    private func handleCorrectDrop(candy: Candy, jar: Jar, dropTime: TimeInterval) {
        stats.correctDrops += 1
        stats.currentStreak += 1
        stats.maxStreak = max(stats.maxStreak, stats.currentStreak)
        
        var points = 100
        let multiplier = stats.streakMultiplier
        points = Int(Double(points) * multiplier)
        
        if dropTime < 1.5 {
            points = Int(Double(points) * 1.15)
        }
        
        stats.score += points
        
        if stats.correctDrops % 5 == 0 {
            stats.score += 250
            audioManager.playComboSound()
        } else {
            audioManager.playCorrectSound()
        }
        
        if let index = roundConfig.jars.firstIndex(where: { $0.id == jar.id }) {
            roundConfig.jars[index].correctDrops += 1
        }
        
        // Проверяем завершение игры для Zen режима
        checkZenModeCompletion()
        
        // Проверяем завершение игры при наполнении банок
        checkJarCompletion()
    }
    
    private func handleIncorrectDrop(candy: Candy, jar: Jar) {
        print("Incorrect drop: \(candy.color.rawValue) \(candy.shape.rawValue) into \(jar.label)")
        print("Current lives before: \(lives)")
        
        stats.incorrectDrops += 1
        stats.currentStreak = 0
        stats.score = max(0, stats.score - 100)
        
        if let currentLives = currentMode.initialLives {
            lives -= 1
            print("Lives after deduction: \(lives)")
            if lives <= 0 {
                print("Game over due to no lives left")
                endGame()
            }
        }
        
        audioManager.playIncorrectSound()
    }
    
    private func spawnCandies() {
        let count = Int.random(in: 2...4)
        for _ in 0..<count {
            let candy = Candy.random()
            candies.append(candy)
            print("Spawned candy: \(candy.color.rawValue) \(candy.shape.rawValue)")
        }
        print("Total candies: \(candies.count)")
    }
    
    private func startCandySpawning() {
        candySpawnTimer?.invalidate()
        candySpawnTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            guard let self = self, self.gameState == .playing else { return }
            if self.candies.count < 8 {
                self.candies.append(Candy.random())
            }
        }
    }
    
    // MARK: - Timer
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.timeRemaining -= 1
            
            if self.timeRemaining <= 0 {
                self.endGame()
            }
        }
    }
    
    private func stopTimers() {
        timer?.invalidate()
        timer = nil
        twistTimer?.invalidate()
        twistTimer = nil
        candySpawnTimer?.invalidate()
        candySpawnTimer = nil
    }
    
    // MARK: - Twist
    private func scheduleTwist(at seconds: Double) {
        twistTimer?.invalidate()
        twistTimer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { [weak self] _ in
            self?.applyTwist()
        }
    }
    
    private func applyTwist() {
        guard let twist = roundConfig.twist else { return }
        
        for patch in twist.patch {
            if let index = roundConfig.jars.firstIndex(where: { $0.id == patch.id }) {
                roundConfig.jars[index] = Jar(id: patch.id, label: roundConfig.jars[index].label, rule: patch.rule, correctDrops: roundConfig.jars[index].correctDrops)
            }
        }
        
        twistMessage = twist.description
        showTwist = true
        audioManager.playTwistSound()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.showTwist = false
        }
    }
    
    // MARK: - Explanation
    func requestExplanation() {
        guard let candy = lastDroppedCandy, let jar = lastDroppedJar else {
            explanationText = "Explanation requires a recent drop."
            showExplanation = true
            return
        }
        
        // Простое объяснение без GPT
        let rule = jar.rule == "ELSE" ? "Everything else" : jar.rule
        explanationText = "The candy was placed in '\(jar.label)' because it matches the rule: \(rule)"
        showExplanation = true
    }
    
    // MARK: - Mimi Note
    private func generateMimiNote() {
        // Простая заметка Мими без GPT
        if stats.accuracy >= 90 {
            mimiNote = "Excellent sorting! You're becoming a true candy master!"
        } else if stats.accuracy >= 70 {
            mimiNote = "Good work! Keep practicing to improve your accuracy."
        } else {
            mimiNote = "Don't worry, practice makes perfect! Take your time to read the rules carefully."
        }
    }
    
    // MARK: - Helpers
    private func resetStats() {
        stats = GameStats()
        mimiNote = ""
    }
    
    private func checkZenModeCompletion() {
        // Для Zen режима завершаем игру при достижении определенного количества правильных бросков
        if currentMode == .zen {
            let targetDrops = 20 // Цель: 20 правильных бросков для завершения раунда
            if stats.correctDrops >= targetDrops {
                print("Zen mode completed with \(stats.correctDrops) correct drops")
                audioManager.playComboSound() // Специальный звук завершения
                endGame()
            }
        }
    }
    
    private func checkJarCompletion() {
        // Проверяем, заполнены ли банки достаточно для завершения раунда
        let maxFillLevel = 0.8 // 80% заполнения для завершения
        let targetDropsPerJar = 8 // Цель: 8 правильных бросков в каждую банку
        
        var allJarsFilled = true
        var almostFilled = false
        
        for jar in roundConfig.jars {
            let fillLevel = Double(jar.correctDrops) / Double(targetDropsPerJar)
            if fillLevel < maxFillLevel {
                allJarsFilled = false
            }
            if fillLevel >= 0.6 && fillLevel < maxFillLevel {
                almostFilled = true
            }
        }
        
        // Уведомляем о том, что банки почти заполнены
        if almostFilled && !allJarsFilled {
            print("Jars almost filled! Keep going!")
            audioManager.playUISound() // Звук предупреждения
        }
        
        if allJarsFilled {
            print("All jars filled! Completing round...")
            audioManager.playComboSound() // Звук завершения
            endGame()
        }
    }
    
    private func generateNewRound() {
        // Генерируем новые правила для следующего раунда
        roundConfig = RoundConfig.fallback()
    }
}

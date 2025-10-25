//
//  Models.swift
//  N1021erwtywrewth
//
//  Created by Agent on 24.10.2025.
//

import Foundation
import SwiftUI

// MARK: - Game Mode
enum GameMode: String, Codable, CaseIterable {
    case classic = "Classic"
    case zen = "Zen"
    case challenge = "Challenge"
    
    var duration: TimeInterval? {
        switch self {
        case .classic: return 70
        case .zen: return nil
        case .challenge: return 45
        }
    }
    
    var initialLives: Int? {
        switch self {
        case .classic: return 3
        case .zen: return nil
        case .challenge: return 2
        }
    }
}

// MARK: - Candy Attributes
enum CandyColor: String, Codable, CaseIterable {
    case pink, mint, cream, yellow, blue, lavender
    
    var color: Color {
        switch self {
        case .pink: return Color(hex: "F8C8DC")
        case .mint: return Color(hex: "B9F5D0")
        case .cream: return Color(hex: "FFF1D6")
        case .yellow: return Color(hex: "FFE58F")
        case .blue: return Color(hex: "BEE3FF")
        case .lavender: return Color(hex: "E0D4FF")
        }
    }
}

enum CandyShape: String, Codable, CaseIterable {
    case circle, square, triangle, star, capsule
}

enum CandySize: String, Codable, CaseIterable {
    case S, M, L
    
    var scale: CGFloat {
        switch self {
        case .S: return 0.7
        case .M: return 1.0
        case .L: return 1.3
        }
    }
}

enum CandyPattern: String, Codable, CaseIterable {
    case solid, striped, spotted, layered
}

enum CandyFlavor: String, Codable, CaseIterable {
    case fruit, mint, chocolate, caramel
}

// MARK: - Candy Model
struct Candy: Identifiable, Codable {
    let id: UUID
    let color: CandyColor
    let shape: CandyShape
    let size: CandySize
    let pattern: CandyPattern
    let flavor: CandyFlavor
    let wrapped: Bool
    let layers: Int
    var spawnTime: Date
    
    init(id: UUID = UUID(), color: CandyColor, shape: CandyShape, size: CandySize, pattern: CandyPattern, flavor: CandyFlavor, wrapped: Bool, layers: Int, spawnTime: Date = Date()) {
        self.id = id
        self.color = color
        self.shape = shape
        self.size = size
        self.pattern = pattern
        self.flavor = flavor
        self.wrapped = wrapped
        self.layers = max(1, min(3, layers))
        self.spawnTime = spawnTime
    }
    
    static func random() -> Candy {
        Candy(
            color: CandyColor.allCases.randomElement()!,
            shape: CandyShape.allCases.randomElement()!,
            size: CandySize.allCases.randomElement()!,
            pattern: CandyPattern.allCases.randomElement()!,
            flavor: CandyFlavor.allCases.randomElement()!,
            wrapped: Bool.random(),
            layers: Int.random(in: 1...3)
        )
    }
}

// MARK: - Jar Model
struct Jar: Identifiable, Codable {
    let id: String
    let label: String
    let rule: String
    var correctDrops: Int = 0
    
    init(id: String, label: String, rule: String, correctDrops: Int = 0) {
        self.id = id
        self.label = label
        self.rule = rule
        self.correctDrops = correctDrops
    }
}

// MARK: - Round Config
struct RoundConfig: Codable {
    let theme: String
    let conciseSummary: String
    var jars: [Jar]
    let twist: RuleTwist?
    
    struct RuleTwist: Codable {
        let whenSeconds: Double?
        let description: String
        let patch: [JarPatch]
        
        struct JarPatch: Codable {
            let id: String
            let rule: String
        }
    }
    
    static func fallback() -> RoundConfig {
        let configs = [
            RoundConfig(
                theme: "Candy Factory",
                conciseSummary: "Sort by color: pink or mint in A, everything else in B.",
                jars: [
                    Jar(id: "A", label: "Color Crew", rule: "color = pink OR color = mint"),
                    Jar(id: "B", label: "Mix Jar", rule: "ELSE")
                ],
                twist: nil
            ),
            RoundConfig(
                theme: "Shape Workshop",
                conciseSummary: "Sort by shape: circles and stars in A, everything else in B.",
                jars: [
                    Jar(id: "A", label: "Round & Star", rule: "shape = circle OR shape = star"),
                    Jar(id: "B", label: "Other Shapes", rule: "ELSE")
                ],
                twist: nil
            ),
            RoundConfig(
                theme: "Size Station",
                conciseSummary: "Sort by size: large candies in A, everything else in B.",
                jars: [
                    Jar(id: "A", label: "Big Treats", rule: "size = L"),
                    Jar(id: "B", label: "Small & Medium", rule: "ELSE")
                ],
                twist: nil
            ),
            RoundConfig(
                theme: "Pattern Palace",
                conciseSummary: "Sort by pattern: striped and layered in A, everything else in B.",
                jars: [
                    Jar(id: "A", label: "Pattern Pros", rule: "pattern = striped OR pattern = layered"),
                    Jar(id: "B", label: "Simple Styles", rule: "ELSE")
                ],
                twist: nil
            ),
            RoundConfig(
                theme: "Flavor Factory",
                conciseSummary: "Sort by flavor: fruit and chocolate in A, everything else in B.",
                jars: [
                    Jar(id: "A", label: "Sweet Treats", rule: "flavor = fruit OR flavor = chocolate"),
                    Jar(id: "B", label: "Other Flavors", rule: "ELSE")
                ],
                twist: nil
            ),
            RoundConfig(
                theme: "Wrapper World",
                conciseSummary: "Sort by wrapper: wrapped candies in A, unwrapped in B.",
                jars: [
                    Jar(id: "A", label: "Wrapped Wonders", rule: "wrapped = true"),
                    Jar(id: "B", label: "Naked Treats", rule: "ELSE")
                ],
                twist: nil
            ),
            RoundConfig(
                theme: "Layer Lab",
                conciseSummary: "Sort by layers: multi-layer candies in A, single layer in B.",
                jars: [
                    Jar(id: "A", label: "Layered Luxe", rule: "layers ≥ 2"),
                    Jar(id: "B", label: "Simple Singles", rule: "ELSE")
                ],
                twist: nil
            ),
            RoundConfig(
                theme: "Complex Combo",
                conciseSummary: "Sort by color and size: pink large or mint medium in A, everything else in B.",
                jars: [
                    Jar(id: "A", label: "Special Combo", rule: "(color = pink AND size = L) OR (color = mint AND size = M)"),
                    Jar(id: "B", label: "Everything Else", rule: "ELSE")
                ],
                twist: nil
            )
        ]
        
        return configs.randomElement() ?? configs[0]
    }
}

// MARK: - Game Stats
struct GameStats {
    var score: Int = 0
    var correctDrops: Int = 0
    var incorrectDrops: Int = 0
    var currentStreak: Int = 0
    var maxStreak: Int = 0
    var totalDropTime: TimeInterval = 0
    var dropCount: Int = 0
    
    var accuracy: Double {
        let total = correctDrops + incorrectDrops
        return total > 0 ? Double(correctDrops) / Double(total) * 100 : 0
    }
    
    var avgDropTime: Double {
        return dropCount > 0 ? totalDropTime / Double(dropCount) : 0
    }
    
    var streakMultiplier: Double {
        return 1.0 + min(Double(currentStreak) * 0.1, 1.0)
    }
}

// MARK: - Records
struct GameRecords: Codable {
    var classicBest: Int = 0
    var zenBest: Int = 0
    var challengeBest: Int = 0
    var totalRounds: Int = 0
    var totalCorrectDrops: Int = 0
    var totalIncorrectDrops: Int = 0
    var longestStreak: Int = 0
    
    var avgAccuracy: Double {
        let total = totalCorrectDrops + totalIncorrectDrops
        return total > 0 ? Double(totalCorrectDrops) / Double(total) * 100 : 0
    }
    
    mutating func updateBest(mode: GameMode, score: Int) {
        switch mode {
        case .classic:
            classicBest = max(classicBest, score)
        case .zen:
            zenBest = max(zenBest, score)
        case .challenge:
            challengeBest = max(challengeBest, score)
        }
    }
}

// MARK: - Settings
struct GameSettings: Codable {
    var musicEnabled: Bool = true
    var sfxEnabled: Bool = true
    var hapticsEnabled: Bool = true
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

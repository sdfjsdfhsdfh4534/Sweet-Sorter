//
//  GameOverView.swift
//  N1021erwtywrewth
//
//  Created by Agent on 24.10.2025.
//

import SwiftUI

struct GameOverView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var showConfetti = false
    
    var isNewRecord: Bool {
        let records = viewModel.records
        switch viewModel.currentMode {
        case .classic:
            return viewModel.stats.score == records.classicBest && viewModel.stats.score > 0
        case .zen:
            return viewModel.stats.score == records.zenBest && viewModel.stats.score > 0
        case .challenge:
            return viewModel.stats.score == records.challengeBest && viewModel.stats.score > 0
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Title
                    VStack(spacing: 8) {
                        Text("Round Complete!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        if isNewRecord {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("New Record!")
                                    .font(.headline)
                                    .foregroundColor(.yellow)
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                            }
                            .scaleEffect(showConfetti ? 1.2 : 1.0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.5).repeatForever(autoreverses: true), value: showConfetti)
                        }
                    }
                    .padding(.top)
                    
                    // Stats card
                    VStack(spacing: 16) {
                        StatRow(label: "Score", value: "\(viewModel.stats.score)", highlight: true)
                        Divider()
                        StatRow(label: "Accuracy", value: String(format: "%.0f%%", viewModel.stats.accuracy))
                        StatRow(label: "Highest Streak", value: "\(viewModel.stats.maxStreak)")
                        StatRow(label: "Correct Drops", value: "\(viewModel.stats.correctDrops)")
                        StatRow(label: "Avg Time per Drop", value: String(format: "%.1fs", viewModel.stats.avgDropTime))
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                    )
                    .padding(.horizontal, 16)
                    
                    // Mimi's Note
                    if !viewModel.mimiNote.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "quote.opening")
                                    .font(.caption)
                                Text("Mimi's Note")
                                    .font(.headline)
                                Spacer()
                            }
                            
                            Text(viewModel.mimiNote)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "E0D4FF").opacity(0.3))
                        )
                        .padding(.horizontal, 16)
                    }
                    
                    // Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            AudioManager.shared.playUISound()
                            viewModel.restartGame()
                        }) {
                            Text("Play Again")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [Color(hex: "F8C8DC"), Color(hex: "B9F5D0")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                        }
                        
                        Button(action: {
                            AudioManager.shared.playUISound()
                            viewModel.startGame(mode: viewModel.currentMode)
                        }) {
                            Text("New Round")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [Color(hex: "B8D9FF"), Color(hex: "87CEEB")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                        }
                        
                        Button(action: {
                            AudioManager.shared.playUISound()
                            viewModel.quitToMenu()
                        }) {
                            Text("Back to Menu")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.ultraThinMaterial)
                                )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
        }
        .onAppear {
            showConfetti = isNewRecord
        }
    }
}

struct StatRow: View {
    let label: String
    let value: String
    var highlight: Bool = false
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(highlight ? .title2 : .body)
                .fontWeight(highlight ? .bold : .semibold)
        }
    }
}

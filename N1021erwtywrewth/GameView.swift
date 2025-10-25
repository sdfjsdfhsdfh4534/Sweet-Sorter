//
//  GameView.swift
//  N1021erwtywrewth
//
//  Created by Agent on 24.10.2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var draggedCandy: Candy?
    @State private var dragOffset: CGSize = .zero
    @State private var highlightedJarId: String?
    @State private var selectedCandy: Candy?
    @State private var showJarPicker = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(hex: "E6F3FF"),
                    Color(hex: "D1E7FF"),
                    Color(hex: "B8D9FF")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 12) {
                // HUD
                HUDView(viewModel: viewModel)
                
                // Theme banner
                VStack(spacing: 4) {
                    Text(viewModel.roundConfig.theme)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("New Rules!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .opacity(0.8)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                )
                
                Text(viewModel.roundConfig.conciseSummary)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                
                // Progress bar for Zen mode
                if viewModel.currentMode == .zen {
                    VStack(spacing: 8) {
                        HStack {
                            Text("Progress to completion:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(viewModel.stats.correctDrops)/20")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 16)
                        
                        ProgressView(value: Double(viewModel.stats.correctDrops), total: 20)
                            .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "B8D9FF")))
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                            .padding(.horizontal, 16)
                    }
                }
                
                // Jars
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(viewModel.roundConfig.jars) { jar in
                            JarView(
                                jar: jar,
                                isHighlighted: highlightedJarId == jar.id,
                                fillLevel: Double(jar.correctDrops) / 8.0
                            )
                            .frame(width: 140)
                            .onDrop(of: [UTType.data], delegate: JarDropDelegate(jar: jar, viewModel: viewModel, draggedCandy: $draggedCandy, highlightedJarId: $highlightedJarId))
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .frame(height: 150)
                
                // Jar fill progress indicator
                VStack(spacing: 8) {
                    Text("Fill Progress")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        ForEach(viewModel.roundConfig.jars) { jar in
                            VStack(spacing: 4) {
                                Text(jar.label)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                ProgressView(value: Double(jar.correctDrops), total: 8)
                                    .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "B8D9FF")))
                                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
                                
                                Text("\(jar.correctDrops)/8")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                Spacer(minLength: 8)
                
                // Candies counter
                VStack(spacing: 4) {
                    Text("Sweets")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Tap to choose jar • Use Auto Sort for help")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .opacity(0.7)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(viewModel.candies) { candy in
                            CandyView(candy: candy, isBeingDragged: draggedCandy?.id == candy.id)
                                .onTapGesture {
                                    AudioManager.shared.playLightHaptic()
                                    // Показываем выбор банки для конфеты
                                    showJarSelection(for: candy)
                                }
                                .onDrag {
                                    self.draggedCandy = candy
                                    let data = try? JSONEncoder().encode(candy)
                                    return NSItemProvider(item: data as (any NSSecureCoding)?, typeIdentifier: UTType.data.identifier)
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .frame(height: 70)
                .padding(.bottom, 8)
                
                // Controls
                HStack(spacing: 20) {
                    if viewModel.lastDroppedCandy != nil {
                        Button(action: {
                            AudioManager.shared.playUISound()
                            viewModel.requestExplanation()
                        }) {
                            Label("Explain", systemImage: "questionmark.circle")
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(.ultraThinMaterial))
                        }
                    }
                    
                    Button(action: {
                        AudioManager.shared.playUISound()
                        // Автоматически сортируем все конфеты
                        for candy in viewModel.candies {
                            if let correctJar = RuleEngine.findMatchingJar(candy: candy, jars: viewModel.roundConfig.jars) {
                                viewModel.dropCandy(candy, into: correctJar)
                            }
                        }
                    }) {
                        Label("Auto Sort", systemImage: "wand.and.stars")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(.ultraThinMaterial))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
            
            // Twist overlay
            if viewModel.showTwist {
                VStack {
                    Text("Rule Twist!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(viewModel.twistMessage)
                        .font(.body)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.purple.opacity(0.9))
                        .shadow(radius: 20)
                )
                .padding()
                .transition(.scale.combined(with: .opacity))
            }
            
            // Pause overlay
            if viewModel.gameState == .paused {
                PauseView(viewModel: viewModel)
            }
            
            // Game over overlay
            if viewModel.gameState == .gameOver {
                GameOverView(viewModel: viewModel)
            }
        }
        .sheet(isPresented: $viewModel.showExplanation) {
            ExplanationSheet(text: viewModel.explanationText)
        }
        .sheet(isPresented: $showJarPicker) {
            if let candy = selectedCandy {
                JarSelectionView(candy: candy, jars: viewModel.roundConfig.jars) { selectedJar in
                    viewModel.dropCandy(candy, into: selectedJar)
                    showJarPicker = false
                    selectedCandy = nil
                }
            }
        }
    }
    
    private func showJarSelection(for candy: Candy) {
        selectedCandy = candy
        showJarPicker = true
    }
}

struct HUDView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        HStack {
            // Score
            VStack(alignment: .leading, spacing: 4) {
                Text("Score")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(viewModel.stats.score)")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            // Timer (if applicable) or Progress (for Zen mode)
            if let duration = viewModel.currentMode.duration {
                VStack(spacing: 4) {
                    Text("Time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(timeString(viewModel.timeRemaining))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(viewModel.timeRemaining < 10 ? .red : .primary)
                }
            } else if viewModel.currentMode == .zen {
                VStack(spacing: 4) {
                    Text("Progress")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(viewModel.stats.correctDrops)/20")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
            }
            
            Spacer()
            
            // Lives (if applicable)
            if viewModel.currentMode.initialLives != nil {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Lives")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack(spacing: 4) {
                        ForEach(0..<viewModel.lives, id: \.self) { _ in
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            
            // Pause button
            Button(action: {
                AudioManager.shared.playUISound()
                viewModel.pauseGame()
            }) {
                Image(systemName: "pause.circle.fill")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .padding(.horizontal, 16)
    }
    
    private func timeString(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct JarDropDelegate: DropDelegate {
    let jar: Jar
    let viewModel: GameViewModel
    @Binding var draggedCandy: Candy?
    @Binding var highlightedJarId: String?
    
    func dropEntered(info: DropInfo) {
        highlightedJarId = jar.id
    }
    
    func dropExited(info: DropInfo) {
        if highlightedJarId == jar.id {
            highlightedJarId = nil
        }
    }
    
    func performDrop(info: DropInfo) -> Bool {
        guard let candy = draggedCandy else { return false }
        
        // Проверяем, что игра активна
        guard viewModel.gameState == .playing else { return false }
        
        viewModel.dropCandy(candy, into: jar)
        draggedCandy = nil
        highlightedJarId = nil
        
        return true
    }
}

struct ExplanationSheet: View {
    let text: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(text)
                    .font(.body)
                    .padding()
            }
            .navigationTitle("Explanation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct JarSelectionView: View {
    let candy: Candy
    let jars: [Jar]
    let onJarSelected: (Jar) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Choose a jar for this candy:")
                    .font(.headline)
                    .padding()
                
                CandyView(candy: candy)
                    .frame(width: 80, height: 80)
                
                VStack(spacing: 16) {
                    ForEach(jars) { jar in
                        Button(action: {
                            onJarSelected(jar)
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(jar.label)
                                        .font(.headline)
                                    Text(jar.rule == "ELSE" ? "Everything else" : jar.rule)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.ultraThinMaterial)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Select Jar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

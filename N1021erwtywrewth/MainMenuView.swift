//
//  MainMenuView.swift
//  N1021erwtywrewth
//
//  Created by Agent on 24.10.2025.
//

import SwiftUI

struct MainMenuView: View {
    @StateObject private var viewModel = GameViewModel()
    @StateObject private var recordsVM = RecordsViewModel()
    @State private var showRules = false
    @State private var showRecords = false
    @State private var showSettings = false
    
    var body: some View {
        ZStack {
            // Background gradient
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
            
            // Floating candies animation
            FloatingCandiesBackground()
            
            VStack(spacing: 20) {
                Spacer(minLength: 20)
                
                // Title
                VStack(spacing: 8) {
                    Text("Sweet Sorter")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "FF6B9D"), Color(hex: "4ECDC4")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 3)
                        .shadow(color: .white.opacity(0.8), radius: 1, x: 0, y: 1)
                    
                    Text("Match, sort, and savor the calm.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer(minLength: 20)
                
                // Mode buttons
                VStack(spacing: 16) {
                    MenuButton(title: "Classic Mode", subtitle: "70s • 3 Lives", icon: "timer") {
                        viewModel.startGame(mode: .classic)
                    }
                    
                    MenuButton(title: "Zen Mode", subtitle: "20 correct drops • No pressure", icon: "leaf.fill") {
                        viewModel.startGame(mode: .zen)
                    }
                    
                    MenuButton(title: "Challenge Mode", subtitle: "45s • Rule Twists", icon: "bolt.fill") {
                        viewModel.startGame(mode: .challenge)
                    }
                }
                .padding(.horizontal, 16)
                
                // Secondary buttons
                HStack(spacing: 12) {
                    SecondaryButton(title: "Records", icon: "trophy.fill") {
                        showRecords = true
                    }
                    
                    SecondaryButton(title: "Rules", icon: "book.fill") {
                        showRules = true
                    }
                    
                    SecondaryButton(title: "Settings", icon: "gearshape.fill") {
                        showSettings = true
                    }
                }
                .padding(.horizontal, 16)
                
                // Best score chip
                if recordsVM.records.classicBest > 0 {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Best: \(recordsVM.records.classicBest)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                    )
                }
                
                Spacer(minLength: 20)
            }
        }
        .fullScreenCover(isPresented: Binding(
            get: { viewModel.gameState == .playing || viewModel.gameState == .paused || viewModel.gameState == .gameOver },
            set: { if !$0 { viewModel.quitToMenu() } }
        )) {
            GameView(viewModel: viewModel)
        }
        .sheet(isPresented: $showRules) {
            RulesView()
        }
        .sheet(isPresented: $showRecords) {
            RecordsView(viewModel: recordsVM)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

struct MenuButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            AudioManager.shared.playUISound()
            action()
        }) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct SecondaryButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            AudioManager.shared.playUISound()
            action()
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct FloatingCandiesBackground: View {
    @State private var positions: [CGPoint] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<8, id: \.self) { index in
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [candyColors[index % candyColors.count].opacity(0.3), candyColors[index % candyColors.count].opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: CGFloat.random(in: 40...80), height: CGFloat.random(in: 40...80))
                        .position(positions.indices.contains(index) ? positions[index] : CGPoint(x: 0, y: 0))
                        .blur(radius: 20)
                }
            }
            .onAppear {
                positions = (0..<8).map { _ in
                    CGPoint(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: CGFloat.random(in: 0...geometry.size.height)
                    )
                }
                animatePositions(in: geometry.size)
            }
        }
    }
    
    private func animatePositions(in size: CGSize) {
        withAnimation(.easeInOut(duration: 20).repeatForever(autoreverses: true)) {
            positions = (0..<8).map { _ in
                CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height)
                )
            }
        }
    }
    
    private let candyColors: [Color] = [
        Color(hex: "FFB6C1"),
        Color(hex: "98FB98"),
        Color(hex: "FFD700"),
        Color(hex: "87CEEB"),
        Color(hex: "DDA0DD")
    ]
}

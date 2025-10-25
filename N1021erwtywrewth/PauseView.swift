//
//  PauseView.swift
//  N1021erwtywrewth
//
//  Created by Agent on 24.10.2025.
//

import SwiftUI

struct PauseView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Paused")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(spacing: 12) {
                    PauseButton(title: "Resume", icon: "play.fill") {
                        viewModel.resumeGame()
                    }
                    
                    PauseButton(title: "Restart Round", icon: "arrow.clockwise") {
                        viewModel.restartGame()
                    }
                    
                    PauseButton(title: "Quit to Menu", icon: "house.fill") {
                        viewModel.quitToMenu()
                    }
                }
                .padding()
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(.ultraThinMaterial)
            )
            .shadow(radius: 20)
            .padding()
        }
    }
}

struct PauseButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            AudioManager.shared.playUISound()
            action()
        }) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 30)
                Text(title)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.2))
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

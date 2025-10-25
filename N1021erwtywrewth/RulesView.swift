//
//  RulesView.swift
//  N1021erwtywrewth
//
//  Created by Agent on 24.10.2025.
//

import SwiftUI

struct RulesView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentPage = 0
    
    let pages: [(title: String, content: String)] = [
        ("Goal", "Drag sweets into the correct jars based on the current rules. Each round has different sorting criteria!"),
        ("Attributes", "Sweets have 7 attributes:\n• Color (pink, mint, cream, yellow, blue, lavender)\n• Shape (circle, square, triangle, star, capsule)\n• Size (S, M, L)\n• Pattern (solid, striped, spotted, layered)\n• Flavor (fruit, mint, chocolate, caramel)\n• Wrapped (yes/no)\n• Layers (1-3)"),
        ("Scoring", "• Correct drop: +100 points\n• Streak bonus: +10% per consecutive correct drop\n• Speed bonus: +15% if dropped within 1.5s\n• Combo: Every 5 correct drops = +250 bonus\n• Mistake: -100 points and streak reset"),
        ("Modes & Rules", "Classic: 70s timer, 3 lives\nZen: 20 correct drops, no pressure\nChallenge: 45s, 2 lives, with Rule Twists\n\nRules change each round and may include complex logic. Watch for mid-round twists in Challenge mode!")
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        VStack(spacing: 20) {
                            Image(systemName: iconForPage(index))
                                .font(.system(size: 60))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: "F8C8DC"), Color(hex: "B9F5D0")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .padding(.top, 40)
                            
                            Text(pages[index].title)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text(pages[index].content)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 30)
                            
                            Spacer()
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                
                Button(action: {
                    AudioManager.shared.playUISound()
                    dismiss()
                }) {
                    Text("Got it!")
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
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(hex: "E6F3FF"),
                        Color(hex: "B8D9FF")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private func iconForPage(_ index: Int) -> String {
        switch index {
        case 0: return "target"
        case 1: return "square.grid.3x3.fill"
        case 2: return "star.fill"
        case 3: return "gamecontroller.fill"
        default: return "questionmark"
        }
    }
}

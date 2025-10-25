//
//  RecordsView.swift
//  N1021erwtywrewth
//
//  Created by Agent on 24.10.2025.
//

import SwiftUI

struct RecordsView: View {
    @ObservedObject var viewModel: RecordsViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showResetConfirm = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: "E6F3FF"),
                        Color(hex: "B8D9FF")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Trophy
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.yellow, Color.orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .yellow.opacity(0.5), radius: 20)
                            .padding(.top)
                        
                        // Best scores
                        VStack(spacing: 16) {
                            Text("Best Scores")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            RecordCard(mode: "Classic", score: viewModel.records.classicBest, icon: "timer")
                            RecordCard(mode: "Zen", score: viewModel.records.zenBest, icon: "leaf.fill")
                            RecordCard(mode: "Challenge", score: viewModel.records.challengeBest, icon: "bolt.fill")
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                        )
                        .padding(.horizontal)
                        
                        // Aggregate stats
                        VStack(spacing: 16) {
                            Text("Overall Stats")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            HStack(spacing: 20) {
                                StatCard(title: "Rounds", value: "\(viewModel.records.totalRounds)", icon: "gamecontroller.fill")
                                StatCard(title: "Accuracy", value: String(format: "%.0f%%", viewModel.records.avgAccuracy), icon: "target")
                            }
                            
                            HStack(spacing: 20) {
                                StatCard(title: "Longest Streak", value: "\(viewModel.records.longestStreak)", icon: "flame.fill")
                                StatCard(title: "Total Drops", value: "\(viewModel.records.totalCorrectDrops)", icon: "checkmark.circle.fill")
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                        )
                        .padding(.horizontal)
                        
                        // Reset button
                        Button(action: {
                            showResetConfirm = true
                        }) {
                            Text("Reset All Stats")
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .stroke(Color.red, lineWidth: 1)
                                )
                        }
                        .padding(.bottom)
                    }
                }
            }
            .navigationTitle("Records")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Reset All Stats?", isPresented: $showResetConfirm) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    viewModel.resetRecords()
                }
            } message: {
                Text("This will permanently delete all your records and statistics.")
            }
        }
    }
}

struct RecordCard: View {
    let mode: String
    let score: Int
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 40)
            
            Text(mode)
                .font(.headline)
            
            Spacer()
            
            Text("\(score)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(score > 0 ? .primary : .secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.3))
        )
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "F8C8DC"), Color(hex: "B9F5D0")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.3))
        )
    }
}

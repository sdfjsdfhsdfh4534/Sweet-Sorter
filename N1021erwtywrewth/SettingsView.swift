//
//  SettingsView.swift
//  N1021erwtywrewth
//
//  Created by Agent on 24.10.2025.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) var dismiss
    
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
                
                Form {
                    Section(header: Text("Audio")) {
                        Toggle("Music", isOn: $viewModel.settings.musicEnabled)
                        Toggle("Sound Effects", isOn: $viewModel.settings.sfxEnabled)
                        Toggle("Haptics", isOn: $viewModel.settings.hapticsEnabled)
                    }
                    
                    Section(header: Text("About")) {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Game Mode")
                            Spacer()
                            Text("Sweet Sorter")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
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

//
//  JarView.swift
//  N1021erwtywrewth
//
//  Created by Agent on 24.10.2025.
//

import SwiftUI

struct JarView: View {
    let jar: Jar
    var isHighlighted: Bool = false
    var fillLevel: Double = 0.0
    
    var body: some View {
        VStack(spacing: 8) {
            // Jar label
            Text(jar.label)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            // Jar container
            ZStack(alignment: .bottom) {
                // Glass jar
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isHighlighted ? Color.blue : Color.white.opacity(0.3), lineWidth: isHighlighted ? 3 : 1)
                    )
                    .frame(height: 120)
                
                // Fill level
                if fillLevel > 0 {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "F8C8DC").opacity(0.4),
                                    Color(hex: "B9F5D0").opacity(0.4)
                                ],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(height: 120 * min(fillLevel, 1.0))
                        .animation(.easeInOut(duration: 0.3), value: fillLevel)
                        .overlay(
                            // Специальный эффект при полном заполнении
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    fillLevel >= 0.8 ? Color.green.opacity(0.6) : Color.clear,
                                    lineWidth: 2
                                )
                                .animation(.easeInOut(duration: 0.5), value: fillLevel)
                        )
                }
                
                // Rule chip
                VStack {
                    Spacer()
                    Text(jar.rule == "ELSE" ? "Everything else" : jar.rule)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.6))
                        )
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                        .padding(.bottom, 8)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white.opacity(0.1))
        )
        .shadow(color: isHighlighted ? Color.blue.opacity(0.3) : Color.black.opacity(0.1), radius: isHighlighted ? 15 : 8)
        .scaleEffect(isHighlighted ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHighlighted)
    }
}

//
//  CandyView.swift
//  N1021erwtywrewth
//
//  Created by Agent on 24.10.2025.
//

import SwiftUI

struct CandyView: View {
    let candy: Candy
    var isBeingDragged: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base shape with pattern
                AnyShape(shapeForCandy())
                    .fill(patternFill)
                
                // Wrapper if needed
                if candy.wrapped {
                    AnyShape(shapeForCandy())
                        .stroke(Color.white.opacity(0.8), lineWidth: 3)
                    
                    Circle()
                        .fill(Color.white.opacity(0.6))
                        .frame(width: 8, height: 8)
                        .position(x: geometry.size.width / 2, y: 5)
                }
                
                // Glassmorphic overlay
                AnyShape(shapeForCandy())
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.3), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
        .frame(width: 60 * candy.size.scale, height: 60 * candy.size.scale)
        .shadow(color: candy.color.color.opacity(0.6), radius: isBeingDragged ? 15 : 8, x: 0, y: isBeingDragged ? 8 : 4)
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        .scaleEffect(isBeingDragged ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isBeingDragged)
        .overlay(
            // Индикатор того, что конфету можно нажать
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.8), lineWidth: 2)
                .scaleEffect(1.1)
        )
        .accessibilityLabel("\(candy.size.rawValue) \(candy.color.rawValue) \(candy.shape.rawValue) candy, \(candy.pattern.rawValue) pattern, \(candy.flavor.rawValue) flavor, \(candy.wrapped ? "wrapped" : "unwrapped"), \(candy.layers) layers")
    }
    
    private func shapeForCandy() -> some Shape {
        switch candy.shape {
        case .circle:
            return AnyShape(Circle())
        case .square:
            return AnyShape(RoundedRectangle(cornerRadius: 12))
        case .triangle:
            return AnyShape(TriangleShape())
        case .star:
            return AnyShape(StarShape())
        case .capsule:
            return AnyShape(Capsule())
        }
    }
    
    private var patternFill: some ShapeStyle {
        switch candy.pattern {
        case .solid:
            return AnyShapeStyle(candy.color.color)
        case .striped:
            return AnyShapeStyle(
                LinearGradient(
                    stops: [
                        .init(color: candy.color.color, location: 0),
                        .init(color: candy.color.color, location: 0.4),
                        .init(color: candy.color.color.opacity(0.5), location: 0.4),
                        .init(color: candy.color.color.opacity(0.5), location: 0.6),
                        .init(color: candy.color.color, location: 0.6),
                        .init(color: candy.color.color, location: 1.0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .spotted:
            return AnyShapeStyle(candy.color.color)
        case .layered:
            return AnyShapeStyle(layeredGradient)
        }
    }
    
    private var layeredGradient: LinearGradient {
        let layerCount = candy.layers
        var stops: [Gradient.Stop] = []
        
        for i in 0..<layerCount {
            let location = Double(i) / Double(layerCount)
            let nextLocation = Double(i + 1) / Double(layerCount)
            let opacity = 1.0 - (Double(i) * 0.2)
            
            stops.append(.init(color: candy.color.color.opacity(opacity), location: location))
            stops.append(.init(color: candy.color.color.opacity(opacity), location: nextLocation))
        }
        
        return LinearGradient(stops: stops, startPoint: .top, endPoint: .bottom)
    }
}

// MARK: - Custom Shapes
struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.4
        let points = 5
        
        for i in 0..<points * 2 {
            let angle = Double(i) * .pi / Double(points) - .pi / 2
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let x = center.x + CGFloat(cos(angle)) * radius
            let y = center.y + CGFloat(sin(angle)) * radius
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        path.closeSubpath()
        return path
    }
}

// MARK: - AnyShape
struct AnyShape: Shape {
    private let _path: (CGRect) -> Path
    
    init<S: Shape>(_ shape: S) {
        _path = { rect in
            shape.path(in: rect)
        }
    }
    
    func path(in rect: CGRect) -> Path {
        _path(rect)
    }
}

// MARK: - Glassmorphic Card
struct GlassmorphicCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.2))
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

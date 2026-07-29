// CircularGauge.swift
// Battery Insight Pro

import SwiftUI

struct CircularGauge: View {
    var value: Double          // 0.0 – 1.0
    var lineWidth: CGFloat = 12
    var gradient: [Color] = [Color.bip.green, Color.bip.accent]
    var trackColor: Color = Color.white.opacity(0.1)
    var label: String = ""
    var valueText: String = ""
    var size: CGFloat = 160
    var animated: Bool = true

    @State private var progress: Double = 0

    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(trackColor, lineWidth: lineWidth)
                .frame(width: size, height: size)

            // Progress arc
            Circle()
                .trim(from: 0, to: animated ? progress : value)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: gradient),
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 1.2, dampingFraction: 0.8), value: progress)

            // Center content
            VStack(spacing: 2) {
                Text(valueText)
                    .font(BIPFont.title(weight: .bold))
                    .foregroundStyle(.primary)
                if !label.isEmpty {
                    Text(label)
                        .font(BIPFont.caption())
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 1.2, dampingFraction: 0.8)) {
                progress = value
            }
        }
        .onChange(of: value) { newVal in
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                progress = newVal
            }
        }
    }
}

struct ScoreRing: View {
    var score: Int  // 0–100
    var title: String
    var size: CGFloat = 140
    var lineWidth: CGFloat = 10

    private var gradient: [Color] {
        switch score {
        case 80...: return [Color.bip.green, Color.bip.mint]
        case 60..<80: return [Color.bip.yellow, Color.bip.orange]
        default: return [Color.bip.red, Color.bip.orange]
        }
    }

    var body: some View {
        CircularGauge(
            value: Double(score) / 100.0,
            lineWidth: lineWidth,
            gradient: gradient,
            label: title,
            valueText: "\(score)",
            size: size
        )
    }
}

struct MiniGauge: View {
    var value: Double // 0–1
    var color: Color
    var size: CGFloat = 60
    var lineWidth: CGFloat = 6
    var text: String

    @State private var progress: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.15), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 1.0, dampingFraction: 0.8), value: progress)
            Text(text)
                .font(BIPFont.caption(weight: .bold))
                .foregroundStyle(color)
        }
        .frame(width: size, height: size)
        .onAppear { withAnimation { progress = value } }
        .onChange(of: value) { v in withAnimation { progress = v } }
    }
}

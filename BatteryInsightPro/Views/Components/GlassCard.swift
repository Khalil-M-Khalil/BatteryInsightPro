// GlassCard.swift
// Battery Insight Pro — Glassmorphism card container

import SwiftUI

struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat = BIPRadius.lg
    var padding: CGFloat = BIPSpacing.md
    var opacity: Double = 0.12
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.25), Color.white.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: .black.opacity(0.35), radius: 16, x: 0, y: 8)
    }
}

// Compact accent-colored card
struct AccentCard<Content: View>: View {
    var gradient: [Color]
    var cornerRadius: CGFloat = BIPRadius.md
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(BIPSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .opacity(0.20)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(gradient.first?.opacity(0.4) ?? Color.clear, lineWidth: 1)
                    )
            )
            .shadow(color: (gradient.first ?? .clear).opacity(0.25), radius: 10, x: 0, y: 5)
    }
}

// StatusBadge.swift
// Battery Insight Pro

import SwiftUI

struct AvailabilityBadge: View {
    var availability: MetricAvailability

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: availability.icon)
                .font(.system(size: 8, weight: .bold))
            Text(availability.label)
                .font(.system(size: 9, weight: .bold, design: .rounded))
        }
        .foregroundStyle(availability.color)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(availability.color.opacity(0.15))
                .overlay(Capsule().stroke(availability.color.opacity(0.3), lineWidth: 0.5))
        )
    }
}

struct StatusPill: View {
    var text: String
    var color: Color
    var icon: String

    var body: some View {
        Label(text, systemImage: icon)
            .font(BIPFont.caption(weight: .semibold))
            .foregroundStyle(color)
            .padding(.horizontal, BIPSpacing.sm)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(color.opacity(0.15))
                    .overlay(Capsule().stroke(color.opacity(0.35), lineWidth: 0.5))
            )
    }
}

struct MetricRow: View {
    var icon: String
    var title: String
    var value: String
    var availability: MetricAvailability
    var iconColor: Color = Color.bip.accent
    var detail: String?
    var onTap: (() -> Void)?

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: BIPSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(iconColor)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(BIPFont.body(weight: .medium))
                        .foregroundStyle(.primary)
                    if availability == .unavailable, let reason = detail {
                        if isExpanded {
                            Text(reason)
                                .font(BIPFont.caption())
                                .foregroundStyle(.secondary)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                }

                Spacer()

                HStack(spacing: 6) {
                    AvailabilityBadge(availability: availability)
                    Text(value)
                        .font(BIPFont.body(weight: .semibold))
                        .foregroundStyle(availability == .unavailable ? .secondary : .primary)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if availability == .unavailable && detail != nil {
                withAnimation(.spring(response: 0.4)) {
                    isExpanded.toggle()
                }
            }
            onTap?()
        }
    }
}

struct SectionHeader: View {
    var title: String
    var icon: String
    var iconColor: Color = Color.bip.accent
    var action: (() -> Void)? = nil
    var actionLabel: String = "See All"

    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .font(BIPFont.headline())
                .foregroundStyle(.primary)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(iconColor, .primary)
            Spacer()
            if let action {
                Button(actionLabel, action: action)
                    .font(BIPFont.caption(weight: .semibold))
                    .foregroundStyle(Color.bip.accent)
            }
        }
    }
}

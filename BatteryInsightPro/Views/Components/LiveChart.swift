// LiveChart.swift
// Battery Insight Pro — Swift Charts wrappers for iOS 16

import SwiftUI
import Charts

struct ChartPoint: Identifiable {
    let id = UUID()
    var index: Int
    var value: Double
}

struct LiveLineChart: View {
    var data: [Double]
    var color: Color
    var title: String
    var unit: String
    var minY: Double = 0
    var maxY: Double = 100

    private var points: [ChartPoint] {
        data.enumerated().map { ChartPoint(index: $0.offset, value: $0.element) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(BIPFont.caption(weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                if let last = data.last {
                    Text("\(Int(last))\(unit)")
                        .font(BIPFont.mono())
                        .foregroundStyle(color)
                }
            }

            Chart(points) { pt in
                AreaMark(
                    x: .value("Time", pt.index),
                    y: .value(title, pt.value)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [color.opacity(0.4), color.opacity(0.0)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                LineMark(
                    x: .value("Time", pt.index),
                    y: .value(title, pt.value)
                )
                .foregroundStyle(color)
                .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            }
            .chartYScale(domain: minY...max(maxY, data.max() ?? maxY))
            .chartXAxis(.hidden)
            .chartYAxis {
                AxisMarks(values: .automatic(desiredCount: 3)) { val in
                    AxisGridLine(stroke: StrokeStyle(dash: [3, 3]))
                        .foregroundStyle(Color.white.opacity(0.1))
                    AxisValueLabel()
                        .font(BIPFont.caption())
                        .foregroundStyle(Color.secondary)
                }
            }
            .frame(height: 80)
            .animation(.easeInOut(duration: 0.3), value: data.count)
        }
    }
}

struct DonutChart: View {
    struct Slice: Identifiable {
        let id = UUID()
        var label: String
        var value: Double
        var color: Color
    }

    var slices: [Slice]
    var size: CGFloat = 160

    var body: some View {
        Chart(slices) { slice in
            if #available(iOS 17.0, *) {
                SectorMark(
                    angle: .value(slice.label, slice.value),
                    innerRadius: .ratio(0.60),
                    angularInset: 2
                )
                .foregroundStyle(slice.color)
                .cornerRadius(4)
            } else {
                // Fallback for iOS 16: render a simple bar representation instead of a sector/donut
                BarMark(
                    x: .value("Period", slice.label),
                    y: .value("Value", slice.value)
                )
                .foregroundStyle(slice.color)
                .cornerRadius(4)
            }
        }
        .frame(width: size, height: size)
    }
}

struct BarHistoryChart: View {
    var data: [(label: String, value: Double)]
    var color: Color
    var maxY: Double = 100
    var unit: String = "%"

    var body: some View {
        Chart {
            ForEach(Array(data.enumerated()), id: \.offset) { i, item in
                BarMark(
                    x: .value("Period", item.label),
                    y: .value("Value", item.value)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [color, color.opacity(0.5)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .cornerRadius(4)
            }
        }
        .chartYScale(domain: 0...maxY)
        .chartYAxis {
            AxisMarks(values: .automatic(desiredCount: 4)) { val in
                AxisGridLine(stroke: StrokeStyle(dash: [3]))
                    .foregroundStyle(Color.white.opacity(0.1))
                AxisValueLabel()
                    .font(BIPFont.caption())
                    .foregroundStyle(Color.secondary)
            }
        }
    }
}

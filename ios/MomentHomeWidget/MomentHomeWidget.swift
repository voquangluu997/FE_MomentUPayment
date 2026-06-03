import WidgetKit
import SwiftUI

// 🔥 Extension background an toàn
extension View {
    @ViewBuilder
    func applyWidgetBackground(_ color: Color) -> some View {
        if #available(iOS 17.0, *) {
            self.containerBackground(for: .widget) {
                color
            }
        } else {
            self.background(color)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let budget: Double
    let spent: Double
    let remaining: Double
    let daysRemaining: Int
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), budget: 10000000, spent: 4500000, remaining: 5500000, daysRemaining: 15)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let userDefaults = UserDefaults(suiteName: "group.moment_u_payment")
        
        let budget = userDefaults?.double(forKey: "budget_total") ?? 0.0
        let spent = userDefaults?.double(forKey: "amount_spent") ?? 0.0
        let remaining = userDefaults?.double(forKey: "amount_remaining") ?? 0.0
        let days = userDefaults?.integer(forKey: "days_remaining") ?? 0
        
        let entry = SimpleEntry(date: Date(), budget: budget, spent: spent, remaining: remaining, daysRemaining: days)
        
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct MomentHomeWidgetEntryView: View {
    var entry: Provider.Entry

    func formatCompactAmount(_ value: Double) -> String {
        let num = abs(value)
        let sign = value < 0 ? "-" : ""
        if num >= 1_000_000_000 {
            return "\(sign)\(String(format: "%.1f", num / 1_000_000_000))B"
        } else if num >= 1_000_000 {
            return "\(sign)\(String(format: "%.1f", num / 1_000_000))M"
        } else if num >= 1_000 {
            return "\(sign)\(String(format: "%.1f", num / 1_000))k"
        }
        return "\(sign)\(Int(num))"
    }

    // 🔒 GIAO DIỆN MÀN HÌNH KHÓA (DUY NHẤT)
    var body: some View {
        let safeBudget = entry.budget == 0 ? 1 : entry.budget
        // Giữ an toàn để ProgressView không bao giờ crash
        let clampedSpent = min(max(0, entry.spent), safeBudget)
        let isOvertarget = entry.spent > entry.budget
        
        VStack(alignment: .leading, spacing: 2) {
            Text("Remaining: \(formatCompactAmount(entry.remaining)) • \(entry.daysRemaining)d lefts")
                .font(.system(size: 11, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
            ProgressView(value: clampedSpent, total: safeBudget)
                .tint(isOvertarget ? .red : .white)
                .frame(height: 5)
            
            Text("Spent: \(formatCompactAmount(entry.spent)) / Budget: \(formatCompactAmount(entry.budget))")
                .font(.system(size: 10, weight: .medium))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .opacity(0.8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .applyWidgetBackground(Color.clear)
        .environment(\.colorScheme, .dark)
    }
}

struct MomentHomeWidget: Widget {
    let kind: String = "MomentHomeWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MomentHomeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Moment Tracker")
        .description("Track your budget on Lock Screen.")
        .supportedFamilies([.accessoryRectangular])
    }
}
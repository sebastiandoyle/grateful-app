import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GratitudeEntry.date, order: .reverse) private var entries: [GratitudeEntry]
    @State private var showingAddEntry = false
    @State private var showingWeeklyRecap = false
    @State private var showingSettings = false

    private var streak: Int {
        calculateStreak()
    }

    private var todayEntries: [GratitudeEntry] {
        entries.filter { Calendar.current.isDateInToday($0.date) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header with streak
                        headerView

                        // Today's gratitudes
                        if !todayEntries.isEmpty {
                            todaySection
                        }

                        // Add button (prominent when no entries today)
                        addButtonSection

                        // Past entries
                        if entries.count > todayEntries.count {
                            pastEntriesSection
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingWeeklyRecap = true
                    } label: {
                        Image(systemName: "calendar")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddEntry) {
            EntryView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingWeeklyRecap) {
            WeeklyRecapView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Grateful")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)

            if streak > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                    Text("\(streak) day streak")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .transition(.opacity.combined(with: .scale))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
                .textCase(.uppercase)
                .tracking(1)

            VStack(spacing: 12) {
                ForEach(todayEntries) { entry in
                    GratitudeCard(entry: entry)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.8).combined(with: .opacity),
                            removal: .opacity
                        ))
                }
            }
        }
    }

    private var addButtonSection: some View {
        Button {
            showingAddEntry = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                Text(todayEntries.isEmpty ? "What are you grateful for?" : "Add another")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
            }
            .foregroundStyle(AppTheme.accent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, todayEntries.isEmpty ? 60 : 20)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                    .fill(AppTheme.lavender.opacity(0.4))
                    .strokeBorder(AppTheme.accent.opacity(0.2), lineWidth: 2, antialiased: true)
            )
        }
        .buttonStyle(.plain)
    }

    private var pastEntriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
                .textCase(.uppercase)
                .tracking(1)

            let pastEntries = entries.filter { !Calendar.current.isDateInToday($0.date) }
            let groupedEntries = Dictionary(grouping: pastEntries) { entry in
                Calendar.current.startOfDay(for: entry.date)
            }

            ForEach(groupedEntries.keys.sorted(by: >).prefix(7), id: \.self) { date in
                VStack(alignment: .leading, spacing: 8) {
                    Text(date.formatted(.dateTime.weekday(.wide).month().day()))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)

                    ForEach(groupedEntries[date] ?? []) { entry in
                        GratitudeCard(entry: entry, isCompact: true)
                    }
                }
            }
        }
    }

    private func calculateStreak() -> Int {
        let calendar = Calendar.current
        var currentDate = calendar.startOfDay(for: Date())
        var streakCount = 0

        while true {
            let hasEntry = entries.contains { entry in
                calendar.isDate(entry.date, inSameDayAs: currentDate)
            }

            if hasEntry {
                streakCount += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            } else {
                break
            }
        }

        return streakCount
    }
}

struct GratitudeCard: View {
    let entry: GratitudeEntry
    var isCompact: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(AppTheme.sage)
                .frame(width: isCompact ? 8 : 12, height: isCompact ? 8 : 12)

            Text(entry.text)
                .font(.system(size: isCompact ? 16 : 18, weight: .regular, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
                .lineLimit(3)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, isCompact ? 16 : 20)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .fill(AppTheme.cardBackground)
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
        )
    }
}

#Preview {
    ContentView()
        .modelContainer(for: GratitudeEntry.self, inMemory: true)
}

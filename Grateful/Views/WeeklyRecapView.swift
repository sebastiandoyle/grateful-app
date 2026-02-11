import SwiftUI
import SwiftData

struct WeeklyRecapView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \GratitudeEntry.date, order: .reverse) private var allEntries: [GratitudeEntry]
    @State private var isAnimating = false

    private var thisWeekEntries: [GratitudeEntry] {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        return allEntries.filter { $0.date >= weekAgo }
    }

    private var weekRange: String {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -6, to: endDate)!
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Gradient background
                LinearGradient(
                    colors: [AppTheme.lavender, AppTheme.cream],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        // Shareable card
                        shareableCard
                            .scaleEffect(isAnimating ? 1 : 0.9)
                            .opacity(isAnimating ? 1 : 0)

                        // Share button
                        ShareLink(item: shareImage, preview: SharePreview("My Week of Gratitude", image: shareImage)) {
                            HStack(spacing: 10) {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share")
                            }
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                    .fill(AppTheme.accent)
                            )
                        }
                        .padding(.horizontal, 24)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(AppTheme.textSecondary.opacity(0.5))
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                isAnimating = true
            }
        }
    }

    @MainActor
    private var shareImage: Image {
        let renderer = ImageRenderer(content: shareableCard)
        renderer.scale = 3
        if let uiImage = renderer.uiImage {
            return Image(uiImage: uiImage)
        }
        return Image(systemName: "heart.fill")
    }

    private var shareableCard: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("My Week of Gratitude")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(weekRange)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            // Entries
            if thisWeekEntries.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "heart")
                        .font(.system(size: 40))
                        .foregroundStyle(AppTheme.sage)
                    Text("Start adding gratitudes\nto see your weekly recap")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 40)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(thisWeekEntries.prefix(7)) { entry in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(AppTheme.sage)
                                .frame(width: 8, height: 8)

                            Text(entry.text)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundStyle(AppTheme.textPrimary)
                                .lineLimit(2)
                        }
                    }

                    if thisWeekEntries.count > 7 {
                        Text("+ \(thisWeekEntries.count - 7) more")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(AppTheme.textSecondary)
                            .padding(.leading, 20)
                    }
                }
            }

            // Footer
            HStack(spacing: 6) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(AppTheme.accent)
                Text("Grateful")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.accent)
            }
            .padding(.top, 8)
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(AppTheme.cardBackground)
                .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 10)
        )
        .padding(.horizontal, 24)
    }
}

#Preview {
    WeeklyRecapView()
        .modelContainer(for: GratitudeEntry.self, inMemory: true)
}

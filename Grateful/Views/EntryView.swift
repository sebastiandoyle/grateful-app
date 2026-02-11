import SwiftUI
import SwiftData

struct EntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var isAnimating = false
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        Spacer(minLength: 40)

                        // Prompt
                        VStack(spacing: 12) {
                            Text("What are you grateful for?")
                                .font(.system(size: 26, weight: .semibold, design: .rounded))
                                .foregroundStyle(AppTheme.textPrimary)
                                .multilineTextAlignment(.center)

                            Text("Take a moment to reflect")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)

                        // Text input
                        TextField("I'm grateful for...", text: $text, axis: .vertical)
                            .font(.system(size: 20, weight: .regular, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)
                            .lineLimit(4...6)
                            .padding(24)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                                    .fill(AppTheme.cardBackground)
                                    .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
                            )
                            .padding(.horizontal, 24)
                            .focused($isFocused)
                            .opacity(isAnimating ? 1 : 0)
                            .offset(y: isAnimating ? 0 : 30)

                        Spacer(minLength: 20)

                        // Save button
                        Button {
                            saveEntry()
                        } label: {
                            Text("Save")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                        .fill(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                              ? AppTheme.accent.opacity(0.4)
                                              : AppTheme.accent)
                                )
                        }
                        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 40)
                    }
                    .frame(minHeight: 350)
                }
                .scrollDismissesKeyboard(.interactively)
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
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isAnimating = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isFocused = true
            }
        }
    }

    private func saveEntry() {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        // Save entry
        let entry = GratitudeEntry(text: trimmedText)
        modelContext.insert(entry)

        // Success haptic
        let success = UINotificationFeedbackGenerator()
        success.notificationOccurred(.success)

        // Dismiss with slight delay for haptic
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            dismiss()
        }
    }
}

#Preview {
    EntryView()
        .modelContainer(for: GratitudeEntry.self, inMemory: true)
}

import SwiftUI
import UserNotifications

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("reminderEnabled") private var reminderEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 20
    @AppStorage("reminderMinute") private var reminderMinute = 0
    @State private var showingTimePicker = false
    @State private var selectedTime = Date()

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Reminders section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Daily Reminder")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(AppTheme.textSecondary)
                                .textCase(.uppercase)
                                .tracking(1)

                            VStack(spacing: 0) {
                                Toggle(isOn: $reminderEnabled) {
                                    HStack(spacing: 14) {
                                        Image(systemName: "bell.fill")
                                            .font(.system(size: 18))
                                            .foregroundStyle(AppTheme.accent)
                                        Text("Enable reminder")
                                            .font(.system(size: 17, weight: .regular, design: .rounded))
                                            .foregroundStyle(AppTheme.textPrimary)
                                    }
                                }
                                .tint(AppTheme.accent)
                                .padding(20)
                                .onChange(of: reminderEnabled) { _, newValue in
                                    if newValue {
                                        requestNotificationPermission()
                                    } else {
                                        cancelNotifications()
                                    }
                                }

                                if reminderEnabled {
                                    Divider()
                                        .padding(.horizontal, 20)

                                    Button {
                                        showingTimePicker = true
                                    } label: {
                                        HStack {
                                            HStack(spacing: 14) {
                                                Image(systemName: "clock")
                                                    .font(.system(size: 18))
                                                    .foregroundStyle(AppTheme.accent)
                                                Text("Reminder time")
                                                    .font(.system(size: 17, weight: .regular, design: .rounded))
                                                    .foregroundStyle(AppTheme.textPrimary)
                                            }
                                            Spacer()
                                            Text(formattedTime)
                                                .font(.system(size: 17, weight: .medium, design: .rounded))
                                                .foregroundStyle(AppTheme.accent)
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundStyle(AppTheme.textSecondary)
                                        }
                                        .padding(20)
                                    }
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                    .fill(AppTheme.cardBackground)
                                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
                            )
                        }

                        // About section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("About")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(AppTheme.textSecondary)
                                .textCase(.uppercase)
                                .tracking(1)

                            VStack(spacing: 0) {
                                HStack {
                                    Text("Version")
                                        .font(.system(size: 17, weight: .regular, design: .rounded))
                                        .foregroundStyle(AppTheme.textPrimary)
                                    Spacer()
                                    Text("1.0.0")
                                        .font(.system(size: 17, weight: .regular, design: .rounded))
                                        .foregroundStyle(AppTheme.textSecondary)
                                }
                                .padding(20)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                    .fill(AppTheme.cardBackground)
                                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
                            )
                        }

                        // Privacy note
                        Text("Your gratitudes are stored only on this device.\nNo data is collected or shared.")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundStyle(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.accent)
                }
            }
            .sheet(isPresented: $showingTimePicker) {
                timePickerSheet
            }
        }
    }

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        var components = DateComponents()
        components.hour = reminderHour
        components.minute = reminderMinute
        let date = Calendar.current.date(from: components) ?? Date()
        return formatter.string(from: date)
    }

    private var timePickerSheet: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "Reminder Time",
                    selection: $selectedTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding()
            }
            .navigationTitle("Select Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        showingTimePicker = false
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let components = Calendar.current.dateComponents([.hour, .minute], from: selectedTime)
                        reminderHour = components.hour ?? 20
                        reminderMinute = components.minute ?? 0
                        scheduleNotification()
                        showingTimePicker = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.height(300)])
        .onAppear {
            var components = DateComponents()
            components.hour = reminderHour
            components.minute = reminderMinute
            selectedTime = Calendar.current.date(from: components) ?? Date()
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            DispatchQueue.main.async {
                if granted {
                    scheduleNotification()
                } else {
                    reminderEnabled = false
                }
            }
        }
    }

    private func scheduleNotification() {
        cancelNotifications()

        let content = UNMutableNotificationContent()
        content.title = "Time for gratitude"
        content.body = "What are you grateful for today?"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = reminderHour
        dateComponents.minute = reminderMinute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "gratitude-reminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    private func cancelNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["gratitude-reminder"])
    }
}

#Preview {
    SettingsView()
}

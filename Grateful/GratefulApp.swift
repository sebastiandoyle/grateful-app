import SwiftUI
import SwiftData

@main
struct GratefulApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: GratitudeEntry.self)
    }
}

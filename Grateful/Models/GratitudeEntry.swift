import Foundation
import SwiftData

@Model
final class GratitudeEntry {
    var text: String
    var date: Date

    init(text: String, date: Date = .now) {
        self.text = text
        self.date = date
    }
}

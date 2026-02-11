import SwiftUI

struct AppTheme {
    // Muted color palette
    static let lavender = Color(red: 0.902, green: 0.878, blue: 0.973) // #E6E0F8
    static let cream = Color(red: 1.0, green: 0.973, blue: 0.941) // #FFF8F0
    static let sage = Color(red: 0.831, green: 0.898, blue: 0.843) // #D4E5D7
    static let warmGray = Color(red: 0.6, green: 0.58, blue: 0.56)
    static let deepPurple = Color(red: 0.42, green: 0.35, blue: 0.55)

    // Semantic colors
    static let background = cream
    static let cardBackground = Color.white
    static let accent = deepPurple
    static let textPrimary = Color(red: 0.2, green: 0.2, blue: 0.25)
    static let textSecondary = warmGray

    // Rounded corner radius
    static let cornerRadius: CGFloat = 20
    static let cardCornerRadius: CGFloat = 24
}

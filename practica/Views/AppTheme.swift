import SwiftUI

/// Paleta de colores y estilos de la app. Tema oscuro tipo cine.
/// Compatible con iOS 14.4.
enum AppTheme {
    // Colores
    static let background = Color(red: 0.08, green: 0.08, blue: 0.10)
    static let surface = Color(red: 0.12, green: 0.12, blue: 0.14)
    static let surfaceElevated = Color(red: 0.16, green: 0.16, blue: 0.18)
    static let accent = Color(red: 0.92, green: 0.65, blue: 0.04)
    static let accentSoft = Color(red: 0.92, green: 0.65, blue: 0.04).opacity(0.2)
    static let textPrimary = Color.white
    static let textSecondary = Color(red: 0.65, green: 0.65, blue: 0.68)
    static let textTertiary = Color(red: 0.50, green: 0.50, blue: 0.52)
    static let divider = Color.white.opacity(0.08)
    static let error = Color(red: 0.95, green: 0.35, blue: 0.35)
    static let favorite = Color(red: 0.95, green: 0.30, blue: 0.40)

    // Diseño: esquinas y espaciado
    static let cardCornerRadius: CGFloat = 14
    static let posterCornerRadius: CGFloat = 10
    static let cardPadding: CGFloat = 14
    static let cardSpacing: CGFloat = 12
    static let listRowSpacing: CGFloat = 10
}

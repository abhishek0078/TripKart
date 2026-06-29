import SwiftUI
import Observation

// MARK: - App Colors

extension Color {
    enum App {
        static let primary       = Color(red: 0.18, green: 0.49, blue: 0.98)
        static let primaryLight  = Color(red: 0.18, green: 0.49, blue: 0.98).opacity(0.12)
        static let background    = Color(.systemBackground)
        static let surface       = Color(.secondarySystemBackground)
        static let textPrimary   = Color(.label)
        static let textSecondary = Color(.secondaryLabel)
        static let textTertiary  = Color(.tertiaryLabel)
        static let border        = Color(.separator)
        static let error         = Color(.systemRed)
        static let success       = Color(.systemGreen)
        static let warning       = Color(.systemOrange)
    }
}

// MARK: - App Typography

extension Font {
    enum App {
        static let display      = Font.system(size: 32, weight: .bold,     design: .rounded)
        static let title        = Font.system(size: 24, weight: .bold,     design: .rounded)
        static let headline     = Font.system(size: 18, weight: .semibold, design: .default)
        static let body         = Font.system(size: 16, weight: .regular,  design: .default)
        static let bodyMedium   = Font.system(size: 16, weight: .medium,   design: .default)
        static let caption      = Font.system(size: 14, weight: .regular,  design: .default)
        static let captionMedium = Font.system(size: 14, weight: .medium,  design: .default)
        static let small        = Font.system(size: 12, weight: .regular,  design: .default)
        static let button       = Font.system(size: 16, weight: .semibold, design: .default)
        static let price        = Font.system(size: 20, weight: .bold,     design: .monospaced)
    }
}

// MARK: - Theme Manager

enum ColorSchemePreference: String, CaseIterable, Codable {
    case system = "System"
    case light  = "Light"
    case dark   = "Dark"

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

@Observable
final class ThemeManager {
    var colorSchemePreference: ColorSchemePreference = .system {
        didSet {
            UserDefaults.standard.set(colorSchemePreference.rawValue, forKey: "tripkart.colorScheme")
        }
    }

    init() {
        let raw = UserDefaults.standard.string(forKey: "tripkart.colorScheme") ?? ""
        colorSchemePreference = ColorSchemePreference(rawValue: raw) ?? .system
    }
}

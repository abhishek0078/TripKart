import SwiftUI

struct AppSettingsView: View {
    @Environment(ThemeManager.self) private var themeManager

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Color Scheme", selection: Binding(
                    get: { themeManager.colorSchemePreference },
                    set: { themeManager.colorSchemePreference = $0 }
                )) {
                    ForEach(ColorSchemePreference.allCases, id: \.self) { pref in
                        Label(pref.rawValue, systemImage: schemeIcon(pref)).tag(pref)
                    }
                }
                .pickerStyle(.segmented)
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            }

            Section("About") {
                HStack {
                    Text("App Version")
                    Spacer()
                    Text("\(appVersion) (\(buildNumber))")
                        .foregroundStyle(Color.App.textTertiary)
                }
                HStack {
                    Text("Developer")
                    Spacer()
                    Text("TripKart Inc.")
                        .foregroundStyle(Color.App.textTertiary)
                }
                Link(destination: URL(string: "https://tripkart.app/privacy")!) {
                    HStack {
                        Text("Privacy Policy").foregroundStyle(Color.App.textPrimary)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundStyle(Color.App.primary)
                    }
                }
                Link(destination: URL(string: "https://tripkart.app/terms")!) {
                    HStack {
                        Text("Terms of Service").foregroundStyle(Color.App.textPrimary)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundStyle(Color.App.primary)
                    }
                }
            }

            Section("Support") {
                HStack {
                    Label("Rate TripKart", systemImage: "star.fill")
                        .foregroundStyle(Color.App.warning)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.App.textTertiary)
                        .font(.system(size: 13))
                }
                HStack {
                    Label("Share TripKart", systemImage: "square.and.arrow.up")
                        .foregroundStyle(Color.App.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.App.textTertiary)
                        .font(.system(size: 13))
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }

    private func schemeIcon(_ pref: ColorSchemePreference) -> String {
        switch pref {
        case .system: return "circle.lefthalf.filled"
        case .light:  return "sun.max.fill"
        case .dark:   return "moon.fill"
        }
    }
}

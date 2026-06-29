import SwiftUI

struct ProfileView: View {
    @Environment(SessionEngine.self)       private var sessionEngine
    @Environment(DependencyContainer.self) private var container
    @State private var showLogoutConfirm = false

    var body: some View {
        List {
            // Avatar header — taps to Personal Info
            Section {
                NavigationLink(destination: PersonalInfoView()) {
                    HStack(spacing: Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(Color.App.primary)
                                .frame(width: 60, height: 60)
                            Text(initials)
                                .font(Font.App.headline)
                                .foregroundStyle(.white)
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text(sessionEngine.currentUser?.name ?? "Traveller")
                                .font(Font.App.bodyMedium)
                                .foregroundStyle(Color.App.textPrimary)
                            Text(sessionEngine.currentUser.map { "+91 \($0.phone)" } ?? "")
                                .font(Font.App.caption)
                                .foregroundStyle(Color.App.textSecondary)
                            if let email = sessionEngine.currentUser?.email {
                                Text(email)
                                    .font(Font.App.caption)
                                    .foregroundStyle(Color.App.textSecondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            // Account section
            Section("Account") {
                NavigationLink(destination: SavedTravellersView(repository: container.travellerRepository)) {
                    menuRow(icon: "figure.2", title: "Saved Travellers", subtitle: "Manage co-travellers")
                }
            }

            // App section
            Section("App") {
                NavigationLink(destination: PreferencesView()) {
                    menuRow(icon: "bell.fill",     title: "Preferences",      subtitle: "Notifications, language")
                }
                NavigationLink(destination: AppSettingsView()) {
                    menuRow(icon: "gearshape.fill", title: "Settings",        subtitle: "Theme, version, about")
                }
            }

            // Logout
            Section {
                Button(role: .destructive) {
                    showLogoutConfirm = true
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .frame(width: 22)
                        Text("Logout")
                    }
                    .foregroundStyle(Color.App.error)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .confirmationDialog(
            "Log out of TripKart?",
            isPresented: $showLogoutConfirm,
            titleVisibility: .visible
        ) {
            Button("Logout", role: .destructive) { sessionEngine.logout() }
        }
    }

    private func menuRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.App.primaryLight.opacity(0.15))
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.App.primary)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Font.App.bodyMedium)
                    .foregroundStyle(Color.App.textPrimary)
                Text(subtitle)
                    .font(Font.App.small)
                    .foregroundStyle(Color.App.textSecondary)
            }
        }
        .padding(.vertical, 2)
    }

    private var initials: String {
        guard let name = sessionEngine.currentUser?.name else { return "U" }
        let parts = name.components(separatedBy: " ")
        let first = parts.first?.first.map(String.init) ?? ""
        let last  = parts.count > 1 ? parts.last?.first.map(String.init) ?? "" : ""
        return (first + last).uppercased()
    }
}

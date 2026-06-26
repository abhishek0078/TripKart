import SwiftUI

struct ProfileView: View {

    @Environment(SessionEngine.self) private var sessionEngine

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                avatarSection
                menuSection
            }
            .padding(Spacing.lg)
        }
        .background(Color.App.background)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Sections

    private var avatarSection: some View {
        VStack(spacing: Spacing.md) {
            // Initials avatar
            ZStack {
                Circle()
                    .fill(Color.App.primary)
                    .frame(width: 80, height: 80)

                Text(initials)
                    .font(Font.App.title)
                    .foregroundStyle(.white)
            }

            if let user = sessionEngine.currentUser {
                VStack(spacing: Spacing.xs) {
                    Text(user.name)
                        .font(Font.App.headline)
                        .foregroundStyle(Color.App.textPrimary)

                    Text("+91 \(user.phone)")
                        .font(Font.App.caption)
                        .foregroundStyle(Color.App.textSecondary)

                    if let email = user.email {
                        Text(email)
                            .font(Font.App.caption)
                            .foregroundStyle(Color.App.textSecondary)
                    }
                }
            }
        }
        .padding(.top, Spacing.md)
    }

    private var menuSection: some View {
        VStack(spacing: 0) {
            ForEach(menuItems, id: \.title) { item in
                ProfileMenuRow(item: item)
                if item.title != menuItems.last?.title {
                    Divider().padding(.leading, Spacing.xl + Spacing.lg)
                }
            }
        }
        .background(Color.App.surface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.large))

        return VStack(spacing: 0) {
            Button(role: .destructive) {
                sessionEngine.logout()
            } label: {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .frame(width: 20)
                    Text("Logout")
                    Spacer()
                }
                .font(Font.App.body)
                .foregroundStyle(Color.App.error)
                .padding(Spacing.lg)
            }
        }
        .background(Color.App.surface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.large))
    }

    private var initials: String {
        guard let name = sessionEngine.currentUser?.name else { return "U" }
        let parts = name.components(separatedBy: " ")
        let first = parts.first?.first.map(String.init) ?? ""
        let last  = parts.count > 1 ? parts.last?.first.map(String.init) ?? "" : ""
        return (first + last).uppercased()
    }

    private var menuItems: [ProfileMenuItem] {
        [
            ProfileMenuItem(icon: "person.fill",        title: "Personal Info",      subtitle: "Name, email, phone"),
            ProfileMenuItem(icon: "figure.2",           title: "Saved Travellers",   subtitle: "Manage co-travellers"),
            ProfileMenuItem(icon: "creditcard.fill",    title: "Payment Methods",    subtitle: "Cards, UPI, wallets"),
            ProfileMenuItem(icon: "gearshape.fill",     title: "Settings",           subtitle: "Preferences, notifications")
        ]
    }
}

private struct ProfileMenuItem {
    let icon: String
    let title: String
    let subtitle: String
}

private struct ProfileMenuRow: View {
    let item: ProfileMenuItem

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: item.icon)
                .font(.system(size: 18))
                .foregroundStyle(Color.App.primary)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(Font.App.bodyMedium)
                    .foregroundStyle(Color.App.textPrimary)
                Text(item.subtitle)
                    .font(Font.App.small)
                    .foregroundStyle(Color.App.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.App.textTertiary)
        }
        .padding(Spacing.lg)
    }
}

#Preview {
    let session = SessionEngine()
    NavigationStack {
        ProfileView()
    }
    .environment(session)
}

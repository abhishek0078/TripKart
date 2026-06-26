import SwiftUI

struct LoaderView: View {

    var message: String = "Please wait…"

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            VStack(spacing: Spacing.md) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(1.2)
                    .tint(Color.App.primary)

                Text(message)
                    .font(Font.App.caption)
                    .foregroundStyle(Color.App.textSecondary)
            }
            .padding(Spacing.xl)
            .background(
                RoundedRectangle(cornerRadius: Radius.large)
                    .fill(Color.App.surface)
                    .shadow(color: .black.opacity(0.12), radius: Elevation.medium)
            )
        }
    }
}

#Preview {
    LoaderView(message: "Sending OTP…")
}

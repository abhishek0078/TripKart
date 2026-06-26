import SwiftUI

struct PrimaryButton: View {

    let title: String
    var isLoading: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .scaleEffect(0.85)
                } else {
                    Text(title)
                        .font(Font.App.button)
                        .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                RoundedRectangle(cornerRadius: Radius.medium)
                    .fill(isDisabled ? Color.App.primary.opacity(0.45) : Color.App.primary)
            )
        }
        .disabled(isDisabled || isLoading)
        .animation(.easeInOut(duration: AnimationDuration.fast), value: isLoading)
        .animation(.easeInOut(duration: AnimationDuration.fast), value: isDisabled)
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        PrimaryButton(title: "Get OTP") { }
        PrimaryButton(title: "Loading…", isLoading: true) { }
        PrimaryButton(title: "Disabled", isDisabled: true) { }
    }
    .padding()
}

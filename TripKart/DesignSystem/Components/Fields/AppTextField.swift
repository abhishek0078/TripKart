import SwiftUI

struct AppTextField: View {

    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var errorMessage: String? = nil
    var prefix: String? = nil
    var maxLength: Int? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(spacing: Spacing.sm) {
                if let prefix {
                    Text(prefix)
                        .font(Font.App.body)
                        .foregroundStyle(Color.App.textSecondary)

                    Divider()
                        .frame(height: 20)
                }

                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .textContentType(textContentType)
                    .font(Font.App.body)
                    .foregroundStyle(Color.App.textPrimary)
                    .focused($isFocused)
                    .onChange(of: text) { _, newValue in
                        guard let maxLength else { return }
                        let filtered = newValue.filter(\.isNumber)
                        if filtered.count > maxLength {
                            text = String(filtered.prefix(maxLength))
                        }
                    }
            }
            .padding(.horizontal, Spacing.md)
            .frame(height: 54)
            .background(
                RoundedRectangle(cornerRadius: Radius.medium)
                    .fill(Color.App.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.medium)
                            .stroke(borderColor, lineWidth: isFocused ? 2 : 1)
                    )
            )
            .animation(.easeInOut(duration: AnimationDuration.fast), value: isFocused)
            .animation(.easeInOut(duration: AnimationDuration.fast), value: errorMessage)

            if let errorMessage {
                Text(errorMessage)
                    .font(Font.App.small)
                    .foregroundStyle(Color.App.error)
                    .padding(.horizontal, Spacing.xs)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private var borderColor: Color {
        if errorMessage != nil { return Color.App.error }
        if isFocused { return Color.App.primary }
        return Color.App.border
    }
}

#Preview {
    @Previewable @State var phone = ""
    VStack(spacing: Spacing.md) {
        AppTextField(
            placeholder: "10-digit mobile number",
            text: $phone,
            keyboardType: .phonePad,
            prefix: "+91"
        )
        AppTextField(
            placeholder: "10-digit mobile number",
            text: $phone,
            errorMessage: "Invalid phone number"
        )
    }
    .padding()
}

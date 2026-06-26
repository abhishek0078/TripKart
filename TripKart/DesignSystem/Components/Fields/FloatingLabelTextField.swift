import SwiftUI

struct FloatingLabelTextField: View {
    let label: String
    var isRequired: Bool = false
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var error: String? = nil

    @FocusState private var isFocused: Bool

    private var isActive: Bool { isFocused || !text.isEmpty }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: Radius.medium)
                    .fill(Color.App.surface)
                    .frame(height: 56)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.medium)
                            .stroke(borderColor, lineWidth: isFocused ? 2 : 1)
                    )

                HStack(spacing: 2) {
                    Text(label)
                    if isRequired {
                        Text("*").foregroundStyle(Color.App.error)
                    }
                }
                .font(isActive ? Font.App.small : Font.App.body)
                .foregroundStyle(labelColor)
                .padding(.horizontal, Spacing.md)
                .offset(y: isActive ? -16 : 0)
                .animation(.easeInOut(duration: AnimationDuration.fast), value: isActive)

                TextField("", text: $text)
                    .font(Font.App.body)
                    .foregroundStyle(Color.App.textPrimary)
                    .keyboardType(keyboardType)
                    .focused($isFocused)
                    .padding(.horizontal, Spacing.md)
                    .offset(y: isActive ? 10 : 0)
                    .animation(.easeInOut(duration: AnimationDuration.fast), value: isActive)
            }
            .onTapGesture { isFocused = true }

            if let error {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 11))
                    Text(error)
                        .font(Font.App.small)
                }
                .foregroundStyle(Color.App.error)
                .padding(.horizontal, Spacing.xs)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: AnimationDuration.fast), value: error)
    }

    private var borderColor: Color {
        if error != nil { return Color.App.error }
        return isFocused ? Color.App.primary : Color.App.border
    }

    private var labelColor: Color {
        if error != nil { return Color.App.error }
        return isFocused ? Color.App.primary : Color.App.textSecondary
    }
}

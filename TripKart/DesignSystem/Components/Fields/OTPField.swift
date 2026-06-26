import SwiftUI

struct OTPField: View {

    @Binding var otp: String
    var length: Int = 6

    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            // Hidden capture field
            TextField("", text: $otp)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($isFocused)
                .opacity(0.001)
                .frame(width: 1, height: 1)
                .onChange(of: otp) { _, newValue in
                    let filtered = String(newValue.filter(\.isNumber).prefix(length))
                    if otp != filtered { otp = filtered }
                }

            // Visual digit boxes
            HStack(spacing: Spacing.sm) {
                ForEach(0..<length, id: \.self) { index in
                    OTPBoxView(
                        digit: digit(at: index),
                        isActive: isFocused && otp.count == index,
                        isFilled: index < otp.count
                    )
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { isFocused = true }
        }
        .onAppear { isFocused = true }
    }

    private func digit(at index: Int) -> String {
        guard index < otp.count else { return "" }
        return String(otp[otp.index(otp.startIndex, offsetBy: index)])
    }
}

private struct OTPBoxView: View {
    let digit: String
    let isActive: Bool
    let isFilled: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Radius.small)
                .fill(Color.App.surface)
                .frame(width: 48, height: 56)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.small)
                        .stroke(borderColor, lineWidth: isActive ? 2 : 1)
                )

            if !digit.isEmpty {
                Text(digit)
                    .font(Font.App.title)
                    .foregroundStyle(Color.App.textPrimary)
            }
        }
        .animation(.easeInOut(duration: AnimationDuration.fast), value: isActive)
    }

    private var borderColor: Color {
        if isActive { return Color.App.primary }
        if isFilled { return Color.App.primary.opacity(0.5) }
        return Color.App.border
    }
}

#Preview {
    @Previewable @State var otp = "123"
    OTPField(otp: $otp)
        .padding()
}

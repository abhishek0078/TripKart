import SwiftUI

struct PassengerPickerSheet: View {
    @Binding var count: Int
    let maxCount: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.xl) {
                Spacer()

                VStack(spacing: Spacing.lg) {
                    Text("\(count)")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.App.primary)

                    Text(count == 1 ? "Passenger" : "Passengers")
                        .font(Font.App.headline)
                        .foregroundStyle(Color.App.textSecondary)
                }

                HStack(spacing: Spacing.xl) {
                    Button {
                        if count > 1 { count -= 1 }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(count > 1 ? Color.App.primary : Color.App.border)
                    }
                    .disabled(count <= 1)

                    Button {
                        if count < maxCount { count += 1 }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(count < maxCount ? Color.App.primary : Color.App.border)
                    }
                    .disabled(count >= maxCount)
                }

                Text("Max \(maxCount) passengers")
                    .font(Font.App.caption)
                    .foregroundStyle(Color.App.textTertiary)

                Spacer()

                PrimaryButton(title: "Confirm", isLoading: false) {
                    dismiss()
                }
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, Spacing.lg)
            }
            .background(Color.App.background)
            .navigationTitle("Passengers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.App.primary)
                }
            }
        }
    }
}

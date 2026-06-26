import SwiftUI

struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    let title: String
    let minimumDate: Date
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.lg) {
                DatePicker(
                    "",
                    selection: $selectedDate,
                    in: minimumDate...,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(Color.App.primary)
                .padding(.horizontal, Spacing.md)

                Spacer()
            }
            .background(Color.App.background)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.App.primary)
                }
            }
        }
    }
}

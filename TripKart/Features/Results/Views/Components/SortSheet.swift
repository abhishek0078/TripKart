import SwiftUI

struct SortSheet: View {
    @Binding var selected: SortOption
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(SortOption.allCases, id: \.self) { option in
                Button {
                    selected = option
                    dismiss()
                } label: {
                    HStack {
                        Text(option.rawValue)
                            .font(Font.App.body)
                            .foregroundStyle(Color.App.textPrimary)
                        Spacer()
                        if selected == option {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.App.primary)
                        }
                    }
                }
                .listRowBackground(Color.App.background)
            }
            .listStyle(.plain)
            .background(Color.App.background)
            .navigationTitle("Sort By")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.App.primary)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

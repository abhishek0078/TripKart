import SwiftUI

struct LocationPickerSheet: View {
    @Binding var searchText: String
    let locations: [SearchLocation]
    let title: String
    let onSelect: (SearchLocation) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color.App.textSecondary)
                    TextField("Search city or code", text: $searchText)
                        .font(Font.App.body)
                }
                .padding(Spacing.md)
                .background(Color.App.surface)
                .clipShape(RoundedRectangle(cornerRadius: Radius.medium))
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.sm)

                if locations.isEmpty {
                    VStack(spacing: Spacing.md) {
                        Image(systemName: "location.slash")
                            .font(.system(size: 44))
                            .foregroundStyle(Color.App.textTertiary)
                        Text("No results found")
                            .font(Font.App.body)
                            .foregroundStyle(Color.App.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(locations) { location in
                        Button {
                            onSelect(location)
                        } label: {
                            HStack(spacing: Spacing.md) {
                                ZStack {
                                    Circle()
                                        .fill(Color.App.primaryLight.opacity(0.15))
                                        .frame(width: 40, height: 40)
                                    Text(location.code)
                                        .font(Font.App.captionMedium)
                                        .foregroundStyle(Color.App.primary)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(location.name)
                                        .font(Font.App.bodyMedium)
                                        .foregroundStyle(Color.App.textPrimary)
                                    Text(location.subtitle)
                                        .font(Font.App.caption)
                                        .foregroundStyle(Color.App.textSecondary)
                                }
                                Spacer()
                            }
                        }
                        .listRowBackground(Color.App.background)
                    }
                    .listStyle(.plain)
                }
            }
            .background(Color.App.background)
            .navigationTitle(title)
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

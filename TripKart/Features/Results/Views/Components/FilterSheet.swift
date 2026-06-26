import SwiftUI

struct FilterSheet: View {
    @Binding var filterOptions: FilterOptions
    let allPriceRange: ClosedRange<Int>
    let availableOperators: [String]
    let showsStops: Bool
    let onReset: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var localOptions: FilterOptions = FilterOptions()

    var body: some View {
        NavigationStack {
            List {
                priceSection
                ratingSection
                if showsStops { stopsSection }
                operatorsSection
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.App.background)
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Reset") {
                        localOptions = FilterOptions()
                    }
                    .foregroundStyle(Color.App.error)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        filterOptions = localOptions
                        dismiss()
                    }
                    .foregroundStyle(Color.App.primary)
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear { localOptions = filterOptions }
    }

    private var priceSection: some View {
        Section("Max Price") {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Text("Up to")
                        .font(Font.App.caption)
                        .foregroundStyle(Color.App.textSecondary)
                    Spacer()
                    Text(localOptions.maxPrice == Int.max
                         ? "₹\(allPriceRange.upperBound)+"
                         : "₹\(localOptions.maxPrice)")
                        .font(Font.App.bodyMedium)
                        .foregroundStyle(Color.App.primary)
                }
                Slider(
                    value: Binding(
                        get: { Double(localOptions.maxPrice == Int.max ? allPriceRange.upperBound : localOptions.maxPrice) },
                        set: { localOptions.maxPrice = Int($0) }
                    ),
                    in: Double(allPriceRange.lowerBound)...Double(allPriceRange.upperBound),
                    step: 50
                )
                .tint(Color.App.primary)
            }
            .listRowBackground(Color.App.surface)
        }
    }

    private var ratingSection: some View {
        Section("Min Rating") {
            HStack(spacing: Spacing.sm) {
                ForEach([0.0, 3.0, 3.5, 4.0, 4.5], id: \.self) { rating in
                    Button {
                        localOptions.minRating = rating
                    } label: {
                        Text(rating == 0 ? "Any" : "\(String(format: "%.1f", rating))★")
                            .font(Font.App.captionMedium)
                            .foregroundStyle(localOptions.minRating == rating ? .white : Color.App.textSecondary)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, Spacing.xs)
                            .background(localOptions.minRating == rating ? Color.App.primary : Color.App.surface)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(
                                    localOptions.minRating == rating ? Color.clear : Color.App.border,
                                    lineWidth: 1
                                )
                            )
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .listRowBackground(Color.App.background)
        }
    }

    private var stopsSection: some View {
        Section("Stops") {
            HStack(spacing: Spacing.sm) {
                ForEach([(Int.max, "Any"), (0, "Direct"), (1, "1 Stop")], id: \.0) { (val, label) in
                    Button {
                        localOptions.maxStops = val
                    } label: {
                        Text(label)
                            .font(Font.App.captionMedium)
                            .foregroundStyle(localOptions.maxStops == val ? .white : Color.App.textSecondary)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, Spacing.xs)
                            .background(localOptions.maxStops == val ? Color.App.primary : Color.App.surface)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(
                                    localOptions.maxStops == val ? Color.clear : Color.App.border,
                                    lineWidth: 1
                                )
                            )
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .listRowBackground(Color.App.background)
        }
    }

    private var operatorsSection: some View {
        Section("Operators") {
            ForEach(availableOperators, id: \.self) { op in
                Button {
                    if localOptions.selectedOperators.contains(op) {
                        localOptions.selectedOperators.remove(op)
                    } else {
                        localOptions.selectedOperators.insert(op)
                    }
                } label: {
                    HStack {
                        Text(op)
                            .font(Font.App.body)
                            .foregroundStyle(Color.App.textPrimary)
                        Spacer()
                        Image(systemName: localOptions.selectedOperators.contains(op)
                              ? "checkmark.square.fill" : "square")
                            .foregroundStyle(localOptions.selectedOperators.contains(op)
                                             ? Color.App.primary : Color.App.border)
                    }
                }
                .listRowBackground(Color.App.surface)
            }
        }
    }
}

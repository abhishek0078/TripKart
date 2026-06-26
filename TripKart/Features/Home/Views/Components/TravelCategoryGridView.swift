import SwiftUI

struct TravelCategoryGridView: View {

    let categories: [TravelCategory]
    let onCategoryTap: (TravelCategory) -> Void

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: Spacing.md) {
            ForEach(categories) { category in
                CategoryCardView(category: category) {
                    onCategoryTap(category)
                }
            }
        }
    }
}

#Preview {
    TravelCategoryGridView(
        categories: [
            TravelCategory(id: "1", name: "Bus",    systemIcon: "bus.fill",      pluginType: "bus",    isAvailable: true),
            TravelCategory(id: "2", name: "Flight", systemIcon: "airplane",      pluginType: "flight", isAvailable: true),
            TravelCategory(id: "3", name: "Train",  systemIcon: "tram.fill",     pluginType: "train",  isAvailable: false),
            TravelCategory(id: "4", name: "Hotel",  systemIcon: "building.2.fill", pluginType: "hotel", isAvailable: false),
            TravelCategory(id: "5", name: "Cab",    systemIcon: "car.fill",      pluginType: "cab",    isAvailable: false)
        ],
        onCategoryTap: { _ in }
    )
    .padding()
}

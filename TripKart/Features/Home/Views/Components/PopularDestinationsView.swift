import SwiftUI

struct PopularDestinationsView: View {

    let destinations: [PopularDestination]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: Spacing.md) {
                ForEach(destinations) { destination in
                    DestinationCardView(destination: destination)
                }
            }
            .padding(.horizontal, Spacing.lg)
        }
    }
}

#Preview {
    PopularDestinationsView(destinations: [
        PopularDestination(id: "1", name: "Goa",    state: "Goa",              systemIcon: "sun.max.fill",    category: "Beaches"),
        PopularDestination(id: "2", name: "Manali", state: "Himachal Pradesh", systemIcon: "mountain.2.fill", category: "Hills")
    ])
}

import SwiftUI

struct SectionHeaderView: View {

    let title: String
    var showSeeAll: Bool = true
    var onSeeAll: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .center) {
            Text(title)
                .font(Font.App.headline)
                .foregroundStyle(Color.App.textPrimary)

            Spacer()

            if showSeeAll {
                Button {
                    onSeeAll?()
                } label: {
                    Text("See All")
                        .font(Font.App.captionMedium)
                        .foregroundStyle(Color.App.primary)
                }
            }
        }
    }
}

#Preview {
    SectionHeaderView(title: "Popular Destinations")
        .padding()
}

import SwiftUI

@Observable
private final class SavedTravellersViewModel {
    var travellers: [Traveller] = []
    var isLoading = false

    private let repository: any TravellerRepository

    init(repository: any TravellerRepository) {
        self.repository = repository
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        travellers = (try? await repository.fetchAll()) ?? []
    }

    func delete(at offsets: IndexSet) {
        let ids = offsets.map { travellers[$0].id }
        travellers.remove(atOffsets: offsets)
        Task {
            for id in ids { try? await repository.delete(id: id) }
        }
    }
}

struct SavedTravellersView: View {
    let repository: any TravellerRepository

    @State private var viewModel: SavedTravellersViewModel
    @State private var showAddSheet = false
    @State private var editingTraveller: Traveller?

    init(repository: any TravellerRepository) {
        self.repository = repository
        _viewModel = State(initialValue: SavedTravellersViewModel(repository: repository))
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView().tint(Color.App.primary)
            } else if viewModel.travellers.isEmpty {
                emptyView
            } else {
                List {
                    ForEach(viewModel.travellers) { traveller in
                        Button { editingTraveller = traveller } label: {
                            travellerRow(traveller)
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { viewModel.delete(at: $0) }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Saved Travellers")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showAddSheet = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .task { await viewModel.load() }
        .onAppear { Task { await viewModel.load() } }
        .sheet(isPresented: $showAddSheet, onDismiss: { Task { await viewModel.load() } }) {
            NavigationStack {
                AddEditTravellerView(repository: repository)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { showAddSheet = false }
                        }
                    }
            }
        }
        .sheet(item: $editingTraveller, onDismiss: { Task { await viewModel.load() } }) { t in
            NavigationStack {
                AddEditTravellerView(repository: repository, existing: t)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { editingTraveller = nil }
                        }
                    }
            }
        }
    }

    private func travellerRow(_ t: Traveller) -> some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color.App.primaryLight.opacity(0.15))
                    .frame(width: 44, height: 44)
                Text("\(t.firstName.prefix(1))\(t.lastName.prefix(1))".uppercased())
                    .font(Font.App.bodyMedium)
                    .foregroundStyle(Color.App.primary)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(t.fullName)
                    .font(Font.App.bodyMedium)
                    .foregroundStyle(Color.App.textPrimary)
                Text("\(t.gender.rawValue) · \(t.age) yrs · \(t.documentType)")
                    .font(Font.App.caption)
                    .foregroundStyle(Color.App.textSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.App.textTertiary)
        }
        .padding(.vertical, 4)
    }

    private var emptyView: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            Image(systemName: "figure.2")
                .font(.system(size: 56))
                .foregroundStyle(Color.App.primary.opacity(0.3))
            Text("No Saved Travellers")
                .font(Font.App.title)
                .foregroundStyle(Color.App.textPrimary)
            Text("Add co-travellers so you can quickly fill in their details during booking.")
                .font(Font.App.body)
                .foregroundStyle(Color.App.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)
            Button { showAddSheet = true } label: {
                Label("Add Traveller", systemImage: "plus.circle.fill")
                    .font(Font.App.bodyMedium)
                    .foregroundStyle(.white)
                    .padding(.horizontal, Spacing.xl)
                    .padding(.vertical, Spacing.md)
                    .background(Color.App.primary)
                    .clipShape(Capsule())
            }
            Spacer()
        }
    }
}

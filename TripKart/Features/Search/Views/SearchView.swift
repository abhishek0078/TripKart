import SwiftUI

struct SearchView: View {
    @Environment(HomeCoordinator.self) private var coordinator
    @State private var viewModel: SearchViewModel

    init(plugin: any SearchPlugin, locationRepository: any LocationRepository) {
        _viewModel = State(initialValue: SearchViewModel(plugin: plugin, locationRepository: locationRepository))
    }

    private var plugin: any SearchPlugin { viewModel.currentPlugin }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.md) {
                if plugin.supportsTripType {
                    tripTypePicker
                }
                locationSection
                Divider().padding(.horizontal, Spacing.md)
                dateSection
                Divider().padding(.horizontal, Spacing.md)
                passengerSection
                Divider().padding(.horizontal, Spacing.md)
                searchButton
            }
            .padding(.vertical, Spacing.md)
        }
        .background(Color.App.background)
        .navigationTitle(plugin.displayName)
        .navigationBarTitleDisplayMode(.large)
        .task { await viewModel.loadLocations() }
        .sheet(isPresented: $viewModel.isLocationPickerPresented) {
            LocationPickerSheet(
                searchText: $viewModel.locationSearchText,
                locations: viewModel.filteredLocations,
                title: viewModel.isPickingOrigin ? plugin.originLabel : plugin.destinationLabel,
                onSelect: { viewModel.selectLocation($0) }
            )
        }
        .sheet(isPresented: $viewModel.isTravelDatePickerPresented) {
            DatePickerSheet(
                selectedDate: $viewModel.travelDate,
                title: "Travel Date",
                minimumDate: Date()
            )
        }
        .sheet(isPresented: $viewModel.isReturnDatePickerPresented) {
            DatePickerSheet(
                selectedDate: $viewModel.returnDate,
                title: "Return Date",
                minimumDate: viewModel.travelDate
            )
        }
        .sheet(isPresented: $viewModel.isPassengerPickerPresented) {
            PassengerPickerSheet(count: $viewModel.passengers, maxCount: plugin.maxPassengers)
                .presentationDetents([.medium])
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            if let msg = viewModel.errorMessage { Text(msg) }
        }
    }

    private var tripTypePicker: some View {
        HStack(spacing: 0) {
            ForEach(TripType.allCases, id: \.self) { type in
                Button {
                    withAnimation(.easeInOut(duration: AnimationDuration.fast)) {
                        viewModel.tripType = type
                    }
                } label: {
                    Text(type.rawValue)
                        .font(Font.App.bodyMedium)
                        .foregroundStyle(viewModel.tripType == type ? .white : Color.App.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.sm)
                        .background(
                            viewModel.tripType == type ? Color.App.primary : Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: Radius.medium))
                }
            }
        }
        .padding(4)
        .background(Color.App.surface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.medium + 4))
        .padding(.horizontal, Spacing.md)
    }

    private var locationSection: some View {
        VStack(spacing: 0) {
            locationButton(
                label: plugin.originLabel,
                icon: "location.fill",
                location: viewModel.origin
            ) {
                viewModel.isPickingOrigin = true
                viewModel.locationSearchText = ""
                viewModel.isLocationPickerPresented = true
            }

            ZStack {
                Divider().padding(.leading, 56)
                HStack {
                    Spacer()
                    Button {
                        withAnimation(.spring(duration: AnimationDuration.normal)) {
                            viewModel.swapLocations()
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.App.primary)
                            .background(Color.App.background)
                    }
                    .padding(.trailing, Spacing.md)
                }
            }

            locationButton(
                label: plugin.destinationLabel,
                icon: "mappin.circle.fill",
                location: viewModel.destination
            ) {
                viewModel.isPickingOrigin = false
                viewModel.locationSearchText = ""
                viewModel.isLocationPickerPresented = true
            }
        }
        .background(Color.App.surface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.large))
        .padding(.horizontal, Spacing.md)
    }

    private func locationButton(
        label: String,
        icon: String,
        location: SearchLocation?,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(Color.App.primary)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(label.uppercased())
                        .font(Font.App.small)
                        .foregroundStyle(Color.App.textTertiary)
                    if let location {
                        Text(location.name)
                            .font(Font.App.headline)
                            .foregroundStyle(Color.App.textPrimary)
                        Text("\(location.subtitle) • \(location.code)")
                            .font(Font.App.caption)
                            .foregroundStyle(Color.App.textSecondary)
                    } else {
                        Text("Select \(label)")
                            .font(Font.App.body)
                            .foregroundStyle(Color.App.textTertiary)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.md)
        }
    }

    private var dateSection: some View {
        HStack(spacing: Spacing.md) {
            dateButton(
                label: "DEPARTURE",
                date: viewModel.travelDate
            ) {
                viewModel.isTravelDatePickerPresented = true
            }

            if plugin.supportsTripType && viewModel.tripType == .roundTrip {
                Divider().frame(height: 44)
                dateButton(
                    label: "RETURN",
                    date: viewModel.returnDate
                ) {
                    viewModel.isReturnDatePickerPresented = true
                }
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    private func dateButton(label: String, date: Date, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(Font.App.small)
                    .foregroundStyle(Color.App.textTertiary)
                Text(date.formatted(.dateTime.day().month(.abbreviated)))
                    .font(Font.App.headline)
                    .foregroundStyle(Color.App.textPrimary)
                Text(date.formatted(.dateTime.year().weekday(.abbreviated)))
                    .font(Font.App.caption)
                    .foregroundStyle(Color.App.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var passengerSection: some View {
        Button {
            viewModel.isPassengerPickerPresented = true
        } label: {
            HStack(spacing: Spacing.md) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.App.primary)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text("PASSENGERS")
                        .font(Font.App.small)
                        .foregroundStyle(Color.App.textTertiary)
                    Text("\(viewModel.passengers) \(viewModel.passengers == 1 ? "Passenger" : "Passengers")")
                        .font(Font.App.headline)
                        .foregroundStyle(Color.App.textPrimary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(Font.App.caption)
                    .foregroundStyle(Color.App.textTertiary)
            }
            .padding(.horizontal, Spacing.md)
        }
    }

    private var searchButton: some View {
        PrimaryButton(title: "Search \(plugin.displayName)", isLoading: false) {
            let result = viewModel.validateAndSearch()
            switch result {
            case .success(let query):
                coordinator.navigateToResults(query: query)
            case .failure(let error):
                viewModel.errorMessage = error.errorDescription ?? "An error occurred."
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.sm)
    }
}

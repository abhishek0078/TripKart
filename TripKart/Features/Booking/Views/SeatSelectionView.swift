import SwiftUI

struct SeatSelectionView: View {
    let isReturn: Bool

    @Environment(BookingCoordinator.self) private var coordinator
    @Environment(BookingEngine.self) private var bookingEngine

    // MARK: — Seat data

    private static let busBooked: Set<String>      = ["1A","1D","2B","3C","4A","4D","5B","6C","7A","8D","9B","10C"]
    private static let businessBooked: Set<String> = ["1A","2D","3B","1C"]
    private static let economyBooked: Set<String>  = ["5A","6E","7C","8F","9B","10A","11D","12C","13E","14B"]
    // Different pre-booked seats for return leg so it looks distinct
    private static let businessReturnBooked: Set<String> = ["1B","2C","3D","2A"]
    private static let economyReturnBooked: Set<String>  = ["4C","5F","6B","7E","8A","9D","10C","11F","12A","13D","14E"]
    private static let busReturnBooked: Set<String>      = ["1B","2C","3A","4D","5C","6A","7D","8B","9C","10A"]

    // MARK: — Helpers to read/write current leg seats

    private var currentSeats: [String] {
        isReturn ? bookingEngine.returnSeats : bookingEngine.outboundSeats
    }

    private func toggleSeat(_ seat: String, booked: Set<String>) {
        guard !booked.contains(seat) else { return }
        if isReturn {
            if bookingEngine.returnSeats.contains(seat) {
                bookingEngine.returnSeats.removeAll { $0 == seat }
            } else if bookingEngine.returnSeats.count < bookingEngine.query.passengers {
                bookingEngine.returnSeats.append(seat)
            }
        } else {
            if bookingEngine.outboundSeats.contains(seat) {
                bookingEngine.outboundSeats.removeAll { $0 == seat }
            } else if bookingEngine.outboundSeats.count < bookingEngine.query.passengers {
                bookingEngine.outboundSeats.append(seat)
            }
        }
    }

    private var currentCabinClass: String {
        isReturn ? bookingEngine.returnCabinClass : bookingEngine.selectedCabinClass
    }

    private func setCabinClass(_ cabin: String) {
        if isReturn {
            if bookingEngine.returnCabinClass != cabin {
                bookingEngine.returnCabinClass = cabin
                bookingEngine.returnSeats = []
            }
        } else {
            if bookingEngine.selectedCabinClass != cabin {
                bookingEngine.selectedCabinClass = cabin
                bookingEngine.outboundSeats = []
            }
        }
    }

    // MARK: — Body

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                legBanner
                switch bookingEngine.plugin.seatSelectionType {
                case .seatGrid:   busSeatSection
                case .cabinClass: flightSeatSection
                }
            }
            .padding(.vertical, Spacing.md)
        }
        .background(Color.App.background)
        .navigationTitle("Select Seat")
        .navigationBarTitleDisplayMode(.large)
        .safeAreaInset(edge: .bottom) { continueButton }
    }

    private var legBanner: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: isReturn ? "arrow.left.circle.fill" : "arrow.right.circle.fill")
                .foregroundStyle(Color.App.primary)
            VStack(alignment: .leading, spacing: 2) {
                Text(isReturn ? "Return Journey" : "Outbound Journey")
                    .font(Font.App.bodyMedium)
                    .foregroundStyle(Color.App.textPrimary)
                let origin = isReturn ? bookingEngine.query.destination : bookingEngine.query.origin
                let dest   = isReturn ? bookingEngine.query.origin : bookingEngine.query.destination
                let date   = isReturn ? (bookingEngine.query.returnDate ?? bookingEngine.query.travelDate) : bookingEngine.query.travelDate
                Text("\(origin.name) → \(dest.name) · \(date.formatted(.dateTime.day().month(.abbreviated)))")
                    .font(Font.App.caption)
                    .foregroundStyle(Color.App.textSecondary)
            }
            Spacer()
        }
        .padding(Spacing.md)
        .background(isReturn ? Color.App.warning.opacity(0.08) : Color.App.primaryLight.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: Radius.medium))
        .padding(.horizontal, Spacing.md)
    }

    // MARK: — Bus

    private var busSeatSection: some View {
        VStack(spacing: Spacing.md) {
            legendView
            busGrid
            selectionSummary
        }
    }

    private var busGrid: some View {
        let booked = isReturn ? Self.busReturnBooked : Self.busBooked
        return VStack(spacing: Spacing.xs) {
            columnHeader(["A","B","","C","D"])
            ForEach(1...10, id: \.self) { row in
                HStack(spacing: 0) {
                    rowLabel("\(row)")
                    seatCell("\(row)A", booked: booked)
                    seatCell("\(row)B", booked: booked)
                    aisleSpace
                    seatCell("\(row)C", booked: booked)
                    seatCell("\(row)D", booked: booked)
                }
                .padding(.horizontal, Spacing.md)
            }
        }
    }

    // MARK: — Flight

    private var flightSeatSection: some View {
        VStack(spacing: Spacing.md) {
            cabinClassPicker
            legendView
            if currentCabinClass == "Business" {
                Text("Business Class · Rows 1–3")
                    .font(Font.App.captionMedium)
                    .foregroundStyle(Color.App.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Spacing.md)
                businessGrid
            } else {
                Text("Economy Class · Rows 4–15")
                    .font(Font.App.captionMedium)
                    .foregroundStyle(Color.App.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Spacing.md)
                economyGrid
            }
            selectionSummary
        }
    }

    private var cabinClassPicker: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(["Economy", "Business"], id: \.self) { cabin in
                Button { setCabinClass(cabin) } label: {
                    VStack(spacing: 4) {
                        Image(systemName: cabin == "Business" ? "star.fill" : "airplane.seat")
                            .font(.system(size: 18))
                            .foregroundStyle(currentCabinClass == cabin ? .white : Color.App.primary)
                        Text(cabin)
                            .font(Font.App.captionMedium)
                            .foregroundStyle(currentCabinClass == cabin ? .white : Color.App.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
                    .background(currentCabinClass == cabin ? Color.App.primary : Color.App.surface)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.medium))
                    .overlay(RoundedRectangle(cornerRadius: Radius.medium)
                        .stroke(currentCabinClass == cabin ? Color.clear : Color.App.border, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    private var businessGrid: some View {
        let booked = isReturn ? Self.businessReturnBooked : Self.businessBooked
        return VStack(spacing: Spacing.xs) {
            columnHeader(["A","B","","C","D"])
            ForEach(1...3, id: \.self) { row in
                HStack(spacing: 0) {
                    rowLabel("\(row)")
                    seatCell("\(row)A", booked: booked)
                    seatCell("\(row)B", booked: booked)
                    aisleSpace
                    seatCell("\(row)C", booked: booked)
                    seatCell("\(row)D", booked: booked)
                }
                .padding(.horizontal, Spacing.md)
            }
        }
    }

    private var economyGrid: some View {
        let booked = isReturn ? Self.economyReturnBooked : Self.economyBooked
        return VStack(spacing: Spacing.xs) {
            columnHeader(["A","B","C","","D","E","F"])
            ForEach(4...15, id: \.self) { row in
                HStack(spacing: 0) {
                    rowLabel("\(row)")
                    seatCell("\(row)A", booked: booked)
                    seatCell("\(row)B", booked: booked)
                    seatCell("\(row)C", booked: booked)
                    aisleSpace
                    seatCell("\(row)D", booked: booked)
                    seatCell("\(row)E", booked: booked)
                    seatCell("\(row)F", booked: booked)
                }
                .padding(.horizontal, Spacing.md)
            }
        }
    }

    // MARK: — Shared helpers

    private var legendView: some View {
        HStack(spacing: Spacing.lg) {
            legendItem(color: Color.App.surface, border: Color.App.border, label: "Available")
            legendItem(color: Color.App.primary, border: .clear, label: "Selected")
            legendItem(color: Color.App.border.opacity(0.4), border: .clear, label: "Booked")
        }
        .padding(.horizontal, Spacing.md)
    }

    private func legendItem(color: Color, border: Color, label: String) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 4).fill(color).frame(width: 18, height: 18)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(border, lineWidth: 1))
            Text(label).font(Font.App.caption).foregroundStyle(Color.App.textSecondary)
        }
    }

    private func columnHeader(_ cols: [String]) -> some View {
        HStack(spacing: 0) {
            Text("").frame(width: 28)
            ForEach(cols, id: \.self) { col in
                if col.isEmpty { aisleSpace }
                else {
                    Text(col).font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.App.textTertiary).frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    private func rowLabel(_ label: String) -> some View {
        Text(label).font(.system(size: 10)).foregroundStyle(Color.App.textTertiary).frame(width: 28)
    }

    private var aisleSpace: some View { Spacer().frame(width: 16) }

    private func seatCell(_ seat: String, booked: Set<String>) -> some View {
        let isBooked   = booked.contains(seat)
        let isSelected = currentSeats.contains(seat)
        return Button { toggleSeat(seat, booked: booked) } label: {
            RoundedRectangle(cornerRadius: 5)
                .fill(isBooked ? Color.App.border.opacity(0.4) : isSelected ? Color.App.primary : Color.App.surface)
                .frame(height: 32)
                .overlay(Text(seat).font(.system(size: 8, weight: .medium))
                    .foregroundStyle(isSelected ? .white : isBooked ? Color.App.textTertiary : Color.App.textSecondary))
                .overlay(RoundedRectangle(cornerRadius: 5)
                    .stroke(isBooked || isSelected ? Color.clear : Color.App.border, lineWidth: 1))
        }
        .frame(maxWidth: .infinity)
        .disabled(isBooked)
    }

    private var selectionSummary: some View {
        HStack {
            Text("Selected:")
                .font(Font.App.caption).foregroundStyle(Color.App.textSecondary)
            if currentSeats.isEmpty {
                Text("None").font(Font.App.caption).foregroundStyle(Color.App.textTertiary)
            } else {
                Text(currentSeats.sorted().joined(separator: ", "))
                    .font(Font.App.captionMedium).foregroundStyle(Color.App.primary)
            }
            Spacer()
            Text("\(currentSeats.count)/\(bookingEngine.query.passengers)")
                .font(Font.App.captionMedium).foregroundStyle(Color.App.textSecondary)
        }
        .padding(.horizontal, Spacing.md)
    }

    private var continueButton: some View {
        let ready = currentSeats.count == bookingEngine.query.passengers
        return VStack(spacing: 0) {
            Divider()
            PrimaryButton(title: "Continue", isLoading: false) {
                if isReturn {
                    coordinator.navigateToReviewBooking()
                } else if bookingEngine.isRoundTrip {
                    coordinator.navigateToReturnFlightSelection()
                } else {
                    coordinator.navigateToReviewBooking()
                }
            }
            .padding(Spacing.md)
            .background(Color.App.background)
            .opacity(ready ? 1 : 0.5)
            .disabled(!ready)
        }
    }
}

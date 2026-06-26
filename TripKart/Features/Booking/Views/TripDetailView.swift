import SwiftUI

struct TripDetailView: View {
    @Environment(BookingCoordinator.self) private var coordinator
    @Environment(BookingEngine.self) private var bookingEngine
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.md) {
                if bookingEngine.isRoundTrip {
                    roundTripBanner
                }
                operatorHeaderCard
                journeyTimelineCard
                tripInfoCard
                FareCardView(
                    fare: bookingEngine.fareBreakdown,
                    passengers: bookingEngine.query.passengers,
                    outboundOperator: bookingEngine.outboundResult.operatorName
                )
                .padding(.horizontal, Spacing.md)
            }
            .padding(.vertical, Spacing.md)
        }
        .background(Color.App.background)
        .navigationTitle("Trip Details")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.App.textTertiary)
                }
            }
        }
        .safeAreaInset(edge: .bottom) { bookButton }
    }

    private var roundTripBanner: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "arrow.left.arrow.right.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(Color.App.primary)
            VStack(alignment: .leading, spacing: 2) {
                Text("Round Trip")
                    .font(Font.App.bodyMedium).foregroundStyle(Color.App.primary)
                if let returnDate = bookingEngine.query.returnDate {
                    Text("Return: \(returnDate.formatted(.dateTime.day().month(.abbreviated).year()))")
                        .font(Font.App.caption).foregroundStyle(Color.App.textSecondary)
                }
            }
            Spacer()
            Text("You'll select the return flight after outbound seats")
                .font(Font.App.small)
                .foregroundStyle(Color.App.textTertiary)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 160)
        }
        .padding(Spacing.md)
        .background(Color.App.primaryLight.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: Radius.medium))
        .padding(.horizontal, Spacing.md)
    }

    private var operatorHeaderCard: some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: Radius.medium)
                    .fill(Color.App.primaryLight.opacity(0.12))
                    .frame(width: 56, height: 56)
                Image(systemName: bookingEngine.outboundResult.operatorIcon)
                    .font(.system(size: 26))
                    .foregroundStyle(Color.App.primary)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(bookingEngine.outboundResult.operatorName)
                    .font(Font.App.headline).foregroundStyle(Color.App.textPrimary)
                if let type = bookingEngine.outboundResult.busType {
                    Text(type).font(Font.App.caption).foregroundStyle(Color.App.textSecondary)
                }
                if let num = bookingEngine.outboundResult.flightNumber {
                    Text(num).font(Font.App.caption).foregroundStyle(Color.App.textSecondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("₹\(bookingEngine.outboundResult.price)")
                    .font(Font.App.price).foregroundStyle(Color.App.primary)
                Text("per person").font(Font.App.small).foregroundStyle(Color.App.textTertiary)
            }
        }
        .padding(Spacing.md)
        .background(Color.App.surface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.large))
        .padding(.horizontal, Spacing.md)
    }

    private var journeyTimelineCard: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text(bookingEngine.outboundResult.departureTime)
                    .font(Font.App.title).foregroundStyle(Color.App.textPrimary)
                Text(bookingEngine.query.origin.name)
                    .font(Font.App.caption).foregroundStyle(Color.App.textSecondary)
                Text(bookingEngine.query.origin.code)
                    .font(Font.App.captionMedium).foregroundStyle(Color.App.primary)
            }
            Spacer()
            VStack(spacing: 4) {
                Text(bookingEngine.outboundResult.duration)
                    .font(Font.App.caption).foregroundStyle(Color.App.textSecondary)
                Image(systemName: "arrow.right").foregroundStyle(Color.App.border)
                Text(bookingEngine.outboundResult.stops == 0 ? "Direct" : "\(bookingEngine.outboundResult.stops) Stop")
                    .font(Font.App.small)
                    .foregroundStyle(bookingEngine.outboundResult.stops == 0 ? Color.App.success : Color.App.warning)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(bookingEngine.outboundResult.arrivalTime)
                    .font(Font.App.title).foregroundStyle(Color.App.textPrimary)
                Text(bookingEngine.query.destination.name)
                    .font(Font.App.caption).foregroundStyle(Color.App.textSecondary)
                Text(bookingEngine.query.destination.code)
                    .font(Font.App.captionMedium).foregroundStyle(Color.App.primary)
            }
        }
        .padding(Spacing.md)
        .background(Color.App.surface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.large))
        .padding(.horizontal, Spacing.md)
    }

    private var tripInfoCard: some View {
        VStack(spacing: Spacing.sm) {
            infoRow("Departure", value: bookingEngine.query.travelDate.formatted(.dateTime.day().month(.wide).year()))
            if bookingEngine.isRoundTrip, let rd = bookingEngine.query.returnDate {
                Divider()
                infoRow("Return", value: rd.formatted(.dateTime.day().month(.wide).year()))
            }
            Divider()
            infoRow("Trip Type", value: bookingEngine.isRoundTrip ? "Round Trip" : "One Way")
            Divider()
            infoRow("Passengers", value: "\(bookingEngine.query.passengers)")
            Divider()
            infoRow("Seats Available", value: "\(bookingEngine.outboundResult.availableSeats)")
            Divider()
            infoRow("Rating", value: String(format: "%.1f ★", bookingEngine.outboundResult.rating))
        }
        .padding(Spacing.md)
        .background(Color.App.surface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.large))
        .padding(.horizontal, Spacing.md)
    }

    private func infoRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label).font(Font.App.body).foregroundStyle(Color.App.textSecondary)
            Spacer()
            Text(value).font(Font.App.bodyMedium).foregroundStyle(Color.App.textPrimary)
        }
    }

    private var bookButton: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("From ₹\(bookingEngine.fareBreakdown.total)")
                        .font(Font.App.headline).foregroundStyle(Color.App.primary)
                    Text(bookingEngine.isRoundTrip ? "Outbound + Return · \(bookingEngine.query.passengers) pax" : "\(bookingEngine.query.passengers) passenger(s)")
                        .font(Font.App.caption).foregroundStyle(Color.App.textSecondary)
                }
                Spacer()
                Button { coordinator.navigateToTravellerForm() } label: {
                    Text("Book Now")
                        .font(Font.App.button).foregroundStyle(.white)
                        .padding(.horizontal, Spacing.xl)
                        .padding(.vertical, Spacing.md)
                        .background(Color.App.primary)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.medium))
                }
            }
            .padding(Spacing.md)
            .background(Color.App.background)
        }
    }
}

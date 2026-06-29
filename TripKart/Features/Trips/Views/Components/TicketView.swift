import SwiftUI

/// Boarding-pass style ticket used both inline and for PDF export via ImageRenderer.
struct TicketView: View {
    let booking: Booking

    var body: some View {
        VStack(spacing: 0) {
            topSection
            perforationLine
            bottomSection
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
    }

    // MARK: – Top half

    private var topSection: some View {
        VStack(spacing: 12) {
            // Brand header
            HStack {
                Text("TripKart")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(Color(red: 0.0, green: 0.47, blue: 0.95))
                Spacer()
                VStack(alignment: .trailing, spacing: 1) {
                    Text("BOOKING ID")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundStyle(Color.gray.opacity(0.6))
                        .kerning(1)
                    Text(booking.id)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.black.opacity(0.7))
                }
            }

            // Route
            HStack(alignment: .bottom, spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(booking.origin.code)
                        .font(.system(size: 36, weight: .heavy))
                        .foregroundStyle(Color.black)
                    Text(booking.origin.name)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.gray)
                    Text(booking.outboundResult.departureTime)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.black)
                }
                Spacer()
                VStack(spacing: 4) {
                    Text(booking.outboundResult.duration)
                        .font(.system(size: 10))
                        .foregroundStyle(Color.gray)
                    Image(systemName: booking.outboundResult.pluginType == "flight" ? "airplane" : "bus.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color(red: 0.0, green: 0.47, blue: 0.95))
                    Text(booking.outboundResult.stops == 0 ? "Direct" : "\(booking.outboundResult.stops) Stop")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(booking.outboundResult.stops == 0 ? Color.green : Color.orange)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(booking.destination.code)
                        .font(.system(size: 36, weight: .heavy))
                        .foregroundStyle(Color.black)
                    Text(booking.destination.name)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.gray)
                    Text(booking.outboundResult.arrivalTime)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.black)
                }
            }

            // Operator + date row
            HStack {
                Label(booking.outboundResult.operatorName, systemImage: "person.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.gray)
                if let fn = booking.outboundResult.flightNumber {
                    Text("· \(fn)").font(.system(size: 11)).foregroundStyle(Color.gray)
                }
                if let bt = booking.outboundResult.busType {
                    Text("· \(bt)").font(.system(size: 11)).foregroundStyle(Color.gray)
                }
                Spacer()
                Text(booking.travelDate.formatted(.dateTime.day().month(.wide).year()))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.black.opacity(0.7))
            }
        }
        .padding(20)
    }

    // MARK: – Perforation

    private var perforationLine: some View {
        GeometryReader { geo in
            ZStack {
                HStack {
                    Circle().fill(Color(UIColor.systemGroupedBackground))
                        .frame(width: 20, height: 20).offset(x: -10)
                    Spacer()
                    Circle().fill(Color(UIColor.systemGroupedBackground))
                        .frame(width: 20, height: 20).offset(x: 10)
                }
                Path { path in
                    path.move(to: CGPoint(x: 14, y: geo.size.height / 2))
                    path.addLine(to: CGPoint(x: geo.size.width - 14, y: geo.size.height / 2))
                }
                .stroke(style: StrokeStyle(lineWidth: 1.2, dash: [5, 4]))
                .foregroundStyle(Color.gray.opacity(0.35))
            }
        }
        .frame(height: 20)
    }

    // MARK: – Bottom half

    private var bottomSection: some View {
        VStack(spacing: 12) {
            // Passengers & seats
            VStack(alignment: .leading, spacing: 8) {
                Text("PASSENGERS & SEATS")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(Color.gray.opacity(0.6))
                    .kerning(1)
                ForEach(booking.travellers.indices, id: \.self) { i in
                    HStack {
                        Text(booking.travellers[i].fullName)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.black)
                        Text("· \(booking.travellers[i].gender.rawValue), \(booking.travellers[i].age) yrs")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.gray)
                        Spacer()
                        if booking.outboundSeats.indices.contains(i) {
                            Text(booking.outboundSeats[i])
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color(red: 0.0, green: 0.47, blue: 0.95))
                                .padding(.horizontal, 8).padding(.vertical, 2)
                                .background(Color(red: 0.0, green: 0.47, blue: 0.95).opacity(0.10))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }
                }
            }

            Rectangle().fill(Color.gray.opacity(0.15)).frame(height: 1)

            // Return journey (if any)
            if booking.isRoundTrip, let ret = booking.returnResult {
                VStack(alignment: .leading, spacing: 6) {
                    Text("RETURN JOURNEY")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(Color.orange.opacity(0.8)).kerning(1)
                    HStack {
                        Text("\(booking.destination.code) → \(booking.origin.code)")
                            .font(.system(size: 14, weight: .bold)).foregroundStyle(Color.black)
                        Spacer()
                        Text("\(ret.departureTime) – \(ret.arrivalTime)")
                            .font(.system(size: 12, weight: .medium)).foregroundStyle(Color.black.opacity(0.7))
                    }
                    if !booking.returnSeats.isEmpty {
                        HStack(spacing: 6) {
                            Text("Seats:").font(.system(size: 11)).foregroundStyle(Color.gray)
                            ForEach(booking.returnSeats, id: \.self) { seat in
                                Text(seat).font(.system(size: 11, weight: .bold)).foregroundStyle(Color.orange)
                            }
                        }
                    }
                }
                Rectangle().fill(Color.gray.opacity(0.15)).frame(height: 1)
            }

            // QR code + fare info
            HStack(alignment: .bottom, spacing: 16) {
                VStack(spacing: 4) {
                    QRCodeView(text: booking.id, size: 72)
                        .padding(6)
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.25), lineWidth: 1))
                    Text("Scan at gate")
                        .font(.system(size: 8))
                        .foregroundStyle(Color.gray.opacity(0.6))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("TOTAL PAID")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(Color.gray.opacity(0.6)).kerning(1)
                        Text("₹\(booking.fareBreakdown.total)")
                            .font(.system(size: 22, weight: .heavy))
                            .foregroundStyle(Color(red: 0.0, green: 0.47, blue: 0.95))
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.green).font(.system(size: 14))
                        Text(booking.status.rawValue.uppercased())
                            .font(.system(size: 13, weight: .bold)).foregroundStyle(Color.green)
                    }
                }
            }
        }
        .padding(20)
    }
}

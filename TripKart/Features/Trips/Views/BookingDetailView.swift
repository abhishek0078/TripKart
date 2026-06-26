import SwiftUI
import UIKit

struct BookingDetailView: View {
    let booking: Booking

    @State private var pdfURL: URL?
    @State private var isGenerating = false

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                TicketView(booking: booking)
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.md)

                fareSection
                if booking.isRoundTrip { returnSection }
                travellerSection
            }
            .padding(.bottom, 100)
        }
        .background(Color.App.background)
        .navigationTitle("Booking Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .safeAreaInset(edge: .bottom) { downloadButton }
    }

    // MARK: – Fare breakdown

    private var fareSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            sectionHeader("Fare Breakdown")
            VStack(spacing: 0) {
                if booking.isRoundTrip {
                    fareRow("Outbound Fare", "₹\(booking.fareBreakdown.outboundFare)")
                    Divider()
                    fareRow("Return Fare",   "₹\(booking.fareBreakdown.returnFare)")
                    Divider()
                    fareRow("Base Fare",     "₹\(booking.fareBreakdown.baseFare)", bold: true)
                } else {
                    fareRow("Base Fare",     "₹\(booking.fareBreakdown.baseFare)")
                }
                Divider()
                fareRow(booking.fareBreakdown.taxLabel, "₹\(booking.fareBreakdown.taxes)")
                if booking.fareBreakdown.discount > 0 {
                    Divider()
                    fareRow("Coupon Discount", "-₹\(booking.fareBreakdown.discount)", accent: true)
                }
                Divider()
                fareRow("Total Paid", "₹\(booking.fareBreakdown.total)", bold: true, large: true)
            }
            .background(Color.App.surface)
            .clipShape(RoundedRectangle(cornerRadius: Radius.large))
            .padding(.horizontal, Spacing.md)
        }
    }

    // MARK: – Return journey

    private var returnSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            sectionHeader("Return Journey")
            if let ret = booking.returnResult {
                VStack(spacing: Spacing.sm) {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("\(booking.destination.name) → \(booking.origin.name)")
                                .font(Font.App.bodyMedium)
                                .foregroundStyle(Color.App.textPrimary)
                            if let rd = booking.returnDate {
                                Text(rd.formatted(.dateTime.day().month(.wide).year()))
                                    .font(Font.App.caption)
                                    .foregroundStyle(Color.App.textSecondary)
                            }
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 3) {
                            Text(ret.operatorName)
                                .font(Font.App.caption)
                                .foregroundStyle(Color.App.textSecondary)
                            Text("\(ret.departureTime) → \(ret.arrivalTime)")
                                .font(Font.App.captionMedium)
                                .foregroundStyle(Color.App.textPrimary)
                        }
                    }
                    if !booking.returnSeats.isEmpty {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "chair.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(Color.App.textTertiary)
                            ForEach(Array(zip(booking.travellers.indices, booking.returnSeats)), id: \.0) { i, seat in
                                Text("\(booking.travellers[i].firstName.prefix(1)):\(seat)")
                                    .font(Font.App.small)
                                    .foregroundStyle(Color.App.warning)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.App.warning.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                            Spacer()
                        }
                    }
                }
                .padding(Spacing.md)
                .background(Color.App.surface)
                .clipShape(RoundedRectangle(cornerRadius: Radius.large))
                .padding(.horizontal, Spacing.md)
            }
        }
    }

    // MARK: – Travellers

    private var travellerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            sectionHeader("Passengers")
            ForEach(booking.travellers.indices, id: \.self) { i in
                let outSeat = booking.outboundSeats.indices.contains(i) ? booking.outboundSeats[i] : nil
                let retSeat = booking.returnSeats.indices.contains(i) ? booking.returnSeats[i] : nil
                TravellerCardView(
                    traveller: booking.travellers[i],
                    index: i + 1,
                    outboundSeat: outSeat,
                    returnSeat: retSeat
                )
                .padding(.horizontal, Spacing.md)
            }
        }
    }

    // MARK: – Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(Font.App.headline)
            .foregroundStyle(Color.App.textPrimary)
            .padding(.horizontal, Spacing.md)
    }

    private func fareRow(_ label: String, _ value: String, bold: Bool = false, large: Bool = false, accent: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(large ? Font.App.bodyMedium : Font.App.body)
                .foregroundStyle(accent ? Color.App.success : Color.App.textSecondary)
            Spacer()
            Text(value)
                .font(large ? Font.App.price : (bold ? Font.App.bodyMedium : Font.App.body))
                .foregroundStyle(accent ? Color.App.success : (large ? Color.App.primary : Color.App.textPrimary))
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
    }

    // MARK: – PDF Download

    @ViewBuilder
    private var downloadButton: some View {
        VStack(spacing: 0) {
            Divider()
            Group {
                if let url = pdfURL {
                    ShareLink(
                        item: url,
                        preview: SharePreview(
                            "TripKart Ticket – \(booking.id)",
                            image: Image(systemName: "ticket.fill")
                        )
                    ) {
                        Label("Share Ticket PDF", systemImage: "square.and.arrow.up")
                            .font(Font.App.button)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.md)
                            .background(Color.App.primary)
                            .clipShape(RoundedRectangle(cornerRadius: Radius.medium))
                    }
                } else {
                    PrimaryButton(
                        title: isGenerating ? "Generating…" : "Download Ticket as PDF",
                        isLoading: isGenerating
                    ) {
                        Task { @MainActor in
                            isGenerating = true
                            pdfURL = makePDFURL(for: booking)
                            isGenerating = false
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.md)
            .background(Color.App.background)
        }
    }
}

// MARK: – PDF Generation

@MainActor
private func makePDFURL(for booking: Booking) -> URL? {
    let renderer = ImageRenderer(
        content: TicketView(booking: booking)
            .frame(width: 360)
            .padding()
            .background(Color(UIColor.systemGroupedBackground))
    )
    renderer.scale = 2.0
    guard let image = renderer.uiImage else { return nil }

    let pageW: CGFloat  = 612
    let drawW: CGFloat  = pageW - 60
    let drawH: CGFloat  = (image.size.height / image.size.width) * drawW
    let pageH: CGFloat  = drawH + 80

    let pdfRenderer = UIGraphicsPDFRenderer(
        bounds: CGRect(x: 0, y: 0, width: pageW, height: pageH)
    )
    let data = pdfRenderer.pdfData { ctx in
        ctx.beginPage()
        image.draw(in: CGRect(x: 30, y: 40, width: drawW, height: drawH))
    }

    let url = FileManager.default.temporaryDirectory
        .appendingPathComponent("TripKart-\(booking.id).pdf")
    try? data.write(to: url)
    return url
}

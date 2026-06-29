import SwiftUI

struct PaymentSuccessView: View {
    @Environment(BookingCoordinator.self)  private var coordinator
    @Environment(DependencyContainer.self) private var container

    let booking: Booking

    @State private var animate = false
    @State private var pdfURL: URL?
    @State private var isGeneratingPDF = false
    @State private var showTicketSheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                Spacer(minLength: Spacing.xl)

                // Animated badge
                ZStack {
                    Circle()
                        .fill(Color.App.success.opacity(0.12))
                        .frame(width: 120, height: 120)
                        .scaleEffect(animate ? 1.0 : 0.5)
                    Circle()
                        .fill(Color.App.success.opacity(0.20))
                        .frame(width: 90, height: 90)
                    Image(systemName: "checkmark")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(Color.App.success)
                        .scaleEffect(animate ? 1.0 : 0.3)
                        .opacity(animate ? 1 : 0)
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.65), value: animate)

                VStack(spacing: Spacing.xs) {
                    Text("Booking Confirmed!")
                        .font(Font.App.display)
                        .foregroundStyle(Color.App.textPrimary)
                    Text("Your trip has been booked successfully.")
                        .font(Font.App.body)
                        .foregroundStyle(Color.App.textSecondary)
                        .multilineTextAlignment(.center)
                }

                // Booking summary card
                VStack(spacing: 0) {
                    detailRow("Booking ID",     booking.id)
                    Divider()
                    detailRow("Amount Paid",    "₹\(booking.fareBreakdown.total)")
                    Divider()
                    detailRow("Date",           booking.travelDate.formatted(.dateTime.day().month(.abbreviated).year()))
                    Divider()
                    detailRow("Status", "Confirmed", valueColor: Color.App.success)
                }
                .background(Color.App.surface)
                .clipShape(RoundedRectangle(cornerRadius: Radius.large))
                .padding(.horizontal, Spacing.md)

                // Inline ticket preview
                TicketView(booking: booking)
                    .padding(.horizontal, Spacing.md)

                Spacer(minLength: Spacing.xl)
            }
            .padding(.vertical, Spacing.md)
        }
        .background(Color.App.background)
        .navigationTitle("Booking Confirmed")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            animate = true
            Task {
                await container.notificationEngine.checkPermission()
                if !container.notificationEngine.permissionGranted {
                    await container.notificationEngine.requestPermission()
                }
                await container.notificationEngine.handleBookingConfirmed(booking)
            }
        }
        .safeAreaInset(edge: .bottom) { bottomButtons }
        .sheet(isPresented: $showTicketSheet) {
            NavigationStack {
                BookingDetailView(booking: booking)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") { showTicketSheet = false }
                        }
                    }
            }
        }
    }

    private func detailRow(_ label: String, _ value: String, valueColor: Color = Color.App.textPrimary) -> some View {
        HStack {
            Text(label)
                .font(Font.App.body)
                .foregroundStyle(Color.App.textSecondary)
            Spacer()
            Text(value)
                .font(Font.App.captionMedium)
                .foregroundStyle(valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
    }

    private var bottomButtons: some View {
        VStack(spacing: Spacing.sm) {
            Divider()

            // Download / share ticket button
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
                            .foregroundStyle(Color.App.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.md)
                            .background(Color.App.primaryLight.opacity(0.10))
                            .clipShape(RoundedRectangle(cornerRadius: Radius.medium))
                            .overlay(
                                RoundedRectangle(cornerRadius: Radius.medium)
                                    .stroke(Color.App.primary.opacity(0.3), lineWidth: 1)
                            )
                    }
                } else {
                    Button {
                        Task { @MainActor in
                            isGeneratingPDF = true
                            pdfURL = makeTicketPDFURL(for: booking)
                            isGeneratingPDF = false
                        }
                    } label: {
                        HStack(spacing: Spacing.sm) {
                            if isGeneratingPDF {
                                ProgressView().tint(Color.App.primary)
                            } else {
                                Image(systemName: "arrow.down.circle.fill")
                            }
                            Text(isGeneratingPDF ? "Generating PDF…" : "Download Ticket as PDF")
                                .font(Font.App.button)
                        }
                        .foregroundStyle(Color.App.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.md)
                        .background(Color.App.primaryLight.opacity(0.10))
                        .clipShape(RoundedRectangle(cornerRadius: Radius.medium))
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.medium)
                                .stroke(Color.App.primary.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .disabled(isGeneratingPDF)
                }
            }
            .padding(.horizontal, Spacing.md)

            // Done button
            PrimaryButton(title: "Done", isLoading: false) {
                coordinator.dismiss()
            }
            .padding(.horizontal, Spacing.md)
            .padding(.bottom, Spacing.sm)
        }
        .background(Color.App.background)
    }
}

// MARK: – PDF Generator

@MainActor
private func makeTicketPDFURL(for booking: Booking) -> URL? {
    let renderer = ImageRenderer(
        content: TicketView(booking: booking)
            .frame(width: 360)
            .padding()
            .background(Color(UIColor.systemGroupedBackground))
    )
    renderer.scale = 2.0
    guard let image = renderer.uiImage else { return nil }

    let pageW: CGFloat = 612
    let drawW: CGFloat = pageW - 60
    let drawH: CGFloat = (image.size.height / image.size.width) * drawW
    let pageH: CGFloat = drawH + 80

    let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageW, height: pageH))
    let data = pdfRenderer.pdfData { ctx in
        ctx.beginPage()
        image.draw(in: CGRect(x: 30, y: 40, width: drawW, height: drawH))
    }

    let url = FileManager.default.temporaryDirectory
        .appendingPathComponent("TripKart-\(booking.id).pdf")
    try? data.write(to: url)
    return url
}

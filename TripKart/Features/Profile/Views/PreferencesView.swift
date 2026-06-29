import SwiftUI

struct PreferencesView: View {
    @AppStorage("pref.bookingUpdates") private var bookingUpdates = true
    @AppStorage("pref.offersPromos")   private var offersPromos   = true
    @AppStorage("pref.priceAlerts")    private var priceAlerts    = false
    @AppStorage("pref.tripReminders")  private var tripReminders  = true

    var body: some View {
        Form {
            Section("Notifications") {
                Toggle("Booking Updates", isOn: $bookingUpdates)
                Toggle("Trip Reminders", isOn: $tripReminders)
                Toggle("Price Alerts",   isOn: $priceAlerts)
                Toggle("Offers & Promotions", isOn: $offersPromos)
            }
            .tint(Color.App.primary)

            Section("Language & Region") {
                HStack {
                    Text("Language")
                        .foregroundStyle(Color.App.textPrimary)
                    Spacer()
                    Text("English")
                        .foregroundStyle(Color.App.textTertiary)
                }
                HStack {
                    Text("Currency")
                        .foregroundStyle(Color.App.textPrimary)
                    Spacer()
                    Text("₹ INR")
                        .foregroundStyle(Color.App.textTertiary)
                }
            }
        }
        .navigationTitle("Preferences")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
}

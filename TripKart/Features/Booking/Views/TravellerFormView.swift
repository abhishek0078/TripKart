import SwiftUI

private struct TravellerDraft {
    var firstName      = ""
    var lastName       = ""
    var age            = ""
    var gender         = Traveller.Gender.male
    var documentNumber = ""

    func firstNameError() -> String? {
        firstName.trimmingCharacters(in: .whitespaces).isEmpty ? "First name is required" : nil
    }
    func lastNameError() -> String? {
        lastName.trimmingCharacters(in: .whitespaces).isEmpty ? "Last name is required" : nil
    }
    func ageError() -> String? {
        let v = age.trimmingCharacters(in: .whitespaces)
        if v.isEmpty { return "Age is required" }
        guard let a = Int(v), a >= 1, a <= 120 else { return "Enter a valid age (1–120)" }
        return nil
    }
    func documentError() -> String? {
        documentNumber.trimmingCharacters(in: .whitespaces).isEmpty ? "Document number is required" : nil
    }

    var isValid: Bool {
        firstNameError() == nil && lastNameError() == nil &&
        ageError() == nil && documentError() == nil
    }

    func toTraveller() -> Traveller {
        Traveller(
            id: UUID().uuidString,
            firstName: firstName.trimmingCharacters(in: .whitespaces),
            lastName: lastName.trimmingCharacters(in: .whitespaces),
            age: Int(age) ?? 0,
            gender: gender,
            documentType: "Aadhaar",
            documentNumber: documentNumber.trimmingCharacters(in: .whitespaces)
        )
    }
}

struct TravellerFormView: View {
    @Environment(BookingCoordinator.self) private var coordinator
    @Environment(BookingEngine.self) private var bookingEngine

    @State private var drafts: [TravellerDraft] = []
    @State private var didAttemptSubmit = false

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                ForEach(drafts.indices, id: \.self) { i in
                    travellerSection(index: i)
                }
            }
            .padding(Spacing.md)
        }
        .background(Color.App.background)
        .navigationTitle("Traveller Details")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { setupDrafts() }
        .safeAreaInset(edge: .bottom) { continueButton }
    }

    private func travellerSection(index: Int) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Passenger \(index + 1)")
                    .font(Font.App.headline)
                    .foregroundStyle(Color.App.textPrimary)
                Spacer()
                Text("of \(drafts.count)")
                    .font(Font.App.caption)
                    .foregroundStyle(Color.App.textTertiary)
            }

            FloatingLabelTextField(
                label: "First Name",
                isRequired: true,
                text: Binding(get: { drafts[index].firstName }, set: { drafts[index].firstName = $0 }),
                error: didAttemptSubmit ? drafts[index].firstNameError() : nil
            )

            FloatingLabelTextField(
                label: "Last Name",
                isRequired: true,
                text: Binding(get: { drafts[index].lastName }, set: { drafts[index].lastName = $0 }),
                error: didAttemptSubmit ? drafts[index].lastNameError() : nil
            )

            FloatingLabelTextField(
                label: "Age",
                isRequired: true,
                text: Binding(get: { drafts[index].age }, set: { drafts[index].age = $0 }),
                keyboardType: .numberPad,
                error: didAttemptSubmit ? drafts[index].ageError() : nil
            )

            genderPicker(index: index)

            FloatingLabelTextField(
                label: "Aadhaar / Document No.",
                isRequired: true,
                text: Binding(get: { drafts[index].documentNumber }, set: { drafts[index].documentNumber = $0 }),
                error: didAttemptSubmit ? drafts[index].documentError() : nil
            )
        }
        .padding(Spacing.md)
        .background(Color.App.surface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.large))
    }

    private func genderPicker(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Gender")
                    .font(Font.App.small)
                    .foregroundStyle(Color.App.textSecondary)
                Spacer()
            }
            HStack(spacing: Spacing.sm) {
                ForEach(Traveller.Gender.allCases, id: \.self) { g in
                    Button {
                        drafts[index].gender = g
                    } label: {
                        Text(g.rawValue)
                            .font(Font.App.captionMedium)
                            .foregroundStyle(drafts[index].gender == g ? .white : Color.App.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.sm)
                            .background(drafts[index].gender == g ? Color.App.primary : Color.App.background)
                            .clipShape(RoundedRectangle(cornerRadius: Radius.medium))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: Radius.medium + 4)
                    .stroke(Color.App.border, lineWidth: 1)
            )
        }
    }

    private var continueButton: some View {
        VStack(spacing: 0) {
            Divider()
            PrimaryButton(title: "Continue", isLoading: false) {
                didAttemptSubmit = true
                if drafts.allSatisfy(\.isValid) {
                    bookingEngine.travellers = drafts.map { $0.toTraveller() }
                    coordinator.navigateToOutboundSeats()
                }
            }
            .padding(Spacing.md)
            .background(Color.App.background)
        }
    }

    private func setupDrafts() {
        guard drafts.isEmpty else { return }
        drafts = (0..<bookingEngine.query.passengers).map { _ in TravellerDraft() }
    }
}

import SwiftUI

private let documentTypes = ["Aadhaar", "Passport", "PAN Card", "Driving License", "Voter ID"]

struct AddEditTravellerView: View {
    @Environment(\.dismiss) private var dismiss

    let repository: any TravellerRepository
    var existing: Traveller?

    @State private var firstName    = ""
    @State private var lastName     = ""
    @State private var age          = ""
    @State private var gender       = Traveller.Gender.male
    @State private var documentType = documentTypes[0]
    @State private var documentNumber = ""
    @State private var didAttempt   = false
    @State private var isSaving     = false
    @State private var showDeleteAlert = false

    var isEditing: Bool { existing != nil }

    var body: some View {
        Form {
            Section("Name") {
                FloatingLabelTextField(label: "First Name", isRequired: true, text: $firstName,
                    error: fieldError(didAttempt && firstName.trimmingCharacters(in: .whitespaces).isEmpty, "First name is required"))
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                FloatingLabelTextField(label: "Last Name", isRequired: true, text: $lastName,
                    error: fieldError(didAttempt && lastName.trimmingCharacters(in: .whitespaces).isEmpty, "Last name is required"))
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }

            Section("Details") {
                FloatingLabelTextField(label: "Age", isRequired: true, text: $age,
                    keyboardType: .numberPad,
                    error: ageError)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                // Gender picker
                HStack {
                    Text("Gender").foregroundStyle(Color.App.textSecondary)
                    Spacer()
                    Picker("Gender", selection: $gender) {
                        ForEach(Traveller.Gender.allCases, id: \.self) { g in
                            Text(g.rawValue).tag(g)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 200)
                }
            }

            Section("Identity Document") {
                Picker("Type", selection: $documentType) {
                    ForEach(documentTypes, id: \.self) { Text($0).tag($0) }
                }

                FloatingLabelTextField(label: "Document Number", isRequired: true, text: $documentNumber,
                    error: fieldError(didAttempt && documentNumber.trimmingCharacters(in: .whitespaces).isEmpty, "Document number is required"))
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }

            if isEditing {
                Section {
                    Button(role: .destructive) { showDeleteAlert = true } label: {
                        Label("Delete Traveller", systemImage: "trash")
                            .foregroundStyle(Color.App.error)
                    }
                }
            }
        }
        .navigationTitle(isEditing ? "Edit Traveller" : "Add Traveller")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { trySave() }
                    .disabled(isSaving)
            }
        }
        .confirmationDialog("Delete this traveller?", isPresented: $showDeleteAlert, titleVisibility: .visible) {
            Button("Delete", role: .destructive) { Task { await deleteTraveller() } }
        }
        .onAppear { populateIfEditing() }
    }

    // MARK: – Validation helpers

    private var ageError: String? {
        guard didAttempt else { return nil }
        let v = age.trimmingCharacters(in: .whitespaces)
        if v.isEmpty { return "Age is required" }
        guard let a = Int(v), a >= 1, a <= 120 else { return "Enter a valid age (1–120)" }
        return nil
    }

    private func fieldError(_ condition: Bool, _ msg: String) -> String? {
        condition ? msg : nil
    }

    private var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty &&
        ageError == nil && !age.isEmpty &&
        !documentNumber.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: – Actions

    private func trySave() {
        didAttempt = true
        guard isFormValid else { return }
        let t = Traveller(
            id: existing?.id ?? UUID().uuidString,
            firstName: firstName.trimmingCharacters(in: .whitespaces),
            lastName: lastName.trimmingCharacters(in: .whitespaces),
            age: Int(age) ?? 0,
            gender: gender,
            documentType: documentType,
            documentNumber: documentNumber.trimmingCharacters(in: .whitespaces)
        )
        isSaving = true
        Task {
            try? await repository.save(t)
            await MainActor.run {
                isSaving = false
                dismiss()
            }
        }
    }

    private func deleteTraveller() async {
        guard let id = existing?.id else { return }
        try? await repository.delete(id: id)
        await MainActor.run { dismiss() }
    }

    private func populateIfEditing() {
        guard let t = existing else { return }
        firstName     = t.firstName
        lastName      = t.lastName
        age           = "\(t.age)"
        gender        = t.gender
        documentType  = t.documentType
        documentNumber = t.documentNumber
    }
}

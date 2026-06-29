import SwiftUI

struct PersonalInfoView: View {
    @Environment(SessionEngine.self) private var sessionEngine
    @Environment(\.dismiss) private var dismiss

    @State private var name  = ""
    @State private var email = ""
    @State private var isSaving = false
    @State private var didAttemptSave = false

    var body: some View {
        Form {
            Section("Contact") {
                HStack {
                    Text("Phone")
                        .foregroundStyle(Color.App.textSecondary)
                    Spacer()
                    Text(sessionEngine.currentUser.map { "+91 \($0.phone)" } ?? "—")
                        .foregroundStyle(Color.App.textTertiary)
                }

                FloatingLabelTextField(
                    label: "Full Name",
                    isRequired: true,
                    text: $name,
                    error: didAttemptSave && name.trimmingCharacters(in: .whitespaces).isEmpty
                        ? "Name is required" : nil
                )
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                FloatingLabelTextField(
                    label: "Email (optional)",
                    text: $email,
                    keyboardType: .emailAddress,
                    error: didAttemptSave && !email.isEmpty && !email.contains("@")
                        ? "Enter a valid email address" : nil
                )
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
        }
        .navigationTitle("Personal Info")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { trySave() }
                    .font(Font.App.bodyMedium)
                    .disabled(isSaving)
            }
        }
        .onAppear {
            name  = sessionEngine.currentUser?.name ?? ""
            email = sessionEngine.currentUser?.email ?? ""
        }
    }

    private func trySave() {
        didAttemptSave = true
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        if !email.isEmpty && !email.contains("@") { return }
        isSaving = true
        sessionEngine.updateProfile(name: trimmed, email: email.isEmpty ? nil : email)
        isSaving = false
        dismiss()
    }
}

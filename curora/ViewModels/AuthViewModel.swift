import SwiftUI
import FirebaseAuth

@Observable class AuthViewModel {
    var user: AppUser?
    var isSignedIn: Bool { user != nil }
    var authListener: AuthStateDidChangeListenerHandle?

    init() {
        listenToAuthState()
    }

    private func listenToAuthState() {
        authListener = Auth.auth().addStateDidChangeListener { _, firebaseUser in
            if let firebaseUser = firebaseUser {
                self.user = AppUser(
                    id: firebaseUser.uid,
                    email: firebaseUser.email ?? "",
                    displayName: firebaseUser.displayName ?? "",
                    createdAt: Date()
                )
            } else {
                self.user = nil
            }
        }
    }

    func signUp(email: String, password: String, name: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        try await result.user.createProfileChangeRequest().commitChanges()
    }

    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }
}

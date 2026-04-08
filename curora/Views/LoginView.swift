import SwiftUI

struct LoginView: View {
    @Environment(AuthViewModel.self) var auth

    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var isSigningUp = false
    @State private var isLoading = false
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            Color.curora.deep.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {

                    // Logo
                    VStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.curora.terra)
                                .frame(width: 64, height: 64)
                                .shadow(color: Color.curora.terra.opacity(0.5), radius: 20, y: 8)
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 28, weight: .light))
                                .foregroundColor(.white)
                        }
                        Text("curora")
                            .font(.custom("Georgia-Italic", size: 40))
                            .foregroundColor(Color.curora.cream)
                        Text("your saved spots, finally home")
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(Color.curora.cream.opacity(0.4))
                            .tracking(1.2)
                    }
                    .padding(.top, 80)
                    .padding(.bottom, 56)

                    // Form
                    VStack(spacing: 12) {
                        if isSigningUp {
                            TextField("Your name", text: $name)
                                .font(.system(size: 15))
                                .foregroundColor(Color.curora.deep)
                                .padding()
                                .frame(height: 52)
                                .background(Color.curora.cream)
                                .cornerRadius(14)
                        }

                        TextField("Email address", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .font(.system(size: 15))
                            .foregroundColor(Color.curora.deep)
                            .padding()
                            .frame(height: 52)
                            .background(Color.curora.cream)
                            .cornerRadius(14)

                        SecureField("Password", text: $password)
                            .font(.system(size: 15))
                            .foregroundColor(Color.curora.deep)
                            .padding()
                            .frame(height: 52)
                            .background(Color.curora.cream)
                            .cornerRadius(14)

                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .font(.system(size: 12))
                                .foregroundColor(Color.curora.terra)
                                .multilineTextAlignment(.center)
                        }

                        Button(action: handleAuth) {
                            ZStack {
                                if isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text(isSigningUp ? "Create Account" : "Sign In")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.curora.terra)
                            .cornerRadius(14)
                        }
                        .disabled(isLoading)

                        Button(action: {
                            withAnimation { isSigningUp.toggle(); errorMessage = "" }
                        }) {
                            Text(isSigningUp
                                 ? "Already have an account? Sign in"
                                 : "New to Curora? Create an account")
                                .font(.system(size: 13, weight: .light))
                                .foregroundColor(Color.curora.cream.opacity(0.45))
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 60)
                }
            }
        }
    }

    func handleAuth() {
        isLoading = true
        errorMessage = ""
        Task {
            do {
                if isSigningUp {
                    try await auth.signUp(email: email, password: password, name: name)
                } else {
                    try await auth.signIn(email: email, password: password)
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

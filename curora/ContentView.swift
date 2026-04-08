// ContentView.swift — Curora
// Root router: Splash → Auth → Onboarding → Main app.

import SwiftUI

struct ContentView: View {
    @Environment(AuthViewModel.self)   var auth
    @Environment(PlacesViewModel.self) var placesVM

    @AppStorage("hasSeenSplash")           private var hasSeenSplash           = false
    @AppStorage("hasCompletedOnboarding")  private var hasCompletedOnboarding  = false
    @AppStorage("hasSeenConnectAccounts")  private var hasSeenConnectAccounts  = false

    var body: some View {
        Group {
            if !hasSeenSplash {
                // 1. First-ever launch: show splash / onboarding slides
                SplashView()

            } else if !auth.isSignedIn {
                // 2. Not signed in: show login / sign-up
                LoginView()

            } else if !hasSeenConnectAccounts {
                // 3. First sign-in: connect accounts screen
                ConnectAccountsView()
                    .onAppear { hasSeenConnectAccounts = true }

            } else if !hasCompletedOnboarding {
                // 4. Importing / scanning animation
                ImportingView()

            } else {
                // 5. Main app
                MainTabView()
                    .onAppear {
                        if let userId = auth.user?.id {
                            placesVM.startListening(userId: userId)
                        }
                    }
                    .onDisappear {
                        placesVM.stopListening()
                    }
            }
        }
        .animation(.easeInOut(duration: 0.35), value: auth.isSignedIn)
        .animation(.easeInOut(duration: 0.35), value: hasSeenSplash)
        .animation(.easeInOut(duration: 0.35), value: hasCompletedOnboarding)
    }
}

// curoraApp.swift — Curora
// App entry point. Configures Firebase and injects global view models.

import SwiftUI
import Firebase

@main
struct curoraApp: App {
    let auth:   AuthViewModel
    let places: PlacesViewModel

    init() {
        FirebaseApp.configure()
        auth   = AuthViewModel()
        places = PlacesViewModel()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(auth)
                .environment(places)
        }
    }
}

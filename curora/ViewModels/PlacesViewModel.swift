// PlacesViewModel.swift — Curora
// Manages all place data: real-time Firestore sync, CRUD, search, grouping.

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import UIKit

@Observable
class PlacesViewModel {

    // MARK: - State
    var places:     [Place]  = []
    var isLoading:  Bool     = false
    var errorMsg:   String   = ""

    private var listener: ListenerRegistration?
    private var currentUserId: String?

    // MARK: - Derived data
    var cities: [String] {
        Array(Set(places.map { $0.city })).sorted()
    }

    var boards: [(city: String, places: [Place])] {
        cities.map { city in
            (city: city, places: places.filter { $0.city == city })
        }
        .sorted { $0.places.count > $1.places.count }
    }

    var visitedCount:  Int { places.filter { $0.visited }.count }
    var unvisitedCount: Int { places.filter { !$0.visited }.count }
    var totalCount:    Int { places.count }

    // MARK: - Start listening
    func startListening(userId: String) {
        guard userId != currentUserId else { return }
        stopListening()
        currentUserId = userId
        isLoading     = true

        listener = FirestoreService.listenToPlaces(userId: userId) { [self] fetched in
            self.places    = fetched
            self.isLoading = false
        }
    }

    // MARK: - Stop listening
    func stopListening() {
        listener?.remove()
        listener       = nil
        currentUserId  = nil
        places         = []
    }

    // MARK: - Search
    func search(_ query: String) -> [Place] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return places }
        let q = query.lowercased()
        return places.filter {
            $0.name.lowercased().contains(q)     ||
            $0.city.lowercased().contains(q)     ||
            $0.category.lowercased().contains(q) ||
            $0.vibe.lowercased().contains(q)     ||
            $0.notes.lowercased().contains(q)
        }
    }

    // MARK: - Filter by city / category
    func places(in city: String) -> [Place]  { places.filter { $0.city == city } }
    func places(category: String) -> [Place] { places.filter { $0.category == category } }

    // MARK: - Add place (with optional image upload)
    func addPlace(_ place: Place, image: UIImage?, userId: String) async {
        isLoading = true
        do {
            let placeId = UUID().uuidString
            var newPlace = place
            newPlace.id     = placeId
            newPlace.userId = userId

            // Upload image first if provided
            if let img = image {
                let url = try await StorageService.uploadPlaceImage(img, userId: userId, placeId: placeId)
                newPlace.imageURL = url
            }

            try await FirestoreService.addPlace(newPlace, userId: userId)
            Haptics.success()
        } catch {
            errorMsg = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Delete place
    func deletePlace(_ place: Place, userId: String) async {
        guard !place.id.isEmpty else { return }
        do {
            try await FirestoreService.deletePlace(id: place.id, userId: userId)
            if !place.imageURL.isEmpty {
                try? await StorageService.deletePlaceImage(userId: userId, placeId: place.id)
            }
        } catch {
            errorMsg = error.localizedDescription
        }
    }

    // MARK: - Toggle visited
    func toggleVisited(_ place: Place, userId: String) async {
        do {
            try await FirestoreService.markVisited(id: place.id, userId: userId, visited: !place.visited)
        } catch {
            errorMsg = error.localizedDescription
        }
    }
}

// FirestoreService.swift — Curora
// All Firestore read/write operations for places.

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct FirestoreService {

    private static var db: Firestore { Firestore.firestore() }

    // MARK: - Collection reference
    static func placesRef(for userId: String) -> CollectionReference {
        db.collection("users").document(userId).collection("places")
    }

    // MARK: - Fetch all places (real-time listener)
    /// Returns a listener handle. Cancel it with `listener.remove()`.
    static func listenToPlaces(
        userId: String,
        onChange: @escaping ([Place]) -> Void
    ) -> ListenerRegistration {
        placesRef(for: userId)
            .order(by: "savedAt", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let docs = snapshot?.documents else { return }
                let places = docs.compactMap { doc -> Place? in
                    var place = try? doc.data(as: Place.self)
                    place?.id = doc.documentID
                    return place
                }
                DispatchQueue.main.async { onChange(places) }
            }
    }

    // MARK: - Add place
    static func addPlace(_ place: Place, userId: String) async throws {
        var p = place
        p.userId = userId
        let ref = placesRef(for: userId).document()
        try ref.setData(from: p)
    }

    // MARK: - Update place
    static func updatePlace(_ place: Place, userId: String) async throws {
        guard !place.id.isEmpty else { return }
        let ref = placesRef(for: userId).document(place.id)
        try ref.setData(from: place, merge: true)
    }

    // MARK: - Delete place
    static func deletePlace(id: String, userId: String) async throws {
        try await placesRef(for: userId).document(id).delete()
    }

    // MARK: - Mark visited
    static func markVisited(id: String, userId: String, visited: Bool) async throws {
        try await placesRef(for: userId).document(id).updateData(["visited": visited])
    }

    // MARK: - Update image URL
    static func updateImageURL(id: String, userId: String, url: String) async throws {
        try await placesRef(for: userId).document(id).updateData(["imageURL": url])
    }
}

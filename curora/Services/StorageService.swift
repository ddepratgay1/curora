// StorageService.swift — Curora
// Upload and retrieve place images via Firebase Storage.

import Foundation
import FirebaseStorage
import UIKit

struct StorageService {

    private static var storage: Storage { Storage.storage() }

    // MARK: - Upload place image
    /// Compresses image, uploads to Storage, returns the download URL string.
    static func uploadPlaceImage(
        _ image: UIImage,
        userId: String,
        placeId: String
    ) async throws -> String {
        guard let data = image.jpegData(compressionQuality: 0.75) else {
            throw StorageError.compressionFailed
        }
        let path = "users/\(userId)/places/\(placeId).jpg"
        let ref  = storage.reference().child(path)
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"

        _ = try await ref.putDataAsync(data, metadata: meta)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }

    // MARK: - Delete place image
    static func deletePlaceImage(userId: String, placeId: String) async throws {
        let path = "users/\(userId)/places/\(placeId).jpg"
        let ref  = storage.reference().child(path)
        try await ref.delete()
    }

    // MARK: - Errors
    enum StorageError: LocalizedError {
        case compressionFailed
        var errorDescription: String? { "Could not compress image for upload." }
    }
}

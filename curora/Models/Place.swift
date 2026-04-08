// Place.swift — Curora data model
// Uses String types for category/vibe so existing mock data still compiles.

import Foundation

struct Place: Identifiable, Codable, Hashable {
    var id:        String
    var name:      String
    var city:      String
    var country:   String  = ""
    var category:  String               // e.g. "Restaurant", "Café"
    var vibe:      String               // e.g. "Date Night", "Brunch"
    var sourceURL: String  = ""
    var imageURL:  String  = ""         // Firebase Storage download URL
    var notes:     String  = ""
    var visited:   Bool    = false
    var rating:    Double? = nil
    var savedAt:   Date    = Date()
    var userId:    String  = ""

    // Helpers
    var categoryEmoji: String {
        switch category {
        case "Restaurant": return "🍽"
        case "Café":       return "☕️"
        case "Bar":        return "🍸"
        case "Hotel":      return "🏨"
        case "Activity":   return "🎭"
        case "Shopping":   return "🛍"
        case "Wellness":   return "🌿"
        default:           return "📍"
        }
    }

    var categoryColor: String {
        switch category {
        case "Restaurant": return "terra"
        case "Café":       return "sage"
        case "Hotel":      return "gold"
        case "Bar":        return "rose"
        case "Activity":   return "blush"
        default:           return "muted"
        }
    }

    var sourceDisplay: String {
        let l = sourceURL.lowercased()
        if l.contains("instagram") { return "Instagram" }
        if l.contains("tiktok")    { return "TikTok" }
        if l.contains("google")    { return "Google Maps" }
        if sourceURL.isEmpty       { return "Manual Entry" }
        return "Link"
    }

    var sourceEmoji: String {
        switch sourceDisplay {
        case "Instagram":    return "📸"
        case "TikTok":       return "▶️"
        case "Google Maps":  return "🗺"
        case "Manual Entry": return "✏️"
        default:             return "🔗"
        }
    }
}

// MARK: - Category / Vibe options
extension Place {
    static let categories = ["Restaurant", "Café", "Bar", "Hotel", "Activity", "Shopping", "Wellness", "Other"]
    static let vibes = ["Date Night", "Girls Night", "Brunch", "Work From", "Late Night",
                        "Tourist Must", "Hidden Gem", "Special Occasion", "Casual", "Luxury", "Explore"]
}

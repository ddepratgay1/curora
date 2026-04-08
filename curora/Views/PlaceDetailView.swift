import SwiftUI

struct PlaceDetailView: View {
    let place: Place
    @State private var isVisited: Bool
    @Environment(\.dismiss) private var dismiss

    init(place: Place) {
        self.place = place
        _isVisited = State(initialValue: place.visited)
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.curora.cream.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // Hero
                    ZStack(alignment: .bottom) {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [heroColor.opacity(0.95), heroColor.opacity(0.65)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 300)

                        Text(categoryEmoji(place.category))
                            .font(.system(size: 72))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 60)

                        LinearGradient(
                            colors: [.clear, Color.curora.cream],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                        .frame(height: 120)

                        VStack {
                            HStack {
                                Button(action: { dismiss() }) {
                                    ZStack {
                                        Circle()
                                            .fill(.white.opacity(0.2))
                                            .frame(width: 36, height: 36)

                                        Image(systemName: "chevron.left")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(.leading, 20)
                                .padding(.top, 60)

                                Spacer()
                            }

                            Spacer()
                        }
                        .frame(height: 300)
                    }

                    // Content
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(place.name)
                                .font(.custom("Georgia", size: 28))
                                .foregroundColor(Color.curora.deep)

                            HStack(spacing: 8) {
                                TagPill(text: place.category, icon: categoryEmoji(place.category))
                                TagPill(text: place.vibe, icon: "✨")
                                TagPill(text: place.city, icon: "📍")
                            }
                        }

                        Divider()
                            .background(Color.curora.muted)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("YOUR NOTE")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color.curora.muted)
                                .tracking(1.5)

                            Text("“\(place.notes)”")
                                .font(.system(size: 15, weight: .light))
                                .foregroundColor(Color.curora.deep)
                                .italic()
                                .lineSpacing(4)
                        }

                        Divider()
                            .background(Color.curora.muted)

                        Link(destination: sourceLink) {
                            HStack(spacing: 10) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.curora.blush)
                                        .frame(width: 36, height: 36)

                                    Text(sourceEmoji(place.sourceURL))
                                        .font(.system(size: 16))
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Saved from \(sourceName(place.sourceURL))")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(Color.curora.deep)

                                    Text("Tap to view original link")
                                        .font(.system(size: 11, weight: .light))
                                        .foregroundColor(Color.curora.muted)
                                }

                                Spacer()

                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.curora.terra)
                            }
                            .padding(14)
                            .background(Color.curora.cream)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.curora.muted, lineWidth: 1)
                            )
                        }

                        Button(action: {
                            withAnimation {
                                isVisited.toggle()
                            }
                        }) {
                            HStack {
                                Image(systemName: isVisited ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 18))

                                Text(isVisited ? "Visited! ✓" : "Mark as Visited")
                                    .font(.system(size: 15, weight: .medium))
                            }
                            .foregroundColor(isVisited ? Color.curora.sage : .white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(isVisited ? Color.curora.sage.opacity(0.2) : Color.curora.terra)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(isVisited ? Color.curora.sage : Color.clear, lineWidth: 1)
                            )
                        }
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                }
            }
        }
        .navigationBarHidden(true)
    }

    var heroColor: Color {
        switch place.category {
        case "Restaurant":
            return Color.curora.terra
        case "Café":
            return Color.curora.sage
        case "Hotel":
            return Color.curora.gold
        case "Activity":
            return Color.curora.blush
        default:
            return Color.curora.muted
        }
    }

    var sourceLink: URL {
        URL(string: place.sourceURL) ?? URL(string: "https://www.google.com")!
    }

    func categoryEmoji(_ category: String) -> String {
        switch category {
        case "Restaurant":
            return "🍽"
        case "Café":
            return "☕"
        case "Hotel":
            return "🏨"
        case "Activity":
            return "🗺"
        default:
            return "📍"
        }
    }

    func sourceEmoji(_ source: String) -> String {
        let lower = source.lowercased()

        if lower.contains("instagram") {
            return "📸"
        } else if lower.contains("tiktok") {
            return "▶️"
        } else if lower.contains("google") || lower.contains("maps") {
            return "🗺"
        } else {
            return "🔗"
        }
    }

    func sourceName(_ source: String) -> String {
        let lower = source.lowercased()

        if lower.contains("instagram") {
            return "Instagram"
        } else if lower.contains("tiktok") {
            return "TikTok"
        } else if lower.contains("google") || lower.contains("maps") {
            return "Google Maps"
        } else {
            return "Original Link"
        }
    }
}

struct TagPill: View {
    let text: String
    let icon: String

    var body: some View {
        HStack(spacing: 4) {
            Text(icon)
                .font(.system(size: 11))

            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color.curora.muted)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.curora.cream)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.curora.muted, lineWidth: 1)
        )
    }
}

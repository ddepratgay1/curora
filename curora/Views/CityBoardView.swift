import SwiftUI

struct CityBoardView: View {
    let board: Board
    let places: [Place]

    @State private var selectedCategory = "All"
    @State private var selectedPlace: Place? = nil
    @Environment(\.dismiss) private var dismiss

    var categories: [String] {
        ["All"] + Array(Set(places.map { $0.category })).sorted()
    }

    var filteredPlaces: [Place] {
        if selectedCategory == "All" {
            return places
        } else {
            return places.filter { $0.category == selectedCategory }
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.curora.cream.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                
                // Header
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(Color.curora.terra)
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)

                VStack(alignment: .leading, spacing: 4) {
                    Text(board.title)
                        .font(.custom("Georgia", size: 28))
                        .foregroundColor(Color.curora.deep)

                    Text("\(filteredPlaces.count) places")
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(Color.curora.muted)
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 16)

                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(categories, id: \.self) { cat in
                            Button(action: { selectedCategory = cat }) {
                                Text(cat)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(selectedCategory == cat ? Color.curora.cream : Color.curora.muted)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(selectedCategory == cat ? Color.curora.deep : Color.clear)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(
                                                selectedCategory == cat ? Color.clear : Color.curora.muted,
                                                lineWidth: 1
                                            )
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 16)

                // Grid
                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 10),
                            GridItem(.flexible(), spacing: 10)
                        ],
                        spacing: 10
                    ) {
                        ForEach(filteredPlaces) { place in
                            PlaceCard(place: place)
                                .onTapGesture {
                                    selectedPlace = place
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(item: $selectedPlace) { place in
            PlaceDetailView(place: place)
        }
    }
}

struct PlaceCard: View {
    let place: Place

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 12)
                .fill(cardColor(for: place.category).opacity(0.8))
                .aspectRatio(3/4, contentMode: .fit)

            Text(categoryEmoji(place.category))
                .font(.system(size: 36))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(.bottom, 40)

            LinearGradient(
                colors: [.clear, Color.curora.deep.opacity(0.75)],
                startPoint: .center,
                endPoint: .bottom
            )
            .cornerRadius(12)

            VStack(alignment: .leading, spacing: 2) {
                Text(place.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)

                Text("\(place.category) · \(place.vibe)")
                    .font(.system(size: 10, weight: .light))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(12)
        }
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

    func cardColor(for category: String) -> Color {
        switch category {
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
}

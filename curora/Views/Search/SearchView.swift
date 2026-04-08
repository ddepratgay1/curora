// SearchView.swift — Curora
// Screen 07: Search & filter saved places by name, city, category, or vibe.

import SwiftUI

struct SearchView: View {
    @Environment(PlacesViewModel.self) var placesVM

    @State private var query:           String = ""
    @State private var selectedCity:    String? = nil
    @State private var selectedCat:     String? = nil
    @State private var selectedPlace:   Place? = nil
    @FocusState private var isSearchFocused: Bool

    private var results: [Place] {
        var base = query.isEmpty ? placesVM.places : placesVM.search(query)
        if let city = selectedCity { base = base.filter { $0.city == city } }
        if let cat  = selectedCat  { base = base.filter { $0.category == cat } }
        return base
    }

    private var allCities:      [String] { placesVM.cities }
    private var allCategories:  [String] { Array(Set(placesVM.places.map { $0.category })).sorted() }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.cCream.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: CSpacing.sm) {
                        Text("Search")
                            .font(CuroraFont.serif(34))
                            .foregroundColor(Color.cDeep)
                            .padding(.top, 60)

                        // Search bar
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 14))
                                .foregroundColor(Color.cMuted)
                            TextField("Restaurants, cafés, cities…", text: $query)
                                .font(CuroraFont.sans(14))
                                .foregroundColor(Color.cDeep)
                                .focused($isSearchFocused)
                                .autocorrectionDisabled()
                            if !query.isEmpty {
                                Button(action: { query = ""; isSearchFocused = false }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Color.cMuted)
                                }
                            }
                        }
                        .padding(14)
                        .background(Color.cWarmWhite)
                        .clipShape(RoundedRectangle(cornerRadius: CRadius.md, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: CRadius.md, style: .continuous)
                                .stroke(isSearchFocused ? Color.cTerracotta.opacity(0.4) : Color.cStone, lineWidth: 0.5)
                        )
                        .animation(.easeOut(duration: 0.2), value: isSearchFocused)
                    }
                    .padding(.horizontal, CSpacing.side)
                    .padding(.bottom, CSpacing.md)

                    // Filter chips
                    if !allCities.isEmpty || !allCategories.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                // Reset
                                if selectedCity != nil || selectedCat != nil {
                                    Button(action: { selectedCity = nil; selectedCat = nil; Haptics.light() }) {
                                        Text("✕ Clear")
                                            .font(CuroraFont.sans(11))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 7)
                                            .background(Color.cDeep)
                                            .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)
                                    .transition(.scale.combined(with: .opacity))
                                }

                                ForEach(allCities, id: \.self) { city in
                                    FilterChip(
                                        label: city,
                                        isActive: selectedCity == city
                                    ) {
                                        Haptics.light()
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedCity = selectedCity == city ? nil : city
                                        }
                                    }
                                }

                                ForEach(allCategories, id: \.self) { cat in
                                    FilterChip(
                                        label: cat,
                                        isActive: selectedCat == cat,
                                        color: .cTerracotta
                                    ) {
                                        Haptics.light()
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedCat = selectedCat == cat ? nil : cat
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, CSpacing.side)
                            .animation(.spring(response: 0.35), value: selectedCity)
                            .animation(.spring(response: 0.35), value: selectedCat)
                        }
                        .padding(.bottom, CSpacing.md)
                    }

                    CuroraDivider().padding(.horizontal, CSpacing.side)

                    // Results
                    if results.isEmpty {
                        emptyState
                    } else {
                        ScrollView {
                            // Count label
                            HStack {
                                Text("\(results.count) place\(results.count == 1 ? "" : "s")")
                                    .font(CuroraFont.sansMedium(11))
                                    .foregroundColor(Color.cMuted)
                                    .kerning(0.3)
                                Spacer()
                            }
                            .padding(.horizontal, CSpacing.side)
                            .padding(.top, CSpacing.md)

                            LazyVStack(spacing: 0) {
                                ForEach(results) { place in
                                    SearchRow(place: place)
                                        .onTapGesture {
                                            Haptics.light()
                                            selectedPlace = place
                                        }
                                }
                            }
                            .padding(.bottom, 100)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(item: $selectedPlace) { place in
                PlaceDetailView(place: place)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: CSpacing.md) {
            Spacer()
            Text("🔍")
                .font(.system(size: 40))
            Text(query.isEmpty ? "No places saved yet." : "No results for \"\(query)\"")
                .font(CuroraFont.serif(22))
                .foregroundColor(Color.cDeep)
            Text(query.isEmpty ? "Start adding spots to search them here." : "Try a different name, city, or category.")
                .font(CuroraFont.sansLight(13))
                .foregroundColor(Color.cMuted)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.horizontal, CSpacing.side)
    }
}

// MARK: - Search Row
private struct SearchRow: View {
    let place: Place

    var body: some View {
        HStack(spacing: 14) {
            // Color swatch
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(accentColor.opacity(0.18))
                    .frame(width: 44, height: 44)
                Text(place.categoryEmoji)
                    .font(.system(size: 20))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(place.name)
                    .font(CuroraFont.sansMedium(14))
                    .foregroundColor(Color.cDeep)
                HStack(spacing: 4) {
                    Text(place.city)
                    Text("·")
                    Text(place.category)
                    if !place.vibe.isEmpty {
                        Text("·")
                        Text(place.vibe)
                    }
                }
                .font(CuroraFont.sansLight(11))
                .foregroundColor(Color.cMuted)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Color.cStone)
        }
        .padding(.horizontal, CSpacing.side)
        .padding(.vertical, 14)
        .overlay(alignment: .bottom) {
            CuroraDivider().padding(.leading, CSpacing.side + 58)
        }
    }

    private var accentColor: Color {
        switch place.category {
        case "Restaurant": return .cTerracotta
        case "Café":       return .cSage
        case "Hotel":      return .cGold
        case "Bar":        return .cRose
        default:           return .cMuted
        }
    }
}

// MARK: - Filter Chip
private struct FilterChip: View {
    let label:    String
    let isActive: Bool
    var color:    Color = .cDeep
    let onTap:    () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(label)
                .font(CuroraFont.sansMedium(11))
                .foregroundColor(isActive ? .white : Color.cDeep)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isActive ? color : Color.cWarmWhite)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(isActive ? Color.clear : Color.cStone, lineWidth: 0.5))
        }
        .buttonStyle(.plain)
    }
}

// PlanTripView.swift — Curora
// Screen 08: Trip planner — pick a city, set dates, and Curora builds a day itinerary.

import SwiftUI

struct PlanTripView: View {
    @Environment(PlacesViewModel.self) var placesVM

    @State private var selectedCity:      String = ""
    @State private var startDate:         Date   = Date()
    @State private var endDate:           Date   = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
    @State private var itinerary:         [[Place]] = []
    @State private var isBuilding:        Bool   = false
    @State private var showItinerary:     Bool   = false

    private var cities: [String] { placesVM.cities }

    var body: some View {
        ZStack {
            Color.cNavy.ignoresSafeArea()
            GrainOverlay(opacity: 0.04)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // Header
                    VStack(alignment: .leading, spacing: CSpacing.sm) {
                        Text("TRIP PLANNER")
                            .font(CuroraFont.sansMedium(9))
                            .kerning(3)
                            .foregroundColor(Color.cRose.opacity(0.8))
                            .padding(.top, 64)

                        Text("Plan your\nnext trip")
                            .font(CuroraFont.serif(42))
                            .foregroundColor(Color.cWarmWhite)
                            .lineSpacing(2)

                        Text("Choose a city from your boards and Curora will build a day-by-day itinerary from your saved spots.")
                            .font(CuroraFont.sansLight(13))
                            .foregroundColor(Color.cWarmWhite.opacity(0.4))
                            .lineSpacing(5)
                    }
                    .padding(.horizontal, CSpacing.side)
                    .padding(.bottom, CSpacing.xl)

                    // Form card
                    VStack(spacing: CSpacing.lg) {

                        // City picker
                        VStack(alignment: .leading, spacing: CSpacing.sm) {
                            darkFieldLabel("Destination")
                            if cities.isEmpty {
                                Text("Save some places first to plan a trip.")
                                    .font(CuroraFont.sansLight(13))
                                    .foregroundColor(Color.cWarmWhite.opacity(0.3))
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(cities, id: \.self) { city in
                                            Button(action: {
                                                Haptics.light()
                                                withAnimation(.spring(response: 0.3)) {
                                                    selectedCity = city
                                                    showItinerary = false
                                                }
                                            }) {
                                                Text(city)
                                                    .font(CuroraFont.sansMedium(12))
                                                    .foregroundColor(selectedCity == city ? Color.cNavy : Color.cWarmWhite.opacity(0.7))
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 9)
                                                    .background(selectedCity == city ? Color.cWarmWhite : Color.white.opacity(0.08))
                                                    .clipShape(Capsule())
                                                    .overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 0.5))
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                            }
                        }

                        // Dates
                        HStack(spacing: CSpacing.md) {
                            VStack(alignment: .leading, spacing: CSpacing.sm) {
                                darkFieldLabel("From")
                                DatePicker("", selection: $startDate, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .colorScheme(.dark)
                                    .labelsHidden()
                                    .onChange(of: startDate) { _, _ in showItinerary = false }
                            }
                            VStack(alignment: .leading, spacing: CSpacing.sm) {
                                darkFieldLabel("To")
                                DatePicker("", selection: $endDate, in: startDate..., displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .colorScheme(.dark)
                                    .labelsHidden()
                                    .onChange(of: endDate) { _, _ in showItinerary = false }
                            }
                        }

                        // Build button
                        Button(action: buildItinerary) {
                            HStack(spacing: 10) {
                                if isBuilding {
                                    ProgressView().tint(.white).scaleEffect(0.8)
                                } else {
                                    Image(systemName: "wand.and.stars")
                                        .font(.system(size: 14))
                                    Text("Build Itinerary")
                                        .font(CuroraFont.sansMedium(14))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(selectedCity.isEmpty ? Color.white.opacity(0.1) : Color.cTerracotta)
                            .clipShape(RoundedRectangle(cornerRadius: CRadius.md, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .disabled(selectedCity.isEmpty || isBuilding)
                    }
                    .padding(CSpacing.lg)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: CRadius.xl, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: CRadius.xl, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                    )
                    .padding(.horizontal, CSpacing.side)
                    .padding(.bottom, CSpacing.xl)

                    // Itinerary
                    if showItinerary && !itinerary.isEmpty {
                        itinerarySection
                    }

                    Spacer(minLength: 100)
                }
            }
        }
    }

    // MARK: - Itinerary section
    private var itinerarySection: some View {
        VStack(alignment: .leading, spacing: CSpacing.lg) {
            Text("Your Itinerary")
                .font(CuroraFont.serif(28))
                .foregroundColor(Color.cWarmWhite)
                .padding(.horizontal, CSpacing.side)

            ForEach(Array(itinerary.enumerated()), id: \.offset) { dayIdx, dayPlaces in
                let date = Calendar.current.date(byAdding: .day, value: dayIdx, to: startDate) ?? startDate

                VStack(alignment: .leading, spacing: CSpacing.md) {
                    // Day header
                    HStack {
                        Text("DAY \(dayIdx + 1)")
                            .font(CuroraFont.sansMedium(9))
                            .kerning(2)
                            .foregroundColor(Color.cTerracotta)
                        Text("·")
                            .foregroundColor(Color.cWarmWhite.opacity(0.2))
                        Text(date, style: .date)
                            .font(CuroraFont.sansLight(12))
                            .foregroundColor(Color.cWarmWhite.opacity(0.4))
                    }

                    // Timeline
                    VStack(spacing: 0) {
                        ForEach(Array(dayPlaces.enumerated()), id: \.offset) { idx, place in
                            HStack(alignment: .top, spacing: 14) {
                                // Timeline dot + line
                                VStack(spacing: 0) {
                                    Circle()
                                        .fill(timelineColor(for: idx))
                                        .frame(width: 8, height: 8)
                                        .padding(.top, 6)
                                    if idx < dayPlaces.count - 1 {
                                        Rectangle()
                                            .fill(Color.white.opacity(0.1))
                                            .frame(width: 1)
                                            .frame(maxHeight: .infinity)
                                    }
                                }

                                // Content
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(timeLabel(for: idx))
                                        .font(CuroraFont.sans(9))
                                        .foregroundColor(Color.cWarmWhite.opacity(0.3))
                                        .kerning(0.5)
                                    Text(place.name)
                                        .font(CuroraFont.sansMedium(14))
                                        .foregroundColor(Color.cWarmWhite)
                                    HStack(spacing: 4) {
                                        Text(place.categoryEmoji)
                                            .font(.system(size: 10))
                                        Text("\(place.category) · \(place.vibe)")
                                            .font(CuroraFont.sansLight(11))
                                            .foregroundColor(Color.cWarmWhite.opacity(0.4))
                                    }
                                }
                                .padding(.bottom, idx < dayPlaces.count - 1 ? CSpacing.lg : 0)
                            }
                        }
                    }
                }
                .padding(CSpacing.lg)
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: CRadius.lg, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: CRadius.lg, style: .continuous)
                        .stroke(Color.white.opacity(0.07), lineWidth: 0.5)
                )
                .padding(.horizontal, CSpacing.side)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
    }

    // MARK: - Build itinerary
    private func buildItinerary() {
        guard !selectedCity.isEmpty else { return }
        Haptics.medium()
        isBuilding = true

        let days = max(1, Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 1)
        let cityPlaces = placesVM.places(in: selectedCity)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            var result: [[Place]] = []
            var shuffled = cityPlaces.shuffled()

            for _ in 0..<days {
                let count = min(shuffled.count, 3)
                if count == 0 { break }
                result.append(Array(shuffled.prefix(count)))
                shuffled = Array(shuffled.dropFirst(count))
                if shuffled.isEmpty { shuffled = cityPlaces.shuffled() }
            }

            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                itinerary     = result
                showItinerary = true
                isBuilding    = false
            }
        }
    }

    private func timeLabel(for index: Int) -> String {
        let hours = ["9:00 AM", "12:30 PM", "3:00 PM", "7:30 PM"]
        return index < hours.count ? hours[index] : "Evening"
    }

    private func timelineColor(for index: Int) -> Color {
        [Color.cTerracotta, Color.cGold, Color.cSage, Color.cRose][index % 4]
    }

    @ViewBuilder
    private func darkFieldLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(CuroraFont.sansMedium(9))
            .kerning(2)
            .foregroundColor(Color.cWarmWhite.opacity(0.4))
    }
}

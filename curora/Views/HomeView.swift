// HomeView.swift — Curora
// Screen 04: Home — boards overview with live Firebase data + luxury editorial style.

import SwiftUI

// MARK: - Mock data (shown as sample when no real places yet)
let mockPlaces: [Place] = [
    Place(id:"1",  name:"Orno",               city:"Miami",       category:"Restaurant", vibe:"Date Night",    sourceURL:"https://instagram.com", notes:"Incredible pasta. Perfect for a special night.",      visited:false, savedAt:Date(), userId:"demo"),
    Place(id:"2",  name:"Panther Coffee",      city:"Miami",       category:"Café",       vibe:"Work From",     sourceURL:"https://tiktok.com",    notes:"Best espresso in Wynwood. Great wifi.",               visited:true,  savedAt:Date(), userId:"demo"),
    Place(id:"3",  name:"Faena Hotel",         city:"Miami",       category:"Hotel",      vibe:"Luxury",        sourceURL:"https://instagram.com", notes:"Pool is unreal. Worth every penny.",                  visited:false, savedAt:Date(), userId:"demo"),
    Place(id:"4",  name:"Via Carota",          city:"New York",    category:"Restaurant", vibe:"Date Night",    sourceURL:"https://instagram.com", notes:"THE pasta in NYC. Book weeks ahead.",                 visited:false, savedAt:Date(), userId:"demo"),
    Place(id:"5",  name:"Blank Street Coffee", city:"New York",    category:"Café",       vibe:"Work From",     sourceURL:"https://tiktok.com",    notes:"Fast, good, always a cute setup.",                    visited:false, savedAt:Date(), userId:"demo"),
    Place(id:"6",  name:"The Jane Hotel",      city:"New York",    category:"Hotel",      vibe:"Casual",        sourceURL:"https://instagram.com", notes:"Tiny rooms but SO much character.",                   visited:true,  savedAt:Date(), userId:"demo"),
    Place(id:"7",  name:"Café de Flore",       city:"Paris",       category:"Café",       vibe:"Tourist Must",  sourceURL:"https://instagram.com", notes:"Touristy but iconic. Go for the croissant.",          visited:false, savedAt:Date(), userId:"demo"),
    Place(id:"8",  name:"Septime",             city:"Paris",       category:"Restaurant", vibe:"Date Night",    sourceURL:"https://instagram.com", notes:"Best meal I've ever had. Book months ahead.",         visited:false, savedAt:Date(), userId:"demo"),
    Place(id:"9",  name:"Le Marais",           city:"Paris",       category:"Activity",   vibe:"Explore",       sourceURL:"https://tiktok.com",    notes:"Wander all day. Best falafel and vintage shops.",     visited:true,  savedAt:Date(), userId:"demo"),
    Place(id:"10", name:"Gjusta",              city:"Los Angeles", category:"Café",       vibe:"Brunch",        sourceURL:"https://instagram.com", notes:"Pastries are insane. Always a line but worth it.",    visited:false, savedAt:Date(), userId:"demo"),
    Place(id:"11", name:"Nobu Malibu",         city:"Los Angeles", category:"Restaurant", vibe:"Special Occasion",sourceURL:"https://tiktok.com", notes:"Ocean view and sushi — a dream combo.",              visited:false, savedAt:Date(), userId:"demo"),
    Place(id:"12", name:"Chateau Marmont",     city:"Los Angeles", category:"Hotel",      vibe:"Hidden Gem",    sourceURL:"https://instagram.com", notes:"Hollywood history everywhere you look.",              visited:false, savedAt:Date(), userId:"demo"),
]

let mockBoards: [(city: String, places: [Place])] = {
    let cities = ["Miami", "New York", "Paris", "Los Angeles"]
    return cities.map { city in (city: city, places: mockPlaces.filter { $0.city == city }) }
}()

// MARK: - HomeView
struct HomeView: View {
    @Environment(AuthViewModel.self)   var auth
    @Environment(PlacesViewModel.self) var placesVM

    @State private var selectedBoard: (city: String, places: [Place])? = nil
    @State private var headerOpacity: Double = 0

    // Use live data if available, fall back to mock
    private var displayBoards: [(city: String, places: [Place])] {
        placesVM.boards.isEmpty ? mockBoards : placesVM.boards
    }
    private var displayPlaces: [Place] {
        placesVM.places.isEmpty ? mockPlaces : placesVM.places
    }
    private var usingMock: Bool { placesVM.places.isEmpty }

    private var firstName: String {
        let name = auth.user?.displayName ?? ""
        return name.components(separatedBy: " ").first ?? "there"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.cCream.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {

                        // ── Top bar ───────────────────────────────────────
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(greeting + ",")
                                    .font(CuroraFont.sansLight(13))
                                    .foregroundColor(Color.cMuted)
                                Text(firstName)
                                    .font(CuroraFont.serifMedium(28))
                                    .foregroundColor(Color.cDeep)
                            }
                            Spacer()

                            // Avatar
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        colors: [Color.cBlush, Color.cTerracotta.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 38, height: 38)
                                Text(firstName.prefix(1).uppercased())
                                    .font(CuroraFont.serifMedium(16))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, CSpacing.side)
                        .padding(.top, 64)
                        .padding(.bottom, CSpacing.lg)
                        .opacity(headerOpacity)
                        .animation(.easeOut(duration: 0.5).delay(0.1), value: headerOpacity)

                        // ── Stats strip ───────────────────────────────────
                        HStack(spacing: 0) {
                            MiniStat(value: "\(displayPlaces.count)",          label: "Saved")
                            CuroraDivider().frame(width: 0.5, height: 28).rotationEffect(.degrees(0))
                            MiniStat(value: "\(displayBoards.count)",          label: "Cities")
                            CuroraDivider().frame(width: 0.5, height: 28)
                            MiniStat(value: "\(displayPlaces.filter{$0.visited}.count)", label: "Visited")
                        }
                        .padding(.horizontal, CSpacing.side)
                        .padding(.bottom, CSpacing.xl)
                        .opacity(headerOpacity)

                        // ── Demo banner (shown when using mock data) ──────
                        if usingMock {
                            HStack(spacing: 8) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 12))
                                Text("Showing sample boards. Tap + to save your first place.")
                                    .font(CuroraFont.sansLight(12))
                                    .lineSpacing(3)
                            }
                            .foregroundColor(Color.cGold)
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.cGold.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: CRadius.md, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: CRadius.md, style: .continuous)
                                    .stroke(Color.cGold.opacity(0.2), lineWidth: 0.5)
                            )
                            .padding(.horizontal, CSpacing.side)
                            .padding(.bottom, CSpacing.lg)
                        }

                        // ── Boards section ────────────────────────────────
                        HStack {
                            Text("Your Boards")
                                .font(CuroraFont.serif(26))
                                .foregroundColor(Color.cDeep)
                            Spacer()
                            Text("\(displayBoards.count) cities")
                                .font(CuroraFont.sansLight(12))
                                .foregroundColor(Color.cMuted)
                        }
                        .padding(.horizontal, CSpacing.side)
                        .padding(.bottom, CSpacing.md)

                        // Board cards
                        VStack(spacing: 14) {
                            ForEach(displayBoards, id: \.city) { board in
                                LuxuryBoardCard(city: board.city, places: board.places)
                                    .onTapGesture {
                                        Haptics.light()
                                        selectedBoard = board
                                    }
                            }
                        }
                        .padding(.horizontal, CSpacing.side)
                        .padding(.bottom, 100)
                    }
                }
                .refreshable {
                    // Pull to refresh — data auto-syncs via Firestore listener
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: Binding(
                get:  { selectedBoard != nil },
                set:  { if !$0 { selectedBoard = nil } }
            )) {
                if let board = selectedBoard {
                    CityBoardView(
                        board: Board(id: board.city, title: board.city, type: "city",
                                     coverImageURL: "", placeCount: board.places.count, createdAt: Date()),
                        places: board.places
                    )
                }
            }
            .onAppear {
                withAnimation { headerOpacity = 1 }
                if let userId = auth.user?.id {
                    placesVM.startListening(userId: userId)
                }
            }
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good morning"
        case 12..<18: return "Good afternoon"
        default:      return "Good evening"
        }
    }
}

// MARK: - Mini stat
private struct MiniStat: View {
    let value: String
    let label: String
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(CuroraFont.serifMedium(22))
                .foregroundColor(Color.cDeep)
            Text(label.uppercased())
                .font(CuroraFont.sans(9))
                .foregroundColor(Color.cMuted)
                .kerning(1)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Luxury Board Card
struct LuxuryBoardCard: View {
    let city:   String
    let places: [Place]

    @State private var isPressed = false

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background tint
            RoundedRectangle(cornerRadius: CRadius.lg, style: .continuous)
                .fill(accentColor.opacity(0.07))
                .frame(height: 152)
                .overlay(
                    // Left accent bar
                    HStack {
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .fill(accentColor)
                            .frame(width: 3, height: 80)
                            .padding(.leading, 18)
                        Spacer()
                    }
                )

            // Content row
            HStack(alignment: .center, spacing: 0) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(cityEmoji)
                        .font(.system(size: 26))
                    Text(city)
                        .font(CuroraFont.serifMedium(24))
                        .foregroundColor(Color.cDeep)
                    HStack(spacing: 5) {
                        Text("\(places.count) places saved")
                            .font(CuroraFont.sansLight(11))
                            .foregroundColor(Color.cMuted)
                        if places.filter({ $0.visited }).count > 0 {
                            Text("·")
                                .foregroundColor(Color.cStone)
                            Text("\(places.filter { $0.visited }.count) visited")
                                .font(CuroraFont.sansLight(11))
                                .foregroundColor(Color.cSage)
                        }
                    }
                }
                .padding(.leading, 28)

                Spacer()

                // Mini thumbnail stack
                HStack(spacing: 5) {
                    ForEach(places.prefix(3)) { place in
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .fill(thumbnailColor(for: place.category).opacity(0.75))
                            .frame(width: 42, height: 58)
                            .overlay(
                                Text(place.categoryEmoji)
                                    .font(.system(size: 16))
                            )
                    }
                }
                .padding(.trailing, 18)
            }
            .frame(height: 152)
        }
        .clipShape(RoundedRectangle(cornerRadius: CRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: CRadius.lg, style: .continuous)
                .stroke(accentColor.opacity(0.12), lineWidth: 0.5)
        )
        .shadowSoft()
        .scaleEffect(isPressed ? 0.97 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }

    private var accentColor: Color {
        switch city {
        case "Miami":       return .cTerracotta
        case "New York":    return .cDeep
        case "Paris":       return .cGold
        case "Los Angeles": return .cSage
        default:            return .cMuted
        }
    }

    private var cityEmoji: String {
        switch city {
        case "Miami":       return "🌴"
        case "New York":    return "🗽"
        case "Paris":       return "🗼"
        case "Los Angeles": return "🌅"
        case "London":      return "🎡"
        case "Barcelona":   return "🏖"
        case "Tokyo":       return "⛩"
        default:            return "📍"
        }
    }

    private func thumbnailColor(for category: String) -> Color {
        switch category {
        case "Restaurant": return .cTerracotta
        case "Café":       return .cSage
        case "Hotel":      return .cGold
        case "Bar":        return .cRose
        default:           return .cMuted
        }
    }
}

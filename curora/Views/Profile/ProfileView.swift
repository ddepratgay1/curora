// ProfileView.swift — Curora
// Screen 09: User profile with stats, city breakdown, and settings.

import SwiftUI

struct ProfileView: View {
    @Environment(AuthViewModel.self)   var auth
    @Environment(PlacesViewModel.self) var placesVM
    @State private var showSignOutAlert = false

    private var firstName: String {
        let display = auth.user?.displayName ?? ""
        return display.components(separatedBy: " ").first ?? auth.user?.email ?? "You"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.cCream.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {

                        // ── Top bar ──────────────────────────────────────
                        HStack {
                            Text("Profile")
                                .font(CuroraFont.serif(30))
                                .foregroundColor(Color.cDeep)
                            Spacer()
                            Button(action: { showSignOutAlert = true }) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 16, weight: .light))
                                    .foregroundColor(Color.cMuted)
                            }
                        }
                        .padding(.horizontal, CSpacing.side)
                        .padding(.top, 62)
                        .padding(.bottom, CSpacing.lg)

                        // ── Avatar + name ────────────────────────────────
                        VStack(spacing: CSpacing.md) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.cBlush, Color.cTerracotta],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 72, height: 72)
                                    .shadowMedium()

                                Text(firstName.prefix(1).uppercased())
                                    .font(CuroraFont.serif(32))
                                    .foregroundColor(.white)
                            }

                            VStack(spacing: 4) {
                                Text(firstName)
                                    .font(CuroraFont.serifMedium(24))
                                    .foregroundColor(Color.cDeep)
                                Text(auth.user?.email ?? "")
                                    .font(CuroraFont.sansLight(12))
                                    .foregroundColor(Color.cMuted)
                            }
                        }
                        .padding(.bottom, CSpacing.xl)

                        // ── Stats bar ────────────────────────────────────
                        HStack(spacing: 0) {
                            StatBlock(value: "\(placesVM.totalCount)",   label: "Saved")
                            Divider().frame(height: 32)
                            StatBlock(value: "\(placesVM.cities.count)", label: "Cities")
                            Divider().frame(height: 32)
                            StatBlock(value: "\(placesVM.visitedCount)", label: "Visited")
                        }
                        .padding(.horizontal, CSpacing.side)
                        .padding(.bottom, CSpacing.xl)

                        CuroraDivider().padding(.horizontal, CSpacing.side)
                            .padding(.bottom, CSpacing.xl)

                        // ── City breakdown ───────────────────────────────
                        if !placesVM.boards.isEmpty {
                            VStack(alignment: .leading, spacing: CSpacing.md) {
                                HStack {
                                    Text("Places by City")
                                        .font(CuroraFont.serif(22))
                                        .foregroundColor(Color.cDeep)
                                    Spacer()
                                }
                                .padding(.horizontal, CSpacing.side)

                                VStack(spacing: 10) {
                                    ForEach(placesVM.boards.prefix(6), id: \.city) { board in
                                        CityProgressRow(
                                            city:     board.city,
                                            count:    board.places.count,
                                            total:    placesVM.totalCount,
                                            visited:  board.places.filter { $0.visited }.count
                                        )
                                    }
                                }
                                .padding(.horizontal, CSpacing.side)
                            }
                            .padding(.bottom, CSpacing.xl)

                            CuroraDivider().padding(.horizontal, CSpacing.side)
                                .padding(.bottom, CSpacing.xl)
                        }

                        // ── Category breakdown ──────────────────────────
                        let categories = Dictionary(grouping: placesVM.places, by: { $0.category })
                        if !categories.isEmpty {
                            VStack(alignment: .leading, spacing: CSpacing.md) {
                                Text("By Category")
                                    .font(CuroraFont.serif(22))
                                    .foregroundColor(Color.cDeep)
                                    .padding(.horizontal, CSpacing.side)

                                LazyVGrid(
                                    columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                                    spacing: 10
                                ) {
                                    ForEach(categories.keys.sorted(), id: \.self) { cat in
                                        CategoryStatCard(
                                            category: cat,
                                            count: categories[cat]?.count ?? 0
                                        )
                                    }
                                }
                                .padding(.horizontal, CSpacing.side)
                            }
                            .padding(.bottom, CSpacing.xl)
                        }

                        // ── Empty state ──────────────────────────────────
                        if placesVM.totalCount == 0 {
                            VStack(spacing: CSpacing.md) {
                                Text("📍")
                                    .font(.system(size: 40))
                                Text("No places saved yet.")
                                    .font(CuroraFont.serif(22))
                                    .foregroundColor(Color.cDeep)
                                Text("Tap + to start building your collection.")
                                    .font(CuroraFont.sansLight(13))
                                    .foregroundColor(Color.cMuted)
                            }
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 40)
                            .padding(.horizontal, CSpacing.side)
                        }

                        Spacer(minLength: 100)
                    }
                }
            }
            .navigationBarHidden(true)
            .alert("Sign out of Curora?", isPresented: $showSignOutAlert) {
                Button("Sign Out", role: .destructive) { try? auth.signOut() }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}

// MARK: - Sub-components
private struct StatBlock: View {
    let value: String
    let label: String
    var body: some View {
        VStack(spacing: 3) {
            Text(value)
                .font(CuroraFont.serifMedium(28))
                .foregroundColor(Color.cDeep)
            Text(label.uppercased())
                .font(CuroraFont.sans(9))
                .foregroundColor(Color.cMuted)
                .kerning(1.5)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct CityProgressRow: View {
    let city:    String
    let count:   Int
    let total:   Int
    let visited: Int

    var progress: CGFloat { total > 0 ? CGFloat(count) / CGFloat(total) : 0 }

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(city)
                    .font(CuroraFont.sansMedium(13))
                    .foregroundColor(Color.cDeep)
                Spacer()
                Text("\(count) saved · \(visited) visited")
                    .font(CuroraFont.sansLight(11))
                    .foregroundColor(Color.cMuted)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.cStone)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.cTerracotta.opacity(0.75))
                        .frame(width: geo.size.width * progress)
                }
                .frame(height: 3)
            }
            .frame(height: 3)
        }
        .padding(14)
        .background(Color.cWarmWhite)
        .clipShape(RoundedRectangle(cornerRadius: CRadius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: CRadius.md, style: .continuous)
                .stroke(Color.cStone, lineWidth: 0.5)
        )
    }
}

private struct CategoryStatCard: View {
    let category: String
    let count:    Int

    private var place: Place {
        Place(id: "", name: "", city: "", category: category, vibe: "", userId: "")
    }

    var body: some View {
        VStack(spacing: 6) {
            Text(place.categoryEmoji)
                .font(.system(size: 24))
            Text("\(count)")
                .font(CuroraFont.serifMedium(20))
                .foregroundColor(Color.cDeep)
            Text(category)
                .font(CuroraFont.sansLight(10))
                .foregroundColor(Color.cMuted)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.cWarmWhite)
        .clipShape(RoundedRectangle(cornerRadius: CRadius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: CRadius.md, style: .continuous)
                .stroke(Color.cStone, lineWidth: 0.5)
        )
    }
}

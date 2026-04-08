// MainTabView.swift — Curora
// Custom luxury tab bar with a center add-place button.

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int      = 0
    @State private var showAddPlace: Bool    = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab content
            Group {
                switch selectedTab {
                case 0:  HomeView()
                case 1:  SearchView()
                case 3:  PlanTripView()
                default: ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Floating tab bar
            CuroraTabBar(
                selectedTab:    $selectedTab,
                onAddTapped:    { showAddPlace = true }
            )
        }
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $showAddPlace) {
            AddPlaceView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(24)
        }
    }
}

// MARK: - Custom Tab Bar
struct CuroraTabBar: View {
    @Binding var selectedTab: Int
    let onAddTapped: () -> Void

    private let tabs: [(tag: Int, icon: String, label: String)] = [
        (0, "square.grid.2x2", "Boards"),
        (1, "magnifyingglass",  "Search"),
        (3, "map",              "Trip"),
        (4, "person",           "Profile"),
    ]

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // Left tabs
            ForEach(tabs.prefix(2), id: \.tag) { tab in
                TabBarItem(icon: tab.icon, label: tab.label,
                           isSelected: selectedTab == tab.tag) {
                    Haptics.light()
                    selectedTab = tab.tag
                }
            }

            // Center add button
            Button(action: {
                Haptics.rigid()
                onAddTapped()
            }) {
                ZStack {
                    Circle()
                        .fill(Color.cTerracotta)
                        .frame(width: 56, height: 56)
                        .shadowTerracotta()
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .light))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(.plain)
            .offset(y: -18)
            .padding(.horizontal, 12)

            // Right tabs
            ForEach(tabs.suffix(2), id: \.tag) { tab in
                TabBarItem(icon: tab.icon, label: tab.label,
                           isSelected: selectedTab == tab.tag) {
                    Haptics.light()
                    selectedTab = tab.tag
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 12)
        .padding(.bottom, 28)
        .background(
            // Frosted glass tab bar
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Rectangle()
                        .fill(Color.cCream.opacity(0.7))
                )
                .overlay(
                    Rectangle()
                        .fill(Color.clear)
                        .border(Color.cStone.opacity(0.6), width: 0.5),
                    alignment: .top
                )
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

struct TabBarItem: View {
    let icon:       String
    let label:      String
    let isSelected: Bool
    let action:     () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? icon + ".fill" : icon)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? Color.cTerracotta : Color.cMuted)
                Text(label)
                    .font(CuroraFont.sans(9))
                    .foregroundColor(isSelected ? Color.cTerracotta : Color.cMuted)
                    .kerning(0.3)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

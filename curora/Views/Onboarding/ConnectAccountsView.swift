// ConnectAccountsView.swift — Curora
// Screen 02: Connect social platforms. MVP shows UI; auto-import is a future feature.

import SwiftUI

struct ConnectAccountsView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var connected: Set<String> = []
    @State private var tapping: String? = nil

    private let platforms: [(id: String, name: String, sub: String, emoji: String, bg: Color)] = [
        ("instagram", "Instagram",   "Tap to connect",  "📸", Color(hex: "FCE4EC")),
        ("tiktok",    "TikTok",      "Tap to connect",  "▶",  Color(hex: "E8F5E9")),
        ("gmaps",     "Google Maps", "Tap to connect",  "🗺",  Color(hex: "E3F2FD")),
    ]

    var body: some View {
        ZStack {
            Color.cWarmWhite.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: CSpacing.sm) {
                    Text("CONNECT")
                        .font(CuroraFont.sansMedium(9))
                        .kerning(3)
                        .foregroundColor(Color.cTerracotta)
                        .padding(.top, 72)

                    Text("Connect your\nsaved spots")
                        .font(CuroraFont.serif(38))
                        .foregroundColor(Color.cDeep)
                        .lineSpacing(2)

                    Text("Link your platforms so Curora can find the places you've already saved. You can always add more later.")
                        .font(CuroraFont.sansLight(13))
                        .foregroundColor(Color.cMuted)
                        .lineSpacing(5)
                        .padding(.top, 4)
                }
                .padding(.horizontal, CSpacing.side)
                .padding(.bottom, CSpacing.xl)

                CuroraDivider().padding(.horizontal, CSpacing.side)

                // Platform list
                VStack(spacing: 10) {
                    ForEach(platforms, id: \.id) { platform in
                        PlatformRow(
                            platform:    platform,
                            isConnected: connected.contains(platform.id),
                            isTapping:   tapping == platform.id
                        ) {
                            handleConnect(platform.id)
                        }
                    }
                }
                .padding(.horizontal, CSpacing.side)
                .padding(.top, CSpacing.lg)

                Spacer()

                // Footer note
                Text("Auto-import is coming soon. For now, add places manually after connecting.")
                    .font(CuroraFont.sansLight(11))
                    .foregroundColor(Color.cMuted.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, CSpacing.side)
                    .padding(.bottom, CSpacing.lg)

                // CTA
                CuroraButton(title: "Continue →", style: .dark) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        hasCompletedOnboarding = false  // ImportingView will set it
                    }
                    // Navigate to importing screen via ContentView
                    UserDefaults.standard.set(true, forKey: "showImporting")
                }
                .padding(.horizontal, CSpacing.side)
                .padding(.bottom, 48)
            }
        }
    }

    private func handleConnect(_ id: String) {
        Haptics.medium()
        tapping = id
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                if connected.contains(id) { connected.remove(id) }
                else                      { connected.insert(id) }
                tapping = nil
            }
        }
    }
}

// MARK: - Platform Row
private struct PlatformRow: View {
    let platform:    (id: String, name: String, sub: String, emoji: String, bg: Color)
    let isConnected: Bool
    let isTapping:   Bool
    let onTap:       () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(isConnected ? Color.cSage.opacity(0.15) : platform.bg)
                        .frame(width: 44, height: 44)
                    Text(platform.emoji)
                        .font(.system(size: 20))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(platform.name)
                        .font(CuroraFont.sansMedium(14))
                        .foregroundColor(Color.cDeep)
                    Text(isConnected ? "Connected ✓" : platform.sub)
                        .font(CuroraFont.sansLight(11))
                        .foregroundColor(isConnected ? Color.cSage : Color.cMuted)
                }

                Spacer()

                Image(systemName: isConnected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isConnected ? Color.cSage : Color.cStone)
            }
            .padding(16)
            .background(isConnected ? Color.cSage.opacity(0.06) : Color.cCream)
            .clipShape(RoundedRectangle(cornerRadius: CRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: CRadius.md, style: .continuous)
                    .stroke(isConnected ? Color.cSage.opacity(0.3) : Color.cStone, lineWidth: 0.5)
            )
            .scaleEffect(isTapping ? 0.97 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isTapping)
        }
        .buttonStyle(.plain)
    }
}

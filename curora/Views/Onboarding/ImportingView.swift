// ImportingView.swift — Curora
// Screen 03: Animated scanning/importing screen shown after onboarding connect step.

import SwiftUI

struct ImportingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(PlacesViewModel.self) var placesVM

    @State private var progress:      CGFloat = 0
    @State private var ringScale:     CGFloat = 0.7
    @State private var ringOpacity:   Double  = 0
    @State private var countText:     Int     = 0
    @State private var labelOpacity:  Double  = 0
    @State private var chipOffset:    CGFloat = 20
    @State private var chipOpacity:   Double  = 0

    private let chips = ["Restaurants", "Cafés", "Hotels", "Activities", "Vibes"]
    @State private var visibleChips: Set<Int> = []

    var body: some View {
        ZStack {
            Color.cNavy.ignoresSafeArea()
            GrainOverlay(opacity: 0.04)

            VStack(spacing: CSpacing.lg) {
                Spacer()

                // Animated ring
                ZStack {
                    Circle()
                        .stroke(Color.cTerracotta.opacity(0.1), lineWidth: 1.5)
                        .frame(width: 130, height: 130)

                    Circle()
                        .stroke(Color.cTerracotta.opacity(0.06), lineWidth: 1)
                        .frame(width: 160, height: 160)

                    Circle()
                        .fill(Color.cTerracotta.opacity(0.12))
                        .frame(width: 90, height: 90)
                        .overlay(
                            Text("📍")
                                .font(.system(size: 34))
                        )
                }
                .scaleEffect(ringScale)
                .opacity(ringOpacity)
                .padding(.bottom, CSpacing.sm)

                // Copy
                VStack(spacing: 10) {
                    Text("Finding your spots…")
                        .font(CuroraFont.serif(28))
                        .foregroundColor(Color.cWarmWhite)
                        .opacity(labelOpacity)

                    HStack(spacing: 6) {
                        Text("\(countText)")
                            .font(CuroraFont.serifMedium(14))
                            .foregroundColor(Color.cTerracotta)
                            .contentTransition(.numericText())
                            .animation(.spring(response: 0.4), value: countText)

                        Text("places discovered")
                            .font(CuroraFont.sansLight(13))
                            .foregroundColor(Color.cWarmWhite.opacity(0.35))
                            .kerning(0.2)
                    }
                    .opacity(labelOpacity)
                }

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white.opacity(0.08))
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.cTerracotta)
                            .frame(width: geo.size.width * progress)
                            .animation(.easeInOut(duration: 0.4), value: progress)
                    }
                    .frame(height: 2)
                }
                .frame(maxWidth: 180)
                .opacity(labelOpacity)

                // Category chips
                HStack(spacing: 8) {
                    ForEach(chips.indices, id: \.self) { i in
                        if visibleChips.contains(i) {
                            Text(chips[i])
                                .font(CuroraFont.sans(10))
                                .foregroundColor(Color.cWarmWhite.opacity(0.5))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 5)
                                .background(Color.white.opacity(0.06))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 0.5))
                                .transition(.scale(scale: 0.7).combined(with: .opacity))
                        }
                    }
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: visibleChips)

                Spacer()
            }
            .padding(.horizontal, CSpacing.side)
        }
        .onAppear(perform: startAnimation)
    }

    private func startAnimation() {
        // Ring entrance
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.1)) {
            ringScale   = 1
            ringOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.4)) {
            labelOpacity = 1
        }

        // Progress + count ticker
        for step in 1...5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(step) * 0.55) {
                progress  = CGFloat(step) / 5.0
                countText = step * 9
                // reveal chips one by one
                if step - 1 < chips.count {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        visibleChips.insert(step - 1)
                    }
                }
            }
        }

        // Finish after 3.2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.4) {
            withAnimation(.easeInOut(duration: 0.5)) {
                hasCompletedOnboarding = true
            }
        }
    }
}

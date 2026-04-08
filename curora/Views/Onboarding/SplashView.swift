// SplashView.swift — Curora
// Screen 01: Onboarding splash. Shows brand, then transitions to LoginView.

import SwiftUI

struct SplashView: View {
    @AppStorage("hasSeenSplash") private var hasSeenSplash = false

    @State private var logoScale:   CGFloat = 0.6
    @State private var logoOpacity: Double  = 0
    @State private var wordOpacity: Double  = 0
    @State private var tagOpacity:  Double  = 0
    @State private var dotsOpacity: Double  = 0
    @State private var dotIndex:    Int     = 0

    private let slides = [
        ("your saved spots,\nfinally home.",  "Collect every place\nyou've ever wanted to visit."),
        ("curate your\nperfect world.",       "Build beautiful boards by\ncity, mood, and moment."),
        ("never lose a\ngood find again.",    "Save from Instagram, TikTok,\nor anywhere — all in one place."),
    ]
    @State private var slideIndex = 0

    var body: some View {
        ZStack {
            Color.cNavy.ignoresSafeArea()
            GrainOverlay(opacity: 0.03)

            VStack(spacing: 0) {
                Spacer()

                // Logo mark
                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.cTerracotta)
                        .frame(width: 72, height: 72)
                        .shadowTerracotta()

                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 30, weight: .ultraLight))
                        .foregroundColor(.white)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                .padding(.bottom, 28)

                // Wordmark
                Text("curora")
                    .font(CuroraFont.serifItalic(52))
                    .foregroundColor(Color.cWarmWhite)
                    .opacity(wordOpacity)
                    .padding(.bottom, 16)

                // Slide text
                VStack(spacing: 8) {
                    Text(slides[slideIndex].0)
                        .font(CuroraFont.sansLight(14))
                        .foregroundColor(Color.cWarmWhite.opacity(0.4))
                        .multilineTextAlignment(.center)
                        .kerning(0.3)
                        .lineSpacing(4)
                        .id(slideIndex)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
                .opacity(tagOpacity)
                .frame(height: 60)

                Spacer()

                // Pagination dots
                HStack(spacing: 6) {
                    ForEach(0..<slides.count, id: \.self) { i in
                        Capsule()
                            .fill(i == slideIndex ? Color.cTerracotta : Color.white.opacity(0.2))
                            .frame(width: i == slideIndex ? 20 : 6, height: 6)
                            .animation(.spring(response: 0.4), value: slideIndex)
                    }
                }
                .opacity(dotsOpacity)
                .padding(.bottom, 48)

                // CTA button
                Button(action: advance) {
                    HStack(spacing: 10) {
                        Text(slideIndex < slides.count - 1 ? "Continue" : "Get Started")
                            .font(CuroraFont.sansMedium(14))
                            .kerning(0.3)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        slideIndex < slides.count - 1
                            ? Color.white.opacity(0.08)
                            : Color.cTerracotta
                    )
                    .clipShape(RoundedRectangle(cornerRadius: CRadius.md, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: CRadius.md, style: .continuous)
                            .stroke(Color.white.opacity(slideIndex < slides.count - 1 ? 0.12 : 0), lineWidth: 0.5)
                    )
                }
                .opacity(dotsOpacity)
                .padding(.horizontal, CSpacing.side)
                .padding(.bottom, 52)
            }
        }
        .onAppear(perform: animate)
    }

    private func animate() {
        withAnimation(.spring(response: 0.7, dampingFraction: 0.65).delay(0.2)) {
            logoScale   = 1
            logoOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.6).delay(0.55)) {
            wordOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.85)) {
            tagOpacity  = 1
            dotsOpacity = 1
        }

        // Auto-advance slides
        Timer.scheduledTimer(withTimeInterval: 3.2, repeats: true) { timer in
            guard slideIndex < slides.count - 1 else { timer.invalidate(); return }
            withAnimation(.easeInOut(duration: 0.4)) { slideIndex += 1 }
        }
    }

    private func advance() {
        Haptics.light()
        if slideIndex < slides.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) { slideIndex += 1 }
        } else {
            hasSeenSplash = true   // triggers ContentView to show LoginView
        }
    }
}

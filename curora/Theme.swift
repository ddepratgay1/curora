// Theme.swift
// Curora — Design System
// All colors, fonts, spacing, and reusable modifiers live here.

import SwiftUI

// MARK: - Color Palette
extension Color {
    static let cCream       = Color(hex: "F9F5EF")
    static let cWarmWhite   = Color(hex: "FDFAF6")
    static let cBlush       = Color(hex: "EDD9C8")
    static let cTerracotta  = Color(hex: "C47B5A")
    static let cDeep        = Color(hex: "2C2118")
    static let cMuted       = Color(hex: "8A7466")
    static let cSage        = Color(hex: "9BAE9A")
    static let cStone       = Color(hex: "E3DDD6")
    static let cGold        = Color(hex: "C9A96E")
    static let cNavy        = Color(hex: "0D0F1C")
    static let cRose        = Color(hex: "C49E96")
    static let cCharcoal    = Color(hex: "1A1410")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a,r,g,b) = (255,(int>>8)*17,(int>>4&0xF)*17,(int&0xF)*17)
        case 6:  (a,r,g,b) = (255,int>>16,int>>8&0xFF,int&0xFF)
        case 8:  (a,r,g,b) = (int>>24,int>>16&0xFF,int>>8&0xFF,int&0xFF)
        default: (a,r,g,b) = (255,255,255,255)
        }
        self.init(.sRGB,
                  red:     Double(r)/255,
                  green:   Double(g)/255,
                  blue:    Double(b)/255,
                  opacity: Double(a)/255)
    }
}

// MARK: - Typography
// Install CormorantGaramond + DMSans TTFs in Xcode and add to Info.plist.
// If fonts are missing, iOS falls back to Georgia / system-sans gracefully.
struct CuroraFont {
    // ── Serif (Cormorant Garamond) ──────────────────────────────────────────
    static func serif(_ size: CGFloat) -> Font {
        .custom("CormorantGaramond-Light", size: size)
    }
    static func serifItalic(_ size: CGFloat) -> Font {
        .custom("CormorantGaramond-LightItalic", size: size)
    }
    static func serifMedium(_ size: CGFloat) -> Font {
        .custom("CormorantGaramond-Medium", size: size)
    }
    static func serifBold(_ size: CGFloat) -> Font {
        .custom("CormorantGaramond-SemiBold", size: size)
    }

    // ── Sans (DM Sans) ──────────────────────────────────────────────────────
    static func sans(_ size: CGFloat) -> Font {
        .custom("DMSans-Regular", size: size)
    }
    static func sansLight(_ size: CGFloat) -> Font {
        .custom("DMSans-Light", size: size)
    }
    static func sansMedium(_ size: CGFloat) -> Font {
        .custom("DMSans-Medium", size: size)
    }
}

// MARK: - Spacing
enum CSpacing {
    static let xs:   CGFloat = 4
    static let sm:   CGFloat = 8
    static let md:   CGFloat = 16
    static let lg:   CGFloat = 24
    static let xl:   CGFloat = 32
    static let xxl:  CGFloat = 48
    static let side: CGFloat = 22   // horizontal edge padding
}

// MARK: - Corner Radius
enum CRadius {
    static let sm:   CGFloat = 8
    static let md:   CGFloat = 12
    static let lg:   CGFloat = 16
    static let xl:   CGFloat = 24
    static let pill: CGFloat = 100
}

// MARK: - Shadow Presets
extension View {
    func shadowSoft() -> some View {
        self.shadow(color: Color.cDeep.opacity(0.08), radius: 12, x: 0, y: 4)
    }
    func shadowMedium() -> some View {
        self.shadow(color: Color.cDeep.opacity(0.14), radius: 20, x: 0, y: 8)
    }
    func shadowTerracotta() -> some View {
        self.shadow(color: Color.cTerracotta.opacity(0.35), radius: 16, x: 0, y: 6)
    }
}

// MARK: - Card Style
struct CuroraCardModifier: ViewModifier {
    var background: Color = .cWarmWhite
    var cornerRadius: CGFloat = CRadius.lg
    func body(content: Content) -> some View {
        content
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.cStone, lineWidth: 0.5)
            )
    }
}

extension View {
    func curoraCard(background: Color = .cWarmWhite,
                    cornerRadius: CGFloat = CRadius.lg) -> some View {
        modifier(CuroraCardModifier(background: background, cornerRadius: cornerRadius))
    }
}

// MARK: - Pill / Tag style
struct PillModifier: ViewModifier {
    var bg: Color = Color.cCream
    var border: Color = Color.cStone
    var textColor: Color = Color.cMuted
    func body(content: Content) -> some View {
        content
            .font(CuroraFont.sans(10))
            .foregroundColor(textColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(bg)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(border, lineWidth: 0.5))
    }
}

extension View {
    func curoPill(bg: Color = .cCream,
                  border: Color = .cStone,
                  text: Color = .cMuted) -> some View {
        modifier(PillModifier(bg: bg, border: border, textColor: text))
    }
}

// MARK: - Haptics
struct Haptics {
    static func light()    { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    static func medium()   { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
    static func rigid()    { UIImpactFeedbackGenerator(style: .rigid).impactOccurred() }
    static func success()  { UINotificationFeedbackGenerator().notificationOccurred(.success) }
}

// MARK: - Grain Overlay (luxury texture)
struct GrainOverlay: View {
    var opacity: Double = 0.04
    var body: some View {
        Rectangle()
            .fill(.clear)
            .overlay(
                GeometryReader { geo in
                    Canvas { context, size in
                        // Lightweight noise pattern
                        for _ in 0..<Int(size.width * size.height / 120) {
                            let x = CGFloat.random(in: 0..<size.width)
                            let y = CGFloat.random(in: 0..<size.height)
                            let r = CGFloat.random(in: 0.3...0.8)
                            let path = Path(ellipseIn: CGRect(x: x, y: y, width: r, height: r))
                            context.fill(path, with: .color(.white.opacity(opacity)))
                        }
                    }
                }
            )
            .allowsHitTesting(false)
    }
}

// MARK: - Section Header style
struct SectionHeader: View {
    let label: String
    let title: String
    var description: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: CSpacing.xs) {
            Text(label.uppercased())
                .font(CuroraFont.sansMedium(9))
                .kerning(2.5)
                .foregroundColor(.cTerracotta)
            Text(title)
                .font(CuroraFont.serif(30))
                .foregroundColor(.cNavy)
            if let desc = description {
                Text(desc)
                    .font(CuroraFont.sansLight(13))
                    .foregroundColor(.cMuted)
                    .lineSpacing(4)
            }
        }
    }
}

// MARK: - Divider
struct CuroraDivider: View {
    var color: Color = .cStone
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: 0.5)
    }
}

// MARK: - Primary Button
struct CuroraButton: View {
    let title: String
    var style: ButtonStyle = .dark
    var isLoading: Bool = false
    let action: () -> Void

    enum ButtonStyle { case dark, terracotta, ghost }

    var bg: Color {
        switch style {
        case .dark:       return .cNavy
        case .terracotta: return .cTerracotta
        case .ghost:      return .clear
        }
    }
    var fg: Color {
        switch style {
        case .ghost: return .cDeep
        default:     return .cWarmWhite
        }
    }

    var body: some View {
        Button(action: {
            Haptics.medium()
            action()
        }) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .tint(fg)
                        .scaleEffect(0.8)
                } else {
                    Text(title)
                        .font(CuroraFont.sansMedium(13))
                        .kerning(0.5)
                        .foregroundColor(fg)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(bg)
            .clipShape(RoundedRectangle(cornerRadius: CRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: CRadius.md, style: .continuous)
                    .stroke(style == .ghost ? Color.cStone : .clear, lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Back Button
struct BackButton: View {
    let action: () -> Void
    var tint: Color = .cDeep

    var body: some View {
        Button(action: {
            Haptics.light()
            action()
        }) {
            Image(systemName: "arrow.left")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(tint)
                .frame(width: 36, height: 36)
                .background(tint.opacity(0.08))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Status Bar Height helper
extension UIApplication {
    static var statusBarHeight: CGFloat {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return scene?.statusBarManager?.statusBarFrame.height ?? 44
    }
}

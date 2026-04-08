// Colors.swift — backward-compat namespace
// Color(hex:) lives in Theme.swift. This file maps the
// legacy `Color.curora.*` names to the Theme cX constants.

import SwiftUI

extension Color {
    struct curora {
        static let deep    = Color.cDeep
        static let terra   = Color.cTerracotta
        static let gold    = Color.cGold
        static let cream   = Color.cCream
        static let blush   = Color.cBlush
        static let sage    = Color.cSage
        static let muted   = Color.cMuted
        static let stone   = Color.cStone
        static let navy    = Color.cNavy
    }
}

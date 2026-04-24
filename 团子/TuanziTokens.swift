import SwiftUI
import Combine

// MARK: - Token Store (支持 DEBUG 实时调参)

class TokenStore: ObservableObject {
    static let shared = TokenStore()
    @Published var revision: Int = 0
    func bump() { revision += 1 }
}

// MARK: - TuanziTokens 样式 Token 系统

struct TuanziTokens {

    // MARK: Colors

    struct Colors {
        // 背景 — 微妙的蓝紫色调深色底，避免纯黑带来的沉闷
        static var windowBg        = Color(red: 0.10, green: 0.10, blue: 0.13)
        static var windowBgNS      = NSColor(red: 0.10, green: 0.10, blue: 0.13, alpha: 1)
        static var sidebarBg       = Color(red: 0.06, green: 0.06, blue: 0.09)
        static var panelBg         = Color(red: 0.08, green: 0.08, blue: 0.11)
        static var dialogBg        = Color(red: 0.11, green: 0.11, blue: 0.14)
        static var groupBg         = Color.white.opacity(0.04)
        static var commandBg       = Color.black.opacity(0.35)
        static var countdownBg     = NSColor(red: 0, green: 0, blue: 0, alpha: 0.55)
        static var glassBg         = Color.white.opacity(0.06)
        static var glassStroke     = Color.white.opacity(0.12)

        // 文字 — 更柔和的分层
        static var textPrimary     = Color.white.opacity(0.92)
        static var textSecondary   = Color.white.opacity(0.62)
        static var textTertiary    = Color.white.opacity(0.42)
        static var textDimmed      = Color.white.opacity(0.22)
        static var textMuted       = Color.white.opacity(0.36)
        static var textSubtle      = Color.white.opacity(0.56)
        static var textCode        = Color(red: 0.75, green: 0.88, blue: 1.0).opacity(0.85)
        static var textHeader      = Color.white.opacity(0.88)
        static var textIcon        = Color.white.opacity(0.50)
        static var textLabel       = Color.white.opacity(0.68)

        // 强调色 — 更鲜艳饱和，猫咪风格的暖色点缀
        static var accentCyan      = Color(red: 0.30, green: 0.82, blue: 1.0)
        static var accentCyanBright = Color(red: 0.15, green: 0.78, blue: 1.0)
        static var accentCyanSoft  = Color(red: 0.25, green: 0.72, blue: 1.0)
        static var accentOrange    = Color(red: 1.0, green: 0.58, blue: 0.18)
        static var accentWarning   = Color(red: 1.0, green: 0.72, blue: 0.22)
        static var accentGreen     = Color(red: 0.20, green: 0.78, blue: 0.50)
        static var accentGreenSoft = Color(red: 0.30, green: 0.85, blue: 0.55)
        static var accentBlue      = Color(red: 0.30, green: 0.58, blue: 1.0)
        static var accentBlueSoft  = Color(red: 0.25, green: 0.62, blue: 0.98)
        static var accentRed       = Color(red: 1.0, green: 0.35, blue: 0.35)
        static var accentPurple    = Color(red: 0.68, green: 0.42, blue: 1.0)
        static var accentPink      = Color(red: 1.0, green: 0.30, blue: 0.65)

        // 状态指示 — 更生动
        static var statusGreen     = Color(red: 0.25, green: 0.88, blue: 0.55)
        static var statusGray      = Color(red: 0.45, green: 0.45, blue: 0.50)
        static var statusRedDim    = Color(red: 1.0, green: 0.35, blue: 0.35).opacity(0.55)

        // 分割线 / 边框 — 毛玻璃质感
        static var divider         = Color.white.opacity(0.07)
        static var border          = Color.white.opacity(0.10)
        static var borderStroke    = Color(NSColor.separatorColor)

        // 按钮 / 交互 — 更明显的悬停反馈
        static var buttonHover     = Color.white.opacity(0.10)
        static var buttonDimBg     = Color.white.opacity(0.06)
        static var buttonCountBg   = Color.white.opacity(0.10)
        static var selectedBorder  = Color.white.opacity(0.55)

        // Tab icon 颜色 — 更鲜艳统一
        static var tabGeneral      = Color(red: 0.55, green: 0.58, blue: 0.68)
        static var tabAgents       = Color(red: 0.68, green: 0.42, blue: 1.0)
        static var tabReminder     = Color(red: 1.0, green: 0.35, blue: 0.35)
        static var tabShortcuts    = Color(red: 1.0, green: 0.30, blue: 0.65)
        static var tabAbout        = Color(red: 0.30, green: 0.62, blue: 1.0)
        static var tabContact      = Color(red: 0.30, green: 0.85, blue: 0.55)
    }

    // MARK: Spacing

    struct Spacing {
        static var xs:  CGFloat = 2
        static var sm:  CGFloat = 4
        static var md:  CGFloat = 8
        static var lg:  CGFloat = 12
        static var xl:  CGFloat = 16
        static var xxl: CGFloat = 20
        static var xxxl: CGFloat = 30
        static var contentInset: CGFloat = 40

        static var rowH:  CGFloat = 10
        static var rowV:  CGFloat = 11
        static var groupLabelLeading: CGFloat = 16
        static var groupLabelBottom: CGFloat = 6
    }

    // MARK: Radius

    struct Radius {
        static var xs:     CGFloat = 5
        static var sm:     CGFloat = 6
        static var md:     CGFloat = 8
        static var lg:     CGFloat = 10
        static var xl:     CGFloat = 12
        static var xxl:    CGFloat = 14
        static var dialog: CGFloat = 18
        static var appIcon: CGFloat = 16
    }

    // MARK: Fonts

    struct Fonts {
        static var tiny:       Font = .system(size: 8)
        static var micro:      Font = .system(size: 9, weight: .bold)
        static var caption:    Font = .system(size: 10)
        static var captionMono: Font = .system(size: 10, design: .monospaced)
        static var captionMed: Font = .system(size: 10, weight: .medium)
        static var footnote:   Font = .system(size: 11)
        static var footnoteMed: Font = .system(size: 11, weight: .medium)
        static var footnoteBold: Font = .system(size: 11, weight: .bold)
        static var body:       Font = .system(size: 12)
        static var bodyMed:    Font = .system(size: 12, weight: .medium)
        static var bodyMono:   Font = .system(size: 12, design: .monospaced)
        static var bodySemi:   Font = .system(size: 12, weight: .semibold)
        static var control:    Font = .system(size: 13)
        static var controlMed: Font = .system(size: 13, weight: .medium)
        static var controlSemi: Font = .system(size: 13, weight: .semibold)
        static var headline:   Font = .system(size: 14, weight: .semibold)
        static var subheading: Font = .system(size: 15, weight: .semibold)
        static var icon:       Font = .system(size: 18, weight: .medium)
        static var title:      Font = .system(size: 22, weight: .bold)
        static var largeIcon:  Font = .system(size: 28)

        // SidebarButton 用
        static var sidebarIcon: Font = .system(size: 11, weight: .semibold)
        static var sidebarLabel: Font = .system(size: 13)

        // KeyCapture 用
        static var keyCap: Font = .system(size: 12, weight: .medium, design: .monospaced)
        static var keyCapSemi: Font = .system(size: 13, weight: .semibold, design: .monospaced)
    }

    // MARK: Layout

    struct Layout {
        static var settingsWidth:  CGFloat = 680
        static var settingsHeight: CGFloat = 500
        static var sidebarWidth:   CGFloat = 200
        static var dialogWidth:    CGFloat = 320
        static var questionWidth:  CGFloat = 340
        static var panelWidth:     CGFloat = 420
        static var panelMaxHeight: CGFloat = 280

        static var appIconSize:    CGFloat = 70
        static var sidebarIconBox: CGFloat = 20
        static var statusDotSize:  CGFloat = 7
        static var spinnerSize:    CGFloat = 13
        static var checkSize:      CGFloat = 9
        static var idleDotSize:    CGFloat = 7
        static var sessionIconSize: CGFloat = 14
        static var radioSize:      CGFloat = 16
        static var radioInner:     CGFloat = 9
        static var optionNumSize:  CGFloat = 20
        static var qrMaxSize:      CGFloat = 220

        static var settingsAppIcon: CGFloat = 40
        static var settingsAppIconRadius: CGFloat = 9

        static var toggleScale:    CGFloat = 0.7
        static var strokeWidth:    CGFloat = 0.5
        static var borderWidth:    CGFloat = 1.0
        static var radioBorderWidth: CGFloat = 1.5
    }

    // MARK: Animation

    struct Animation {
        static var spinnerDuration: Double = 0.8
        static var panelSlide:    Double = 0.25
        static var hoverDefault:  Double = 0.4
    }

    // MARK: Shadow

    struct Shadow {
        static var panelColor  = Color.black.opacity(0.45)
        static var panelRadius: CGFloat = 24
        static var panelY:      CGFloat = 8
        static var dialogColor = Color.black.opacity(0.55)
        static var dialogRadius: CGFloat = 30
        static var dialogY:     CGFloat = 10
        static var glowColor   = Color(red: 0.3, green: 0.6, blue: 1.0).opacity(0.08)
        static var glowRadius: CGFloat = 40
    }
}

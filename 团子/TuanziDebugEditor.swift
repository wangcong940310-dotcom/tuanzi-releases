import SwiftUI

#if DEBUG

// MARK: - Token Debug Editor

@available(macOS 13.0, *)
struct TokenDebugEditor: View {
    @ObservedObject private var store = TokenStore.shared
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            Button(action: { withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() } }) {
                HStack(spacing: 4) {
                    Image(systemName: "paintbrush.fill")
                        .font(.system(size: 10))
                    Text("Tokens")
                        .font(.system(size: 10, weight: .medium))
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 8))
                }
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(Color.black.opacity(0.6))
                .cornerRadius(6)
            }
            .buttonStyle(.plain)

            if isExpanded {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        sectionHeader("Colors")
                        colorRow("Window BG", get: { TuanziTokens.Colors.windowBg }, set: { TuanziTokens.Colors.windowBg = $0 })
                        colorRow("Sidebar BG", get: { TuanziTokens.Colors.sidebarBg }, set: { TuanziTokens.Colors.sidebarBg = $0 })
                        colorRow("Panel BG", get: { TuanziTokens.Colors.panelBg }, set: { TuanziTokens.Colors.panelBg = $0 })
                        colorRow("Dialog BG", get: { TuanziTokens.Colors.dialogBg }, set: { TuanziTokens.Colors.dialogBg = $0 })
                        colorRow("Accent Cyan", get: { TuanziTokens.Colors.accentCyan }, set: { TuanziTokens.Colors.accentCyan = $0 })
                        colorRow("Accent Orange", get: { TuanziTokens.Colors.accentOrange }, set: { TuanziTokens.Colors.accentOrange = $0 })
                        colorRow("Accent Green", get: { TuanziTokens.Colors.accentGreen }, set: { TuanziTokens.Colors.accentGreen = $0 })
                        colorRow("Accent Blue", get: { TuanziTokens.Colors.accentBlue }, set: { TuanziTokens.Colors.accentBlue = $0 })

                        sectionHeader("Spacing")
                        sliderRow("XS", get: { TuanziTokens.Spacing.xs }, set: { TuanziTokens.Spacing.xs = $0 }, range: 0...8)
                        sliderRow("SM", get: { TuanziTokens.Spacing.sm }, set: { TuanziTokens.Spacing.sm = $0 }, range: 0...12)
                        sliderRow("MD", get: { TuanziTokens.Spacing.md }, set: { TuanziTokens.Spacing.md = $0 }, range: 2...16)
                        sliderRow("LG", get: { TuanziTokens.Spacing.lg }, set: { TuanziTokens.Spacing.lg = $0 }, range: 4...24)
                        sliderRow("XL", get: { TuanziTokens.Spacing.xl }, set: { TuanziTokens.Spacing.xl = $0 }, range: 8...32)
                        sliderRow("XXL", get: { TuanziTokens.Spacing.xxl }, set: { TuanziTokens.Spacing.xxl = $0 }, range: 12...40)
                        sliderRow("Content", get: { TuanziTokens.Spacing.contentInset }, set: { TuanziTokens.Spacing.contentInset = $0 }, range: 16...60)

                        sectionHeader("Radius")
                        sliderRow("XS", get: { TuanziTokens.Radius.xs }, set: { TuanziTokens.Radius.xs = $0 }, range: 0...12)
                        sliderRow("SM", get: { TuanziTokens.Radius.sm }, set: { TuanziTokens.Radius.sm = $0 }, range: 0...12)
                        sliderRow("MD", get: { TuanziTokens.Radius.md }, set: { TuanziTokens.Radius.md = $0 }, range: 0...16)
                        sliderRow("LG", get: { TuanziTokens.Radius.lg }, set: { TuanziTokens.Radius.lg = $0 }, range: 0...20)
                        sliderRow("XL", get: { TuanziTokens.Radius.xl }, set: { TuanziTokens.Radius.xl = $0 }, range: 0...24)
                        sliderRow("Dialog", get: { TuanziTokens.Radius.dialog }, set: { TuanziTokens.Radius.dialog = $0 }, range: 0...32)

                        HStack {
                            Button("Reset All") { resetAllTokens(); store.bump() }
                                .font(.system(size: 11))
                            Spacer()
                            Text("rev \(store.revision)")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.white.opacity(0.3))
                        }
                        .padding(.top, 8)
                    }
                    .padding(12)
                }
                .frame(width: 240)
                .frame(maxHeight: 400)
                .background(Color.black.opacity(0.85))
                .cornerRadius(8)
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(.white.opacity(0.4))
            .padding(.top, 4)
    }

    private func colorRow(_ label: String, get: @escaping () -> Color, set: @escaping (Color) -> Void) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 100, alignment: .leading)
            ColorPicker("", selection: Binding(get: get, set: { set($0); store.bump() }))
                .labelsHidden()
        }
    }

    private func sliderRow(_ label: String, get: @escaping () -> CGFloat, set: @escaping (CGFloat) -> Void, range: ClosedRange<CGFloat>) -> some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 60, alignment: .leading)
            Slider(value: Binding(
                get: get,
                set: { set($0); store.bump() }
            ), in: range)
            Text("\(Int(get()))")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.white.opacity(0.5))
                .frame(width: 24, alignment: .trailing)
        }
    }

    private func resetAllTokens() {
        TuanziTokens.Colors.windowBg = Color(red: 0.12, green: 0.12, blue: 0.14)
        TuanziTokens.Colors.sidebarBg = Color(red: 0.07, green: 0.07, blue: 0.09)
        TuanziTokens.Colors.panelBg = Color(red: 0.1, green: 0.1, blue: 0.1)
        TuanziTokens.Colors.dialogBg = Color(red: 0.13, green: 0.13, blue: 0.15)
        TuanziTokens.Colors.accentCyan = Color(red: 0.4, green: 0.8, blue: 1.0)
        TuanziTokens.Colors.accentOrange = Color(red: 1.0, green: 0.6, blue: 0.15)
        TuanziTokens.Colors.accentGreen = Color(red: 0.15, green: 0.72, blue: 0.45)
        TuanziTokens.Colors.accentBlue = Color(red: 0.25, green: 0.55, blue: 1.0)
        TuanziTokens.Spacing.xs = 2; TuanziTokens.Spacing.sm = 4
        TuanziTokens.Spacing.md = 8; TuanziTokens.Spacing.lg = 12
        TuanziTokens.Spacing.xl = 16; TuanziTokens.Spacing.xxl = 20
        TuanziTokens.Spacing.contentInset = 40
        TuanziTokens.Radius.xs = 4; TuanziTokens.Radius.sm = 5
        TuanziTokens.Radius.md = 6; TuanziTokens.Radius.lg = 8
        TuanziTokens.Radius.xl = 10; TuanziTokens.Radius.dialog = 16
    }
}

#endif

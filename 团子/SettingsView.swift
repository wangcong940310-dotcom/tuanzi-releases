import Cocoa
import SwiftUI
import Combine
import ServiceManagement

// MARK: - PetSettings 持久化设置

class PetSettings: ObservableObject {
    static let shared = PetSettings()

    @Published var launchAtLogin: Bool          { didSet { save("launchAtLogin", launchAtLogin);       applyLaunchAtLogin() } }
    @Published var showPanelOnHover: Bool       { didSet { save("showPanelOnHover", showPanelOnHover); notify() } }
    @Published var hoverDelay: Double           { didSet { save("hoverDelay", hoverDelay);             notify() } }
    @Published var idleTimeout: Double          { didSet { save("idleTimeout", idleTimeout);           notify() } }
    @Published var typingTimeout: Double        { didSet { save("typingTimeout", typingTimeout);       notify() } }
    @Published var enableCompletionSound: Bool  { didSet { save("enableCompletionSound", enableCompletionSound) } }
    @Published var enableFeishuMonitor: Bool    { didSet { save("enableFeishuMonitor", enableFeishuMonitor);   notify() } }
    // 快捷键
    @Published var permissionModifier: String   { didSet { save("permissionModifier", permissionModifier) } }
    @Published var shortcutApprove: String      { didSet { save("shortcutApprove", shortcutApprove) } }
    @Published var shortcutDeny: String         { didSet { save("shortcutDeny", shortcutDeny) } }
    @Published var shortcutAlwaysAllow: String  { didSet { save("shortcutAlwaysAllow", shortcutAlwaysAllow) } }
    @Published var shortcutAutoApprove: String  { didSet { save("shortcutAutoApprove", shortcutAutoApprove) } }
    @Published var shortcutFocusTerminal: String { didSet { save("shortcutFocusTerminal", shortcutFocusTerminal) } }

    private init() {
        let d = UserDefaults.standard
        launchAtLogin          = d.object(forKey: "launchAtLogin")          as? Bool   ?? false
        showPanelOnHover       = d.object(forKey: "showPanelOnHover")       as? Bool   ?? true
        hoverDelay             = d.object(forKey: "hoverDelay")             as? Double ?? 0.4
        idleTimeout            = d.object(forKey: "idleTimeout")            as? Double ?? 25.0
        typingTimeout          = d.object(forKey: "typingTimeout")          as? Double ?? 3.0
        enableCompletionSound  = d.object(forKey: "enableCompletionSound")  as? Bool   ?? true
        enableFeishuMonitor    = d.object(forKey: "enableFeishuMonitor")    as? Bool   ?? true
        permissionModifier     = d.object(forKey: "permissionModifier")     as? String ?? "control"
        shortcutApprove        = d.object(forKey: "shortcutApprove")        as? String ?? "y"
        shortcutDeny           = d.object(forKey: "shortcutDeny")           as? String ?? "n"
        shortcutAlwaysAllow    = d.object(forKey: "shortcutAlwaysAllow")    as? String ?? "a"
        shortcutAutoApprove    = d.object(forKey: "shortcutAutoApprove")    as? String ?? "b"
        shortcutFocusTerminal  = d.object(forKey: "shortcutFocusTerminal")  as? String ?? "t"
    }

    private func save(_ key: String, _ value: Any) { UserDefaults.standard.set(value, forKey: key) }
    private func notify() { NotificationCenter.default.post(name: .petSettingsChanged, object: nil) }

    private func applyLaunchAtLogin() {
        if #available(macOS 13.0, *) {
            do {
                if launchAtLogin { try SMAppService.mainApp.register() }
                else             { try SMAppService.mainApp.unregister() }
            } catch { print("⚠️ 登录启动设置失败: \(error)") }
        }
    }
}

extension Notification.Name {
    static let petSettingsChanged = Notification.Name("petSettingsChanged")
}

// MARK: - SettingsWindowController

class SettingsWindowController: NSWindowController {
    static let shared = SettingsWindowController()

    private init() {
        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 780, height: 520),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        win.title = "团子"
        win.titlebarAppearsTransparent = false
        win.isReleasedWhenClosed = false
        if #available(macOS 13.0, *) {
            win.contentView = NSHostingView(rootView: SettingsRootView())
        }
        super.init(window: win)
    }
    required init?(coder: NSCoder) { fatalError() }

    func open() {
        window?.center()
        showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

// MARK: - SettingsRootView

private enum SettingsTab: String, CaseIterable, Identifiable {
    case general   = "通用"
    case reminder  = "提醒"
    case shortcuts = "快捷键"
    case about     = "关于"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .general:   return "gearshape.fill"
        case .reminder:  return "bell.badge.fill"
        case .shortcuts: return "keyboard.fill"
        case .about:     return "info.circle.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .general:   return Color(red: 0.55, green: 0.55, blue: 0.60)
        case .reminder:  return Color(red: 0.95, green: 0.30, blue: 0.30)
        case .shortcuts: return Color(red: 0.95, green: 0.25, blue: 0.65)
        case .about:     return Color(red: 0.20, green: 0.60, blue: 0.95)
        }
    }

    var description: String {
        switch self {
        case .general:   return "登录启动、消息监听等基本设置"
        case .reminder:  return "任务完成提示音与通知偏好"
        case .shortcuts: return "权限弹窗的键盘快捷键"
        case .about:     return "团子版本信息"
        }
    }
}

@available(macOS 13.0, *)
struct SettingsRootView: View {
    @State private var selected: SettingsTab = .general

    var body: some View {
        HStack(spacing: 0) {
            // MARK: 侧边栏
            VStack(alignment: .leading, spacing: 2) {
                ForEach(SettingsTab.allCases) { tab in
                    SidebarButton(tab: tab, isSelected: selected == tab) {
                        selected = tab
                    }
                }
                Spacer()
            }
            .padding(.top, 12)
            .padding(.horizontal, 8)
            .frame(width: 160)
            .background(.background)

            Divider()

            // MARK: 内容区
            DetailView(tab: selected)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 650, height: 480)
    }
}

@available(macOS 13.0, *)
private struct SidebarButton: View {
    let tab: SettingsTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(tab.iconColor)
                        .frame(width: 20, height: 20)
                    Image(systemName: tab.icon)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                }
                Text(tab.rawValue)
                    .font(.system(size: 13))
                    .foregroundStyle(isSelected ? .white : .primary)
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(isSelected ? Color.accentColor : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 内容区公共结构

@available(macOS 13.0, *)
private struct DetailView: View {
    let tab: SettingsTab
    @StateObject private var settings = PetSettings.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 顶部 header
                VStack(spacing: 6) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(tab.iconColor)
                            .frame(width: 56, height: 56)
                        Image(systemName: tab.icon)
                            .font(.system(size: 26, weight: .medium))
                            .foregroundStyle(.white)
                    }
                    .padding(.bottom, 2)
                    Text(tab.rawValue)
                        .font(.system(size: 20, weight: .bold))
                    Text(tab.description)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 32)
                .padding(.bottom, 20)

                Divider()

                // 内容
                VStack(spacing: 16) {
                    switch tab {
                    case .general:   GeneralPane(settings: settings)
                    case .reminder:  ReminderPane(settings: settings)
                    case .shortcuts: ShortcutsPane(settings: settings)
                    case .about:     AboutPane()
                    }
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - 分组容器

private struct SettingsGroup<Content: View>: View {
    var label: String? = nil
    let content: Content
    init(label: String? = nil, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let label {
                Text(label.uppercased())
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                    .padding(.leading, 16)
                    .padding(.bottom, 6)
            }
            VStack(spacing: 0) { content }
                .background(.quaternary.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(.separator, lineWidth: 0.5))
        }
    }
}

private struct RowDivider: View {
    var body: some View {
        Divider().padding(.leading, 16)
    }
}

private struct ToggleRow: View {
    let title: String
    var subtitle: String? = nil
    @Binding var value: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 13))
                if let sub = subtitle {
                    Text(sub).font(.system(size: 11)).foregroundStyle(.secondary)
                }
            }
            Spacer()
            Toggle("", isOn: $value).labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, subtitle != nil ? 10 : 11)
    }
}

private struct SliderRow: View {
    let title: String
    let range: ClosedRange<Double>
    let unit: String
    let step: Double
    let decimals: Int
    @Binding var value: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title).font(.system(size: 13))
                Spacer()
                Text(decimals == 0 ? "\(Int(value))\(unit)" : String(format: "%.\(decimals)f\(unit)", value))
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            Slider(value: $value, in: range, step: step)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - 各分页内容

private struct GeneralPane: View {
    @ObservedObject var settings: PetSettings
    var body: some View {
        SettingsGroup(label: "系统") {
            ToggleRow(title: "登录时打开", value: $settings.launchAtLogin)
        }
        SettingsGroup(label: "IM 监听") {
            ToggleRow(
                title: "监听飞书消息角标",
                subtitle: "有新消息时播放动画与声音提醒",
                value: $settings.enableFeishuMonitor
            )
        }
    }
}

private struct PanelPane: View {
    @ObservedObject var settings: PetSettings
    var body: some View {
        SettingsGroup(label: "展开") {
            ToggleRow(
                title: "悬停时展开面板",
                subtitle: "吸附侧边后，鼠标悬停自动弹出终端会话列表",
                value: $settings.showPanelOnHover
            )
            RowDivider()
            SliderRow(title: "悬停延迟", range: 0.1...2.0, unit: "s", step: 0.05, decimals: 2, value: $settings.hoverDelay)
        }
    }
}

private struct ReminderPane: View {
    @ObservedObject var settings: PetSettings
    var body: some View {
        SettingsGroup(label: "声音") {
            ToggleRow(
                title: "任务完成提示音",
                subtitle: "Claude 完成任务时播放提示音",
                value: $settings.enableCompletionSound
            )
        }
    }
}

private struct AnimationPane: View {
    @ObservedObject var settings: PetSettings
    var body: some View {
        SettingsGroup(label: "睡眠") {
            SliderRow(title: "空闲超时", range: 10...120, unit: "s", step: 5, decimals: 0, value: $settings.idleTimeout)
        }
        SettingsGroup(label: "打字") {
            SliderRow(title: "打字停止超时", range: 1...15, unit: "s", step: 1, decimals: 0, value: $settings.typingTimeout)
        }
    }
}

// MARK: - 快捷键自定义组件

private struct KeyBadge: View {
    let label: String
    var body: some View {
        Text(label)
            .font(.system(size: 12, weight: .medium, design: .monospaced))
            .foregroundStyle(.primary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.quaternary)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(.separator, lineWidth: 0.5))
    }
}

private struct KeyCaptureButton: View {
    @Binding var key: String
    @State private var isCapturing = false
    @State private var monitor: Any?

    var body: some View {
        Button(action: startCapture) {
            Text(isCapturing ? "·" : key.uppercased())
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .frame(minWidth: 32)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(isCapturing ? Color.accentColor.opacity(0.15) : Color(.controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(isCapturing ? Color.accentColor : Color(.separatorColor), lineWidth: 0.5))
        }
        .buttonStyle(.plain)
    }

    private func startCapture() {
        isCapturing = true
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            defer {
                isCapturing = false
                if let m = self.monitor { NSEvent.removeMonitor(m); self.monitor = nil }
            }
            if event.keyCode == 53 { return nil } // ESC 取消
            guard let char = event.charactersIgnoringModifiers?.lowercased(),
                  char.count == 1,
                  let first = char.first,
                  first.isLetter || first.isNumber
            else { return nil }
            self.key = char
            return nil
        }
    }
}

private struct CustomShortcutRow: View {
    let title: String
    let modSymbol: String
    @Binding var key: String

    var body: some View {
        HStack {
            Text(title).font(.system(size: 13))
            Spacer()
            HStack(spacing: 4) {
                KeyBadge(label: modSymbol)
                Text("+").font(.system(size: 11)).foregroundStyle(.secondary)
                KeyCaptureButton(key: $key)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

private struct ShortcutsPane: View {
    @ObservedObject var settings: PetSettings

    private var modSymbol: String {
        switch settings.permissionModifier {
        case "option":  return "⌥"
        case "command": return "⌘"
        default:        return "⌃"
        }
    }

    var body: some View {
        // 修饰键
        SettingsGroup(label: "修饰键") {
            HStack {
                Text("修饰键").font(.system(size: 13))
                Spacer()
                Picker("", selection: $settings.permissionModifier) {
                    Text("⌃ Control").tag("control")
                    Text("⌥ Option").tag("option")
                    Text("⌘ Command").tag("command")
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .frame(width: 130)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }

        // 权限弹窗快捷键
        SettingsGroup(label: "权限弹窗") {
            CustomShortcutRow(title: "批准",       modSymbol: modSymbol, key: $settings.shortcutApprove)
            RowDivider()
            CustomShortcutRow(title: "拒绝",       modSymbol: modSymbol, key: $settings.shortcutDeny)
            RowDivider()
            CustomShortcutRow(title: "始终允许",   modSymbol: modSymbol, key: $settings.shortcutAlwaysAllow)
            RowDivider()
            CustomShortcutRow(title: "自动批准权限", modSymbol: modSymbol, key: $settings.shortcutAutoApprove)
            RowDivider()
            CustomShortcutRow(title: "跳转到终端", modSymbol: modSymbol, key: $settings.shortcutFocusTerminal)
        }

        Text("点击字母可重新绑定。自动批准后续不再弹窗，重启重置。")
            .font(.system(size: 11))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 4)
    }
}

private struct AboutPane: View {
    var body: some View {
        SettingsGroup {
            HStack(spacing: 14) {
                Text("🐱").font(.system(size: 36))
                VStack(alignment: .leading, spacing: 3) {
                    Text("团子").font(.system(size: 14, weight: .semibold))
                    Text("版本 1.0.0").font(.system(size: 12)).foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            RowDivider()
            HStack {
                Text("Webhook 端口").font(.system(size: 13))
                Spacer()
                Text("23333")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            RowDivider()
            HStack {
                Text("开发者").font(.system(size: 13))
                Spacer()
                Text("王聪").font(.system(size: 12)).foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
        }
    }
}

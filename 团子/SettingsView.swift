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
        win.title = ""
        win.titlebarAppearsTransparent = true
        win.titleVisibility = .hidden
        win.isReleasedWhenClosed = false
        win.backgroundColor = .windowBackgroundColor
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
        if let titlebarView = window?.standardWindowButton(.closeButton)?.superview {
            titlebarView.wantsLayer = true
            for button in [NSWindow.ButtonType.closeButton, .miniaturizeButton, .zoomButton] {
                if let btn = window?.standardWindowButton(button) {
                    var f = btn.frame
                    f.origin.x += 12
                    f.origin.y -= 6
                    btn.frame = f
                }
            }
        }
    }
}

// MARK: - SettingsRootView

private enum SettingsTab: String, CaseIterable, Identifiable {
    case general   = "通用"
    case agents    = "AI 助手"
    case reminder  = "提醒"
    case shortcuts = "快捷键"
    case about     = "关于"
    case contact   = "反馈"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .general:   return "gearshape.fill"
        case .agents:    return "cpu.fill"
        case .reminder:  return "bell.badge.fill"
        case .shortcuts: return "keyboard.fill"
        case .about:     return "info.circle.fill"
        case .contact:   return "bubble.left.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .general:   return TuanziTokens.Colors.tabGeneral
        case .agents:    return TuanziTokens.Colors.tabAgents
        case .reminder:  return TuanziTokens.Colors.tabReminder
        case .shortcuts: return TuanziTokens.Colors.tabShortcuts
        case .about:     return TuanziTokens.Colors.tabAbout
        case .contact:   return TuanziTokens.Colors.tabContact
        }
    }

    var description: String {
        switch self {
        case .general:   return "登录启动、消息监听等基本设置"
        case .agents:    return "管理 AI 助手 Hook 安装状态"
        case .reminder:  return "任务完成提示音与通知偏好"
        case .shortcuts: return "权限弹窗的键盘快捷键"
        case .about:     return "团子版本信息"
        case .contact:   return "问题反馈与建议"
        }
    }
}

@available(macOS 13.0, *)
struct SettingsRootView: View {
    @State private var selected: SettingsTab = .general

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                if let appIcon = NSImage(named: "AppIcon") {
                    Image(nsImage: appIcon)
                        .resizable()
                        .frame(width: TuanziTokens.Layout.appIconSize, height: TuanziTokens.Layout.appIconSize)
                        .clipShape(RoundedRectangle(cornerRadius: TuanziTokens.Radius.appIcon))
                        .padding(.bottom, 8)
                        .frame(maxWidth: .infinity)
                }
                ForEach(SettingsTab.allCases) { tab in
                    SidebarButton(tab: tab, isSelected: selected == tab) {
                        selected = tab
                    }
                }
                Spacer()
            }
            .padding(.top, TuanziTokens.Spacing.xxxl)
            .padding(.horizontal, TuanziTokens.Spacing.rowH)
            .padding(.bottom, TuanziTokens.Spacing.rowH)
            .frame(width: TuanziTokens.Layout.sidebarWidth)
            .frame(maxHeight: .infinity)
            .background(Color(.windowBackgroundColor).opacity(0.95))

            DetailView(tab: selected)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: TuanziTokens.Layout.settingsWidth, height: TuanziTokens.Layout.settingsHeight)
        .background(Color(.windowBackgroundColor))
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
                    RoundedRectangle(cornerRadius: TuanziTokens.Radius.sm)
                        .fill(tab.iconColor)
                        .frame(width: TuanziTokens.Layout.sidebarIconBox, height: TuanziTokens.Layout.sidebarIconBox)
                    Image(systemName: tab.icon)
                        .font(TuanziTokens.Fonts.sidebarIcon)
                        .foregroundColor(.white)
                }
                Text(tab.rawValue)
                    .font(TuanziTokens.Fonts.control)
                    .foregroundStyle(isSelected ? .white : .primary)
                Spacer()
            }
            .padding(.horizontal, TuanziTokens.Spacing.md)
            .padding(.vertical, 5)
            .background(isSelected ? Color.accentColor : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: TuanziTokens.Radius.md))
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
                Text(tab.rawValue)
                    .font(TuanziTokens.Fonts.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, TuanziTokens.Spacing.xxl)
                    .padding(.bottom, TuanziTokens.Spacing.lg)
                    .padding(.horizontal, TuanziTokens.Spacing.contentInset)

                // 内容
                VStack(spacing: 16) {
                    switch tab {
                    case .general:   GeneralPane(settings: settings)
                    case .agents:    AgentsPane()
                    case .reminder:  ReminderPane(settings: settings)
                    case .shortcuts: ShortcutsPane(settings: settings)
                    case .about:     AboutPane()
                    case .contact:   ContactPane()
                    }
                }
                .padding(.horizontal, TuanziTokens.Spacing.contentInset)
                .padding(.vertical, TuanziTokens.Spacing.xxl)
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
                    .font(TuanziTokens.Fonts.footnoteMed)
                    .foregroundStyle(.secondary)
                    .padding(.leading, TuanziTokens.Spacing.groupLabelLeading)
                    .padding(.bottom, TuanziTokens.Spacing.groupLabelBottom)
            }
            VStack(spacing: 0) { content }
                .background(Color(.controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: TuanziTokens.Radius.xl))
                .overlay(RoundedRectangle(cornerRadius: TuanziTokens.Radius.xl).stroke(Color(.separatorColor), lineWidth: TuanziTokens.Layout.strokeWidth))
        }
    }
}

private struct RowDivider: View {
    var body: some View {
        Divider().padding(.leading, TuanziTokens.Spacing.groupLabelLeading)
    }
}

private struct ToggleRow: View {
    let title: String
    var subtitle: String? = nil
    @Binding var value: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(TuanziTokens.Fonts.control)
                if let sub = subtitle {
                    Text(sub).font(TuanziTokens.Fonts.footnote).foregroundStyle(.secondary)
                }
            }
            Spacer()
            Toggle("", isOn: $value).labelsHidden().toggleStyle(.switch).scaleEffect(TuanziTokens.Layout.toggleScale, anchor: .trailing)
        }
        .padding(.horizontal, TuanziTokens.Spacing.xl)
        .padding(.vertical, subtitle != nil ? TuanziTokens.Spacing.rowH : TuanziTokens.Spacing.rowV)
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
                Text(title).font(TuanziTokens.Fonts.control)
                Spacer()
                Text(decimals == 0 ? "\(Int(value))\(unit)" : String(format: "%.\(decimals)f\(unit)", value))
                    .font(TuanziTokens.Fonts.bodyMono)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            Slider(value: $value, in: range, step: step)
        }
        .padding(.horizontal, TuanziTokens.Spacing.xl)
        .padding(.vertical, TuanziTokens.Spacing.lg)
    }
}

// MARK: - 各分页内容

private struct GeneralPane: View {
    @ObservedObject var settings: PetSettings
    var body: some View {
        SettingsGroup(label: "系统") {
            ToggleRow(title: "登录时打开", value: $settings.launchAtLogin)
        }
        SettingsGroup(label: "侧边面板") {
            ToggleRow(
                title: "悬停时展开面板",
                subtitle: "吸附侧边后，鼠标悬停自动弹出终端会话列表",
                value: $settings.showPanelOnHover
            )
            RowDivider()
            SliderRow(title: "悬停延迟", range: 0.1...2.0, unit: "s", step: 0.05, decimals: 2, value: $settings.hoverDelay)
        }
        SettingsGroup(label: "动画") {
            SliderRow(title: "空闲超时", range: 10...120, unit: "s", step: 5, decimals: 0, value: $settings.idleTimeout)
            RowDivider()
            SliderRow(title: "打字停止超时", range: 1...15, unit: "s", step: 1, decimals: 0, value: $settings.typingTimeout)
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
            .font(TuanziTokens.Fonts.keyCap)
            .foregroundStyle(.primary)
            .padding(.horizontal, TuanziTokens.Spacing.md)
            .padding(.vertical, TuanziTokens.Spacing.sm)
            .background(.quaternary)
            .clipShape(RoundedRectangle(cornerRadius: TuanziTokens.Radius.md))
            .overlay(RoundedRectangle(cornerRadius: TuanziTokens.Radius.md).stroke(TuanziTokens.Colors.borderStroke, lineWidth: TuanziTokens.Layout.strokeWidth))
    }
}

private struct KeyCaptureButton: View {
    @Binding var key: String
    @State private var isCapturing = false
    @State private var monitor: Any?

    var body: some View {
        Button(action: startCapture) {
            Text(isCapturing ? "·" : key.uppercased())
                .font(TuanziTokens.Fonts.keyCapSemi)
                .frame(minWidth: 32)
                .padding(.horizontal, TuanziTokens.Spacing.md)
                .padding(.vertical, TuanziTokens.Spacing.sm)
                .background(isCapturing ? Color.accentColor.opacity(0.15) : Color(.controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: TuanziTokens.Radius.md))
                .overlay(RoundedRectangle(cornerRadius: TuanziTokens.Radius.md).stroke(isCapturing ? Color.accentColor : TuanziTokens.Colors.borderStroke, lineWidth: TuanziTokens.Layout.strokeWidth))
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
            Text(title).font(TuanziTokens.Fonts.control)
            Spacer()
            HStack(spacing: 4) {
                KeyBadge(label: modSymbol)
                Text("+").font(TuanziTokens.Fonts.footnote).foregroundStyle(.secondary)
                KeyCaptureButton(key: $key)
            }
        }
        .padding(.horizontal, TuanziTokens.Spacing.xl)
        .padding(.vertical, TuanziTokens.Spacing.rowH)
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
                Text("修饰键").font(TuanziTokens.Fonts.control)
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
            .padding(.horizontal, TuanziTokens.Spacing.xl)
            .padding(.vertical, TuanziTokens.Spacing.rowH)
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
            .font(TuanziTokens.Fonts.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 4)
    }
}

// MARK: - AI 助手管理

private struct AgentRowData: Identifiable {
    let id: String
    let name: String
    let configPath: String
    let groupLabel: String
}

private struct AgentsPane: View {
    @State private var hookStates: [String: Bool] = [:]
    @State private var dirExists: [String: Bool] = [:]

    private let claudeFamily: [AgentRowData] = [
        AgentRowData(id: "claude", name: "Claude Code", configPath: "~/.claude/settings.json", groupLabel: ""),
        AgentRowData(id: "qoder", name: "Qoder", configPath: "~/.qoder/settings.json", groupLabel: ""),
        AgentRowData(id: "qwen", name: "Qwen Code", configPath: "~/.qwen/settings.json", groupLabel: ""),
        AgentRowData(id: "factory", name: "Factory", configPath: "~/.factory/settings.json", groupLabel: ""),
        AgentRowData(id: "codebuddy", name: "CodeBuddy", configPath: "~/.codebuddy/settings.json", groupLabel: ""),
    ]

    private let otherAgents: [AgentRowData] = [
        AgentRowData(id: "codex", name: "Codex CLI", configPath: "~/.codex/config.toml", groupLabel: ""),
        AgentRowData(id: "gemini", name: "Gemini CLI", configPath: "~/.gemini/settings.json", groupLabel: ""),
        AgentRowData(id: "kimi", name: "Kimi CLI", configPath: "~/.kimi/config.toml", groupLabel: ""),
        AgentRowData(id: "cursor", name: "Cursor", configPath: "~/.cursor/hooks.json", groupLabel: ""),
        AgentRowData(id: "opencode", name: "OpenCode", configPath: "~/.config/opencode/plugins/", groupLabel: ""),
    ]

    var body: some View {
        SettingsGroup(label: "Claude 系列") {
            ForEach(Array(claudeFamily.enumerated()), id: \.element.id) { index, agent in
                if index > 0 { RowDivider() }
                agentRow(agent)
            }
        }

        SettingsGroup(label: "其他 AI 助手") {
            ForEach(Array(otherAgents.enumerated()), id: \.element.id) { index, agent in
                if index > 0 { RowDivider() }
                agentRow(agent)
            }
        }

        Text("开启后，团子会在对应 AI 助手的配置文件中注入 Hook，使团子能响应该助手的状态变化。")
            .font(TuanziTokens.Fonts.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 4)
    }

    private func agentRow(_ agent: AgentRowData) -> some View {
        let exists = dirExists[agent.id] ?? false
        let installed = hookStates[agent.id] ?? false

        return HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(installed ? TuanziTokens.Colors.statusGreen : (exists ? TuanziTokens.Colors.statusGray : TuanziTokens.Colors.statusRedDim))
                        .frame(width: TuanziTokens.Layout.statusDotSize, height: TuanziTokens.Layout.statusDotSize)
                    Text(agent.name).font(TuanziTokens.Fonts.control)
                }
                Text(agent.configPath)
                    .font(TuanziTokens.Fonts.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Toggle("", isOn: Binding(
                get: { hookStates[agent.id] ?? false },
                set: { newValue in
                    hookStates[agent.id] = newValue
                    toggleHook(agentId: agent.id, enabled: newValue)
                }
            ))
            .labelsHidden()
            .toggleStyle(.switch)
            .scaleEffect(TuanziTokens.Layout.toggleScale, anchor: .trailing)
            .disabled(!exists)
        }
        .padding(.horizontal, TuanziTokens.Spacing.xl)
        .padding(.vertical, TuanziTokens.Spacing.rowH)
        .opacity(exists ? 1.0 : 0.5)
        .onAppear { refreshState(agent.id) }
    }

    private func refreshState(_ agentId: String) {
        guard let agent = AgentRegistry.allAgents.first(where: { $0.id == agentId }) else { return }
        let home = NSHomeDirectory()
        let configDir = (home + "/" + agent.configPath) as NSString
        var isDir: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: configDir.deletingLastPathComponent, isDirectory: &isDir) && isDir.boolValue
        dirExists[agentId] = exists

        if exists, let content = try? String(contentsOfFile: home + "/" + agent.configPath, encoding: .utf8) {
            hookStates[agentId] = content.contains(".clawd/hook") || content.contains("127.0.0.1:23333")
        } else {
            hookStates[agentId] = false
        }
    }

    private func toggleHook(agentId: String, enabled: Bool) {
        guard let agent = AgentRegistry.allAgents.first(where: { $0.id == agentId }) else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            if let vc = NSApp.windows.first?.contentViewController as? ViewController {
                if enabled { vc.installHooksForAgent(agent) }
                else { vc.uninstallHooksForAgent(agent) }
            }
        }
    }
}

private struct AboutPane: View {
    @State private var isChecking = false
    @State private var statusText = ""

    private var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    var body: some View {
        SettingsGroup {
            HStack(spacing: 14) {
                if let appIcon = NSImage(named: "AppIcon") {
                    Image(nsImage: appIcon)
                        .resizable()
                        .frame(width: TuanziTokens.Layout.settingsAppIcon, height: TuanziTokens.Layout.settingsAppIcon)
                        .clipShape(RoundedRectangle(cornerRadius: TuanziTokens.Layout.settingsAppIconRadius))
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("团子").font(TuanziTokens.Fonts.headline)
                    Text("版本 \(currentVersion)")
                        .font(TuanziTokens.Fonts.body).foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, TuanziTokens.Spacing.xl)
            .padding(.vertical, 14)
            RowDivider()
            HStack {
                Text("检查更新").font(TuanziTokens.Fonts.control)
                Spacer()
                if !statusText.isEmpty {
                    Text(statusText)
                        .font(TuanziTokens.Fonts.footnote)
                        .foregroundStyle(.secondary)
                }
                Button("检查更新") { checkForUpdate() }
                    .disabled(isChecking)
            }
            .padding(.horizontal, TuanziTokens.Spacing.xl)
            .padding(.vertical, TuanziTokens.Spacing.rowV)
        }
    }

    private func checkForUpdate() {
        isChecking = true
        statusText = "检查中..."
        UpdateChecker.check { result in
            DispatchQueue.main.async {
                isChecking = false
                switch result {
                case .newVersion(let version, let url):
                    statusText = ""
                    showUpdateAlert(version: version, url: url)
                case .upToDate:
                    statusText = "已是最新版本"
                case .error:
                    statusText = "检查失败"
                }
            }
        }
    }

    private func showUpdateAlert(version: String, url: URL) {
        let alert = NSAlert()
        alert.messageText = "发现新版本 \(version)"
        alert.informativeText = "当前版本 \(currentVersion)，点击下载更新。"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "下载更新")
        alert.addButton(withTitle: "稍后")
        if alert.runModal() == .alertFirstButtonReturn {
            NSWorkspace.shared.open(url)
        }
    }
}

enum UpdateCheckResult {
    case newVersion(String, URL)
    case upToDate
    case error
}

struct UpdateChecker {
    static let repo = "wangcong940310-dotcom/tuanzi-releases"
    static let apiURL = "https://api.github.com/repos/\(repo)/releases/latest"
    static let releasePage = "https://github.com/\(repo)/releases/latest"

    static func check(completion: @escaping (UpdateCheckResult) -> Void) {
        guard let url = URL(string: apiURL) else { completion(.error); return }
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard error == nil, let data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let tagName = json["tag_name"] as? String else {
                completion(.error); return
            }
            let remote = tagName.replacingOccurrences(of: "v", with: "")
            let current = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
            if remote.compare(current, options: .numeric) == .orderedDescending {
                let downloadURL = URL(string: releasePage)!
                completion(.newVersion(remote, downloadURL))
            } else {
                completion(.upToDate)
            }
        }.resume()
    }
}

private struct ContactPane: View {
    var body: some View {
        SettingsGroup {
            VStack(spacing: 12) {
                Text("扫描二维码反馈问题或建议")
                    .font(TuanziTokens.Fonts.control)
                    .foregroundStyle(.secondary)
                    .padding(.top, 14)
                if let img = NSImage(named: "feishu_qr") {
                    Image(nsImage: img)
                        .resizable()
                        .interpolation(.high)
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: TuanziTokens.Layout.qrMaxSize, maxHeight: TuanziTokens.Layout.qrMaxSize)
                        .clipShape(RoundedRectangle(cornerRadius: TuanziTokens.Radius.xxl))
                }
                Spacer().frame(height: 2)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

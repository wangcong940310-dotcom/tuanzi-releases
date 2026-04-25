import Cocoa
import SpriteKit
import SwiftUI
import Network

// 企业定制版飞书的 bundle ID（小米办公Pro）
private let feishuBundleID = "com.larksuite.feishu.ka.saxmsa667.mac"

// MARK: - Agent 注册表

enum AgentConfigFormat {
    case claudeJSON
    case toml
    case cursorJSON
    case openCodePlugin
}

struct AgentDefinition {
    let id: String
    let displayName: String
    let processNames: [String]
    let configFormat: AgentConfigFormat
    let configPath: String
    let badgeColor: (r: Double, g: Double, b: Double)
}

struct AgentRegistry {
    static let allAgents: [AgentDefinition] = [
        AgentDefinition(id: "claude", displayName: "Claude", processNames: ["claude"],
                        configFormat: .claudeJSON, configPath: ".claude/settings.json",
                        badgeColor: (1.0, 0.6, 0.15)),
        AgentDefinition(id: "qoder", displayName: "Qoder", processNames: ["qoder"],
                        configFormat: .claudeJSON, configPath: ".qoder/settings.json",
                        badgeColor: (0.3, 0.8, 0.5)),
        AgentDefinition(id: "qwen", displayName: "Qwen Code", processNames: ["qwen"],
                        configFormat: .claudeJSON, configPath: ".qwen/settings.json",
                        badgeColor: (0.4, 0.5, 0.95)),
        AgentDefinition(id: "factory", displayName: "Factory", processNames: ["factory"],
                        configFormat: .claudeJSON, configPath: ".factory/settings.json",
                        badgeColor: (0.85, 0.35, 0.35)),
        AgentDefinition(id: "codebuddy", displayName: "CodeBuddy", processNames: ["codebuddy"],
                        configFormat: .claudeJSON, configPath: ".codebuddy/settings.json",
                        badgeColor: (0.2, 0.7, 0.9)),
        AgentDefinition(id: "codex", displayName: "Codex", processNames: ["codex"],
                        configFormat: .toml, configPath: ".codex/config.toml",
                        badgeColor: (0.0, 0.75, 0.45)),
        AgentDefinition(id: "gemini", displayName: "Gemini", processNames: ["gemini"],
                        configFormat: .claudeJSON, configPath: ".gemini/settings.json",
                        badgeColor: (0.25, 0.55, 0.95)),
        AgentDefinition(id: "kimi", displayName: "Kimi", processNames: ["kimi"],
                        configFormat: .toml, configPath: ".kimi/config.toml",
                        badgeColor: (0.55, 0.35, 0.85)),
        AgentDefinition(id: "cursor", displayName: "Cursor", processNames: ["cursor"],
                        configFormat: .cursorJSON, configPath: ".cursor/hooks.json",
                        badgeColor: (0.95, 0.4, 0.6)),
        AgentDefinition(id: "opencode", displayName: "OpenCode", processNames: ["opencode"],
                        configFormat: .openCodePlugin, configPath: ".config/opencode/plugins/tuanzi.js",
                        badgeColor: (0.6, 0.8, 0.2)),
    ]

    static let processPattern: String = {
        allAgents.flatMap(\.processNames).joined(separator: "|")
    }()

    static func agent(forProcessName name: String) -> AgentDefinition? {
        allAgents.first { agent in agent.processNames.contains(where: { name.contains($0) }) }
    }
}

// MARK: - 终端/IDE 注册表

enum TerminalJumpMethod {
    case appleScriptTTY
    case bundleActivation
    case cliOpen(String)
    case tmux
}

struct TerminalDefinition {
    let id: String
    let displayName: String
    let bundleId: String
    let jumpMethod: TerminalJumpMethod
}

struct TerminalRegistry {
    static let allTerminals: [TerminalDefinition] = [
        // 终端模拟器
        TerminalDefinition(id: "iterm2", displayName: "iTerm2", bundleId: "com.googlecode.iterm2", jumpMethod: .appleScriptTTY),
        TerminalDefinition(id: "terminal", displayName: "Terminal", bundleId: "com.apple.Terminal", jumpMethod: .appleScriptTTY),
        TerminalDefinition(id: "kitty", displayName: "Kitty", bundleId: "net.kovidgoyal.kitty", jumpMethod: .bundleActivation),
        TerminalDefinition(id: "wezterm", displayName: "WezTerm", bundleId: "com.github.wez.wezterm", jumpMethod: .bundleActivation),
        TerminalDefinition(id: "ghostty", displayName: "Ghostty", bundleId: "com.mitchellh.ghostty", jumpMethod: .bundleActivation),
        TerminalDefinition(id: "warp", displayName: "Warp", bundleId: "dev.warp.Warp-Stable", jumpMethod: .bundleActivation),
        TerminalDefinition(id: "kaku", displayName: "Kaku", bundleId: "", jumpMethod: .bundleActivation),
        // 终端复用器
        TerminalDefinition(id: "tmux", displayName: "tmux", bundleId: "", jumpMethod: .tmux),
        TerminalDefinition(id: "cmux", displayName: "cmux", bundleId: "", jumpMethod: .bundleActivation),
        TerminalDefinition(id: "zellij", displayName: "Zellij", bundleId: "", jumpMethod: .bundleActivation),
        // 编辑器 / IDE
        TerminalDefinition(id: "vscode", displayName: "VS Code", bundleId: "com.microsoft.VSCode", jumpMethod: .cliOpen("code")),
        TerminalDefinition(id: "vscode-insiders", displayName: "VS Code Insiders", bundleId: "com.microsoft.VSCodeInsiders", jumpMethod: .cliOpen("code-insiders")),
        TerminalDefinition(id: "cursor-ide", displayName: "Cursor IDE", bundleId: "com.todesktop.230313mzl4w4u92", jumpMethod: .cliOpen("cursor")),
        TerminalDefinition(id: "windsurf", displayName: "Windsurf", bundleId: "com.codeium.windsurf", jumpMethod: .cliOpen("windsurf")),
        TerminalDefinition(id: "trae", displayName: "Trae", bundleId: "com.trae.app", jumpMethod: .cliOpen("trae")),
        TerminalDefinition(id: "trae-cn", displayName: "Trae", bundleId: "cn.trae.app", jumpMethod: .cliOpen("trae-cn")),
        TerminalDefinition(id: "idea", displayName: "IntelliJ IDEA", bundleId: "com.jetbrains.intellij", jumpMethod: .cliOpen("idea")),
        TerminalDefinition(id: "webstorm", displayName: "WebStorm", bundleId: "com.jetbrains.WebStorm", jumpMethod: .cliOpen("webstorm")),
        TerminalDefinition(id: "pycharm", displayName: "PyCharm", bundleId: "com.jetbrains.pycharm", jumpMethod: .cliOpen("pycharm")),
        TerminalDefinition(id: "goland", displayName: "GoLand", bundleId: "com.jetbrains.goland", jumpMethod: .cliOpen("goland")),
        TerminalDefinition(id: "clion", displayName: "CLion", bundleId: "com.jetbrains.clion", jumpMethod: .cliOpen("clion")),
        TerminalDefinition(id: "rubymine", displayName: "RubyMine", bundleId: "com.jetbrains.rubymine", jumpMethod: .cliOpen("rubymine")),
        TerminalDefinition(id: "phpstorm", displayName: "PhpStorm", bundleId: "com.jetbrains.PhpStorm", jumpMethod: .cliOpen("phpstorm")),
        TerminalDefinition(id: "rider", displayName: "Rider", bundleId: "com.jetbrains.rider", jumpMethod: .cliOpen("rider")),
        TerminalDefinition(id: "rustrover", displayName: "RustRover", bundleId: "com.jetbrains.rustrover", jumpMethod: .cliOpen("rustrover")),
    ]

    static let terminalBundleIds: [String] = allTerminals.filter { !$0.bundleId.isEmpty }.map(\.bundleId)

    static func terminal(forBundleId bid: String) -> TerminalDefinition? {
        allTerminals.first { $0.bundleId == bid }
    }
}

class ViewController: NSViewController {

    // MARK: - Properties 属性

    var skView: SKView!
    var spriteNode: SKSpriteNode!
    var mouseDownLocation: NSPoint = .zero

    var globalMouseMonitor: Any?
    var globalKeyboardMonitor: Any?
    var globalAppMonitor: Any?
    var localMouseMonitor: Any?
    var localKeyboardMonitor: Any?

    // 动画帧序列
    var idleTextures: [SKTexture] = []
    var randomIdle1Textures: [SKTexture] = []   // 刨地
    var randomIdle2Textures: [SKTexture] = []   // 转圈
    var enterSearchTextures: [SKTexture] = []
    var searchLoopTextures: [SKTexture] = []
    var exitSearchTextures: [SKTexture] = []
    var enterThinkingTextures: [SKTexture] = []
    var thinkingLoopTextures: [SKTexture] = []
    var exitThinkingTextures: [SKTexture] = []
    var enterWorkingTextures: [SKTexture] = []
    var workingLoopTextures: [SKTexture] = []
    var exitWorkingTextures: [SKTexture] = []
    var drinkWaterTextures: [SKTexture] = []
    var messageTextures: [SKTexture] = []
    var clickTextures: [SKTexture] = []
    var enterSleepTextures: [SKTexture] = []
    var sleepLoopTextures: [SKTexture] = []
    var wakeUpTextures: [SKTexture] = []
    var enterTypingTextures: [SKTexture] = []
    var typingLoopTextures: [SKTexture] = []
    var exitTypingTextures: [SKTexture] = []
    var runEnterTextures: [SKTexture] = []
    var runLoopTextures: [SKTexture] = []
    var runExitTextures: [SKTexture] = []
    var runRestTextures: [SKTexture] = []
    var dragEnterTextures: [SKTexture] = []
    var dragLoopTextures: [SKTexture] = []
    var dragExitTextures: [SKTexture] = []
    var petTextures: [SKTexture] = []
    // var snapEnterTextures: [SKTexture] = []
    // var snapIdleTextures: [SKTexture] = []
    // var snapDragEnterTextures: [SKTexture] = []
    // var snapDragLoopTextures: [SKTexture] = []
    // var snapDragExitTextures: [SKTexture] = []
    // var isDraggingFromSnap = false
    var snapLeftEnterTextures: [SKTexture] = []
    var snapLeftIdleTextures: [SKTexture] = []
    var snapLeftExitTextures: [SKTexture] = []
    var snapRightEnterTextures: [SKTexture] = []
    var snapRightIdleTextures: [SKTexture] = []
    var snapRightExitTextures: [SKTexture] = []
    var isDraggingFromSnap = false
    // TODO: 替换为正式素材
    var errorTextures: [SKTexture] = []
    var attentionTextures: [SKTexture] = []
    var notificationTextures: [SKTexture] = []
    var snapReminder1Textures: [SKTexture] = []
    var snapReminder2Textures: [SKTexture] = []

    // 计时器
    var idleActionTimer: Timer?
    var idleTimeout: TimeInterval { PetSettings.shared.idleTimeout }
    var typingTimer: Timer?
    var typingTimeout: TimeInterval { PetSettings.shared.typingTimeout }
    var waterTimer: Timer?
    var countdownTimer: Timer?
    var waterReminderEndDate: Date?
    var waterReminderIntervalSeconds: Double = 0
    var countdownContainer: NSView?
    var countdownLabel: NSTextField?
    var feishuTimer: Timer?
    var feishuAlertTimer: Timer?
    var chaseTimer: Timer?
    var accessibilityCheckTimer: Timer?
    var processDiscoveryTimer: Timer?

    // 状态
    var isSleeping = false
    var isTyping = false
    var terminalIsActive = false
    // Claude 正在思考/工作中（区别于 isClaudeStateActive：此标志随用户打字会被清除）
    var isThinkingOnClaudeProxy = false
    var firstKeystrokeTime: Date?
    var lastFeishuBadgeCount: String = ""
    var isChasing = false
    var isPlayingRunExit = false
    var isRestingAtMouse = false
    var isPetting = false
    var isCurrentlyDragging = false
    var isMouseOverPet = false
    // MARK: 终端面板悬停（仅侧边吸附时生效）
    var terminalPanelWindow: NSPanel?
    var isMouseInTerminalPanel = false
    var terminalHoverShowTimer: Timer?
    var terminalAutoHideTimer: Timer?
    var terminalHoverShowDelay: TimeInterval { PetSettings.shared.hoverDelay }
    let terminalAutoHideDelay: TimeInterval = 0.3
    var isSnappedToSide = false
    var snappedSide: Int = 0  // -1 = left, 1 = right, 0 = none
    // Claude 事件处理期间为 true，阻止其他动画打断
    var isClaudeStateActive = false
    // 拖拽结束后用于恢复 Claude 状态
    var lastClaudeState: String = ""
    var isMenuOpen = false
    var permissionDialogWindow: NSWindow?
    var permissionKeyMonitors: [Any] = []
    var pendingPermissionSessionId: String?
    var permissionEventSeq: UInt64 = 0
    var webhookEventCounter: UInt64 = 0
    var autoApproveEnabled = false
    var isSnapReminding = false
    var snapReminderTimer: Timer?
    var snapReminderCycleCount = 0
    // 用户正在主动交互（拖拽/追逐/摸摸），此时不响应自动动画切换
    var isInteracting: Bool { isCurrentlyDragging || isChasing || isPetting || isSnappedToSide }

    var webhookServer: ClaudeWebhookServer?
    // 团子自己维护的 Claude session 列表，不依赖 vibe-island
    var claudeSessions: [String: [String: Any]] = [:]

    private var sessionsFileURL: URL {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = support.appendingPathComponent("团子")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("sessions.json")
    }

    func loadSessionsFromDisk() {
        guard let data = try? Data(contentsOf: sessionsFileURL),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: [String: Any]] else { return }
        let cutoff = Date().timeIntervalSince1970 - 86400  // 24小时
        for (key, val) in dict {
            guard (val["lastActivityAt"] as? Double ?? 0) > cutoff else { continue }
            guard val["status"] as? String != "ended" else { continue }
            var updated = val
            updated["status"] = "idle"  // 重启后重置为空闲
            claudeSessions[key] = updated
        }
    }

    func saveSessionsToDisk() {
        let toSave = claudeSessions.filter { !$0.key.hasPrefix("tty-") && !$0.key.hasPrefix("pid-") }
        guard let data = try? JSONSerialization.data(withJSONObject: toSave) else { return }
        try? data.write(to: sessionsFileURL)
    }

    // MARK: - Lifecycle 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.clear.cgColor
        setupSpriteKit()
        setupGlobalMonitors()
        setupAccessibilityCheck()
        resetIdleTimer()
        if PetSettings.shared.enableFeishuMonitor { startFeishuMonitor() }
        // startChaseTimer()  // 追鼠标功能暂时关闭
        setupWebhookServer()
        installHooksOnFirstLaunch()
        requestAutomationPermissionOnFirstLaunch()
        NotificationCenter.default.addObserver(self, selector: #selector(applySettings), name: .petSettingsChanged, object: nil)
        loadSessionsFromDisk()
        startProcessDiscovery()
        checkForUpdateOnLaunch()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        if let window = view.window {
            window.isOpaque = false; window.backgroundColor = NSColor.clear
            window.hasShadow = false; window.styleMask = .borderless
            window.level = NSWindow.Level(rawValue: NSWindow.Level.floating.rawValue + 1); window.isRestorable = false
            window.acceptsMouseMovedEvents = true
            window.collectionBehavior = [.canJoinAllSpaces, .stationary]
        }

        view.trackingAreas.forEach { view.removeTrackingArea($0) }
        let trackingArea = NSTrackingArea(rect: view.bounds, options: [.activeAlways, .mouseEnteredAndExited, .inVisibleRect], owner: self, userInfo: nil)
        view.addTrackingArea(trackingArea)
        view.discardCursorRects()
        view.addCursorRect(view.bounds, cursor: .openHand)
    }

    deinit {
        if let m = globalMouseMonitor { NSEvent.removeMonitor(m) }
        if let k = globalKeyboardMonitor { NSEvent.removeMonitor(k) }
        if let a = globalAppMonitor { NSWorkspace.shared.notificationCenter.removeObserver(a) }
        if let m = localMouseMonitor { NSEvent.removeMonitor(m) }
        if let k = localKeyboardMonitor { NSEvent.removeMonitor(k) }
        idleActionTimer?.invalidate(); typingTimer?.invalidate()
        waterTimer?.invalidate(); countdownTimer?.invalidate()
        terminalHoverShowTimer?.invalidate(); terminalAutoHideTimer?.invalidate()
        snapReminderTimer?.invalidate()
        terminalPanelWindow?.close(); terminalPanelWindow = nil
        feishuTimer?.invalidate(); feishuAlertTimer?.invalidate()
        chaseTimer?.invalidate()
        accessibilityCheckTimer?.invalidate()
        processDiscoveryTimer?.invalidate()
        webhookServer?.stop()
    }

    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        isMouseOverPet = true
        if waterTimer?.isValid == true && !isSnappedToSide { countdownContainer?.isHidden = false }
        stopSnapReminder()

        // 终端面板：仅侧边吸附时触发，权限弹窗显示期间不触发
        guard isSnappedToSide else { return }
        guard permissionDialogWindow == nil else { return }
        terminalAutoHideTimer?.invalidate(); terminalAutoHideTimer = nil
        if terminalPanelWindow?.isVisible == true { return }  // 已显示则不重复触发
        terminalHoverShowTimer?.invalidate()
        terminalHoverShowTimer = Timer.scheduledTimer(withTimeInterval: terminalHoverShowDelay, repeats: false) { [weak self] _ in
            guard let self, self.isMouseOverPet, self.isSnappedToSide else { return }
            guard self.permissionDialogWindow == nil else { return }
            self.showTerminalPanel()
        }
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        isMouseOverPet = false
        if !isCurrentlyDragging { NSCursor.arrow.set() }
        countdownContainer?.isHidden = true

        // 终端面板：取消显示计时，延迟隐藏（给鼠标移入面板留时间）
        terminalHoverShowTimer?.invalidate(); terminalHoverShowTimer = nil
        guard terminalPanelWindow?.isVisible == true else { return }
        guard !isMouseInTerminalPanel else { return }  // 鼠标移入 panel 则不触发 auto-hide
        terminalAutoHideTimer?.invalidate()
        terminalAutoHideTimer = Timer.scheduledTimer(withTimeInterval: terminalAutoHideDelay, repeats: false) { [weak self] _ in
            guard let self, !self.isMouseOverPet, !self.isMouseInTerminalPanel else { return }
            self.hideTerminalPanel()
        }
    }

    // MARK: - Settings 设置响应

    @objc func applySettings() {
        // 飞书监听启停
        if PetSettings.shared.enableFeishuMonitor {
            if feishuTimer?.isValid != true { startFeishuMonitor() }
        } else {
            feishuTimer?.invalidate(); feishuTimer = nil
        }
    }

    // MARK: - Webhook 服务器配置

    func setupWebhookServer() {
        webhookServer = ClaudeWebhookServer()

        // UserPromptSubmit
        webhookServer?.onThinking = { [weak self] in
            guard let self else { return }
            self.webhookEventCounter += 1
            self.isClaudeStateActive = true
            self.isThinkingOnClaudeProxy = true
            self.lastClaudeState = "thinking"
            TextureManager.shared.preload([.enterWorking, .workingLoop, .exitWorking])
            self.startThinkingAnimationLoop()
            if self.pendingPermissionSessionId != nil,
               self.webhookEventCounter > self.permissionEventSeq {
                self.dismissPermissionDialogIfNeeded()
            }
        }

        // PreToolUse / PostToolUse / SubagentStop
        webhookServer?.onWorking = { [weak self] in
            guard let self else { return }
            self.webhookEventCounter += 1
            self.stopSnapReminder()
            self.isClaudeStateActive = true
            self.isThinkingOnClaudeProxy = true
            self.lastClaudeState = "working"
            TextureManager.shared.preload([.attention])
            self.startWorkingAnimationLoop()
            if self.pendingPermissionSessionId != nil,
               self.webhookEventCounter > self.permissionEventSeq {
                self.dismissPermissionDialogIfNeeded()
            }
        }

        // PostToolUseFailure / StopFailure
        // webhookServer?.onError = { [weak self] in
        //     self?.isClaudeStateActive = true
        //     self?.isThinkingOnClaudeProxy = false
        //     self?.playErrorAnimation()
        // }

        // Stop / PostCompact
        webhookServer?.onAttention = { [weak self] in
            guard let self else { return }
            self.webhookEventCounter += 1
            self.isClaudeStateActive = true
            self.isThinkingOnClaudeProxy = false
            if self.pendingPermissionSessionId != nil,
               self.webhookEventCounter > self.permissionEventSeq {
                self.dismissPermissionDialogIfNeeded()
            }
            if self.isSnappedToSide {
                self.startSnapReminderLoop()
            } else {
                self.playAttentionAnimation()
            }
        }

        // Notification / Elicitation
        webhookServer?.onNotification = { [weak self] in
            self?.isClaudeStateActive = true
            self?.playNotificationAnimation()
        }

        // SessionStart
        webhookServer?.onIdle = { [weak self] in
            self?.stopSnapReminder()
            self?.isClaudeStateActive = false
            self?.isThinkingOnClaudeProxy = false
            self?.lastClaudeState = ""
            if self?.isSnappedToSide == true {
                self?.restoreSnapIdleIfNeeded()
            } else {
                self?.startIdleAnimation()
            }
        }

        // SessionEnd
        webhookServer?.onSleeping = { [weak self] in
            if self?.isSnappedToSide == true {
                self?.isClaudeStateActive = false
                self?.isThinkingOnClaudeProxy = false
                self?.restoreSnapIdleIfNeeded()
            } else {
                self?.isClaudeStateActive = true
                self?.isThinkingOnClaudeProxy = false
                self?.enterSleep()
            }
        }

        // 兼容旧版 /claude/start 和 /claude/stop 路由
        webhookServer?.onClaudeStart = { [weak self] in
            self?.isClaudeStateActive = true
            self?.isThinkingOnClaudeProxy = true
            self?.startThinkingAnimationLoop()
        }
        webhookServer?.onClaudeStop = { [weak self] in
            self?.isClaudeStateActive = false
            self?.isThinkingOnClaudeProxy = false
            if self?.isSnappedToSide == true {
                self?.restoreSnapIdleIfNeeded()
            } else {
                self?.stopThinkingAnimation()
            }
        }

        // PermissionRequest：持有 HTTP 连接直到用户点击确认/拒绝
        webhookServer?.onPermissionRequest = { [weak self] payload, completion in
            guard let self, let window = self.view.window else {
                completion(["hookSpecificOutput": ["hookEventName": "PermissionRequest", "decision": ["behavior": "deny"]]])
                return
            }

            // 记录当前权限弹窗对应的 session，用于自动关闭
            let permSessionId = payload["session_id"] as? String
            self.pendingPermissionSessionId = permSessionId
            self.permissionEventSeq = self.webhookEventCounter

            let toolName = payload["tool_name"] as? String ?? "Unknown"
            let toolInput = payload["tool_input"] as? [String: Any] ?? [:]

            if toolName == "AskUserQuestion",
               let questions = toolInput["questions"] as? [[String: Any]],
               let first = questions.first,
               let options = first["options"] as? [[String: Any]], !options.isEmpty {
                let questionText = first["question"] as? String ?? "请选择"
                let labels = options.map { ($0["label"] as? String ?? "") + (($0["description"] as? String).map { " — \($0)" } ?? "") }
                self.showAskUserQuestionDialog(prompt: questionText, options: labels) { selectedIndex in
                    let selectedLabel = options[selectedIndex]["label"] as? String ?? ""
                    var updatedInput = toolInput
                    updatedInput["answers"] = [questionText: selectedLabel]
                    completion(["hookSpecificOutput": [
                        "hookEventName": "PermissionRequest",
                        "decision": [
                            "behavior": "allow",
                            "updatedInput": updatedInput
                        ]
                    ]])
                }
                return
            }

            let command = toolInput["command"] as? String
                ?? toolInput["description"] as? String
                ?? toolInput.map { "\($0.key): \($0.value)" }.joined(separator: "\n")
            let suggestions = payload["permission_suggestions"] as? [[String: Any]] ?? []

            if self.isSnappedToSide {
                self.showInlinePermission(toolName: toolName, command: command, suggestions: suggestions) { decision in
                    completion(["hookSpecificOutput": ["hookEventName": "PermissionRequest", "decision": decision]])
                }
            } else {
                self.showPermissionDialog(toolName: toolName, command: command, suggestions: suggestions, in: window) { decision in
                    completion(["hookSpecificOutput": ["hookEventName": "PermissionRequest", "decision": decision]])
                }
            }
        }

        // TCP 断开也尝试关闭弹窗（辅助检测）
        webhookServer?.onPermissionConnectionClosed = { [weak self] in
            self?.dismissPermissionDialogIfNeeded()
        }

        // Elicitation：Claude 提问，等用户选择
        webhookServer?.onElicitationRequest = { [weak self] payload, completion in
            guard let self, let window = self.view.window else {
                completion(["action": "cancel"])
                return
            }
            let prompt  = payload["prompt"]  as? String ?? "请选择一个选项"
            let options = payload["options"] as? [String] ?? []
            if self.isSnappedToSide {
                self.showInlineElicitation(prompt: prompt, options: options) { result in
                    completion(result)
                }
            } else {
                self.showElicitationDialog(prompt: prompt, options: options, in: window) { result in
                    completion(result)
                }
            }
        }

        webhookServer?.onSessionUpdate = { [weak self] sessionData in
            guard let self, let sessionId = sessionData["sessionId"] as? String, !sessionId.isEmpty else { return }

            if let pendingSid = self.pendingPermissionSessionId,
               sessionId == pendingSid,
               let status = sessionData["status"] as? String,
               status == "ended" {
                self.dismissPermissionDialogIfNeeded()
            }

            if sessionData["status"] as? String == "ended" {
                self.claudeSessions.removeValue(forKey: sessionId)
                self.saveSessionsToDisk()
            } else {
                // 首次注册时去重：移除同终端的旧 session（包括持久化的旧 session）
                let isNew = self.claudeSessions[sessionId] == nil
                if isNew {
                    let hookTsid = sessionData["termSessionId"] as? String ?? ""
                    let hookTty  = sessionData["tty"]  as? String ?? ""
                    let hookCwd  = sessionData["cwd"]  as? String ?? ""
                    let dupKey: String? = {
                        // 1. TERM_SESSION_ID 精确匹配（最可靠）
                        if !hookTsid.isEmpty {
                            let byTsid = self.claudeSessions.keys.first { k in
                                k != sessionId &&
                                (self.claudeSessions[k]?["termSessionId"] as? String) == hookTsid
                            }
                            if byTsid != nil { return byTsid }
                        }
                        // 2. tty 精确匹配（任意 session，不限 tty-/pid- 前缀）
                        if !hookTty.isEmpty {
                            let byTty = self.claudeSessions.keys.first { k in
                                k != sessionId &&
                                (self.claudeSessions[k]?["tty"] as? String) == hookTty
                            }
                            if byTty != nil { return byTty }
                        }
                        // 3. cwd 兜底，仅移除扫描占位（避免误杀真实 session）
                        if !hookCwd.isEmpty {
                            return self.claudeSessions.keys.first { k in
                                k != sessionId &&
                                (k.hasPrefix("pid-") || k.hasPrefix("tty-")) &&
                                (self.claudeSessions[k]?["cwd"] as? String) == hookCwd
                            }
                        }
                        return nil
                    }()
                    if let dup = dupKey { self.claudeSessions.removeValue(forKey: dup) }
                }
                var existing = self.claudeSessions[sessionId] ?? [:]
                if existing["startedAt"] == nil { existing["startedAt"] = Date().timeIntervalSince1970 }
                for (k, v) in sessionData {
                    if k == "firstUserMessage", let s = v as? String, s.isEmpty { continue }
                    if k == "lastAssistantMessage", let s = v as? String, s.isEmpty { continue }
                    existing[k] = v
                }
                // 推断 terminalApp（参照 open-vibe-island inferTerminalApp 优先级）
                existing["terminalApp"] = Self.inferTerminalApp(from: existing)
                self.claudeSessions[sessionId] = existing
                self.saveSessionsToDisk()
            }
        }

        webhookServer?.start(port: 23333)
    }

    // MARK: - Hook 安装引擎

    private var hookScriptPath: String { NSHomeDirectory() + "/.clawd/hook.sh" }

    func ensureHookScript() {
        let dir = NSHomeDirectory() + "/.clawd"
        let fm = FileManager.default
        try? fm.createDirectory(atPath: dir, withIntermediateDirectories: true)
        let script = """
        #!/bin/bash
        STATE="$1"
        [ -z "$STATE" ] && exit 0
        BODY=$(cat 2>/dev/null)
        SESSION_ID=$(echo "$BODY" | python3 -c \\
          "import sys,json; d=json.load(sys.stdin); print(d.get('session_id','default'))" \\
          2>/dev/null || echo "default")
        curl -sf -X POST http://127.0.0.1:23333/state \\
          -H "Content-Type: application/json" \\
          -d "{\\"state\\":\\"${STATE}\\",\\"session_id\\":\\"${SESSION_ID}\\"}" \\
          --max-time 1 --connect-timeout 0.5 > /dev/null 2>&1 || true
        exit 0
        """
        let path = hookScriptPath
        if let existing = try? String(contentsOfFile: path, encoding: .utf8), existing.contains("127.0.0.1:23333") { return }
        try? script.write(toFile: path, atomically: true, encoding: .utf8)
        chmod(path, 0o755)
    }

    private func chmod(_ path: String, _ mode: mode_t) {
        Darwin.chmod(path, mode)
    }

    private func tuanziHookMarker(_ agentId: String) -> String { ".clawd/hook" }

    private func sessionTrackingCommand(status: String, agentId: String) -> String {
        // 参照 open-vibe-island inferTerminalApp，上报所有关键环境变量
        return """
        body=$(cat); echo "$body" | jq -c \
          --arg cwd "$(pwd)" \
          --arg tty "$(python3 -c 'import os; print(os.ttyname(2))' 2>/dev/null || ps -o tty= -p $PPID 2>/dev/null | tr -d ' ' | grep -v '^[?]*$' | head -1 | sed 's,^,/dev/,')" \
          --arg ts "$(date +%s)" \
          --arg tsid "${TERM_SESSION_ID:-}" \
          --arg termapp "${TERM_PROGRAM:-}" \
          --arg termemu "${TERMINAL_EMULATOR:-}" \
          --arg cursortrace "${CURSOR_TRACE_ID:-}" \
          --arg cmuxid "${CMUX_WORKSPACE_ID:-}" \
          --arg zellij "${ZELLIJ:-}" \
          --arg itermsid "${ITERM_SESSION_ID:-}" \
          --arg warplocal "${WARP_IS_LOCAL_SHELL_SESSION:-}" \
          --arg ghosttyres "${GHOSTTY_RESOURCES_DIR:-}" \
          --arg cfbundle "${__CFBundleIdentifier:-}" \
          --arg agent "\(agentId)" \
          '{sessionId:(.session_id//""),cwd:$cwd,tty:$tty,termSessionId:$tsid,terminalApp:$termapp,terminalEmulator:$termemu,cursorTraceId:$cursortrace,cmuxWorkspaceId:$cmuxid,zellij:$zellij,itermSessionId:$itermsid,warpLocal:$warplocal,ghosttyResources:$ghosttyres,cfBundleIdentifier:$cfbundle,agentId:$agent,status:"\(status)",toolTarget:(.tool_name//""),lastActivityAt:($ts|tonumber)}' \
          2>/dev/null | curl -s -X POST http://127.0.0.1:23333/session -H 'Content-Type: application/json' -d @- --max-time 5 2>/dev/null || true
        """
    }

    func installHooksForAgent(_ agent: AgentDefinition) {
        ensureHookScript()
        let home = NSHomeDirectory()
        let configFullPath = home + "/" + agent.configPath

        switch agent.configFormat {
        case .claudeJSON:
            installClaudeJSONHooks(agent: agent, configPath: configFullPath)
        case .toml:
            installTOMLHooks(agent: agent, configPath: configFullPath)
        case .cursorJSON:
            installCursorJSONHooks(agent: agent, configPath: configFullPath)
        case .openCodePlugin:
            installOpenCodePlugin(agent: agent, pluginPath: configFullPath)
        }

        UserDefaults.standard.set(true, forKey: "hookEnabled_\(agent.id)")
        print("✅ Hook 已安装: \(agent.displayName)")
    }

    func uninstallHooksForAgent(_ agent: AgentDefinition) {
        let home = NSHomeDirectory()
        let configFullPath = home + "/" + agent.configPath

        switch agent.configFormat {
        case .claudeJSON:
            uninstallClaudeJSONHooks(configPath: configFullPath)
        case .toml:
            uninstallTOMLHooks(configPath: configFullPath)
        case .cursorJSON:
            uninstallCursorJSONHooks(configPath: configFullPath)
        case .openCodePlugin:
            try? FileManager.default.removeItem(atPath: configFullPath)
        }

        UserDefaults.standard.set(false, forKey: "hookEnabled_\(agent.id)")
        print("🗑 Hook 已卸载: \(agent.displayName)")
    }

    func isHookInstalled(for agent: AgentDefinition) -> Bool {
        let home = NSHomeDirectory()
        let configFullPath = home + "/" + agent.configPath
        guard let content = try? String(contentsOfFile: configFullPath, encoding: .utf8) else { return false }
        return content.contains(".clawd/hook") || content.contains("127.0.0.1:23333")
    }

    func agentConfigDirExists(_ agent: AgentDefinition) -> Bool {
        let home = NSHomeDirectory()
        let dir = (home + "/" + agent.configPath) as NSString
        var isDir: ObjCBool = false
        return FileManager.default.fileExists(atPath: dir.deletingLastPathComponent, isDirectory: &isDir) && isDir.boolValue
    }

    func installHooksOnFirstLaunch() {
        for agent in AgentRegistry.allAgents {
            if agentConfigDirExists(agent) && !isHookInstalled(for: agent) {
                installHooksForAgent(agent)
            }
        }
    }

    // MARK: Claude JSON Hook 安装

    private func installClaudeJSONHooks(agent: AgentDefinition, configPath: String) {
        let fm = FileManager.default
        let dir = (configPath as NSString).deletingLastPathComponent
        try? fm.createDirectory(atPath: dir, withIntermediateDirectories: true)

        // 备份
        if fm.fileExists(atPath: configPath) {
            try? fm.copyItem(atPath: configPath, toPath: configPath + ".tuanzi-backup")
        }

        var config: [String: Any] = [:]
        if let data = fm.contents(atPath: configPath),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            config = json
        }

        var hooks = config["hooks"] as? [String: Any] ?? [:]
        let hookPath = hookScriptPath
        let agentId = agent.id

        let stateHooks: [(String, String)] = [
            ("UserPromptSubmit", "thinking"),
            ("PreToolUse", "working"),
            ("PostToolUse", "working"),
            ("PostToolUseFailure", "error"),
            ("Stop", "attention"),
            ("StopFailure", "error"),
            ("Notification", "notification"),
            ("Elicitation", "notification"),
            ("SessionStart", "idle"),
            ("SessionEnd", "sleeping"),
        ]

        for (event, state) in stateHooks {
            var eventHooks = hooks[event] as? [[String: Any]] ?? []
            eventHooks.removeAll { entry in
                let innerHooks = entry["hooks"] as? [[String: Any]] ?? []
                return innerHooks.contains { ($0["command"] as? String ?? "").contains(".clawd/hook") }
            }
            let newEntry: [String: Any] = [
                "matcher": "",
                "hooks": [["type": "command", "command": "bash \(hookPath) \(state)"]]
            ]
            eventHooks.insert(newEntry, at: 0)
            hooks[event] = eventHooks
        }

        // Session tracking hooks
        let sessionTrackEvents: [(String, String)] = [
            ("SessionStart", "idle"),
            ("PreToolUse", "working"),
            ("SessionEnd", "ended"),
        ]
        for (event, status) in sessionTrackEvents {
            var eventHooks = hooks[event] as? [[String: Any]] ?? []
            eventHooks.removeAll { entry in
                let innerHooks = entry["hooks"] as? [[String: Any]] ?? []
                return innerHooks.contains { ($0["command"] as? String ?? "").contains("127.0.0.1:23333/session") }
            }
            let trackEntry: [String: Any] = [
                "matcher": "*",
                "hooks": [["type": "command", "command": sessionTrackingCommand(status: status, agentId: agentId)]]
            ]
            eventHooks.append(trackEntry)
            hooks[event] = eventHooks
        }

        // Permission hook
        var permHooks = hooks["PermissionRequest"] as? [[String: Any]] ?? []
        permHooks.removeAll { entry in
            let innerHooks = entry["hooks"] as? [[String: Any]] ?? []
            return innerHooks.contains { ($0["command"] as? String ?? "").contains("127.0.0.1:23333/permission") }
        }
        permHooks.insert([
            "matcher": "",
            "hooks": [["type": "command", "command": "curl -s -X POST http://127.0.0.1:23333/permission -H 'Content-Type: application/json' -d @- --max-time 600"]]
        ], at: 0)
        hooks["PermissionRequest"] = permHooks

        config["hooks"] = hooks
        if let data = try? JSONSerialization.data(withJSONObject: config, options: [.prettyPrinted, .sortedKeys]) {
            try? data.write(to: URL(fileURLWithPath: configPath))
        }
    }

    private func uninstallClaudeJSONHooks(configPath: String) {
        guard let data = FileManager.default.contents(atPath: configPath),
              var config = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              var hooks = config["hooks"] as? [String: Any] else { return }

        for (event, var eventHooks) in hooks {
            guard var arr = eventHooks as? [[String: Any]] else { continue }
            arr.removeAll { entry in
                let innerHooks = entry["hooks"] as? [[String: Any]] ?? []
                return innerHooks.contains {
                    let cmd = $0["command"] as? String ?? ""
                    return cmd.contains(".clawd/hook") || cmd.contains("127.0.0.1:23333")
                }
            }
            hooks[event] = arr
        }

        config["hooks"] = hooks
        if let data = try? JSONSerialization.data(withJSONObject: config, options: [.prettyPrinted, .sortedKeys]) {
            try? data.write(to: URL(fileURLWithPath: configPath))
        }
    }

    // MARK: TOML Hook 安装 (Codex/Kimi)

    private let tomlMarkerStart = "# --- tuanzi-hooks-start ---"
    private let tomlMarkerEnd = "# --- tuanzi-hooks-end ---"

    private func installTOMLHooks(agent: AgentDefinition, configPath: String) {
        let fm = FileManager.default
        let dir = (configPath as NSString).deletingLastPathComponent
        try? fm.createDirectory(atPath: dir, withIntermediateDirectories: true)

        if fm.fileExists(atPath: configPath) {
            try? fm.copyItem(atPath: configPath, toPath: configPath + ".tuanzi-backup")
        }

        var content = (try? String(contentsOfFile: configPath, encoding: .utf8)) ?? ""

        // 移除旧的团子 hook 块
        if let startRange = content.range(of: tomlMarkerStart),
           let endRange = content.range(of: tomlMarkerEnd) {
            content.removeSubrange(startRange.lowerBound...endRange.upperBound)
            content = content.trimmingCharacters(in: .newlines)
        }

        let hookPath = hookScriptPath
        let events: [(String, String)] = [
            ("SessionStart", "idle"),
            ("UserPromptSubmit", "thinking"),
            ("PreToolUse", "working"),
            ("PostToolUse", "working"),
            ("Stop", "attention"),
            ("SessionEnd", "sleeping"),
        ]

        var tomlBlock = "\n\n\(tomlMarkerStart)\n"
        for (event, state) in events {
            tomlBlock += """
            [[hooks]]
            event = "\(event)"
            command = ["bash", "\(hookPath)", "\(state)"]

            """
        }
        tomlBlock += "\(tomlMarkerEnd)\n"

        content += tomlBlock
        try? content.write(toFile: configPath, atomically: true, encoding: .utf8)
    }

    private func uninstallTOMLHooks(configPath: String) {
        guard var content = try? String(contentsOfFile: configPath, encoding: .utf8) else { return }
        if let startRange = content.range(of: tomlMarkerStart),
           let endRange = content.range(of: tomlMarkerEnd) {
            content.removeSubrange(startRange.lowerBound...endRange.upperBound)
            content = content.trimmingCharacters(in: .newlines) + "\n"
            try? content.write(toFile: configPath, atomically: true, encoding: .utf8)
        }
    }

    // MARK: Cursor JSON Hook 安装

    private func installCursorJSONHooks(agent: AgentDefinition, configPath: String) {
        let fm = FileManager.default
        let dir = (configPath as NSString).deletingLastPathComponent
        try? fm.createDirectory(atPath: dir, withIntermediateDirectories: true)

        if fm.fileExists(atPath: configPath) {
            try? fm.copyItem(atPath: configPath, toPath: configPath + ".tuanzi-backup")
        }

        var config: [String: Any] = [:]
        if let data = fm.contents(atPath: configPath),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            config = json
        }

        let hookPath = hookScriptPath
        let cursorEvents: [(String, String)] = [
            ("beforeSubmitPrompt", "thinking"),
            ("beforeShellExecution", "working"),
            ("beforeMCPExecution", "working"),
            ("beforeReadFile", "working"),
            ("afterFileEdit", "working"),
            ("afterAgentResponse", "attention"),
        ]

        var hooks = config["hooks"] as? [String: Any] ?? [:]
        for (event, state) in cursorEvents {
            var arr = hooks[event] as? [[String: Any]] ?? []
            arr.removeAll { ($0["command"] as? String ?? "").contains(".clawd/hook") }
            arr.insert(["command": "bash \(hookPath) \(state)"], at: 0)
            hooks[event] = arr
        }
        config["hooks"] = hooks

        if let data = try? JSONSerialization.data(withJSONObject: config, options: [.prettyPrinted, .sortedKeys]) {
            try? data.write(to: URL(fileURLWithPath: configPath))
        }
    }

    private func uninstallCursorJSONHooks(configPath: String) {
        guard let data = FileManager.default.contents(atPath: configPath),
              var config = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              var hooks = config["hooks"] as? [String: Any] else { return }

        for (event, _) in hooks {
            guard var arr = hooks[event] as? [[String: Any]] else { continue }
            arr.removeAll { ($0["command"] as? String ?? "").contains(".clawd/hook") }
            hooks[event] = arr
        }
        config["hooks"] = hooks

        if let data = try? JSONSerialization.data(withJSONObject: config, options: [.prettyPrinted, .sortedKeys]) {
            try? data.write(to: URL(fileURLWithPath: configPath))
        }
    }

    // MARK: OpenCode Plugin 安装

    private func installOpenCodePlugin(agent: AgentDefinition, pluginPath: String) {
        let fm = FileManager.default
        let dir = (pluginPath as NSString).deletingLastPathComponent
        try? fm.createDirectory(atPath: dir, withIntermediateDirectories: true)

        let plugin = """
        // Tuanzi plugin for OpenCode
        const http = require('http');
        function notify(state) {
          const data = JSON.stringify({ state });
          const req = http.request({
            hostname: '127.0.0.1', port: 23333, path: '/state',
            method: 'POST', headers: { 'Content-Type': 'application/json', 'Content-Length': data.length },
            timeout: 1000
          });
          req.on('error', () => {});
          req.write(data);
          req.end();
        }
        module.exports = {
          onSessionStart: () => notify('idle'),
          onSessionEnd: () => notify('sleeping'),
          onUserPrompt: () => notify('thinking'),
          onToolUse: () => notify('working'),
          onToolResult: () => notify('working'),
          onComplete: () => notify('attention'),
          onError: () => notify('error'),
        };
        """
        try? plugin.write(toFile: pluginPath, atomically: true, encoding: .utf8)
    }

    // MARK: - Setup 初始化与素材加载
    private func loadTextures(named prefix: String, _ range: Range<Int>) -> [SKTexture] {
        range.map { SKTexture(imageNamed: "\(prefix)_\($0)") }
    }

    private func ensureTextures(_ groups: TextureGroup...) {
        for group in groups {
            let textures = TextureManager.shared.textures(for: group)
            switch group {
            case .idle:             idleTextures = textures
            case .randomIdle1:      randomIdle1Textures = textures
            case .randomIdle2:      randomIdle2Textures = textures
            case .enterSearch:      enterSearchTextures = textures
            case .searchLoop:       searchLoopTextures = textures
            case .exitSearch:       exitSearchTextures = textures
            case .enterThinking:    enterThinkingTextures = textures
            case .thinkingLoop:     thinkingLoopTextures = textures
            case .exitThinking:     exitThinkingTextures = textures
            case .enterWorking:     enterWorkingTextures = textures
            case .workingLoop:      workingLoopTextures = textures
            case .exitWorking:      exitWorkingTextures = textures
            case .drinkWater:       drinkWaterTextures = textures
            case .message:          messageTextures = textures; notificationTextures = textures
            case .click:            clickTextures = textures
            case .enterSleep:       enterSleepTextures = textures
            case .sleepLoop:        sleepLoopTextures = textures
            case .wakeUp:           wakeUpTextures = textures
            case .enterTyping:      enterTypingTextures = textures
            case .typingLoop:       typingLoopTextures = textures
            case .exitTyping:       exitTypingTextures = textures
            case .dragEnter:        dragEnterTextures = textures
            case .dragLoop:         dragLoopTextures = textures
            case .dragExit:         dragExitTextures = textures
            case .runEnter:         runEnterTextures = textures
            case .runLoop:          runLoopTextures = textures
            case .runExit:          runExitTextures = textures
            case .runRest:          runRestTextures = textures
            case .pet:              petTextures = textures
            case .attention:        attentionTextures = textures
            case .snapLeftEnter:    snapLeftEnterTextures = textures
            case .snapLeftIdle:     snapLeftIdleTextures = textures
            case .snapLeftExit:     snapLeftExitTextures = textures
            case .snapRightEnter:   snapRightEnterTextures = textures
            case .snapRightIdle:    snapRightIdleTextures = textures
            case .snapRightExit:    snapRightExitTextures = textures
            case .snapReminder1:    snapReminder1Textures = textures
            case .snapReminder2:    snapReminder2Textures = textures
            }
        }
    }

    private func clearNormalTextures() {
        enterSearchTextures = []; searchLoopTextures = []; exitSearchTextures = []
        enterThinkingTextures = []; thinkingLoopTextures = []; exitThinkingTextures = []
        enterWorkingTextures = []; workingLoopTextures = []; exitWorkingTextures = []
        drinkWaterTextures = []; messageTextures = []; notificationTextures = []; clickTextures = []
        enterSleepTextures = []; sleepLoopTextures = []; wakeUpTextures = []
        enterTypingTextures = []; typingLoopTextures = []; exitTypingTextures = []
        dragEnterTextures = []; dragLoopTextures = []; dragExitTextures = []
        runEnterTextures = []; runLoopTextures = []; runExitTextures = []; runRestTextures = []
        petTextures = []; attentionTextures = []
        TextureManager.shared.evict(TextureGroup.normalNonEssential)
    }

    private func clearSnapTextures() {
        snapLeftEnterTextures = []; snapLeftIdleTextures = []; snapLeftExitTextures = []
        snapRightEnterTextures = []; snapRightIdleTextures = []; snapRightExitTextures = []
        snapReminder1Textures = []; snapReminder2Textures = []
        TextureManager.shared.evict(TextureGroup.snapAll)
    }
    func setupSpriteKit() {
        skView = SKView(frame: view.bounds); skView.autoresizingMask = [.width, .height]
        skView.wantsLayer = true; skView.layer?.backgroundColor = NSColor.clear.cgColor
        skView.allowsTransparency = true; view.addSubview(skView)

        let scene = PetScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFit; scene.backgroundColor = NSColor.clear
        scene.viewController = self
        setupSpriteNode(in: scene); skView.presentScene(scene)
    }

    func setupSpriteNode(in scene: SKScene) {
        ensureTextures(.idle, .randomIdle1, .randomIdle2, .click)

        guard let firstTex = idleTextures.first else {
            print("❌ 待机纹理加载失败，无法初始化 spriteNode")
            return
        }
        spriteNode = SKSpriteNode(texture: firstTex)
        spriteNode.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        spriteNode.name = "petSprite"
        let scale = min(scene.size.width / spriteNode.size.width, scene.size.height / spriteNode.size.height)
        spriteNode.setScale(scale * 0.95); scene.addChild(spriteNode)

        setupCountdownLabel()
        startIdleAnimation()
    }

    func setupCountdownLabel() {
        countdownContainer = NSView(frame: NSRect(x: 0, y: 5, width: 120, height: 28))
        countdownContainer?.wantsLayer = true
        countdownContainer?.layer?.backgroundColor = NSColor(red: 0, green: 0, blue: 0, alpha: 0.6).cgColor
        countdownContainer?.layer?.cornerRadius = 8
        countdownContainer?.isHidden = true

        countdownLabel = NSTextField(labelWithString: "")
        countdownLabel?.textColor = NSColor.white
        countdownLabel?.font = NSFont.boldSystemFont(ofSize: 14)
        countdownLabel?.alignment = .center
        countdownLabel?.isEditable = false
        countdownLabel?.isBordered = false
        countdownLabel?.drawsBackground = false

        if let container = countdownContainer, let label = countdownLabel {
            container.translatesAutoresizingMaskIntoConstraints = false
            label.translatesAutoresizingMaskIntoConstraints = false

            view.addSubview(container)
            container.addSubview(label)

            NSLayoutConstraint.activate([
                container.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -2),
                container.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
                container.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
                container.heightAnchor.constraint(equalToConstant: 28),

                label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 6),
                label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10)
            ])
        }
    }

    // MARK: - Snap Idle 恢复吸附待机
    func restoreSnapIdleIfNeeded() {
        guard isSnappedToSide, !isCurrentlyDragging, !isPetting, !isSnapReminding else { return }
        guard spriteNode.action(forKey: "snapSequence") == nil,
              spriteNode.action(forKey: "snapReminderSequence") == nil else { return }
        let textures = snappedSide == -1 ? snapLeftIdleTextures : snapRightIdleTextures
        guard !textures.isEmpty else { return }
        let sceneW = spriteNode.scene!.size.width
        let padding = (sceneW - spriteNode.frame.size.width) / 2
        spriteNode.position.x = sceneW / 2 + (snappedSide == -1 ? -padding : padding)
        spriteNode.removeAllActions()
        spriteNode.run(SKAction.repeatForever(SKAction.animate(with: textures, timePerFrame: 0.05)), withKey: "snapSequence")
    }

    // MARK: - Animation 动画控制
    func startIdleAnimation() {
        ensureTextures(.idle, .randomIdle1, .randomIdle2)
        guard !idleTextures.isEmpty, !isInteracting else { return }
        spriteNode.removeAllActions()
        
        let dice = Int.random(in: 1...100); var playCount = 1
        var selectedTextures = idleTextures
        
        if dice <= 15 && !randomIdle1Textures.isEmpty { selectedTextures = randomIdle1Textures }
        else if dice > 15 && dice <= 30 && !randomIdle2Textures.isEmpty { selectedTextures = randomIdle2Textures }
        else { playCount = Int.random(in: 3...5) }
        
        let repeatAction = SKAction.repeat(SKAction.animate(with: selectedTextures, timePerFrame: 0.05), count: playCount)
        spriteNode.run(SKAction.sequence([repeatAction, SKAction.run { [weak self] in self?.startIdleAnimation() }]), withKey: "idleSequence")
    }

    func startPetting() {
        ensureTextures(.pet)
        guard !petTextures.isEmpty, !isInteracting else { return }
        isPetting = true; spriteNode.removeAllActions()
        isSleeping = false; isTyping = false; isThinkingOnClaudeProxy = false

        let petAction = SKAction.animate(with: petTextures, timePerFrame: 0.05)
        let completion = SKAction.run { [weak self] in self?.finishPetting() }
        spriteNode.run(SKAction.sequence([petAction, completion]), withKey: "pettingSequence")
    }

    func finishPetting() {
        guard isPetting else { return }
        isPetting = false
        if isThinkingOnClaudeProxy { startThinkingAnimationLoop() }
        else { startIdleAnimation() }
    }

    func startDraggingAnimationSequence() {
        guard !isCurrentlyDragging else { return }
        ensureTextures(.dragEnter, .dragLoop, .dragExit)
        if isSnappedToSide { clearSnapTextures(); isSnappedToSide = false; snappedSide = 0 }
        isCurrentlyDragging = true; spriteNode.removeAllActions()
        if let firstFrame = dragEnterTextures.first { spriteNode.texture = firstFrame }
        isSleeping = false; isTyping = false; isThinkingOnClaudeProxy = false
        isPlayingRunExit = false; isRestingAtMouse = false; isPetting = false

        guard !dragEnterTextures.isEmpty, !dragLoopTextures.isEmpty else {
            isCurrentlyDragging = false; startIdleAnimation(); return
        }

        let enterAction = SKAction.animate(with: dragEnterTextures, timePerFrame: 0.03)
        let loopAction = SKAction.repeatForever(SKAction.animate(with: dragLoopTextures, timePerFrame: 0.07))
        spriteNode.run(SKAction.sequence([enterAction, loopAction]), withKey: "activeDragSequence")
    }

    func stopDraggingAnimationSequence() {
        guard isCurrentlyDragging else { return }
        isCurrentlyDragging = false; spriteNode.removeAction(forKey: "activeDragSequence")
        isDraggingFromSnap = false
        guard !dragExitTextures.isEmpty else { self.handlePostDraggingState(); return }

        let exitAction = SKAction.animate(with: dragExitTextures, timePerFrame: 0.04)
        let restoreStateAction = SKAction.run { [weak self] in
            self?.spriteNode.xScale = abs(self?.spriteNode.xScale ?? 1)
            self?.handlePostDraggingState()
            self?.checkAndSnapToSide()
        }
        spriteNode.run(SKAction.sequence([exitAction, restoreStateAction]), withKey: "dragExitAction")
    }
    
    func handlePostDraggingState() {
        guard spriteNode != nil else { return }
        if isChasing { startChasing(); return }
        if isClaudeStateActive {
            switch lastClaudeState {
            case "thinking": startThinkingAnimationLoop()
            case "working":  startWorkingAnimationLoop()
            default:         startIdleAnimation()
            }
            return
        }
        startIdleAnimation()
    }
    
    // MARK: - Boundary 边界限制
    func clampedOrigin(for window: NSWindow, x: CGFloat, y: CGFloat) -> NSPoint {
        guard let screen = window.screen ?? NSScreen.main else { return NSPoint(x: x, y: y) }
        let sf = screen.visibleFrame
        let ww = window.frame.width
        let wh = window.frame.height
        let clampedX = min(max(x, sf.minX), sf.maxX - ww)
        let clampedY = min(max(y, sf.minY), sf.maxY - wh)
        return NSPoint(x: clampedX, y: clampedY)
    }

    func playSnapExit() {
        let exitTextures = snappedSide == -1 ? snapLeftExitTextures : snapRightExitTextures
        guard !exitTextures.isEmpty else { return }
        isSnappedToSide = false; snappedSide = 0
        spriteNode.removeAllActions()
        spriteNode.xScale = abs(spriteNode.xScale)
        spriteNode.position.x = spriteNode.scene!.size.width / 2
        let exitAction = SKAction.animate(with: exitTextures, timePerFrame: 0.04)
        spriteNode.run(SKAction.sequence([exitAction, SKAction.run { [weak self] in
            self?.clearSnapTextures()
            self?.checkAndSnapToSide()
            if self?.isSnappedToSide == false { self?.startIdleAnimation() }
        }]), withKey: "snapExitSequence")
    }

    // MARK: - Side Snap 侧边吸附
    let snapThreshold: CGFloat = 60

    // func playSnapIdleLoop() {
    //     guard !snapIdleTextures.isEmpty else { return }
    //     spriteNode.removeAllActions()
    //     spriteNode.run(SKAction.repeatForever(SKAction.animate(with: snapIdleTextures, timePerFrame: 0.05)), withKey: "snapSequence")
    // }

    func checkAndSnapToSide() {
        guard let window = view.window,
              let screen = window.screen ?? NSScreen.main else { return }
        let wf = window.frame
        let sf = screen.visibleFrame
        let snapLeft = wf.minX - sf.minX < snapThreshold
        let snapRight = sf.maxX - wf.maxX < snapThreshold
        guard snapLeft || snapRight else { return }

        isSnappedToSide = true
        snappedSide = snapLeft ? -1 : 1
        if snapLeft {
            ensureTextures(.snapLeftEnter, .snapLeftIdle, .snapLeftExit, .snapReminder2)
        } else {
            ensureTextures(.snapRightEnter, .snapRightIdle, .snapRightExit, .snapReminder1)
        }
        clearNormalTextures()
        spriteNode.xScale = abs(spriteNode.xScale)
        let targetX: CGFloat = snapLeft ? sf.minX : sf.maxX - wf.width
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.3
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            window.animator().setFrameOrigin(NSPoint(x: targetX, y: wf.origin.y))
        }
        let enterTextures   = snapLeft ? snapLeftEnterTextures : snapRightEnterTextures
        let snapIdleTextures = snapLeft ? snapLeftIdleTextures  : snapRightIdleTextures
        guard !enterTextures.isEmpty, !snapIdleTextures.isEmpty else { return }
        spriteNode.removeAllActions()
        let sceneW = spriteNode.scene!.size.width
        let padding = (sceneW - spriteNode.frame.size.width) / 2
        let shiftAction = SKAction.moveTo(x: sceneW / 2 + (snapLeft ? -padding : padding), duration: 0.3)
        shiftAction.timingMode = .easeOut
        spriteNode.run(shiftAction, withKey: "snapShift")
        let enterAction = SKAction.animate(with: enterTextures, timePerFrame: 0.04)
        let idleLoop = SKAction.repeatForever(SKAction.animate(with: snapIdleTextures, timePerFrame: 0.05))
        spriteNode.run(SKAction.sequence([enterAction, idleLoop]), withKey: "snapSequence")
    }

    func unsnap() {
        guard let window = view.window, let screen = window.screen ?? NSScreen.main else { return }
        let sf = screen.visibleFrame
        let wf = window.frame
        let targetX: CGFloat = snappedSide == -1 ? sf.minX : sf.maxX - wf.width
        spriteNode.position.x = spriteNode.scene!.size.width / 2
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.2
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            window.animator().setFrameOrigin(NSPoint(x: targetX, y: wf.origin.y))
        }
        // 不在这里清 isSnappedToSide，由 startDraggingAnimationSequence 清
        // spriteNode.removeAction(forKey: "snapSequence")
    }

    // MARK: - Chase 追逐鼠标
    func toggleChasingMode() { if isChasing { stopChasing() } else { startChasing() } }

    func startChasing() {
        guard !isCurrentlyDragging else { return }
        ensureTextures(.runEnter, .runLoop, .runExit, .runRest)
        isChasing = true; isSleeping = false; isTyping = false; isThinkingOnClaudeProxy = false
        isPlayingRunExit = false; isRestingAtMouse = false; isPetting = false

        spriteNode.removeAllActions()
        guard !runEnterTextures.isEmpty, !runLoopTextures.isEmpty else { return }
        
        let enterAction = SKAction.animate(with: runEnterTextures, timePerFrame: 0.009)
        let loopAction = SKAction.repeatForever(SKAction.animate(with: runLoopTextures, timePerFrame: 0.02))
        spriteNode.run(SKAction.sequence([enterAction, loopAction]), withKey: "runSequence")
    }

    func stopChasing() {
        isChasing = false; isRestingAtMouse = false
        spriteNode.removeAction(forKey: "runSequence")
        spriteNode.removeAction(forKey: "runRestSequence")
        if !isPlayingRunExit { playRunExitAnimation() }
    }

    func playRunExitAnimation() {
        guard !isPlayingRunExit, !runExitTextures.isEmpty else { return }
        isPlayingRunExit = true; isRestingAtMouse = false; spriteNode.removeAllActions()
        
        let exitAction = SKAction.animate(with: runExitTextures, timePerFrame: 0.03)
        let finishAction = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.isPlayingRunExit = false
            if self.isChasing { self.startRestingAtMouse() }
            else { self.spriteNode.xScale = abs(self.spriteNode.xScale); self.startIdleAnimation() }
        }
        spriteNode.run(SKAction.sequence([exitAction, finishAction]), withKey: "runExitSequence")
    }

    func startRestingAtMouse() {
        isRestingAtMouse = true; spriteNode.removeAllActions()
        guard !runRestTextures.isEmpty else { return }
        let restLoop = SKAction.repeatForever(SKAction.animate(with: runRestTextures, timePerFrame: 0.04))
        spriteNode.run(restLoop, withKey: "runRestSequence")
    }

    func startThinkingAnimationLoop() {
        ensureTextures(.enterSearch, .searchLoop, .exitSearch)
        guard !enterSearchTextures.isEmpty, !searchLoopTextures.isEmpty else { return }
        guard !isInteracting else { return }
        spriteNode.removeAllActions(); isTyping = false; isSleeping = false
        let sequence = SKAction.sequence([SKAction.animate(with: enterSearchTextures, timePerFrame: 0.05), SKAction.repeatForever(SKAction.animate(with: searchLoopTextures, timePerFrame: 0.05))])
        spriteNode.run(sequence, withKey: "thinkingSequence")
    }

    func stopThinkingAnimation() {
        isClaudeStateActive = false
        if isSnappedToSide { restoreSnapIdleIfNeeded(); return }
        spriteNode.removeAllActions()
        guard !exitSearchTextures.isEmpty else { startIdleAnimation(); return }
        spriteNode.run(SKAction.sequence([SKAction.animate(with: exitSearchTextures, timePerFrame: 0.05), SKAction.run { [weak self] in self?.startIdleAnimation() }]), withKey: "exitSearchSequence")
    }

    func startPonderAnimationLoop() {
        ensureTextures(.enterThinking, .thinkingLoop, .exitThinking)
        guard !enterThinkingTextures.isEmpty, !thinkingLoopTextures.isEmpty else { return }
        guard !isInteracting else { return }
        spriteNode.removeAllActions(); isTyping = false; isSleeping = false
        let sequence = SKAction.sequence([SKAction.animate(with: enterThinkingTextures, timePerFrame: 0.05), SKAction.repeatForever(SKAction.animate(with: thinkingLoopTextures, timePerFrame: 0.05))])
        spriteNode.run(sequence, withKey: "ponderSequence")
    }

    func stopPonderAnimation() {
        if isSnappedToSide { restoreSnapIdleIfNeeded(); return }
        spriteNode.removeAllActions()
        guard !exitThinkingTextures.isEmpty else { startIdleAnimation(); return }
        spriteNode.run(SKAction.sequence([SKAction.animate(with: exitThinkingTextures, timePerFrame: 0.05), SKAction.run { [weak self] in self?.startIdleAnimation() }]), withKey: "exitPonderSequence")
    }

    func startWorkingAnimationLoop() {
        ensureTextures(.enterWorking, .workingLoop, .exitWorking, .exitSearch)
        guard !isInteracting else { return }
        guard spriteNode.action(forKey: "workingSequence") == nil else { return } // 已在循环中，不重新播
        guard !enterWorkingTextures.isEmpty, !workingLoopTextures.isEmpty else {
            spriteNode.removeAction(forKey: "thinkingSequence"); return
        }

        let beginWorking = { [weak self] in
            guard let self else { return }
            self.spriteNode.removeAllActions(); self.isTyping = false; self.isSleeping = false
            let seq = SKAction.sequence([SKAction.animate(with: self.enterWorkingTextures, timePerFrame: 0.05), SKAction.repeatForever(SKAction.animate(with: self.workingLoopTextures, timePerFrame: 0.05))])
            self.spriteNode.run(seq, withKey: "workingSequence")
        }

        if spriteNode.action(forKey: "thinkingSequence") != nil {
            // 搜索还在循环，先播退出帧再进工作
            spriteNode.removeAction(forKey: "thinkingSequence")
            guard !exitSearchTextures.isEmpty else { beginWorking(); return }
            spriteNode.run(SKAction.sequence([SKAction.animate(with: exitSearchTextures, timePerFrame: 0.05), SKAction.run(beginWorking)]))
        } else {
            beginWorking()
        }
    }

    func stopWorkingAnimation() {
        if isSnappedToSide { restoreSnapIdleIfNeeded(); return }
        spriteNode.removeAllActions()
        guard !exitWorkingTextures.isEmpty else { startIdleAnimation(); return }
        spriteNode.run(SKAction.sequence([SKAction.animate(with: exitWorkingTextures, timePerFrame: 0.05), SKAction.run { [weak self] in self?.startIdleAnimation() }]), withKey: "exitWorkingSequence")
    }

    func startSleepAnimation() {
        ensureTextures(.enterSleep, .sleepLoop, .wakeUp)
        guard !enterSleepTextures.isEmpty, !sleepLoopTextures.isEmpty else { return }
        guard !isInteracting else { return }
        spriteNode.removeAllActions(); isThinkingOnClaudeProxy = false
        spriteNode.run(SKAction.sequence([SKAction.animate(with: enterSleepTextures, timePerFrame: 0.05), SKAction.repeatForever(SKAction.animate(with: sleepLoopTextures, timePerFrame: 0.05))]), withKey: "sleepSequence")
    }

    func wakeUp() {
        guard isSleeping else { return }
        isSleeping = false; spriteNode.removeAllActions()
        guard !wakeUpTextures.isEmpty else { startIdleAnimation(); return }
        spriteNode.run(SKAction.sequence([SKAction.animate(with: wakeUpTextures, timePerFrame: 0.05), SKAction.run { [weak self] in self?.startIdleAnimation() }]), withKey: "wakeUpSequence")
    }

    func startTypingAnimation() {
        ensureTextures(.enterTyping, .typingLoop, .exitTyping)
        guard !isInteracting else { return }
        spriteNode.removeAllActions(); isTyping = true; isThinkingOnClaudeProxy = false
        guard !enterTypingTextures.isEmpty, !typingLoopTextures.isEmpty else { return }
        spriteNode.run(SKAction.sequence([SKAction.animate(with: enterTypingTextures, timePerFrame: 0.05), SKAction.repeatForever(SKAction.animate(with: typingLoopTextures, timePerFrame: 0.05))]), withKey: "typingSequence")
    }
    
    func stopTypingAnimation() {
        guard isTyping else { return }
        isTyping = false; spriteNode.removeAllActions()
        guard !exitTypingTextures.isEmpty else { handlePostTypingState(); return }
        spriteNode.run(SKAction.sequence([SKAction.animate(with: exitTypingTextures, timePerFrame: 0.02), SKAction.run { [weak self] in self?.handlePostTypingState() }]), withKey: "exitTypingSequence")
    }
    
    func handlePostTypingState() {
        if isThinkingOnClaudeProxy { startThinkingAnimationLoop() } else { startIdleAnimation() }
    }

    func playClickAnimationOnce() {
        guard !clickTextures.isEmpty else { return }
        guard !isInteracting else { return }
        spriteNode.removeAllActions()
        spriteNode.run(SKAction.sequence([SKAction.animate(with: clickTextures, timePerFrame: 0.05), SKAction.run { [weak self] in self?.handleClickFinishedState() }]), withKey: "clickAnimation")
    }

    func handleClickFinishedState() {
        if isThinkingOnClaudeProxy { startThinkingAnimationLoop() }
        else if isTyping { startTypingAnimation() }
        else { startIdleAnimation() }
    }

    // MARK: - Elicitation Dialog 选项弹窗
    var elicitationDialogWindow: NSWindow?

    func showElicitationDialog(prompt: String, options: [String], in window: NSWindow, completion: @escaping ([String: Any]) -> Void) {
        guard elicitationDialogWindow == nil else { return }

        let dismiss: ([String: Any]) -> Void = { [weak self] result in
            self?.elicitationDialogWindow?.close()
            self?.elicitationDialogWindow = nil
            completion(result)
        }

        let view = ElicitationDialogView(
            prompt: prompt,
            options: options,
            onSelect: { selected in dismiss(["action": "accept", "selected": selected]) },
            onCancel: { dismiss(["action": "cancel"]) }
        )

        let dialogW: CGFloat = 320
        let baseH:   CGFloat = 130  // 标题 + 问题 + 取消按钮
        let optionH: CGFloat = 44   // 每个选项
        let dialogH = baseH + CGFloat(options.count) * optionH

        let hosting = NSHostingView(rootView: view)
        hosting.frame = NSRect(x: 0, y: 0, width: dialogW, height: dialogH)

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: dialogW, height: dialogH),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.contentView = hosting
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.level = NSWindow.Level(rawValue: NSWindow.Level.floating.rawValue + 2)
        panel.isMovableByWindowBackground = true

        let petFrame = window.frame
        let dialogOrigin: NSPoint
        if isSnappedToSide {
            let dialogX = snappedSide == -1
                ? petFrame.maxX - 80
                : petFrame.minX - dialogW + 80
            dialogOrigin = NSPoint(x: dialogX, y: petFrame.midY - dialogH / 2)
        } else {
            dialogOrigin = NSPoint(x: petFrame.midX - dialogW / 2, y: petFrame.maxY + 8)
        }
        panel.setFrameOrigin(dialogOrigin)

        elicitationDialogWindow = panel
        panel.makeKeyAndOrderFront(nil)
        NSSound(named: "确认提示")?.play()
    }

    // MARK: - Permission Dialog 权限弹窗

    /// 关闭权限弹窗（参照 OVI actionableStateResolved 清除 permissionRequest）
    func dismissPermissionDialogIfNeeded() {
        pendingPermissionSessionId = nil
        if permissionDialogWindow != nil {
            permissionKeyMonitors.forEach { NSEvent.removeMonitor($0) }
            permissionKeyMonitors = []
            permissionDialogWindow?.close()
            permissionDialogWindow = nil
        }
        if inlinePermissionWindow != nil {
            permissionKeyMonitors.forEach { NSEvent.removeMonitor($0) }
            permissionKeyMonitors = []
            inlinePermissionWindow?.close()
            inlinePermissionWindow = nil
        }
        if askUserQuestionWindow != nil {
            askUserQuestionWindow?.close()
            askUserQuestionWindow = nil
        }
    }

    func showPermissionDialog(toolName: String, command: String, suggestions: [[String: Any]], in window: NSWindow, completion: @escaping ([String: Any]) -> Void) {
        guard permissionDialogWindow == nil else { return }

        // 自动批准模式：直接通过，不弹窗
        if autoApproveEnabled {
            completion(["behavior": "allow"])
            return
        }

        let dismiss: ([String: Any]) -> Void = { [weak self] decision in
            self?.permissionKeyMonitors.forEach { NSEvent.removeMonitor($0) }
            self?.permissionKeyMonitors = []
            self?.permissionDialogWindow?.close()
            self?.permissionDialogWindow = nil
            completion(decision)
        }

        // 从 PetSettings 读取快捷键配置
        let s = PetSettings.shared
        let modSym: String
        switch s.permissionModifier {
        case "option":  modSym = "⌥"
        case "command": modSym = "⌘"
        default:        modSym = "⌃"
        }

        let view = PermissionDialogView(
            toolName: toolName,
            command: command,
            hasSuggestions: !suggestions.isEmpty,
            shortcutApprove:     "\(modSym)\(s.shortcutApprove.uppercased())",
            shortcutDeny:        "\(modSym)\(s.shortcutDeny.uppercased())",
            shortcutAlwaysAllow: "\(modSym)\(s.shortcutAlwaysAllow.uppercased())",
            onAllow:       { dismiss(["behavior": "allow"]) },
            onAlwaysAllow: { dismiss(["behavior": "allow", "updatedPermissions": suggestions]) },
            onDeny:        { dismiss(["behavior": "deny"]) }
        )

        let dialogW: CGFloat = 320

        let hosting = NSHostingView(rootView: view)
        hosting.frame = NSRect(x: 0, y: 0, width: dialogW, height: 100)
        // 让 SwiftUI 根据内容自己算高度
        let fittingH = hosting.fittingSize.height
        let dialogH = max(fittingH, 200)
        hosting.frame = NSRect(x: 0, y: 0, width: dialogW, height: dialogH)

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: dialogW, height: dialogH),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.contentView = hosting
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.level = NSWindow.Level(rawValue: NSWindow.Level.floating.rawValue + 2)
        panel.isMovableByWindowBackground = true

        // 吸附状态时弹窗显示在侧边，否则显示在上方居中
        let petFrame = window.frame
        let dialogOrigin: NSPoint
        if isSnappedToSide {
            let dialogX = snappedSide == -1
                ? petFrame.maxX - 80
                : petFrame.minX - dialogW + 80
            let dialogY = petFrame.midY - dialogH / 2
            dialogOrigin = NSPoint(x: dialogX, y: dialogY)
        } else {
            dialogOrigin = NSPoint(x: petFrame.midX - dialogW / 2, y: petFrame.maxY + 8)
        }
        panel.setFrameOrigin(dialogOrigin)

        permissionDialogWindow = panel
        panel.makeKeyAndOrderFront(nil)
        NSSound(named: "确认提示")?.play()

        // 注册全局+本地快捷键监听（弹窗不抢焦点，需手动捕获）
        let handler: (NSEvent) -> Void = { [weak self] event in
            guard self?.permissionDialogWindow != nil else { return }
            let cfg = PetSettings.shared
            let expectedMod: NSEvent.ModifierFlags
            switch cfg.permissionModifier {
            case "option":  expectedMod = .option
            case "command": expectedMod = .command
            default:        expectedMod = .control
            }
            let mod = event.modifierFlags.intersection([.control, .option, .command, .shift])
            guard mod == expectedMod else { return }
            let char = event.charactersIgnoringModifiers?.lowercased()
            switch char {
            case cfg.shortcutApprove:
                DispatchQueue.main.async { dismiss(["behavior": "allow"]) }
            case cfg.shortcutDeny:
                DispatchQueue.main.async { dismiss(["behavior": "deny"]) }
            case cfg.shortcutAlwaysAllow where !suggestions.isEmpty:
                DispatchQueue.main.async { dismiss(["behavior": "allow", "updatedPermissions": suggestions]) }
            case cfg.shortcutAutoApprove:
                DispatchQueue.main.async {
                    self?.autoApproveEnabled = true
                    dismiss(["behavior": "allow"])
                }
            case cfg.shortcutFocusTerminal:
                DispatchQueue.main.async { self?.focusTerminal() }
            default: break
            }
        }
        if let global = NSEvent.addGlobalMonitorForEvents(matching: .keyDown, handler: handler) {
            permissionKeyMonitors.append(global)
        }
        if let local = NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: { event in
            handler(event); return event
        }) {
            permissionKeyMonitors.append(local)
        }
    }

    func focusTerminal() {
        for bid in TerminalRegistry.terminalBundleIds {
            if let app = NSRunningApplication.runningApplications(withBundleIdentifier: bid).first {
                app.activate(options: .activateIgnoringOtherApps)
                return
            }
        }
    }

    // MARK: - Terminal Panel 终端会话面板

    // 用 lsof 获取进程的 cwd
    private func cwdForPID(_ pid: String) -> String {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", "lsof -p \(pid) 2>/dev/null | awk '$4==\"cwd\"{print $9}' | head -1"]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()
        try? task.run()
        task.waitUntilExit()
        return String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    // 用 lsof 获取进程的 cwd（供 openTerminalSession tty 为空时回退查找）
    private func processInfo(pid: String) -> (cwd: String, tty: String) {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", """
            cwd=$(lsof -p \(pid) 2>/dev/null | awk '$4=="cwd"{print $9}' | head -1)
            tty=$(ps -p \(pid) -o tty= 2>/dev/null | tr -d ' ')
            echo "$cwd|$tty"
        """]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()
        try? task.run()
        task.waitUntilExit()
        let out = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let parts = out.split(separator: "|", maxSplits: 1).map(String.init)
        let cwd = parts.first ?? ""
        let ttyRaw = parts.count > 1 ? parts[1] : ""
        let tty = ttyRaw == "??" || ttyRaw.isEmpty ? "" : "/dev/\(ttyRaw)"
        return (cwd: cwd, tty: tty)
    }

    // MARK: - Process Discovery 进程发现
    func startProcessDiscovery() {
        processDiscoveryTimer?.invalidate()
        processDiscoveryTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.discoverAgentProcesses()
        }
    }

    func discoverAgentProcesses() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            let pattern = AgentRegistry.processPattern
            let task = Process()
            task.launchPath = "/bin/bash"
            task.arguments = ["-c", "pgrep -f '\(pattern)' 2>/dev/null | head -40"]
            let pipe = Pipe()
            task.standardOutput = pipe
            task.standardError = Pipe()
            try? task.run()
            task.waitUntilExit()
            let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            let pids = output.split(separator: "\n").map(String.init).filter { !$0.isEmpty }
            guard !pids.isEmpty else { return }

            var discovered: [(pid: String, tty: String, cwd: String, agentId: String)] = []
            for pid in pids {
                let infoTask = Process()
                infoTask.launchPath = "/bin/bash"
                infoTask.arguments = ["-c", "ps -o tty=,args= -p \(pid) 2>/dev/null"]
                let infoPipe = Pipe()
                infoTask.standardOutput = infoPipe
                infoTask.standardError = Pipe()
                try? infoTask.run()
                infoTask.waitUntilExit()
                let info = String(data: infoPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?
                    .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                let matchedAgent = AgentRegistry.agent(forProcessName: info)
                guard matchedAgent != nil else { continue }
                let parts = info.split(separator: " ", maxSplits: 1)
                let ttyRaw = parts.first.map(String.init) ?? ""
                let tty = (ttyRaw == "??" || ttyRaw.isEmpty) ? "" : "/dev/\(ttyRaw)"
                let cwdTask = Process()
                cwdTask.launchPath = "/bin/bash"
                cwdTask.arguments = ["-c", "lsof -p \(pid) 2>/dev/null | awk '$4==\"cwd\"{print $9}' | head -1"]
                let cwdPipe = Pipe()
                cwdTask.standardOutput = cwdPipe
                cwdTask.standardError = Pipe()
                try? cwdTask.run()
                cwdTask.waitUntilExit()
                let cwd = String(data: cwdPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?
                    .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                if !cwd.isEmpty { discovered.append((pid: pid, tty: tty, cwd: cwd, agentId: matchedAgent!.id)) }
            }

            let activeTtys = Set(discovered.map(\.tty).filter { !$0.isEmpty })
            let activeCwds = Set(discovered.map(\.cwd).filter { !$0.isEmpty })

            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                let now = Date().timeIntervalSince1970
                let graceWindow: Double = 120

                for proc in discovered {
                    let alreadyTracked = self.claudeSessions.values.contains { dict in
                        let sTty = dict["tty"] as? String ?? ""
                        let sCwd = dict["cwd"] as? String ?? ""
                        return (!sTty.isEmpty && sTty == proc.tty) || (!sCwd.isEmpty && sCwd == proc.cwd)
                    }
                    if !alreadyTracked {
                        let key = "pid-\(proc.pid)"
                        self.claudeSessions[key] = [
                            "sessionId": key, "cwd": proc.cwd, "tty": proc.tty,
                            "agentId": proc.agentId,
                            "status": "working", "lastActivityAt": now, "startedAt": now
                        ]
                    }
                }

                var keysToRemove: [String] = []
                for (key, dict) in self.claudeSessions {
                    let sTty = dict["tty"] as? String ?? ""
                    let sCwd = dict["cwd"] as? String ?? ""
                    let lastActive = dict["lastActivityAt"] as? Double ?? 0
                    let isAlive = (!sTty.isEmpty && activeTtys.contains(sTty)) ||
                                  (!sCwd.isEmpty && activeCwds.contains(sCwd))
                    if !isAlive && (now - lastActive) > graceWindow {
                        keysToRemove.append(key)
                    }
                }
                for key in keysToRemove { self.claudeSessions.removeValue(forKey: key) }
                if !keysToRemove.isEmpty { self.saveSessionsToDisk() }
            }
        }
    }

    // 刷新面板内容（从内存读取，不再扫描 tty）
    func refreshTerminalSessionsAsync() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let self, let panel = self.terminalPanelWindow, panel.isVisible else { return }
                let sessions = self.loadTerminalSessions()
                let panelW: CGFloat = 373
                let rowH = sessions.map { s -> Int in
                    var h = 50
                    if !s.shortMessage.isEmpty { h += 16 }
                    if !s.lastAssistantMessage.isEmpty { h += s.lastAssistantMessage.count > 60 ? 30 : 16 }
                    if !s.toolTarget.isEmpty && s.isProcessing { h += 16 }
                    return h
                }.reduce(0, +)
                let panelH: CGFloat = min(CGFloat(56 + rowH + 20 + 38), 500)
                let panelView = TerminalSessionPanelView(
                    sessions: sessions,
                    waterCountdown: self.waterCountdownString,
                    onSelect: { [weak self] session in self?.openTerminalSession(session) },
                    onSettings: { SettingsWindowController.shared.open() },
                    onMouseEnter: { [weak self] in
                        self?.isMouseInTerminalPanel = true
                        self?.terminalAutoHideTimer?.invalidate()
                    },
                    onMouseExit: { [weak self] in
                        self?.isMouseInTerminalPanel = false
                        self?.terminalAutoHideTimer?.invalidate()
                        self?.terminalAutoHideTimer = Timer.scheduledTimer(withTimeInterval: self?.terminalAutoHideDelay ?? 0.5, repeats: false) { [weak self] _ in
                            guard let self, !self.isMouseOverPet, !self.isMouseInTerminalPanel else { return }
                            self.hideTerminalPanel()
                        }
                    }
                )
                if let existing = panel.contentView as? FirstMouseHostingView<TerminalSessionPanelView> {
                    existing.rootView = panelView
                } else {
                    let hosting = FirstMouseHostingView(rootView: panelView)
                    hosting.wantsLayer = true
                    hosting.layer?.backgroundColor = NSColor.clear.cgColor
                    hosting.layer?.cornerRadius = TuanziTokens.Radius.xxl
                    hosting.layer?.masksToBounds = true
                    panel.contentView = hosting
                }
                panel.setContentSize(NSSize(width: panelW, height: panelH))
            }
        }
    }

    func loadTerminalSessions() -> [TerminalSession] {
        return claudeSessions.compactMap { id, dict in
            guard let cwd = dict["cwd"] as? String, !cwd.isEmpty else { return nil }
            // 过滤幽灵会话：没有任何消息内容的空壳 session
            let firstMsg = dict["firstUserMessage"] as? String ?? ""
            let lastMsg = dict["lastAssistantMessage"] as? String ?? ""
            if firstMsg.isEmpty && lastMsg.isEmpty { return nil }
            let termApp = Self.inferTerminalApp(from: dict)
            return TerminalSession(
                id: id,
                cwd: cwd,
                firstUserMessage: dict["firstUserMessage"] as? String ?? "",
                lastAssistantMessage: dict["lastAssistantMessage"] as? String ?? "",
                status: dict["status"] as? String ?? "",
                toolTarget: dict["toolTarget"] as? String ?? "",
                tty: dict["tty"] as? String ?? "",
                lastActivityAt: dict["lastActivityAt"] as? Double ?? 0,
                termSessionId: dict["termSessionId"] as? String ?? "",
                terminalApp: termApp,
                startedAt: dict["startedAt"] as? Double ?? 0,
                agentId: dict["agentId"] as? String ?? "claude"
            )
        }.sorted { $0.lastActivityAt > $1.lastActivityAt }
    }

    func openTerminalSession(_ session: TerminalSession) {
        hideTerminalPanel()
        let termApp = resolveTerminalApp(session)
        let def = TerminalRegistry.terminal(forBundleId: termApp)

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            switch def?.jumpMethod {
            case .cliOpen:
                // 编辑器（VS Code / Trae / Cursor 等）：直接 open -b 激活，不改变 workspace
                self?.activateByBundle(termApp)
                return
            case .bundleActivation:
                // Ghostty / WezTerm / Kitty / Warp：open -b 激活
                self?.activateByBundle(termApp)
                return
            default:
                break
            }
            // AppleScript / tmux 跳转链
            if self?.jumpToTerminal(session) == true { return }
            if self?.jumpViaTmux(session) == true { return }
            if self?.jumpByCwd(session) == true { return }
            DispatchQueue.main.async { self?.focusTerminal() }
        }
    }

    /// 通过 open -b 激活应用（任何线程安全，参照 OVI TerminalJumpService）
    private func activateByBundle(_ bundleId: String) {
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = ["-b", bundleId]
        task.standardOutput = Pipe()
        task.standardError = Pipe()
        try? task.run()
        task.waitUntilExit()
    }

    private func jumpViaTmux(_ session: TerminalSession) -> Bool {
        guard !session.cwd.isEmpty else { return false }
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", "which tmux >/dev/null 2>&1 && tmux list-panes -a -F '#{pane_current_path} #{session_name}:#{window_index}.#{pane_index}' 2>/dev/null"]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()
        try? task.run()
        task.waitUntilExit()
        let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        for line in output.split(separator: "\n") {
            let parts = line.split(separator: " ", maxSplits: 1)
            guard parts.count == 2 else { continue }
            if String(parts[0]) == session.cwd {
                let target = String(parts[1])
                let selectTask = Process()
                selectTask.launchPath = "/bin/bash"
                selectTask.arguments = ["-c", "tmux select-pane -t '\(target)' && tmux select-window -t '\(target)'"]
                selectTask.standardOutput = Pipe()
                selectTask.standardError = Pipe()
                try? selectTask.run()
                return true
            }
        }
        return false
    }

    private func jumpToTerminal(_ session: TerminalSession) -> Bool {
        let tty = session.tty
        guard !tty.isEmpty else { return false }

        let termApp = resolveTerminalApp(session)
        var script: String?

        switch termApp {
        case "com.googlecode.iterm2":
            script = """
            tell application "iTerm2"
                repeat with w in windows
                    repeat with t in tabs of w
                        repeat with s in sessions of t
                            if tty of s is "\(tty)" then
                                select t
                                set index of w to 1
                                activate
                                return
                            end if
                        end repeat
                    end repeat
                end repeat
            end tell
            """
        case "com.apple.Terminal":
            script = """
            tell application "Terminal"
                repeat with wi from 1 to (count of windows)
                    repeat with ti from 1 to (count of tabs of window wi)
                        if tty of tab ti of window wi is "\(tty)" then
                            set selected tab of window wi to tab ti of window wi
                            set miniaturized of window wi to false
                            set index of window wi to 1
                            activate
                            return
                        end if
                    end repeat
                end repeat
            end tell
            """
        default:
            // 其他终端：用 open -b 激活（线程安全）
            if !termApp.isEmpty {
                activateByBundle(termApp)
                return true
            }
            script = """
            tell application "Terminal"
                repeat with wi from 1 to (count of windows)
                    repeat with ti from 1 to (count of tabs of window wi)
                        if tty of tab ti of window wi is "\(tty)" then
                            set selected tab of window wi to tab ti of window wi
                            set miniaturized of window wi to false
                            set index of window wi to 1
                            activate
                            return
                        end if
                    end repeat
                end repeat
            end tell
            """
        }

        guard let src = script else { return false }
        if let as_ = NSAppleScript(source: src) {
            var err: NSDictionary?
            as_.executeAndReturnError(&err)
            return err == nil
        }
        return false
    }

    private func jumpByCwd(_ session: TerminalSession) -> Bool {
        let cwd = session.cwd
        guard !cwd.isEmpty else { return false }

        let ids = ["com.googlecode.iterm2", "com.apple.Terminal"]
        for bid in ids {
            guard NSRunningApplication.runningApplications(withBundleIdentifier: bid).first != nil else { continue }

            let script: String
            if bid == "com.googlecode.iterm2" {
                script = """
                tell application "iTerm2"
                    repeat with w in windows
                        repeat with t in tabs of w
                            repeat with s in sessions of t
                                set sName to name of s
                                if sName contains "\(session.projectName)" then
                                    select t
                                    set index of w to 1
                                    activate
                                    return "found"
                                end if
                            end repeat
                        end repeat
                    end repeat
                end tell
                """
            } else {
                script = """
                tell application "Terminal"
                    repeat with wi from 1 to (count of windows)
                        repeat with ti from 1 to (count of tabs of window wi)
                            set cProcs to processes of tab ti of window wi
                            if (count of cProcs) > 0 then
                                set tabName to name of tab ti of window wi
                                if tabName contains "\(session.projectName)" then
                                    set selected tab of window wi to tab ti of window wi
                                    set miniaturized of window wi to false
                                    set index of window wi to 1
                                    activate
                                    return "found"
                                end if
                            end if
                        end repeat
                    end repeat
                end tell
                """
            }

            if let as_ = NSAppleScript(source: script) {
                var err: NSDictionary?
                let result = as_.executeAndReturnError(&err)
                if let str = result.stringValue, str == "found" { return true }
            }
        }
        return false
    }

    private func resolveTerminalApp(_ session: TerminalSession) -> String {
        if !session.terminalApp.isEmpty {
            return Self.normalizeTerminalApp(session.terminalApp)
        }
        for bid in TerminalRegistry.terminalBundleIds {
            if NSRunningApplication.runningApplications(withBundleIdentifier: bid).first != nil {
                return bid
            }
        }
        return "com.apple.Terminal"
    }

    /// 将 $TERM_PROGRAM 等值标准化为 bundleId（参照 open-vibe-island inferTerminalApp）
    static func normalizeTerminalApp(_ raw: String) -> String {
        // 已经是 bundleId 格式
        if raw.contains(".") && raw.filter({ $0 == "." }).count >= 2 { return raw }

        let lower = raw.lowercased()
        // 精确匹配 $TERM_PROGRAM 值 → bundleId
        switch lower {
        case "apple_terminal":
            return "com.apple.Terminal"
        case "iterm.app", "iterm2":
            return "com.googlecode.iterm2"
        case "vscode":
            return "com.microsoft.VSCode"
        case "vscode-insiders":
            return "com.microsoft.VSCode"  // 归为同一类
        case "trae":
            return "com.trae.app"
        case "windsurf":
            return "com.codeium.windsurf"
        case "wezterm":
            return "com.github.wez.wezterm"
        case "kaku":
            return raw  // 无 bundleId
        default:
            break
        }
        // 模糊匹配
        if lower.contains("warp") { return "dev.warp.Warp-Stable" }
        if lower.contains("ghostty") { return "com.mitchellh.ghostty" }
        if lower.contains("kitty") { return "net.kovidgoyal.kitty" }
        if lower.contains("cursor") { return "com.todesktop.230313mzl4w4u92" }
        // JetBrains 系列
        if lower.contains("intellij") { return "com.jetbrains.intellij" }
        if lower.contains("webstorm") { return "com.jetbrains.WebStorm" }
        if lower.contains("pycharm") { return "com.jetbrains.pycharm" }
        if lower.contains("goland") { return "com.jetbrains.goland" }
        if lower.contains("clion") { return "com.jetbrains.clion" }
        if lower.contains("rubymine") { return "com.jetbrains.rubymine" }
        if lower.contains("phpstorm") { return "com.jetbrains.PhpStorm" }
        if lower.contains("rider") { return "com.jetbrains.rider" }
        if lower.contains("rustrover") { return "com.jetbrains.rustrover" }
        // 兜底：尝试 TerminalRegistry 模糊匹配
        let cleaned = lower.replacingOccurrences(of: "_", with: "").replacingOccurrences(of: " ", with: "")
        if let def = TerminalRegistry.allTerminals.first(where: {
            cleaned.contains($0.id.lowercased()) ||
            $0.displayName.lowercased().replacingOccurrences(of: " ", with: "") == cleaned
        }), !def.bundleId.isEmpty {
            return def.bundleId
        }
        return raw
    }

    /// 从 session 数据的环境变量推断 terminalApp bundleId
    /// 优先级参照 open-vibe-island inferTerminalApp
    static func inferTerminalApp(from dict: [String: Any]) -> String {
        let rawTermApp = dict["terminalApp"] as? String ?? ""
        let termEmu = dict["terminalEmulator"] as? String ?? ""
        let cursorTrace = dict["cursorTraceId"] as? String ?? ""
        let cmuxId = dict["cmuxWorkspaceId"] as? String ?? ""
        let zellij = dict["zellij"] as? String ?? ""
        let itermSid = dict["itermSessionId"] as? String ?? ""
        let warpLocal = dict["warpLocal"] as? String ?? ""
        let ghosttyRes = dict["ghosttyResources"] as? String ?? ""
        let cfBundle = dict["cfBundleIdentifier"] as? String ?? ""

        // 优先级 1：多路复用器
        if !cmuxId.isEmpty { return "" }  // cmux 无 bundleId
        if !zellij.isEmpty { return "" }  // zellij 无 bundleId

        // 优先级 2：TERM_PROGRAM（最权威）
        if !rawTermApp.isEmpty {
            var normalized = normalizeTerminalApp(rawTermApp)
            // Cursor 也设 TERM_PROGRAM=vscode，用 CURSOR_TRACE_ID 区分
            if normalized == "com.microsoft.VSCode" && !cursorTrace.isEmpty {
                normalized = "com.todesktop.230313mzl4w4u92"
            }
            return normalized
        }

        // 优先级 3：特定应用环境变量（兜底，容易被跨应用继承污染）
        if !itermSid.isEmpty { return "com.googlecode.iterm2" }
        if !warpLocal.isEmpty { return "dev.warp.Warp-Stable" }
        if !ghosttyRes.isEmpty { return "com.mitchellh.ghostty" }

        // 优先级 4：JetBrains TERMINAL_EMULATOR
        if termEmu.lowercased().contains("jetbrains") {
            let bid = cfBundle.lowercased()
            if bid.contains("webstorm") { return "com.jetbrains.WebStorm" }
            if bid.contains("pycharm") { return "com.jetbrains.pycharm" }
            if bid.contains("goland") { return "com.jetbrains.goland" }
            if bid.contains("clion") { return "com.jetbrains.clion" }
            if bid.contains("rubymine") { return "com.jetbrains.rubymine" }
            if bid.contains("phpstorm") { return "com.jetbrains.PhpStorm" }
            if bid.contains("rider") { return "com.jetbrains.rider" }
            if bid.contains("rustrover") { return "com.jetbrains.rustrover" }
            return "com.jetbrains.intellij"
        }

        // 优先级 5：__CFBundleIdentifier 兜底
        // VS Code 扩展环境没有 TERM_PROGRAM，但有 __CFBundleIdentifier
        if !cfBundle.isEmpty {
            // 直接就是 bundleId 格式，检查是否为已知应用
            if TerminalRegistry.terminal(forBundleId: cfBundle) != nil {
                return cfBundle
            }
            // 模糊匹配（部分 bundleId 大小写不同）
            let lowerBid = cfBundle.lowercased()
            if let def = TerminalRegistry.allTerminals.first(where: {
                !$0.bundleId.isEmpty && $0.bundleId.lowercased() == lowerBid
            }) {
                return def.bundleId
            }
        }

        return rawTermApp
    }

    // MARK: - Inline Permission 侧边内联权限审批
    var inlinePermissionWindow: NSPanel?

    func showInlinePermission(toolName: String, command: String, suggestions: [[String: Any]], completion: @escaping ([String: Any]) -> Void) {
        guard inlinePermissionWindow == nil else { return }

        if autoApproveEnabled {
            completion(["behavior": "allow"]); return
        }

        let dismiss: ([String: Any]) -> Void = { [weak self] decision in
            self?.permissionKeyMonitors.forEach { NSEvent.removeMonitor($0) }
            self?.permissionKeyMonitors = []
            self?.inlinePermissionWindow?.close()
            self?.inlinePermissionWindow = nil
            completion(decision)
        }

        let s = PetSettings.shared
        let modSym: String
        switch s.permissionModifier {
        case "option":  modSym = "⌥"
        case "command": modSym = "⌘"
        default:        modSym = "⌃"
        }

        let view = PermissionDialogView(
            toolName: toolName, command: command, hasSuggestions: !suggestions.isEmpty,
            shortcutApprove: "\(modSym)\(s.shortcutApprove.uppercased())",
            shortcutDeny: "\(modSym)\(s.shortcutDeny.uppercased())",
            shortcutAlwaysAllow: "\(modSym)\(s.shortcutAlwaysAllow.uppercased())",
            onAllow:       { dismiss(["behavior": "allow"]) },
            onAlwaysAllow: { dismiss(["behavior": "allow", "updatedPermissions": suggestions]) },
            onDeny:        { dismiss(["behavior": "deny"]) }
        )

        let panelW: CGFloat = 320
        let hosting = NSHostingView(rootView: view)
        hosting.frame = NSRect(x: 0, y: 0, width: panelW, height: 100)
        let panelH = max(hosting.fittingSize.height, 200)
        hosting.frame = NSRect(x: 0, y: 0, width: panelW, height: panelH)

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: panelW, height: panelH),
            styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false
        )
        panel.contentView = hosting
        panel.backgroundColor = .clear; panel.isOpaque = false
        panel.hasShadow = true; panel.level = NSWindow.Level(rawValue: NSWindow.Level.floating.rawValue + 2)

        guard let petWindow = self.view.window else { dismiss(["behavior": "deny"]); return }
        let pf = petWindow.frame
        let sf = (petWindow.screen ?? NSScreen.main)?.visibleFrame ?? NSScreen.main!.visibleFrame
        let targetX: CGFloat = snappedSide == 1 ? pf.maxX - 110 - panelW : pf.minX + 65
        let startX: CGFloat = snappedSide == 1 ? sf.maxX : sf.minX - panelW
        let targetY = max(pf.midY - panelH / 2, 8)

        panel.setFrame(NSRect(x: startX, y: targetY, width: panelW, height: panelH), display: false)
        panel.orderFrontRegardless()
        let anim = NSViewAnimation(viewAnimations: [[
            NSViewAnimation.Key.target: panel,
            NSViewAnimation.Key.startFrame: NSValue(rect: NSRect(x: startX, y: targetY, width: panelW, height: panelH)),
            NSViewAnimation.Key.endFrame: NSValue(rect: NSRect(x: targetX, y: targetY, width: panelW, height: panelH))
        ]])
        anim.duration = 0.25; anim.animationCurve = .easeOut; anim.start()
        inlinePermissionWindow = panel
        NSSound(named: "确认提示")?.play()

        let handler: (NSEvent) -> Void = { [weak self] event in
            guard self?.inlinePermissionWindow != nil else { return }
            let cfg = PetSettings.shared
            let expectedMod: NSEvent.ModifierFlags
            switch cfg.permissionModifier {
            case "option":  expectedMod = .option
            case "command": expectedMod = .command
            default:        expectedMod = .control
            }
            let mod = event.modifierFlags.intersection([.control, .option, .command, .shift])
            guard mod == expectedMod else { return }
            let char = event.charactersIgnoringModifiers?.lowercased()
            switch char {
            case cfg.shortcutApprove:
                DispatchQueue.main.async { dismiss(["behavior": "allow"]) }
            case cfg.shortcutDeny:
                DispatchQueue.main.async { dismiss(["behavior": "deny"]) }
            case cfg.shortcutAlwaysAllow where !suggestions.isEmpty:
                DispatchQueue.main.async { dismiss(["behavior": "allow", "updatedPermissions": suggestions]) }
            case cfg.shortcutAutoApprove:
                DispatchQueue.main.async { self?.autoApproveEnabled = true; dismiss(["behavior": "allow"]) }
            case cfg.shortcutFocusTerminal:
                DispatchQueue.main.async { self?.focusTerminal() }
            default: break
            }
        }
        if let global = NSEvent.addGlobalMonitorForEvents(matching: .keyDown, handler: handler) {
            permissionKeyMonitors.append(global)
        }
        if let local = NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: { event in handler(event); return event }) {
            permissionKeyMonitors.append(local)
        }
    }

    // MARK: - Inline Elicitation 侧边内联选项
    var inlineElicitationWindow: NSPanel?

    // MARK: - AskUserQuestion 选项弹窗
    var askUserQuestionWindow: NSPanel?

    func showAskUserQuestionDialog(prompt: String, options: [String], completion: @escaping (Int) -> Void) {
        guard askUserQuestionWindow == nil else { return }

        let dismiss: (Int) -> Void = { [weak self] index in
            self?.askUserQuestionWindow?.close()
            self?.askUserQuestionWindow = nil
            completion(index)
        }

        let view = AskUserQuestionView(prompt: prompt, options: options, onSelect: dismiss)

        let panelW: CGFloat = 340
        let panelH: CGFloat = CGFloat(100 + options.count * 48)
        let hosting = NSHostingView(rootView: view)
        hosting.frame = NSRect(x: 0, y: 0, width: panelW, height: panelH)

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: panelW, height: panelH),
            styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false
        )
        panel.contentView = hosting
        panel.backgroundColor = .clear; panel.isOpaque = false
        panel.hasShadow = true
        panel.level = NSWindow.Level(rawValue: NSWindow.Level.floating.rawValue + 2)

        guard let petWindow = self.view.window else { dismiss(0); return }
        if isSnappedToSide {
            let pf = petWindow.frame
            let targetX: CGFloat = snappedSide == 1 ? pf.maxX - 110 - panelW : pf.minX + 65
            let targetY = max(pf.midY - panelH / 2, 8)
            panel.setFrameOrigin(NSPoint(x: targetX, y: targetY))
        } else {
            let petFrame = petWindow.frame
            panel.setFrameOrigin(NSPoint(x: petFrame.midX - panelW / 2, y: petFrame.maxY + 8))
        }

        askUserQuestionWindow = panel
        panel.makeKeyAndOrderFront(nil)
        NSSound(named: "确认提示")?.play()
    }

    func typeInTerminal(_ text: String) {
        let escaped = text.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"")
        let script = """
        tell application "System Events"
            keystroke "\(escaped)"
        end tell
        """
        DispatchQueue.global(qos: .userInitiated).async {
            if let as_ = NSAppleScript(source: script) {
                var err: NSDictionary?
                as_.executeAndReturnError(&err)
            }
        }
    }

    func showInlineElicitation(prompt: String, options: [String], completion: @escaping ([String: Any]) -> Void) {
        guard inlineElicitationWindow == nil else { return }

        let dismiss: ([String: Any]) -> Void = { [weak self] result in
            self?.inlineElicitationWindow?.close()
            self?.inlineElicitationWindow = nil
            completion(result)
        }

        let view = ElicitationDialogView(
            prompt: prompt, options: options,
            onSelect: { selected in dismiss(["action": "accept", "selected": selected]) },
            onCancel: { dismiss(["action": "cancel"]) }
        )

        let panelW: CGFloat = 320
        let panelH: CGFloat = CGFloat(130 + options.count * 44)
        let hosting = NSHostingView(rootView: view)
        hosting.frame = NSRect(x: 0, y: 0, width: panelW, height: panelH)

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: panelW, height: panelH),
            styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false
        )
        panel.contentView = hosting
        panel.backgroundColor = .clear; panel.isOpaque = false
        panel.hasShadow = true; panel.level = NSWindow.Level(rawValue: NSWindow.Level.floating.rawValue + 2)

        guard let petWindow = self.view.window else { dismiss(["action": "cancel"]); return }
        let pf = petWindow.frame
        let sf = (petWindow.screen ?? NSScreen.main)?.visibleFrame ?? NSScreen.main!.visibleFrame
        let targetX: CGFloat = snappedSide == 1 ? pf.maxX - 110 - panelW : pf.minX + 65
        let startX: CGFloat = snappedSide == 1 ? sf.maxX : sf.minX - panelW
        let targetY = max(pf.midY - panelH / 2, 8)

        panel.setFrame(NSRect(x: startX, y: targetY, width: panelW, height: panelH), display: false)
        panel.orderFrontRegardless()
        let anim = NSViewAnimation(viewAnimations: [[
            NSViewAnimation.Key.target: panel,
            NSViewAnimation.Key.startFrame: NSValue(rect: NSRect(x: startX, y: targetY, width: panelW, height: panelH)),
            NSViewAnimation.Key.endFrame: NSValue(rect: NSRect(x: targetX, y: targetY, width: panelW, height: panelH))
        ]])
        anim.duration = 0.25; anim.animationCurve = .easeOut; anim.start()
        inlineElicitationWindow = panel
        NSSound(named: "确认提示")?.play()
    }

    func showTerminalPanel() {
        guard view.window != nil else { return }
        // 异步刷新（不阻塞渲染，扫完自动更新面板内容）
        refreshTerminalSessionsAsync()
        let sessions = loadTerminalSessions()
        let panelW: CGFloat = 373
        let rowH = sessions.map { s -> Int in
                    var h = 50
                    if !s.shortMessage.isEmpty { h += 16 }
                    if !s.lastAssistantMessage.isEmpty { h += s.lastAssistantMessage.count > 60 ? 30 : 16 }
                    if !s.toolTarget.isEmpty && s.isProcessing { h += 16 }
                    return h
                }.reduce(0, +)
                let panelH: CGFloat = min(CGFloat(56 + rowH + 20 + 38), 500)

        if terminalPanelWindow == nil {
            let panel = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: panelW, height: panelH),
                styleMask: [.borderless, .nonactivatingPanel],
                backing: .buffered, defer: false
            )
            panel.backgroundColor = .clear
            panel.isOpaque = false
            panel.hasShadow = true
            panel.level = NSWindow.Level(rawValue: NSWindow.Level.floating.rawValue + 2)
            panel.acceptsMouseMovedEvents = true
            panel.isReleasedWhenClosed = false
            terminalPanelWindow = panel
        }

        let panelView = TerminalSessionPanelView(
            sessions: sessions,
            waterCountdown: waterCountdownString,
            onSelect: { [weak self] session in self?.openTerminalSession(session) },
            onSettings: { SettingsWindowController.shared.open() },
            onMouseEnter: { [weak self] in
                self?.isMouseInTerminalPanel = true
                self?.terminalAutoHideTimer?.invalidate()
            },
            onMouseExit: { [weak self] in
                self?.isMouseInTerminalPanel = false
                guard self?.isMouseOverPet == false else { return }
                self?.terminalAutoHideTimer?.invalidate()
                self?.terminalAutoHideTimer = Timer.scheduledTimer(withTimeInterval: self?.terminalAutoHideDelay ?? 0.5, repeats: false) { [weak self] _ in
                    guard let self, !self.isMouseOverPet, !self.isMouseInTerminalPanel else { return }
                    self.hideTerminalPanel()
                }
            }
        )
        let hosting = FirstMouseHostingView(rootView: panelView)
        hosting.frame = NSRect(x: 0, y: 0, width: panelW, height: panelH)
        hosting.wantsLayer = true
        hosting.layer?.backgroundColor = NSColor.clear.cgColor
        hosting.layer?.cornerRadius = TuanziTokens.Radius.xxl
        hosting.layer?.masksToBounds = true

        terminalPanelWindow?.contentView = hosting
        terminalPanelWindow?.setContentSize(NSSize(width: panelW, height: panelH))

        // 根据吸附方向决定弹出位置和动画方向
        guard let panel = terminalPanelWindow, let petWindow = view.window else { return }
        let pf = petWindow.frame
        let sf = (petWindow.screen ?? NSScreen.main)?.visibleFrame ?? NSScreen.main!.visibleFrame
        let targetX: CGFloat = snappedSide == 1 ? pf.maxX - 110 - panelW : pf.minX + 65
        let startX:  CGFloat = snappedSide == 1 ? sf.maxX               : sf.minX - panelW
        let targetY = max(pf.midY - panelH / 2, 8)
        let startFrame = NSRect(x: startX,   y: targetY, width: panelW, height: panelH)
        let endFrame   = NSRect(x: targetX,  y: targetY, width: panelW, height: panelH)
        panel.setFrame(startFrame, display: false)
        panel.orderFrontRegardless()
        let anim = NSViewAnimation(viewAnimations: [[
            NSViewAnimation.Key.target:     panel,
            NSViewAnimation.Key.startFrame: NSValue(rect: startFrame),
            NSViewAnimation.Key.endFrame:   NSValue(rect: endFrame)
        ]])
        anim.duration = 0.25
        anim.animationCurve = .easeOut
        anim.start()
    }

    func hideTerminalPanel() {
        // 只有面板可见时才隐藏；guard 失败时不设 cooldown，避免误拦截悬停
        guard let panel = terminalPanelWindow, panel.isVisible else { return }
        let sf = (view.window?.screen ?? NSScreen.main)?.visibleFrame ?? NSScreen.main!.visibleFrame
        let exitX: CGFloat = snappedSide == 1 ? sf.maxX : sf.minX - panel.frame.width
        let endFrame = NSRect(x: exitX, y: panel.frame.minY,
                              width: panel.frame.width, height: panel.frame.height)
        let anim = NSViewAnimation(viewAnimations: [[
            NSViewAnimation.Key.target:     panel,
            NSViewAnimation.Key.startFrame: NSValue(rect: panel.frame),
            NSViewAnimation.Key.endFrame:   NSValue(rect: endFrame)
        ]])
        anim.duration = 0.15
        anim.animationCurve = .easeIn
        anim.start()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak panel] in
            panel?.orderOut(nil)
        }
    }

    // func playErrorAnimation() {
    //     guard !errorTextures.isEmpty else { isClaudeStateActive = false; startIdleAnimation(); return }
    //     guard !isInteracting else { return }
    //     spriteNode.removeAllActions(); isTyping = false; isSleeping = false; isThinkingOnClaudeProxy = false
    //     let playAction = SKAction.animate(with: errorTextures, timePerFrame: 0.05)
    //     spriteNode.run(SKAction.sequence([playAction, SKAction.run { [weak self] in self?.isClaudeStateActive = false; self?.startIdleAnimation() }]), withKey: "errorSequence")
    // }

    func playAttentionAnimation() {
        ensureTextures(.attention)
        guard !attentionTextures.isEmpty else { isClaudeStateActive = false; startIdleAnimation(); return }
        guard !isInteracting else { return }
        spriteNode.removeAllActions(); isTyping = false; isSleeping = false; isThinkingOnClaudeProxy = false
        let playAction = SKAction.animate(with: attentionTextures, timePerFrame: 0.05)
        let finish = SKAction.run { [weak self] in self?.isClaudeStateActive = false; self?.startIdleAnimation() }
        if PetSettings.shared.enableCompletionSound {
            let soundAction = SKAction.playSoundFileNamed("claude提示.mp3", waitForCompletion: false)
            spriteNode.run(SKAction.sequence([soundAction, playAction, finish]), withKey: "attentionSequence")
        } else {
            spriteNode.run(SKAction.sequence([playAction, finish]), withKey: "attentionSequence")
        }
    }

    func playNotificationAnimation() {
        ensureTextures(.message, .click)
        guard !isInteracting else { return }
        spriteNode.removeAllActions(); isTyping = false; isSleeping = false; isThinkingOnClaudeProxy = false
        let texturesToPlay = notificationTextures.isEmpty ? clickTextures : notificationTextures
        guard !texturesToPlay.isEmpty else { isClaudeStateActive = false; return }
        let playAction = SKAction.repeat(SKAction.animate(with: texturesToPlay, timePerFrame: 0.05), count: 2)
        spriteNode.run(SKAction.sequence([playAction, SKAction.run { [weak self] in self?.isClaudeStateActive = false; self?.startIdleAnimation() }]), withKey: "notificationSequence")
    }

    // MARK: - Snap Reminder 侧边任务完成提醒

    func startSnapReminderLoop() {
        guard isSnappedToSide else { return }
        isSnapReminding = true
        snapReminderCycleCount = 0
        playSnapReminderCycle()
    }

    func playSnapReminderCycle() {
        guard isSnappedToSide, isSnapReminding else { stopSnapReminder(); return }
        snapReminderCycleCount += 1
        guard snapReminderCycleCount <= 1 else { stopSnapReminder(); return }

        let snapIdleTextures = snappedSide == -1 ? snapLeftIdleTextures : snapRightIdleTextures
        let reminderTextures = snappedSide == -1 ? snapReminder2Textures : snapReminder1Textures
        guard !reminderTextures.isEmpty else { stopSnapReminder(); return }

        var actions: [SKAction] = []
        if PetSettings.shared.enableCompletionSound {
            actions.append(SKAction.playSoundFileNamed("claude提示.mp3", waitForCompletion: false))
        }
        actions.append(SKAction.animate(with: reminderTextures, timePerFrame: 0.05))
        // 提醒完后短暂播一轮 snap idle，再安排下次循环
        if !snapIdleTextures.isEmpty {
            actions.append(SKAction.animate(with: snapIdleTextures, timePerFrame: 0.05))
        }
        actions.append(SKAction.run { [weak self] in
            guard let self, self.isSnapReminding, self.isSnappedToSide else { self?.stopSnapReminder(); return }
            if !snapIdleTextures.isEmpty {
                self.spriteNode.run(SKAction.repeatForever(SKAction.animate(with: snapIdleTextures, timePerFrame: 0.05)), withKey: "snapSequence")
            }
            self.snapReminderTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
                guard let self, self.isSnapReminding else { return }
                self.playSnapReminderCycle()
            }
        })

        spriteNode.removeAction(forKey: "snapSequence")
        spriteNode.run(SKAction.sequence(actions), withKey: "snapReminderSequence")
    }

    func stopSnapReminder() {
        guard isSnapReminding else { return }
        isSnapReminding = false
        snapReminderTimer?.invalidate(); snapReminderTimer = nil
        spriteNode.removeAction(forKey: "snapReminderSequence")
        isClaudeStateActive = false
        guard isSnappedToSide else { return }
        let snapIdleTextures = snappedSide == -1 ? snapLeftIdleTextures : snapRightIdleTextures
        guard !snapIdleTextures.isEmpty else { return }
        spriteNode.run(SKAction.repeatForever(SKAction.animate(with: snapIdleTextures, timePerFrame: 0.05)), withKey: "snapSequence")
    }

    // MARK: - Water Reminder 喝水提醒
    func playDrinkWaterAnimation() {
        ensureTextures(.drinkWater)
        guard !drinkWaterTextures.isEmpty else { return }
        // 最高优先级：强制打断所有状态
        stopCountdown()
        spriteNode.removeAllActions()
        isTyping = false; isSleeping = false; isThinkingOnClaudeProxy = false

        let drinkSequence = SKAction.sequence([
            SKAction.playSoundFileNamed("提醒.mp3", waitForCompletion: false),
            SKAction.repeat(SKAction.animate(with: drinkWaterTextures, timePerFrame: 0.05), count: 3),
            SKAction.run { [weak self] in
                self?.restartWaterCountdown()
                self?.checkAndSnapToSide()
                if self?.isSnappedToSide == false { self?.startIdleAnimation() }
            }
        ])

        if isSnappedToSide {
            let exitTextures = snappedSide == -1 ? snapLeftExitTextures : snapRightExitTextures
            isSnappedToSide = false; snappedSide = 0
            spriteNode.xScale = abs(spriteNode.xScale)
            if !exitTextures.isEmpty {
                spriteNode.run(SKAction.sequence([
                    SKAction.animate(with: exitTextures, timePerFrame: 0.04),
                    drinkSequence
                ]), withKey: "drinkWaterSequence")
                return
            }
        }
        spriteNode.run(drinkSequence, withKey: "drinkWaterSequence")
    }

    func scheduleWaterReminder(minutes: Double) {
        waterTimer?.invalidate(); countdownTimer?.invalidate()
        waterReminderIntervalSeconds = minutes * 60
        waterReminderEndDate = Date().addingTimeInterval(waterReminderIntervalSeconds)
        countdownContainer?.isHidden = isSnappedToSide || !isMouseOverPet
        updateCountdownDisplay()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in self?.updateCountdownDisplay() }
        waterTimer = Timer.scheduledTimer(withTimeInterval: waterReminderIntervalSeconds, repeats: true) { [weak self] _ in self?.playDrinkWaterAnimation() }
    }

    func restartWaterCountdown() {
        guard waterReminderIntervalSeconds > 0, waterTimer?.isValid == true else { return }
        countdownTimer?.invalidate()
        waterReminderEndDate = Date().addingTimeInterval(waterReminderIntervalSeconds)
        countdownContainer?.isHidden = isSnappedToSide || !isMouseOverPet
        updateCountdownDisplay()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in self?.updateCountdownDisplay() }
    }

    var waterCountdownString: String {
        guard let endDate = waterReminderEndDate else { return "" }
        let remaining = endDate.timeIntervalSince(Date())
        guard remaining > 0 else { return "" }
        let h = Int(remaining) / 3600
        let m = (Int(remaining) % 3600) / 60
        let s = Int(remaining) % 60
        return h > 0 ? String(format: "%d:%02d:%02d", h, m, s) : String(format: "%02d:%02d", m, s)
    }

    func updateCountdownDisplay() {
        guard let endDate = waterReminderEndDate else { stopCountdown(); return }
        let remaining = endDate.timeIntervalSince(Date())
        if remaining <= 0 { stopCountdown(); return }

        if isSnappedToSide {
            countdownContainer?.isHidden = true
            if terminalPanelWindow?.isVisible == true { refreshTerminalSessionsAsync() }
        } else {
            let hours = Int(remaining) / 3600
            let minutes = (Int(remaining) % 3600) / 60
            let seconds = Int(remaining) % 60
            let timeString = hours > 0 ? String(format: "%d:%02d:%02d", hours, minutes, seconds) : String(format: "%02d:%02d", minutes, seconds)
            countdownLabel?.stringValue = "💧 \(timeString)"
            countdownLabel?.alignment = .center
        }
    }

    func stopCountdown() { countdownTimer?.invalidate(); countdownTimer = nil; waterReminderEndDate = nil; countdownContainer?.isHidden = true }
    func cancelWaterReminder() { waterTimer?.invalidate(); stopCountdown(); refreshTerminalSessionsAsync() }

    // MARK: - Timers 定时任务
    func startChaseTimer() {
        chaseTimer?.invalidate()
        chaseTimer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            guard let self else { return }
            guard !self.isClaudeStateActive, !self.isCurrentlyDragging, !self.isPetting else { return }
            if self.isSleeping { self.wakeUp() }
            self.startChasing()
        }
    }

    // MARK: - IM Badge Monitor 消息角标监听
    func startFeishuMonitor() {
        feishuTimer?.invalidate()
        feishuTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in self?.checkFeishuBadge() }
    }
    
    func checkFeishuBadge() {
        // AXUIElement API 需在主线程调用
        let targetName = "小米办公Pro"
        var currentBadge = ""

        if let dockApp = NSWorkspace.shared.runningApplications.first(where: { $0.bundleIdentifier == "com.apple.dock" }) {
            let dockElement = AXUIElementCreateApplication(dockApp.processIdentifier)
            var childrenRaw: CFTypeRef?
            if AXUIElementCopyAttributeValue(dockElement, kAXChildrenAttribute as CFString, &childrenRaw) == .success,
               let children = childrenRaw as? [AXUIElement], let listElement = children.first {
                var listChildrenRaw: CFTypeRef?
                if AXUIElementCopyAttributeValue(listElement, kAXChildrenAttribute as CFString, &listChildrenRaw) == .success,
                   let dockItems = listChildrenRaw as? [AXUIElement] {
                    for item in dockItems {
                        var titleRaw: CFTypeRef?
                        if AXUIElementCopyAttributeValue(item, kAXTitleAttribute as CFString, &titleRaw) == .success,
                           let title = titleRaw as? String, title == targetName {
                            var badgeRaw: CFTypeRef?
                            if AXUIElementCopyAttributeValue(item, "AXStatusLabel" as CFString, &badgeRaw) == .success {
                                currentBadge = (badgeRaw as? String) ?? ""
                            }
                            break
                        }
                    }
                }
            }
        }

        if !currentBadge.isEmpty && currentBadge != lastFeishuBadgeCount {
            lastFeishuBadgeCount = currentBadge
            feishuAlertTimer?.invalidate()
            playFeishuMessageAnimation()
        } else if currentBadge.isEmpty {
            lastFeishuBadgeCount = ""
            feishuAlertTimer?.invalidate()
        }
    }
    
    func playFeishuMessageAnimation() {
        ensureTextures(.message, .click)
        guard !isInteracting, !isClaudeStateActive else { return }
        spriteNode.removeAllActions(); isTyping = false; isSleeping = false; isThinkingOnClaudeProxy = false
        let soundAction = SKAction.playSoundFileNamed("提醒.mp3", waitForCompletion: false)
        let texturesToPlay = messageTextures.isEmpty ? clickTextures : messageTextures
        guard !texturesToPlay.isEmpty else { return }

        let repeatAction = SKAction.repeat(SKAction.animate(with: texturesToPlay, timePerFrame: 0.05), count: 2)
        spriteNode.run(SKAction.sequence([soundAction, repeatAction, SKAction.run { [weak self] in self?.startIdleAnimation() }]), withKey: "feishuMessageSequence")
    }

    // MARK: - Idle & Sleep 空闲与睡眠
    func resetIdleTimer() {
        idleActionTimer?.invalidate()
        if isSleeping && !isClaudeStateActive { wakeUp() }

        idleActionTimer = Timer.scheduledTimer(withTimeInterval: idleTimeout, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            if !self.isTyping && !self.isThinkingOnClaudeProxy && !self.isClaudeStateActive && !self.isCurrentlyDragging && !self.isChasing && !self.isSleeping && !self.isPetting {
                self.enterSleep()
            }
        }
    }
    
    func enterSleep() { guard !isSleeping, !isTyping, !isThinkingOnClaudeProxy, !isInteracting else { return }; isSleeping = true; startSleepAnimation() }
    
    func resetTypingTimer() {
        typingTimer?.invalidate()
        typingTimer = Timer.scheduledTimer(withTimeInterval: typingTimeout, repeats: false) { [weak self] _ in self?.stopTypingAnimation(); self?.firstKeystrokeTime = nil }
    }

    // MARK: - Event Monitors 全局事件监听
    func setupGlobalMonitors() {
        localMouseMonitor = NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) { [weak self] event in
            self?.resetIdleTimer(); return event
        }
        globalMouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved]) { [weak self] _ in self?.resetIdleTimer() }

        globalKeyboardMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.keyDown]) { [weak self] _ in self?.handleTypingActivity() }
        localKeyboardMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in self?.handleTypingActivity(); return event }
    }

    // 检测辅助功能授权状态，授权后自动重注册全局监听器（无需手动重启 app）
    func setupAccessibilityCheck() {
        if !AXIsProcessTrusted() {
            let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
            AXIsProcessTrustedWithOptions(options)

            accessibilityCheckTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] timer in
                guard let self else { timer.invalidate(); return }
                if AXIsProcessTrusted() {
                    timer.invalidate()
                    self.accessibilityCheckTimer = nil
                    if let m = self.globalMouseMonitor { NSEvent.removeMonitor(m) }
                    if let k = self.globalKeyboardMonitor { NSEvent.removeMonitor(k) }
                    self.setupGlobalMonitors()
                }
            }
        }
    }

    func checkForUpdateOnLaunch() {
        let lastCheck = UserDefaults.standard.double(forKey: "lastUpdateCheck")
        let now = Date().timeIntervalSince1970
        guard now - lastCheck > 86400 else { return }
        UserDefaults.standard.set(now, forKey: "lastUpdateCheck")
        UpdateChecker.check { result in
            DispatchQueue.main.async {
                guard case .newVersion(let version, let url) = result else { return }
                let current = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
                let alert = NSAlert()
                alert.messageText = "发现新版本 \(version)"
                alert.informativeText = "当前版本 \(current)，点击下载更新。"
                alert.alertStyle = .informational
                alert.addButton(withTitle: "下载更新")
                alert.addButton(withTitle: "稍后")
                if alert.runModal() == .alertFirstButtonReturn {
                    NSWorkspace.shared.open(url)
                }
            }
        }
    }

    func requestAutomationPermissionOnFirstLaunch() {
        guard !UserDefaults.standard.bool(forKey: "hasRequestedAutomation") else { return }
        UserDefaults.standard.set(true, forKey: "hasRequestedAutomation")
        DispatchQueue.global(qos: .utility).async {
            let script = NSAppleScript(source: "tell application \"Terminal\" to name of front window")
            var err: NSDictionary?
            script?.executeAndReturnError(&err)
        }
    }

    func updateCursorHover(event: NSEvent) {
        guard !isCurrentlyDragging else { return }
        if isMouseOverPet { NSCursor.openHand.set() }
        else { NSCursor.arrow.set() }
    }
    
    func handleTypingActivity() {
        guard !isCurrentlyDragging, !isChasing, !isClaudeStateActive else { return }
        resetIdleTimer(); resetTypingTimer(); isThinkingOnClaudeProxy = false
        if !isTyping {
            if firstKeystrokeTime == nil { firstKeystrokeTime = Date() }
            else if let firstTime = firstKeystrokeTime, Date().timeIntervalSince(firstTime) >= 0.5 { startTypingAnimation() }
        }
    }

    // MARK: - Window Drag 窗口拖拽
    override func mouseDown(with event: NSEvent) { super.mouseDown(with: event); mouseDownLocation = event.locationInWindow }
    
    override func mouseDragged(with event: NSEvent) {
        guard let window = view.window else { return }
        window.setFrameOrigin(clampedOrigin(for: window, x: NSEvent.mouseLocation.x - mouseDownLocation.x, y: NSEvent.mouseLocation.y - mouseDownLocation.y))
        startDraggingAnimationSequence()
    }
    
    override func mouseUp(with event: NSEvent) { super.mouseUp(with: event); stopDraggingAnimationSequence() }
}


// MARK: - CommandScrollView 命令滚动视图
struct CommandScrollView: NSViewRepresentable {
    let text: String

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.scrollerStyle = .overlay

        let textView = NSTextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.drawsBackground = false
        textView.textContainerInset = NSSize(width: 10, height: 10)
        textView.textContainer?.lineFragmentPadding = 0
        textView.textContainer?.widthTracksTextView = true
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]

        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular),
            .foregroundColor: NSColor.white.withAlphaComponent(0.75)
        ]
        textView.textStorage?.setAttributedString(NSAttributedString(string: text, attributes: attrs))
        textView.backgroundColor = .clear

        scrollView.documentView = textView
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular),
            .foregroundColor: NSColor.white.withAlphaComponent(0.75)
        ]
        textView.textStorage?.setAttributedString(NSAttributedString(string: text, attributes: attrs))
        nsView.documentView?.scroll(.zero)
    }
}

// MARK: - PermissionDialogView 权限弹窗视图
struct PermissionDialogView: View {
    let toolName: String
    let command: String
    let hasSuggestions: Bool
    let shortcutApprove: String
    let shortcutDeny: String
    let shortcutAlwaysAllow: String
    let onAllow: () -> Void
    let onAlwaysAllow: () -> Void
    let onDeny: () -> Void

    var body: some View {
        ZStack {
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow, cornerRadius: TuanziTokens.Radius.dialog)
            RoundedRectangle(cornerRadius: TuanziTokens.Radius.dialog)
                .fill(TuanziTokens.Colors.dialogBg.opacity(0.82))
                .overlay(
                    RoundedRectangle(cornerRadius: TuanziTokens.Radius.dialog)
                        .stroke(TuanziTokens.Colors.glassStroke, lineWidth: TuanziTokens.Layout.borderWidth)
                )

            VStack(alignment: .leading, spacing: 0) {
                // 标题行
                HStack(spacing: 10) {
                    Image(systemName: "lock.shield")
                        .font(TuanziTokens.Fonts.icon)
                        .foregroundColor(TuanziTokens.Colors.accentWarning)
                    Text("Claude 请求权限")
                        .font(TuanziTokens.Fonts.subheading)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.top, TuanziTokens.Spacing.xxl)
                .padding(.horizontal, TuanziTokens.Spacing.xxl)

                Divider()
                    .background(TuanziTokens.Colors.divider)
                    .padding(.top, TuanziTokens.Spacing.lg)

                // 工具标签
                HStack(spacing: 6) {
                    Text("工具")
                        .font(TuanziTokens.Fonts.footnoteMed)
                        .foregroundColor(TuanziTokens.Colors.textTertiary)
                        .padding(.horizontal, TuanziTokens.Spacing.md)
                        .padding(.vertical, 3)
                        .background(Color.white.opacity(0.07))
                        .clipShape(Capsule())
                    Text(toolName)
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundColor(TuanziTokens.Colors.accentCyan)
                }
                .padding(.top, 14)
                .padding(.horizontal, TuanziTokens.Spacing.xxl)

                // 命令内容：文字少保持现有高度，文字多自动翻倍
                CommandScrollView(text: command)
                    .frame(minHeight: 60, maxHeight: command.count > 150 ? 400 : 200)
                    .background(TuanziTokens.Colors.commandBg)
                    .clipShape(RoundedRectangle(cornerRadius: TuanziTokens.Radius.lg))
                    .padding(.top, TuanziTokens.Spacing.rowH)
                    .padding(.horizontal, TuanziTokens.Spacing.xxl)

                // 按钮区
                VStack(spacing: 8) {
                    if hasSuggestions {
                        Button(action: onAlwaysAllow) {
                            HStack {
                                Text("始终允许")
                                    .font(TuanziTokens.Fonts.controlMed)
                                    .foregroundColor(.white)
                                Spacer()
                                Text(shortcutAlwaysAllow)
                                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                    .foregroundColor(TuanziTokens.Colors.textLabel)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, TuanziTokens.Spacing.xs)
                                    .background(Color.white.opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: TuanziTokens.Radius.xs))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, TuanziTokens.Spacing.lg)
                            .padding(.vertical, 9)
                            .background(TuanziTokens.Colors.accentGreen)
                            .clipShape(RoundedRectangle(cornerRadius: TuanziTokens.Radius.lg))
                        }
                        .buttonStyle(.plain)
                        .keyboardShortcut("a", modifiers: .control)
                    }

                    Button(action: onAllow) {
                        HStack {
                            Text("允许一次")
                                .font(TuanziTokens.Fonts.controlMed)
                                .foregroundColor(.white)
                            Spacer()
                            Text(shortcutApprove)
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .foregroundColor(TuanziTokens.Colors.textLabel)
                                .padding(.horizontal, 5)
                                .padding(.vertical, TuanziTokens.Spacing.xs)
                                .background(Color.white.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: TuanziTokens.Radius.xs))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, TuanziTokens.Spacing.lg)
                        .padding(.vertical, 9)
                        .background(TuanziTokens.Colors.accentBlue)
                        .clipShape(RoundedRectangle(cornerRadius: TuanziTokens.Radius.lg))
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut("y", modifiers: .control)

                    Button(action: onDeny) {
                        HStack {
                            Text("拒绝")
                                .font(TuanziTokens.Fonts.controlMed)
                                .foregroundColor(Color.white.opacity(0.7))
                            Spacer()
                            Text(shortcutDeny)
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .foregroundColor(TuanziTokens.Colors.textIcon)
                                .padding(.horizontal, 5)
                                .padding(.vertical, TuanziTokens.Spacing.xs)
                                .background(TuanziTokens.Colors.buttonCountBg)
                                .clipShape(RoundedRectangle(cornerRadius: TuanziTokens.Radius.xs))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, TuanziTokens.Spacing.lg)
                        .padding(.vertical, 9)
                        .background(TuanziTokens.Colors.border)
                        .clipShape(RoundedRectangle(cornerRadius: TuanziTokens.Radius.lg))
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut("n", modifiers: .control)
                }
                .padding(.top, 14)
                .padding(.horizontal, TuanziTokens.Spacing.xxl)
                .padding(.bottom, TuanziTokens.Spacing.xxl)
            }
        }
        .frame(width: TuanziTokens.Layout.dialogWidth)
    }
}

// MARK: - ElicitationDialogView 选项弹窗
struct ElicitationDialogView: View {
    let prompt: String
    let options: [String]
    let onSelect: (String) -> Void
    let onCancel: () -> Void

    @State private var selected: String? = nil

    var body: some View {
        ZStack {
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow, cornerRadius: TuanziTokens.Radius.dialog)
            RoundedRectangle(cornerRadius: TuanziTokens.Radius.dialog)
                .fill(TuanziTokens.Colors.dialogBg.opacity(0.82))
                .overlay(
                    RoundedRectangle(cornerRadius: TuanziTokens.Radius.dialog)
                        .stroke(TuanziTokens.Colors.glassStroke, lineWidth: TuanziTokens.Layout.borderWidth)
                )

            VStack(alignment: .leading, spacing: 0) {
                // 标题行
                HStack(spacing: 10) {
                    Image(systemName: "questionmark.circle")
                        .font(TuanziTokens.Fonts.icon)
                        .foregroundColor(TuanziTokens.Colors.accentCyan)
                    Text("Claude 需要你选择")
                        .font(TuanziTokens.Fonts.subheading)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.top, 18)
                .padding(.horizontal, TuanziTokens.Spacing.xxl)

                // 问题
                Text(prompt)
                    .font(TuanziTokens.Fonts.body)
                    .foregroundColor(TuanziTokens.Colors.textSecondary)
                    .padding(.top, 6)
                    .padding(.horizontal, TuanziTokens.Spacing.xxl)

                Divider()
                    .background(TuanziTokens.Colors.divider)
                    .padding(.top, TuanziTokens.Spacing.rowH)

                // 选项列表
                VStack(spacing: 6) {
                    ForEach(options, id: \.self) { option in
                        Button(action: { onSelect(option) }) {
                            HStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .stroke(selected == option
                                            ? TuanziTokens.Colors.accentBlue
                                            : Color.white.opacity(0.25),
                                            lineWidth: TuanziTokens.Layout.radioBorderWidth)
                                        .frame(width: TuanziTokens.Layout.radioSize, height: TuanziTokens.Layout.radioSize)
                                    if selected == option {
                                        Circle()
                                            .fill(TuanziTokens.Colors.accentBlue)
                                            .frame(width: TuanziTokens.Layout.checkSize, height: TuanziTokens.Layout.checkSize)
                                    }
                                }
                                Text(option)
                                    .font(TuanziTokens.Fonts.control)
                                    .foregroundColor(.white)
                                    .lineLimit(2)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, TuanziTokens.Spacing.lg)
                            .padding(.vertical, TuanziTokens.Spacing.rowH)
                            .background(selected == option
                                ? TuanziTokens.Colors.accentBlue.opacity(0.15)
                                : TuanziTokens.Colors.buttonDimBg)
                            .clipShape(RoundedRectangle(cornerRadius: TuanziTokens.Radius.lg))
                            .overlay(
                                RoundedRectangle(cornerRadius: TuanziTokens.Radius.lg)
                                    .stroke(selected == option
                                        ? TuanziTokens.Colors.accentBlue.opacity(0.5)
                                        : Color.clear, lineWidth: TuanziTokens.Layout.borderWidth)
                            )
                        }
                        .buttonStyle(.plain)
                        .simultaneousGesture(TapGesture().onEnded { selected = option })
                    }
                }
                .padding(.top, TuanziTokens.Spacing.rowH)
                .padding(.horizontal, TuanziTokens.Spacing.xxl)

                // 取消
                Button(action: onCancel) {
                    Text("取消")
                        .font(TuanziTokens.Fonts.controlMed)
                        .foregroundColor(TuanziTokens.Colors.textIcon)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(TuanziTokens.Colors.buttonDimBg)
                        .clipShape(RoundedRectangle(cornerRadius: TuanziTokens.Radius.lg))
                }
                .buttonStyle(.plain)
                .padding(.top, TuanziTokens.Spacing.rowH)
                .padding(.horizontal, TuanziTokens.Spacing.xxl)
                .padding(.bottom, TuanziTokens.Spacing.xl)
            }
        }
        .frame(width: TuanziTokens.Layout.dialogWidth)
    }
}

// MARK: - AskUserQuestionView 选项弹窗视图
struct AskUserQuestionView: View {
    let prompt: String
    let options: [String]
    let onSelect: (Int) -> Void

    var body: some View {
        ZStack {
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow, cornerRadius: TuanziTokens.Radius.dialog)
            RoundedRectangle(cornerRadius: TuanziTokens.Radius.dialog)
                .fill(TuanziTokens.Colors.dialogBg.opacity(0.82))
                .overlay(
                    RoundedRectangle(cornerRadius: TuanziTokens.Radius.dialog)
                        .stroke(TuanziTokens.Colors.glassStroke, lineWidth: TuanziTokens.Layout.borderWidth)
                )

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 10) {
                    Image(systemName: "list.bullet.circle")
                        .font(TuanziTokens.Fonts.icon)
                        .foregroundColor(TuanziTokens.Colors.accentCyan)
                    Text("Claude 想问你")
                        .font(TuanziTokens.Fonts.subheading)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.top, 18)
                .padding(.horizontal, TuanziTokens.Spacing.xxl)

                Text(prompt)
                    .font(TuanziTokens.Fonts.body)
                    .foregroundColor(TuanziTokens.Colors.textSecondary)
                    .padding(.top, 6)
                    .padding(.horizontal, TuanziTokens.Spacing.xxl)

                Divider().background(TuanziTokens.Colors.divider).padding(.top, TuanziTokens.Spacing.rowH)

                VStack(spacing: 6) {
                    ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                        Button(action: { onSelect(index) }) {
                            HStack(spacing: 10) {
                                Text("\(index + 1)")
                                    .font(TuanziTokens.Fonts.footnoteBold)
                                    .foregroundColor(TuanziTokens.Colors.textIcon)
                                    .frame(width: TuanziTokens.Layout.optionNumSize, height: TuanziTokens.Layout.optionNumSize)
                                    .background(TuanziTokens.Colors.buttonCountBg)
                                    .clipShape(RoundedRectangle(cornerRadius: TuanziTokens.Radius.xs))
                                Text(option)
                                    .font(TuanziTokens.Fonts.control)
                                    .foregroundColor(.white)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, TuanziTokens.Spacing.lg)
                            .padding(.vertical, TuanziTokens.Spacing.rowH)
                            .background(TuanziTokens.Colors.buttonDimBg)
                            .clipShape(RoundedRectangle(cornerRadius: TuanziTokens.Radius.lg))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, TuanziTokens.Spacing.rowH)
                .padding(.horizontal, TuanziTokens.Spacing.xxl)
                .padding(.bottom, TuanziTokens.Spacing.xl)
            }
        }
        .frame(width: TuanziTokens.Layout.questionWidth)
    }
}

// MARK: - TerminalSession 数据模型
struct TerminalSession: Identifiable {
    let id: String
    let cwd: String
    let firstUserMessage: String
    let lastAssistantMessage: String
    let status: String
    let toolTarget: String
    let tty: String
    let lastActivityAt: Double
    let termSessionId: String
    let terminalApp: String
    let startedAt: Double
    let agentId: String

    var projectName: String { URL(fileURLWithPath: cwd).lastPathComponent }
    var shortMessage: String {
        let s = firstUserMessage
        return s.count > 60 ? String(s.prefix(60)) + "…" : s
    }
    var isProcessing: Bool { status == "working" }
    var isDone: Bool { status == "idle" }

    var agentDisplayName: String {
        AgentRegistry.allAgents.first { $0.id == agentId }?.displayName ?? "Claude"
    }

    var agentBadgeColor: Color {
        guard let agent = AgentRegistry.allAgents.first(where: { $0.id == agentId }) else {
            return Color(red: 1.0, green: 0.6, blue: 0.15)
        }
        return Color(red: agent.badgeColor.r, green: agent.badgeColor.g, blue: agent.badgeColor.b)
    }

    var editorDisplayName: String {
        guard !terminalApp.isEmpty else { return "" }
        // 先按 bundleId 精确匹配
        if let def = TerminalRegistry.terminal(forBundleId: terminalApp) {
            return def.displayName
        }
        // 按 id 或 displayName 模糊匹配（terminalApp 可能是 "Apple_Terminal" 等格式）
        let lower = terminalApp.lowercased().replacingOccurrences(of: "_", with: "")
        if let def = TerminalRegistry.allTerminals.first(where: {
            lower.contains($0.id.lowercased()) || lower.contains($0.displayName.lowercased().replacingOccurrences(of: " ", with: ""))
        }) {
            return def.displayName
        }
        // 兜底：把下划线替换为空格
        return terminalApp.replacingOccurrences(of: "_", with: " ")
    }

    var elapsedTime: String {
        guard startedAt > 0 else { return "" }
        let elapsed = Int(Date().timeIntervalSince1970 - startedAt)
        if elapsed < 60 { return "\(elapsed)s" }
        if elapsed < 3600 { return "\(elapsed / 60)m\(elapsed % 60)s" }
        return "\(elapsed / 3600)h\(elapsed / 60 % 60)m"
    }
}

// MARK: - TerminalSessionPanelView 终端会话面板视图
struct TerminalSessionPanelView: View {
    let sessions: [TerminalSession]
    let waterCountdown: String
    let onSelect: (TerminalSession) -> Void
    let onSettings: () -> Void
    let onMouseEnter: () -> Void
    let onMouseExit: () -> Void

    private let bg = TuanziTokens.Colors.panelBg
    private let dividerColor = TuanziTokens.Colors.divider

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "cpu")
                    .foregroundColor(TuanziTokens.Colors.textIcon)
                Text("AI 会话")
                    .font(TuanziTokens.Fonts.bodySemi)
                    .foregroundColor(TuanziTokens.Colors.textHeader)
                Spacer()
                if !waterCountdown.isEmpty {
                    HStack(spacing: 3) {
                        Text("💧")
                            .font(TuanziTokens.Fonts.caption)
                        Text(waterCountdown)
                            .font(TuanziTokens.Fonts.captionMono)
                            .foregroundColor(TuanziTokens.Colors.accentCyanSoft)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, TuanziTokens.Spacing.xs)
                    .background(TuanziTokens.Colors.accentCyanSoft.opacity(0.1))
                    .cornerRadius(TuanziTokens.Radius.md)
                }
                Text("\(sessions.count)")
                    .font(TuanziTokens.Fonts.footnote)
                    .foregroundColor(TuanziTokens.Colors.textIcon)
                    .padding(.horizontal, 6)
                    .padding(.vertical, TuanziTokens.Spacing.xs)
                    .background(TuanziTokens.Colors.buttonCountBg)
                    .cornerRadius(TuanziTokens.Radius.lg)
            }
            .padding(.horizontal, TuanziTokens.Spacing.lg)
            .padding(.vertical, TuanziTokens.Spacing.rowH)

            dividerColor.frame(height: 1)

            if sessions.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "terminal.fill")
                        .font(TuanziTokens.Fonts.largeIcon)
                        .foregroundColor(TuanziTokens.Colors.textDimmed)
                    Text("没有活跃的 AI 会话")
                        .font(TuanziTokens.Fonts.bodySemi)
                        .foregroundColor(TuanziTokens.Colors.textTertiary)
                    Text("打开终端运行 AI 助手，团子会自动识别")
                        .font(TuanziTokens.Fonts.footnote)
                        .foregroundColor(TuanziTokens.Colors.textDimmed)
                        .multilineTextAlignment(.center)
                    Button(action: onSettings) {
                        HStack(spacing: 4) {
                            Image(systemName: "gearshape")
                            Text("管理 Hook")
                        }
                        .font(TuanziTokens.Fonts.footnote)
                        .foregroundColor(TuanziTokens.Colors.accentCyanBright)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(TuanziTokens.Colors.accentCyanSoft.opacity(0.1))
                        .cornerRadius(TuanziTokens.Radius.md)
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(sessions) { session in
                            SessionRowView(session: session) {
                                onSelect(session)
                            }
                            if session.id != sessions.last?.id {
                                dividerColor.frame(height: 1).padding(.leading, TuanziTokens.Spacing.lg)
                            }
                        }
                    }
                }
                .frame(maxHeight: TuanziTokens.Layout.panelMaxHeight)
            }
            // 底部工具栏
            dividerColor.frame(height: 1)
            HStack {
                Spacer()
                Button(action: onSettings) {
                    Image(systemName: "gearshape")
                        .font(TuanziTokens.Fonts.control)
                        .foregroundColor(TuanziTokens.Colors.textIcon)
                        .padding(7)
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, TuanziTokens.Spacing.rowH)
            .padding(.vertical, 6)
        }
        .frame(width: TuanziTokens.Layout.panelWidth)
        .background(bg)
        .clipShape(RoundedRectangle(cornerRadius: TuanziTokens.Radius.xxl))
        .overlay(
            RoundedRectangle(cornerRadius: TuanziTokens.Radius.xxl)
                .stroke(TuanziTokens.Colors.glassStroke, lineWidth: TuanziTokens.Layout.strokeWidth)
        )
        .shadow(color: TuanziTokens.Shadow.panelColor, radius: TuanziTokens.Shadow.panelRadius, x: 0, y: TuanziTokens.Shadow.panelY)
        .shadow(color: TuanziTokens.Shadow.glowColor, radius: TuanziTokens.Shadow.glowRadius)
        .onHover { hovering in
            if hovering { onMouseEnter() } else { onMouseExit() }
        }
    }
}

struct SessionStatusIcon: View {
    let isProcessing: Bool
    let hasDoneTask: Bool  // 跑过任务且已完成
    @State private var rotation: Double = 0

    var body: some View {
        if isProcessing {
            // 缺一角的圆弧旋转 spinner
            Circle()
                .trim(from: 0.15, to: 1.0)
                .stroke(TuanziTokens.Colors.accentCyanBright, style: StrokeStyle(lineWidth: 1.8, lineCap: .round))
                .frame(width: TuanziTokens.Layout.spinnerSize, height: TuanziTokens.Layout.spinnerSize)
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    withAnimation(.linear(duration: TuanziTokens.Animation.spinnerDuration).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                }
        } else if hasDoneTask {
            // 对号（跑过任务，已完成）
            Image(systemName: "checkmark")
                .font(TuanziTokens.Fonts.micro)
                .foregroundColor(TuanziTokens.Colors.textIcon)
        } else {
            // 灰色圆点（普通空闲终端）
            Circle()
                .fill(TuanziTokens.Colors.textDimmed)
                .frame(width: TuanziTokens.Layout.idleDotSize, height: TuanziTokens.Layout.idleDotSize)
        }
    }
}

struct SessionRowView: View {
    let session: TerminalSession
    let onTap: () -> Void
    @State private var isHovered = false

    private var timeAgo: String {
        let diff = Date().timeIntervalSince1970 - session.lastActivityAt
        if diff < 60 { return "<1m" }
        if diff < 3600 { return "\(Int(diff / 60))m" }
        return "\(Int(diff / 3600))h"
    }

    private var renderedMarkdown: AttributedString {
        let raw = session.lastAssistantMessage
        if let md = try? AttributedString(markdown: raw, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
            return md
        }
        return AttributedString(raw)
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .center, spacing: 6) {
                    SessionStatusIcon(isProcessing: session.isProcessing, hasDoneTask: !session.firstUserMessage.isEmpty)
                        .frame(width: TuanziTokens.Layout.sessionIconSize, height: TuanziTokens.Layout.sessionIconSize)

                    HStack(spacing: 0) {
                        Text(session.projectName)
                            .font(TuanziTokens.Fonts.bodySemi)
                            .foregroundColor(TuanziTokens.Colors.textPrimary)
                            .lineLimit(1)
                        if !session.firstUserMessage.isEmpty {
                            Text(" · \(session.firstUserMessage)")
                                .font(TuanziTokens.Fonts.body)
                                .foregroundColor(TuanziTokens.Colors.textSecondary)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 4) {
                        if session.isProcessing, !session.elapsedTime.isEmpty {
                            Text(session.elapsedTime)
                                .font(TuanziTokens.Fonts.captionMono)
                                .foregroundColor(TuanziTokens.Colors.accentCyanBright.opacity(0.7))
                        } else {
                            Text(timeAgo)
                                .font(TuanziTokens.Fonts.caption)
                                .foregroundColor(TuanziTokens.Colors.textMuted)
                        }
                        if !session.editorDisplayName.isEmpty {
                            Text(session.editorDisplayName)
                                .font(TuanziTokens.Fonts.caption)
                                .foregroundColor(TuanziTokens.Colors.textMuted)
                                .padding(.horizontal, 4).padding(.vertical, TuanziTokens.Spacing.xs)
                                .background(Color.white.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: TuanziTokens.Radius.xs))
                        }
                        Text(session.agentDisplayName)
                            .font(TuanziTokens.Fonts.captionMed)
                            .foregroundColor(session.agentBadgeColor)
                            .padding(.horizontal, 5).padding(.vertical, TuanziTokens.Spacing.xs)
                            .background(session.agentBadgeColor.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: TuanziTokens.Radius.xs))
                    }
                }

                if !session.shortMessage.isEmpty {
                    Text("你: \(session.shortMessage)")
                        .font(TuanziTokens.Fonts.footnote)
                        .foregroundColor(TuanziTokens.Colors.textTertiary)
                        .lineLimit(1)
                        .padding(.leading, TuanziTokens.Spacing.xxl)
                }

                if !session.lastAssistantMessage.isEmpty {
                    Text(renderedMarkdown)
                        .font(TuanziTokens.Fonts.footnote)
                        .foregroundColor(TuanziTokens.Colors.textSubtle)
                        .lineLimit(2)
                        .padding(.leading, TuanziTokens.Spacing.xxl)
                }

                if !session.toolTarget.isEmpty && session.isProcessing {
                    HStack(spacing: 4) {
                        Image(systemName: "gearshape.2")
                            .font(TuanziTokens.Fonts.tiny)
                            .foregroundColor(TuanziTokens.Colors.textDimmed)
                        Text(session.toolTarget)
                            .font(TuanziTokens.Fonts.captionMono)
                            .foregroundColor(Color.white.opacity(0.3))
                            .lineLimit(1)
                    }
                    .padding(.leading, TuanziTokens.Spacing.xxl)
                }
            }
            .padding(.horizontal, TuanziTokens.Spacing.lg)
            .padding(.vertical, 9)
            .background(isHovered ? TuanziTokens.Colors.buttonHover : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: TuanziTokens.Radius.md))
            .contentShape(Rectangle())
            .animation(.easeInOut(duration: 0.15), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { h in isHovered = h }
    }
}

// MARK: - VisualEffectView 毛玻璃背景
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    var cornerRadius: CGFloat = 0

    func makeNSView(context: Context) -> NSVisualEffectView {
        let v = NSVisualEffectView()
        v.material = material
        v.blendingMode = blendingMode
        v.state = .active
        v.wantsLayer = true
        v.layer?.cornerRadius = cornerRadius
        v.layer?.masksToBounds = true
        return v
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.layer?.cornerRadius = cornerRadius
    }
}

// MARK: - FirstMouseHostingView 接受首次点击
/// NSHostingView 默认不接受 nonactivatingPanel 里的 firstMouse，导致第一次点击无效。
/// 重写 acceptsFirstMouse 让按钮在面板非激活状态下也能响应。
class FirstMouseHostingView<Content: View>: NSHostingView<Content> {
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
    deinit {}  // 阻止 Release 优化器在 deinit 路径上 crash（Swift compiler bug）
}

// MARK: - ClaudeWebhookServer Webhook 服务器
class ClaudeWebhookServer {
    var listener: NWListener?

    // 旧版兼容
    var onClaudeStart: (() -> Void)?
    var onClaudeStop: (() -> Void)?

    // 新增状态回调
    var onThinking: (() -> Void)?      // UserPromptSubmit
    var onWorking: (() -> Void)?       // PreToolUse / PostToolUse / SubagentStop
    var onError: (() -> Void)?         // PostToolUseFailure / StopFailure
    var onAttention: (() -> Void)?     // Stop / PostCompact
    var onNotification: (() -> Void)?  // Notification / Elicitation
    var onIdle: (() -> Void)?          // SessionStart
    var onSleeping: (() -> Void)?      // SessionEnd

    // 权限请求回调（HTTP hook，Claude 等待响应）
    var onPermissionRequest: ((_ payload: [String: Any], _ completion: @escaping ([String: Any]) -> Void) -> Void)?
    // 权限请求连接断开回调（用户在编辑器中直接批准后 curl 被杀）
    var onPermissionConnectionClosed: (() -> Void)?

    // Elicitation 回调（HTTP hook，Claude 等待用户选择）
    var onElicitationRequest: ((_ payload: [String: Any], _ completion: @escaping ([String: Any]) -> Void) -> Void)?

    // Session 更新回调（SessionStart/Stop/PreToolUse 等）
    var onSessionUpdate: ((_ sessionData: [String: Any]) -> Void)?

    func start(port: UInt16) {
        do {
            let parameters = NWParameters.tcp
            listener = try NWListener(using: parameters, on: NWEndpoint.Port(rawValue: port)!)
            listener?.newConnectionHandler = { [weak self] connection in
                self?.handleConnection(connection)
            }
            listener?.start(queue: .global(qos: .background))
            print("📡 Webhook 监听已启动: 端口 \(port)")
        } catch {
            print("❌ Webhook 监听启动失败: \(error.localizedDescription)")
        }
    }

    func stop() {
        listener?.cancel()
        listener = nil
    }

    private func handleConnection(_ connection: NWConnection) {
        connection.start(queue: .global(qos: .background))
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, _, _ in
            guard let self, let data, let request = String(data: data, encoding: .utf8) else {
                connection.cancel(); return
            }

            let sendOK = {
                let r = "HTTP/1.1 200 OK\r\nContent-Length: 2\r\n\r\nOK"
                connection.send(content: r.data(using: .utf8)!, completion: .contentProcessed { _ in connection.cancel() })
            }

            // 解析公共 JSON body
            let json: [String: Any]? = {
                guard let range = request.range(of: "\r\n\r\n"),
                      let d = String(request[range.upperBound...]).data(using: .utf8)
                else { return nil }
                return try? JSONSerialization.jsonObject(with: d) as? [String: Any]
            }()

            // /session 路由：session 状态上报（SessionStart/Stop/PreToolUse）
            if request.contains("POST /session") {
                if let payload = json {
                    DispatchQueue.main.async { self.onSessionUpdate?(payload) }
                }
                sendOK(); return
            }

            // /elicitation 路由：Claude 提问，等用户选择后响应
            if request.contains("POST /elicitation") {
                guard let payload = json else { sendOK(); return }
                DispatchQueue.main.async {
                    self.onElicitationRequest?(payload) { responseDict in
                        let body = (try? JSONSerialization.data(withJSONObject: responseDict))
                            .flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
                        let r = "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: \(body.utf8.count)\r\n\r\n\(body)"
                        connection.send(content: r.data(using: .utf8)!, completion: .contentProcessed { _ in connection.cancel() })
                    }
                }
                return
            }

            // /permission 路由：持有连接，等用户点击后再响应
            if request.contains("POST /permission") {
                guard let payload = json else { sendOK(); return }
                // 监听连接断开（用户在编辑器中直接批准时 curl 被杀，连接断开）
                var dismissed = false
                let dismissLock = NSLock()
                let notifyClose: () -> Void = {
                    dismissLock.lock()
                    let alreadyDismissed = dismissed
                    dismissed = true
                    dismissLock.unlock()
                    guard !alreadyDismissed else { return }
                    DispatchQueue.main.async {
                        self.onPermissionConnectionClosed?()
                    }
                }
                // 方式1: state 变化
                connection.stateUpdateHandler = { state in
                    if case .cancelled = state { notifyClose() }
                    if case .failed = state { notifyClose() }
                }
                // 方式2: 持续读取，TCP 对端关闭时 isComplete=true 或 error
                func watchDisconnect() {
                    connection.receive(minimumIncompleteLength: 1, maximumLength: 1) { _, _, isComplete, error in
                        if isComplete || error != nil {
                            notifyClose()
                        } else {
                            watchDisconnect()
                        }
                    }
                }
                watchDisconnect()
                DispatchQueue.main.async {
                    self.onPermissionRequest?(payload) { responseDict in
                        dismissLock.lock()
                        dismissed = true
                        dismissLock.unlock()
                        let body = (try? JSONSerialization.data(withJSONObject: responseDict))
                            .flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
                        let r = "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: \(body.utf8.count)\r\n\r\n\(body)"
                        connection.send(content: r.data(using: .utf8)!, completion: .contentProcessed { _ in connection.cancel() })
                    }
                }
                return
            }

            // 旧版路由兼容
            if request.contains("POST /claude/start") {
                DispatchQueue.main.async { self.onClaudeStart?() }
                sendOK(); return
            }
            if request.contains("POST /claude/stop") {
                DispatchQueue.main.async { self.onClaudeStop?() }
                sendOK(); return
            }

            // /state 路由
            guard request.contains("POST /state") || request.contains("POST /update"),
                  let state = json?["state"] as? String else { sendOK(); return }

            let sessionId = json?["session_id"] as? String
            DispatchQueue.main.async {
                switch state {
                case "thinking":     self.onThinking?()
                case "working":      self.onWorking?()
                case "error":        self.onError?()
                case "attention":
                    self.onAttention?()
                    // Stop 事件：直接将 session 状态更新为 idle
                    if let sid = sessionId, !sid.isEmpty, sid != "default" {
                        self.onSessionUpdate?([
                            "sessionId": sid,
                            "status": "idle",
                            "lastActivityAt": Date().timeIntervalSince1970
                        ])
                    }
                case "notification": self.onNotification?()
                case "idle":         self.onIdle?()
                case "sleeping":
                    self.onSleeping?()
                    // SessionEnd 事件：将 session 状态更新为 ended
                    if let sid = sessionId, !sid.isEmpty, sid != "default" {
                        self.onSessionUpdate?([
                            "sessionId": sid,
                            "status": "ended",
                            "lastActivityAt": Date().timeIntervalSince1970
                        ])
                    }
                default: break
                }
            }
            sendOK()
        }
    }
}


// MARK: - PetScene 场景交互层
class PetScene: SKScene, NSMenuDelegate {
    weak var viewController: ViewController?
    var initialWindowOrigin: NSPoint?
    var lastMouseX: CGFloat = 0
    var swipeDirection: Int = 0
    var swipeCount: Int = 0
    var lastSwipeTime: TimeInterval = 0
    var pettingStartTime: TimeInterval = 0

    override func update(_ currentTime: TimeInterval) {
        guard let vc = viewController, !vc.isCurrentlyDragging, !vc.isMenuOpen else { return }
        guard let window = self.view?.window else { return }

        // 安全网：吸附状态下动画丢失时自动恢复
        vc.restoreSnapIdleIfNeeded()

        let mouseLoc = NSEvent.mouseLocation
        let windowFrame = window.frame

        if !vc.isChasing {
            if windowFrame.contains(mouseLoc) {
                let dx = mouseLoc.x - lastMouseX
                let triggerThreshold: CGFloat = 2.0

                if abs(dx) > triggerThreshold {
                    let newDir = dx > 0 ? 1 : -1
                    if swipeDirection != newDir {
                        swipeDirection = newDir; swipeCount += 1; lastSwipeTime = currentTime
                        if swipeCount == 1 { pettingStartTime = currentTime }
                        if swipeCount >= 3 && currentTime - pettingStartTime >= 1.0 {
                            swipeCount = 0; pettingStartTime = 0; vc.startPetting()
                        }
                    }
                }
                lastMouseX = mouseLoc.x
                if currentTime - lastSwipeTime > 0.5 { swipeCount = 0; pettingStartTime = 0 }
            } else { swipeCount = 0; lastMouseX = mouseLoc.x }
        }
        
        if vc.isChasing && !vc.isPlayingRunExit {
            let petCenterX = windowFrame.origin.x + windowFrame.width / 2
            let petCenterY = windowFrame.origin.y + windowFrame.height / 2
            let dx = mouseLoc.x - petCenterX
            let dy = mouseLoc.y - petCenterY
            let distance = sqrt(dx*dx + dy*dy)
            
            let baseScale = abs(vc.spriteNode.xScale)
            vc.spriteNode.xScale = dx < 0 ? -baseScale : baseScale
            
            if distance < 35.0 { if !vc.isRestingAtMouse { vc.playRunExitAnimation() } }
            else {
                let speed: CGFloat = 10.0
                let moveX = (dx / distance) * speed; let moveY = (dy / distance) * speed
                window.setFrameOrigin(NSPoint(x: windowFrame.origin.x + moveX, y: windowFrame.origin.y + moveY))
                if vc.isRestingAtMouse { vc.startChasing() }
            }
        }
    }

    override func mouseDown(with event: NSEvent) {
        if let vc = viewController { vc.mouseDownLocation = event.locationInWindow }
        viewController?.resetIdleTimer()
        if let window = self.view?.window { initialWindowOrigin = window.frame.origin }

        let node = self.atPoint(event.location(in: self))
        if node.name == "petSprite" || node.parent?.name == "petSprite" { NSCursor.closedHand.set() }
    }

    override func mouseDragged(with event: NSEvent) {
        guard let vc = viewController, let window = vc.view.window else { return }
        window.setFrameOrigin(vc.clampedOrigin(for: window, x: NSEvent.mouseLocation.x - vc.mouseDownLocation.x, y: NSEvent.mouseLocation.y - vc.mouseDownLocation.y))
        vc.resetIdleTimer(); vc.startDraggingAnimationSequence()
        NSCursor.closedHand.set()
    }
    
    override func mouseUp(with event: NSEvent) {
        swipeCount = 0; pettingStartTime = 0; swipeDirection = 0
        viewController?.stopDraggingAnimationSequence()
        guard let window = self.view?.window, let initialOrigin = initialWindowOrigin else { return }
        let movementDist = sqrt(pow(window.frame.origin.x - initialOrigin.x, 2) + pow(window.frame.origin.y - initialOrigin.y, 2))
        
        let node = self.atPoint(event.location(in: self))
        let isTouchingPet = node.name == "petSprite" || node.parent?.name == "petSprite"
        if isTouchingPet { NSCursor.openHand.set() } else { NSCursor.arrow.set() }
        
        if movementDist < 2.0 {
            if isTouchingPet {
                if event.clickCount == 1 {
                    if viewController?.isSnappedToSide == true { viewController?.playSnapExit() }
                    else if viewController?.isChasing == true { viewController?.stopChasing() } else { viewController?.playClickAnimationOnce() }
                } else if event.clickCount == 2 {
                    let customID = feishuBundleID
                    let feishuURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: customID) ?? URL(fileURLWithPath: "/Applications/小米办公Pro.app")
                    NSWorkspace.shared.openApplication(at: feishuURL, configuration: NSWorkspace.OpenConfiguration(), completionHandler: nil)
                }
            }
        }
        initialWindowOrigin = nil
    }
    
    override func rightMouseDown(with event: NSEvent) {
        let hitNode = atPoint(event.location(in: self))
        let snapped = viewController?.isSnappedToSide ?? false
        if hitNode.name == "petSprite" || hitNode.parent?.name == "petSprite" || snapped {
            let menu = NSMenu(title: "PetMenu")
            menu.delegate = self

            let waterItem = NSMenuItem(title: "💧 提醒喝水...", action: nil, keyEquivalent: "")
            let waterSubMenu = NSMenu()
            waterSubMenu.addItem(withTitle: "每小时提醒", action: #selector(setWater60m), keyEquivalent: "").target = self
            waterSubMenu.addItem(NSMenuItem.separator())
            waterSubMenu.addItem(withTitle: "⏰ 自定义间隔...", action: #selector(setCustomWaterTime), keyEquivalent: "").target = self
            waterSubMenu.addItem(NSMenuItem.separator())
            waterSubMenu.addItem(withTitle: "🚫 取消提醒", action: #selector(cancelWater), keyEquivalent: "").target = self
            waterItem.submenu = waterSubMenu

            let feishuItem = NSMenuItem(title: "💬 打开小米办公Pro", action: #selector(openFeishu), keyEquivalent: ""); feishuItem.target = self
            let terminalItem = NSMenuItem(title: "💻 打开终端", action: #selector(openTerminal), keyEquivalent: ""); terminalItem.target = self
            // let chaseTitle = (viewController?.isChasing == true) ? "🛑 停止追逐鼠标" : "🐁 开始追逐鼠标"
            // let chaseItem = NSMenuItem(title: chaseTitle, action: #selector(toggleChase), keyEquivalent: "")
            // chaseItem.target = self
            let settingsItem = NSMenuItem(title: "设置...", action: #selector(openSettings), keyEquivalent: ""); settingsItem.target = self
            let exitItem = NSMenuItem(title: "❌ 退出", action: #selector(exitApp), keyEquivalent: ""); exitItem.target = self

            menu.addItem(waterItem); menu.addItem(NSMenuItem.separator())
            menu.addItem(feishuItem); menu.addItem(terminalItem); menu.addItem(NSMenuItem.separator())
            menu.addItem(settingsItem); menu.addItem(NSMenuItem.separator())
            menu.addItem(exitItem)
            
            if let view = self.view { viewController?.isMenuOpen = true; NSMenu.popUpContextMenu(menu, with: event, for: view) }
        }
    }
    
    @objc func setWater60m() { viewController?.scheduleWaterReminder(minutes: 60) }
    @objc func cancelWater() { viewController?.cancelWaterReminder() }
    @objc func setCustomWaterTime() {
        guard let vc = viewController, let window = vc.view.window else { return }
        let alert = NSAlert(); alert.messageText = "设置喝水提醒间隔"; alert.informativeText = "每隔多久提醒一次，支持格式：\n• 秒：30s\n• 分钟：45 或 45m\n• 小时：1h"
        alert.addButton(withTitle: "确定"); alert.addButton(withTitle: "取消")
        let inputField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24)); inputField.placeholderString = "例如：30s / 45m / 1h"
        alert.accessoryView = inputField
        alert.beginSheetModal(for: window) { response in
            if response == .alertFirstButtonReturn {
                let raw = inputField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                let minutes: Double?
                if raw.hasSuffix("s"), let val = Double(raw.dropLast()) {
                    minutes = val / 60.0
                } else if raw.hasSuffix("h"), let val = Double(raw.dropLast()) {
                    minutes = val * 60.0
                } else if raw.hasSuffix("m"), let val = Double(raw.dropLast()) {
                    minutes = val
                } else {
                    minutes = Double(raw)
                }
                if let m = minutes, m > 0 { vc.scheduleWaterReminder(minutes: m) } else {
                    let errorAlert = NSAlert(); errorAlert.messageText = "输入无效"; errorAlert.informativeText = "请输入有效时间，如：30s / 45m / 1h"
                    errorAlert.addButton(withTitle: "确定"); errorAlert.beginSheetModal(for: window, completionHandler: nil)
                }
            }
        }
    }
    func menuDidClose(_ menu: NSMenu) { viewController?.isMenuOpen = false }
    @objc func openFeishu() {
        let customID = feishuBundleID
        let feishuURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: customID) ?? URL(fileURLWithPath: "/Applications/小米办公Pro.app")
        NSWorkspace.shared.openApplication(at: feishuURL, configuration: NSWorkspace.OpenConfiguration(), completionHandler: nil)
    }
    @objc func openTerminal() {
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Terminal") { NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration(), completionHandler: nil) }
    }
    @objc func openSettings() { SettingsWindowController.shared.open() }
    @objc func toggleChase() { viewController?.toggleChasingMode() }
    @objc func exitApp() { NSApplication.shared.terminate(nil) }
}


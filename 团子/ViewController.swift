import Cocoa
import SpriteKit
import SwiftUI
import Network

// 企业定制版飞书的 bundle ID（小米办公Pro）
private let feishuBundleID = "com.larksuite.feishu.ka.saxmsa667.mac"

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
    var terminalHoverCooldownUntil: Date?
    var terminalHoverShowDelay: TimeInterval { PetSettings.shared.hoverDelay }
    let terminalAutoHideDelay: TimeInterval = 0.5
    let terminalHoverCooldownDuration: TimeInterval = 0.5
    var isSnappedToSide = false
    var snappedSide: Int = 0  // -1 = left, 1 = right, 0 = none
    // Claude 事件处理期间为 true，阻止其他动画打断
    var isClaudeStateActive = false
    // 拖拽结束后用于恢复 Claude 状态
    var lastClaudeState: String = ""
    var isMenuOpen = false
    var permissionDialogWindow: NSWindow?
    var permissionKeyMonitors: [Any] = []
    var autoApproveEnabled = false
    var isSnapReminding = false
    var snapReminderTimer: Timer?
    var snapReminderCycleCount = 0
    // 用户正在主动交互（拖拽/追逐/摸摸），此时不响应自动动画切换
    var isInteracting: Bool { isCurrentlyDragging || isChasing || isPetting || isSnappedToSide }

    var webhookServer: ClaudeWebhookServer?

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
        NotificationCenter.default.addObserver(self, selector: #selector(applySettings), name: .petSettingsChanged, object: nil)
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
        webhookServer?.stop()
    }

    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        isMouseOverPet = true
        if waterTimer?.isValid == true { countdownContainer?.isHidden = false }
        stopSnapReminder()

        // 终端面板：仅侧边吸附时触发，权限弹窗显示期间不触发
        guard isSnappedToSide else { return }
        guard permissionDialogWindow == nil else { return }
        terminalAutoHideTimer?.invalidate(); terminalAutoHideTimer = nil
        if let cooldown = terminalHoverCooldownUntil, Date() < cooldown { return }
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
            self?.isClaudeStateActive = true
            self?.isThinkingOnClaudeProxy = true
            self?.lastClaudeState = "thinking"
            self?.startThinkingAnimationLoop()
        }

        // PreToolUse / PostToolUse / SubagentStop
        webhookServer?.onWorking = { [weak self] in
            self?.stopSnapReminder()
            self?.isClaudeStateActive = true
            self?.isThinkingOnClaudeProxy = true
            self?.lastClaudeState = "working"
            self?.startWorkingAnimationLoop()
        }

        // PostToolUseFailure / StopFailure
        // webhookServer?.onError = { [weak self] in
        //     self?.isClaudeStateActive = true
        //     self?.isThinkingOnClaudeProxy = false
        //     self?.playErrorAnimation()
        // }

        // Stop / PostCompact
        webhookServer?.onAttention = { [weak self] in
            self?.isClaudeStateActive = true
            self?.isThinkingOnClaudeProxy = false
            if self?.isSnappedToSide == true {
                self?.startSnapReminderLoop()
            } else {
                self?.playAttentionAnimation()
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
            self?.startIdleAnimation()
        }

        // SessionEnd
        webhookServer?.onSleeping = { [weak self] in
            self?.isClaudeStateActive = true
            self?.isThinkingOnClaudeProxy = false
            self?.enterSleep()
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
            self?.stopThinkingAnimation()
        }

        // PermissionRequest：持有 HTTP 连接直到用户点击确认/拒绝
        webhookServer?.onPermissionRequest = { [weak self] payload, completion in
            guard let self, let window = self.view.window else {
                completion(["hookSpecificOutput": ["hookEventName": "PermissionRequest", "decision": ["behavior": "deny"]]])
                return
            }

            let toolName = payload["tool_name"] as? String ?? "Unknown"
            let toolInput = payload["tool_input"] as? [String: Any] ?? [:]
            let command = toolInput["command"] as? String
                ?? toolInput["description"] as? String
                ?? toolInput.map { "\($0.key): \($0.value)" }.joined(separator: "\n")
            let suggestions = payload["permission_suggestions"] as? [[String: Any]] ?? []

            showPermissionDialog(toolName: toolName, command: command, suggestions: suggestions, in: window) { decision in
                completion(["hookSpecificOutput": ["hookEventName": "PermissionRequest", "decision": decision]])
            }
        }

        webhookServer?.start(port: 23333)
    }

    // MARK: - Setup 初始化与素材加载
    private func loadTextures(named prefix: String, _ range: Range<Int>) -> [SKTexture] {
        range.map { SKTexture(imageNamed: "\(prefix)_\($0)") }
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
        idleTextures          = loadTextures(named: "待机",       0..<240)
        randomIdle1Textures   = loadTextures(named: "伸懒腰",       0..<80)
        randomIdle2Textures   = loadTextures(named: "舔爪子",       0..<80)

        enterSearchTextures   = loadTextures(named: "搜索",       0..<20)
        searchLoopTextures    = loadTextures(named: "搜索",       20..<67)
        exitSearchTextures    = loadTextures(named: "搜索",       67..<80)

        enterThinkingTextures = loadTextures(named: "思考",       0..<17)
        thinkingLoopTextures  = loadTextures(named: "思考",       17..<67)
        exitThinkingTextures  = loadTextures(named: "思考",       67..<79)

        enterWorkingTextures  = loadTextures(named: "工作",       0..<59)
        workingLoopTextures   = loadTextures(named: "工作",       59..<78)
        exitWorkingTextures   = loadTextures(named: "工作",       82..<127)

        drinkWaterTextures    = loadTextures(named: "喝水",       0..<80)
        messageTextures       = loadTextures(named: "提醒",   0..<48)

        clickTextures         = loadTextures(named: "戳",  19..<48)
        enterSleepTextures    = loadTextures(named: "睡觉", 0..<52)
        sleepLoopTextures     = loadTextures(named: "睡觉", 52..<120)
        wakeUpTextures        = loadTextures(named: "睡觉", 120..<160)

        enterTypingTextures   = loadTextures(named: "敲键盘",     0..<38)
        typingLoopTextures    = loadTextures(named: "敲键盘",     38..<100)
        exitTypingTextures    = loadTextures(named: "敲键盘",     100..<128)

        dragEnterTextures     = loadTextures(named: "提起",       18..<59)
        dragLoopTextures      = loadTextures(named: "提起",       129..<177)
        dragExitTextures      = loadTextures(named: "提起",       178..<226)

        runEnterTextures      = loadTextures(named: "滚动",       0..<46)
        runLoopTextures       = loadTextures(named: "滚动",       46..<81)
        runExitTextures       = loadTextures(named: "滚动",       81..<106)
        runRestTextures       = loadTextures(named: "滚动",       106..<152)

        petTextures           = loadTextures(named: "摸摸",       0..<80)
        // snapEnterTextures     = loadTextures(named: "吸附变换",   0..<48)
        // snapIdleTextures      = loadTextures(named: "吸附待机",   0..<81)
        // snapDragEnterTextures = loadTextures(named: "侧边提起",   0..<49)
        // snapDragLoopTextures  = loadTextures(named: "侧边提起",   129..<178)
        // snapDragExitTextures  = loadTextures(named: "侧边提起",   178..<227)
        snapLeftEnterTextures  = loadTextures(named: "走到左侧",   0..<49)
        snapLeftIdleTextures   = loadTextures(named: "左侧待机",   0..<81)
        snapLeftExitTextures   = loadTextures(named: "左侧走出",   0..<49)
        snapRightEnterTextures = loadTextures(named: "走到右侧",   0..<49)
        snapRightIdleTextures  = loadTextures(named: "右侧待机",   0..<81)
        snapRightExitTextures  = loadTextures(named: "右侧走出",   0..<49)

        errorTextures         = loadTextures(named: "报错",       0..<80)
        attentionTextures     = loadTextures(named: "完成",       0..<80)
        notificationTextures  = messageTextures
        snapReminder1Textures = loadTextures(named: "右提醒",  0..<48)
        snapReminder2Textures = loadTextures(named: "左提醒",  0..<48)

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

    // MARK: - Animation 动画控制
    func startIdleAnimation() {
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
        if isSnappedToSide { isSnappedToSide = false; snappedSide = 0 }
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
        let exitAction = SKAction.animate(with: exitTextures, timePerFrame: 0.04)
        spriteNode.run(SKAction.sequence([exitAction, SKAction.run { [weak self] in
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
        let enterAction = SKAction.animate(with: enterTextures, timePerFrame: 0.04)
        let idleLoop = SKAction.repeatForever(SKAction.animate(with: snapIdleTextures, timePerFrame: 0.05))
        spriteNode.run(SKAction.sequence([enterAction, idleLoop]), withKey: "snapSequence")
    }

    func unsnap() {
        guard let window = view.window, let screen = window.screen ?? NSScreen.main else { return }
        let sf = screen.visibleFrame
        let wf = window.frame
        let targetX: CGFloat = snappedSide == -1 ? sf.minX : sf.maxX - wf.width
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
        guard !enterSearchTextures.isEmpty, !searchLoopTextures.isEmpty else { return }
        guard !isInteracting else { return }
        spriteNode.removeAllActions(); isTyping = false; isSleeping = false
        let sequence = SKAction.sequence([SKAction.animate(with: enterSearchTextures, timePerFrame: 0.05), SKAction.repeatForever(SKAction.animate(with: searchLoopTextures, timePerFrame: 0.05))])
        spriteNode.run(sequence, withKey: "thinkingSequence")
    }

    func stopThinkingAnimation() {
        isClaudeStateActive = false
        spriteNode.removeAllActions()
        guard !exitSearchTextures.isEmpty else { startIdleAnimation(); return }
        spriteNode.run(SKAction.sequence([SKAction.animate(with: exitSearchTextures, timePerFrame: 0.05), SKAction.run { [weak self] in self?.startIdleAnimation() }]), withKey: "exitSearchSequence")
    }

    func startPonderAnimationLoop() {
        guard !enterThinkingTextures.isEmpty, !thinkingLoopTextures.isEmpty else { return }
        guard !isInteracting else { return }
        spriteNode.removeAllActions(); isTyping = false; isSleeping = false
        let sequence = SKAction.sequence([SKAction.animate(with: enterThinkingTextures, timePerFrame: 0.05), SKAction.repeatForever(SKAction.animate(with: thinkingLoopTextures, timePerFrame: 0.05))])
        spriteNode.run(sequence, withKey: "ponderSequence")
    }

    func stopPonderAnimation() {
        spriteNode.removeAllActions()
        guard !exitThinkingTextures.isEmpty else { startIdleAnimation(); return }
        spriteNode.run(SKAction.sequence([SKAction.animate(with: exitThinkingTextures, timePerFrame: 0.05), SKAction.run { [weak self] in self?.startIdleAnimation() }]), withKey: "exitPonderSequence")
    }

    func startWorkingAnimationLoop() {
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
        spriteNode.removeAllActions()
        guard !exitWorkingTextures.isEmpty else { startIdleAnimation(); return }
        spriteNode.run(SKAction.sequence([SKAction.animate(with: exitWorkingTextures, timePerFrame: 0.05), SKAction.run { [weak self] in self?.startIdleAnimation() }]), withKey: "exitWorkingSequence")
    }

    func startSleepAnimation() {
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

    // MARK: - Permission Dialog 权限弹窗
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
        let dialogH: CGFloat = 430

        let hosting = NSHostingView(rootView: view)
        hosting.frame = NSRect(x: 0, y: 0, width: dialogW, height: dialogH)

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: dialogW, height: dialogH),            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.contentView = hosting
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.level = .floating
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
            let mod = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
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
        let ids = ["com.googlecode.iterm2", "com.apple.Terminal",
                   "net.kovidgoyal.kitty", "com.github.wez.wezterm"]
        for bid in ids {
            if let app = NSRunningApplication.runningApplications(withBundleIdentifier: bid).first {
                app.activate(options: .activateIgnoringOtherApps)
                return
            }
        }
    }

    // MARK: - Terminal Panel 终端会话面板

    func loadTerminalSessions() -> [TerminalSession] {
        let path = (NSString("~/Library/Application Support/vibe-island/session-terminals.json")).expandingTildeInPath
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String: Any]]
        else { return [] }
        return json.compactMap { id, dict in
            guard let cwd = dict["cwd"] as? String else { return nil }
            return TerminalSession(
                id: id,
                cwd: cwd,
                firstUserMessage: dict["firstUserMessage"] as? String ?? "",
                lastAssistantMessage: dict["lastAssistantMessage"] as? String ?? "",
                status: dict["status"] as? String ?? "",
                toolTarget: dict["toolTarget"] as? String ?? "",
                tty: dict["tty"] as? String ?? "",
                lastActivityAt: dict["lastActivityAt"] as? Double ?? 0
            )
        }.sorted { $0.lastActivityAt > $1.lastActivityAt }
    }

    func openTerminalSession(_ session: TerminalSession) {
        hideTerminalPanel()
        let tty = session.tty
        guard !tty.isEmpty else { return }
        let script = """
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
        DispatchQueue.global(qos: .userInitiated).async {
            if let as_ = NSAppleScript(source: script) {
                var err: NSDictionary?
                as_.executeAndReturnError(&err)
            }
        }
    }

    func showTerminalPanel() {
        guard view.window != nil else { return }
        let sessions = loadTerminalSessions()
        let panelW: CGFloat = 280
        let panelH: CGFloat = min(CGFloat(56 + sessions.count * 62 + 20 + 38), 400)

        if terminalPanelWindow == nil {
            let panel = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: panelW, height: panelH),
                styleMask: [.borderless, .nonactivatingPanel],
                backing: .buffered, defer: false
            )
            panel.backgroundColor = .clear
            panel.isOpaque = false
            panel.hasShadow = true
            panel.level = .floating
            panel.acceptsMouseMovedEvents = true
            panel.isReleasedWhenClosed = false
            terminalPanelWindow = panel
        }

        let panelView = TerminalSessionPanelView(
            sessions: sessions,
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
                    self.terminalHoverCooldownUntil = Date().addingTimeInterval(self.terminalHoverCooldownDuration)
                }
            }
        )
        let hosting = FirstMouseHostingView(rootView: panelView)
        hosting.frame = NSRect(x: 0, y: 0, width: panelW, height: panelH)
        hosting.wantsLayer = true
        hosting.layer?.cornerRadius = 12
        hosting.layer?.masksToBounds = true
        terminalPanelWindow?.contentView = hosting
        terminalPanelWindow?.setContentSize(NSSize(width: panelW, height: panelH))

        // 根据吸附方向决定弹出位置和动画方向
        guard let panel = terminalPanelWindow, let petWindow = view.window else { return }
        let screen = petWindow.screen ?? NSScreen.main
        let screenMaxX = screen?.visibleFrame.maxX ?? NSScreen.main?.visibleFrame.maxX ?? 1440
        // 右侧吸附：面板贴右边缘（与左侧对称），从右侧屏幕外飞入
        // 左侧吸附：面板贴左边缘 50px，从左侧屏幕外飞入
        let targetX: CGFloat = snappedSide == 1 ? screenMaxX - panelW - 50 : 50
        let startX:  CGFloat = snappedSide == 1 ? screenMaxX               : -panelW
        let targetY = max(petWindow.frame.midY - panelH / 2, 8)
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
        let screen = view.window?.screen ?? NSScreen.main
        let screenMaxX = screen?.visibleFrame.maxX ?? NSScreen.main?.visibleFrame.maxX ?? 1440
        // 右侧吸附：向右飞出；左侧吸附：向左飞出
        let exitX: CGFloat = snappedSide == 1 ? screenMaxX : -panel.frame.width
        let endFrame = NSRect(x: exitX, y: panel.frame.minY,
                              width: panel.frame.width, height: panel.frame.height)
        let anim = NSViewAnimation(viewAnimations: [[
            NSViewAnimation.Key.target:     panel,
            NSViewAnimation.Key.startFrame: NSValue(rect: panel.frame),
            NSViewAnimation.Key.endFrame:   NSValue(rect: endFrame)
        ]])
        anim.duration = 0.2
        anim.animationCurve = .easeIn
        anim.start()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self, weak panel] in
            panel?.orderOut(nil)
            self?.terminalHoverCooldownUntil = Date().addingTimeInterval(self?.terminalHoverCooldownDuration ?? 0.5)
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
        guard snapReminderCycleCount <= 3 else { stopSnapReminder(); return }

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
        countdownContainer?.isHidden = !isMouseOverPet
        updateCountdownDisplay()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in self?.updateCountdownDisplay() }
        waterTimer = Timer.scheduledTimer(withTimeInterval: waterReminderIntervalSeconds, repeats: true) { [weak self] _ in self?.playDrinkWaterAnimation() }
    }

    func restartWaterCountdown() {
        guard waterReminderIntervalSeconds > 0, waterTimer?.isValid == true else { return }
        countdownTimer?.invalidate()
        waterReminderEndDate = Date().addingTimeInterval(waterReminderIntervalSeconds)
        countdownContainer?.isHidden = !isMouseOverPet
        updateCountdownDisplay()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in self?.updateCountdownDisplay() }
    }

    func updateCountdownDisplay() {
        guard let endDate = waterReminderEndDate else { stopCountdown(); return }
        let remaining = endDate.timeIntervalSince(Date())
        if remaining <= 0 { stopCountdown(); return }

        let hours = Int(remaining) / 3600
        let minutes = (Int(remaining) % 3600) / 60
        let seconds = Int(remaining) % 60
        let timeString = hours > 0 ? String(format: "%d:%02d:%02d", hours, minutes, seconds) : String(format: "%02d:%02d", minutes, seconds)
        countdownLabel?.stringValue = "💧 \(timeString)"
        countdownLabel?.alignment = .center
    }

    func stopCountdown() { countdownTimer?.invalidate(); countdownTimer = nil; waterReminderEndDate = nil; countdownContainer?.isHidden = true }
    func cancelWaterReminder() { waterTimer?.invalidate(); stopCountdown() }

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
            self?.resetIdleTimer(); self?.updateCursorHover(event: event); return event
        }
        globalMouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved]) { [weak self] _ in self?.resetIdleTimer() }

        globalKeyboardMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.keyDown]) { [weak self] _ in self?.handleTypingActivity() }
        localKeyboardMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in self?.handleTypingActivity(); return event }
    }

    // 检测辅助功能授权状态，授权后自动重注册全局监听器（无需手动重启 app）
    func setupAccessibilityCheck() {
        guard !AXIsProcessTrusted() else { return }
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
    
    func updateCursorHover(event: NSEvent) {
        guard !isCurrentlyDragging else { return }
        let locationInView = skView.convert(event.locationInWindow, from: nil)
        guard let scene = skView.scene else { return }
        let locationInScene = scene.convertPoint(fromView: locationInView)
        let node = scene.atPoint(locationInScene)
        if node.name == "petSprite" || node.parent?.name == "petSprite" { NSCursor.openHand.set() }
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
            // 背景
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.13, green: 0.13, blue: 0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 0) {
                // 标题行
                HStack(spacing: 10) {
                    Image(systemName: "lock.shield")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(red: 1.0, green: 0.7, blue: 0.2))
                    Text("Claude 请求权限")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)

                // 分隔线
                Divider()
                    .background(Color.white.opacity(0.08))
                    .padding(.top, 12)

                // 工具标签
                HStack(spacing: 6) {
                    Text("工具")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.4))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.white.opacity(0.07))
                        .clipShape(Capsule())
                    Text(toolName)
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(red: 0.4, green: 0.8, blue: 1.0))
                }
                .padding(.top, 14)
                .padding(.horizontal, 20)

                // 命令内容
                CommandScrollView(text: command)
                    .frame(height: 140)
                    .background(Color.black.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.top, 10)
                    .padding(.horizontal, 20)

                // 按钮区
                VStack(spacing: 8) {
                    // 永久允许（仅当有 suggestions 时显示）
                    if hasSuggestions {
                        Button(action: onAlwaysAllow) {
                            HStack {
                                Text("始终允许")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white)
                                Spacer()
                                Text(shortcutAlwaysAllow)
                                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.65))
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(Color.white.opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 9)
                            .background(Color(red: 0.15, green: 0.72, blue: 0.45))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                        .keyboardShortcut("a", modifiers: .control)
                    }

                    // 允许一次
                    Button(action: onAllow) {
                        HStack {
                            Text("允许一次")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white)
                            Spacer()
                            Text(shortcutApprove)
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .foregroundColor(.white.opacity(0.65))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Color.white.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 9)
                        .background(Color(red: 0.25, green: 0.55, blue: 1.0))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut("y", modifiers: .control)

                    // 拒绝
                    Button(action: onDeny) {
                        HStack {
                            Text("拒绝")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.7))
                            Spacer()
                            Text(shortcutDeny)
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Color.white.opacity(0.10))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 9)
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut("n", modifiers: .control)
                }
                .padding(.top, 14)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .frame(width: 320)
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

    var projectName: String { URL(fileURLWithPath: cwd).lastPathComponent }
    var shortMessage: String {
        let s = firstUserMessage
        return s.count > 60 ? String(s.prefix(60)) + "…" : s
    }
    var isProcessing: Bool { status == "processing" }
}

// MARK: - TerminalSessionPanelView 终端会话面板视图
struct TerminalSessionPanelView: View {
    let sessions: [TerminalSession]
    let onSelect: (TerminalSession) -> Void
    let onSettings: () -> Void
    let onMouseEnter: () -> Void
    let onMouseExit: () -> Void

    private let bg = Color(red: 0.1, green: 0.1, blue: 0.1)
    private let dividerColor = Color.white.opacity(0.08)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 标题栏
            HStack {
                Image(systemName: "terminal")
                    .foregroundColor(.white.opacity(0.5))
                Text("终端会话")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.85))
                Spacer()
                Text("\(sessions.count)")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            dividerColor.frame(height: 1)

            if sessions.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "terminal.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white.opacity(0.2))
                    Text("没有活跃的终端会话")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.4))
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
                                dividerColor.frame(height: 1).padding(.leading, 12)
                            }
                        }
                    }
                }
                .frame(maxHeight: 280)
            }
            // 底部工具栏
            dividerColor.frame(height: 1)
            HStack {
                Spacer()
                Button(action: onSettings) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.45))
                        .padding(7)
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
        }
        .frame(width: 280)
        .background(bg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 6)
        .onHover { hovering in
            if hovering { onMouseEnter() } else { onMouseExit() }
        }
    }
}

struct SessionRowView: View {
    let session: TerminalSession
    let onTap: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Circle()
                    .fill(session.isProcessing ? Color(red: 0.2, green: 0.9, blue: 0.4) : Color.white.opacity(0.2))
                    .frame(width: 7, height: 7)
                    .padding(.leading, 2)

                VStack(alignment: .leading, spacing: 2) {
                    Text(session.projectName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(1)
                    if !session.shortMessage.isEmpty {
                        Text(session.shortMessage)
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.45))
                            .lineLimit(1)
                    }
                }
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(isHovered ? Color.white.opacity(0.08) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { h in isHovered = h }
    }
}

// MARK: - VisualEffectView 毛玻璃背景
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let v = NSVisualEffectView()
        v.material = material
        v.blendingMode = blendingMode
        v.state = .active
        return v
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
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

    func start(port: UInt16) {
        do {
            let parameters = NWParameters.tcp
            listener = try NWListener(using: parameters, on: NWEndpoint.Port(rawValue: port)!)
            listener?.newConnectionHandler = { [weak self] connection in
                self?.handleConnection(connection)
            }
            listener?.start(queue: .global(qos: .background))
            print("📡 狗蛋 Webhook 监听已启动: 端口 \(port)")
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

            // /permission 路由：持有连接，等用户点击后再响应
            if request.contains("POST /permission") {
                guard let payload = json else { sendOK(); return }
                DispatchQueue.main.async {
                    self.onPermissionRequest?(payload) { responseDict in
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

            DispatchQueue.main.async {
                switch state {
                case "thinking":     self.onThinking?()
                case "working":      self.onWorking?()
                case "error":        self.onError?()
                case "attention":    self.onAttention?()
                case "notification": self.onNotification?()
                case "idle":         self.onIdle?()
                case "sleeping":     self.onSleeping?()
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


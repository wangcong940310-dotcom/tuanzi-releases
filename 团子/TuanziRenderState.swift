import SwiftUI

// MARK: - Session Panel Render State

struct SessionPanelRenderState {
    let sessions: [SessionRowRenderState]
    let waterCountdown: String

    static let mockEmpty = SessionPanelRenderState(sessions: [], waterCountdown: "")
    static let mockSingle = SessionPanelRenderState(
        sessions: [.mockWorking],
        waterCountdown: "45:12"
    )
    static let mockMultiple = SessionPanelRenderState(
        sessions: [.mockWorking, .mockIdle, .mockCodex, .mockGemini],
        waterCountdown: "12:30"
    )
}

struct SessionRowRenderState: Identifiable {
    let id: String
    let projectName: String
    let firstUserMessage: String
    let lastAssistantMessage: String
    let isProcessing: Bool
    let elapsedTime: String
    let timeAgo: String
    let agentName: String
    let agentColor: Color
    let toolTarget: String

    static let mockWorking = SessionRowRenderState(
        id: "s1", projectName: "my-app", firstUserMessage: "Fix the login bug",
        lastAssistantMessage: "I'll look into the authentication module...",
        isProcessing: true, elapsedTime: "2m15s", timeAgo: "", agentName: "Claude",
        agentColor: TuanziTokens.Colors.accentOrange, toolTarget: "Edit"
    )
    static let mockIdle = SessionRowRenderState(
        id: "s2", projectName: "backend", firstUserMessage: "Add rate limiting",
        lastAssistantMessage: "Done! I've added rate limiting to all API endpoints.",
        isProcessing: false, elapsedTime: "", timeAgo: "5m", agentName: "Claude",
        agentColor: TuanziTokens.Colors.accentOrange, toolTarget: ""
    )
    static let mockCodex = SessionRowRenderState(
        id: "s3", projectName: "frontend", firstUserMessage: "Refactor components",
        lastAssistantMessage: "", isProcessing: true, elapsedTime: "30s", timeAgo: "",
        agentName: "Codex", agentColor: Color(red: 0.0, green: 0.75, blue: 0.45), toolTarget: "Bash"
    )
    static let mockGemini = SessionRowRenderState(
        id: "s4", projectName: "data-pipeline", firstUserMessage: "Optimize queries",
        lastAssistantMessage: "Analyzing the slow queries...", isProcessing: false,
        elapsedTime: "", timeAgo: "12m", agentName: "Gemini",
        agentColor: Color(red: 0.25, green: 0.55, blue: 0.95), toolTarget: ""
    )
}

// MARK: - Permission Dialog Render State

struct PermissionRenderState {
    let toolName: String
    let command: String
    let shortcutApprove: String
    let shortcutDeny: String
    let shortcutAlwaysAllow: String

    static let mockShort = PermissionRenderState(
        toolName: "Bash", command: "npm install",
        shortcutApprove: "Y", shortcutDeny: "N", shortcutAlwaysAllow: "A"
    )
    static let mockLong = PermissionRenderState(
        toolName: "Bash",
        command: "find /Users/dev/project -name '*.swift' -type f -exec grep -l 'import Foundation' {} \\; | head -20",
        shortcutApprove: "Y", shortcutDeny: "N", shortcutAlwaysAllow: "A"
    )
}

// MARK: - Elicitation Dialog Render State

struct ElicitationRenderState {
    let question: String
    let description: String
    let options: [(value: String, label: String)]

    static let mockTwo = ElicitationRenderState(
        question: "Choose a database",
        description: "Which database should we use for this project?",
        options: [("postgres", "PostgreSQL"), ("sqlite", "SQLite")]
    )
    static let mockFour = ElicitationRenderState(
        question: "Select framework",
        description: "Pick the UI framework for the frontend:",
        options: [("react", "React"), ("vue", "Vue.js"), ("svelte", "Svelte"), ("angular", "Angular")]
    )
}

// MARK: - Agent Settings Render State

struct AgentSettingsRenderState: Identifiable {
    let id: String
    let name: String
    let configPath: String
    let isInstalled: Bool
    let dirExists: Bool

    static let mockClaude = AgentSettingsRenderState(
        id: "claude", name: "Claude Code", configPath: "~/.claude/settings.json",
        isInstalled: true, dirExists: true
    )
    static let mockCodex = AgentSettingsRenderState(
        id: "codex", name: "Codex CLI", configPath: "~/.codex/config.toml",
        isInstalled: false, dirExists: true
    )
    static let mockMissing = AgentSettingsRenderState(
        id: "kimi", name: "Kimi CLI", configPath: "~/.kimi/config.toml",
        isInstalled: false, dirExists: false
    )
}

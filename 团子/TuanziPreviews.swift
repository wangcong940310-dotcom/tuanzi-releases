import SwiftUI

// MARK: - Preview Gallery

#if DEBUG

@available(macOS 13.0, *)
struct SessionPanel_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TerminalSessionPanelView(
                sessions: [],
                waterCountdown: "",
                onSelect: { _ in }, onSettings: {},
                onMouseEnter: {}, onMouseExit: {}
            )
            .previewDisplayName("Empty")

            TerminalSessionPanelView(
                sessions: [mockSession(id: "1", project: "my-app", agent: "Claude", processing: true, elapsed: "2m15s")],
                waterCountdown: "45:12",
                onSelect: { _ in }, onSettings: {},
                onMouseEnter: {}, onMouseExit: {}
            )
            .previewDisplayName("Single Working")

            TerminalSessionPanelView(
                sessions: [
                    mockSession(id: "1", project: "my-app", agent: "Claude", processing: true, elapsed: "1m30s"),
                    mockSession(id: "2", project: "backend", agent: "Codex", processing: false, elapsed: ""),
                    mockSession(id: "3", project: "frontend", agent: "Gemini", processing: true, elapsed: "45s"),
                ],
                waterCountdown: "12:30",
                onSelect: { _ in }, onSettings: {},
                onMouseEnter: {}, onMouseExit: {}
            )
            .previewDisplayName("Multi-Agent")
        }
        .frame(width: TuanziTokens.Layout.panelWidth)
        .background(Color.black)
    }

    static func mockSession(id: String, project: String, agent: String, processing: Bool, elapsed: String) -> TerminalSession {
        TerminalSession(
            id: id, cwd: "/Users/dev/\(project)",
            firstUserMessage: "Fix the login bug",
            lastAssistantMessage: processing ? "Working on it..." : "Done!",
            status: processing ? "working" : "idle",
            toolTarget: processing ? "Edit" : "",
            tty: "/dev/ttys001",
            lastActivityAt: Date().timeIntervalSince1970 - (processing ? 0 : 300),
            termSessionId: "", terminalApp: "",
            startedAt: Date().timeIntervalSince1970 - 90,
            agentId: agent.lowercased()
        )
    }
}

@available(macOS 13.0, *)
struct SessionRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            SessionRowView(
                session: SessionPanel_Previews.mockSession(id: "1", project: "my-app", agent: "Claude", processing: true, elapsed: "2m"),
                onTap: {}
            )
            SessionRowView(
                session: SessionPanel_Previews.mockSession(id: "2", project: "backend", agent: "Codex", processing: false, elapsed: ""),
                onTap: {}
            )
        }
        .frame(width: TuanziTokens.Layout.panelWidth)
        .background(TuanziTokens.Colors.panelBg)
        .previewDisplayName("Session Rows")
    }
}

@available(macOS 13.0, *)
struct PermissionDialog_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PermissionDialogView(
                toolName: "Bash",
                command: "rm -rf /tmp/build && npm run build",
                hasSuggestions: true,
                shortcutApprove: "⌃Y",
                shortcutDeny: "⌃N",
                shortcutAlwaysAllow: "⌃A",
                onAllow: {}, onAlwaysAllow: {}, onDeny: {}
            )
            .previewDisplayName("Permission - Short Command")

            PermissionDialogView(
                toolName: "Edit",
                command: "sed -i '' 's/oldFunction/newFunction/g' /Users/dev/my-app/src/components/AuthProvider.tsx /Users/dev/my-app/src/hooks/useAuth.ts /Users/dev/my-app/src/utils/tokenRefresh.ts",
                hasSuggestions: false,
                shortcutApprove: "⌃Y",
                shortcutDeny: "⌃N",
                shortcutAlwaysAllow: "⌃A",
                onAllow: {}, onAlwaysAllow: {}, onDeny: {}
            )
            .previewDisplayName("Permission - Long Command, No Suggestions")
        }
        .background(Color.black)
    }
}

@available(macOS 13.0, *)
struct SettingsRoot_Previews: PreviewProvider {
    static var previews: some View {
        SettingsRootView()
            .frame(width: TuanziTokens.Layout.settingsWidth, height: TuanziTokens.Layout.settingsHeight)
            .previewDisplayName("Settings")
    }
}

#endif

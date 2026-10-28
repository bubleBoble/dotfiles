/** @jsxImportSource @opentui/solid */
import { Plugin } from "@opencode/plugin/tui"
import type { Context } from "@opencode/plugin/tui/context"
import { For, Show, createEffect, createSignal, on, onCleanup } from "solid-js"
import { latestRequest, loadChanges } from "./changes.mjs"

type Change = {
    file: string
    status: "added" | "deleted" | "modified"
    additions: number
    deletions: number
}

function Changes(props: { context: Context; sessionID: string }) {
    const context = props.context
    const [mode, setMode] = createSignal<"git" | "session">("git")
    const [files, setFiles] = createSignal<Change[]>([])
    const [state, setState] = createSignal("Loading…")
    const requests = latestRequest()
    let timer: ReturnType<typeof setTimeout> | undefined
    const toggle = () => {
        setMode(mode() === "git" ? "session" : "git")
    }

    const refresh = () => {
        const sessionID = props.sessionID
        const scope = mode()
        const location = context.data.session.get(sessionID)?.location
        // Never fall back to the launch directory for a different session.
        if (!location) {
            requests.invalidate()
            setFiles([])
            setState("Session location unavailable")
            return
        }
        void requests.run(async () => {
            if (scope === "session") await context.data.session.message.sync(sessionID)
            return loadChanges(context.client, scope, sessionID, location,
                context.data.session.message.list(sessionID))
        }, (result: Change[]) => {
            setFiles([...result].sort((a, b) => a.file.localeCompare(b.file)))
            setState(result.length ? "" : "No changes")
        }, () => {
            setFiles([])
            setState(scope === "session" ? "Session changes unavailable (snapshots required)" : "Git status unavailable")
        })
    }

    createEffect(on(() => [props.sessionID, mode(), context.data.session.get(props.sessionID)?.location], () => {
        requests.invalidate()
        setFiles([])
        setState("Loading…")
        refresh()
    }))

    const stop = context.data.listen(({ details }) => {
        if (!/^(filesystem\.|vcs\.|session\.)/.test(details.type) || timer !== undefined) return
        timer = setTimeout(() => {
            timer = undefined
            refresh()
        }, 250)
    })
    // Also catch edits outside OpenCode when the server emits no file event.
    const poll = setInterval(refresh, 3000)
    context.keymap.layer(() => ({
        commands: [{
            id: "dotfiles.changes.toggle",
            title: "Changes: toggle Git / session",
            palette: true,
            slash: { name: "changes" },
            run: toggle,
        }],
    }))
    onCleanup(() => {
        requests.invalidate()
        stop()
        clearInterval(poll)
        if (timer !== undefined) clearTimeout(timer)
    })

    return <box>
        <text fg={context.theme.text.base} onMouseDown={toggle}>
            <b>{mode() === "git" ? "Git status" : "Session changes"}</b> ↔ ({files().length})
        </text>
        <Show when={state()}><text fg={context.theme.text.muted}>{state()}</text></Show>
        <For each={files()}>{(file) => <box flexDirection="row" gap={1}>
            <text fg={file.status === "added" ? context.theme.diff.text.added : file.status === "deleted" ? context.theme.diff.text.removed : context.theme.text.base}>
                {file.status === "added" ? "A" : file.status === "deleted" ? "D" : "M"}
            </text>
            <text fg={context.theme.text.muted} flexGrow={1} flexShrink={1}>{file.file}</text>
            <box flexDirection="row" gap={1} flexShrink={0}>
                <text fg={context.theme.diff.text.added}>+{file.additions}</text>
                <text fg={context.theme.diff.text.removed}>-{file.deletions}</text>
            </box>
        </box>}</For>
    </box>
}

export default Plugin.define({
    id: "dotfiles.changes",
    setup(context) {
        return context.ui.slot({
            append: "sidebar.content",
            render: (input) => <Changes context={context} sessionID={input.sessionID} />,
        })
    },
})

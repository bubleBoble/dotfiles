/**
 * Gives the prompt a distinct background and hides empty-prompt hints without
 * changing editor shortcuts. Autocomplete rows render above the panel, and a
 * fallback status row replaces the status line while completions hide it.
 * `startup.quiet` hides the welcome screen only.
 */
import type { ExtensionAPI, ExtensionContext } from "@oh-my-pi/pi-coding-agent";
import { CustomEditor } from "@oh-my-pi/pi-tui/prompt/custom-editor";
import * as fs from "fs";
import * as os from "os";
import * as nodePath from "path";

class QuietEditor extends CustomEditor {
    constructor(
        tui: ConstructorParameters<typeof CustomEditor>[0],
        theme: ConstructorParameters<typeof CustomEditor>[1],
        keybindings: ConstructorParameters<typeof CustomEditor>[2],
        private readonly statusRow: () => string,
    ) {
        super(tui, theme, keybindings);
    }

    override describePlaceholder = () => "";

    override render(width: number): string[] {
        this.placeholder = undefined;
        const background = "\x1b[48;2;37;42;54m";
        const lines = super.render(width);

        // The panel runs from the first border row to the matching closing
        // border row; rows after it are @/autocomplete suggestions. Move the
        // suggestion rows above the panel so the input stays at the bottom of
        // the block instead of sliding while the list filters on each key.
        let open = -1;
        let close = -1;
        for (let i = 0; i < lines.length; i++) {
            const plain = lines[i].replace(/\x1b\[[0-9;]*m/g, "");
            if (!/^─+$/.test(plain)) continue;
            if (open === -1) open = i;
            else {
                close = i;
                break;
            }
        }

        let insidePrompt = false;
        const patched = lines.map(line => {
            const plain = line.replace(/\x1b\[[0-9;]*m/g, "");
            if (/^─+$/.test(plain)) {
                insidePrompt = !insidePrompt;
                const edge = insidePrompt ? "▄" : "▀";
                return "\x1b[49m\x1b[38;2;37;42;54m"
                    + edge.repeat(plain.length)
                    + "\x1b[39m";
            }
            if (!insidePrompt) return line;
            return background
                + line.replace(/\x1b\[(0|49)m/g, `$&${background}`)
                + "\x1b[49m";
        });

        if (open === -1 || close === -1) return patched;
        const above = patched.slice(0, open);
        const completions = patched.slice(close + 1);
        const panel = patched.slice(open, close + 1);

        // OMP hides the status line while the completion list is open. Keep
        // its information available by rendering a fallback row below the
        // panel for exactly as long as completion rows exist.
        if (completions.length === 0) return [...above, ...panel];
        return [...above, ...completions, ...panel, "", this.statusRow()];
    }
}

function formatTokens(tokens: number): string {
    if (tokens < 1_000) return String(Math.round(tokens));
    return `${(tokens / 1_000).toFixed(1).replace(/\.0$/, "")}K`;
}

function gitBranch(cwd: string): string | undefined {
    try {
        const head = fs.readFileSync(nodePath.join(cwd, ".git", "HEAD"), "utf8").trim();
        if (head.startsWith("ref: refs/heads/")) return head.slice("ref: refs/heads/".length);
        return head.slice(0, 7);
    } catch {
        return undefined;
    }
}

function buildStatusRow(ctx: ExtensionContext): () => string {
    return () => {
        const model = ctx.models?.current?.() ?? ctx.model;
        const usage = ctx.getContextUsage();
        const cwd = ctx.cwd.replace(os.homedir(), "~");
        const branch = gitBranch(ctx.cwd);
        const parts = [
            model?.name,
            cwd,
            branch,
            usage && usage.contextWindow > 0
                ? `${formatTokens(usage.tokens)}/${formatTokens(usage.contextWindow)}`
                : undefined,
        ].filter(part => part !== undefined);
        return `\x1b[2m ${parts.join(" · ")}\x1b[22m`;
    };
}

export default function (pi: ExtensionAPI) {
    pi.on("session_start", (_event, ctx) => {
        if (!ctx.hasUI) return;
        ctx.ui.setEditorComponent((tui, theme, keybindings) =>
            new QuietEditor(tui, theme, keybindings, buildStatusRow(ctx)));
    });
}

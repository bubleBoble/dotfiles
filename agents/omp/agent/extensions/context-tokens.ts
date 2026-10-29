/**
 * Shows estimated occupied context tokens and the window limit as `56K/500K`,
 * plus a proportional colored bar of the context window (`context-bar`):
 * system prompt in accent, conversation messages in message color, free space
 * dimmed — the dominant /context categories. Both sides are estimated at
 * ~4 characters per token; OMP does not expose its exact per-category
 * breakdown to extensions. Uses current context usage, not session totals.
 */
import type { ExtensionAPI, ExtensionContext } from "@oh-my-pi/pi-coding-agent";

const BAR_CELLS = 16;
const FILLED = "█";
const EMPTY = "░";
const CHARS_PER_TOKEN = 4;

export default function (pi: ExtensionAPI) {
    let timer: NodeJS.Timeout | undefined;
    let previous: string | undefined;
    let previousBar: string | undefined;

    function formatTokens(tokens: number): string {
        return tokens < 1_000
            ? String(Math.round(tokens))
            : `${(tokens / 1_000).toFixed(1).replace(/\.0$/, "")}K`;
    }

    function messageText(entry: unknown): number {
        const { message } = entry as { message?: { content?: unknown } };
        const content = message?.content;
        if (!Array.isArray(content)) return 0;
        let chars = 0;
        for (const block of content) {
            if (
                block &&
                typeof block === "object" &&
                "text" in block &&
                typeof (block as { text: unknown }).text === "string"
            ) {
                chars += (block as { text: string }).text.length;
            }
        }
        return Math.ceil(chars / CHARS_PER_TOKEN);
    }

    function renderBar(ctx: ExtensionContext): string | undefined {
        const usage = ctx.getContextUsage();
        if (!usage || !(usage.contextWindow > 0)) return undefined;

        const systemTokens = Math.ceil(ctx.getSystemPrompt().length / CHARS_PER_TOKEN);
        const branch = ctx.sessionManager.getBranch() as unknown[];
        let messageTokens = 0;
        for (const entry of branch) {
            if ((entry as { type?: unknown }).type === "message") {
                messageTokens += messageText(entry);
            }
        }

        const theme = ctx.ui.theme as { fg?: (color: string, text: string) => string } | undefined;
        const paint = (color: string, text: string) =>
            theme?.fg ? theme.fg(color, text) : text;

        const scale = usage.contextWindow / BAR_CELLS;
        let filled = "";
        let used = 0;
        let cellsUsed = 0;
        for (const [tokens, color] of [
            [systemTokens, "accent"],
            [messageTokens, "userMessageText"]
        ] as Array<[number, string]>) {
            if (tokens <= 0) continue;
            const cells = Math.min(
                Math.max(1, Math.round((used + tokens) / scale) - cellsUsed),
                BAR_CELLS - cellsUsed,
            );
            if (cells <= 0) continue;
            filled += paint(color, FILLED.repeat(cells));
            used += tokens;
            cellsUsed += cells;
        }
        return filled + paint("muted", EMPTY.repeat(Math.max(0, BAR_CELLS - cellsUsed)));
    }

    function start(_event: unknown, ctx: ExtensionContext) {
        clearInterval(timer);
        if (!ctx.hasUI) return;
        previous = undefined;
        previousBar = undefined;

        function update() {
            const usage = ctx.getContextUsage();
            const value = usage
                ? `${formatTokens(usage.tokens)}/${usage.contextWindow > 0 ? formatTokens(usage.contextWindow) : "?"}`
                : undefined;
            if (value !== previous) {
                ctx.ui.setStatus("context-tokens", value);
                previous = value;
            }
            const bar = renderBar(ctx);
            if (bar !== undefined && bar !== previousBar) {
                ctx.ui.setStatus("context-bar", bar);
                previousBar = bar;
            }
        }

        update();
        // Also refresh after model changes, which have no extension lifecycle event.
        timer = setInterval(update, 1_000);
    }

    pi.on("session_start", start);
    pi.on("session_switch", start);
    pi.on("session_shutdown", () => {
        clearInterval(timer);
    });
}

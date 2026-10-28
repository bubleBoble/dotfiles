/**
 * Shows estimated occupied context tokens and the window limit as `56K/500K`.
 * Requires `status` in the configured status-line segments; uses current context
 * usage, not cumulative session tokens.
 */
import type { ExtensionAPI, ExtensionContext } from "@oh-my-pi/pi-coding-agent";

export default function (pi: ExtensionAPI) {
    let timer: NodeJS.Timeout | undefined;
    let previous: string | undefined;

    function formatTokens(tokens: number): string {
        return tokens < 1_000
            ? String(Math.round(tokens))
            : `${(tokens / 1_000).toFixed(1).replace(/\.0$/, "")}K`;
    }

    function start(_event: unknown, ctx: ExtensionContext) {
        clearInterval(timer);
        if (!ctx.hasUI) return;
        previous = undefined;

        function update() {
            const usage = ctx.getContextUsage();
            const value = usage
                ? `${formatTokens(usage.tokens)}/${usage.contextWindow > 0 ? formatTokens(usage.contextWindow) : "?"}`
                : undefined;
            if (value !== previous) {
                ctx.ui.setStatus("context-tokens", value);
                previous = value;
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

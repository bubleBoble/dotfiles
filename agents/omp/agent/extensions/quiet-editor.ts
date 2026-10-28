/**
 * Gives the prompt a distinct background and hides empty-prompt hints without
 * changing editor shortcuts. `startup.quiet` hides the welcome screen only.
 */
import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";
import { CustomEditor } from "@oh-my-pi/pi-tui/prompt/custom-editor";

class QuietEditor extends CustomEditor {
    override describePlaceholder = () => "";

    override render(width: number): string[] {
        this.placeholder = undefined;
        const background = "\x1b[48;2;37;42;54m";
        const lines = super.render(width);
        let insidePrompt = false;
        return lines.map(line => {
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
    }
}

export default function (pi: ExtensionAPI) {
    pi.on("session_start", (_event, ctx) => {
        if (!ctx.hasUI) return;
        ctx.ui.setEditorComponent((tui, theme, keybindings) =>
            new QuietEditor(tui, theme, keybindings));
    });
}

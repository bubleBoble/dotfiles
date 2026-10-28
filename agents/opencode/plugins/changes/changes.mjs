// Keep the request logic independent of the terminal renderer.
/** @param {import("@opencode/plugin/tui/context").Context["client"]} client */
export async function loadChanges(client, mode, sessionID, location, messages) {
    if (mode === "git") {
        return (await client.vcs.status({ location })).data;
    }
    const prompts = messages.filter((message) => message.type === "user");
    if (prompts.length === 0) return [];
    return client.session.diff({
        sessionID,
        from: prompts[0].id,
        to: prompts.at(-1).id,
        context: 0,
    });
}

export function latestRequest() {
    let version = 0;
    return {
        invalidate() { version++; },
        async run(load, accept, reject) {
            const current = ++version;
            try {
                const result = await load();
                if (current === version) accept(result);
            } catch (error) {
                if (current === version) reject(error);
            }
        },
    };
}

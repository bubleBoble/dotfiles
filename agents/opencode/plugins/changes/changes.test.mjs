import assert from "node:assert/strict";
import test from "node:test";
import { latestRequest, loadChanges } from "./changes.mjs";

test("Git status uses the active session location", async () => {
    const location = { directory: "/worktree" };
    const files = [{ file: "new.txt", status: "added" }];
    const client = { vcs: { status: async (input) => {
        assert.deepEqual(input, { location });
        return { data: files };
    } } };
    assert.equal(await loadChanges(client, "git", "session", location, []), files);
});

test("session changes span the first through latest prompt, not just one turn", async () => {
    const files = [{ file: "removed.txt", status: "deleted" }];
    const client = { session: { diff: async (input) => {
        assert.deepEqual(input, { sessionID: "session", from: "first", to: "last", context: 0 });
        return files;
    } } };
    const messages = [{ id: "first", type: "user" }, { id: "reply", type: "assistant" }, { id: "last", type: "user" }];
    assert.equal(await loadChanges(client, "session", "session", {}, messages), files);
});

test("an empty session does not request a latest-turn fallback", async () => {
    assert.deepEqual(await loadChanges({}, "session", "session", {}, []), []);
});

test("late responses cannot overwrite a newer mode or session", async () => {
    const requests = latestRequest();
    let finish;
    const accepted = [];
    const stale = requests.run(() => new Promise((resolve) => { finish = resolve; }), (value) => accepted.push(value), assert.fail);
    await requests.run(async () => "new", (value) => accepted.push(value), assert.fail);
    finish("old");
    await stale;
    assert.deepEqual(accepted, ["new"]);
});

test("errors reach the failure handler and disposal ignores pending results", async () => {
    const requests = latestRequest();
    const error = new Error("Snapshots unavailable");
    await requests.run(async () => { throw error; }, assert.fail, (cause) => assert.equal(cause, error));
    let finish;
    const pending = requests.run(() => new Promise((resolve) => { finish = resolve; }), assert.fail, assert.fail);
    requests.invalidate();
    finish([]);
    await pending;
});

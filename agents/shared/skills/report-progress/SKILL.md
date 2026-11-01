---
name: report-progress
description: Report progress and delays, challenge unnecessary work, and decide how to proceed.
disable-model-invocation: true
---

# Report progress

Use existing evidence to give a brief update before doing more work:

- **Progress:** what is complete, what remains against the user's request, and the current operation.
- **Delay:** the concrete reason for the delay; distinguish evidence from hypotheses.
- **Reassessment:** identify scope creep, redundant checks, and repeated actions that add no evidence. State what verification established and what remains uncertain.
- **Decision:** continue, change approach, or stop, with a reason. Give the smallest useful next action and its stopping condition, or state completion or the exact blocker.

Reuse valid check results. Keep required verification; add a check only if it resolves an uncertainty that could change a decision. Retry only after relevant conditions change or to test an explicit transient-failure hypothesis, with a bounded retry or timeout condition.

Separate code defects from environment, transport, and hardware failures. Repeated USB HID timeouts alone do not prove a firmware defect; mocks or skipped checks do not prove real-device behavior. Complete useful hardware-independent work and report what remains unverified.

Act on your decision without waiting for approval. Invocation alone is not a reason to cancel a running operation or stop the task. Ask only for a genuinely necessary decision, access, or physical intervention. Ending a loop does not make unfinished work complete.

# OMP usage data: primary-source evidence

Research snapshot: upstream `can1357/oh-my-pi`, commit
[`88a69582c755bd000e8dc0290981fc787a4f400c`](https://github.com/can1357/oh-my-pi/tree/88a69582c755bd000e8dc0290981fc787a4f400c).
No installed OMP files, real databases, transcripts, or credentials were inspected;
local version/schema compatibility remains unverified. This is research, not a claim
that the machine's historical records are complete.

## Storage and freshness

- Default SQLite database: `~/.omp/stats.db`; source transcripts:
  `~/.omp/agent/sessions/`, including nested subagent/advisor transcripts.
  The database is a **derived cache**, opened in WAL mode, not the source of truth.
  [Database initialization](https://github.com/can1357/oh-my-pi/blob/88a69582c755bd000e8dc0290981fc787a4f400c/packages/stats/src/db.ts#L159-L180),
  [transcript classification](https://github.com/can1357/oh-my-pi/blob/88a69582c755bd000e8dc0290981fc787a4f400c/packages/stats/src/parser.ts#L44-L61).
- Exact path resolver: config root is `path.join(homedir, PI_CONFIG_DIR || '.omp')`;
  named profiles append `profiles/<name>`. `OMP_PROFILE` wins over `PI_PROFILE`
  even when explicitly empty; empty/whitespace/`default` means no named profile.
  On Linux/macOS, with the default agent directory, a nonempty `XDG_DATA_HOME`
  redirects the database to `$XDG_DATA_HOME/omp/stats.db` only if that `omp`
  directory exists. For named profiles, the existence test and selected root are
  `$XDG_DATA_HOME/omp/profiles/<name>`, not just the base `omp` directory.
  A non-default `PI_CODING_AGENT_DIR` disables this XDG selection for the default
  profile but does not move the config-root database into that custom agent directory;
  named profiles ignore that agent override.
  [Profile/root rules](https://github.com/can1357/oh-my-pi/blob/88a69582c755bd000e8dc0290981fc787a4f400c/packages/utils/src/dirs.ts#L43-L123),
  [directory selection](https://github.com/can1357/oh-my-pi/blob/88a69582c755bd000e8dc0290981fc787a4f400c/packages/utils/src/dirs.ts#L328-L433),
  [stats/session paths](https://github.com/can1357/oh-my-pi/blob/88a69582c755bd000e8dc0290981fc787a4f400c/packages/utils/src/dirs.ts#L922-L925).
- `/stats` opens immediately **without awaiting ingestion**. Its live server starts
  a full sync, watches transcripts, and periodically resyncs. An existing database
  can therefore be incomplete or stale. Exact one-shot refresh: **`omp stats --summary`**
  (or `omp stats --json`), using the same profile/environment as the database.
  This awaits session sync and rollup refresh before printing the summary. Wait
  for successful command completion; opening the dashboard alone is insufficient.
  [Slash-command behavior](https://github.com/can1357/oh-my-pi/blob/88a69582c755bd000e8dc0290981fc787a4f400c/packages/coding-agent/src/slash-commands/helpers/stats-dashboard.ts#L72-L103),
  [live ingestion](https://github.com/can1357/oh-my-pi/blob/88a69582c755bd000e8dc0290981fc787a4f400c/packages/stats/src/live.ts#L77-L85),
  [blocking refresh command](https://github.com/can1357/oh-my-pi/blob/88a69582c755bd000e8dc0290981fc787a4f400c/packages/coding-agent/src/cli/stats-cli.ts#L86-L100).
  **Inference:** database mtime or latest request time cannot prove transcript
  completeness. A DB-only plotter should disclose cached-data scope and refresh
  instructions, not silently promise freshness or parse transcripts itself.

## Verified raw schema and counting

The relevant table is `messages`, not `user_messages` or `tool_calls`.
[Full authoritative DDL](https://github.com/can1357/oh-my-pi/blob/88a69582c755bd000e8dc0290981fc787a4f400c/packages/stats/src/db.ts#L189-L218):

```sql
-- Relevant columns, not a replacement CREATE TABLE statement:
id INTEGER PRIMARY KEY AUTOINCREMENT,
session_file TEXT NOT NULL, entry_id TEXT NOT NULL, folder TEXT NOT NULL,
model TEXT NOT NULL, provider TEXT NOT NULL, api TEXT NOT NULL,
timestamp INTEGER NOT NULL, duration INTEGER, ttft INTEGER,
stop_reason TEXT NOT NULL, error_message TEXT,
input_tokens INTEGER NOT NULL, output_tokens INTEGER NOT NULL,
cache_read_tokens INTEGER NOT NULL, cache_write_tokens INTEGER NOT NULL,
total_tokens INTEGER NOT NULL, premium_requests REAL NOT NULL,
agent_type TEXT NOT NULL DEFAULT 'main',
-- Also cost_* fields and service_tier; UNIQUE(session_file, entry_id).
```

- A request is **one indexed row**, `COUNT(*)`, including errors, aborted and
  zero-token calls; only `stop_reason = 'error'` is the failure counter. Do not
  use premium-request weights as request counts. Both assistant entries and
  separate `model_usage` entries feed this table; user prompts and tool executions
  do not each count as model requests. Missing identity/usage can cause malformed
  transcript entries to be skipped. This measures recorded calls, not necessarily
  every underlying HTTP retry.
  [Parser](https://github.com/can1357/oh-my-pi/blob/88a69582c755bd000e8dc0290981fc787a4f400c/packages/stats/src/parser.ts#L234-L341),
  [ingestion branches](https://github.com/can1357/oh-my-pi/blob/88a69582c755bd000e8dc0290981fc787a4f400c/packages/stats/src/parser.ts#L602-L609),
  [COUNT and failure semantics](https://github.com/can1357/oh-my-pi/blob/88a69582c755bd000e8dc0290981fc787a4f400c/packages/stats/src/rollup.ts#L82-L113).
- Timestamps are Unix **milliseconds**: finite positive message timestamp,
  otherwise parsed ISO entry timestamp, otherwise `0` (unknown). Exclude/report
  unknown timestamps separately rather than showing them as actual 1970 usage.
  [Timestamp coercion](https://github.com/can1357/oh-my-pi/blob/88a69582c755bd000e8dc0290981fc787a4f400c/packages/stats/src/parser.ts#L344-L350).
- Default aggregate includes all agent types. Branch copies are guarded against
  duplicate `(entry_id, timestamp)` across files; same-file replay upserts.
  Do not add another model-name-based deduplication layer.
  [Fork guard](https://github.com/can1357/oh-my-pi/blob/88a69582c755bd000e8dc0290981fc787a4f400c/packages/stats/src/db.ts#L1121-L1135).
- Model identity is **`(provider, model)`**, preserving recorded IDs, not model
  roles (`default`/`task`) or the current config. UI adds the provider to labels
  when a model ID occurs with multiple providers. Request share is each model's
  count divided by **all requests in that time bucket**, not token share or
  whole-period share; the UI folds beyond six models into Other.
  [Grouping](https://github.com/can1357/oh-my-pi/blob/88a69582c755bd000e8dc0290981fc787a4f400c/packages/stats/src/rollup.ts#L741-L747),
  [share calculation and labels](https://github.com/can1357/oh-my-pi/blob/88a69582c755bd000e8dc0290981fc787a4f400c/packages/stats/src/client/routes/ModelsRoute.tsx#L247-L315).

## Tokens: do not conflate the two totals

`input_tokens` is **uncached conversation input**; `cache_read_tokens` and
`cache_write_tokens` are separate prompt buckets. `output_tokens` includes
thinking, assistant text, and tool-call arguments; reasoning tokens are a subset,
not an extra bucket. Repeated cached context counts again on each request: these
are usage volumes, not unique text or occupied context.
[Usage type contract](https://github.com/can1357/oh-my-pi/blob/88a69582c755bd000e8dc0290981fc787a4f400c/packages/catalog/src/types.ts#L211-L243).

- **Conversation tokens** = input + output + cache read + cache write. This is
  the Models table/Overview headline metric.
  [UI helper](https://github.com/can1357/oh-my-pi/blob/88a69582c755bd000e8dc0290981fc787a4f400c/packages/stats/src/client/data/view-models.ts#L16-L25),
  [Models table](https://github.com/can1357/oh-my-pi/blob/88a69582c755bd000e8dc0290981fc787a4f400c/packages/stats/src/client/routes/ModelsRoute.tsx#L366-L375).
- **`total_tokens`** may additionally contain provider-side orchestration tokens.
  A finite reported total remains authoritative; missing/malformed totals derive
  from those four buckets plus orchestration input/output/cache read. Therefore
  `SUM(total_tokens)` need not equal the four-bucket sum. Raw stats columns do not
  preserve a separate orchestration breakdown; don't label their difference as
  an exact orchestration measurement. Cache hit rate upstream is cache read /
  (uncached input + cache read), excluding cache writes.
  [Total derivation](https://github.com/can1357/oh-my-pi/blob/88a69582c755bd000e8dc0290981fc787a4f400c/packages/stats/src/parser.ts#L185-L220),
  [cache rate](https://github.com/can1357/oh-my-pi/blob/88a69582c755bd000e8dc0290981fc787a4f400c/packages/stats/src/rollup.ts#L643-L662).

## Minimal query contract / candidate implementation

Use Python stdlib `sqlite3` with a read-only URI (`mode=ro`, **not** `immutable=1`,
because the database uses WAL), an explicit read transaction for consistent
multiple queries, and schema inspection to reject incompatible databases. Query
raw `messages`: upstream rollups require dirty-bucket reconciliation and are not
safe to sum naively during live ingestion. [Rollup design](https://github.com/can1357/oh-my-pi/blob/88a69582c755bd000e8dc0290981fc787a4f400c/packages/stats/src/rollup.ts#L1-L18).

```sql
SELECT provider, model, COUNT(*) AS requests,
       SUM(input_tokens) AS uncached_input,
       SUM(output_tokens) AS output,
       SUM(cache_read_tokens) AS cache_read,
       SUM(cache_write_tokens) AS cache_write,
       SUM(input_tokens + output_tokens + cache_read_tokens + cache_write_tokens)
           AS conversation_tokens,
       SUM(total_tokens) AS recorded_total_tokens
FROM messages
WHERE timestamp >= ? AND timestamp < ? AND timestamp > 0
GROUP BY provider, model;
```

For local-calendar daily charts, select the same aggregates grouped also by
`date(timestamp / 1000, 'unixepoch', 'localtime') AS day`; upstream uses exactly
this local-day expression. Bind start-local-midnight and next-day-after-end
local-midnight as Unix ms; construct calendar midnights independently, not by
adding 86,400 seconds across DST. Fill missing dates in Python; no-request share
is undefined (show a gap/“no requests”, not a spurious percentage).
[Upstream local-day query](https://github.com/can1357/oh-my-pi/blob/88a69582c755bd000e8dc0290981fc787a4f400c/packages/stats/src/db.ts#L1318-L1343).

Candidate simplest renderer: one self-contained local HTML file with escaped
labels, inline SVG, request-share percentages and separate conversation-token
volumes, a numeric totals table, explicit timezone/date range, and a cache/freshness
notice. No external assets, credentials, telemetry, session parsing, or third-party
plotting dependencies are necessary. This design recommendation is an inference,
not an upstream interface guarantee. Local OMP version/history can differ; validate
schema when the script runs and retain `--db` for explicit selection.

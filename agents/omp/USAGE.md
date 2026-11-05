# Offline OMP usage charts

Run from the repository root with Python 3 (standard library only):

```sh
# Refresh the derived stats cache first, using the same OMP profile/environment:
omp stats --summary
python3 agents/omp/usage.py --days 30 --output omp-usage.html
python3 agents/omp/usage.py --start 2026-10-01 --end 2026-10-31 --output october.html
# Explicit source, e.g. for a named profile or XDG installation:
python3 agents/omp/usage.py --db /path/to/stats.db --days 7 --output week.html
```

Open the generated HTML in a browser. It works offline: no server, JavaScript,
CDN, or plotting dependency. Generation never opens a browser automatically.
Default output is `omp-usage.html` in the current directory; an existing output
file is replaced. Output parent directories must already exist.

## Source and freshness

The default source is `~/.omp/stats.db`. This utility does not resolve OMP's
profile, `PI_CONFIG_DIR`, `PI_CODING_AGENT_DIR`, or XDG directory rules: pass
`--db` for any installation whose database lives elsewhere. Source access uses
SQLite read-only mode, including normal WAL visibility; a missing database is
an error, not a new empty database. The utility does not read session transcripts
or refresh stats itself.

The database is a derived cache and may be stale or incomplete. Run
`omp stats --summary` (or `omp stats --json`) before generation with the same
profile/environment as the intended sessions. Database existence or a recent
row does not establish completeness.

## Periods and counts

- Default: last 30 calendar days, including today. `--days N` must be positive.
- `--start` and `--end` must be supplied together and are inclusive ISO dates.
  They cannot be combined with `--days`.
- Dates use the machine's local timezone at report generation. Each local
  midnight is resolved separately, so daylight-saving days may span 23 or 25
  hours. A report moved elsewhere retains its generated dates and counts.
- Each `messages` row is a request, including failed, aborted, zero-token,
  assistant, and persisted model-usage entries. All agent types are included.
  Rows with unknown timestamp zero are excluded. Provider/model pairs stay
  distinct in labels and the period request-share denominator.
- Tokens are `input_tokens + output_tokens + cache_read_tokens + cache_write_tokens`,
  matching OMP's model token metric. Input excludes cached input; output includes
  thinking and tool arguments. Provider orchestration tokens that may appear in
  `total_tokens` are deliberately excluded from both daily charts.
- Daily per-model lines share one chart; the second line chart sums those same
  model values. Missing days are zero. Single-day reports retain visible points.
  No-data periods show zero totals and an explicit message.

Schema/metric reference: official
[OMP source at 88a6958](https://github.com/can1357/oh-my-pi/tree/88a69582c755bd000e8dc0290981fc787a4f400c):
`packages/stats/src/db.ts` (schema), `packages/catalog/src/types.ts` (token buckets),
and `packages/coding-agent/src/cli/stats-cli.ts` (blocking stats refresh).

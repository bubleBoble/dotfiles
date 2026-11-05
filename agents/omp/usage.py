#!/usr/bin/env python3
"""Render OMP usage as a dependency-free, offline HTML report."""

import argparse
from datetime import date, datetime, timedelta
from html import escape
from pathlib import Path
import sqlite3
import sys

COLORS = ("#2563eb", "#dc2626", "#059669", "#9333ea", "#d97706", "#0891b2", "#db2777")


def period(parser, args):
    today = date.today()
    if args.days is not None and (args.start or args.end):
        parser.error("--days cannot be combined with --start or --end")
    if args.start or args.end:
        if not (args.start and args.end):
            parser.error("--start and --end must be supplied together")
        start, end = args.start, args.end
    else:
        days = args.days if args.days is not None else 30
        if days < 1:
            parser.error("--days must be positive")
        end = today
        try:
            start = end - timedelta(days=days - 1)
        except OverflowError:
            parser.error("--days exceeds the supported date range")
    if start > end:
        parser.error("--start must not be after --end")
    return start, end


def line_chart(title, dates, series):
    width, height = 900, 310
    left, right, top, bottom = 85, 25, 25, 60
    plot_w, plot_h = width - left - right, height - top - bottom
    maximum = max((max(values, default=0) for _, values in series), default=0) or 1
    parts = [f'<section><h2>{escape(title)}</h2>',
             f'<svg role="img" aria-label="{escape(title, quote=True)}" viewBox="0 0 {width} {height}">',
             f'<title>{escape(title)}</title>']
    for step in range(5):
        y = top + plot_h * step / 4
        value = maximum * (4 - step) / 4
        parts.append(f'<path class="grid" d="M{left},{y} H{width-right}"/>')
        parts.append(f'<text x="{left-10}" y="{y+4}" text-anchor="end">{value:,.0f}</text>')
    def x(index):
        return left + plot_w * (index / (len(dates) - 1) if len(dates) > 1 else 0.5)
    indices = sorted({0, len(dates) // 2, len(dates) - 1})
    for index in indices:
        parts.append(f'<text x="{x(index)}" y="{height-25}" text-anchor="middle">'
                     f'{dates[index].isoformat()}</text>')
    for index, (model, values) in enumerate(series):
        color = COLORS[index % len(COLORS)]
        points = " ".join(f'{x(i):.2f},{top+plot_h*(1-value/maximum):.2f}'
                          for i, value in enumerate(values))
        parts.append(f'<polyline fill="none" stroke="{color}" stroke-width="2" points="{points}"/>')
        for i, value in enumerate(values):
            y = top + plot_h * (1 - value / maximum)
            parts.append(f'<circle cx="{x(i):.2f}" cy="{y:.2f}" r="3" fill="{color}">'
                         f'<title>{escape(model)} · {dates[i]}: {value:,} tokens</title></circle>')
    parts.append('</svg><ul class="legend">')
    for index, (model, _) in enumerate(series):
        parts.append(f'<li style="border-color:{COLORS[index % len(COLORS)]}">{escape(model)}</li>')
    parts.append('</ul></section>')
    return "\n".join(parts)


def render(start, end, daily, requests):
    dates = []
    day = start
    while True:
        dates.append(day)
        if day == end:
            break
        day += timedelta(days=1)
    models = sorted(set(requests) | set(daily))
    series = [(model, [daily.get(model, {}).get(day, 0) for day in dates]) for model in models]
    total_requests = sum(requests.values())
    total_tokens = sum(sum(values) for _, values in series)
    parts = ['<!doctype html><html lang="en"><meta charset="utf-8">',
             '<meta name="viewport" content="width=device-width, initial-scale=1">',
             '<title>OMP usage</title><style>',
             'body{font:16px system-ui,sans-serif;max-width:1100px;margin:2rem auto;padding:0 1rem;'
             'color:#172033;background:#f8fafc}section{background:white;padding:1rem;margin:1rem 0;'
             'border:1px solid #dbe2ec;border-radius:8px}svg{width:100%;height:auto}'
             'svg text{font-size:12px;fill:#475569}.grid{stroke:#e2e8f0;fill:none}'
             '.legend{display:flex;flex-wrap:wrap;gap:1rem;list-style:none;padding:0}'
             '.legend li{border-left:12px solid;padding-left:.5rem}.bar{height:16px;background:#2563eb}'
             '.share{margin:1rem 0}.muted{color:#475569}</style>',
             '<body><h1>OMP usage</h1>',
             f'<p>{start} through {end}, inclusive · local calendar dates</p>',
             f'<p>{total_requests:,} requests · {total_tokens:,} tokens</p>',
             '<p class="muted">Cached stats may be stale or incomplete. Run '
             '<code>omp stats --summary</code> first with the same profile and environment. '
             'This report does not refresh stats or read session transcripts. Tokens sum input, output, '
             'cache reads, and cache writes; provider orchestration tokens are excluded.</p>',
             '<section><h2>Period request share per model</h2>']
    for model in sorted(models, key=lambda model: (-requests.get(model, 0), model)):
        count = requests.get(model, 0)
        share = count / total_requests * 100 if total_requests else 0
        parts.append(f'<div class="share">{escape(model)} — {count:,} requests ({share:.1f}%)'
                     f'<div class="bar" style="width:{share:.4f}%"></div></div>')
    if not total_requests:
        parts.append('<p>No requests in this period.</p>')
    parts.append('</section>')
    parts.append(line_chart('Daily tokens per model', dates, series))
    totals = [sum(values[i] for _, values in series) for i in range(len(dates))]
    parts.append(line_chart('Daily total tokens', dates, [('All models', totals)]))
    parts.append('<p class="muted">Missing dates are shown as zero. Hover over points for exact counts.</p>')
    parts.append('</body></html>')
    return "\n".join(parts)


def read_usage(path, start, end):
    # Local midnights are resolved separately so DST days need not be 24 hours.
    lower = int(datetime.combine(start, datetime.min.time()).timestamp() * 1000)
    upper = int(datetime.combine(end + timedelta(days=1), datetime.min.time()).timestamp() * 1000)
    daily, requests = {}, {}
    uri = path.expanduser().resolve().as_uri() + "?mode=ro"
    with sqlite3.connect(uri, uri=True) as db:
        rows = db.execute(
            "SELECT provider, model, date(timestamp / 1000.0, 'unixepoch', 'localtime'), "
            "COUNT(*), SUM(input_tokens + output_tokens + cache_read_tokens + cache_write_tokens) "
            "FROM messages WHERE timestamp >= ? AND timestamp < ? AND timestamp > 0 "
            "GROUP BY provider, model, date(timestamp / 1000.0, 'unixepoch', 'localtime')",
            (lower, upper),
        )
        for provider, model, day, count, tokens in rows:
            label = f"{provider}/{model}"
            requests[label] = requests.get(label, 0) + count
            daily.setdefault(label, {})[date.fromisoformat(day)] = tokens
    return daily, requests


def main():
    parser = argparse.ArgumentParser(
        description=__doc__,
        epilog="Dates are inclusive, in the machine's local timezone. Default: last 30 days including today.",
    )
    parser.add_argument("--db", type=Path, default=Path.home() / ".omp/stats.db",
                        help="OMP stats database (default: ~/.omp/stats.db; override for profiles/XDG)")
    parser.add_argument("--output", type=Path, default=Path("omp-usage.html"), help="output HTML path")
    parser.add_argument("--days", type=int, help="last N calendar days, including today")
    parser.add_argument("--start", type=date.fromisoformat, metavar="YYYY-MM-DD")
    parser.add_argument("--end", type=date.fromisoformat, metavar="YYYY-MM-DD")
    args = parser.parse_args()
    start, end = period(parser, args)
    if end == date.max:
        parser.error("--end must be before 9999-12-31")
    try:
        daily, requests = read_usage(args.db, start, end)
        args.output.write_text(render(start, end, daily, requests), encoding="utf-8")
    except (OSError, sqlite3.Error, OverflowError, ValueError) as error:
        print(f"usage.py: {error}", file=sys.stderr)
        return 1
    print("Cached stats may be stale or incomplete; run omp stats --summary first with the same profile/env.")
    print(f"Wrote {args.output}")
    return 0


if __name__ == "__main__":
    sys.exit(main())

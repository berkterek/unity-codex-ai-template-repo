# Mailbox And Heartbeat Protocol

Agents use mailbox and heartbeat files to report progress while running.

Recommended paths:

```text
.codex/runtime/mailbox/{agent-id}.jsonl
.codex/runtime/heartbeat/{agent-id}.json
```

## Mailbox

Mailbox is append-only JSONL.

Common messages:

```json
{"ts":"2026-04-30T10:01:00Z","type":"started","message":"beginning task"}
{"ts":"2026-04-30T10:04:00Z","type":"progress","message":"read input files"}
{"ts":"2026-04-30T10:06:00Z","type":"partial_result","file":"src/Foo.cs","status":"complete"}
{"ts":"2026-04-30T10:07:00Z","type":"blocker","message":"missing dependency"}
{"ts":"2026-04-30T10:08:00Z","type":"completing","message":"implementation complete"}
```

Allowed message types:

- `started`
- `progress`
- `partial_result`
- `blocker`
- `warning`
- `completing`

## Heartbeat

Heartbeat is a single JSON object overwritten after major actions:

```json
{"ts":"2026-04-30T10:05:00Z","task":"P1.T1","status":"working","last_action":"edited src/Foo.cs"}
```

## Monitoring

Suggested thresholds:

- Warning: heartbeat older than 10 minutes.
- Stall: heartbeat older than 20 minutes.

Before replacing a stalled agent, read its mailbox. A recent `blocker` or
`completing` message may explain the delay.

## Cleanup

After a phase is committed and no longer needs recovery:

- Mailbox files may be archived or deleted.
- Heartbeat files may be deleted.
- Do not delete files while the phase is active or paused.


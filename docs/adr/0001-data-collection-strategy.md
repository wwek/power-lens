# ADR 0001: Hybrid Data Collection Strategy

## Status

Accepted

## Context

Power Lens needs to collect battery status, process metrics, CPU usage, and sleep assertion data on macOS. There are two main approaches for each data source: calling system APIs directly (Mach/IOKit) or spawning shell commands (`ps`, `top`, `pmset`).

The choice affects performance, reliability, code complexity, and whether root/sandbox permissions are needed.

## Decision

Use a hybrid approach — each data source uses the most practical method:

| Data Source | Method | Rationale |
|---|---|---|
| Total CPU/Memory | Mach API (`host_statistics`) | Zero overhead, structured data, used by all comparable tools |
| Process list (per-app CPU, memory, name) | Shell: `ps` via `Process`+`Pipe` | Simple, reliable, verified by Stats (20k stars). `proc_pidinfo` requires bridging C APIs and is not Sendable-friendly |
| Battery status | IOKit (`IOPSCopyPowerSourcesInfo`) + CFRunLoop push notifications | Push-based — only triggers on state change, no polling. Also reads `AppleSmartBattery` IO service for cycle count/capacity |
| Sleep assertions | IOKit API (`IOPMCopyAssertionsByProcess`) | Returns structured dictionary keyed by PID. No text parsing, no process spawn |
| App identity | `NSRunningApplication` | One call gives `bundleIdentifier` + `localizedName`. Fallback hardcoded rules for CLI/system processes |

## Consequences

- **No `proc_pidinfo` dependency** — avoids C bridging, unsafe pointers, and Sendable friction. Trade-off: loses fine-grained per-process I/O and network stats in V0.1 (deferred to V0.2).
- **`ps` spawned every 5 seconds** — minimal overhead (< 1ms per invocation on Apple Silicon). Stats has validated this at scale.
- **Battery uses push + poll hybrid** — CFRunLoop callback for state transitions (charging/discharging), periodic IOKit query for level percentage.
- **No sandbox compatibility** — `Process` (forking shell commands) doesn't work in App Store sandbox. This locks us out of Mac App Store unless we rewrite process collection to use only APIs. Acceptable for V0.1 since distribution is GitHub Release + Homebrew.

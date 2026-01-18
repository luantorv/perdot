# perdot – Design Contracts & Decisions

This document describes the **design contracts**, responsibilities, and
architectural decisions behind `perdot`.

It is intended as internal documentation and engineering notes.

---

## Core Philosophy

perdot is an **orchestrator of configuration**, not a runtime manager.

Fundamental principles:

- perdot never runs as a daemon
- perdot never owns the session lifecycle
- perdot prepares the system, then disappears
- removing perdot must not break the system

If perdot is uninstalled, the system should keep working.

---

## Responsibility Boundaries

### What perdot DOES

- Manage dotfiles via symlinks
- Resolve configs based on installed package versions
- Backup existing files before overriding
- Prepare user systemd units when required
- Provide diagnostics and status information

### What perdot DOES NOT DO

- Manage or control the graphical session
- Act as a service manager
- Hide systemd or abstract it away
- Enforce desktop or workflow decisions
- Keep background processes running

---

## Repository-Level Contracts

### Runtime State (`state/`)

The `state/` directory is **runtime-only** and disposable.

Expected structure:

```
state/
├── backups/ # Backup copies of replaced files
├── locks/ # Reserved for future locking
├── logs/ # Reserved for future logging
└── last_run.touched # Runtime marker
```


Contracts:
- `state/` may be safely deleted
- No configuration must depend on `state/`
- perdot recreates missing runtime state automatically

---

## Script Architecture

Execution flow:

```
bin/perdot
→ scripts/resolver.sh
→ scripts/runtime.sh
→ scripts/{command}.sh
```


### runtime.sh (bootstrap contract)

`runtime.sh` is the **single source of runtime initialization**.

It must:
- define global paths
- ensure runtime state exists
- perform minimal, non-interactive setup

It must NOT:
- perform command logic
- modify user configuration
- emit user-facing output (except verbose/debug)

No script may assume state exists without sourcing `runtime.sh`.

---

## Command Contracts

### `perdot install`

Purpose:
- Install perdot
- Link dotfiles according to resolver logic
- Optionally install packages

Contracts:
- Idempotent
- Safe to re-run
- Does NOT enable services automatically
- Does NOT start user daemons

---

### `perdot update`

Purpose:
- Pull repository updates
- Refresh symlinks
- Optionally update packages
- Optionally restart affected services

Contracts:
- Must not blindly restart services
- Restarts only services related to updated configs
- Must respect `--dry-run`

---

### `perdot setup`

Purpose:
- Prepare session-level integration

Responsibilities:
- Ensure systemd user session is available
- Link provided user systemd unit files
- Enable and start those units

Contracts:
- No package installation
- No config resolution
- No session detection or hacks
- Only acts on units present in the repository

perdot does NOT create its own services.

---

### `perdot uninstall`

Purpose:
- Remove perdot-managed symlinks
- Disable perdot-provided user services
- Leave the system functional

Contracts:
- Must not delete user-generated files
- Must not remove packages
- Rollback is manual and explicit

---

### `perdot status`

Purpose:
- Observe, never modify

Must report:
- Repository validity
- Dotfiles linkage state
- Missing or incorrect files
- Runtime state presence
- User service status

Contracts:
- Read-only
- No side effects
- No auto-repair

---

### `perdot doctor`

Purpose:
- Diagnose environment issues

Must check:
- Required tools availability
- Repository layout correctness
- PATH configuration
- Package presence (non-invasive)

Contracts:
- No system modification
- Clear OK / WARN / ERROR output

---

## Dotfiles Resolution Contract

Dotfiles are resolved using the following logic:

```
files/{package}/
├── base/
├── >=X.Y.Z/
```

Rules:
- `base/` is always applied if present
- Versioned directories apply if:
  installed_version >= declared_version
- Highest applicable version wins
- Missing mappings are warnings, not fatal errors

Resolver logic must be:
- deterministic
- side-effect free during planning
- reusable by install, update, and status

---

## systemd User Units Policy

perdot may provide **minimal user systemd units** only when:

- Upstream does not provide one, or
- The unit is required for a supported feature

Rules:
- Units must be generic and standard
- No perdot-specific logic inside units
- Units must work independently of perdot
- No custom targets or wrappers

perdot only:
- links units
- enables units
- starts units

---

## Design Non-Goals

The following are explicitly out of scope:

- Session managers
- Declarative OS configuration
- Full package management replacement
- Cross-distro abstraction
- GUI frontends

---

## Guiding Principle

When in doubt:

> Prefer explicit behavior over convenience  
> Prefer clarity over automation  
> Prefer boring code over clever code

If a feature makes perdot harder to remove, it is likely wrong.

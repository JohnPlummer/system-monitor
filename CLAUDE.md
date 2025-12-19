# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Lightweight bash-based macOS monitoring tool for diagnosing system freezes and kernel panics. Captures key metrics (memory pressure, file descriptors, thread counts, CPU/memory hogs) every 60 seconds via launchd.

## Commands

```bash
# Control the monitor
./ctl.sh install     # Install launchd agent and start
./ctl.sh start       # Start monitoring
./ctl.sh stop        # Stop monitoring
./ctl.sh status      # Check running status
./ctl.sh run-once    # Capture single snapshot
./ctl.sh uninstall   # Remove agent (preserves logs)

# View logs
./view-logs.sh last      # Most recent snapshot
./view-logs.sh tail      # Last 5 snapshots
./view-logs.sh files     # File descriptor trend
./view-logs.sh memory    # Memory pressure trend
./view-logs.sh threads   # Thread count trend
./view-logs.sh watch     # Real-time tail
```

## Architecture

- `monitor.sh` - Core monitoring script run by launchd every 60 seconds. Collects metrics via `memory_pressure`, `vm_stat`, `lsof`, `ps`, and writes to logs/system-metrics.log with automatic rotation at 50MB.
- `ctl.sh` - Manages launchd agent lifecycle (install/start/stop/uninstall)
- `view-logs.sh` - Log analysis helper with trend views for specific metrics
- `com.jp.system-monitor.plist` - launchd agent definition (StartInterval=60, RunAtLoad=true)

## Configuration

- Change logging interval: Edit `StartInterval` in plist, then `./ctl.sh uninstall && ./ctl.sh install`
- Change log rotation size: Edit `MAX_LOG_SIZE_MB` in monitor.sh (default 50MB)

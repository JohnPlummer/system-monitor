# System Monitor

Lightweight monitoring tool for diagnosing macOS freezes and kernel panics. Captures key system metrics every 60 seconds to help identify resource exhaustion before a hang.

## Background

Created to diagnose recurring watchdog timeout panics on a Mac Mini M4. The panic logs showed 650+ kernel threads and signs of system-wide resource pressure, but no obvious culprit. This monitor logs the metrics most likely to reveal exhaustion patterns:

- File descriptor usage (common cause of hangs)
- Thread counts per process
- Memory pressure and swap state
- CPU and memory hogs

## Quick Start

```bash
cd ~/code/system-monitor
chmod +x *.sh
./ctl.sh install
```

This installs a launchd agent that runs every 60 seconds and starts logging immediately.

## Commands

### Control Script

```bash
./ctl.sh install     # Install launchd agent and start monitoring
./ctl.sh start       # Start monitoring (if stopped)
./ctl.sh stop        # Stop monitoring
./ctl.sh status      # Check if monitor is running
./ctl.sh run-once    # Capture a single snapshot now
./ctl.sh uninstall   # Remove launchd agent (preserves logs)
```

### Viewing Logs

```bash
./view-logs.sh last      # Show most recent snapshot
./view-logs.sh tail      # Show last 5 snapshots
./view-logs.sh files     # Show file descriptor trend over time
./view-logs.sh memory    # Show memory pressure trend
./view-logs.sh threads   # Show kernel thread count trend
./view-logs.sh all       # Open full log in less
./view-logs.sh watch     # Real-time tail -f
```

## What Gets Logged

Each snapshot captures:

| Metric | Why It Matters |
|--------|----------------|
| Memory pressure | macOS's own assessment of memory state |
| VM stats | Free, active, wired, compressed pages; swap activity |
| Swap usage | Total swap allocated and used |
| System-wide open files | Count vs kern.maxfiles limit |
| Top 10 by open files | Identifies file descriptor leaks |
| Top 10 by threads | Identifies runaway thread creation |
| Total threads | System-wide thread count |
| Top 5 by CPU | Current CPU hogs |
| Top 5 by memory | Current memory hogs |
| Load average | Overall system load |

## Files

```
system-monitor/
├── README.md                      # This file
├── ctl.sh                         # Control script (install/start/stop)
├── monitor.sh                     # The actual monitoring script
├── view-logs.sh                   # Log viewing/analysis helper
├── com.jp.system-monitor.plist   # launchd agent definition
└── logs/
    ├── system-metrics.log        # Main log file
    ├── system-metrics.log.old    # Rotated log (after 50MB)
    └── monitor-error.log         # stderr from monitor.sh
```

## After a Freeze

Once the system recovers from a freeze or panic:

1. Check what was happening before the hang:

   ```bash
   ./view-logs.sh tail
   ```

2. Look for trends in resource usage:

   ```bash
   ./view-logs.sh files    # Were FDs climbing?
   ./view-logs.sh threads  # Were kernel threads spiking?
   ```

3. Check the full log for patterns:

   ```bash
   ./view-logs.sh all
   ```

### What to Look For

- **File descriptors approaching limit** - kern.maxfiles is typically 122880; if open files climbs toward this, something's leaking
- **Memory pressure going "critical"** - indicates severe memory exhaustion
- **Thread count climbing** - watch for sustained increases
- **Single process dominating** - one app repeatedly at top of multiple lists

## Analysis with Claude Code

Run `/analyze` in Claude Code to analyse the logs for resource exhaustion patterns.

## Configuration

To change the logging interval, edit the `StartInterval` value in `com.jp.system-monitor.plist` (value is in seconds), then reinstall:

```bash
./ctl.sh uninstall
./ctl.sh install
```

To change the log rotation size, edit `MAX_LOG_SIZE_MB` in `monitor.sh` (default 50MB).

## Uninstalling

```bash
./ctl.sh uninstall
```

This removes the launchd agent but preserves logs. To remove everything:

```bash
./ctl.sh uninstall
rm -rf ~/code/system-monitor
```

## Limitations

- The monitor itself uses lsof which can be slow under heavy load
- If the system freezes hard, the last snapshot may be up to 60 seconds before the freeze
- Kernel task thread count requires root access so isn't captured

## See Also

- Console.app - for system logs and crash reports
- Activity Monitor - for real-time process inspection
- `sudo spindump` - captures stack traces during hangs
- `sudo sysdiagnose` - comprehensive system diagnostic bundle

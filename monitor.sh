#!/bin/bash

# Lightweight system monitor for diagnosing freezes
# Logs key metrics that might indicate resource exhaustion

LOG_DIR="$HOME/code/system-monitor/logs"
MAX_LOG_SIZE_MB=50
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

mkdir -p "$LOG_DIR"

# Rotate log if it gets too big
LOG_FILE="$LOG_DIR/system-metrics.log"
if [[ -f "$LOG_FILE" ]]; then
    size_kb=$(du -k "$LOG_FILE" | cut -f1)
    if (( size_kb > MAX_LOG_SIZE_MB * 1024 )); then
        mv "$LOG_FILE" "$LOG_FILE.old"
    fi
fi

{
    echo "=== $TIMESTAMP ==="
    
    # Memory pressure (most critical for hangs)
    echo "-- Memory Pressure --"
    memory_pressure 2>/dev/null | head -5
    
    # VM stats snapshot
    echo "-- VM Stats --"
    vm_stat | grep -E "(free|active|inactive|wired|compressed|swapins|swapouts)"
    
    # Swap usage
    echo "-- Swap --"
    sysctl vm.swapusage 2>/dev/null
    
    # File descriptor counts - system wide
    echo "-- File Descriptors --"
    fd_count=$(lsof -l 2>/dev/null | wc -l | tr -d ' ')
    echo "System-wide open files: $fd_count"
    sysctl kern.maxfiles kern.maxfilesperproc 2>/dev/null
    
    # Top 10 processes by open file count
    echo "-- Top 10 by Open Files --"
    lsof -l 2>/dev/null | awk 'NR>1 {print $1}' | sort | uniq -c | sort -rn | head -10
    
    # Thread counts - single ps call, much faster
    echo "-- Top 10 by Threads --"
    ps -A -M -o pid=,comm= | awk '{count[$1" "$2]++} END {for (p in count) print count[p], p}' | sort -rn | head -10
    
    # Total thread count system-wide
    echo "-- Total Threads --"
    ps -A -M | tail -n +2 | wc -l | tr -d ' '
    
    # Process count
    echo "-- Process Count --"
    ps -A | tail -n +2 | wc -l | tr -d ' '
    
    # Top CPU consumers
    echo "-- Top 5 by CPU --"
    ps -A -o %cpu=,pid=,comm= -r | head -5
    
    # Top memory consumers  
    echo "-- Top 5 by Memory --"
    ps -A -o %mem=,pid=,comm= -m | head -5
    
    # Load average
    echo "-- Load Average --"
    uptime
    
    echo ""
} >> "$LOG_FILE"

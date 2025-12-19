#!/bin/bash

# View and analyse system monitor logs

LOG_FILE="$HOME/code/system-monitor/logs/system-metrics.log"

usage() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  tail      Show last 5 snapshots (default)"
    echo "  last      Show last snapshot only"
    echo "  files     Show file descriptor trend"
    echo "  memory    Show memory pressure trend"
    echo "  threads   Show kernel thread trend"
    echo "  all       Show entire log"
    echo "  watch     Watch log in real-time"
    echo ""
}

if [[ ! -f "$LOG_FILE" ]]; then
    echo "No log file found yet. Wait for monitor to run or run monitor.sh manually."
    exit 1
fi

case "${1:-tail}" in
    tail)
        # Last 5 snapshots - get line numbers of last 5 "===" markers
        lines=$(grep -n "^===" "$LOG_FILE" | tail -5 | cut -d: -f1)
        if [[ -z "$lines" ]]; then
            echo "No snapshots found in log"
            exit 1
        fi
        first_line=$(echo "$lines" | head -1)
        sed -n "${first_line},\$p" "$LOG_FILE"
        ;;
    last)
        # Last snapshot only - find last "===" and print from there
        last_line=$(grep -n "^===" "$LOG_FILE" | tail -1 | cut -d: -f1)
        if [[ -z "$last_line" ]]; then
            echo "No snapshots found in log"
            exit 1
        fi
        sed -n "${last_line},\$p" "$LOG_FILE"
        ;;
    files)
        # File descriptor trend
        echo "Timestamp                | Open Files"
        echo "-------------------------|------------"
        grep -E "(^=== |System-wide open)" "$LOG_FILE" | paste - - | \
            sed 's/=== //g' | sed 's/ ===.*open files: /  |  /g'
        ;;
    memory)
        # Memory pressure trend
        echo "Timestamp                | Memory Pressure"
        echo "-------------------------|----------------"
        grep -E "(^=== |System-wide memory)" "$LOG_FILE" | paste - - | \
            sed 's/=== //g' | sed 's/ ===.*: /  |  /g' | tail -20
        ;;
    threads)
        # Kernel thread count trend - look for the line after "-- Kernel Task Threads --"
        echo "Timestamp                | Kernel Threads"
        echo "-------------------------|---------------"
        awk '/^=== /{ts=$0} /^-- Kernel Task Threads --/{getline; print ts "  |  " $0}' "$LOG_FILE" | \
            sed 's/=== //g' | sed 's/ ===//g' | tail -30
        ;;
    all)
        less "$LOG_FILE"
        ;;
    watch)
        tail -f "$LOG_FILE"
        ;;
    *)
        usage
        ;;
esac

#!/bin/bash

# Control script for system monitor

SCRIPT_DIR="$HOME/code/system-monitor"
PLIST_NAME="com.jp.system-monitor.plist"
PLIST_SRC="$SCRIPT_DIR/$PLIST_NAME"
PLIST_DST="$HOME/Library/LaunchAgents/$PLIST_NAME"

usage() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  install   Install and start the monitor"
    echo "  start     Start monitoring"
    echo "  stop      Stop monitoring"
    echo "  status    Check if monitor is running"
    echo "  uninstall Remove the monitor completely"
    echo "  run-once  Run a single snapshot now"
    echo ""
}

case "${1:-}" in
    install)
        echo "Making scripts executable..."
        chmod +x "$SCRIPT_DIR/monitor.sh"
        chmod +x "$SCRIPT_DIR/view-logs.sh"
        chmod +x "$SCRIPT_DIR/ctl.sh"
        
        echo "Creating logs directory..."
        mkdir -p "$SCRIPT_DIR/logs"
        
        echo "Installing launchd agent..."
        mkdir -p "$HOME/Library/LaunchAgents"
        cp "$PLIST_SRC" "$PLIST_DST"
        
        echo "Loading agent..."
        launchctl load "$PLIST_DST"
        
        echo "Running initial snapshot..."
        "$SCRIPT_DIR/monitor.sh"
        
        echo ""
        echo "✓ Monitor installed and running"
        echo "  Logs: $SCRIPT_DIR/logs/system-metrics.log"
        echo "  View: $SCRIPT_DIR/view-logs.sh"
        ;;
    start)
        launchctl load "$PLIST_DST" 2>/dev/null || echo "Already loaded or not installed"
        echo "Monitor started"
        ;;
    stop)
        launchctl unload "$PLIST_DST" 2>/dev/null || echo "Already stopped or not installed"
        echo "Monitor stopped"
        ;;
    status)
        if launchctl list | grep -q "com.jp.system-monitor"; then
            echo "Monitor is running"
            echo "Last log entry:"
            tail -1 "$SCRIPT_DIR/logs/system-metrics.log" 2>/dev/null || echo "(no logs yet)"
        else
            echo "Monitor is not running"
        fi
        ;;
    uninstall)
        echo "Stopping monitor..."
        launchctl unload "$PLIST_DST" 2>/dev/null
        
        echo "Removing launchd agent..."
        rm -f "$PLIST_DST"
        
        echo "✓ Monitor uninstalled (logs preserved in $SCRIPT_DIR/logs/)"
        ;;
    run-once)
        "$SCRIPT_DIR/monitor.sh"
        echo "Snapshot captured. View with: $SCRIPT_DIR/view-logs.sh last"
        ;;
    *)
        usage
        ;;
esac

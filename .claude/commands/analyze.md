Read the system monitor log file at ~/code/system-monitor/logs/system-metrics.log (focus on the last 100 snapshots, roughly 100 minutes of data).

Analyse the log for patterns that might indicate resource exhaustion causing freezes or kernel panics.

Look for:

1. File descriptor counts trending upward toward the limit (kern.maxfiles shows the limit)
2. Memory pressure changes or swap usage spikes
3. Thread counts climbing unusually high
4. Any single process repeatedly dominating CPU, memory, or open files
5. Patterns in timing - do metrics degrade at specific intervals?
6. Any correlation between high resource usage and specific processes

The log captures: memory pressure, VM stats, swap usage, file descriptor counts and limits, top processes by open files/threads/CPU/memory, total thread count, process count, and load average.

If you identify a likely culprit, suggest specific next steps to confirm and remediate.

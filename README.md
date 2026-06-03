# Internet Monitor

A simple internet connection monitoring tool for Raspberry Pi using the Ookla Speedtest CLI.

The project periodically measures download speed, upload speed, and latency, storing the results in a log file. It also includes a reporting script that generates statistics about your connection performance over time.

## Project Structure

```text
internet-monitor/
├── internet_log.txt
├── monitor.sh
└── report.sh
```

### Files

| File               | Description                                                               |
| ------------------ | ------------------------------------------------------------------------- |
| `monitor.sh`       | Runs periodic internet speed tests and stores the results in the log file |
| `report.sh`        | Analyzes the log file and generates a performance report                  |
| `internet_log.txt` | Historical log containing all collected measurements                      |

---

# Requirements
* Ookla Speedtest CLI

---

# Installing Ookla Speedtest CLI

Update the system:

```bash
sudo apt update
sudo apt upgrade -y
```

Install required packages:

```bash
sudo apt install curl gnupg apt-transport-https -y
```

Add the official Ookla repository:

```bash
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
```

Install Speedtest CLI:

```bash
sudo apt install speedtest -y
```

Verify the installation:

```bash
speedtest --version
```

Run a manual speed test:

```bash
speedtest
```

---

# Usage

## Start Monitoring

Make the script executable:

```bash
chmod +x monitor.sh
```

Run the monitoring script:

```bash
./monitor.sh
```

The script will periodically append results to:

```text
internet_log.txt
```

Example log entry:

```text
[2026-06-02 08:12:15]
Download: 936.537616 Mbps
Upload: 702.329112 Mbps
Ping: 0.479 ms
------------------------
```

---

## Generate a Report

Make the script executable:

```bash
chmod +x report.sh
```

Run the report script:

```bash
./report.sh
```

The report includes:

* Monitoring start date and time
* Monitoring end date and time
* Total monitoring duration
* Average measurement interval
* Average download speed
* Average upload speed
* Average latency (ping)
* Minimum and maximum values
* Number of failed measurements
* Success rate

Example output:

```text
==================================================
NETWORK PERFORMANCE REPORT
==================================================

ANALYZED PERIOD
---------------
Start              : 2026-05-31 20:32:47
End                : 2026-06-02 10:06:33
Duration           : 1d 13h 33min
Average Interval   : 10min 9s

DOWNLOAD
---------
Average Speed      : 932.66 Mbps
Minimum Speed      : 926.75 Mbps
Maximum Speed      : 940.55 Mbps

UPLOAD
-------
Average Speed      : 697.51 Mbps
Minimum Speed      : 639.53 Mbps
Maximum Speed      : 711.04 Mbps

PING
-----
Average Ping       : 0.936 ms
Minimum Ping       : 0.479 ms
Maximum Ping       : 1.153 ms

AVAILABILITY
------------
Valid Measurements : 158
Failed Tests       : 0
Success Rate       : 100.00%

==================================================
```

---

# Running in the Background

To keep monitoring active after closing the terminal:

```bash
nohup ./monitor.sh > monitor.log 2>&1 &
```

Check if the process is running:

```bash
ps aux | grep monitor.sh
```

Stop monitoring:

```bash
pkill -f monitor.sh
```
---

# License

This project is provided for personal and educational use.

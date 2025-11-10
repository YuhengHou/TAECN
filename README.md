# TA-ECN Congestion Control (OMNeT++ 6.2 + INET 4.5.4)

This project implements and evaluates a **Traffic-Adaptive ECN (TA-ECN)** congestion control mechanism against a fixed-threshold **Baseline** under datacenter-like load.  
All experiments are performed in **OMNeT++ 6.2.0** with **INET 4.5.4**.

---

## Project Structure

```
taecn/
├── src/                     # NED and C++ source files
├── omnetpp.ini              # Simulation configurations
├── results/                 # Simulation outputs (.vec/.sca/.csv/.png)
├── compare_queue_stats.py   # Python script for queue length analysis
└── README.md
```

---

## 1. Build the Project

```bash
cd ~/default_workspace/taecn
make MODE=release -j$(nproc)
```

Builds all binaries and ensures INET linkage is correct.

---

## 2. Run Simulations (30 s wall time)

### (a) **Baseline (Fixed K)**

```bash
timeout 30s opp_run -u Cmdenv   -l ../inet-4.5.4/out/clang-release/src/libINET.so   -n .:src:../inet-4.5.4/src   -f omnetpp.ini -c HighloadBaseline
```

### (b) **Adaptive (TA-ECN)**

```bash
timeout 30s opp_run -u Cmdenv   -l ../inet-4.5.4/out/clang-release/src/libINET.so   -n .:src:../inet-4.5.4/src   -f omnetpp.ini -c HighloadAdaptive
```

🕒 Each run stops automatically after **30 seconds of real-world time**.  
All output files will appear under `./results/`.

---

## 3. Export Queue Metrics from `.vec`

Focus on **leaf queues**, where congestion buildup occurs:

```bash
# Baseline
opp_scavetool export -T v -F CSV-R   -o results/HighloadBaseline_queueLength.csv   --filter 'module =~ "TAECN.leaves[*].eth[*].queue" AND name =~ "queueLength:vector"'   results/HighloadBaseline.vec

# Adaptive
opp_scavetool export -T v -F CSV-R   -o results/HighloadAdaptive_queueLength.csv   --filter 'module =~ "TAECN.leaves[*].eth[*].queue" AND name =~ "queueLength:vector"'   results/HighloadAdaptive.vec
```

These CSV files contain all queue length samples across leaf interfaces.

---

## 4. Compare Queue Statistics

```bash
python3 compare_queue_stats.py
```

This script:
- Reads both exported CSVs  
- Computes `mean`, `p95`, and `max` queue lengths  
- Generates comparative plots under `./results/`  

Example output:

```
Baseline (Fixed K): mean=2.21, p95=8, max=15
Adaptive (TA-ECN):  mean=1.74, p95=6, max=11
Saved: results/compare_queueLength_fixed.png
```

---

## 5. Back Up the Entire Project

```bash
cd ~/default_workspace
zip -r taecn_backup_20251110.zip taecn
```

File will appear at  
`\\wsl$\Ubuntu\home\opp_env\default_workspace\taecn_backup_20251110.zip`

---

## 6. Access Results in Windows File Explorer

Paste this path in the Explorer address bar:

```
\\wsl$\Ubuntu\home\opp_env\default_workspace\taecn\results
```

or open directly from terminal:

```bash
explorer.exe results
```

---

## Notes

- `HighloadBaseline.vec/.sca` → Baseline experiment data  
- `HighloadAdaptive.vec/.sca` → Adaptive experiment data  
- The comparison focuses on **queue dynamics**; throughput, FCT, or ECN marking can be added analogously.
- Ensure OMNeT++ environment variables are set before running (`setenv PATH` and `opp_env` virtual shell).

---

## References

- **OMNeT++**: https://omnetpp.org  
- **INET Framework**: https://inet.omnetpp.org  
- **TA-ECN Concept**: Adaptive ECN threshold tuning for dynamic datacenter loads

#!/usr/bin/env python3
"""
TA-ECN vs Fixed-K Baseline Comparative Analysis
Author: Yuheng Hou (JHU ECE HLT Track)
Description:
  Computes and visualizes queue length and queueing delay comparison
  between Adaptive TA-ECN and Baseline ECN configurations.
"""

import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path

# --- File paths ---
results_dir = Path("results")
files = {
    "Baseline": {
        "queue": results_dir / "Baseline_(Fixed_K)_queueLength.csv",
        "delay": results_dir / "Baseline_(Fixed_K)_queueingTime.csv",
    },
    "Adaptive": {
        "queue": results_dir / "Adaptive_(TA-ECN)_queueLength.csv",
        "delay": results_dir / "Adaptive_(TA-ECN)_queueingTime.csv",
    },
}

# --- Helper to load data vectors ---
def load_vectors(csv_path):
    """Load vector time-series data exported from OMNeT++."""
    df = pd.read_csv(csv_path)
    df = df[df["type"] == "vector"]
    times, values = [], []
    for _, row in df.iterrows():
        t = [float(x) for x in str(row["vectime"]).split()]
        v = [float(x) for x in str(row["vecvalue"]).split()]
        times.extend(t)
        values.extend(v)
    return pd.DataFrame({"time": times, "value": values})

# --- Summary statistics ---
def summarize(df, label):
    if df.empty:
        return {"mean": 0, "p95": 0, "count": 0}
    mean = df["value"].mean()
    p95 = df["value"].quantile(0.95)
    print(f"[{label}] count={len(df)}  mean={mean:.6f}  p95={p95:.6f}")
    return {"mean": mean, "p95": p95, "count": len(df)}

# --- Main analysis ---
def main():
    print("📊 Analyzing TA-ECN vs Fixed-K Baseline...\n")

    data = {key: {} for key in files}
    summary = {}

    for config, metrics in files.items():
        for metric, path in metrics.items():
            if path.exists():
                data[config][metric] = load_vectors(path)
                print(f"✅ Loaded {len(data[config][metric])} samples from {path.name}")
            else:
                data[config][metric] = pd.DataFrame(columns=["time", "value"])
                print(f"⚠️ Missing file: {path.name}")

    print("\n=== Statistical Summary ===")
    summary["Baseline_queue"] = summarize(data["Baseline"]["queue"], "Baseline QueueLength")
    summary["Adaptive_queue"] = summarize(data["Adaptive"]["queue"], "Adaptive QueueLength")
    summary["Baseline_delay"] = summarize(data["Baseline"]["delay"], "Baseline QueueingTime")
    summary["Adaptive_delay"] = summarize(data["Adaptive"]["delay"], "Adaptive QueueingTime")

    # --- Table output ---
    print("\n=== Comparative Table ===")
    table = pd.DataFrame({
        "Metric": ["QueueLength_mean", "QueueLength_95th", "QueueingTime_mean", "QueueingTime_95th"],
        "Baseline": [
            summary["Baseline_queue"]["mean"],
            summary["Baseline_queue"]["p95"],
            summary["Baseline_delay"]["mean"],
            summary["Baseline_delay"]["p95"],
        ],
        "Adaptive": [
            summary["Adaptive_queue"]["mean"],
            summary["Adaptive_queue"]["p95"],
            summary["Adaptive_delay"]["mean"],
            summary["Adaptive_delay"]["p95"],
        ],
    })
    print(table.to_string(index=False, float_format="%.6f"))

    # --- Visualization ---
    fig, axes = plt.subplots(2, 1, figsize=(10, 8))

    # Queue length plot
    axes[0].plot(data["Baseline"]["queue"]["time"], data["Baseline"]["queue"]["value"], label="Baseline (Fixed K)")
    axes[0].plot(data["Adaptive"]["queue"]["time"], data["Adaptive"]["queue"]["value"], label="Adaptive (TA-ECN)")
    axes[0].set_title("Queue Length Comparison: TA-ECN vs Fixed K")
    axes[0].set_xlabel("Simulation Time (s)")
    axes[0].set_ylabel("Queue Length (pkts)")
    axes[0].legend()
    axes[0].grid(True)

    # Queueing time plot
    axes[1].plot(data["Baseline"]["delay"]["time"], data["Baseline"]["delay"]["value"], label="Baseline (Fixed K)")
    axes[1].plot(data["Adaptive"]["delay"]["time"], data["Adaptive"]["delay"]["value"], label="Adaptive (TA-ECN)")
    axes[1].set_title("Queueing Delay Comparison: TA-ECN vs Fixed K")
    axes[1].set_xlabel("Simulation Time (s)")
    axes[1].set_ylabel("Queueing Time (s)")
    axes[1].legend()
    axes[1].grid(True)

    plt.tight_layout()
    plt.savefig(results_dir / "taecn_vs_baseline_comparison.png", dpi=300)
    print("\n📈 Saved plot to results/taecn_vs_baseline_comparison.png")

if __name__ == "__main__":
    main()

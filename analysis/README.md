# 📈 Analysis Layer: Actuarial Risk & Solvency Modeling

This directory contains the **Python-based analytical core** of the audit. By integrating the raw evidence from [`/sql_scripts`](../sql_scripts), we transition from data extraction to **Stochastic and Deterministic Risk Modeling**.

## 🎯 Analytical Objectives
From an **Actuarial Science** perspective, the primary goal is to evaluate the **Surplus Process** of the Aave V3 protocol during the 18-second liquidity shock. We aim to determine the "Distance to Ruin" for top-tier whales and the systemic resilience of the WBTC/USDT market.

---

## 📂 Notebook Index: The "Four-Pillar" Framework

### Pillar 1: Market Microstructure & Basis Risk
These notebooks quantify the "Execution Friction" and the gap between on-chain reality and global benchmarks.
* **`Market Reality & Basis Risk.ipynb`**: Benchmarks DEX spot prices against global CEX data to quantify the **Basis Risk**.
* **`Market Stress Timeline___Price Deviation Audit.ipynb`**: Visualizes the high-frequency volatility spikes within the crash window.
* **`Volume Profile___ Slippage Sensitivity.ipynb`**: Analyzes the order book depth and how slippage scales with trade size during a crash.



### Pillar 2: Systemic Concentration (Pareto Audit)
Evaluating the "Too Big to Fail" risk within the Aave ecosystem.
* **`Systemic Concentration.ipynb`**: Uses the **Pareto Principle (80/20 Rule)** to assess debt concentration among the Top 10 borrowers and its impact on protocol solvency.

### Pillar 3: Whale Solvency & Trajectory
Real-time tracking of individual high-net-worth positions.
* **`Whale LTV Tracker.ipynb` / `Price Divergence___Health Factor Audit.ipynb`**: Tracks the **Health Factor (HF)** trajectory of specific whales using "Shadow Prices" rather than lagging Oracle prices.
* **`Liquidation Waterfall.ipynb`**: Identifies the specific price points where individual "whale" positions trigger a cascade.



### Pillar 4: Protocol Resilience Simulations
Advanced stress testing to identify the "Insolvency Cliff."
* **`Liquidation Waterfall Simulation.ipynb`**: A **Deterministic Stress Test** that simulates "What-if" scenarios (e.g., *What if BTC dropped 25% instead of 12%?*).
* **`The Silent Oracle Proof.ipynb`**: Quantitative evidence proving that the Oracle's filtering logic successfully prevented **Recursive Ruin**.

---

## 🧮 Actuarial Methodology

### 1. The Surplus Process Model
We treat Aave's safety buffer as an actuarial surplus:
$$U(t) = u + ct - S(t)$$
* **$u$**: Initial Collateral Over-collateralization.
* **$S(t)$**: Stochastic Price Shock (The Dec 24 Crash).
Our analysis proves that $U(t) > 0$ throughout the event, meaning no "Ruin" (Insolvency) occurred.



### 2. Shadow Health Factor Analysis
Traditional DeFi tools show HF based on **Oracle Prices**. Our notebooks calculate the **Shadow HF** based on **DEX Spot Prices**, revealing the hidden risk exposure during the 18-second window of extreme basis deviation.

---

## 🛠️ Execution & Requirements
All analysis is performed in **Jupyter (Python 3.10+)**.

**Key Libraries:**
* `Pandas`: High-frequency data manipulation.
* `Matplotlib / Seaborn`: Forensic data visualization.
* `NumPy`: Linear algebra for multi-asset collateral weighting.
* `SciPy`: Solvency distribution modeling.

**Data Dependency:** Inputs are sourced from the [`/data`](../data) directory, which are outputs of the SQL extraction phase.

---

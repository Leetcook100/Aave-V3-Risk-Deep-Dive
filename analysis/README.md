# 📊 Analysis Portfolio: High-Frequency DeFi Forensic Audit

This directory contains the core analytical engine of the **Aave V3 Resilience Study**. These notebooks utilize block-level data (~12.5s resolution) to "stress test" the protocol's solvency and oracle integrity during the BTC/USD liquidity shock of December 24, 2025.

## 🛠️ Analytical Framework

Unlike standard financial audits that rely on daily or hourly price feeds, this project employs **Block-Level Sampling**. This is critical for capturing **Basis Risk**—the "danger window" where on-chain market prices drop faster than the Oracle update frequency.

### 1. Oracle Integrity & Market Microstructure
These notebooks investigate the "silent proof": why the protocol remained stable despite a -12.76% price divergence in on-chain liquidity.

* **[The Silent Oracle Proof.ipynb](/The_Silent_Oracle_Proof.ipynb)**: Forensic evidence of Aave’s Oracle heartbeat and deviation logic filtering out 18 seconds of extreme market noise.
* **[Market Reality & Basis Risk.ipynb](./Market_Reality_Basis_Risk.ipynb)**: Quantifies the "Shadow Gap" between global benchmarks and localized DEX execution prices.
* **[Market Stress Timeline](./Market_Stress_Timeline___Price_Deviation_Audit.ipynb)**: Maps intra-block volatility intensity and deviation percentages across the incident window.



### 2. Solvency & Whale Risk Trajectories
Focuses on individual and systemic health factors (HF) using real-time market prices rather than protocol-reported indices.

* **[Whale Solvency Trajectory.ipynb](./Whale_Solvency_Trajectory.ipynb)**: Tracks the "Shadow HF" of the Top 5 borrowers, modeling how close major whales came to the liquidation threshold.
* **[Price Divergence & HF Audit](./Price_Divergence___Health_Factor_Audit.ipynb)**: A comparative audit of theoretical protocol safety vs. real-world market stress.
* **[Volume Profile & Slippage Sensitivity](./Volume_Profile___Slippage_Sensitivity.ipynb)**: Analyzes execution density and the "V-Shape" recovery curve to measure the speed of liquidity mean reversion.



### 3. Systemic Stress Testing & Concentration
Modeling the "worst-case" scenario and identifying structural vulnerabilities within the Aave V3 USDT pool.

* **[Liquidation Waterfall Simulation.ipynb](./Liquidation_Waterfall_Simulation.ipynb)**: An actuarial simulation sweeping price drops from 0% to 50% across volatile collateral to identify the "Liquidation Cliff"—the point of systemic bad debt.
* **[Systemic Concentration.ipynb](./Systemic_Concentration.ipynb)**: Analyzes the Pareto distribution of debt. Highlights that **63.95% of debt** is concentrated among 50 whales, heavily backed by Liquid Staking Tokens (weETH).



---

## 📋 Data Dependency Mapping

| Analytical Target | Source File (CSV) | Key Metric |
| :--- | :--- | :--- |
| **Price Deviation** | `03_deviation_audit.csv` | Max Basis Risk (-12.76%) |
| **Oracle Benchmarking** | `09_oracle_market_benchmarking.csv` | Heartbeat Filter Delta |
| **Whale Solvency** | `06_final_whale_solvency_parameters.csv` | Shadow Health Factor |
| **Liquidation Triggers** | `12_whale_liquidation_triggers.csv` | Individual "Cliff" Prices |
| **Concentration** | `07_systemic_concentration_audit.csv` | Pareto Ratio (63.95%) |

---

## 🧪 Requirements & Execution

1. **Environment**: Python 3.9+ with `pandas`, `matplotlib`, `seaborn`, and `numpy`.
2. **Execution Order**: 
    - Run `The Silent Oracle Proof.ipynb` first to establish the incident baseline.
    - Run `Whale Solvency Trajectory.ipynb` to view individual account impact.
    - Run `Liquidation Waterfall Simulation.ipynb` for the final systemic stress assessment.
3. **Verification**: All data is indexed via Ethereum Block #24081542 and is verifiable on Etherscan.io.

---

### 🏛️ Actuarial Conclusion
The audit confirms that Aave V3’s **Oracle Smoothing Mechanism** acted as a successful circuit breaker. While localized DEX prices crashed to **$85,858**, the protocol Oracle maintained a floor of **$98,420**, effectively ignoring 18 seconds of noise and preventing an erroneous **$125M** liquidation cascade.

# 📊 Analysis Portfolio: High-Frequency DeFi Forensic Audit

This directory contains the core analytical engine of the **Aave V3 Resilience Study**. These notebooks utilize block-level data (~12.5s resolution) to "stress test" the protocol's solvency and oracle integrity during the BTC/USD liquidity shock of December 24, 2025.

## 🛠️ Analytical Framework

Unlike standard financial audits that rely on daily or hourly price feeds, this project employs **Block-Level Sampling**. This is critical for capturing **Basis Risk**—the "danger window" where on-chain market prices drop faster than the Oracle update frequency.

### 1. Oracle Integrity & Price Deviation
These notebooks investigate the "silent proof": why the protocol remained stable despite extreme market noise.

* **[The_Silent_Oracle_Proof.ipynb](./The_Silent_Oracle_Proof.ipynb)**: Forensic evidence showing how Aave’s Oracle heartbeat and deviation logic filtered out 18 seconds of localized flash crash noise.
* **[Market_Reality_&_Basis_Risk.ipynb](./Market_Reality_&_Basis_Risk.ipynb)**: Quantifies the gap between global benchmarks and local DEX execution prices.
* **[Market_Stress_Timeline_Audit.ipynb](./Market_Stress_Timeline___Price_Deviation_Audit.ipynb)**: A block-by-block audit of price deviation intensity.



### 2. Whale Solvency & Monitoring
Real-time tracking of the protocol's largest stakeholders to identify "hidden" liquidation risks.

* **[Whale_Solvency_Trajectory.ipynb](./Whale_Solvency_Trajectory.ipynb)**: Tracks the "Shadow Health Factor" of top borrowers using real-time spot prices.
* **[Whale_LTV_Tracker.ipynb](./Whale_LTV_Tracker.ipynb)**: High-frequency monitoring of Loan-to-Value ratios at 15-second intervals during the crash.
* **[Price_Divergence_&_HF_Audit.ipynb](./Price_Divergence___Health_Factor_Audit.ipynb)**: Comparative analysis of theoretical protocol safety vs. real-world market stress.
* **[Volume_Profile_&_Slippage.ipynb](./Volume_Profile___Slippage_Sensitivity.ipynb)**: Analyzes on-chain liquidity depth and execution slippage during peak volatility.



### 3. Systemic Stress Testing & Composition
Modeling "what-if" scenarios to identify structural vulnerabilities and the "Liquidation Cliff."

* **[Liquidation_Waterfall_Simulation.ipynb](./Liquidation_Waterfall_Simulation.ipynb)**: A systemic simulation sweeping price drops from 0% to 50% to identify the point of inevitable bad debt.
* **[Liquidation_Waterfall.ipynb](./Liquidation_Waterfall.ipynb)**: Cumulative liquidation modeling for individual whale profiles.
* **[Systemic_Concentration.ipynb](./Systemic_Concentration.ipynb)**: Analyzes the Pareto distribution of debt. Highlights that **63.95% of debt** is held by 50 whales, primarily backed by Liquid Staking Tokens (weETH).



---

## 📋 Data Dependency Mapping

| Analytical Target | Source File (CSV) | Key Metric |
| :--- | :--- | :--- |
| **Price Deviation** | `03_deviation_audit.csv` | Max Basis Risk (-12.76%) |
| **Oracle Benchmarking** | `09_oracle_market_benchmarking.csv` | Heartbeat Filter Delta |
| **Whale LTV** | `06_final_whale_solvency_parameters.csv` | Real-time LTV Tracking |
| **Liquidation Triggers** | `12_whale_liquidation_triggers.csv` | Account "Cliff" Prices |
| **Concentration** | `07_systemic_concentration_audit.csv` | Top 50 Ratio (63.95%) |

---

## 🧪 Requirements & Execution

1. **Environment**: Python 3.9+ with `pandas`, `matplotlib`, `seaborn`, and `numpy`.
2. **Execution Order**: 
    - Run `The_Silent_Oracle_Proof.ipynb` first to establish the incident baseline.
    - Run `Whale_LTV_Tracker.ipynb` to view the immediate impact on solvency.
    - Run `Liquidation_Waterfall_Simulation.ipynb` for the final systemic risk assessment.
3. **Verification**: All data is indexed via Ethereum Block #24081542 and is verifiable on Etherscan.io.

---

### 🏛️ Actuarial Conclusion
The audit confirms that Aave V3’s **Oracle Smoothing Mechanism** successfully acted as a circuit breaker. While localized DEX prices crashed to **$85,858**, the protocol Oracle maintained a floor of **$98,420**, effectively ignoring 18 seconds of extreme volatility and preventing an erroneous **$125M** liquidation cascade.

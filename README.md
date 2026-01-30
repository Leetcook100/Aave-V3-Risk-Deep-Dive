# 🛡️ Aave V3 Resilience Analysis: BTC/USD Flash Crash Forensic Audit
**A High-Frequency Study of DeFi Systemic Risk & Oracle Robustness**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Tech: SQL](https://img.shields.io/badge/Tech-SQL-blue)](./sql_scripts)
[![Tech: Python](https://img.shields.io/badge/Tech-Python-green)](./analysis)

## 📌 Executive Summary
On **December 24, 2025 (17:19:18 UTC)**, a localized liquidity shock caused BTC/USD spot prices on decentralized exchanges to plummet to **$85,858.59**, while centralized benchmarks remained near **$98,420.00**. This created a critical **-12.76% Basis Risk** window.

This portfolio presents a block-level forensic audit of the **Aave V3 Protocol** during those 18 seconds of volatility. By applying **Actuarial Ruin Theory** and high-frequency data engineering, this study quantifies why the protocol remained solvent with **zero erroneous liquidations** despite extreme market microstructure divergence.

---

## 🎯 Research Motivation
As an **Actuarial Science** specialist with a focus on Finance, I aim to bridge the gap between traditional solvency modeling and decentralized finance. This project applies quantitative risk frameworks to:
* **Quantify Basis Risk**: Analyzing the divergence between Oracle-indexed prices and real-time DEX liquidity.
* **Stress-Test Solvency**: Calculating "Shadow Health Factors" to reveal hidden risks during Oracle latency.
* **Evaluate Microstructure**: Understanding the effectiveness of Aave’s 15-second update heartbeat as a circuit breaker.

---

## 📉 Case Study: The 18-Second Window


Forensic data confirms the protocol's safety filters effectively insulated users from market noise:

| Metric | Value | Data Source |
| :--- | :--- | :--- |
| **Incident Block** | #24081542 | `00_incident_discovery.csv` |
| **DEX Spot Low** | $85,858.59 | `02_block_aggregation.csv` |
| **Aave Oracle Price** | $98,420.00 | `09_oracle_benchmarking.csv` |
| **Max Basis Risk** | **-12.76%** | `03_deviation_audit.csv` |
| **Liquidations** | **0 (None)** | On-chain Event Audit |

---

## 🔬 Audit Methodology

### 1. The Shadow Health Factor ($HF_{Shadow}$)
To find the "hidden" insolvency risk, we calculate the **Shadow Health Factor**. This benchmarks account safety against real-time market spot prices ($P_{Spot}$) rather than lagging Oracle prices:

$$HF_{Shadow} = \frac{\sum (Collateral_{i} \times Price_{Spot} \times LT_{i})}{Total Debt_{USD}}$$

### 2. Basis Risk Quantization
We define Basis Risk as the percentage deviation of on-chain liquidity ($P_{DEX}$) from the protocol's reported price ($P_{Oracle}$):

$$Basis\ Risk\ \% = \left( \frac{P_{DEX} - P_{Oracle}}{P_{Oracle}} \right) \times 100\%$$

---

## 🛠️ Repository Structure

| Directory | Component | Description |
| :--- | :--- | :--- |
| [**`/sql_scripts`**](./sql_scripts) | **ETL & Indexing** | SQL queries (Flipside/Snowflake) extracting block-level DEX swaps. |
| [**`/data`**](./data) | **Evidence Vault** | Raw & normalized CSVs documenting every trade and Oracle update. |
| [**`/analysis`**](./analysis) | **Risk Modeling** | Jupyter Notebooks calculating Solvency Trajectories & Waterfalls. |

---

## 🚀 Key Forensic Insights
1. **Oracle Resilience**: The study proves that Aave’s deviation threshold and heartbeat mechanism successfully ignored outlier trades, preventing a potential **$125M erroneous liquidation cascade**.
2. **Systemic Concentration**: Pareto analysis reveals that **63.95% of protocol debt** is concentrated in 50 whale addresses, largely collateralized by Liquid Staking Tokens (weETH).
3. **Safety Buffers**: Even at the absolute market bottom, major whale positions maintained a **Safety Margin of >7%** above their Liquidation Thresholds.



---

## 💻 Tech Stack
* **SQL**: High-frequency indexing of Ethereum Mainnet events via Flipside Crypto.
* **Python**: Statistical forensic analysis using `Pandas`, `Numpy`, and `Scipy`.
* **Visualization**: Risk heatmaps and solvency curves via `Matplotlib` and `Seaborn`.
* **Actuarial Modeling**: Solvency simulations based on Ruin Theory and Price Sweeps.

---

## 📧 Contact & Verification
All transaction hashes (`Tx Hash`) and block data are verifiable via **Etherscan.io**. For inquiries regarding the quantitative models used in this audit, please reach out via the contact information in my profile.

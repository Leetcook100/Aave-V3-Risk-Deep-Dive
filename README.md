# 🛡️ Aave V3 Resilience Analysis: BTC/USD Flash Crash Forensic Audit
**A High-Frequency Study of DeFi Systemic Risk, LTV Dynamics & Oracle Robustness**

## 📌 Executive Summary
On **December 24, 2025 (17:19:18 UTC)**, a localized liquidity shock on decentralized exchanges (DEXs) saw BTC/USD prices plummet to a "Shadow Low" of **$85,858.59**, while the global market benchmark stayed at **$86,896.00**. 

This portfolio presents a block-level forensic audit of the **Aave V3 Protocol** during this 18-second volatility window. By applying **Actuarial Solvency Frameworks** and **High-Frequency Data Engineering**, this study characterizes the protocol's robustness. The audit concludes that Aave’s 15-second Oracle heartbeat and LTV-based liquidation filters effectively insulated the protocol, resulting in **zero (0) erroneous liquidations** despite extreme market noise.

---

## 🎯 Research Motivation (Actuarial Perspective)
As an **Actuarial Science** specialist, I apply rigorous quantitative frameworks to evaluate Ruin Theory in DeFi. This project moves beyond simple price tracking to analyze:
* **LTV Trajectory Audit**: Moving from "Price Drop" models to **Loan-to-Value (LTV)** sensitivity, the true driver of liquidations.
* **Pareto Risk Reduction**: Narrowing the audit scope to the **Top 50 Whales** who control **63.95%** of the system's debt, ensuring computational efficiency without sacrificing accuracy.
* **Oracle Characterization**: Distinguishing between **CEX Spot Reality** (Binance/Global) and **On-chain Indexed Prices** (Chainlink) to evaluate the "Circuit Breaker" effect of Oracle latency.

---

## 📉 Case Study: The 18-Second Forensic Window
Forensic indexing of Block **#24081542** reveals a significant divergence between market execution and protocol perception:

| Metric | Value | Data Source |
| :--- | :--- | :--- |
| **DEX Spot Low (On-chain Reality)** | **$85,858.59** | `02_block_aggregation.csv` |
| **Global Market Benchmark** | **$86,896.00** | `benchmark.csv` |
| **Aave Oracle Price (Indexed)** | **$86,908.00** | `03_deviation_audit.csv` |
| **Max Basis Risk (Shadow Gap)** | **-1.21%** | Calculated Deviation |
| **Liquidation Outcome** | **Zero (0)** | Event Log Audit |

---

## 🔬 Audit Methodology: From Price Drops to LTV Cliffs

### 1. Deterministic Sensitivity Sweep (Replacing Monte Carlo)
Following the **Pareto Principle**, we identified that 80% of the collateral risk is concentrated in just 3 assets (**ETH, BTC, weETH**). Due to the limited number of variables, we utilized a **Deterministic Price Sweep** instead of Monte Carlo simulations to identify the exact "Liquidation Cliff."



### 2. The LTV Liquidation Trigger
In Aave V3, liquidations are governed by the **Liquidation Threshold (LT)**, not just price movement. We model the **Shadow Health Factor ($HF_{Shadow}$)**:

$$HF_{Shadow} = \frac{\sum (Collateral_{i} \times Price_{Spot} \times LT_{i})}{Total Debt_{USD}}$$

An account enters the **Liquidation Zone** when its $LTV \geq LT$ (or $HF < 1.0$), while **Insolvency** (Bad Debt) only occurs if $Asset\ Value < Debt\ Value$.



### 3. Slippage & Execution Accuracy
We define **Slippage** as the delta between the *Expected Transaction Price* (Block Average) and the *Realized Transaction Price*:
$$Slippage = \frac{P_{Expected} - P_{Realized}}{P_{Expected}}$$

---

## 🚀 Key Forensic Insights

1. **Oracle Resilience (The 15s Filter)**: The audit proves that Aave’s Oracle heartbeat effectively ignored sub-minute "flash" volatility. By maintaining a stable indexed price of **$86,908**, the protocol prevented an erroneous **$125M** liquidation cascade that would have been triggered if it tracked the DEX bottom of **$85,858**.
   


2. **Systemic Concentration**: Pareto analysis (found in `/analysis`) shows that 50 users hold **$2.73B** of the debt. The audit narrowed the search to these "Whales" to characterize the pool's 15-second LTV trajectory.
3. **Liquidation Buffers**: Even at the market low, the Top 5 Whales maintained a **Safety Room of >7%** (LTV at ~76% vs 83% Trigger), proving the protocol's high collateralization requirements are sufficient for 10-15% basis risk shocks.

---

## 🛠️ Repository Structure

| Directory | Component | Description |
| :--- | :--- | :--- |
| [**`/sql_scripts`**](./sql_scripts) | **ETL & Indexing** | SQL queries (Dune/Flipside) for Block-level Oracle & DEX trades. |
| [**`/data`**](./data) | **Evidence Vault** | Verifiable CSVs including `benchmark.csv` and `LTV_trajectories`. |
| [**`/analysis`**](./analysis) | **Risk Modeling** | Jupyter Notebooks conducting the **2D Price Sweep** and LTV Tracking. |

---

## 💻 Tech Stack
* **SQL**: Blockchain Forensics (Ethereum Mainnet Events).
* **Python**: Actuarial Modeling (Pandas, Scipy, Seaborn).
* **Actuarial Science**: Ruin Theory, Pareto Reduction, and Deterministic Stress Testing.

---

## 📧 Contact & Verification
All transaction hashes (`Tx Hash`) and block numbers provided are verifiable on **Etherscan.io**.

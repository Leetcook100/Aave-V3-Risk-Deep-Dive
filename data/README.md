# 📂 Data Warehouse: Forensic Evidence Repository

This directory serves as the **Forensic Evidence Repository** for the Aave V3 BTC Flash Crash Audit. It contains the raw and processed `.csv` datasets extracted via SQL, which form the empirical basis for the Python risk simulations.

## 🎯 Data Integrity & Standards
All datasets are indexed by **Ethereum Block Number** (primary key) to ensure temporal alignment across multiple data sources (DEX, Oracle, and Protocol State).

* **Temporal Anchor**: Dec 24, 2025 (UTC).
* **Incident Block**: `24081538`.
* **Resolution**: Block-level (~12.5 seconds) for DEX trades; Minute-level for Oracle benchmarks.

---

## 📑 Dataset Inventory

### 1. Market Microstructure (Price & Liquidity)
These files capture the "Ground Truth" of the 18-second liquidity shock.
* **`01_raw_dex_trades.csv`**: Every individual swap event during the crash window.
* **`02_block_aggregation.csv`**: High-frequency metrics (Volatility, Volume) aggregated per block.
* **`03_deviation_audit.csv`**: Calculated basis risk showing the delta between spot prices and the benchmark.



### 2. Entity Discovery (Whale Tracking)
Mapping the debt positions of the Top 10 high-net-worth individuals.
* **`04_initial_debtor_discovery.csv`**: Initial reconnaissance of top USDT borrowers.
* **`05_whale_exposure_mapping.csv`**: Cross-referenced data linking debtors to their specific collateral assets.
* **`06_final_whale_solvency_parameters.csv`**: **[Critical]** Cleaned dataset with numerical Liquidation Thresholds (LT) used for Python stress tests.

### 3. Systemic Risk Metrics
Macro-level protocol health data.
* **`07_systemic_concentration_audit.csv`**: Pareto distribution data (Top 10 Debt vs. Total Market).
* **`08_aggregate_collateral_composition.csv`**: Asset breakdown of the collateral backing the USDT market.



### 4. Oracle & Benchmarking
Evidence of the protocol's defense mechanism.
* **`09_oracle_market_benchmarking.csv`**: Standardized global prices used as a control group.
* **`10_chainlink_oracle_staleness_audit.csv`** & **`11_oracle_event_density.csv`**: Evidence of "Oracle Silence." These files contain 0 records for the crash window, proving the filtering logic was active.

---

## 🛠️ Data Processing Pipeline

The data follows a strict **ELT (Extract, Load, Transform)** workflow:
1. **Extract**: SQL queries from [`/sql_scripts`](../sql_scripts) pull raw hex data from Ethereum.
2. **Load**: Data is saved as CSVs in this folder to maintain a static audit trail.
3. **Transform**: Python scripts in [`/analysis`](../analysis) handle decimal normalization:
    * **WBTC**: 8 Decimals.
    * **USDC/USDT**: 6 Decimals.
    * **WETH/LSTs**: 18 Decimals.

# 📂 Data Evidence: Aave V3 Resilience Audit Pipeline

This directory contains the primary datasets used for the **Aave V3 DeFi Audit**. The data spans on-chain Ethereum events, block-level DEX aggregations, and global market benchmarks during the BTC/USD flash crash incident on December 24, 2025.

## 📊 Dataset Catalog

### Phase 0: Incident Discovery & Scoping
* **[00_incident_block_discovery.csv](./00_incident_block_discovery.csv)**: Pinpoints the specific block range (starting at Block #24081538) where the liquidity shock occurred.
* **[04_initial_debtor_discovery.csv](./04_initial_debtor_discovery.csv)**: Raw list of all active USDT borrowers on Aave V3 leading up to the incident.

### Phase 1: High-Frequency Market Microstructure
* **[01_raw_dex_trades.csv](./01_raw_dex_trades.csv)**: Transaction-level data for every BTC-related swap on decentralized exchanges (Uniswap V2/V3, Curve) during the crash.
* **[02_block_aggregation.csv](./02_block_aggregation.csv)**: Aggregates individual trades into 12.5s block windows to determine the "Shadow" market low.
* **[03_deviation_audit.csv](./03_deviation_audit.csv)**: Quantifies the basis risk by calculating the delta between DEX spot prices and the Protocol Oracle price.

### Phase 2: Oracle Integrity Audits
* **[09_oracle_market_benchmarking.csv](./09_oracle_market_benchmarking.csv)**: Minute-by-minute price data from centralized exchanges (Binance) used to verify Oracle accuracy.
* **[10_chainlink_oracle_staleness_audit.csv](./10_chainlink_oracle_staleness_audit.csv)**: Audit of price update frequency. *Note: "No results" confirms the Oracle maintained stability within its deviation threshold.*
* **[11_oracle_event_density_audit.csv](./11_oracle_event_density_audit.csv)**: Verification of log-event density. Confirms the Oracle successfully filtered extreme short-term noise.

### Phase 3: Whale Solvency & Risk Parameters
* **[05_whale_exposure_mapping.csv](./05_whale_exposure_mapping.csv)**: Maps specific whale personas to their multi-asset collateral portfolios and debt obligations.
* **[06_final_whale_solvency_parameters.csv](./06_final_whale_solvency_parameters.csv)**: Normalized and cleaned dataset used for "Shadow Health Factor" time-series analysis.
* **[12_whale_liquidation_triggers.csv](./12_whale_liquidation_triggers.csv)**: Actuarial "Price Sweep" results calculating the exact BTC/ETH prices required to trigger liquidations for the Top 50 whales.

### Phase 4: Systemic Concentration & Resilience
* **[07_systemic_concentration_audit.csv](./07_systemic_concentration_audit.csv)**: Pareto analysis of protocol debt.
* **[07_systemic_concentration_audit (limit 50).csv](./07_systemic_concentration_audit%20(limit%2050).csv)**: Expanded audit verifying that 63.95% of protocol debt is concentrated in the top 50 accounts.
* **[08_aggregate_collateral_composition.csv](./08_aggregate_collateral_composition.csv)**: Breakdown of the billions in collateral (weETH, WETH, WBTC) backing the USDT debt pool.

---

## 🛠️ Data Standards & Processing

### 1. Decimal Normalization
All token amounts are normalized from raw EVM integers to human-readable floats:
- **WBTC**: Adjusted by $10^8$
- **USDT/USDC**: Adjusted by $10^6$
- **WETH/weETH**: Adjusted by $10^{18}$

### 2. Time Standardization
Timestamps are converted to UTC. Some datasets include a `timestamp_fixed` column to handle Excel/CSV truncation artifacts (e.g., mapping `MM:SS.f` back to the Dec 24, 2025 window).

### 3. Oracle Baseline
The audit assumes an Aave V3 Liquidation Threshold (LT) of **0.83** for WBTC and **0.825** for WETH as the primary triggers for systemic insolvency simulations.

---
**Verification Hint**: Block heights and transaction hashes provided in these datasets are verifiable via [Etherscan.io](https://etherscan.io).

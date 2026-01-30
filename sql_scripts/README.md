# 🛠️ SQL Scripts: High-Frequency DeFi Forensic Pipeline

This directory contains the primary forensic SQL engine used to extract, normalize, and model data from the Ethereum Mainnet. These scripts serve as the verifiable evidence for the **Aave V3 Resilience Audit**, moving chronologically from incident discovery to systemic solvency stress testing.

## 🏛️ Forensic Workflow Architecture

The scripts are grouped into five logical phases of a DeFi risk audit.

### Phase 0: Incident Discovery & Scoping
Establishing the "Ground Zero" of the liquidity shock.
* **[00_incident_block_discovery.sql](./00_incident_block_discovery.sql)**: Maps the exact UTC timestamp of the flash crash to Ethereum **Block #24081538**.
* **[04_initial_debtor_discovery.sql](./04_initial_debtor_discovery.sql)**: Scans the protocol state leading up to the crash to identify all active USDT borrowers.

### Phase 1: High-Frequency Market Microstructure
Capturing the "Market Reality" at a 12.5-second resolution.
* **[01_raw_dex_trades.sql](./01_raw_dex_trades.sql)**: Extracts transaction-level swap data for WBTC across Uniswap and SushiSwap to identify sub-block price action.
* **[02_block_aggregation.sql](./02_block_aggregation.sql)**: Aggregates trades by block height to calculate `min_price` and `volatility_flags`.
* **[03_deviation_audit.sql](./03_deviation_audit.sql)**: Quantifies the localized "Shadow Price" vs. the Protocol Oracle, identifying a **-12.76% Basis Risk**.



### Phase 2: Debtor Profiling & Exposure Mapping
Transforming raw addresses into human-readable risk personas.
* **[05_whale_exposure_mapping.sql](./05_whale_exposure_mapping.sql)**: Profiles the Top 10 borrowers, mapping their nicknames to multi-asset collateral portfolios.
* **[06_final_whale_solvency_parameters.sql](./06_final_whale_solvency_parameters.sql)**: Normalizes token decimals and applies Aave V3 Liquidation Thresholds (LT) for time-series modeling.

### Phase 3: Systemic Concentration & Asset Composition
Measuring the protocol's structural dependencies.
* **[07_systemic_concentration_audit.sql](./07_systemic_concentration_audit.sql)**: Conducts a Pareto analysis of the USDT debt pool.
    * *Finding*: **63.95% of debt** is concentrated in the top 50 addresses.
* **[08_aggregate_collateral_composition.sql](./08_aggregate_collateral_composition.sql)**: Breaks down the total USD value of collateral by category, identifying heavy reliance on **Liquid Staking Tokens (weETH)**.



### Phase 4: Oracle Integrity & Staleness Verification
Proving the protocol's insulation from market noise.
* **[09_oracle_market_benchmarking.sql](./09_oracle_market_benchmarking.sql)**: Retrieves 1-minute granularity benchmark prices to verify Oracle update logic.
* **[10_chainlink_oracle_staleness_audit.sql](./10_chainlink_oracle_staleness_audit.sql)**: Audits for "Stale Feeds"—confirming the Oracle updated correctly during peak stress.
* **[11_oracle_event_density_audit.sql](./11_oracle_event_density_audit.sql)**: Analyzes update frequency; proves the Oracle filtered 18s of noise by remaining within the 0.5% deviation heartbeat.

### Phase 5: Actuarial Sensitivity (The Price Sweep)
* **[12_whale_liquidation_triggers.sql](./12_whale_liquidation_triggers.sql)**: The final actuarial calculation. It computes the exact ETH/BTC prices that would trigger a systemic liquidation cascade for the Top 50 whales.
    * *Feature*: Includes a **"Dust Filter"** to eliminate mathematical ghost prices from low-value collateral.

---

## 🔧 Technical Standards

| Feature | Implementation Detail |
| :--- | :--- |
| **Indexing** | Primary key is `BLOCK_NUMBER` for ~12.5s forensic resolution. |
| **Precision** | Decimals handled via `POWER(10, reserve_decimals)` (e.g., WBTC=8, USDT=6). |
| **Netting** | Solvency is calculated using `SUM(Borrow - Repay - Liquidation)` for true exposure. |
| **Benchmarks** | WBTC Oracle: $86,908 | ETH Benchmark: $3,000 | BTC Benchmark: $90,000. |

---

## 📋 Data Usage
The outputs of these scripts (stored as `.csv` files in `/data/`) are consumed by the Jupyter Notebooks in `/analysis/` to generate LTV trajectories and liquidation waterfalls.

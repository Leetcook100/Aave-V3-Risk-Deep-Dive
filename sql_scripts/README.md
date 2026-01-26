# 🛠️ SQL Extraction Layer: On-Chain Forensic Indexing

This directory contains the **Source Queries** used to extract high-frequency trading data and protocol state evidence from the Ethereum blockchain. These scripts are designed for **Flipside Crypto** or **Dune Analytics** (Snowflake-based) to audit the BTC/USD flash crash on **December 24, 2025**.

## 🎯 Extraction Objective
Standard price feeds (Oracle) often smooth out data to prevent market manipulation. These scripts bypass those filters to capture **Block-Level Reality** (~12.5s resolution), providing the "Ground Truth" evidence required to assess Aave V3's resilience during extreme liquidity shocks.



---

## 📜 Audit Workflow & Script Inventory

### Phase 1: Incident Anchoring
Before analyzing trades, we must translate "human time" into "blockchain time."
* **`00_incident_block_discovery.sql`**
    * **Logic**: Maps the timestamp `17:19:18` to the logical block height.
    * **Anchor**: **Block #24081538**.

### Phase 2: Market Pricing & Basis Risk
Capturing the "Ground Truth" of prices across Uniswap V3 and Sushiswap.
* **`01_incident_snapshot.sql`**: Granular log of every individual WBTC swap.
* **`02_high_frequency_metrics.sql`**: Aggregates trades into 15s block intervals.
* **`03_basis_risk_quantification.sql`**: Measures the gap between DEX spot and Oracle baseline.
    * **Audit Metric**: $$Basis\ Risk\ \% = \frac{Price_{Spot} - Price_{Oracle}}{Price_{Oracle}} \times 100\%$$

### Phase 3: Debtor & Risk Profiling (Whale Watching)
Identifying who was at risk and what they were holding.
* **`04_initial_debtor_discovery.sql`**: Scans 24h of activity to find the Top 100 USDT borrowers.
* **`05_final_whale_solvency_analysis.sql`**: Maps collateral (WBTC/WETH) and injects precise numerical risk parameters (e.g., **0.825 LT** for WETH) for Python stress testing.

### Phase 4: Systemic Impact Assessment
Analyzing if individual failures could trigger a protocol-wide crisis.
* **`07_systemic_concentration_audit.sql`**: **Pareto Analysis** comparing Top 10 debtor volume vs. total market debt.
* **`08_aggregate_collateral_composition.sql`**: Audits the total collateral structure backing the USDT market.

### Phase 5: Oracle Integrity Verification
Proving why the protocol remained safe during the 18-second volatility.
* **`09_oracle_market_benchmarking.sql`**: Benchmarks DEX prices against global aggregated market prices.
* **`10_chainlink_oracle_staleness_audit.sql`**: Identifies the last valid Oracle update before the crash.
* **`11_oracle_event_density_audit.sql`**: Proves **"Oracle Silence"**—the lack of price updates during the 18s crash window, preventing erroneous liquidations.



---

## 🔍 Audit Requirement Traceability

| Requirement | SQL Implementation | Resolution |
| :--- | :--- | :--- |
| **15s Sampling** | `GROUP BY BLOCK_NUMBER` | ~12.5 seconds (Block level) |
| **Multi-DEX Aggregation** | `PLATFORM IN ('uniswap-v3', 'sushiswap')` | Aggregated Spot Price |
| **Risk Parameters** | `CASE WHEN reserve = 'WBTC' THEN 0.75` | Numerical LT for Python |
| **Oracle Verification** | `chainlink.price_feeds` | Update Density Analysis |

---

## 🛠️ Execution Instructions

1.  **Environment**: Execute on [Flipside Crypto](https://next.flipsidecrypto.xyz/).
2.  **Order**: Always run `00_incident_block_discovery.sql` first to confirm the `BLOCK_NUMBER` for your specific timeframe.
3.  **Asset Mapping**: Ensure `reserve` addresses match the specific **WBTC** and **USDT** contracts used in the audit.
4.  **Export**: Save results as `.csv` and move to the [`/data`](../data) directory for Python processing.

---

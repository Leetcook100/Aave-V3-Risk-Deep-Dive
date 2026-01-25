# 🛠️ SQL Extraction Layer: On-Chain Data Indexing

This folder contains the **Source Queries** used to extract high-frequency trading data from the Ethereum blockchain. These scripts are designed to be executed on **Flipside Crypto** (or similar Snowflake-based data warehouses) to interface with the `ethereum.defi.ez_dex_swaps` tables.

## 🎯 Extraction Objectives
The goal of these scripts is to move beyond "daily averages" and capture the **Block-Level Market Reality**. This is essential for auditing 18-second flash crashes where traditional price feeds often fail.

---

## 📜 Script Inventory

### 1. `01_raw_dex_trades.sql` (Micro-Event Capture)
* **Objective**: To isolate a focused 150-block window around the incident (Block 24081538).
* **Audit Logic**: It calculates the **Price Range** ($Max - Min$) and **Standard Deviation** within each 12-second block. 
* **Key Output**: Provides the raw data for `Sheet2.csv` and `Sheet4.csv`, allowing us to see individual trade execution prices versus the block average.

### 2. `02_block_aggregation.sql` (Macro Volatility Baseline)
* **Objective**: To scan a 30-minute window to establish a "Normal Market" baseline.
* **Audit Logic**: Uses a `CASE` statement to normalize prices across different DEX platforms (Uniswap V2/V3, Sushiswap).
* **Key Output**: Tags blocks with `HIGH_VOLATILITY` or `NORMAL` flags based on intra-block price swings, helping auditors identify if the crash was an isolated anomaly or part of a larger trend.

### 3. `03_deviation_audit.sql` (Oracle vs. Spot Benchmarking)
* **Objective**: To extract the specific metrics required for **Basis Risk** assessment.
* **Audit Logic**: Focuses on the price calculation from swap amounts:
    $$Price_{Spot} = \frac{Amount_{USD}}{Amount_{Tokens}}$$
* **Key Output**: Generates the high-resolution price feed used to benchmark the Aave Oracle's "lag" or "smoothing" effect.

---

## 🔍 Audit Requirement Traceability

| Requirement | SQL Implementation | Resolution |
| :--- | :--- | :--- |
| **15s Sampling Frequency** | `GROUP BY BLOCK_NUMBER` | ~12.5 seconds (Block level) |
| **Multi-DEX Aggregation** | `PLATFORM IN ('uniswap-v2', 'uniswap-v3', 'sushiswap')` | Aggregated Spot Price |
| **Characterize Volatility** | `STDDEV(PRICE)` & `MAX(PRICE) - MIN(PRICE)` | Intra-block delta |

---

## 🛠️ Execution Instructions
1.  Open [Flipside Crypto App](https://next.flipsidecrypto.xyz/).
2.  Copy the contents of the `.sql` files into the query editor.
3.  Ensure the `BLOCK_NUMBER` parameters match the specific BTC/USD incident window.
4.  Export the resulting dataset as a `.csv` and place it in the `/data` directory.

> **Note on Asset Mapping**: While the source scripts use `WETH` for initial logic testing, the final audit data (found in `/data`) was extracted using the same logic applied to the **WBTC** (Wrapped Bitcoin) contract to align with the **BTC/USD** project scope.

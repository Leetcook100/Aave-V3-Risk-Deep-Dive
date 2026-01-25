# 📂 Data Repository: On-Chain BTC Flash Crash Evidence

This directory contains the raw and processed datasets used for the **BTC/USD Flash Crash Audit**. These datasets provide the "ground truth" for market activity during the liquidity shock observed in December 2025.

## 📌 Data Provenance
* **Source**: Ethereum Blockchain (via Flipside Crypto).
* **Asset**: WBTC (Wrapped Bitcoin) as the primary collateral.
* **Pairs**: WBTC/USD (calculated across major DEX pools including Uniswap V2/V3 and Sushiswap).
* **Resolution**: Block-level granularity (~12-15 seconds per observation).

---

## 📄 File Inventory

### 1. `Sheet2.csv` (Raw Transactional Evidence)
* **Description**: Granular log of every individual swap involving WBTC within the audit window.
* **Key Columns**:
    * `Block number`: The unique identifier of the Ethereum block.
    * `Btc spot price usd`: The execution price of the specific trade.
    * `Tx hash`: The unique transaction ID for on-chain verification.
    * `Platform`: The DEX where the trade occurred (e.g., Uniswap-v3).
* **Audit Role**: Used to characterize market "noise" and identify the absolute lowest price points executed by arbitrageurs.

### 2. `Sheet4.csv` (Block-Level Time Series)
* **Description**: Aggregated market metrics for each block. This is the primary dataset for time-series analysis.
* **Key Columns**:
    * `Swap count`: Total number of trades in the block (measures intensity).
    * `Min price / Max price`: The price range within the 12s window.
    * `Total volume usd`: The total liquidity moved in that block.
    * `Volatility flag`: Automated tagging of high-risk blocks.
* **Audit Role**: Used to satisfy the requirement for **15-second sampling frequency** and to correlate trading intensity with price impact.

### 3. `Sheet6.csv` (Quantitative Audit Summary)
* **Description**: A filtered dataset focusing on the deviation between market reality and the protocol baseline.
* **Key Columns**:
    * `Min price deviation pct`: The percentage gap between the DEX spot price and the Oracle reference ($98,420).
    * `Price range`: Measures the "gap" between the highest and lowest trades in a single block.
* **Audit Role**: The "Smoking Gun" evidence used to quantify **Basis Risk** and justify why the Oracle smoothing mechanism prevented liquidations.

---

## ⚠️ Important Note on Time Formats
The `Block timestamp` column in these CSVs may exhibit a truncation bug due to Excel exporting (e.g., `49:35.0` instead of `09:49:35`). 
* **Fix**: The analysis notebooks in the `/analysis` folder contain a `fix_time()` pre-processing function to reconstruct these into standard ISO-8601 timestamps.

## 🔒 Data Integrity
To verify the authenticity of this data, any `Tx hash` in `Sheet2.csv` can be queried directly on [Etherscan](https://etherscan.io) using the provided block numbers.

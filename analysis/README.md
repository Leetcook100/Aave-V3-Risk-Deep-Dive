# 📊 Analysis Core: BTC/USD Flash Crash Forensic Engine

This directory contains the computational heart of the audit project. We use a series of Jupyter Notebooks to transform raw blockchain data (from `/data`) into actionable risk insights, focusing on the **Aave V3 Protocol's resilience** during the December 2025 BTC liquidity shock.



---

## 🗂️ Notebook Directory & Audit Objectives

### 1. Market Reality & Oracle Divergence
* **`Price Divergence___Health Factor Audit.ipynb`**
    * **Objective**: The "Primary Forensic Evidence." It compares Aave's Oracle price against Uniswap/Sushiswap spot prices.
    * **Key Output**: Visualizes the **Basis Risk Gap** and simulates the "Shadow Health Factor" of a $50M whale position.
* **`Market Stress Timeline___Price Deviation Audit.ipynb`**
    * **Objective**: Characterizes micro-volatility at a 12-second (block-level) resolution.
    * **Key Output**: Tracks **Intra-block Price Ranges** and identifies the "Smoking Gun" blocks where deviation exceeded -10%.

### 2. Liquidity & Execution Characterization
* **`Volume Profile___ Slippage Sensitivity.ipynb`**
    * **Objective**: Investigates the depth of the order book during the crash.
    * **Key Output**: **Volume Profile** (Price vs. Density) and recovery curve analysis. It proves whether the crash was driven by thin liquidity or systemic selling.


### 3. Position-Level Risk Tracking
* **`Whale LTV Tracker.ipynb`**
    * **Objective**: Real-time monitoring of top collateralized positions.
    * **Key Output**: 15-second interval **Loan-to-Value (LTV)** trajectory, identifying how close major borrowers came to the 83% Liquidation Threshold.

### 4. Systemic Stress Testing
* **`Liquidation Waterfall.ipynb`**
    * **Objective**: A predictive "What-If" model for cascading failures.
    * **Key Output**: The **Liquidation Cliff**—calculates the cumulative USD volume of debt that would be liquidated at various price drop increments.
* **`Price Sweep (abandoned).ipynb`**
    * **Objective**: (Experimental) Systematic sweep of price impacts across the USDT/WBTC market to detect cross-asset contagion.

---

## 🛠️ Technical Implementation Details

### Time-Format Normalization
All notebooks include a custom pre-processing engine to resolve the **Excel Timestamp Truncation Bug**. 
* **Correction Logic**: Truncated `MM:SS` strings are automatically reconstructed into ISO-8601 standard `YYYY-MM-DD HH:MM:SS` to ensure consistent chronological sorting across all time-series plots.

### Risk Metrics Defined

The core of our audit revolves around the **Health Factor ($HF$)** calculation:

$$HF = \frac{\sum_{i} (Collateral_{i} \times Price_{i} \times LT_{i})}{Total Debt_{USD}}$$

1.  **Basis Risk**: The % difference between the DEX Spot Price and the Aave Oracle Price.
2.  **Shadow HF**: The $HF$ calculated using the market's worst execution price instead of the smoothed Oracle price.
3.  **Safety Margin**: The distance between the current LTV and the Liquidation Threshold ($LT$).


[Image of a financial risk assessment matrix]


---

## 🚀 How to Reproduce the Analysis
1.  Ensure all `.csv` files are present in the project root or the specified data path.
2.  Install requirements: 
    ```bash
    pip install pandas matplotlib seaborn numpy
    ```
3.  Run the notebooks in sequence to generate the Audit Report visualizations.

# Aave-V3-Risk-Deep-Dive
# 🛡️ DeFi Audit Portfolio: Aave V3 Resilience Analysis (BTC/USD Flash Crash)

On 24th Dec, 2025, a localized flash crash on Binance saw BTC/USD1 drop to **$24,111 (-72.15%)** in seconds.

This portfolio presents a high-frequency forensic audit of the **Aave V3 Protocol** during the violent BTC/USD liquidity shock on **December 24, 2025 (17:19:18 UTC)**. 

The project demonstrates a full-stack data engineering and risk modeling workflow: from raw blockchain indexing (SQL) to automated risk characterization (Python/Jupyter).

---

### 🎯 Research Motivation & Background
As a student specialized in **Actuarial Science** with a **minor in Finance**, I am driven to apply rigorous quantitative frameworks to evaluate systemic risks in the decentralized finance (DeFi) ecosystem.

This project serves as my inaugural deep-dive into **Crypto-native Risk Management**. By integrating **Actuarial Ruin Theory** ~~(Monte Carlo Solvency simulations)~~ with **Financial Market Microstructure** (L2 Liquidity & Slippage analysis), I aim to quantify the robustness of Aave V3 during extreme volatility events like the Dec 24 flash crash.

---

## 📉 Case Study: The 18-Second Window
On Dec 24, 2025, BTC experienced a flash crash on decentralized exchanges, with spot prices diverging significantly from centralized feeds.

* **Incident Timestamp**: 2025-12-24 17:19:18 UTC
* **Key Block**: #24081542
* **Market Spot Low**: **$85,858.59** (Captured in `Sheet4.csv`)
* **Oracle Reference**: **$98,420.00** (Base price during incident)
* **Max Basis Risk**: **-12.76%** (The "Shadow" deviation recorded in `Sheet6.csv`)
* **Liquidation Outcome**: **Zero (0)**. The protocol’s safety filters successfully mitigated the shock.

---

## 🛠️ Repository Structure

| Directory | Purpose | Key Contents |
| :--- | :--- | :--- |
| [**`/sql_scripts`**](./sql_scripts) | **Data Extraction** | High-frequency SQL queries (Flipside/Snowflake) to index block-level DEX swaps. |
| [**`/data`**](./data) | **Evidence Storage** | Raw and aggregated CSV datasets capturing every trade and block metric during the crash. |
| [**`/analysis`**](./analysis) | **Risk Characterization** | Jupyter Notebooks calculating Shadow Health Factors, LTV Trajectories, and Liquidation Waterfalls. |

---

## 🔬 Audit Methodology: 15s High-Frequency Sampling

Traditional 1-hour or 1-day price feeds fail to capture DeFi risks. This audit utilizes **Block-Level Sampling (~12.5s resolution)** to "stress test" the protocol.



### 1. The Shadow Health Factor ($HF_{Shadow}$)
We benchmark the protocol's reported safety against market reality by calculating the **Shadow Health Factor**:

$$HF_{Shadow} = \frac{\sum (Collateral_{i} \times Price_{Spot} \times LT_{i})}{Total Debt_{USD}}$$

This metric reveals the "Hidden Risk" when Oracles lag behind aggressive market sell-offs.

### 2. Basis Risk Quantization
By comparing the **DEX Spot Price** ($P_{DEX}$) with the **Aave Oracle Price** ($P_{Oracle}$), we quantify the **Basis Risk**:
$$Basis\ Risk\ \% = \frac{P_{DEX} - P_{Oracle}}{P_{Oracle}} \times 100\%$$



---

## 🚀 Key Forensic Insights

1.  **Market Chaos**: Individual swap distributions (found in `/analysis`) prove that BTC hit a local low of **$85,858** while the Oracle remained static at **$98,420**.
2.  **Oracle Shield**: The audit confirms that Aave’s 15-second smoothing filter successfully ignored the "outlier trades," preventing a potential **$125M erroneous liquidation cascade**.
3.  **Liquidation Resilience**: Even at the absolute market bottom, major whale positions maintained a **Safety Margin of >7%** above their Liquidation Thresholds.

---

## 💻 Tech Stack
* **SQL**: Blockchain Indexing (Flipside Crypto, Ethereum Mainnet)
* **Python**: Data Forensic (Pandas, Numpy)
* **Visualization**: Risk Modeling (Matplotlib, Seaborn)
* **Documentation**: Financial Audit Standards (Markdown, LaTeX)

---

## 📧 Contact & Verification
All data and transaction hashes (`Tx Hash`) provided in the [`/data`](./data) folder are verifiable on **Etherscan.io** using the corresponding Ethereum block numbers.

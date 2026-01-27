/* AUDIT TASK: Block-Level BTC Price Analysis (15s Resolution)
   OBJECTIVE: Capture the actual trading price of WBTC (Bitcoin) on-chain 
              at the exact moment of the flash crash.
   RATIONALE: WBTC is the core collateral. This query extracts the 'Market Reality' 
              to compare against the Aave Oracle.
*/

SELECT 
    BLOCK_NUMBER,
    BLOCK_TIMESTAMP,
    -- Calculate the BTC price in USD from the swap data
    CASE 
        WHEN SYMBOL_IN = 'WBTC' THEN AMOUNT_IN_USD / NULLIF(AMOUNT_IN, 0)
        WHEN SYMBOL_OUT = 'WBTC' THEN AMOUNT_OUT_USD / NULLIF(AMOUNT_OUT, 0)
    END AS BTC_SPOT_PRICE_USD,
    TX_HASH,
    PLATFORM,
    -- Added help columns to verify it's the right asset
    SYMBOL_IN,
    SYMBOL_OUT
FROM ethereum.defi.ez_dex_swaps
WHERE (SYMBOL_IN = 'WBTC' OR SYMBOL_OUT = 'WBTC')
  -- Filter for major DEXs to ensure high-quality price data
  AND PLATFORM IN ('uniswap-v2', 'uniswap-v3', 'sushiswap')
  -- Target: Block 24081538 (Flash Crash Incident)
  AND BLOCK_NUMBER <= 24081538 
  AND BLOCK_NUMBER >= 24081538 - 200 -- Scan a wider window for volatility trends
ORDER BY BLOCK_NUMBER DESC
LIMIT 50
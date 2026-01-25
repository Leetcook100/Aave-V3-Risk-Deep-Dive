/* AUDIT TASK: Block-Level DEX Price Analysis (15s Resolution)
   OBJECTIVE: Capture the actual trading price of ETH on-chain 
              at the exact moment of the flash crash.
   RATIONALE: If the Oracle is silent, the DEX price represents 
              the 'Market Reality' that auditors use for benchmarking.
*/

SELECT 
    BLOCK_NUMBER,
    BLOCK_TIMESTAMP,
    -- Calculate the price from the swap amount (Amount_USD / Amount_Tokens)
    CASE 
        WHEN SYMBOL_IN = 'WETH' THEN AMOUNT_IN_USD / AMOUNT_IN
        WHEN SYMBOL_OUT = 'WETH' THEN AMOUNT_OUT_USD / AMOUNT_OUT
    END AS ETH_SPOT_PRICE_USD,
    TX_HASH,
    PLATFORM
FROM ethereum.defi.ez_dex_swaps
WHERE (SYMBOL_IN = 'WETH' OR SYMBOL_OUT = 'WETH')
  -- Focus on major DEXs for accurate pricing
  AND PLATFORM IN ('uniswap-v2', 'uniswap-v3', 'sushiswap')
  -- Target the exact block from your incident
  AND BLOCK_NUMBER <= 24081538 
  AND BLOCK_NUMBER >= 24081538 - 100 -- Scan about 20 minutes before
ORDER BY BLOCK_NUMBER DESC
LIMIT 20

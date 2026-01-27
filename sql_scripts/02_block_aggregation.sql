/* Extended BTC/USD Price Analysis: 30-minute window around block 24081538
   OBJECTIVE: Detect anomalies, flash crash patterns, or unusual volatility in WBTC.
   RATIONALE: Uses block-level aggregation to characterize market reality.
*/

WITH block_prices AS (
    SELECT 
        BLOCK_NUMBER,
        BLOCK_TIMESTAMP,
        -- Calculate the BTC price (WBTC/USD)
        CASE 
            WHEN SYMBOL_IN = 'WBTC' THEN AMOUNT_IN_USD / NULLIF(AMOUNT_IN, 0)
            WHEN SYMBOL_OUT = 'WBTC' THEN AMOUNT_OUT_USD / NULLIF(AMOUNT_OUT, 0)
        END AS BTC_PRICE_USD,
        AMOUNT_IN_USD + AMOUNT_OUT_USD AS swap_volume_usd,
        PLATFORM,
        TX_HASH
    FROM ethereum.defi.ez_dex_swaps
    WHERE (SYMBOL_IN = 'WBTC' OR SYMBOL_OUT = 'WBTC')
      AND PLATFORM IN ('uniswap-v2', 'uniswap-v3', 'sushiswap')
      -- 30-minute window around the crash block
      AND BLOCK_NUMBER BETWEEN 24081388 AND 24081688 
)
SELECT 
    BLOCK_NUMBER,
    BLOCK_TIMESTAMP,
    COUNT(*) as swap_count,
    AVG(BTC_PRICE_USD) as avg_price,
    MIN(BTC_PRICE_USD) as min_price,
    MAX(BTC_PRICE_USD) as max_price,
    STDDEV(BTC_PRICE_USD) as price_stddev,
    SUM(swap_volume_usd) as total_volume_usd,
    -- Adjusted volatility thresholds for BTC (Current Price ~$98k)
    CASE 
        -- If price range within a single 12s block > $2,000 (approx 2% move)
        WHEN MAX(BTC_PRICE_USD) - MIN(BTC_PRICE_USD) > 2000 THEN 'EXTREME_CRASH_VOLATILITY'
        -- If price range > $1,000 (approx 1% move)
        WHEN MAX(BTC_PRICE_USD) - MIN(BTC_PRICE_USD) > 1000 THEN 'HIGH_VOLATILITY'
        -- If Standard Deviation is high
        WHEN STDDEV(BTC_PRICE_USD) > 500 THEN 'ELEVATED_VOLATILITY'
        ELSE 'NORMAL'
    END as volatility_flag
FROM block_prices
WHERE BTC_PRICE_USD IS NOT NULL AND BTC_PRICE_USD > 0
GROUP BY BLOCK_NUMBER, BLOCK_TIMESTAMP
ORDER BY BLOCK_NUMBER DESC
LIMIT 100
/* Extended DEX Price Analysis: 30-minute window around block 24081538
   to detect any anomalies, flash crash patterns, or unusual volatility
*/

WITH block_prices AS (
    SELECT 
        BLOCK_NUMBER,
        BLOCK_TIMESTAMP,
        CASE 
            WHEN SYMBOL_IN = 'WETH' THEN AMOUNT_IN_USD / NULLIF(AMOUNT_IN, 0)
            WHEN SYMBOL_OUT = 'WETH' THEN AMOUNT_OUT_USD / NULLIF(AMOUNT_OUT, 0)
        END AS ETH_PRICE_USD,
        AMOUNT_IN_USD + AMOUNT_OUT_USD AS swap_volume_usd,
        PLATFORM,
        TX_HASH
    FROM ethereum.defi.ez_dex_swaps
    WHERE (SYMBOL_IN = 'WETH' OR SYMBOL_OUT = 'WETH')
      AND PLATFORM IN ('uniswap-v2', 'uniswap-v3', 'sushiswap')
      AND BLOCK_NUMBER BETWEEN 24081388 AND 24081688  -- ~150 blocks (~30 min window)
      AND ETH_PRICE_USD IS NOT NULL
      AND ETH_PRICE_USD > 0
)
SELECT 
    BLOCK_NUMBER,
    BLOCK_TIMESTAMP,
    COUNT(*) as swap_count,
    AVG(ETH_PRICE_USD) as avg_price,
    MIN(ETH_PRICE_USD) as min_price,
    MAX(ETH_PRICE_USD) as max_price,
    STDDEV(ETH_PRICE_USD) as price_stddev,
    SUM(swap_volume_usd) as total_volume_usd,
    -- Flag blocks with unusual price deviation
    CASE 
        WHEN MAX(ETH_PRICE_USD) - MIN(ETH_PRICE_USD) > 100 THEN 'HIGH_VOLATILITY'
        WHEN STDDEV(ETH_PRICE_USD) > 50 THEN 'ELEVATED_VOLATILITY'
        ELSE 'NORMAL'
    END as volatility_flag
FROM block_prices
GROUP BY BLOCK_NUMBER, BLOCK_TIMESTAMP
ORDER BY BLOCK_NUMBER DESC
LIMIT 50

/* Detailed view of blocks leading up to and including block 24081538
   to identify the exact flash crash moment
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
      AND BLOCK_NUMBER BETWEEN 24081438 AND 24081588  -- Focused 150-block window
      AND ETH_PRICE_USD IS NOT NULL
      AND ETH_PRICE_USD > 0
)
SELECT 
    BLOCK_NUMBER,
    BLOCK_TIMESTAMP,
    COUNT(*) as swap_count,
    ROUND(AVG(ETH_PRICE_USD), 2) as avg_price,
    ROUND(MIN(ETH_PRICE_USD), 2) as min_price,
    ROUND(MAX(ETH_PRICE_USD), 2) as max_price,
    ROUND(STDDEV(ETH_PRICE_USD), 2) as price_stddev,
    ROUND(MAX(ETH_PRICE_USD) - MIN(ETH_PRICE_USD), 2) as price_range,
    ROUND(SUM(swap_volume_usd), 2) as total_volume_usd,
    CASE 
        WHEN MAX(ETH_PRICE_USD) - MIN(ETH_PRICE_USD) > 100 THEN 'HIGH_VOLATILITY'
        WHEN STDDEV(ETH_PRICE_USD) > 50 THEN 'ELEVATED_VOLATILITY'
        ELSE 'NORMAL'
    END as volatility_flag,
    -- Calculate deviation from normal price (~2935)
    ROUND((MIN(ETH_PRICE_USD) - 2935) / 2935 * 100, 2) as min_price_deviation_pct
FROM block_prices
GROUP BY BLOCK_NUMBER, BLOCK_TIMESTAMP
ORDER BY BLOCK_NUMBER DESC
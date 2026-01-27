/* Detailed view of blocks leading up to and including block 24081538
    to identify the exact BTC/USD flash crash moment
*/

WITH block_prices AS (
    SELECT 
        BLOCK_NUMBER,
        BLOCK_TIMESTAMP,
        -- Calculate the BTC price (WBTC/USD) derived from swap amounts
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
      AND BLOCK_NUMBER BETWEEN 24081438 AND 24081588  -- Focused 150-block window
      AND BTC_PRICE_USD IS NOT NULL
      AND BTC_PRICE_USD > 0
)
SELECT 
    BLOCK_NUMBER,
    BLOCK_TIMESTAMP,
    COUNT(*) as swap_count,
    ROUND(AVG(BTC_PRICE_USD), 2) as avg_price,
    ROUND(MIN(BTC_PRICE_USD), 2) as min_price,
    ROUND(MAX(BTC_PRICE_USD), 2) as max_price,
    ROUND(STDDEV(BTC_PRICE_USD), 2) as price_stddev,
    ROUND(MAX(BTC_PRICE_USD) - MIN(BTC_PRICE_USD), 2) as price_range,
    ROUND(SUM(swap_volume_usd), 2) as total_volume_usd,
    -- Adjusted volatility thresholds for BTC high-value context
    CASE 
        WHEN MAX(BTC_PRICE_USD) - MIN(BTC_PRICE_USD) > 2000 THEN 'EXTREME_CRASH_VOLATILITY'
        WHEN MAX(BTC_PRICE_USD) - MIN(BTC_PRICE_USD) > 1000 THEN 'HIGH_VOLATILITY'
        WHEN STDDEV(BTC_PRICE_USD) > 500 THEN 'ELEVATED_VOLATILITY'
        ELSE 'NORMAL'
    END as volatility_flag,
    -- Calculate deviation from pre-crash benchmark (~$98,420)
    ROUND((MIN(BTC_PRICE_USD) - 98420) / 98420 * 100, 2) as min_price_deviation_pct
FROM block_prices
GROUP BY BLOCK_NUMBER, BLOCK_TIMESTAMP
ORDER BY BLOCK_NUMBER DESC
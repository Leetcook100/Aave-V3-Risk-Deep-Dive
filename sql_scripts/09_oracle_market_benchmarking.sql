/* Query: Standardized Market Prices (Alternative to Chainlink table)
   Objective: Get 1-minute granularity prices to verify against Oracle feeds.
*/

SELECT 
    minute,
    symbol,
    price
FROM prices.usd 
/* Use the timestamps from your block finding query */
WHERE minute >= TIMESTAMP '2025-12-24 09:10:00' 
  AND minute <= TIMESTAMP '2025-12-24 09:30:00'
  AND symbol IN ('WETH', 'WBTC', 'USDC')
  AND blockchain = 'ethereum'
ORDER BY minute DESC;

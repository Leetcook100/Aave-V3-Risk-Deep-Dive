/* AUDIT TASK: Block-Level Oracle Verification
   OBJECTIVE: Retrieve every individual Oracle update during the crash.
   SCHEMA: Based on verified 'chainlink.price_feeds' columns.
   RATIONALE: This table is EVENT-BASED, not hourly. It records every time 
              the Oracle pushed a new price to Ethereum.
*/

SELECT 
    block_number,
    block_time,
    -- Column 'oracle_price' from your schema screenshot
    oracle_price AS eth_price_usd,
    base,
    quote
FROM chainlink.price_feeds 
/* Filter for Ethereum to ensure we are in the correct timeline */
WHERE blockchain = 'ethereum' 
  -- Ticker columns as seen in the Explorer
  AND base = 'ETH' 
  AND quote = 'USD' 
  -- Focusing on the critical 10-minute window of the crash
  AND block_time >= TIMESTAMP '2025-12-24 09:15:00'
  AND block_time <= TIMESTAMP '2025-12-24 09:25:00'
ORDER BY block_number DESC;

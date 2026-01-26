/* AUDIT TASK: Precise Oracle Verification at Crash Block
   OBJECTIVE: Retrieve the deterministic on-chain price at Block 24081538.
   TABLE: chainlink.price_feeds (Curated Dune Table)
   RATIONALE: We verify the 'oracle_price' column to prove the protocol's 
              insulation from sub-second exchange volatility.
*/

SELECT 
    block_number,
    block_time,
    -- Column 'price' is renamed to 'oracle_price' in this schema
    -- Since it is a 'double' type, division by 1e8 is typically not required.
    oracle_price AS eth_price_usd,
    base,
    quote
FROM chainlink.price_feeds 
/* Filtering by the exact block of the 18th-second incident */
WHERE block_number = 24081538
  -- Targeting the ETH/USD feed directly via human-readable symbols
  AND base = 'ETH'
  AND quote = 'USD'

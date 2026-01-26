SELECT 
    * FROM aave_v3_ethereum.Pool_evt_Borrow
WHERE evt_block_number BETWEEN 24081538 - 7200 AND 24081538 
AND reserve = 0xdac17f958d2ee523a2206206994597c13d831ec7
LIMIT 100

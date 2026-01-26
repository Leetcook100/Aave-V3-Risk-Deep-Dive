/* Query: Identification of Representative Collateral Tokens 
  Objective: To determine which tokens back the majority of USDT debt 
  for characterization of liquidation risk during the price crash.
*/

WITH usdt_borrowers AS (
    /* Step 1: Isolate all unique user addresses with active USDT debt at the crash block */
    SELECT DISTINCT "onBehalfOf" AS user_address
    FROM aave_v3_ethereum.Pool_evt_Borrow
    WHERE "reserve" = 0xdac17f958d2ee523a2206206994597c13d831ec7 -- USDT reserve address
    AND evt_block_number <= 24081538
),

collateral_balances AS (
    /* Step 2: Aggregate collateral balances across all identified USDT borrowers */
    SELECT 
        s."reserve" AS asset_address,
        SUM(s.amount) AS raw_amount
    FROM aave_v3_ethereum.Pool_evt_Supply s
    JOIN usdt_borrowers b ON s."onBehalfOf" = b.user_address
    WHERE s.evt_block_number <= 24081538
    GROUP BY 1
)

/* Step 3: Map hex addresses to token names and normalize by decimals */
SELECT 
    CASE 
        WHEN asset_address = 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2 THEN 'WETH'
        WHEN asset_address = 0x2260fac5e5542a773aa44fbcfedf7c193bc2c599 THEN 'WBTC'
        WHEN asset_address = 0x4c9edd5852cd905f086c759e8383e09bff1e68b3 THEN 'weETH'
        WHEN asset_address = 0x7f39c581f595b53c5cb19bd0b3f8da6c935e2ca0 THEN 'wstETH'
        WHEN asset_address = 0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48 THEN 'USDC'
        ELSE 'Other/Dust Assets' 
    END AS representative_token,
    
    /* Calculate the aggregate volume to rank token dominance */
    ROUND(SUM(raw_amount) / 
        CASE 
            WHEN asset_address = 0x2260fac5e5542a773aa44fbcfedf7c193bc2c599 THEN 1e8 -- WBTC decimals
            WHEN asset_address IN (0xdac17f958d2ee523a2206206994597c13d831ec7, 0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48) THEN 1e6 -- USDT/USDC decimals
            ELSE 1e18 -- Standard ETH-based decimals
        END, 2) AS aggregate_collateral_volume

FROM collateral_balances
GROUP BY 1, asset_address
ORDER BY aggregate_collateral_volume DESC;

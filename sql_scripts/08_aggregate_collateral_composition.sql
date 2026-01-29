Query Identification of Representative Collateral Value (Fixed Aggregation)
   Objective Calculate the NET USD value of collateral for active USDT borrowers.
   Fix Calculated USD values at the address level before aggregating by category.


WITH active_usdt_borrowers AS (
     Step 1 Identify users who actually owe USDT 
    SELECT user_address
    FROM (
        SELECT onBehalfOf AS user_address, SUM(amount)  1e6 AS amount FROM aave_v3_ethereum.Pool_evt_Borrow 
        WHERE reserve = 0xdac17f958d2ee523a2206206994597c13d831ec7 AND evt_block_number = 24081538 GROUP BY 1
        UNION ALL
        SELECT user AS user_address, -SUM(amount)  1e6 AS amount FROM aave_v3_ethereum.Pool_evt_Repay 
        WHERE reserve = 0xdac17f958d2ee523a2206206994597c13d831ec7 AND evt_block_number = 24081538 GROUP BY 1
        UNION ALL
        SELECT user AS user_address, -SUM(debtToCover)  1e6 AS amount FROM aave_v3_ethereum.Pool_evt_LiquidationCall 
        WHERE debtAsset = 0xdac17f958d2ee523a2206206994597c13d831ec7 AND evt_block_number = 24081538 GROUP BY 1
    ) t
    GROUP BY 1
    HAVING SUM(amount)  0 
),

net_collateral_values AS (
     Step 2 Calculate Net Volume and USD Value PER ADDRESS first 
    SELECT 
        asset_address,
        SUM(net_amount) AS total_raw_balance,
         Perform the math here while we still have the specific asset_address 
        SUM(net_amount)  POWER(10, 
            CASE 
                WHEN asset_address = 0x2260fac5e5542a773aa44fbcfedf7c193bc2c599 THEN 8
                WHEN asset_address IN (0xdac17f958d2ee523a2206206994597c13d831ec7, 0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48) THEN 6
                ELSE 18 
            END) AS scaled_volume,
        (SUM(net_amount)  POWER(10, 
            CASE 
                WHEN asset_address = 0x2260fac5e5542a773aa44fbcfedf7c193bc2c599 THEN 8
                WHEN asset_address IN (0xdac17f958d2ee523a2206206994597c13d831ec7, 0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48) THEN 6
                ELSE 18 
            END))  CASE 
                WHEN asset_address = 0x2260fac5e5542a773aa44fbcfedf7c193bc2c599 THEN 90000 
                WHEN asset_address IN (0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2, 0x4c9edd5852cd905f086c759e8383e09bff1e68b3, 0x7f39c581f595b53c5cb19bd0b3f8da6c935e2ca0) THEN 3000  ETH price set to $3k 
                ELSE 1 
            END AS usd_value
    FROM (
        SELECT onBehalfOf AS user_address, reserve AS asset_address, amount AS net_amount FROM aave_v3_ethereum.Pool_evt_Supply WHERE evt_block_number = 24081538
        UNION ALL
        SELECT user AS user_address, reserve, -amount AS net_amount FROM aave_v3_ethereum.Pool_evt_Withdraw WHERE evt_block_number = 24081538
        UNION ALL
        SELECT user AS user_address, collateralAsset, -liquidatedCollateralAmount FROM aave_v3_ethereum.Pool_evt_LiquidationCall WHERE evt_block_number = 24081538
    ) s
    JOIN active_usdt_borrowers b ON s.user_address = b.user_address
    GROUP BY 1
)

 Step 3 Aggregate by Category 
SELECT 
    CASE 
        WHEN asset_address = 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2 THEN 'WETH'
        WHEN asset_address = 0x2260fac5e5542a773aa44fbcfedf7c193bc2c599 THEN 'WBTC'
        WHEN asset_address = 0x4c9edd5852cd905f086c759e8383e09bff1e68b3 THEN 'weETH'
        WHEN asset_address = 0x7f39c581f595b53c5cb19bd0b3f8da6c935e2ca0 THEN 'wstETH'
        WHEN asset_address = 0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48 THEN 'USDC'
        ELSE 'OtherMinor Assets' 
    END AS representative_token,
    ROUND(SUM(scaled_volume), 2) AS aggregate_net_volume,
    ROUND(SUM(usd_value), 2) AS estimated_usd_value
FROM net_collateral_values
GROUP BY 1
ORDER BY 3 DESC;

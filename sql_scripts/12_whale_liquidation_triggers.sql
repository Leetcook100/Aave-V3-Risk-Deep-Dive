/* Query: 12_whale_liquidation_triggers.sql
   Objective: Calculate precise Liquidation Trigger Prices for the Top 50 Whales.
   
   Audit Enhancements:
   1. REAL-TIME SOLVENCY: Uses Net Debt (Borrows - Repays - Liquidations).
   2. DUST FILTER: Returns 0 if an asset contributes < 1% to the account's safety, 
      eliminating "mathematical ghost" prices (the trillion-dollar errors).
   3. BAD DEBT IDENTIFICATION: Explicitly flags accounts that are already 
      underwater (HF < 1.0) instead of showing theoretical prices.
   4. BENCHMARKS: ETH @ $3,000, BTC @ $90,000.
*/

WITH user_net_debt AS (
    -- Step 1: Calculate actual outstanding USDT debt (Net Position)
    SELECT 
        "user_address",
        SUM("net_change") AS "current_net_debt"
    FROM (
        SELECT "onBehalfOf" AS "user_address", SUM("amount") / 1e6 AS "net_change" 
        FROM aave_v3_ethereum.Pool_evt_Borrow 
        WHERE "reserve" = 0xdac17f958d2ee523a2206206994597c13d831ec7 AND "evt_block_number" <= 24081538 GROUP BY 1
        UNION ALL
        SELECT "user" AS "user_address", -SUM("amount") / 1e6 AS "net_change" 
        FROM aave_v3_ethereum.Pool_evt_Repay 
        WHERE "reserve" = 0xdac17f958d2ee523a2206206994597c13d831ec7 AND "evt_block_number" <= 24081538 GROUP BY 1
        UNION ALL
        SELECT "user" AS "user_address", -SUM("debtToCover") / 1e6 AS "net_change" 
        FROM aave_v3_ethereum.Pool_evt_LiquidationCall 
        WHERE "debtAsset" = 0xdac17f958d2ee523a2206206994597c13d831ec7 AND "evt_block_number" <= 24081538 GROUP BY 1
    ) combined
    GROUP BY 1
    HAVING SUM("net_change") > 1000 -- Focus on non-trivial debt
),

active_whales AS (
    -- Step 2: Sample Top 50 Whales (representing ~64% of total USDT debt)
    SELECT "user_address", "current_net_debt" 
    FROM user_net_debt
    ORDER BY 2 DESC 
    LIMIT 50
),

net_collateral AS (
    -- Step 3: Calculate net collateral balances per asset with correct decimals
    SELECT 
        w."user_address",
        c."asset_address",
        SUM(c."net_amount") / POWER(10, CASE 
            WHEN c."asset_address" = 0x2260fac5e5542a773aa44fbcfedf7c193bc2c599 THEN 8 -- WBTC
            WHEN c."asset_address" IN (0xdac17f958d2ee523a2206206994597c13d831ec7, 0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48) THEN 6 -- USDT/USDC
            ELSE 18 END) AS "token_amount",
        CASE 
            WHEN c."asset_address" = 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2 THEN 0.825 -- WETH
            WHEN c."asset_address" = 0x2260fac5e5542a773aa44fbcfedf7c193bc2c599 THEN 0.75  -- WBTC
            WHEN c."asset_address" = 0x4c9edd5852cd905f086c759e8383e09bff1e68b3 THEN 0.80  -- weETH
            WHEN c."asset_address" = 0x7f39c581f595b53c5cb19bd0b3f8da6c935e2ca0 THEN 0.81  -- wstETH
            ELSE 0.75 END AS "lt"
    FROM (
        SELECT "onBehalfOf" AS "user_address", "reserve" AS "asset_address", "amount" AS "net_amount" FROM aave_v3_ethereum.Pool_evt_Supply WHERE "evt_block_number" <= 24081538
        UNION ALL
        SELECT "user" AS "user_address", "reserve", -"amount" FROM aave_v3_ethereum.Pool_evt_Withdraw WHERE "evt_block_number" <= 24081538
        UNION ALL
        SELECT "user" AS "user_address", "collateralAsset", -"liquidatedCollateralAmount" FROM aave_v3_ethereum.Pool_evt_LiquidationCall WHERE "evt_block_number" <= 24081538
    ) c
    JOIN active_whales w ON c."user_address" = w."user_address"
    GROUP BY 1, 2, 4
),

whale_stats AS (
    -- Step 4: Aggregate weighted components for the Health Factor formula
    SELECT 
        "user_address",
        SUM(CASE WHEN "asset_address" IN (0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2, 0x4c9edd5852cd905f086c759e8383e09bff1e68b3, 0x7f39c581f595b53c5cb19bd0b3f8da6c935e2ca0) 
            THEN "token_amount" * "lt" ELSE 0 END) AS "eth_weighted_factor",
        SUM(CASE WHEN "asset_address" = 0x2260fac5e5542a773aa44fbcfedf7c193bc2c599 
            THEN "token_amount" * "lt" ELSE 0 END) AS "btc_weighted_factor",
        SUM(CASE WHEN "asset_address" NOT IN (0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2, 0x4c9edd5852cd905f086c759e8383e09bff1e68b3, 0x7f39c581f595b53c5cb19bd0b3f8da6c935e2ca0, 0x2260fac5e5542a773aa44fbcfedf7c193bc2c599) 
            THEN "token_amount" * "lt" ELSE 0 END) AS "stable_weighted_collateral"
    FROM net_collateral
    GROUP BY 1
)

-- Final Audit Output: Liquidation Sensitivity Analysis
SELECT 
    w."user_address",
    w."current_net_debt" AS "outstanding_debt_usdt",
    ROUND((s."eth_weighted_factor" * 3000 + s."btc_weighted_factor" * 90000 + s."stable_weighted_collateral") / w."current_net_debt", 2) AS "current_hf",
    
    -- ETH Price Trigger with Bad Debt Safeguard
    CASE 
        WHEN (s."eth_weighted_factor" * 3000 + s."btc_weighted_factor" * 90000 + s."stable_weighted_collateral") / w."current_net_debt" < 1.0 THEN 999999 -- Already Liquidatable
        WHEN (s."eth_weighted_factor" * 3000) / w."current_net_debt" < 0.01 THEN 0 -- Dust Asset Filter
        ELSE GREATEST(0, ROUND((w."current_net_debt" - s."stable_weighted_collateral" - s."btc_weighted_factor" * 90000) / NULLIF(s."eth_weighted_factor", 0), 2))
    END AS "eth_liquidation_price",
    
    -- BTC Price Trigger with Bad Debt Safeguard
    CASE 
        WHEN (s."eth_weighted_factor" * 3000 + s."btc_weighted_factor" * 90000 + s."stable_weighted_collateral") / w."current_net_debt" < 1.0 THEN 999999 -- Already Liquidatable
        WHEN (s."btc_weighted_factor" * 90000) / w."current_net_debt" < 0.01 THEN 0 -- Dust Asset Filter
        ELSE GREATEST(0, ROUND((w."current_net_debt" - s."stable_weighted_collateral" - s."eth_weighted_factor" * 3000) / NULLIF(s."btc_weighted_factor", 0), 2))
    END AS "btc_liquidation_price"

FROM active_whales w
JOIN whale_stats s ON w."user_address" = s."user_address"
ORDER BY 2 DESC;

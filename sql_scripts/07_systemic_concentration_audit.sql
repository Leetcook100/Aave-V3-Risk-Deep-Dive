WITH user_net_debt AS (
    -- Step 1: Calculate current net debt for ALL users
    SELECT 
        user_address,
        SUM(net_change) AS current_outstanding_debt
    FROM (
        -- Borrows (+)
        SELECT "onBehalfOf" AS user_address, SUM(amount) / 1e6 AS net_change
        FROM aave_v3_ethereum.Pool_evt_Borrow
        WHERE "reserve" = 0xdac17f958d2ee523a2206206994597c13d831ec7 -- USDT
        AND evt_block_number <= 24081538
        GROUP BY 1
        
        UNION ALL
        
        -- Repays (-)
        SELECT "user" AS user_address, -SUM(amount) / 1e6 AS net_change
        FROM aave_v3_ethereum.Pool_evt_Repay
        WHERE "reserve" = 0xdac17f958d2ee523a2206206994597c13d831ec7 -- USDT
        AND evt_block_number <= 24081538
        GROUP BY 1

        UNION ALL
        
        -- Liquidations (-)
        SELECT "user" AS user_address, -SUM(debtToCover) / 1e6 AS net_change
        FROM aave_v3_ethereum.Pool_evt_LiquidationCall
        WHERE "debtAsset" = 0xdac17f958d2ee523a2206206994597c13d831ec7 -- USDT
        AND evt_block_number <= 24081538
        GROUP BY 1
    ) combined
    GROUP BY 1
    HAVING SUM(net_change) > 0 
),

protocol_total AS (
    -- Step 2: Total Market Size
    SELECT SUM(current_outstanding_debt) AS total_protocol_debt
    FROM user_net_debt
),

top_50_sum AS (
    -- Step 3: Top 50 Whales Aggregate
    SELECT SUM(current_outstanding_debt) AS top_50_debt
    FROM (
        SELECT current_outstanding_debt
        FROM user_net_debt
        ORDER BY current_outstanding_debt DESC
        LIMIT 50 -- Expanded to 50
    ) t50
)

-- Step 4: Final Assessment
SELECT 
    p.total_protocol_debt AS global_usdt_debt,
    t.top_50_debt AS whales_50_debt,
    ROUND((t.top_50_debt / p.total_protocol_debt) * 100, 2) AS top_50_ratio_percentage,
    CASE 
        WHEN (t.top_50_debt / p.total_protocol_debt) >= 0.80 THEN 'Pareto Standard Met (Top 50)'
        WHEN (t.top_50_debt / p.total_protocol_debt) >= 0.60 THEN 'High Concentration'
        ELSE 'Strongly Distributed (Requires Group Analysis)'
    END AS audit_verdict
FROM protocol_total p, top_50_sum t;

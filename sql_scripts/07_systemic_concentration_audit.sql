WITH total_market AS (
    -- Step 1: Calculate the entire protocol's USDT debt at the specific block
    SELECT 
        'Aave V3 Ethereum' AS market,
        SUM(amount) / 1e6 AS total_protocol_usdt_debt
    FROM aave_v3_ethereum.Pool_evt_Borrow
    WHERE "reserve" = 0xdac17f958d2ee523a2206206994597c13d831ec7 -- USDT
    AND evt_block_number <= 24081538
),

top_10_debt AS (
    -- Step 2: Sum the debt of the Top 10 largest borrowers only
    SELECT 
        SUM(whale_debt) AS top_10_total_debt
    FROM (
        SELECT 
            "onBehalfOf",
            SUM(amount) / 1e6 AS whale_debt
        FROM aave_v3_ethereum.Pool_evt_Borrow
        WHERE "reserve" = 0xdac17f958d2ee523a2206206994597c13d831ec7
        AND evt_block_number <= 24081538
        GROUP BY 1
        ORDER BY 2 DESC
        LIMIT 10
    ) t
)

-- Step 3: Pareto Comparison
SELECT 
    m.total_protocol_usdt_debt,
    t.top_10_total_debt,
    ROUND(t.top_10_total_debt, 2) AS top_10_debt_display,
    ROUND((t.top_10_total_debt / m.total_protocol_usdt_debt) * 100, 2) AS pareto_ratio_percentage,
    -- Add a descriptive label for the report
    CASE 
        WHEN (t.top_10_total_debt / m.total_protocol_usdt_debt) >= 0.80 THEN 'High Concentration (Pareto Confirmed)'
        ELSE 'Distributed Risk'
    END AS risk_characterization
FROM total_market m, top_10_debt t;

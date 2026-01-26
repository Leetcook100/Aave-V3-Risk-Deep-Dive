WITH top_debtors AS (
    SELECT 
        "onBehalfOf" AS user_address,
        SUM(amount) / 1e6 AS total_borrowed_usdt
    FROM aave_v3_ethereum.Pool_evt_Borrow
    WHERE evt_block_number BETWEEN 24081538 - 7200 AND 24081538
    AND "reserve" = 0xdac17f958d2ee523a2206206994597c13d831ec7 -- USDT
    GROUP BY 1
    ORDER BY 2 DESC
    LIMIT 10
)

SELECT 
    CASE 
        WHEN s."onBehalfOf" = 0x85e05c10db73499fbdecab0dfbb794a446feeec8 THEN 'Whale #1 (ETH Giant)'
        WHEN s."onBehalfOf" = 0xfaf1358fe6a9fa29a169dfc272b14e709f54840f THEN 'Whale #2 (Core Depositor)'
        WHEN s."onBehalfOf" = 0xe5c248d8d3f3871bd0f68e9c4743459c43bb4e4c THEN 'Whale #3 (Tier-1 Holder)'
        WHEN s."onBehalfOf" = 0xa7c624014699a8b537cc4b326eb65f00852ee2a3 THEN 'Whale #4 (Liquidity Provider)'
        WHEN s."onBehalfOf" = 0x4444ee1efbcfc7716754d4df119a1dbbe29934b3 THEN 'Whale #5 (Yield Arbitrager)'
        ELSE 'Top 10 Borrower' 
    END AS whale_nickname,

    CASE 
        WHEN s."reserve" = 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2 THEN 'WETH'
        WHEN s."reserve" = 0x2260fac5e5542a773aa44fbcfedf7c193bc2c599 THEN 'WBTC'
        WHEN s."reserve" = 0x4c9edd5852cd905f086c759e8383e09bff1e68b3 THEN 'weETH'
        WHEN s."reserve" = 0x7f39c581f595b53c5cb19bd0b3f8da6c935e2ca0 THEN 'wstETH'
        WHEN s."reserve" = 0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48 THEN 'USDC'
        ELSE 'Other' 
    END AS asset_name,

    -- Use the EXACT 80% / 82.5% figures I verified
    CASE 
        WHEN s."reserve" = 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2 THEN 0.825 -- WETH
        WHEN s."reserve" = 0x2260fac5e5542a773aa44fbcfedf7c193bc2c599 THEN 0.75  -- WBTC
        WHEN s."reserve" = 0x4c9edd5852cd905f086c759e8383e09bff1e68b3 THEN 0.80  -- weETH (The one I checked)
        WHEN s."reserve" = 0x7f39c581f595b53c5cb19bd0b3f8da6c935e2ca0 THEN 0.81  -- wstETH
        ELSE 0.75 -- Conservative floor
    END AS liquidation_threshold,

    -- Calculating the actual usage of their borrowing capacity
    t.total_borrowed_usdt AS current_debt_usdt,
    ROUND(SUM(s.amount) / 
        CASE 
            WHEN s."reserve" = 0x2260fac5e5542a773aa44fbcfedf7c193bc2c599 THEN 1e8 
            WHEN s."reserve" IN (0xdac17f958d2ee523a2206206994597c13d831ec7, 0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48) THEN 1e6 
            ELSE 1e18 
        END, 2) AS collateral_amount

FROM aave_v3_ethereum.Pool_evt_Supply s
JOIN top_debtors t ON s."onBehalfOf" = t.user_address
WHERE s.evt_block_number <= 24081538
GROUP BY 1, 2, 4, s."reserve", t.total_borrowed_usdt
ORDER BY t.total_borrowed_usdt DESC;

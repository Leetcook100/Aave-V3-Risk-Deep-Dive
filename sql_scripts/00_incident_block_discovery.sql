SELECT 
    number AS flash_crash_block,
    time
FROM ethereum.blocks
WHERE time >= CAST('2025-12-24 09:19:18' AS TIMESTAMP)
ORDER BY time ASC
LIMIT 1;


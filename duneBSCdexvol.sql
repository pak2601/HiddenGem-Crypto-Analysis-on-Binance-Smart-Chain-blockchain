WITH token_trades AS (
  SELECT
    t.token_bought_symbol AS token,
    t.token_bought_address AS address,
    t.block_time,
    t.tx_from,
    t.amount_usd,
    
    t.token_pair,
    t.tx_hash
  FROM dex.trades AS t
  WHERE
    blockchain = 'bnb'
    AND DATE_TRUNC('day', block_time) >= TRY_CAST('2025-01-01' AS DATE)
    AND NOT t.token_bought_symbol IS NULL
  UNION ALL
  SELECT
    token_sold_symbol AS token,
    token_sold_address AS address,
    block_time,
    tx_from,
    amount_usd,
    token_pair,
    tx_hash
  FROM dex.trades
  WHERE
    blockchain = 'bnb'
    AND DATE_TRUNC('day', block_time) >= TRY_CAST('2025-01-01' AS DATE)
    AND NOT token_sold_symbol IS NULL
), daily_price AS (
  SELECT
    symbol AS token,
    contract_address,
    DATE_TRUNC('day', minute) AS day,
    AVG(price) AS daily_price
  FROM prices.usd
  WHERE
    blockchain = 'bnb' AND minute >= TRY_CAST('2025-01-01' AS DATE)
  GROUP BY
    symbol,
    contract_address,
    DATE_TRUNC('day', minute)
  HAVING
    AVG(price) <> 0
), daily_stats AS (
  SELECT
    t.token,
    t.address AS contract_address,
    DATE_TRUNC('day', t.block_time) AS day,
    SUM(t.amount_usd) AS trading_volume,
    COUNT(DISTINCT t.token_pair) AS trading_pairs,
    COUNT(DISTINCT t.tx_from) AS total_traders,
    AVG(t.amount_usd) AS avg_trading_size,
    LAG(SUM(t.amount_usd), 1) OVER (PARTITION BY t.token ORDER BY DATE_TRUNC('day', t.block_time)) AS prev_volume
  FROM token_trades AS t
  GROUP BY
    1,
    2,
    3
), total_bsc_vol AS (
SELECT
    DATE_TRUNC('day', block_time) AS day,
    SUM(amount_usd) AS total_volume 
  FROM dex.trades
  WHERE
    blockchain = 'bnb'
    AND DATE_TRUNC('day', block_time) >= TRY_CAST('2025-01-01' AS DATE)
  GROUP BY
    DATE_TRUNC('day', block_time)
),
daily_stats_with_share AS (
SELECT
    ds.token,
    ds.contract_address,
    ds.day,
    ds.trading_volume,
    ds.trading_pairs,
    ds.total_traders,
    ds.avg_trading_size,
    ds.prev_volume,
    COALESCE((ds.trading_volume / tbv.total_volume * 100), 0) AS market_share
  FROM daily_stats AS ds
  JOIN total_bsc_vol AS tbv
    ON ds.day = tbv.day
)
SELECT
  ds.token,
  ds.contract_address,
  ds.day,
  ds.trading_volume,
  ds.trading_pairs,
  ds.total_traders,
  ds.avg_trading_size,
  COALESCE(dp.daily_price, 0) AS daily_price
FROM daily_stats_with_share AS ds
LEFT JOIN daily_price AS dp
  ON ds.contract_address = dp.contract_address AND ds.day = dp.day
WHERE
 ds.trading_volume >= 10000 AND dp.daily_price > 0 AND total_traders >= 2
ORDER BY
  ds.day,
  ds.trading_volume DESC


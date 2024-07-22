--голова и плечи
SELECT * FROM Ticker
    MATCH_RECOGNIZE (
        PARTITION BY symbol
        ORDER BY tstamp
            MEASURES
                FIRST(UP1.tstamp) AS UP1,
                FIRST(UP2.tstamp) AS UP2,
                FIRST(UP3.tstamp) AS UP3
        ONE ROW PER MATCH
        AFTER MATCH SKIP PAST LAST ROW
        PATTERN (STRT UP1+ DOWN+ UP2+ DOWN+ UP3+ DOWN+)
        DEFINE
            DOWN AS price < PREV(price),
            UP1 AS price > PREV(price),
            UP2 AS price > PREV(price) AND price > ALL(PREV(price),NEXT(price)),
            UP3 AS price > PREV(price)
        ) PATTERN
ORDER BY PATTERN.symbol, PATTERN.UP2;


















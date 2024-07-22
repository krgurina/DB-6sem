-- ALTER TABLE SERVICES ADD SERVISE_PRICE INT
-- COMMIT
select * from SERVICES;
select * from SERVICE_TYPES;


--предоставления услуг для каждого клиента на следующий год, увеличивая сумму предоставленных
--услуг на 5% каждый месяц от предыдущего для услуг определенного вида.
WITH OrderedServices AS (
    SELECT
        SERVICE_GUEST_ID,
        EXTRACT(YEAR FROM SERVICE_START_DATE) AS Year,
        EXTRACT(MONTH FROM SERVICE_START_DATE) AS Month,
        Sum(SERVISE_PRICE) AS sold_amount
    FROM
        SERVICES
    WHERE
        EXTRACT(YEAR FROM SERVICE_START_DATE) = 2023
    group by SERVICE_GUEST_ID, EXTRACT(YEAR FROM SERVICE_START_DATE), EXTRACT(MONTH FROM SERVICE_START_DATE)
)
SELECT
    SERVICE_GUEST_ID,
    Year,
    Month,
    sold_amount
from OrderedServices
MODEL
PARTITION BY (SERVICE_GUEST_ID)
DIMENSION BY (Month, Year)
measures (sold_amount)
rules (sold_amount[for Month from 1 to 12 increment  1,2025] = ceil(sold_amount[cv(), 2023]*1.05)
    )
order by Year, Month, SERVICE_GUEST_ID;

--ищем последовательность, начинающуюся с периода роста (STRT), за которым следует
--один или более периодов повышения цены (UP+), за которым следует один или более периодов понижения цены (DOWN+).
-- Рост, падение, рост предоставления для каждого вида услуг
SELECT *
FROM SERVICES
    MATCH_RECOGNIZE (
partition by SERVICE_TYPE_ID
ORDER BY SERVICE_START_DATE
MEASURES
    STRT.SERVICE_START_DATE AS start_period,
    FIRST(UP.SERVICE_START_DATE) AS highest_point_period,
    FIRST(DOWN.SERVICE_START_DATE) AS low_point_period,
    LAST(UP.SERVICE_START_DATE) AS highest2_point_period


ONE ROW PER MATCH
AFTER MATCH SKIP TO LAST UP
PATTERN (STRT UP+ DOWN+ UP+)
DEFINE
DOWN AS DOWN.SERVISE_PRICE < PREV (DOWN.SERVISE_PRICE),
UP AS UP.SERVISE_PRICE> PREV (UP.SERVISE_PRICE) ) MR
ORDER BY MR.SERVICE_TYPE_ID, MR.start_period;


















--только рост
SELECT *
FROM SERVICES
    MATCH_RECOGNIZE (
partition by SERVICE_TYPE_ID
ORDER BY SERVICE_START_DATE
MEASURES
    STRT.SERVICE_START_DATE AS start_period,
    LAST(UP.SERVICE_START_DATE) AS end_period
ONE ROW PER MATCH
PATTERN (STRT UP{2,} )
DEFINE
UP AS UP.SERVISE_PRICE> PREV (UP.SERVISE_PRICE) ) MR
ORDER BY MR.SERVICE_TYPE_ID, MR.start_period;


--только падение
SELECT *
FROM SERVICES
    MATCH_RECOGNIZE (
partition by SERVICE_TYPE_ID
ORDER BY SERVICE_START_DATE
MEASURES
    STRT.SERVICE_START_DATE AS start_period,
    LAST(DOWN.SERVICE_START_DATE) AS end_period
ONE ROW PER MATCH
PATTERN (STRT DOWN{2,} )
DEFINE
DOWN AS DOWN.SERVISE_PRICE < PREV (DOWN.SERVISE_PRICE)
 ) MR
ORDER BY MR.SERVICE_TYPE_ID, MR.start_period;











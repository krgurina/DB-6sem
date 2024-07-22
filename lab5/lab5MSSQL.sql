--3
-- Вычисление итогов предоставленных услуг для определенного 
-- клиаента помесячно, за квартал, за полгода, за год.
SELECT 
	S.service_id, ST.service_type_name,
    YEAR(service_start_date) AS year,
    MONTH(service_start_date) AS month,
    DATEPART(QUARTER, service_start_date) AS quarter,
    CASE WHEN MONTH(service_start_date) <= 6 THEN 1 ELSE 2 END AS half_year,
    SUM(service_type_daily_price) OVER (PARTITION BY YEAR(service_start_date), MONTH(service_start_date)) AS month_total,
    SUM(service_type_daily_price) OVER (PARTITION BY YEAR(service_start_date), DATEPART(QUARTER, service_start_date)) AS quarter_total,
    SUM(service_type_daily_price) OVER (PARTITION BY YEAR(service_start_date), CASE WHEN MONTH(service_start_date) <= 6 THEN 1 ELSE 2 END) AS half_year_total,
      --SUM(service_type_daily_price) OVER (PARTITION BY YEAR(service_start_date) RANGE INTERVAL '6' MONTH PRECEDING) AS half_year_total,
	SUM(service_type_daily_price) OVER (PARTITION BY YEAR(service_start_date)) AS yearly_total
FROM SERVICES S
INNER JOIN SERVICE_TYPES ST ON
S.service_type_id=ST.service_type_id
WHERE S.service_guest_id = 1
order by s.service_id;
--WHERE S.service_type_id = 1;



--4
-- Вычисление итогов предоставленных услуг для определенного вида услуги за период:
--•	объем услуг;
--•	сравнение их с общим объемом услуг (в %);
--•	сравнение с наибольшим объемом услуг (в %).
SELECT 
    S.service_id,
    ST.service_type_daily_price,
    S.service_start_date,
	SUM(ST.service_type_daily_price) OVER (PARTITION BY YEAR(S.service_start_date), MONTH(service_start_date)) AS monthly_total,
	SUM(ST.service_type_daily_price) OVER (PARTITION BY S.service_type_id) AS total_price,
	--	сравнение их с общим объемом услуг (в %);
	ROUND(CAST(SUM(ST.service_type_daily_price) OVER (PARTITION BY YEAR(S.service_start_date), MONTH(service_start_date)) AS FLOAT) / NULLIF(SUM(ST.service_type_daily_price) OVER (PARTITION BY S.service_type_id), 0), 2) *100 AS monthly_to_total,

	--	сравнение с наибольшим объемом услуг 
			ROUND(CAST(MAX(ST.service_type_daily_price) OVER (PARTITION BY S.service_type_id)  AS FLOAT) / NULLIF(SUM(ST.service_type_daily_price)OVER (PARTITION BY YEAR(S.service_start_date), MONTH(service_start_date)), 0), 2) *100 AS monthly_to_max,

		--ROUND(CAST(SUM(ST.service_type_daily_price) OVER (PARTITION BY YEAR(S.service_start_date), MONTH(service_start_date)) AS FLOAT) / NULLIF(MAX(ST.service_type_daily_price) OVER (PARTITION BY S.service_type_id), 0), 2) AS monthly_to_max,
--5.	Продемонстрируйте применение функции ранжирования ROW_NUMBER() для разбиения результатов запроса на страницы (по 20 строк на каждую страницу).
		ROW_NUMBER() OVER(ORDER BY S.service_id) AS ROW_NUM
FROM SERVICES S
INNER JOIN SERVICE_TYPES ST ON S.service_type_id = ST.service_type_id
WHERE S.service_type_id = 1 or S.service_type_id = 2;






delete from SERVICES where service_id=9




-- немного по-другому
DECLARE @start_date DATE = '2023-01-01';
DECLARE @end_date DATE = '2024-12-31';

WITH ServiceStats AS (
    SELECT
        s.service_type_id,
        COUNT(*) AS service_count,
        SUM(st.service_type_daily_price)  AS total_cost,
		ROUND(SUM(st.service_type_daily_price) / SUM(SUM(st.service_type_daily_price)) OVER () * 100, 2) AS percentage_total,        
		MAX(SUM(st.service_type_daily_price)) OVER () AS max_total_cost
    FROM
        SERVICES s
    JOIN SERVICE_TYPES st ON s.service_type_id = st.service_type_id
    WHERE s.service_start_date >= @start_date AND s.service_end_date <= @end_date
    GROUP BY s.service_type_id
)
SELECT
    ST.service_type_id,
    ST.service_type_name,
    SS.service_count,
    SS.total_cost,
    SS.percentage_total,
    SS.total_cost / SS.max_total_cost * 100 AS percentage_max
FROM ServiceStats SS
JOIN SERVICE_TYPES ST ON SS.service_type_id = ST.service_type_id;



---------------

--------------------

--5 применение функции ранжирования ROW_NUMBER() для разбиения 
-- результатов запроса на страницы (по 20 строк на каждую страницу).
WITH RankedServices AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY service_id) AS RowNum
    FROM SERVICES
)
SELECT * FROM RankedServices
WHERE RowNum BETWEEN 1 AND 20; 

--6
-- применение функции ранжирования ROW_NUMBER() для удаления дубликатов.
	INSERT INTO SERVICES2 (service_id, service_type_id, service_guest_id, service_start_date, service_end_date)
VALUES 
    (1, 1, 4, '2023-11-05', '2023-11-10'),
    (2, 1, 2, '2023-03-10', '2023-03-15'),
    (3, 1, 3, '2023-04-20', '2023-04-25');
select * from SERVICES2;

WITH RankedServices AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY service_id, service_type_id, service_guest_id, service_start_date, service_end_date ORDER BY service_id) AS RowNum
    FROM SERVICES2
)
DELETE FROM RankedServices
WHERE RowNum > 1; -- Удаление всех дубликатов кроме первого в каждой группе

select * from SERVICES2


--7 6 заказов
--Вернуть для каждого клиента общую стоимость услуг 
--за последние 6 месяцев помесячно.
WITH RankedServices AS (
    SELECT
        service_guest_id,
        service_type_id,
        ROW_NUMBER() OVER (PARTITION BY service_guest_id ORDER BY service_start_date DESC) AS RowNum
    FROM SERVICES)

SELECT	G.guest_name,
		G.guest_surname,
		SUM(ST.service_type_daily_price) AS total_cost_last_6_months
	FROM RankedServices RS
	JOIN GUESTS G ON RS.service_guest_id = G.guest_id
	JOIN SERVICE_TYPES ST ON RS.service_type_id = ST.service_type_id
		WHERE RowNum <= 6
		GROUP BY G.guest_name, G.guest_surname;



--8
-- Какой гость заказал наибольшее число услуг определенного типа? 
--Вернуть для всех услуг.
WITH GuestServiceCounts AS (
    SELECT	s.service_type_id,
			s.service_guest_id,
			COUNT(*) AS service_count,
			RANK() OVER (PARTITION BY s.service_type_id ORDER BY COUNT(*) DESC) AS service_rank
    FROM SERVICES s
    GROUP BY s.service_type_id, s.service_guest_id
)
SELECT	gs.service_type_id,
		gs.service_count,
		gs.service_guest_id,
		g.guest_name,
		g.guest_surname
FROM GuestServiceCounts gs
JOIN GUESTS g ON gs.service_guest_id = g.guest_id
WHERE gs.service_rank = 1;


--5






CREATE TABLE SERVICES2 (
    service_id INT,
    service_type_id INT NOT NULL,
    service_guest_id INT NOT NULL,
    service_start_date DATE NOT NULL,
    service_end_date DATE NOT NULL,
    FOREIGN KEY (service_type_id) REFERENCES SERVICE_TYPES(service_type_id) ON DELETE CASCADE,
    FOREIGN KEY (service_guest_id) REFERENCES GUESTS(guest_id) ON DELETE CASCADE
);
























--4


-- Вычисление итогов предоставленных услуг для определенного вида услуги за период:






--8 Какая услуга была предоставлена наибольшее число раз для определенного вида? Вернуть для всех клиентов.
WITH RankedServices AS (
    SELECT 
	S.service_guest_id,
        ST.service_type_name,
        S.service_type_id,
        COUNT(*) AS order_count,
        ROW_NUMBER() OVER (PARTITION BY S.service_type_id ORDER BY COUNT(*) DESC) AS ServiceRank
    FROM SERVICES S
    INNER JOIN SERVICE_TYPES ST ON S.service_type_id = ST.service_type_id
    GROUP BY S.service_guest_id, ST.service_type_name, S.service_type_id
)
SELECT 
service_guest_id,
    service_type_name,
    order_count
FROM RankedServices
WHERE ServiceRank = 1;










WITH RankedServices AS (
    SELECT 
        S.service_guest_id,
        ST.service_type_name,
        S.service_type_id,
        COUNT(*) AS order_count,
        ROW_NUMBER() OVER (PARTITION BY S.service_guest_id ORDER BY COUNT(*) DESC) AS ServiceRank
    FROM SERVICES S
    INNER JOIN SERVICE_TYPES ST ON S.service_type_id = ST.service_type_id
    GROUP BY S.service_guest_id, ST.service_type_name, S.service_type_id
)
SELECT 
    service_guest_id,
    service_type_name,
    order_count
FROM RankedServices
WHERE ServiceRank = 1;




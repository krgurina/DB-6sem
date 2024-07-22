--3
-- ¬ычисление итогов предоставленных услуг дл€ определенного 
-- клиаента помес€чно, за квартал, за полгода, за год.
SELECT 
    ST.service_type_name,
    EXTRACT(YEAR FROM service_start_date) AS year,
    EXTRACT(MONTH FROM service_start_date) AS month,
    CASE WHEN EXTRACT(MONTH FROM service_start_date) <= 3 THEN 1
         WHEN EXTRACT(MONTH FROM service_start_date) <= 6 THEN 2
         WHEN EXTRACT(MONTH FROM service_start_date) <= 9 THEN 3
         ELSE 4
    END AS quarter,
    CASE WHEN EXTRACT(MONTH FROM service_start_date) <= 6 THEN 1 ELSE 2 END AS half_year,
    SUM(service_type_daily_price) OVER (PARTITION BY EXTRACT(YEAR FROM service_start_date), EXTRACT(MONTH FROM service_start_date)) AS month_total,
    SUM(service_type_daily_price) OVER (PARTITION BY EXTRACT(YEAR FROM service_start_date), CASE WHEN EXTRACT(MONTH FROM service_start_date) <= 3 THEN 1
                                                                                            WHEN EXTRACT(MONTH FROM service_start_date) <= 6 THEN 2
                                                                                            WHEN EXTRACT(MONTH FROM service_start_date) <= 9 THEN 3
                                                                                            ELSE 4
                                                                                        END) AS quarter_total,
    SUM(service_type_daily_price) OVER (PARTITION BY EXTRACT(YEAR FROM service_start_date), CASE WHEN EXTRACT(MONTH FROM service_start_date) <= 6 THEN 1 ELSE 2 END) AS half_year_total,
    SUM(service_type_daily_price) OVER (PARTITION BY EXTRACT(YEAR FROM service_start_date)) AS yearly_total
FROM SERVICES S
INNER JOIN SERVICE_TYPES ST ON S.service_type_id = ST.service_type_id
WHERE S.service_guest_id = 2
ORDER BY ST.service_type_name;
    
    
    
select * from SERVICES

--4 ¬ычисление итогов предоставленных услуг дл€ определенного вида услуги за период:
--Х	объем услуг;
--Х	сравнение их с общим объемом услуг (в %);
--Х	сравнение с наибольшим объемом услуг (в %).
SELECT 
    S.service_id,
    ST.service_type_daily_price,
    S.service_start_date,
    SUM(ST.service_type_daily_price) OVER (PARTITION BY EXTRACT(YEAR FROM S.service_start_date), EXTRACT(MONTH FROM S.service_start_date)) AS monthly_total,
    SUM(ST.service_type_daily_price) OVER (PARTITION BY S.service_type_id) AS total_price,
    ROUND((SUM(ST.service_type_daily_price) OVER (PARTITION BY EXTRACT(YEAR FROM S.service_start_date), EXTRACT(MONTH FROM S.service_start_date))) / NULLIF(SUM(ST.service_type_daily_price) OVER (PARTITION BY S.service_type_id), 0) * 100, 2) AS monthly_to_total,
    MAX(ST.service_type_daily_price) OVER (PARTITION BY S.service_type_id) AS max_price,
    ROUND((MAX(ST.service_type_daily_price) OVER (PARTITION BY S.service_type_id)) / NULLIF(SUM(ST.service_type_daily_price) OVER (PARTITION BY EXTRACT(YEAR FROM S.service_start_date), EXTRACT(MONTH FROM S.service_start_date)), 0) * 100, 2) AS monthly_to_max,
    ROW_NUMBER() OVER(ORDER BY S.service_id) AS ROW_NUM
FROM SERVICES S
INNER JOIN SERVICE_TYPES ST ON S.service_type_id = ST.service_type_id
WHERE S.service_type_id IN (1, 2,3,4);

-- 5. ¬ернуть дл€ каждого клиента общую стоимость услуг 
--за последние 6 мес€цев помес€чно
SELECT
    G.guest_id,
    G.guest_name,
    G.guest_surname,
    EXTRACT(MONTH FROM service_start_date) AS month,
    SUM(ST.service_type_daily_price) OVER (PARTITION BY G.guest_id, TO_CHAR(S.service_start_date, 'YYYY-MM')) AS monthly_total_cost
FROM SERVICES S
    INNER JOIN GUESTS G ON S.service_guest_id = G.guest_id
    INNER JOIN SERVICE_TYPES ST ON S.service_type_id = ST.service_type_id
    WHERE S.service_start_date >= ADD_MONTHS(TRUNC(SYSDATE), -6)




    
--6
-- ака€ услуга была предоставлена наибольшее число раз дл€ 
--определенного вида? ¬ернуть дл€ всех видов.
SELECT 
    service_guest_id,
    service_type_name,
    order_count
FROM (
    SELECT 
        S.service_guest_id,
        ST.service_type_name,
        COUNT(*) AS order_count,
        ROW_NUMBER() OVER (PARTITION BY S.service_type_id ORDER BY COUNT(*) DESC) AS ServiceRank
    FROM 
        SERVICES S
    INNER JOIN 
        SERVICE_TYPES ST ON S.service_type_id = ST.service_type_id
    GROUP BY 
        S.service_guest_id, ST.service_type_name, S.service_type_id
) RankedServices
WHERE 
    ServiceRank = 1;
    
    
    


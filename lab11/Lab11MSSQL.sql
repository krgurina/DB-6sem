CREATE FUNCTION GetServicesByDateRange
(
    @StartDate DATE,
    @EndDate DATE
)
RETURNS TABLE
AS
RETURN
(
    SELECT service_id, service_guest_id, service_start_date, service_end_date
    FROM OrderedSERVICES
    WHERE service_start_date BETWEEN @StartDate AND @EndDate
)

--drop function GetServicesByDateRange


SELECT * FROM dbo.GetServicesByDateRange('2023-01-01', '2023-03-31');
-----------------------------------------------------------------------

select count(*) from OrderedSERVICES;
select * from OrderedSERVICES

CREATE TABLE OrderedSERVICES (
    service_id INT,
    service_guest_id INT,
    service_start_date DATETIME,
    service_end_date DATETIME ,
);

--drop table OrderedSERVICES
INSERT INTO OrderedSERVICES (service_id, service_guest_id, service_start_date, service_end_date)
VALUES (1, 4, CAST('2023-03-05 10:00:00' AS DATETIME), CAST('2023-03-10 10:00:00' AS DATETIME))

INSERT INTO OrderedSERVICES (service_id, service_guest_id, service_start_date, service_end_date)
VALUES (2, 4, '2023-03-05 10:00:00:00', '2023-03-10 10:00:00:00');

INSERT INTO OrderedSERVICES (service_id, service_guest_id, service_start_date, service_end_date)
VALUES (3, 3, '2023-03-01 10:00:00:00', '2023-03-05 10:00:00:00');

INSERT INTO OrderedSERVICES (service_id, service_guest_id, service_start_date, service_end_date)
VALUES (4, 3, '2023-04-10 10:00:00:00', '2023-04-11 10:00:00:00');

INSERT INTO OrderedSERVICES (service_id, service_guest_id, service_start_date, service_end_date)
VALUES (5, 1, '2023-11-05', '2023-11-10');

INSERT INTO OrderedSERVICES (service_id, service_guest_id, service_start_date, service_end_date)
VALUES (6, 1, '2023-03-02', '2023-03-03');



CREATE OR REPLACE TYPE ServiceTableType AS TABLE OF order_type;

--drop type ServiceTableType
--drop table Ordered_SERVICES
CREATE OR REPLACE FUNCTION GetServicesByDateRange
(
    StartDate IN DATE,
    EndDate IN DATE
)
RETURN ServiceTableType PIPELINED
AS
BEGIN
    FOR serv IN (
        SELECT service_type_id, service_guest_id, service_start_date, service_end_date, service_PRICE, service_status
        FROM Ordered_SERVICES
        WHERE SERVICE_START_DATE >= StartDate AND SERVICE_END_DATE <= EndDate
    ) LOOP
        PIPE ROW (order_type(serv.SERVICE_TYPE_ID, serv.SERVICE_GUEST_ID, serv.SERVICE_START_DATE, serv.SERVICE_END_DATE, serv.service_PRICE, serv.service_status));
    END LOOP;

    RETURN;
END;
/

select * from Ordered_SERVICES;

SELECT * FROM TABLE(CAST(GetServicesByDateRange(TO_DATE('2023-06-01', 'YYYY-MM-DD'), TO_DATE('2023-07-10', 'YYYY-MM-DD')) AS ServiceTableType));




CREATE TABLE Ordered_SERVICES (
    service_id NUMBER(10) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
    service_type_id NUMBER(10) NOT NULL,
    service_guest_id NUMBER(10) NOT NULL,
    service_start_date DATE NOT NULL,
    service_end_date DATE NOT NULL,
    service_PRICE number(10,2),
    service_status NVARCHAR2(200)
);

CREATE OR REPLACE TYPE order_type AS OBJECT (
    service_type_id NUMBER(10),
    service_guest_id NUMBER(10),
    service_start_date DATE,
    service_end_date DATE,
    service_PRICE number(10,2),
    service_status NVARCHAR2(200)
);

INSERT INTO Ordered_SERVICES (service_type_id, service_guest_id, service_start_date, service_end_date, service_PRICE, service_status)
VALUES (1, 2, TO_DATE('2023-06-05', 'YYYY-MM-DD'), TO_DATE('2023-06-10', 'YYYY-MM-DD'), 19.33,'new');
INSERT INTO Ordered_SERVICES (service_type_id, service_guest_id, service_start_date, service_end_date, service_PRICE, service_status)
VALUES (2, 2, TO_DATE('2023-06-15', 'YYYY-MM-DD'), TO_DATE('2023-06-20', 'YYYY-MM-DD'), 9.63,'running');
INSERT INTO Ordered_SERVICES (service_type_id, service_guest_id, service_start_date, service_end_date, service_PRICE, service_status)
VALUES (2, 3, TO_DATE('2024-06-05', 'YYYY-MM-DD'), TO_DATE('2024-06-10', 'YYYY-MM-DD'), 19.03,'deny');
INSERT INTO Ordered_SERVICES (service_type_id, service_guest_id, service_start_date, service_end_date, service_PRICE, service_status)
VALUES (1, 2, TO_DATE('2023-06-22', 'YYYY-MM-DD'), TO_DATE('2023-06-25', 'YYYY-MM-DD'), 9.73,'new');
commit;

drop function GetServicesByDateRange
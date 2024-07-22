---------------------------------------------------------------------------
-- Определение объектного типа для SERVICE_TYPE
---------------------------------------------------------------------------
CREATE OR REPLACE TYPE service_type_type AS OBJECT (
    service_type_id NUMBER(10),
    service_type_name NVARCHAR2(50),
    service_type_description NVARCHAR2(200),
    service_type_daily_price FLOAT(10),

    -- Дополнительный конструктор
    CONSTRUCTOR FUNCTION service_type_type(
        p_service_type_id NUMBER,
        p_service_type_name NVARCHAR2,
        p_service_type_description NVARCHAR2,
        p_service_type_daily_price FLOAT
    ) RETURN SELF AS RESULT,

    -- Метод сравнения типа MAP или ORDER
    ORDER MEMBER FUNCTION compare_type(el service_type_type) RETURN NUMBER,

    -- Функция, как метод экземпляра
    MEMBER FUNCTION get_total_price(p_count INT) RETURN FLOAT,

    -- Процедура, как метод экземпляра
    MEMBER PROCEDURE update_price(new_price FLOAT)
);


-- Тело для SERVICE_TYPE
CREATE OR REPLACE TYPE BODY service_type_type AS
    -- Дополнительный конструктор
    CONSTRUCTOR FUNCTION service_type_type(
        p_service_type_id NUMBER,
        p_service_type_name NVARCHAR2,
        p_service_type_description NVARCHAR2,
        p_service_type_daily_price FLOAT
    ) RETURN SELF AS RESULT IS
    BEGIN
        SELF.service_type_id := p_service_type_id;
        SELF.service_type_name := p_service_type_name;
        SELF.service_type_description := p_service_type_description;
        SELF.service_type_daily_price := p_service_type_daily_price;
        RETURN;
    END;

    -- Метод сравнения типа MAP или ORDER
    ORDER MEMBER FUNCTION compare_type(el service_type_type) RETURN NUMBER IS
    BEGIN
        IF SELF.service_type_daily_price > el.service_type_daily_price THEN
            RETURN 1;
        ELSIF SELF.service_type_daily_price < el.service_type_daily_price THEN
            RETURN -1;
        ELSE
            RETURN 0;
        END IF;
    END;

    -- Функция, как метод экземпляра
    MEMBER FUNCTION get_total_price(p_count INT) RETURN FLOAT IS
    BEGIN
        RETURN SELF.service_type_daily_price*p_count;
    END;

    -- Процедура, как метод экземпляра
    MEMBER PROCEDURE update_price(new_price FLOAT) IS
    BEGIN
        SELF.service_type_daily_price := new_price;
    END;
END;





---------------------------------------------------------------------------
-- Создание объектного типа данных для SERVICES
---------------------------------------------------------------------------
CREATE OR REPLACE TYPE service_type AS OBJECT (
    service_id NUMBER(10),
    service_type_id NUMBER(10),
    service_guest_id NUMBER(10),
    service_start_date DATE,
    service_end_date DATE,
    service_price INT,

    -- Дополнительный конструктор
    CONSTRUCTOR FUNCTION service_type(
        p_service_id NUMBER,
        p_service_type_id NUMBER,
        p_service_guest_id NUMBER,
        p_service_start_date DATE,
        p_service_end_date DATE,
        p_service_price INT
    ) RETURN SELF AS RESULT,

    -- Метод сравнения типа MAP или ORDER
    ORDER MEMBER FUNCTION compare_type(el service_type) RETURN NUMBER,

    -- Функция, как метод экземпляра
    MEMBER FUNCTION get_price(p_count INT) RETURN INT,
    MEMBER FUNCTION get return number deterministic,
    -- Процедура, как метод экземпляра
    MEMBER PROCEDURE update_price(new_price INT)
);


-- Тело для SERVICES
CREATE OR REPLACE TYPE BODY service_type AS
    -- Дополнительный конструктор
    CONSTRUCTOR FUNCTION service_type(
        p_service_id NUMBER,
        p_service_type_id NUMBER,
        p_service_guest_id NUMBER,
        p_service_start_date DATE,
        p_service_end_date DATE,
        p_service_price INT
    ) RETURN SELF AS RESULT IS
    BEGIN
        SELF.service_id := p_service_id;
        SELF.service_type_id := p_service_type_id;
        SELF.service_guest_id := p_service_guest_id;
        SELF.service_start_date := p_service_start_date;
        SELF.service_end_date := p_service_end_date;
        SELF.service_price := p_service_price;
        RETURN;
    END;

    -- Метод сравнения типа MAP или ORDER
    ORDER MEMBER FUNCTION compare_type(el service_type) RETURN NUMBER IS
    BEGIN
        IF SELF.service_price > el.service_price THEN
            RETURN 1;
        ELSIF SELF.service_price < el.service_price THEN
            RETURN -1;
        ELSE
            RETURN 0;
        END IF;
    END;

    -- Функция, как метод экземпляра
    MEMBER FUNCTION get_price(p_count INT) RETURN INT IS
    BEGIN
        RETURN SELF.service_price * p_count;
    END;

    MEMBER FUNCTION get return number deterministic
    is
        rc number := 0;
    begin
        rc:= EXTRACT(MONTH FROM sysdate);
        return rc;
        end;

    -- Процедура, как метод экземпляра
    MEMBER PROCEDURE update_price(new_price INT) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Цена обновлена');
        SELF.service_price := new_price;
    END;
END;
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

select * from SERVICES;
--перенос данных
CREATE TABLE object_services OF service_type AS
    SELECT s.service_id, s.service_type_id, s.service_guest_id, s.service_start_date, s.service_end_date, s.SERVISE_PRICE
    FROM SERVICES s;

select * from object_services;

--перенос данных
select * from SERVICE_TYPES;

CREATE TABLE object_service_types OF service_type_type AS
    SELECT s.service_type_id, s.service_type_name, s.service_type_description, s.service_type_daily_price
    FROM SERVICE_TYPES s;

select * from object_service_types;


drop table object_service_types;
drop table object_services;
drop table with_index;


--создание + сравнение
DECLARE
    service1 service_type;
    service2 service_type;
    result NUMBER;
BEGIN
    service1 := service_type(100, 1, 2, TO_DATE('2023-06-05', 'YYYY-MM-DD'), TO_DATE('2023-06-10', 'YYYY-MM-DD'), 100);
    service2 := service_type(101, 2, 3, TO_DATE('2023-06-05', 'YYYY-MM-DD'), TO_DATE('2023-06-10', 'YYYY-MM-DD'), 200);

result := service1.compare_type(service2);
    IF result = -1 THEN
        DBMS_OUTPUT.PUT_LINE('service2 дороже service1');
    ELSIF result = 1 THEN
        DBMS_OUTPUT.PUT_LINE('service1 дороже service2');
    ELSE
        DBMS_OUTPUT.PUT_LINE('service1 и service2 равны по стоимости');
    END IF;
END;

-- процедура как метод экземляра
DECLARE
    service1 service_type;
BEGIN
    service1 := service_type(100, 1, 2, TO_DATE('2023-06-05', 'YYYY-MM-DD'), TO_DATE('2023-06-10', 'YYYY-MM-DD'), 100);
    service1.update_price(12);
    DBMS_OUTPUT.PUT_LINE(service1.SERVICE_PRICE);
END;

--функция как метод экземляра
DECLARE
    service1 service_type;
    res int;
BEGIN
    service1 := service_type(100, 1, 2, TO_DATE('2023-06-05', 'YYYY-MM-DD'), TO_DATE('2023-06-10', 'YYYY-MM-DD'), 100);
    res:=service1.get_price(12);
    DBMS_OUTPUT.PUT_LINE(res);
END;

--идексирование по атрибуту
create index price_service_index on object_services(SERVICE_PRICE);
--drop index price_service_index;
select * from object_services where SERVICE_PRICE = 100;

--индексирование по методу
create table with_index(
    serv service_type
);

create bitmap index  serv_method_index on with_index(serv.get());
--план запроса
select count(*) from with_index e
         where e.serv.get()=4;

INSERT INTO with_index (serv) values (service_type(102, 1, 2, TO_DATE('2023-06-05', 'YYYY-MM-DD'), TO_DATE('2023-06-10', 'YYYY-MM-DD'), 100)
);
select * from with_index;

--объектные представления
CREATE or replace view object_view OF service_type
    with object identifier (service_id)
    AS
    SELECT s.service_id, s.service_type_id, s.service_guest_id, s.service_start_date, s.service_end_date, s.SERVISE_PRICE
    FROM SERVICES s;

select count(*) from object_view;
select * from object_view;


drop table object_service_types;
drop table object_services;
drop table with_index;

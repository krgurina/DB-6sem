use DB_6sem;
-------------------- ИНДЕКСЫ --------------------
CREATE INDEX service_daily_price_index ON SERVICE_TYPES(service_type_daily_price);
CREATE INDEX room_capacity_index ON ROOMS(room_capacity);
CREATE INDEX room_daily_price_index ON ROOMS(room_daily_price);
CREATE INDEX service_guest_index ON SERVICES(service_guest_id);
CREATE INDEX service_dates_index ON SERVICES(service_start_date, service_end_date);
CREATE INDEX booking_room_index ON BOOKING(booking_room_id);
CREATE INDEX booking_dates_index ON BOOKING(booking_start_date, booking_end_date);

-------------------- Представления --------------------
go
CREATE VIEW BOOKING_INFO_VIEW AS
SELECT
    b.booking_id,
    b.booking_room_id,
    r.room_name,
    g.guest_id,
    g.guest_name,
    g.guest_surname,
    b.booking_start_date,
    b.booking_end_date,
    b.booking_status
FROM BOOKING b
JOIN GUESTS g ON b.booking_guest_id = g.guest_id
JOIN ROOMS r ON b.booking_room_id = r.room_number;

CREATE VIEW GuestServiceInfo AS
SELECT
    g.guest_id,
    g.guest_name,
    g.guest_surname,
    s.service_id,
    st.service_type_name,
    s.service_start_date,
    s.service_end_date,
    st.service_type_daily_price
FROM GUESTS g
JOIN SERVICES s ON g.guest_id = s.service_guest_id
JOIN SERVICE_TYPES st ON s.service_type_id = st.service_type_id;

-------------------- ПРОЦЕДУРЫ --------------------
-- 1
CREATE OR ALTER PROCEDURE ADD_ROOM
	@p_room_number INT = NULL,
	@p_room_name NVARCHAR(50) = NULL,
	@p_room_capacity INT = NULL,
	@p_room_daily_price FLOAT = NULL,
	@p_room_description NVARCHAR(200) = NULL
AS
BEGIN
    DECLARE @existing_count INT;
	DECLARE @existing_number_count INT;

    IF @p_room_name IS NULL OR @p_room_capacity IS NULL OR @p_room_daily_price IS NULL OR @p_room_description IS NULL
    BEGIN
        THROW 50000, 'Все параметры должны быть заданы, а именно @p_room_name, @p_room_capacity, @p_room_daily_price, @p_room_description.', 1;
    END

    IF @p_room_capacity < 0
    BEGIN
        THROW 50001, 'Вместимость комнаты должна быть больше 0.', 1;
    END

    IF @p_room_daily_price <= 0
    BEGIN
        THROW 50002, 'Ежедневная стоимость комнаты должна быть больше 0.', 1;
    END

    SELECT @existing_count = COUNT(*)
    FROM ROOMS WHERE ROOM_NAME = @p_room_name AND ROOM_CAPACITY = @p_room_capacity;

    IF @existing_count > 0
    BEGIN
        THROW 50003, 'Комната с таким именем и вместимостью уже существует.', 1;
    END

	---
	    SELECT @existing_number_count = COUNT(*)
    FROM ROOMS WHERE ROOM_NUMBER = @p_room_number;

    IF @existing_number_count > 0
    BEGIN
        THROW 50003, 'Комната с таким именем и вместимостью уже существует.', 1;
    END
	--

    INSERT INTO ROOMS (room_number, room_name, room_capacity, room_daily_price, room_description)
    VALUES (@p_room_number, @p_room_name, @p_room_capacity, @p_room_daily_price, @p_room_description);

    COMMIT;

    PRINT 'Комната успешно создана. Номер комнаты: ' + CAST(@p_room_number AS NVARCHAR(10));
END;

--2
CREATE OR ALTER PROCEDURE UPDATE_ROOM
  @p_room_number INT = NULL,
  @p_new_room_name NVARCHAR(50) = NULL,
  @p_new_room_capacity INT = NULL,
  @p_new_room_daily_price FLOAT = NULL,
  @p_new_room_description NVARCHAR(200) = NULL
AS
BEGIN
    DECLARE @v_existing_count INT;
    DECLARE @v_existing_room_number INT;
    DECLARE @v_existing_room_name NVARCHAR(50);
    DECLARE @v_existing_room_capacity INT;
    DECLARE @v_existing_room_daily_price FLOAT;
    DECLARE @v_existing_room_description NVARCHAR(200);

    IF @p_room_number IS NULL
    BEGIN
        THROW 50004, 'Номер комнаты должен быть задан обязательно.', 1;
    END

    -- Проверка наличия комнаты с указанным номером
    SELECT
        @v_existing_room_number = room_number,
        @v_existing_room_name = room_name,
        @v_existing_room_capacity = room_capacity,
        @v_existing_room_daily_price = room_daily_price,
        @v_existing_room_description = room_description
    FROM ROOMS
    WHERE room_number = @p_room_number;

    IF @v_existing_room_number IS NULL
    BEGIN
        THROW 50001, 'Комната с указанным номером не существует.', 1;
    END

    IF @p_new_room_capacity IS NOT NULL
    BEGIN
        IF @p_new_room_capacity < 0
        BEGIN
            THROW 50005, 'Вместимость комнаты должна быть больше 0.', 1;
        END
    END

    IF @p_new_room_daily_price IS NOT NULL
    BEGIN
        IF @p_new_room_daily_price <= 0
        BEGIN
            THROW 50006, 'Ежедневная стоимость комнаты должна быть больше 0.', 1;
        END
    END

    UPDATE ROOMS
    SET
        room_name = COALESCE(@p_new_room_name, @v_existing_room_name),
        room_capacity = COALESCE(@p_new_room_capacity, @v_existing_room_capacity),
        room_daily_price = COALESCE(@p_new_room_daily_price, @v_existing_room_daily_price),
        room_description = COALESCE(@p_new_room_description, @v_existing_room_description)
    WHERE room_number = @p_room_number;

    COMMIT;

    PRINT 'Комната успешно обновлена.';
END;

--3
CREATE OR ALTER PROCEDURE GET_ROOM_LIST
  @p_id INT = NULL
AS
BEGIN
    DECLARE @v_room_number INT,
            @v_room_name NVARCHAR(50),
            @v_room_capacity INT,
            @v_room_daily_price FLOAT,
            @v_room_description NVARCHAR(200);

    DECLARE room_cursor CURSOR FOR
    SELECT ROOM_NUMBER, ROOM_NAME, ROOM_CAPACITY, ROOM_DAILY_PRICE, ROOM_DESCRIPTION
    FROM ROOMS
    WHERE ROOM_NUMBER = ISNULL(@p_id, ROOM_NUMBER);

    OPEN room_cursor;
    FETCH NEXT FROM room_cursor INTO @v_room_number, @v_room_name, @v_room_capacity, @v_room_daily_price, @v_room_description;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT 'Номер комнаты: ' + CAST(@v_room_number AS NVARCHAR(10)) +
              ', Название: ' + @v_room_name +
              ', Вместимость: ' + CAST(@v_room_capacity AS NVARCHAR(10)) +
              ', Суточная стоимость: ' + CAST(@v_room_daily_price AS NVARCHAR(10)) +
              ', Описание: ' + @v_room_description;

        FETCH NEXT FROM room_cursor INTO @v_room_number, @v_room_name, @v_room_capacity, @v_room_daily_price, @v_room_description;
    END;

    CLOSE room_cursor;
END;

--4
CREATE OR ALTER PROCEDURE PRE_BOOKING (
    @p_room_id INT,
    @p_guest_id INT,
    @p_start_date DATE,
    @p_end_date DATE
) AS
BEGIN
    DECLARE @v_room_exists INT;
    DECLARE @v_guest_exists INT;
    DECLARE @v_room_available INT;
    DECLARE @v_booking_id INT;

    -- Проверка существования гостя
    SELECT @v_guest_exists = COUNT(*) FROM GUESTS WHERE GUEST_ID = @p_guest_id;
    IF @v_guest_exists = 0
    BEGIN
        THROW 51000, 'Гость с указанным ID не найден.', 1;
    END;

    -- Проверка существования комнаты
    SELECT @v_room_exists = COUNT(*) FROM ROOMS WHERE ROOM_NUMBER = @p_room_id;
    IF @v_room_exists = 0
    BEGIN
        THROW 51000, 'Номер с указанным ID не найден.', 1;
    END;

    -- Проверка доступности комнаты в выбранные даты
    SELECT @v_room_available = COUNT(*)
    FROM BOOKING
    WHERE BOOKING_ROOM_ID = @p_room_id
        AND (
            (@p_start_date BETWEEN BOOKING_START_DATE AND BOOKING_END_DATE)
            OR (@p_end_date BETWEEN BOOKING_START_DATE AND BOOKING_END_DATE)
            OR (BOOKING_START_DATE BETWEEN @p_start_date AND @p_end_date)
            OR (BOOKING_END_DATE BETWEEN @p_start_date AND @p_end_date)
        );

    IF @v_room_available > 0
    BEGIN
        THROW 51000, 'Номер занят в выбранные даты.', 1;
    END;

    -- Вставка записи о бронировании
    INSERT INTO BOOKING (BOOKING_ROOM_ID, BOOKING_GUEST_ID, BOOKING_START_DATE, BOOKING_END_DATE, BOOKING_STATUS)
    VALUES (@p_room_id, @p_guest_id, @p_start_date, @p_end_date, 'BOOKED');

    SET @v_booking_id = SCOPE_IDENTITY();

    COMMIT;

    PRINT 'Бронирование успешно добавлено. ID: ' + CAST(@v_booking_id AS NVARCHAR(10));
END;

--5
CREATE OR ALTER PROCEDURE DELETE_ROOM
    @p_room_number INT
AS
BEGIN
    DECLARE @v_existing_count INT;

    IF @p_room_number IS NULL
    BEGIN 
		THROW 50003, 'Номер комнаты должен быть задан обязательно.', 1;
    END;

    SELECT @v_existing_count = COUNT(*)
    FROM ROOMS WHERE room_number = @p_room_number;

    IF @v_existing_count = 0
    BEGIN
		THROW 50007, 'Комната с указанным номером не существует.', 1;
    END;

    DELETE FROM ROOMS WHERE room_number = @p_room_number;
    COMMIT;
    PRINT 'Комната успешно удалена.';
END;



-------------------- ФУНКЦИИ --------------------
CREATE OR ALTER FUNCTION Calculate_Stay_Cost
    (@p_booking_id INT)
RETURNS FLOAT
AS
BEGIN
    DECLARE @v_total_cost FLOAT = 0;
    DECLARE @v_current_user_id INT;
    DECLARE @v_booking_state NVARCHAR(20);

    -- Получаем информацию о брони
    SELECT @v_current_user_id = b.booking_guest_id,
           @v_booking_state = b.booking_status
    FROM BOOKING b
    WHERE b.booking_id = @p_booking_id;

    IF @v_booking_state != 'CONFIRMED'
    BEGIN
        RETURN NULL;  -- или можно выбросить ошибку с помощью THROW
    END;

    -- Рассчитываем стоимость проживания
    SELECT @v_total_cost = DATEDIFF(day, b.booking_start_date, b.booking_end_date) * r.room_daily_price +
                           COALESCE((SELECT SUM(DATEDIFF(day, s.service_start_date, s.service_end_date) * st.service_type_daily_price)
                                     FROM SERVICES s
                                     JOIN SERVICE_TYPES st ON s.service_type_id = st.service_type_id
                                     WHERE s.service_guest_id = @v_current_user_id), 0)
    FROM BOOKING b
    JOIN ROOMS r ON b.booking_room_id = r.room_number
    WHERE b.booking_id = @p_booking_id;

    RETURN @v_total_cost;
END;



-------------------- ТРИГГЕРЫ --------------------
CREATE TRIGGER UPDATE_GUEST_TRIGGER
ON GUESTS
AFTER INSERT, DELETE, UPDATE
AS
BEGIN
    PRINT 'Данные о гостях успешно обновлены';
END;
-------------------- ИНДЕКСЫ --------------------
CREATE INDEX service_daily_price_index ON SERVICE_TYPES(service_type_daily_price);
CREATE INDEX room_capacity_index ON ROOMS(room_capacity);
CREATE INDEX room_daily_price_index ON ROOMS(room_daily_price);
CREATE INDEX service_guest_index ON SERVICES(service_guest_id);
CREATE INDEX service_dates_index ON SERVICES(service_start_date, service_end_date);
CREATE INDEX booking_room_index ON BOOKING(booking_room_id);
CREATE INDEX booking_dates_index ON BOOKING(booking_start_date, booking_end_date);

-------------------- Представления --------------------
CREATE OR REPLACE VIEW BOOKING_INFO_VIEW AS
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

-------------------- ПОСЛЕДОВАТЕЛЬНОСТИ --------------------
CREATE SEQUENCE seq_guests
START WITH 1
INCREMENT BY 1
MAXVALUE 500;

CREATE SEQUENCE seq_rooms
START WITH 1
INCREMENT BY 1
MAXVALUE 600;


-------------------- ПРОЦЕДУРЫ --------------------
-- 1
CREATE OR REPLACE PROCEDURE ADD_ROOM(
  p_room_name        NVARCHAR2 DEFAULT NULL,
  p_room_capacity    NUMBER DEFAULT NULL,
  p_room_daily_price FLOAT DEFAULT NULL,
  p_room_description NVARCHAR2 DEFAULT NULL
) AS
    existing_count NUMBER;
    v_room_number NUMBER;
BEGIN
    IF p_room_name IS NULL OR p_room_capacity IS NULL OR p_room_daily_price IS NULL OR p_room_description IS NULL THEN
        RAISE_APPLICATION_ERROR(-20029, 'Все параметры должны быть заданы, а именно p_room_name, p_room_capacity, p_room_daily_price, p_room_description.');
    END IF;

    IF p_room_capacity < 0 THEN
        RAISE_APPLICATION_ERROR(-20006, 'Вместимость комнаты должна быть больше 0.');
    END IF;

    IF p_room_daily_price <= 0 THEN
        RAISE_APPLICATION_ERROR(-20007, 'Ежедневная стоимость комнаты должна быть больше 0.');
    END IF;

    SELECT COUNT(*) INTO existing_count FROM ROOMS
        WHERE ROOM_NAME = p_room_name AND ROOM_CAPACITY = p_room_capacity;
    IF existing_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Комната с таким именем и вместимостью уже существует.');
    END IF;

    INSERT INTO ROOMS (room_name, room_capacity, room_daily_price, room_description)
    VALUES (p_room_name, p_room_capacity, p_room_daily_price, p_room_description) returning room_number into v_room_number;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Комната успешно создана. Номер комнаты: ' || v_room_number);
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
    ROLLBACK;
END ADD_ROOM;

-- 2. изменить комнату 
CREATE OR REPLACE PROCEDURE UPDATE_ROOM(
    p_room_number NUMBER DEFAULT NULL,
    p_new_room_name NVARCHAR2 DEFAULT NULL,
    p_new_room_capacity NUMBER DEFAULT NULL,
    p_new_room_daily_price FLOAT DEFAULT NULL,
    p_new_room_description NVARCHAR2 DEFAULT NULL
) AS
    v_existing_count NUMBER;
    v_existing_room ROOMS%ROWTYPE;
BEGIN
    IF p_room_number IS NULL THEN
        RAISE_APPLICATION_ERROR(-20030, 'Номер комнаты должен быть задан обязательно.');
    END IF;

    -- Проверка наличия комнаты с указанным номером
    SELECT * INTO v_existing_room
    FROM ROOMS WHERE room_number = p_room_number;

    IF v_existing_room.room_number IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Комната с указанным номером не существует.');
    END IF;

    IF p_new_room_capacity IS NOT NULL THEN
        IF p_new_room_capacity < 0 THEN
            RAISE_APPLICATION_ERROR(-20006, 'Вместимость комнаты должна быть больше 0.');
        END IF;
    END IF;

    IF p_new_room_daily_price IS NOT NULL THEN
        IF p_new_room_daily_price <= 0 THEN
            RAISE_APPLICATION_ERROR(-20007, 'Ежедневная стоимость комнаты должна быть больше 0.');
        END IF;
    END IF;

    UPDATE ROOMS
    SET
        room_name = COALESCE(p_new_room_name, v_existing_room.room_name),
        room_capacity = COALESCE(p_new_room_capacity, v_existing_room.room_capacity),
        room_daily_price = COALESCE(p_new_room_daily_price, v_existing_room.room_daily_price),
        room_description = COALESCE(p_new_room_description, v_existing_room.room_description)
    WHERE room_number = p_room_number;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Комната успешно обновлена.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END UPDATE_ROOM;

--3
CREATE OR REPLACE PROCEDURE GET_ROOM_LIST(p_id NUMBER DEFAULT NULL) AS
    v_cursor SYS_REFCURSOR;
    v_info ROOMS%ROWTYPE;
BEGIN
    v_cursor := Get_Room_Cursor(p_id);
    LOOP
        FETCH v_cursor INTO v_info;
        EXIT WHEN v_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Номер комнаты: ' || v_info.ROOM_NUMBER ||
                             ', Название: ' || v_info.ROOM_NAME ||
                             ', Вместимость: ' || v_info.ROOM_CAPACITY ||
                             ', Суточная стоимость: ' || v_info.ROOM_DAILY_PRICE ||
                             ', Описание: ' || v_info.ROOM_DESCRIPTION);
    END LOOP;

    CLOSE v_cursor;
END GET_ROOM_LIST;

-- 4
CREATE OR REPLACE PROCEDURE PRE_BOOKING(
    p_room_id NUMBER,
    p_guest_id NUMBER,
    p_start_date DATE,
    p_end_date DATE
)
AS
    v_room_exists NUMBER;
    v_guest_exists NUMBER;
    v_room_available NUMBER;
    v_booking_id NUMBER;
BEGIN
    -- Проверка существования гостя
    SELECT COUNT(*) INTO v_guest_exists FROM GUESTS WHERE GUEST_ID = p_guest_id;
    IF v_guest_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Гость с указанным ID не найден.');
    END IF;

    -- Проверка существования комнаты
    SELECT COUNT(*) INTO v_room_exists FROM ROOMS WHERE ROOM_NUMBER = p_room_id;
    IF v_room_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Номер с указанным ID не найден.');
    END IF;

    -- Проверка доступности комнаты в выбранные даты
    SELECT COUNT(*) INTO v_room_available
    FROM BOOKING
    WHERE BOOKING_ROOM_ID = p_room_id
        AND (
            (p_start_date BETWEEN BOOKING_START_DATE AND BOOKING_END_DATE)
            OR (p_end_date BETWEEN BOOKING_START_DATE AND BOOKING_END_DATE)
            OR (BOOKING_START_DATE BETWEEN p_start_date AND p_end_date)
            OR (BOOKING_END_DATE BETWEEN p_start_date AND p_end_date)
        );

    IF v_room_available > 0 THEN
        RAISE_APPLICATION_ERROR(-20013, 'Номер занят в выбранные даты.');
    END IF;

    INSERT INTO BOOKING (BOOKING_ROOM_ID, BOOKING_GUEST_ID, BOOKING_START_DATE, BOOKING_END_DATE, BOOKING_STATUS)
    VALUES (p_room_id, p_guest_id, p_start_date, p_end_date, 'BOOKED')
    RETURNING BOOKING_ID INTO v_booking_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Бронирование успешно добавлено. ID: '|| v_booking_id);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END PRE_BOOKING;


-------------------- ФУНКЦИИ --------------------
--1
CREATE OR REPLACE FUNCTION DELETE_ROOM(
    p_room_number NUMBER
) RETURN NUMBER AS
    v_existing_count NUMBER;
BEGIN
    IF p_room_number IS NULL THEN
        RAISE_APPLICATION_ERROR(-20030, 'Номер комнаты должен быть задан обязательно.');
    END IF;

    -- Проверка наличия комнаты с указанным номером
    SELECT COUNT(*) INTO v_existing_count
    FROM ROOMS WHERE room_number = p_room_number;

    IF v_existing_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Комната с указанным номером не существует.');
    END IF;

    DELETE FROM ROOMS WHERE room_number = p_room_number;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Комната успешно удалена.');
    RETURN 1;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
        RETURN 0;
END DELETE_ROOM;

--------------------------------------
--2
CREATE OR REPLACE FUNCTION Get_Room_Cursor(p_id NUMBER DEFAULT NULL) RETURN SYS_REFCURSOR
    AS
    result_cursor SYS_REFCURSOR;
BEGIN
    IF p_id IS NOT NULL THEN
        OPEN result_cursor FOR
            SELECT * FROM ROOMS WHERE ROOM_NUMBER = p_id;
    ELSE
        OPEN result_cursor FOR
            SELECT * FROM ROOMS;
    END IF;
    RETURN result_cursor;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        RETURN NULL;
END Get_Room_Cursor;
--------------------------------------------------------
--3
CREATE OR REPLACE FUNCTION Calculate_Stay_Cost(p_booking_id IN NUMBER) RETURN FLOAT AS
    v_total_cost FLOAT := 0;
    v_current_user_id NUMBER;
    v_booking_state NVARCHAR2(20);

BEGIN
    -- Получаем информацию о брони
    SELECT b.BOOKING_GUEST_ID, b.BOOKING_STATUS
    INTO v_current_user_id, v_booking_state
    FROM BOOKING b
    WHERE b.BOOKING_ID = p_booking_id;

    IF v_booking_state != 'CONFIRMED' THEN
        RAISE_APPLICATION_ERROR(-20036, 'Расчет стоимости доступен только для подтвержденных броней.');
    END IF;

    -- Рассчитываем стоимость проживания
    SELECT
        ((b.BOOKING_END_DATE - b.BOOKING_START_DATE) * r.ROOM_DAILY_PRICE +
        NVL((SELECT SUM((s.SERVICE_END_DATE - s.SERVICE_START_DATE) * st.SERVICE_TYPE_DAILY_PRICE)
             FROM SERVICES s
             JOIN SERVICE_TYPES st ON s.SERVICE_TYPE_ID = st.SERVICE_TYPE_ID
             WHERE s.SERVICE_GUEST_ID = v_current_user_id), 0)) AS TOTAL_COST
    INTO v_total_cost
    FROM BOOKING b
    JOIN ROOMS r ON b.BOOKING_ROOM_ID = r.ROOM_NUMBER
    WHERE b.BOOKING_ID = p_booking_id;

    RETURN v_total_cost;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Данные не найдены: ');
        RETURN NULL;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        RETURN NULL;
END Calculate_Stay_Cost;

-------------------- ТРИГГЕРЫ --------------------
create or replace trigger UPDATE_GUEST_TRIGGER
    after insert or delete or update
    on GUESTS
begin
    DBMS_OUTPUT.PUT_LINE('Данные о гостях успешно обновлены');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Произошла ошибка при экспорте гостей: ' || SQLERRM);
end;




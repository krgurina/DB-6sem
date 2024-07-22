-------------------- ������� --------------------
CREATE INDEX service_daily_price_index ON SERVICE_TYPES(service_type_daily_price);
CREATE INDEX room_capacity_index ON ROOMS(room_capacity);
CREATE INDEX room_daily_price_index ON ROOMS(room_daily_price);
CREATE INDEX service_guest_index ON SERVICES(service_guest_id);
CREATE INDEX service_dates_index ON SERVICES(service_start_date, service_end_date);
CREATE INDEX booking_room_index ON BOOKING(booking_room_id);
CREATE INDEX booking_dates_index ON BOOKING(booking_start_date, booking_end_date);

-------------------- ������������� --------------------
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

-------------------- ������������������ --------------------
CREATE SEQUENCE seq_guests
START WITH 1
INCREMENT BY 1
MAXVALUE 500;

CREATE SEQUENCE seq_rooms
START WITH 1
INCREMENT BY 1
MAXVALUE 600;


-------------------- ��������� --------------------
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
        RAISE_APPLICATION_ERROR(-20029, '��� ��������� ������ ���� ������, � ������ p_room_name, p_room_capacity, p_room_daily_price, p_room_description.');
    END IF;

    IF p_room_capacity < 0 THEN
        RAISE_APPLICATION_ERROR(-20006, '����������� ������� ������ ���� ������ 0.');
    END IF;

    IF p_room_daily_price <= 0 THEN
        RAISE_APPLICATION_ERROR(-20007, '���������� ��������� ������� ������ ���� ������ 0.');
    END IF;

    SELECT COUNT(*) INTO existing_count FROM ROOMS
        WHERE ROOM_NAME = p_room_name AND ROOM_CAPACITY = p_room_capacity;
    IF existing_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20002, '������� � ����� ������ � ������������ ��� ����������.');
    END IF;

    INSERT INTO ROOMS (room_name, room_capacity, room_daily_price, room_description)
    VALUES (p_room_name, p_room_capacity, p_room_daily_price, p_room_description) returning room_number into v_room_number;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('������� ������� �������. ����� �������: ' || v_room_number);
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('��������� ������: ' || SQLERRM);
    ROLLBACK;
END ADD_ROOM;

-- 2. �������� ������� 
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
        RAISE_APPLICATION_ERROR(-20030, '����� ������� ������ ���� ����� �����������.');
    END IF;

    -- �������� ������� ������� � ��������� �������
    SELECT * INTO v_existing_room
    FROM ROOMS WHERE room_number = p_room_number;

    IF v_existing_room.room_number IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, '������� � ��������� ������� �� ����������.');
    END IF;

    IF p_new_room_capacity IS NOT NULL THEN
        IF p_new_room_capacity < 0 THEN
            RAISE_APPLICATION_ERROR(-20006, '����������� ������� ������ ���� ������ 0.');
        END IF;
    END IF;

    IF p_new_room_daily_price IS NOT NULL THEN
        IF p_new_room_daily_price <= 0 THEN
            RAISE_APPLICATION_ERROR(-20007, '���������� ��������� ������� ������ ���� ������ 0.');
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
    DBMS_OUTPUT.PUT_LINE('������� ������� ���������.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('��������� ������: ' || SQLERRM);
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

        DBMS_OUTPUT.PUT_LINE('����� �������: ' || v_info.ROOM_NUMBER ||
                             ', ��������: ' || v_info.ROOM_NAME ||
                             ', �����������: ' || v_info.ROOM_CAPACITY ||
                             ', �������� ���������: ' || v_info.ROOM_DAILY_PRICE ||
                             ', ��������: ' || v_info.ROOM_DESCRIPTION);
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
    -- �������� ������������� �����
    SELECT COUNT(*) INTO v_guest_exists FROM GUESTS WHERE GUEST_ID = p_guest_id;
    IF v_guest_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, '����� � ��������� ID �� ������.');
    END IF;

    -- �������� ������������� �������
    SELECT COUNT(*) INTO v_room_exists FROM ROOMS WHERE ROOM_NUMBER = p_room_id;
    IF v_room_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, '����� � ��������� ID �� ������.');
    END IF;

    -- �������� ����������� ������� � ��������� ����
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
        RAISE_APPLICATION_ERROR(-20013, '����� ����� � ��������� ����.');
    END IF;

    INSERT INTO BOOKING (BOOKING_ROOM_ID, BOOKING_GUEST_ID, BOOKING_START_DATE, BOOKING_END_DATE, BOOKING_STATUS)
    VALUES (p_room_id, p_guest_id, p_start_date, p_end_date, 'BOOKED')
    RETURNING BOOKING_ID INTO v_booking_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('������������ ������� ���������. ID: '|| v_booking_id);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('��������� ������: ' || SQLERRM);
        ROLLBACK;
END PRE_BOOKING;


-------------------- ������� --------------------
--1
CREATE OR REPLACE FUNCTION DELETE_ROOM(
    p_room_number NUMBER
) RETURN NUMBER AS
    v_existing_count NUMBER;
BEGIN
    IF p_room_number IS NULL THEN
        RAISE_APPLICATION_ERROR(-20030, '����� ������� ������ ���� ����� �����������.');
    END IF;

    -- �������� ������� ������� � ��������� �������
    SELECT COUNT(*) INTO v_existing_count
    FROM ROOMS WHERE room_number = p_room_number;

    IF v_existing_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, '������� � ��������� ������� �� ����������.');
    END IF;

    DELETE FROM ROOMS WHERE room_number = p_room_number;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('������� ������� �������.');
    RETURN 1;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('��������� ������: ' || SQLERRM);
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
        DBMS_OUTPUT.PUT_LINE('��������� ������: ' || SQLERRM);
        RETURN NULL;
END Get_Room_Cursor;
--------------------------------------------------------
--3
CREATE OR REPLACE FUNCTION Calculate_Stay_Cost(p_booking_id IN NUMBER) RETURN FLOAT AS
    v_total_cost FLOAT := 0;
    v_current_user_id NUMBER;
    v_booking_state NVARCHAR2(20);

BEGIN
    -- �������� ���������� � �����
    SELECT b.BOOKING_GUEST_ID, b.BOOKING_STATUS
    INTO v_current_user_id, v_booking_state
    FROM BOOKING b
    WHERE b.BOOKING_ID = p_booking_id;

    IF v_booking_state != 'CONFIRMED' THEN
        RAISE_APPLICATION_ERROR(-20036, '������ ��������� �������� ������ ��� �������������� ������.');
    END IF;

    -- ������������ ��������� ����������
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
        DBMS_OUTPUT.PUT_LINE('������ �� �������: ');
        RETURN NULL;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('��������� ������: ' || SQLERRM);
        RETURN NULL;
END Calculate_Stay_Cost;

-------------------- �������� --------------------
create or replace trigger UPDATE_GUEST_TRIGGER
    after insert or delete or update
    on GUESTS
begin
    DBMS_OUTPUT.PUT_LINE('������ � ������ ������� ���������');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('��������� ������ ��� �������� ������: ' || SQLERRM);
end;




CREATE TABLE ROOMS (
    room_number NUMBER(10) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
    room_name NVARCHAR2(50) NOT NULL,
    room_capacity NUMBER(10) NOT NULL,
    room_daily_price FLOAT(10) NOT NULL,
    room_description NVARCHAR2(200) NOT NULL,
    CONSTRAINT room_pk PRIMARY KEY (room_number)
);

CREATE TABLE GUESTS (
    guest_id NUMBER(10) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
    guest_email NVARCHAR2(50) NOT NULL,
    guest_name NVARCHAR2(50) NOT NULL,
    guest_surname NVARCHAR2(50) NOT NULL,
    username NVARCHAR2(50) NOT NULL UNIQUE,
    guest_bdate DATE NOT NULL,
    CONSTRAINT guest_pk PRIMARY KEY (guest_id)
);

CREATE TABLE SERVICE_TYPES (
    service_type_id NUMBER(10) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
    service_type_name NVARCHAR2(50) NOT NULL,
    service_type_description NVARCHAR2(200) NOT NULL,
    service_type_daily_price FLOAT(10) NOT NULL,
    CONSTRAINT service_type_pk PRIMARY KEY (service_type_id)
);

CREATE TABLE SERVICES (
    service_id NUMBER(10) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
    service_type_id NUMBER(10) NOT NULL,
    service_guest_id NUMBER(10) NOT NULL,
    service_start_date DATE NOT NULL,
    service_end_date DATE NOT NULL,
    SERVISE_PRICE INT,
    CONSTRAINT service_pk PRIMARY KEY (service_id),
    CONSTRAINT service_service_type_fk FOREIGN KEY (service_type_id) REFERENCES SERVICE_TYPES(service_type_id) ON DELETE CASCADE,
    CONSTRAINT service_guest_fk FOREIGN KEY (service_guest_id) REFERENCES GUESTS(guest_id) ON DELETE CASCADE
);


CREATE TABLE BOOKING (
    booking_id NUMBER(10) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
    booking_room_id NUMBER(10) NOT NULL,
    booking_guest_id NUMBER(10) NOT NULL,
    booking_start_date DATE NOT NULL,
    booking_end_date DATE NOT NULL,
    booking_status NVARCHAR2(20) NOT NULL,
    CONSTRAINT booking_pk PRIMARY KEY (booking_id),
    CONSTRAINT booking_room_fk FOREIGN KEY (booking_room_id) REFERENCES ROOMS(room_number) ON DELETE CASCADE,
    CONSTRAINT booking_guest_fk FOREIGN KEY (booking_guest_id) REFERENCES GUESTS(guest_id) ON DELETE CASCADE
);

CREATE TABLE ROOMS (
    room_number INT NOT NULL PRIMARY KEY,
    room_name NVARCHAR(50) NOT NULL,
    room_capacity INT NOT NULL,
    room_daily_price FLOAT NOT NULL,
    room_description NVARCHAR(200) NOT NULL
);

CREATE TABLE GUESTS (
    guest_id INT IDENTITY(1,1) PRIMARY KEY,
    guest_email NVARCHAR(50) NOT NULL,
    guest_name NVARCHAR(50) NOT NULL,
    guest_surname NVARCHAR(50) NOT NULL,
    username NVARCHAR(50) NOT NULL UNIQUE,
    guest_bdate DATE NOT NULL
);

CREATE TABLE SERVICE_TYPES (
    service_type_id INT IDENTITY(1,1) PRIMARY KEY,
    service_type_name NVARCHAR(50) NOT NULL,
    service_type_description NVARCHAR(200) NOT NULL,
    service_type_daily_price FLOAT NOT NULL
);

CREATE TABLE SERVICES (
    service_id INT IDENTITY(1,1) PRIMARY KEY,
    service_type_id INT NOT NULL,
    service_guest_id INT NOT NULL,
    service_start_date DATE NOT NULL,
    service_end_date DATE NOT NULL,
    FOREIGN KEY (service_type_id) REFERENCES SERVICE_TYPES(service_type_id) ON DELETE CASCADE,
    FOREIGN KEY (service_guest_id) REFERENCES GUESTS(guest_id) ON DELETE CASCADE
);

CREATE TABLE BOOKING (
    booking_id INT IDENTITY(1,1) PRIMARY KEY,
    booking_room_id INT NOT NULL,
    booking_guest_id INT NOT NULL,
    booking_start_date DATE NOT NULL,
    booking_end_date DATE NOT NULL,
    booking_status NVARCHAR(20) NOT NULL,
    FOREIGN KEY (booking_room_id) REFERENCES ROOMS(room_number) ON DELETE CASCADE,
    FOREIGN KEY (booking_guest_id) REFERENCES GUESTS(guest_id) ON DELETE CASCADE
);

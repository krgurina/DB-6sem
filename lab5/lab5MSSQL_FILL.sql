alter table ROOMS DROP COLUMN room_hierarchy

INSERT INTO GUESTS (guest_email, guest_name, guest_surname, username, guest_bdate)
VALUES 
    ('user1@gmail.com', 'Кристина', 'Гурина', 'kristina', '2003-09-28'),
    ('user2@gmail.com', 'Евгения', 'Коктыш', 'jojik', '2003-12-26'),
    ('user3@gmail.com', 'Авдеева', 'Вера', 'vera', '2003-09-23'),
	('user4@gmail.com', 'Иванов', 'Иван', 'user4', '2001-10-23');

INSERT INTO SERVICE_TYPES (service_type_name, service_type_description, service_type_daily_price)
VALUES 
    ('Спа-услуги', 'Спа-центры предоставляют различные процедуры, массажи, сауны, джакузи, а также услуги парикмахера и маникюра', 100.00),
    ('Трансфер', 'Услуги трансфера из/в аэропорт или другие места', 20.00),
    ('Экскурсии', 'Организация поездок и экскурсий по местным достопримечательностям', 30.00),
	('Комната ожидания родителей', 'В комнате есть множество игрушек, с которыми Ваш ребенок может поиграть, специальный столик для рисования, горка и многое другое', 75.00),
	('Фитнес-центр', 'Оборудованный тренажерный зал с современными тренажерами и инструкторами', 50.00),
	('Сейф', 'В лобби предоставляется услуга пользования сейфом, где Вы можете оставить ценные вещи', 25.00),
	('Услуга «звонок-будильник»', 'Для связи с сервисным центром наберите "0" и сообщите время, когда Вас необходимо разбудить', 10.00);

INSERT INTO SERVICES (service_type_id, service_guest_id, service_start_date, service_end_date)
VALUES 
    (1, 4, '2023-11-05', '2023-11-10'),
    (1, 2, '2023-03-10', '2023-03-15'),
    (1, 3, '2023-04-20', '2023-04-25');

	INSERT INTO SERVICES (service_type_id, service_guest_id, service_start_date, service_end_date)
VALUES 
    (3, 1, '2023-11-05', '2023-11-10'),
    (6, 2, '2022-03-10', '2022-03-15'),
    (5, 3, '2024-01-20', '2024-01-25');

INSERT INTO BOOKING (booking_room_id, booking_guest_id, booking_start_date, booking_end_date, booking_status)
VALUES 
    (101, 1, '2024-01-05', '2024-01-10', 'Одобрено'),
    (102, 2, '2024-02-10', '2024-02-15', 'Одобрено'),
    (103, 3, '2024-03-20', '2024-03-25', 'Одобрено');



	INSERT INTO SERVICES2 (service_id, service_type_id, service_guest_id, service_start_date, service_end_date)
VALUES 
    (1, 1, 4, '2023-11-05', '2023-11-10'),
    (2, 1, 2, '2023-03-10', '2023-03-15'),
    (3, 1, 3, '2023-04-20', '2023-04-25');
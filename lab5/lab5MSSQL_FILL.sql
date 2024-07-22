alter table ROOMS DROP COLUMN room_hierarchy

INSERT INTO GUESTS (guest_email, guest_name, guest_surname, username, guest_bdate)
VALUES 
    ('user1@gmail.com', '��������', '������', 'kristina', '2003-09-28'),
    ('user2@gmail.com', '�������', '������', 'jojik', '2003-12-26'),
    ('user3@gmail.com', '�������', '����', 'vera', '2003-09-23'),
	('user4@gmail.com', '������', '����', 'user4', '2001-10-23');

INSERT INTO SERVICE_TYPES (service_type_name, service_type_description, service_type_daily_price)
VALUES 
    ('���-������', '���-������ ������������� ��������� ���������, �������, �����, �������, � ����� ������ ����������� � ��������', 100.00),
    ('��������', '������ ��������� ��/� �������� ��� ������ �����', 20.00),
    ('���������', '����������� ������� � ��������� �� ������� ����������������������', 30.00),
	('������� �������� ���������', '� ������� ���� ��������� �������, � �������� ��� ������� ����� ��������, ����������� ������ ��� ���������, ����� � ������ ������', 75.00),
	('������-�����', '������������� ����������� ��� � ������������ ����������� � �������������', 50.00),
	('����', '� ����� ��������������� ������ ����������� ������, ��� �� ������ �������� ������ ����', 25.00),
	('������ �������-���������', '��� ����� � ��������� ������� �������� "0" � �������� �����, ����� ��� ���������� ���������', 10.00);

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
    (101, 1, '2024-01-05', '2024-01-10', '��������'),
    (102, 2, '2024-02-10', '2024-02-15', '��������'),
    (103, 3, '2024-03-20', '2024-03-25', '��������');



	INSERT INTO SERVICES2 (service_id, service_type_id, service_guest_id, service_start_date, service_end_date)
VALUES 
    (1, 1, 4, '2023-11-05', '2023-11-10'),
    (2, 1, 2, '2023-03-10', '2023-03-15'),
    (3, 1, 3, '2023-04-20', '2023-04-25');
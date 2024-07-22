--1
CREATE TABLESPACE lab10_ts
DATAFILE 'lab10_ts.dat'
SIZE 100M
AUTOEXTEND ON
EXTENT MANAGEMENT LOCAL;

--drop table PHOTO
CREATE TABLE PHOTO (
    photo_id NUMBER(10) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
    photo_room_type NUMBER(10) NOT NULL,
    photo_source BLOB DEFAULT EMPTY_BLOB(),
    doc_file BLOB DEFAULT EMPTY_BLOB(),
    CONSTRAINT photo_pk PRIMARY KEY (photo_id)
) tablespace lab10_ts;
--2

CREATE DIRECTORY MEDIA_DIR AS 'E:\univer\DB\photo';
drop directory MEDIA_DIR;

--3
CREATE USER user_lab10 IDENTIFIED BY 123;
GRANT CONNECT, RESOURCE TO user_lab10;
GRANT CREATE SESSION TO user_lab10;
GRANT EXECUTE ON DBMS_LOB TO user_lab10;--в консоли
GRANT read,write ON DIRECTORY MEDIA_DIR TO user_lab10;

--4
ALTER USER user_lab10 QUOTA UNLIMITED ON lab10_ts;
GRANT ALL PRIVILEGES ON admin.PHOTO TO user_lab10;

--5
select * from PHOTO;
drop table PHOTO;


--6
INSERT INTO PHOTO (photo_room_type, photo_source, doc_file)
        VALUES (1, BFILENAME('MEDIA_DIR', 'ph1.jpg'), BFILENAME('MEDIA_DIR', 'test.docx'));
INSERT INTO PHOTO (photo_room_type, photo_source, doc_file)
        VALUES (2, BFILENAME('MEDIA_DIR', 'ph2.jpg'), BFILENAME('MEDIA_DIR', 'test.docx'));

select * from PHOTO;

update PHOTO set photo_source = BFILENAME('MEDIA_DIR', 'ph3.jpg') where photo_id = 10;
UPDATE PHOTO SET photo_source = BFILENAME('MEDIA_DIR', 'ph4.jpg') WHERE photo_id = 9;
update PHOTO set doc_file = BFILENAME('MEDIA_DIR', 'test2.docx') where photo_id = 9;
commit;



select user from dual
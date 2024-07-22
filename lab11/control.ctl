LOAD DATA
INFILE 'E:\univer\DB\lab11\oimp.csv'
APPEND
INTO TABLE Ordered_SERVICES
FIELDS TERMINATED BY ","
(
    service_type_id,
    service_guest_id,
    service_start_date Date "DD/MM/YYYY",
    service_end_date Date "DD/MM/YYYY",
    service_PRICE "ROUND(:service_PRICE,1)" ,
    service_status "UPPER(:service_status)"
)
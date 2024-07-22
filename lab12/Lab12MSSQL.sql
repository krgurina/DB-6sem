select * from  
				  SERVICE_TYPES st 
				  JOIN SERVICES s ON s.service_id=st.service_type_id
				  JOIN GUESTS g ON s.service_guest_id=g.guest_id
select * from Report


--1

create table Report (
id INTEGER primary key identity(1,1),
xml_column XML
);

drop table Report;
--select * from Movies


--2.	Создайте процедуру генерации XML

--drop function generateXML

	CREATE FUNCTION generateXML()
	RETURNS XML
	AS
	BEGIN
		DECLARE @x XML;
		SET @x = (
			SELECT 
			s.service_id AS "@ServiceId",
			st.service_type_name AS "serviceT/name", 
			st.service_type_id AS "serviceT/serviceTId",
			g.guest_id as "guest/guestId",
			g.guest_name AS "guest/name",

			
		  GETDATE() AS "Дата"
				FROM 
				  SERVICE_TYPES st 
				  JOIN SERVICES s ON s.service_id=st.service_type_id
				  JOIN GUESTS g ON s.service_guest_id=g.guest_id
				FOR XML PATH('Service')
		);
		RETURN @x;
	END;
	GO


DECLARE @xmlData XML;
SET @xmlData = dbo.generateXML();
SELECT @xmlData AS XMLData;


--3.	Создайте процедуру вставки этого XML в таблицу Report.
create procedure InsertInReport
as
DECLARE @xmlData XML; 
SET @xmlData = dbo.generateXML()
insert into Report values(@xmlData);
go

  execute InsertInReport
  select * from Report;




--4.	Создайте индекс над XML-столбцом в таблице Report. v
create primary xml index My_XML_Index on Report(xml_column)

create xml index Second_XML_Index on Report(xml_column)
using xml index My_XML_Index for path

--drop index Second_XML_Index on report
--drop index My_XML_Index on report

--запросы для индекса
SELECT xml_column.query('/Service/guest/name') AS [xml_column]
        FROM Report
        FOR XML AUTO, TYPE

SELECT *
FROM Report
WHERE xml_column.exist('/Service/ServiceT/serviceTId')=1
AND xml_column.exist('/Service/guest/Id') =1;


--5.	Создайте процедуру извлечения значений элементов и/или 
--атрибутов из XML -столбца в таблице Report (параметр – значение атрибута или элемента).
select * from Report;
--drop procedure SelectData;

CREATE PROCEDURE SelectData
    @XPath NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = '
        SELECT xml_column.query(''' + @XPath + ''') AS [xml_column]
        FROM Report
        FOR XML AUTO, TYPE
    ';
    EXEC sp_executesql @SQL;
END;

execute SelectData  '/Service/guest/name'







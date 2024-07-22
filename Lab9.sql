drop table ServiceObjTab;

-- Создание типа коллекции для объектных таблиц
CREATE TYPE ServicesTab IS TABLE OF service_type;
CREATE TYPE ServiceTypesTab IS TABLE OF service_type_type;

-- Создание типа объекта с вложенной коллекцией
CREATE TYPE ServiceObj AS OBJECT (
  Services ServicesTab,
  ServiceTypes ServiceTypesTab
);


-- Создание таблицы для хранения объектов типа ServiceObj
  CREATE TABLE ServiceObjTab OF ServiceObj
  NESTED TABLE Services STORE AS ServicesNestedTable1
  NESTED TABLE ServiceTypes STORE AS ServiceTypesNestedTable1;




-- Вставка данных в таблицу
DECLARE
  services ServicesTab := ServicesTab();
  service_types ServiceTypesTab := ServiceTypesTab();
BEGIN
  -- Добавление данных в коллекцию services
  services.EXTEND;
  services(services.COUNT) := service_type(1, 1, 101, TO_DATE('2022-01-01', 'YYYY-MM-DD'), TO_DATE('2022-01-10', 'YYYY-MM-DD'), 100);
  services.EXTEND;
  services(services.COUNT) := service_type(2, 2, 102, TO_DATE('2020-02-01', 'YYYY-MM-DD'), TO_DATE('2022-02-10', 'YYYY-MM-DD'), 150);

  -- Добавление данных в коллекцию service_types
  service_types.EXTEND;
  service_types(service_types.COUNT) := service_type_type(1, 'Service Type 1', 'Description 1', 50);
  service_types.EXTEND;
  service_types(service_types.COUNT) := service_type_type(2, 'Service Type 2', 'Description 2', 75);

  -- Вставка тестовых данных в таблицу ServiceObjTab
  INSERT INTO ServiceObjTab VALUES (ServiceObj(services, service_types));
END;
/

-- Проверка, является ли членом коллекции какой-то произвольный элемент
DECLARE
  service_exists NUMBER;
BEGIN
  SELECT COUNT(*) INTO service_exists
  FROM TABLE(SELECT t.Services FROM ServiceObjTab t)
  WHERE service_id = 10;

  IF service_exists > 0 THEN
    DBMS_OUTPUT.PUT_LINE('Услуга с ID 1 существует в коллекции.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Услуга с ID 1 не существует в коллекции.');
  END IF;
END;
/


--
-- Проверка на пустые коллекции
SELECT * FROM ServiceObjTab WHERE Services IS EMPTY OR ServiceTypes IS EMPTY;



-- Преобразование коллекций в таблицы
SELECT * FROM TABLE(SELECT t.Services FROM ServiceObjTab t);
SELECT * FROM TABLE(SELECT t.ServiceTypes FROM ServiceObjTab t);


--

-- BULK
DECLARE
  TYPE ServiceObjArray IS TABLE OF ServiceObj;
  service_objects ServiceObjArray;
BEGIN
  SELECT VALUE(u) BULK COLLECT INTO service_objects FROM ServiceObjTab u;
  FORALL i IN service_objects.FIRST..service_objects.LAST
    INSERT INTO ServiceObjTab VALUES service_objects(i);
  COMMIT;
END;



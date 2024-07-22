delete from ROOMS;
delete from ROOMS where room_hierarchy='/1/1/1';
delete from ROOMS where room_number=107;


ALTER TABLE ROOMS
ADD room_hierarchy HIERARCHYID;
---------------------------------------------------------------------------------------------


-------------------- вывод всего --------------------
	SELECT *,
		room_hierarchy.ToString() AS Hierarchy, 
		room_hierarchy.GetLevel() AS Level 
	FROM ROOMS;
---------------------------------------------------------------------------------------------
--2
---------------------------------------------------------------------------------------------

DROP PROCEDURE GetSubordinates;

CREATE PROCEDURE GetSubordinates (@id INT) AS
	BEGIN
		DECLARE @h hierarchyid
		SET @h = (SELECT room_hierarchy FROM ROOMS WHERE room_number = @id);

		SELECT 
		room_number,
        room_name,
        room_hierarchy.ToString() AS hierarchy_path,
        room_hierarchy.GetLevel() AS level
		FROM ROOMS
		WHERE room_hierarchy.IsDescendantOf(@h) = 1 AND room_number != @id;
	END

	EXEC GetSubordinates @id = 2;
---------------------------------------------------------------------------------------------
--3
---------------------------------------------------------------------------------------------
--	drop procedure addChild 

create procedure addChild 
@nodeValue hierarchyid,
@IDRoom int
as begin 
	declare @count int;
	set @count = (select count(*) from ROOMS where room_hierarchy.GetAncestor(1) = @nodeValue);
	if @count>0 
	begin
		declare @child hierarchyid;
		select @child = room_hierarchy from ROOMS where room_hierarchy.IsDescendantOf(@nodeValue)=1;
		INSERT INTO ROOMS
		VALUES ( @IDRoom, '40', 1, 50, 'Добавленная 3этаж',@nodeValue.GetDescendant(@child, NULL));
	end;
	else 
	begin
	INSERT INTO ROOMS
		VALUES ( @IDRoom, '40', 1, 50, 'Добавленная 3этаж',@nodeValue.GetDescendant(NULL, NULL));
	end;
end;

exec addChild @nodeValue='/3/',@IDRoom=109
---------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
SELECT *,
		room_hierarchy.ToString() AS Hierarchy, 
		room_hierarchy.GetLevel() AS Level,
		room_hierarchy.GetAncestor(1).ToString() AS Parent
	FROM ROOMS;
---------------------------------------------------------------------------------------------

	drop procedure MoveChild
---------------------------------------------------------------------------------------------
-- 4 
---------------------------------------------------------------------------------------------
CREATE PROCEDURE moveChild 
    @old_parent_hierarchy hierarchyid,
    @new_parent_hierarchy hierarchyid
AS 
BEGIN 
    DECLARE @child hierarchyid;
    DECLARE @currentNode hierarchyid;
	DECLARE @room_id int;
	DECLARE @count int;
    DECLARE room_cur CURSOR FOR
    SELECT room_number
		FROM ROOMS
		WHERE room_hierarchy.GetAncestor(1) = @old_parent_hierarchy;

    OPEN room_cur;
    FETCH NEXT FROM room_cur INTO @room_id;

    WHILE @@FETCH_STATUS = 0
    BEGIN
		set @count = (select count(*) from ROOMS where room_hierarchy.GetAncestor(1) = @new_parent_hierarchy);
		if @count=0 
		begin
			update ROOMS set room_hierarchy = @new_parent_hierarchy.GetDescendant(null,NULL) where room_number = @room_id;
			FETCH NEXT FROM room_cur INTO @room_id;
		end;
		else begin 
			select @child = room_hierarchy from ROOMS where room_hierarchy.IsDescendantOf(@new_parent_hierarchy)=1;
			update ROOMS set room_hierarchy = @new_parent_hierarchy.GetDescendant(@child, NULL) where room_number = @room_id;
			FETCH NEXT FROM room_cur INTO @room_id;
    end;
    END;
    CLOSE room_cur;
    DEALLOCATE room_cur;
END;

---------------------------------------------------------------------------------------------
EXEC MoveChild '/3/', '/1/';
---------------------------------------------------------------------------------------------
SELECT 
		*,
	room_hierarchy.ToString() AS Hierarchy, 
	room_hierarchy.GetLevel() AS Level 
FROM ROOMS;


--------------------------------------------------------------------------------------------


	SELECT 
		*,
		room_hierarchy.ToString() AS Hierarchy, 
		room_hierarchy.GetLevel() AS Level 
	FROM 
		ROOMS;
END;
































---------------------------------------------------------------------------------------------
--корень
INSERT INTO ROOMS (room_number, room_name, room_capacity, room_daily_price, room_description, room_hierarchy) 
VALUES (1, '1 корпус', 0, 0, 'Корень отеля', HIERARCHYID::GetRoot());

--1 детёнок
declare @ManagerNode hierarchyid;
select @ManagerNode=room_hierarchy from ROOMS where room_number = 1;
INSERT INTO ROOMS (room_number, room_name, room_capacity, room_daily_price, room_description, room_hierarchy) 
VALUES (2, '1 этаж', 0, 0, 'Стандартные комнаты', @ManagerNode.GetDescendant(NULL, NULL));

-- 2 детёнок
declare @ManagerNode hierarchyid;
declare @Level hierarchyid;
select @Level = room_hierarchy from ROOMS where room_number = 3;
select @ManagerNode=room_hierarchy from ROOMS where room_number = 1;
INSERT INTO ROOMS (room_number, room_name, room_capacity, room_daily_price, room_description, room_hierarchy) 
VALUES (4, '3 этаж', 0, 0, 'Стандартные комнаты', @ManagerNode.GetDescendant(@Level, NULL));
select * from rooms;

--
declare @ManagerNode hierarchyid;
declare @Level hierarchyid;
select @Level = room_hierarchy from ROOMS where room_number = 3;
select @ManagerNode=room_hierarchy from ROOMS where room_number = 1;
INSERT INTO ROOMS (room_number, room_name, room_capacity, room_daily_price, room_description, room_hierarchy) 
VALUES (4, '3 этаж', 0, 0, 'Полулюкс', @ManagerNode.GetDescendant(@Level, NULL));

--крыло 1
declare @ManagerNode hierarchyid;
select @ManagerNode=room_hierarchy from ROOMS where room_number = 3;
INSERT INTO ROOMS (room_number, room_name, room_capacity, room_daily_price, room_description, room_hierarchy) 
VALUES (7, 'Южное крыло', 0, 0, 'Стандартные комнаты(Южное крыло)', @ManagerNode.GetDescendant(NULL, NULL));

--крыло 2
declare @ManagerNode hierarchyid;
declare @Level hierarchyid;
select @Level = room_hierarchy from ROOMS where room_number = 7;
select @ManagerNode=room_hierarchy from ROOMS where room_number = 3;
INSERT INTO ROOMS (room_number, room_name, room_capacity, room_daily_price, room_description, room_hierarchy) 
VALUES (8, 'Северное крыло', 0, 0, 'Стандартные комнаты(Северное крыло)', @ManagerNode.GetDescendant(@Level, NULL));

--комнаты
--1
declare @ManagerNode hierarchyid;
select @ManagerNode=room_hierarchy from ROOMS where room_number = 6;
INSERT INTO ROOMS (room_number, room_name, room_capacity, room_daily_price, room_description, room_hierarchy) 
VALUES (151, '151', 2, 100, 'Стандарт', @ManagerNode.GetDescendant(NULL, NULL));

--2
declare @ManagerNode hierarchyid;
declare @Level hierarchyid;
select @Level = room_hierarchy from ROOMS where room_number = 153;
select @ManagerNode=room_hierarchy from ROOMS where room_number = 6;
INSERT INTO ROOMS (room_number, room_name, room_capacity, room_daily_price, room_description, room_hierarchy) 
VALUES (154, '154', 3, 100, 'Стандарт', @ManagerNode.GetDescendant(@Level, NULL));

--3
declare @ManagerNode hierarchyid;
declare @Level hierarchyid;
select @Level = room_hierarchy from ROOMS where room_number = 102;
select @ManagerNode=room_hierarchy from ROOMS where room_number = 5;
INSERT INTO ROOMS (room_number, room_name, room_capacity, room_daily_price, room_description, room_hierarchy) 
VALUES (103, '103', 3, 100, 'Стандарт', @ManagerNode.GetDescendant(@Level, NULL));




select * from rooms;




declare @ManagerNode hierarchyid;
declare @Level hierarchyid;
select @Level = room_hierarchy from ROOMS where room_number = 22;
select @ManagerNode=room_hierarchy from ROOMS where room_number = 2;
INSERT INTO ROOMS (room_number, room_name, room_capacity, room_daily_price, room_description, room_hierarchy) 
VALUES (202, '202', 2, 100, 'Standard', @ManagerNode.GetDescendant(@Level, NULL));


declare @Level hierarchyid;
select @Level = room_hierarchy from ROOMS where room_number = 23;
INSERT INTO ROOMS (room_number, room_name, room_capacity, room_daily_price, room_description, room_hierarchy) 
VALUES (230, '230', 3, 150, 'Standard', @Level.GetDescendant(Null, NULL));


declare @Level hierarchyid;
declare @child hierarchyid;
select @Level = room_hierarchy from ROOMS where room_number = 202;
select @child = room_hierarchy from ROOMS where room_number = 103;
INSERT INTO ROOMS (room_number, room_name, room_capacity, room_daily_price, room_description, room_hierarchy) 
VALUES (3036, '3036', 1, 50, 'Single Room', @Level.GetDescendant(@child, NULL));





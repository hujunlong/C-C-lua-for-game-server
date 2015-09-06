delimiter $$
drop procedure if exists GetAllTownItems  $$
create procedure GetAllTownItems(_uid int)
L:
begin
	select * from function_building where player=_uid;
	select * from business_building where player=_uid;
	select * from decoration where player=_uid;
	select * from road where player=_uid;
end L $$

DELIMITER ;
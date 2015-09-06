delimiter $$
drop procedure if exists GetPlayerBasicInfo  $$
create procedure GetPlayerBasicInfo(_uid int)
L:
begin
	select * from base_info where player=_uid;
end L $$

DELIMITER ;
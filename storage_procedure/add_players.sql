
delimiter $$
drop procedure if exists add_players  $$
create procedure add_players(_id_start int, _id_end int)
begin
	repeat
		insert into base_info (player,nickname) values(_id_start, _id_start);
		insert into town (player,blocks) values(_id_start, 0x000000000000000000000000000e0f000000001415000000000000000000000000000000);
		insert into prop_setting (player,bag_grids_count,warehouse_grids_count) values(_id_start,24,27);
		set _id_start = _id_start+1;
	UNTIL _id_start>=_id_end
	end repeat;
end $$
DELIMITER ;
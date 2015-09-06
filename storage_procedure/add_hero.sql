delimiter $$
drop procedure if exists add_heros  $$
create procedure add_heros(_id_start int, _id_end int)
begin
	repeat
		insert into hero (player,id) values(_id_start,1);
		insert into hero (player,id) values(_id_start,2);
		set _id_start = _id_start+1;
	UNTIL _id_start>=_id_end
	end repeat;
end $$
DELIMITER ;
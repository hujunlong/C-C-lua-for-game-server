delimiter $$
drop procedure if exists create_player  $$
create procedure create_player(_id int , _name char(6), _sex int)
begin
		insert into base_info (player,nickname, sex, progress, gold, silver) values(_id, _name, _sex,1, 100, 1000000);
		insert into town (player,blocks) values(_id, 0x000000000000000000000000000e0f000000001415000000000000000000000000000000);
		insert into prop_setting (player,bag_grids_count,warehouse_grids_count) values(_id,20,20);
		insert into hero (player,id,location) values(_id,17,2);
		insert into hero (player,id,location) values(_id,21,5);
		insert into skill (player,id,level) values(_id,12,1);
		insert into status(player) values(_id);
		insert into settings (player) values(_id);
		insert into prop (player, id, location, amount, kind, area) values(_id, 1, 3,1,39,3);
		insert into equipment (player, id, hero, equiped) values(_id,1,17,1);
		insert into prop (player, id, location, amount, kind, area) values(_id, 2, 3,1,41,3);
		insert into equipment (player, id, hero,equiped) values(_id,2,21,1);
		
		INSERT INTO `decoration` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '9', '3003', '26', '0', '0', '50');
		INSERT INTO `decoration` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '23', '3004', '28', '0', '0', '56');
		INSERT INTO `decoration` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '19', '3003', '27', '0', '0', '65');
		INSERT INTO `decoration` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '13', '3004', '27', '0', '0', '71');
		INSERT INTO `decoration` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '12', '3003', '22', '0', '0', '79');
		INSERT INTO `decoration` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '22', '3003', '23', '0', '0', '80');
		INSERT INTO `decoration` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '15', '3004', '19', '0', '0', '82');
		INSERT INTO `decoration` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '13', '3023', '22', '0', '0', '92');
		INSERT INTO `function_building` (`level`, `x`, `id`, `y`, `aspect`, `player`, `kind`, `progress`, `last_reap`) VALUES ('1', '16', '1', '17', '3', _id, '1001', '6', '1354958724');
		INSERT INTO `function_building` (`level`, `x`, `id`, `y`, `aspect`, `player`, `kind`, `progress`, `last_reap`) VALUES ('3', '10', '2', '23', '0', _id, '1007', '1', '1354958724');
		INSERT INTO `function_building` (`level`, `x`, `id`, `y`, `aspect`, `player`, `kind`, `progress`, `last_reap`) VALUES ('1', '10', '3', '16', '3', _id, '1017', '1', '1354958724');
		INSERT INTO `road` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '14', '3013', '24', '0', '1', '7');
		INSERT INTO `road` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '14', '3013', '22', '0', '1', '8');
		INSERT INTO `road` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '16', '3013', '20', '0', '0', '12');
		INSERT INTO `road` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '18', '3013', '20', '0', '0', '13');
		INSERT INTO `road` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '14', '3012', '30', '0', '1', '27');
		INSERT INTO `road` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '22', '3012', '20', '0', '2', '29');
		INSERT INTO `road` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '20', '3013', '28', '0', '1', '42');
		INSERT INTO `road` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '20', '3015', '20', '0', '3', '44');
		INSERT INTO `road` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '20', '3013', '24', '0', '1', '45');
		INSERT INTO `road` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '20', '3013', '22', '0', '1', '46');
		INSERT INTO `road` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '14', '3013', '28', '0', '1', '48');
		INSERT INTO `road` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '20', '3012', '30', '0', '1', '72');
		INSERT INTO `road` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '10', '3012', '20', '0', '0', '75');
		INSERT INTO `road` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '14', '3015', '20', '0', '3', '76');
		INSERT INTO `road` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '12', '3013', '20', '0', '0', '81');
		INSERT INTO `road` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '20', '3013', '26', '0', '1', '95');
		INSERT INTO `road` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '14', '3013', '26', '0', '1', '98');

end $$
DELIMITER ;
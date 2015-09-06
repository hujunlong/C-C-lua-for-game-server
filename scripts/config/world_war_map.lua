local world_map = {}
world_map[10] =
{
name = "阿贝斯山脉",
country = 1,
adjacent_maps = {6,7,13,14},
weather_probability = {cloudy=0.4,rain=0.2,fog=0.4},
locations = {},
retention = fasle,
}
world_map[10].locations[2] =
{
    adjacent_locations={3,94,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[10].locations[3] =
{
    adjacent_locations={2,55,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[10].locations[6] =
{
    adjacent_locations={10,7,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[10].locations[7] =
{
    adjacent_locations={6,8,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[10].locations[8] =
{
    adjacent_locations={7,9,},
    terrain = 'plain',
    born = false,
    reborn = true,
    default = 0,
}
world_map[10].locations[9] =
{
    adjacent_locations={8,16,},
    terrain = 'cave',
    born = false,
    reborn = false,
    default = 0,
}
world_map[10].locations[10] =
{
    adjacent_locations={6,11,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[10].locations[11] =
{
    adjacent_locations={10,12,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[10].locations[12] =
{
    adjacent_locations={11,96,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[10].locations[16] =
{
    adjacent_locations={9,17,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[10].locations[17] =
{
    adjacent_locations={16,18,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[10].locations[18] =
{
    adjacent_locations={17,19,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[10].locations[19] =
{
    adjacent_locations={18,20,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[10].locations[20] =
{
    adjacent_locations={19,21,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[10].locations[21] =
{
    adjacent_locations={20,22,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[10].locations[22] =
{
    adjacent_locations={21,23,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[10].locations[23] =
{
    adjacent_locations={22,24,},
    terrain = 'forest',
    born = false,
    reborn = true,
    default = 1,
}
world_map[10].locations[24] =
{
    adjacent_locations={23,26,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[10].locations[25] =
{
    adjacent_locations={26,30,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[10].locations[26] =
{
    adjacent_locations={25,24,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[10].locations[30] =
{
    adjacent_locations={25,31,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[10].locations[31] =
{
    adjacent_locations={30,},
    terrain = 'mountain',
    born = true,
    reborn = true,
    default = 1,
}
world_map[10].locations[35] =
{
    adjacent_locations={36,},
    terrain = 'forest',
    born = false,
    reborn = true,
    default = 1,
}
world_map[10].locations[36] =
{
    adjacent_locations={35,37,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[10].locations[37] =
{
    adjacent_locations={36,38,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[10].locations[38] =
{
    adjacent_locations={37,98,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[10].locations[45] =
{
    adjacent_locations={79,46,},
    terrain = 'mountain',
    born = false,
    reborn = true,
    default = 1,
}
world_map[10].locations[46] =
{
    adjacent_locations={45,47,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[10].locations[47] =
{
    adjacent_locations={46,48,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[10].locations[48] =
{
    adjacent_locations={47,49,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[10].locations[49] =
{
    adjacent_locations={48,50,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[10].locations[50] =
{
    adjacent_locations={49,92,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[10].locations[51] =
{
    adjacent_locations={52,92,},
    terrain = 'cave',
    born = false,
    reborn = false,
    default = 0,
}
world_map[10].locations[52] =
{
    adjacent_locations={51,53,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[10].locations[53] =
{
    adjacent_locations={52,54,56,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[10].locations[54] =
{
    adjacent_locations={53,93,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[10].locations[55] =
{
    adjacent_locations={3,93,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[10].locations[56] =
{
    adjacent_locations={53,88,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[10].locations[59] =
{
    adjacent_locations={60,},
    terrain = 'plain',
    born = true,
    reborn = true,
    default = 0,
}
world_map[10].locations[60] =
{
    adjacent_locations={61,59,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[10].locations[61] =
{
    adjacent_locations={62,60,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[10].locations[62] =
{
    adjacent_locations={63,61,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[10].locations[63] =
{
    adjacent_locations={64,62,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[10].locations[64] =
{
    adjacent_locations={63,65,88,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[10].locations[65] =
{
    adjacent_locations={64,66,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[10].locations[66] =
{
    adjacent_locations={65,67,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[10].locations[67] =
{
    adjacent_locations={66,70,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[10].locations[70] =
{
    adjacent_locations={67,71,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[10].locations[71] =
{
    adjacent_locations={70,72,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[10].locations[72] =
{
    adjacent_locations={71,73,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[10].locations[73] =
{
    adjacent_locations={72,74,},
    terrain = 'mountain',
    born = false,
    reborn = true,
    default = 0,
}
world_map[10].locations[74] =
{
    adjacent_locations={73,75,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[10].locations[75] =
{
    adjacent_locations={74,76,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[10].locations[76] =
{
    adjacent_locations={75,77,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[10].locations[77] =
{
    adjacent_locations={76,91,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[10].locations[78] =
{
    adjacent_locations={79,97,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[10].locations[79] =
{
    adjacent_locations={78,45,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[10].locations[88] =
{
    adjacent_locations={56,64,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[10].locations[91] =
{
    adjacent_locations={77,97,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[10].locations[92] =
{
    adjacent_locations={50,51,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[10].locations[93] =
{
    adjacent_locations={54,55,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[10].locations[94] =
{
    adjacent_locations={2,95,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[10].locations[95] =
{
    adjacent_locations={94,96,},
    terrain = 'forest',
    born = false,
    reborn = true,
    default = 0,
}
world_map[10].locations[96] =
{
    adjacent_locations={95,12,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[10].locations[97] =
{
    adjacent_locations={91,98,78,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[10].locations[98] =
{
    adjacent_locations={97,38,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[11] =
{
name = "弗瑞尔盆地",
country = 3,
adjacent_maps = {7,8,9},
weather_probability = {cloudy=1},
locations = {},
retention = fasle,
}
world_map[11].locations[6] =
{
    adjacent_locations={9,73,},
    terrain = 'plain',
    born = false,
    reborn = true,
    default = 0,
}
world_map[11].locations[9] =
{
    adjacent_locations={6,10,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[11].locations[10] =
{
    adjacent_locations={9,11,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[11].locations[11] =
{
    adjacent_locations={10,12,33,47,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[11].locations[12] =
{
    adjacent_locations={11,13,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[11].locations[13] =
{
    adjacent_locations={14,12,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[11].locations[14] =
{
    adjacent_locations={13,15,17,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[11].locations[15] =
{
    adjacent_locations={14,},
    terrain = 'mountain',
    born = true,
    reborn = true,
    default = 0,
}
world_map[11].locations[17] =
{
    adjacent_locations={14,18,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[11].locations[18] =
{
    adjacent_locations={17,19,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[11].locations[19] =
{
    adjacent_locations={18,20,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[11].locations[20] =
{
    adjacent_locations={19,21,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[11].locations[21] =
{
    adjacent_locations={20,27,},
    terrain = 'plain',
    born = false,
    reborn = true,
    default = 0,
}
world_map[11].locations[27] =
{
    adjacent_locations={21,28,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[11].locations[28] =
{
    adjacent_locations={27,29,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[11].locations[29] =
{
    adjacent_locations={28,34,30,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[11].locations[30] =
{
    adjacent_locations={29,31,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[11].locations[31] =
{
    adjacent_locations={30,32,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[11].locations[32] =
{
    adjacent_locations={31,33,},
    terrain = 'forest',
    born = false,
    reborn = true,
    default = 0,
}
world_map[11].locations[33] =
{
    adjacent_locations={32,11,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[11].locations[34] =
{
    adjacent_locations={29,35,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[11].locations[35] =
{
    adjacent_locations={34,36,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[11].locations[36] =
{
    adjacent_locations={35,37,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[11].locations[37] =
{
    adjacent_locations={36,38,48,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[11].locations[38] =
{
    adjacent_locations={37,39,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[11].locations[39] =
{
    adjacent_locations={40,38,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[11].locations[40] =
{
    adjacent_locations={41,39,},
    terrain = 'forest',
    born = false,
    reborn = true,
    default = 1,
}
world_map[11].locations[41] =
{
    adjacent_locations={42,40,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[11].locations[42] =
{
    adjacent_locations={43,41,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[11].locations[43] =
{
    adjacent_locations={44,42,99,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[11].locations[44] =
{
    adjacent_locations={45,43,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[11].locations[45] =
{
    adjacent_locations={46,44,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[11].locations[46] =
{
    adjacent_locations={47,45,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[11].locations[47] =
{
    adjacent_locations={11,46,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[11].locations[48] =
{
    adjacent_locations={37,49,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[11].locations[49] =
{
    adjacent_locations={48,50,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[11].locations[50] =
{
    adjacent_locations={49,51,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[11].locations[51] =
{
    adjacent_locations={50,52,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[11].locations[52] =
{
    adjacent_locations={51,53,},
    terrain = 'plain',
    born = false,
    reborn = true,
    default = 1,
}
world_map[11].locations[53] =
{
    adjacent_locations={52,54,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[11].locations[54] =
{
    adjacent_locations={53,55,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[11].locations[55] =
{
    adjacent_locations={54,56,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[11].locations[56] =
{
    adjacent_locations={55,57,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[11].locations[57] =
{
    adjacent_locations={56,61,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[11].locations[61] =
{
    adjacent_locations={57,62,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[11].locations[62] =
{
    adjacent_locations={61,90,63,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[11].locations[63] =
{
    adjacent_locations={62,64,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[11].locations[64] =
{
    adjacent_locations={63,94,101,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[11].locations[65] =
{
    adjacent_locations={66,101,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[11].locations[66] =
{
    adjacent_locations={65,67,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[11].locations[67] =
{
    adjacent_locations={66,68,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[11].locations[68] =
{
    adjacent_locations={67,69,},
    terrain = 'forest',
    born = false,
    reborn = true,
    default = 0,
}
world_map[11].locations[69] =
{
    adjacent_locations={68,70,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[11].locations[70] =
{
    adjacent_locations={69,71,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[11].locations[71] =
{
    adjacent_locations={70,72,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[11].locations[72] =
{
    adjacent_locations={71,73,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[11].locations[73] =
{
    adjacent_locations={72,6,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[11].locations[90] =
{
    adjacent_locations={62,91,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[11].locations[91] =
{
    adjacent_locations={90,},
    terrain = 'plain',
    born = true,
    reborn = true,
    default = 1,
}
world_map[11].locations[94] =
{
    adjacent_locations={95,64,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[11].locations[95] =
{
    adjacent_locations={96,94,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[11].locations[96] =
{
    adjacent_locations={97,95,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[11].locations[97] =
{
    adjacent_locations={98,96,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[11].locations[98] =
{
    adjacent_locations={99,97,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[11].locations[99] =
{
    adjacent_locations={43,98,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[11].locations[101] =
{
    adjacent_locations={64,65,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[12] =
{
name = "卢西亚沼泽",
country = 2,
adjacent_maps = {5,6,8},
weather_probability = {cloudy=0.4,rain=0.2,fog=0.4},
locations = {},
retention = fasle,
}
world_map[12].locations[3] =
{
    adjacent_locations={4,46,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[12].locations[4] =
{
    adjacent_locations={3,6,},
    terrain = 'mountain',
    born = true,
    reborn = true,
    default = 0,
}
world_map[12].locations[6] =
{
    adjacent_locations={4,7,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[12].locations[7] =
{
    adjacent_locations={6,8,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[12].locations[8] =
{
    adjacent_locations={7,9,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[12].locations[9] =
{
    adjacent_locations={8,10,19,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[12].locations[10] =
{
    adjacent_locations={9,11,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[12].locations[11] =
{
    adjacent_locations={10,12,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[12].locations[12] =
{
    adjacent_locations={11,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[12].locations[19] =
{
    adjacent_locations={9,20,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[12].locations[20] =
{
    adjacent_locations={19,21,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[12].locations[21] =
{
    adjacent_locations={20,22,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[12].locations[22] =
{
    adjacent_locations={21,23,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[12].locations[23] =
{
    adjacent_locations={22,24,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[12].locations[24] =
{
    adjacent_locations={23,25,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[12].locations[25] =
{
    adjacent_locations={24,26,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[12].locations[26] =
{
    adjacent_locations={25,27,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[12].locations[27] =
{
    adjacent_locations={26,28,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[12].locations[28] =
{
    adjacent_locations={27,29,},
    terrain = 'forest',
    born = false,
    reborn = true,
    default = 0,
}
world_map[12].locations[29] =
{
    adjacent_locations={28,30,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[12].locations[30] =
{
    adjacent_locations={29,68,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[12].locations[41] =
{
    adjacent_locations={42,47,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[12].locations[42] =
{
    adjacent_locations={41,43,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[12].locations[43] =
{
    adjacent_locations={42,44,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[12].locations[44] =
{
    adjacent_locations={43,45,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[12].locations[45] =
{
    adjacent_locations={44,46,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[12].locations[46] =
{
    adjacent_locations={45,3,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[12].locations[47] =
{
    adjacent_locations={41,48,},
    terrain = 'lake',
    born = false,
    reborn = true,
    default = 0,
}
world_map[12].locations[48] =
{
    adjacent_locations={47,49,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[12].locations[49] =
{
    adjacent_locations={48,50,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[12].locations[50] =
{
    adjacent_locations={49,51,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[12].locations[51] =
{
    adjacent_locations={50,52,},
    terrain = 'lake',
    born = false,
    reborn = true,
    default = 1,
}
world_map[12].locations[52] =
{
    adjacent_locations={51,65,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 1,
}
world_map[12].locations[60] =
{
    adjacent_locations={61,99,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[12].locations[61] =
{
    adjacent_locations={60,62,},
    terrain = 'mountain',
    born = false,
    reborn = true,
    default = 1,
}
world_map[12].locations[62] =
{
    adjacent_locations={61,63,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[12].locations[63] =
{
    adjacent_locations={62,64,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[12].locations[64] =
{
    adjacent_locations={63,65,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[12].locations[65] =
{
    adjacent_locations={64,66,52,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 1,
}
world_map[12].locations[66] =
{
    adjacent_locations={65,67,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 1,
}
world_map[12].locations[67] =
{
    adjacent_locations={66,68,69,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[12].locations[68] =
{
    adjacent_locations={67,30,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[12].locations[69] =
{
    adjacent_locations={67,70,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 1,
}
world_map[12].locations[70] =
{
    adjacent_locations={69,71,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 1,
}
world_map[12].locations[71] =
{
    adjacent_locations={70,72,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 1,
}
world_map[12].locations[72] =
{
    adjacent_locations={71,73,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 1,
}
world_map[12].locations[73] =
{
    adjacent_locations={72,81,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 1,
}
world_map[12].locations[81] =
{
    adjacent_locations={73,82,},
    terrain = 'lake',
    born = false,
    reborn = true,
    default = 1,
}
world_map[12].locations[82] =
{
    adjacent_locations={81,83,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 1,
}
world_map[12].locations[83] =
{
    adjacent_locations={82,84,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 1,
}
world_map[12].locations[84] =
{
    adjacent_locations={83,85,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 1,
}
world_map[12].locations[85] =
{
    adjacent_locations={84,87,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 1,
}
world_map[12].locations[87] =
{
    adjacent_locations={88,85,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[12].locations[88] =
{
    adjacent_locations={89,87,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[12].locations[89] =
{
    adjacent_locations={90,88,},
    terrain = 'mountain',
    born = false,
    reborn = true,
    default = 1,
}
world_map[12].locations[90] =
{
    adjacent_locations={91,89,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 1,
}
world_map[12].locations[91] =
{
    adjacent_locations={90,106,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 1,
}
world_map[12].locations[99] =
{
    adjacent_locations={60,100,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 1,
}
world_map[12].locations[100] =
{
    adjacent_locations={99,101,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 1,
}
world_map[12].locations[101] =
{
    adjacent_locations={100,102,},
    terrain = 'lake',
    born = true,
    reborn = true,
    default = 1,
}
world_map[12].locations[102] =
{
    adjacent_locations={101,103,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 1,
}
world_map[12].locations[103] =
{
    adjacent_locations={102,104,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[12].locations[104] =
{
    adjacent_locations={103,109,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[12].locations[105] =
{
    adjacent_locations={106,109,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[12].locations[106] =
{
    adjacent_locations={105,91,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[12].locations[109] =
{
    adjacent_locations={104,105,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[13] =
{
name = "潘达废墟",
country = 1,
adjacent_maps = {10,11,12},
weather_probability = {cloudy=0.4,rain=0.2,fog=0.4},
locations = {},
retention = fasle,
}
world_map[13].locations[1] =
{
    adjacent_locations={2,},
    terrain = 'forest',
    born = false,
    reborn = true,
    default = 0,
}
world_map[13].locations[2] =
{
    adjacent_locations={1,3,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[13].locations[3] =
{
    adjacent_locations={2,4,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[13].locations[4] =
{
    adjacent_locations={3,5,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[13].locations[5] =
{
    adjacent_locations={4,6,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[13].locations[6] =
{
    adjacent_locations={5,7,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[13].locations[7] =
{
    adjacent_locations={6,8,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[13].locations[8] =
{
    adjacent_locations={7,9,14,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[13].locations[9] =
{
    adjacent_locations={8,10,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[13].locations[10] =
{
    adjacent_locations={9,11,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[13].locations[11] =
{
    adjacent_locations={10,12,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[13].locations[12] =
{
    adjacent_locations={11,13,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[13].locations[13] =
{
    adjacent_locations={12,},
    terrain = 'plain',
    born = true,
    reborn = true,
    default = 0,
}
world_map[13].locations[14] =
{
    adjacent_locations={8,15,16,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[13].locations[15] =
{
    adjacent_locations={14,25,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[13].locations[16] =
{
    adjacent_locations={14,17,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[13].locations[17] =
{
    adjacent_locations={16,18,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[13].locations[18] =
{
    adjacent_locations={17,19,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[13].locations[19] =
{
    adjacent_locations={18,20,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[13].locations[20] =
{
    adjacent_locations={19,53,},
    terrain = 'wasteland',
    born = false,
    reborn = true,
    default = 0,
}
world_map[13].locations[25] =
{
    adjacent_locations={15,26,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[13].locations[26] =
{
    adjacent_locations={25,27,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[13].locations[27] =
{
    adjacent_locations={26,33,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[13].locations[33] =
{
    adjacent_locations={27,34,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[13].locations[34] =
{
    adjacent_locations={33,35,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[13].locations[35] =
{
    adjacent_locations={34,64,36,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[13].locations[36] =
{
    adjacent_locations={35,37,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[13].locations[37] =
{
    adjacent_locations={38,36,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[13].locations[38] =
{
    adjacent_locations={43,37,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[13].locations[43] =
{
    adjacent_locations={44,38,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[13].locations[44] =
{
    adjacent_locations={45,43,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[13].locations[45] =
{
    adjacent_locations={46,44,},
    terrain = 'citadel',
    born = false,
    reborn = true,
    default = 1,
}
world_map[13].locations[46] =
{
    adjacent_locations={47,45,},
    terrain = 'citadel',
    born = false,
    reborn = false,
    default = 1,
}
world_map[13].locations[47] =
{
    adjacent_locations={57,46,},
    terrain = 'citadel',
    born = false,
    reborn = false,
    default = 1,
}
world_map[13].locations[53] =
{
    adjacent_locations={20,54,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[13].locations[54] =
{
    adjacent_locations={53,55,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[13].locations[55] =
{
    adjacent_locations={54,56,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[13].locations[56] =
{
    adjacent_locations={55,57,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[13].locations[57] =
{
    adjacent_locations={56,58,47,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[13].locations[58] =
{
    adjacent_locations={57,59,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[13].locations[59] =
{
    adjacent_locations={58,60,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[13].locations[60] =
{
    adjacent_locations={59,61,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[13].locations[61] =
{
    adjacent_locations={90,60,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[13].locations[64] =
{
    adjacent_locations={35,65,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[13].locations[65] =
{
    adjacent_locations={64,66,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[13].locations[66] =
{
    adjacent_locations={65,68,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[13].locations[68] =
{
    adjacent_locations={66,69,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[13].locations[69] =
{
    adjacent_locations={68,70,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[13].locations[70] =
{
    adjacent_locations={69,71,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[13].locations[71] =
{
    adjacent_locations={70,73,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[13].locations[73] =
{
    adjacent_locations={71,74,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 1,
}
world_map[13].locations[74] =
{
    adjacent_locations={73,75,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[13].locations[75] =
{
    adjacent_locations={74,76,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 1,
}
world_map[13].locations[76] =
{
    adjacent_locations={75,77,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[13].locations[77] =
{
    adjacent_locations={76,78,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[13].locations[78] =
{
    adjacent_locations={77,79,86,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[13].locations[79] =
{
    adjacent_locations={78,82,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[13].locations[82] =
{
    adjacent_locations={79,83,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 1,
}
world_map[13].locations[83] =
{
    adjacent_locations={82,84,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[13].locations[84] =
{
    adjacent_locations={83,85,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[13].locations[85] =
{
    adjacent_locations={84,},
    terrain = 'mountain',
    born = true,
    reborn = true,
    default = 1,
}
world_map[13].locations[86] =
{
    adjacent_locations={78,87,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[13].locations[87] =
{
    adjacent_locations={86,88,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[13].locations[88] =
{
    adjacent_locations={87,89,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[13].locations[89] =
{
    adjacent_locations={88,90,},
    terrain = 'forest',
    born = false,
    reborn = true,
    default = 1,
}
world_map[13].locations[90] =
{
    adjacent_locations={89,61,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[14] =
{
name = "阿克提克冰原",
country = 1,
adjacent_maps = {2,4,10},
weather_probability = {cloudy=0.2,snow=0.8},
locations = {},
retention = fasle,
}
world_map[14].locations[1] =
{
    adjacent_locations={2,},
    terrain = 'citadel',
    born = true,
    reborn = true,
    default = 0,
}
world_map[14].locations[2] =
{
    adjacent_locations={1,3,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[14].locations[3] =
{
    adjacent_locations={2,4,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[14].locations[4] =
{
    adjacent_locations={3,6,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[14].locations[6] =
{
    adjacent_locations={4,7,32,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[14].locations[7] =
{
    adjacent_locations={6,8,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[14].locations[8] =
{
    adjacent_locations={7,9,21,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[14].locations[9] =
{
    adjacent_locations={8,10,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[14].locations[10] =
{
    adjacent_locations={9,11,},
    terrain = 'coastal',
    born = false,
    reborn = false,
    default = 0,
}
world_map[14].locations[11] =
{
    adjacent_locations={10,},
    terrain = 'forest',
    born = false,
    reborn = true,
    default = 0,
}
world_map[14].locations[21] =
{
    adjacent_locations={8,22,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[14].locations[22] =
{
    adjacent_locations={21,23,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[14].locations[23] =
{
    adjacent_locations={22,24,},
    terrain = 'coastal',
    born = false,
    reborn = false,
    default = 0,
}
world_map[14].locations[24] =
{
    adjacent_locations={23,25,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[14].locations[25] =
{
    adjacent_locations={24,26,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[14].locations[26] =
{
    adjacent_locations={25,27,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[14].locations[27] =
{
    adjacent_locations={26,28,62,},
    terrain = 'forest',
    born = false,
    reborn = true,
    default = 0,
}
world_map[14].locations[28] =
{
    adjacent_locations={27,29,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[14].locations[29] =
{
    adjacent_locations={63,28,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[14].locations[32] =
{
    adjacent_locations={33,6,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[14].locations[33] =
{
    adjacent_locations={32,41,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[14].locations[41] =
{
    adjacent_locations={33,42,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[14].locations[42] =
{
    adjacent_locations={41,43,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[14].locations[43] =
{
    adjacent_locations={42,44,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[14].locations[44] =
{
    adjacent_locations={43,51,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[14].locations[51] =
{
    adjacent_locations={57,44,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[14].locations[57] =
{
    adjacent_locations={58,51,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[14].locations[58] =
{
    adjacent_locations={59,97,57,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[14].locations[59] =
{
    adjacent_locations={60,58,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[14].locations[60] =
{
    adjacent_locations={61,59,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[14].locations[61] =
{
    adjacent_locations={62,60,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[14].locations[62] =
{
    adjacent_locations={61,27,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[14].locations[63] =
{
    adjacent_locations={64,29,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[14].locations[64] =
{
    adjacent_locations={65,63,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[14].locations[65] =
{
    adjacent_locations={66,85,64,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[14].locations[66] =
{
    adjacent_locations={67,65,},
    terrain = 'coastal',
    born = false,
    reborn = false,
    default = 1,
}
world_map[14].locations[67] =
{
    adjacent_locations={68,66,},
    terrain = 'coastal',
    born = false,
    reborn = false,
    default = 1,
}
world_map[14].locations[68] =
{
    adjacent_locations={69,67,},
    terrain = 'coastal',
    born = false,
    reborn = false,
    default = 1,
}
world_map[14].locations[69] =
{
    adjacent_locations={70,68,},
    terrain = 'coastal',
    born = false,
    reborn = false,
    default = 1,
}
world_map[14].locations[70] =
{
    adjacent_locations={69,},
    terrain = 'coastal',
    born = false,
    reborn = true,
    default = 1,
}
world_map[14].locations[76] =
{
    adjacent_locations={77,},
    terrain = 'plain',
    born = true,
    reborn = true,
    default = 1,
}
world_map[14].locations[77] =
{
    adjacent_locations={78,76,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[14].locations[78] =
{
    adjacent_locations={79,77,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[14].locations[79] =
{
    adjacent_locations={80,78,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[14].locations[80] =
{
    adjacent_locations={81,79,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[14].locations[81] =
{
    adjacent_locations={82,80,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[14].locations[82] =
{
    adjacent_locations={106,81,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 1,
}
world_map[14].locations[85] =
{
    adjacent_locations={65,86,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[14].locations[86] =
{
    adjacent_locations={85,87,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[14].locations[87] =
{
    adjacent_locations={86,91,116,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[14].locations[91] =
{
    adjacent_locations={92,87,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[14].locations[92] =
{
    adjacent_locations={93,91,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[14].locations[93] =
{
    adjacent_locations={92,94,105,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 1,
}
world_map[14].locations[94] =
{
    adjacent_locations={95,93,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 1,
}
world_map[14].locations[95] =
{
    adjacent_locations={94,96,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 1,
}
world_map[14].locations[96] =
{
    adjacent_locations={97,95,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 1,
}
world_map[14].locations[97] =
{
    adjacent_locations={58,96,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 1,
}
world_map[14].locations[105] =
{
    adjacent_locations={93,106,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 1,
}
world_map[14].locations[106] =
{
    adjacent_locations={105,82,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 1,
}
world_map[14].locations[116] =
{
    adjacent_locations={87,117,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[14].locations[117] =
{
    adjacent_locations={116,118,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 1,
}
world_map[14].locations[118] =
{
    adjacent_locations={117,119,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 1,
}
world_map[14].locations[119] =
{
    adjacent_locations={118,120,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 1,
}
world_map[14].locations[120] =
{
    adjacent_locations={119,121,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 1,
}
world_map[14].locations[121] =
{
    adjacent_locations={120,122,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 1,
}
world_map[14].locations[122] =
{
    adjacent_locations={121,},
    terrain = 'lake',
    born = false,
    reborn = true,
    default = 1,
}
world_map[2] =
{
name = "圣伊格帝国",
country = 1,
adjacent_maps = {5,6,14},
weather_probability = {sunny=0.4,rain=0.2,cloudy=0.4},
locations = {},
retention = true,
}
world_map[3] =
{
name = "古兰克尔",
country = 2,
adjacent_maps = {5,8,9},
weather_probability = {sunny=0.4,rain=0.2,cloudy=0.4},
locations = {},
retention = true,
}
world_map[4] =
{
name = "赛里斯",
country = 3,
adjacent_maps = {7,9,14},
weather_probability = {sunny=0.4,rain=0.2,cloudy=0.4},
locations = {},
retention = true,
}
world_map[5] =
{
name = "微风平原",
country = 2,
adjacent_maps = {2,3,12},
weather_probability = {sunny=0.4,rain=0.3,cloudy=0.3},
locations = {},
retention = fasle,
}
world_map[5].locations[6] =
{
    adjacent_locations={9,7,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[5].locations[7] =
{
    adjacent_locations={6,108,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[5].locations[9] =
{
    adjacent_locations={10,6,},
    terrain = 'citadel',
    born = false,
    reborn = false,
    default = 0,
}
world_map[5].locations[10] =
{
    adjacent_locations={11,9,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[5].locations[11] =
{
    adjacent_locations={13,10,12,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[5].locations[12] =
{
    adjacent_locations={11,65,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[5].locations[13] =
{
    adjacent_locations={14,11,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[5].locations[14] =
{
    adjacent_locations={13,17,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[5].locations[17] =
{
    adjacent_locations={18,14,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[5].locations[18] =
{
    adjacent_locations={19,17,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[5].locations[19] =
{
    adjacent_locations={34,18,20,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[5].locations[20] =
{
    adjacent_locations={19,21,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[5].locations[21] =
{
    adjacent_locations={20,22,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[5].locations[22] =
{
    adjacent_locations={21,23,},
    terrain = 'citadel',
    born = false,
    reborn = false,
    default = 0,
}
world_map[5].locations[23] =
{
    adjacent_locations={22,},
    terrain = 'plain',
    born = true,
    reborn = true,
    default = 0,
}
world_map[5].locations[34] =
{
    adjacent_locations={35,109,19,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[5].locations[35] =
{
    adjacent_locations={36,34,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[5].locations[36] =
{
    adjacent_locations={37,35,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[5].locations[37] =
{
    adjacent_locations={38,36,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[5].locations[38] =
{
    adjacent_locations={39,37,},
    terrain = 'mountain',
    born = false,
    reborn = true,
    default = 0,
}
world_map[5].locations[39] =
{
    adjacent_locations={40,38,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[5].locations[40] =
{
    adjacent_locations={41,39,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[5].locations[41] =
{
    adjacent_locations={49,40,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[5].locations[49] =
{
    adjacent_locations={50,41,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[5].locations[50] =
{
    adjacent_locations={51,49,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[5].locations[51] =
{
    adjacent_locations={52,50,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[5].locations[52] =
{
    adjacent_locations={53,51,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[5].locations[53] =
{
    adjacent_locations={54,52,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[5].locations[54] =
{
    adjacent_locations={107,53,},
    terrain = 'plain',
    born = false,
    reborn = true,
    default = 1,
}
world_map[5].locations[60] =
{
    adjacent_locations={110,61,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[5].locations[61] =
{
    adjacent_locations={62,60,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[5].locations[62] =
{
    adjacent_locations={63,61,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[5].locations[63] =
{
    adjacent_locations={112,62,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[5].locations[64] =
{
    adjacent_locations={81,112,96,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[5].locations[65] =
{
    adjacent_locations={12,66,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[5].locations[66] =
{
    adjacent_locations={65,67,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[5].locations[67] =
{
    adjacent_locations={66,69,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[5].locations[69] =
{
    adjacent_locations={67,70,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[5].locations[70] =
{
    adjacent_locations={69,71,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[5].locations[71] =
{
    adjacent_locations={70,72,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[5].locations[72] =
{
    adjacent_locations={71,73,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[5].locations[73] =
{
    adjacent_locations={72,74,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[5].locations[74] =
{
    adjacent_locations={73,75,},
    terrain = 'citadel',
    born = false,
    reborn = true,
    default = 1,
}
world_map[5].locations[75] =
{
    adjacent_locations={74,76,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[5].locations[76] =
{
    adjacent_locations={75,77,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[5].locations[77] =
{
    adjacent_locations={76,111,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[5].locations[80] =
{
    adjacent_locations={111,81,82,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[5].locations[81] =
{
    adjacent_locations={80,64,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[5].locations[82] =
{
    adjacent_locations={80,83,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[5].locations[83] =
{
    adjacent_locations={82,84,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[5].locations[84] =
{
    adjacent_locations={83,85,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[5].locations[85] =
{
    adjacent_locations={84,86,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[5].locations[86] =
{
    adjacent_locations={85,},
    terrain = 'mountain',
    born = true,
    reborn = true,
    default = 1,
}
world_map[5].locations[96] =
{
    adjacent_locations={64,97,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[5].locations[97] =
{
    adjacent_locations={96,102,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[5].locations[102] =
{
    adjacent_locations={97,103,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[5].locations[103] =
{
    adjacent_locations={102,104,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[5].locations[104] =
{
    adjacent_locations={103,105,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[5].locations[105] =
{
    adjacent_locations={104,106,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[5].locations[106] =
{
    adjacent_locations={105,107,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[5].locations[107] =
{
    adjacent_locations={106,54,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[5].locations[108] =
{
    adjacent_locations={7,},
    terrain = 'forest',
    born = false,
    reborn = true,
    default = 0,
}
world_map[5].locations[109] =
{
    adjacent_locations={34,110,},
    terrain = 'plain',
    born = false,
    reborn = true,
    default = 0,
}
world_map[5].locations[110] =
{
    adjacent_locations={109,60,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[5].locations[111] =
{
    adjacent_locations={77,80,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[5].locations[112] =
{
    adjacent_locations={64,63,},
    terrain = 'plain',
    born = false,
    reborn = true,
    default = 1,
}
world_map[6] =
{
name = "卡塔湖",
country = 1,
adjacent_maps = {2,10,12},
weather_probability = {sunny=0.1,rain=0.6,cloudy=0.3},
locations = {},
retention = fasle,
}
world_map[6].locations[30] =
{
    adjacent_locations={41,31,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[6].locations[31] =
{
    adjacent_locations={30,32,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[6].locations[32] =
{
    adjacent_locations={31,33,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[6].locations[33] =
{
    adjacent_locations={32,35,},
    terrain = 'lake',
    born = true,
    reborn = true,
    default = 0,
}
world_map[6].locations[35] =
{
    adjacent_locations={33,36,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[6].locations[36] =
{
    adjacent_locations={35,37,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[6].locations[37] =
{
    adjacent_locations={36,39,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[6].locations[39] =
{
    adjacent_locations={37,40,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[6].locations[40] =
{
    adjacent_locations={39,133,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[6].locations[41] =
{
    adjacent_locations={30,42,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[6].locations[42] =
{
    adjacent_locations={41,141,43,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[6].locations[43] =
{
    adjacent_locations={146,42,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[6].locations[78] =
{
    adjacent_locations={79,151,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[6].locations[79] =
{
    adjacent_locations={80,78,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[6].locations[80] =
{
    adjacent_locations={88,123,79,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[6].locations[88] =
{
    adjacent_locations={89,80,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[6].locations[89] =
{
    adjacent_locations={90,88,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[6].locations[90] =
{
    adjacent_locations={91,89,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[6].locations[91] =
{
    adjacent_locations={96,90,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[6].locations[96] =
{
    adjacent_locations={97,91,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[6].locations[97] =
{
    adjacent_locations={98,96,},
    terrain = 'forest',
    born = true,
    reborn = true,
    default = 1,
}
world_map[6].locations[98] =
{
    adjacent_locations={99,97,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[6].locations[99] =
{
    adjacent_locations={100,98,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[6].locations[100] =
{
    adjacent_locations={101,99,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[6].locations[101] =
{
    adjacent_locations={104,100,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[6].locations[104] =
{
    adjacent_locations={105,101,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[6].locations[105] =
{
    adjacent_locations={107,104,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[6].locations[107] =
{
    adjacent_locations={110,105,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[6].locations[110] =
{
    adjacent_locations={111,107,},
    terrain = 'mountain',
    born = false,
    reborn = true,
    default = 1,
}
world_map[6].locations[111] =
{
    adjacent_locations={124,110,112,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[6].locations[112] =
{
    adjacent_locations={111,113,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[6].locations[113] =
{
    adjacent_locations={112,114,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[6].locations[114] =
{
    adjacent_locations={113,115,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[6].locations[115] =
{
    adjacent_locations={114,116,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 1,
}
world_map[6].locations[116] =
{
    adjacent_locations={115,117,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 1,
}
world_map[6].locations[117] =
{
    adjacent_locations={118,116,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 1,
}
world_map[6].locations[118] =
{
    adjacent_locations={119,117,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 1,
}
world_map[6].locations[119] =
{
    adjacent_locations={120,118,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 1,
}
world_map[6].locations[120] =
{
    adjacent_locations={121,119,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 1,
}
world_map[6].locations[121] =
{
    adjacent_locations={122,120,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 1,
}
world_map[6].locations[122] =
{
    adjacent_locations={123,121,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[6].locations[123] =
{
    adjacent_locations={80,122,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[6].locations[124] =
{
    adjacent_locations={125,111,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[6].locations[125] =
{
    adjacent_locations={126,124,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[6].locations[126] =
{
    adjacent_locations={127,125,},
    terrain = 'citadel',
    born = false,
    reborn = false,
    default = 0,
}
world_map[6].locations[127] =
{
    adjacent_locations={128,126,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[6].locations[128] =
{
    adjacent_locations={129,127,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[6].locations[129] =
{
    adjacent_locations={130,128,},
    terrain = 'lake',
    born = false,
    reborn = true,
    default = 0,
}
world_map[6].locations[130] =
{
    adjacent_locations={131,129,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[6].locations[131] =
{
    adjacent_locations={132,130,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[6].locations[132] =
{
    adjacent_locations={133,131,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[6].locations[133] =
{
    adjacent_locations={40,134,132,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[6].locations[134] =
{
    adjacent_locations={133,135,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[6].locations[135] =
{
    adjacent_locations={136,134,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[6].locations[136] =
{
    adjacent_locations={137,135,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[6].locations[137] =
{
    adjacent_locations={138,136,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[6].locations[138] =
{
    adjacent_locations={139,137,},
    terrain = 'lake',
    born = false,
    reborn = true,
    default = 0,
}
world_map[6].locations[139] =
{
    adjacent_locations={140,138,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[6].locations[140] =
{
    adjacent_locations={141,139,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[6].locations[141] =
{
    adjacent_locations={42,140,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[6].locations[146] =
{
    adjacent_locations={147,43,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[6].locations[147] =
{
    adjacent_locations={148,146,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[6].locations[148] =
{
    adjacent_locations={149,147,},
    terrain = 'plain',
    born = false,
    reborn = true,
    default = 0,
}
world_map[6].locations[149] =
{
    adjacent_locations={150,148,},
    terrain = 'mountain',
    born = false,
    reborn = true,
    default = 0,
}
world_map[6].locations[150] =
{
    adjacent_locations={151,149,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[6].locations[151] =
{
    adjacent_locations={78,150,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[7] =
{
name = "莫西矿区",
country = 3,
adjacent_maps = {4,10,11},
weather_probability = {sunny=0.4,cloudy=0.4,fog=0.2},
locations = {},
retention = fasle,
}
world_map[7].locations[17] =
{
    adjacent_locations={18,},
    terrain = 'mountain',
    born = false,
    reborn = true,
    default = 0,
}
world_map[7].locations[18] =
{
    adjacent_locations={19,17,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[7].locations[19] =
{
    adjacent_locations={20,18,146,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[7].locations[20] =
{
    adjacent_locations={21,19,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[7].locations[21] =
{
    adjacent_locations={22,20,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[7].locations[22] =
{
    adjacent_locations={21,70,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[7].locations[33] =
{
    adjacent_locations={34,39,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[7].locations[34] =
{
    adjacent_locations={35,33,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[7].locations[35] =
{
    adjacent_locations={36,34,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[7].locations[36] =
{
    adjacent_locations={37,35,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[7].locations[37] =
{
    adjacent_locations={38,36,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[7].locations[38] =
{
    adjacent_locations={37,},
    terrain = 'plain',
    born = true,
    reborn = true,
    default = 0,
}
world_map[7].locations[39] =
{
    adjacent_locations={33,149,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[7].locations[40] =
{
    adjacent_locations={149,41,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[7].locations[41] =
{
    adjacent_locations={40,42,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[7].locations[42] =
{
    adjacent_locations={43,41,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[7].locations[43] =
{
    adjacent_locations={44,42,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[7].locations[44] =
{
    adjacent_locations={45,43,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[7].locations[45] =
{
    adjacent_locations={46,44,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[7].locations[46] =
{
    adjacent_locations={65,45,101,},
    terrain = 'plain',
    born = false,
    reborn = true,
    default = 0,
}
world_map[7].locations[65] =
{
    adjacent_locations={46,66,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[7].locations[66] =
{
    adjacent_locations={65,67,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[7].locations[67] =
{
    adjacent_locations={66,68,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[7].locations[68] =
{
    adjacent_locations={67,69,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[7].locations[69] =
{
    adjacent_locations={74,68,73,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[7].locations[70] =
{
    adjacent_locations={71,22,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[7].locations[71] =
{
    adjacent_locations={72,70,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[7].locations[72] =
{
    adjacent_locations={73,71,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[7].locations[73] =
{
    adjacent_locations={69,72,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[7].locations[74] =
{
    adjacent_locations={75,69,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[7].locations[75] =
{
    adjacent_locations={129,76,74,},
    terrain = 'mountain',
    born = false,
    reborn = true,
    default = 1,
}
world_map[7].locations[76] =
{
    adjacent_locations={75,77,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[7].locations[77] =
{
    adjacent_locations={76,78,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[7].locations[78] =
{
    adjacent_locations={77,79,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[7].locations[79] =
{
    adjacent_locations={78,80,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[7].locations[80] =
{
    adjacent_locations={79,81,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[7].locations[81] =
{
    adjacent_locations={80,82,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[7].locations[82] =
{
    adjacent_locations={81,83,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[7].locations[83] =
{
    adjacent_locations={82,84,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[7].locations[84] =
{
    adjacent_locations={83,85,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[7].locations[85] =
{
    adjacent_locations={84,},
    terrain = 'plain',
    born = true,
    reborn = true,
    default = 1,
}
world_map[7].locations[88] =
{
    adjacent_locations={89,},
    terrain = 'mountain',
    born = false,
    reborn = true,
    default = 1,
}
world_map[7].locations[89] =
{
    adjacent_locations={88,90,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[7].locations[90] =
{
    adjacent_locations={89,92,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[7].locations[92] =
{
    adjacent_locations={90,93,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[7].locations[93] =
{
    adjacent_locations={92,94,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[7].locations[94] =
{
    adjacent_locations={93,95,},
    terrain = 'citadel',
    born = false,
    reborn = false,
    default = 1,
}
world_map[7].locations[95] =
{
    adjacent_locations={94,96,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 1,
}
world_map[7].locations[96] =
{
    adjacent_locations={95,97,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 1,
}
world_map[7].locations[97] =
{
    adjacent_locations={96,98,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 1,
}
world_map[7].locations[98] =
{
    adjacent_locations={97,99,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 1,
}
world_map[7].locations[99] =
{
    adjacent_locations={98,100,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 1,
}
world_map[7].locations[100] =
{
    adjacent_locations={99,102,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[7].locations[101] =
{
    adjacent_locations={46,102,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[7].locations[102] =
{
    adjacent_locations={100,101,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[7].locations[129] =
{
    adjacent_locations={75,130,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[7].locations[130] =
{
    adjacent_locations={129,131,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[7].locations[131] =
{
    adjacent_locations={141,130,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[7].locations[141] =
{
    adjacent_locations={142,131,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[7].locations[142] =
{
    adjacent_locations={143,141,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[7].locations[143] =
{
    adjacent_locations={144,142,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[7].locations[144] =
{
    adjacent_locations={147,143,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[7].locations[145] =
{
    adjacent_locations={146,147,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[7].locations[146] =
{
    adjacent_locations={19,145,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[7].locations[147] =
{
    adjacent_locations={145,144,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[7].locations[149] =
{
    adjacent_locations={39,40,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[8] =
{
name = "赞恩丘陵",
country = 2,
adjacent_maps = {3,11,12,13},
weather_probability = {rain=0.2,cloudy=0.4,fog=0.4},
locations = {},
retention = fasle,
}
world_map[8].locations[2] =
{
    adjacent_locations={3,},
    terrain = 'plain',
    born = false,
    reborn = true,
    default = 0,
}
world_map[8].locations[3] =
{
    adjacent_locations={2,4,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[8].locations[4] =
{
    adjacent_locations={3,5,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[8].locations[5] =
{
    adjacent_locations={4,6,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[8].locations[6] =
{
    adjacent_locations={5,7,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[8].locations[7] =
{
    adjacent_locations={6,8,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[8].locations[8] =
{
    adjacent_locations={7,69,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[8].locations[23] =
{
    adjacent_locations={135,},
    terrain = 'plain',
    born = true,
    reborn = true,
    default = 0,
}
world_map[8].locations[26] =
{
    adjacent_locations={31,},
    terrain = 'plain',
    born = false,
    reborn = true,
    default = 0,
}
world_map[8].locations[31] =
{
    adjacent_locations={41,26,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[8].locations[41] =
{
    adjacent_locations={42,31,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[8].locations[42] =
{
    adjacent_locations={43,41,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[8].locations[43] =
{
    adjacent_locations={44,42,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[8].locations[44] =
{
    adjacent_locations={43,46,55,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[8].locations[46] =
{
    adjacent_locations={47,44,},
    terrain = 'citadel',
    born = false,
    reborn = false,
    default = 1,
}
world_map[8].locations[47] =
{
    adjacent_locations={48,46,},
    terrain = 'citadel',
    born = false,
    reborn = false,
    default = 1,
}
world_map[8].locations[48] =
{
    adjacent_locations={49,47,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[8].locations[49] =
{
    adjacent_locations={50,48,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[8].locations[50] =
{
    adjacent_locations={51,49,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[8].locations[51] =
{
    adjacent_locations={52,50,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[8].locations[52] =
{
    adjacent_locations={53,51,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[8].locations[53] =
{
    adjacent_locations={54,52,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[8].locations[54] =
{
    adjacent_locations={90,53,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[8].locations[55] =
{
    adjacent_locations={44,131,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[8].locations[56] =
{
    adjacent_locations={131,57,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[8].locations[57] =
{
    adjacent_locations={56,58,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[8].locations[58] =
{
    adjacent_locations={57,59,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[8].locations[59] =
{
    adjacent_locations={58,60,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[8].locations[60] =
{
    adjacent_locations={121,61,59,120,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[8].locations[61] =
{
    adjacent_locations={60,62,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[8].locations[62] =
{
    adjacent_locations={61,63,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 1,
}
world_map[8].locations[63] =
{
    adjacent_locations={72,62,64,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[8].locations[64] =
{
    adjacent_locations={65,63,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[8].locations[65] =
{
    adjacent_locations={66,64,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[8].locations[66] =
{
    adjacent_locations={67,65,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[8].locations[67] =
{
    adjacent_locations={68,66,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 0,
}
world_map[8].locations[68] =
{
    adjacent_locations={69,67,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[8].locations[69] =
{
    adjacent_locations={8,68,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[8].locations[72] =
{
    adjacent_locations={73,63,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[8].locations[73] =
{
    adjacent_locations={72,74,},
    terrain = 'forest',
    born = false,
    reborn = false,
    default = 1,
}
world_map[8].locations[74] =
{
    adjacent_locations={73,75,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[8].locations[75] =
{
    adjacent_locations={74,76,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[8].locations[76] =
{
    adjacent_locations={75,77,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[8].locations[77] =
{
    adjacent_locations={76,78,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[8].locations[78] =
{
    adjacent_locations={77,79,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[8].locations[79] =
{
    adjacent_locations={78,},
    terrain = 'mountain',
    born = false,
    reborn = true,
    default = 1,
}
world_map[8].locations[90] =
{
    adjacent_locations={54,},
    terrain = 'mountain',
    born = false,
    reborn = true,
    default = 1,
}
world_map[8].locations[104] =
{
    adjacent_locations={118,117,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[8].locations[105] =
{
    adjacent_locations={106,},
    terrain = 'mountain',
    born = true,
    reborn = true,
    default = 1,
}
world_map[8].locations[106] =
{
    adjacent_locations={105,107,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[8].locations[107] =
{
    adjacent_locations={106,108,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[8].locations[108] =
{
    adjacent_locations={107,109,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[8].locations[109] =
{
    adjacent_locations={108,110,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[8].locations[110] =
{
    adjacent_locations={109,117,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[8].locations[117] =
{
    adjacent_locations={104,110,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[8].locations[118] =
{
    adjacent_locations={119,104,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[8].locations[119] =
{
    adjacent_locations={120,118,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[8].locations[120] =
{
    adjacent_locations={60,119,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[8].locations[121] =
{
    adjacent_locations={122,60,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[8].locations[122] =
{
    adjacent_locations={123,121,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[8].locations[123] =
{
    adjacent_locations={124,122,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[8].locations[124] =
{
    adjacent_locations={125,123,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[8].locations[125] =
{
    adjacent_locations={126,124,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[8].locations[126] =
{
    adjacent_locations={135,125,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[8].locations[131] =
{
    adjacent_locations={55,56,},
    terrain = 'plain',
    born = false,
    reborn = false,
    default = 0,
}
world_map[8].locations[135] =
{
    adjacent_locations={23,126,},
    terrain = 'citadel',
    born = false,
    reborn = false,
    default = 0,
}
world_map[9] =
{
name = "克努努沙漠",
country = 3,
adjacent_maps = {3,4,11},
weather_probability = {sunny=0.8,cloudy=0.2},
locations = {},
retention = fasle,
}
world_map[9].locations[4] =
{
    adjacent_locations={89,5,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[9].locations[5] =
{
    adjacent_locations={4,6,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[9].locations[6] =
{
    adjacent_locations={5,7,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[9].locations[7] =
{
    adjacent_locations={6,8,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[9].locations[8] =
{
    adjacent_locations={7,9,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[9].locations[9] =
{
    adjacent_locations={8,10,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[9].locations[10] =
{
    adjacent_locations={9,11,},
    terrain = 'wasteland',
    born = true,
    reborn = true,
    default = 0,
}
world_map[9].locations[11] =
{
    adjacent_locations={10,12,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[9].locations[12] =
{
    adjacent_locations={11,13,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[9].locations[13] =
{
    adjacent_locations={12,15,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[9].locations[15] =
{
    adjacent_locations={13,16,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[9].locations[16] =
{
    adjacent_locations={15,17,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[9].locations[17] =
{
    adjacent_locations={16,25,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[9].locations[25] =
{
    adjacent_locations={17,26,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[9].locations[26] =
{
    adjacent_locations={25,27,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[9].locations[27] =
{
    adjacent_locations={26,28,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[9].locations[28] =
{
    adjacent_locations={27,29,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 0,
}
world_map[9].locations[29] =
{
    adjacent_locations={28,30,},
    terrain = 'lake',
    born = false,
    reborn = true,
    default = 0,
}
world_map[9].locations[30] =
{
    adjacent_locations={29,31,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 1,
}
world_map[9].locations[31] =
{
    adjacent_locations={30,32,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 1,
}
world_map[9].locations[32] =
{
    adjacent_locations={31,36,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 1,
}
world_map[9].locations[36] =
{
    adjacent_locations={37,32,},
    terrain = 'lake',
    born = false,
    reborn = false,
    default = 1,
}
world_map[9].locations[37] =
{
    adjacent_locations={102,36,38,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 1,
}
world_map[9].locations[38] =
{
    adjacent_locations={37,},
    terrain = 'wasteland',
    born = false,
    reborn = true,
    default = 1,
}
world_map[9].locations[60] =
{
    adjacent_locations={66,61,},
    terrain = 'wasteland',
    born = true,
    reborn = true,
    default = 1,
}
world_map[9].locations[61] =
{
    adjacent_locations={60,62,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 1,
}
world_map[9].locations[62] =
{
    adjacent_locations={61,63,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 1,
}
world_map[9].locations[63] =
{
    adjacent_locations={62,64,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 1,
}
world_map[9].locations[64] =
{
    adjacent_locations={63,70,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 1,
}
world_map[9].locations[66] =
{
    adjacent_locations={60,114,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 1,
}
world_map[9].locations[67] =
{
    adjacent_locations={86,94,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[9].locations[70] =
{
    adjacent_locations={64,71,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[9].locations[71] =
{
    adjacent_locations={70,72,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[9].locations[72] =
{
    adjacent_locations={71,73,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[9].locations[73] =
{
    adjacent_locations={72,74,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[9].locations[74] =
{
    adjacent_locations={73,75,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[9].locations[75] =
{
    adjacent_locations={74,76,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[9].locations[76] =
{
    adjacent_locations={75,77,},
    terrain = 'mountain',
    born = false,
    reborn = false,
    default = 1,
}
world_map[9].locations[77] =
{
    adjacent_locations={76,78,},
    terrain = 'wasteland',
    born = false,
    reborn = true,
    default = 1,
}
world_map[9].locations[78] =
{
    adjacent_locations={77,81,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[9].locations[81] =
{
    adjacent_locations={82,78,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[9].locations[82] =
{
    adjacent_locations={83,81,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[9].locations[83] =
{
    adjacent_locations={84,82,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[9].locations[84] =
{
    adjacent_locations={85,83,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[9].locations[85] =
{
    adjacent_locations={86,84,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[9].locations[86] =
{
    adjacent_locations={87,85,67,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[9].locations[87] =
{
    adjacent_locations={88,86,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[9].locations[88] =
{
    adjacent_locations={89,87,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[9].locations[89] =
{
    adjacent_locations={4,88,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[9].locations[94] =
{
    adjacent_locations={67,95,},
    terrain = 'wasteland',
    born = false,
    reborn = true,
    default = 0,
}
world_map[9].locations[95] =
{
    adjacent_locations={94,96,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 1,
}
world_map[9].locations[96] =
{
    adjacent_locations={95,97,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[9].locations[97] =
{
    adjacent_locations={96,98,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 0,
}
world_map[9].locations[98] =
{
    adjacent_locations={97,99,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 1,
}
world_map[9].locations[99] =
{
    adjacent_locations={98,103,100,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 1,
}
world_map[9].locations[100] =
{
    adjacent_locations={101,99,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 1,
}
world_map[9].locations[101] =
{
    adjacent_locations={100,102,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 1,
}
world_map[9].locations[102] =
{
    adjacent_locations={101,37,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 1,
}
world_map[9].locations[103] =
{
    adjacent_locations={99,104,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 1,
}
world_map[9].locations[104] =
{
    adjacent_locations={103,105,},
    terrain = 'wasteland',
    born = false,
    reborn = true,
    default = 1,
}
world_map[9].locations[105] =
{
    adjacent_locations={104,110,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 1,
}
world_map[9].locations[110] =
{
    adjacent_locations={111,105,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 1,
}
world_map[9].locations[111] =
{
    adjacent_locations={112,110,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 1,
}
world_map[9].locations[112] =
{
    adjacent_locations={113,111,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 1,
}
world_map[9].locations[113] =
{
    adjacent_locations={114,112,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 1,
}
world_map[9].locations[114] =
{
    adjacent_locations={66,113,},
    terrain = 'wasteland',
    born = false,
    reborn = false,
    default = 1,
}
return world_map

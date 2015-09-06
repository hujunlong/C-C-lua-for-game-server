local map = {}

map[20200] = 
{
    darkmine = {min = 6, max = 10},
    weather_probability = {sunny=0.4,rain=0.2,cloudy=0.4},
    mobility_cost = 1,
    start_location = 9,
    locations = {},
    monsters = {30201,30202,30203,30204,30205},
    box_monsters = {20001},
    location_groups = {},
}
map[20200].locations[1] = 
{
    adjacent_locations={2,},
    terrain = 'forest',
    box = 1,
}
map[20200].locations[2] = 
{
    adjacent_locations={3,1,},
    terrain = 'forest',
}
map[20200].locations[3] = 
{
    adjacent_locations={4,2,34,},
    terrain = 'forest',
}
map[20200].locations[4] = 
{
    adjacent_locations={5,30,3,},
    terrain = 'plain',
}
map[20200].locations[5] = 
{
    adjacent_locations={6,4,},
    terrain = 'plain',
    box = 9,
}
map[20200].locations[6] = 
{
    adjacent_locations={7,5,},
    terrain = 'citadel',
}
map[20200].locations[7] = 
{
    adjacent_locations={8,6,},
    terrain = 'citadel',
}
map[20200].locations[8] = 
{
    adjacent_locations={9,7,},
    terrain = 'citadel',
}
map[20200].locations[9] = 
{
    adjacent_locations={10,8,},
    terrain = 'citadel',
}
map[20200].locations[10] = 
{
    adjacent_locations={11,41,9,},
    terrain = 'plain',
}
map[20200].locations[11] = 
{
    adjacent_locations={12,10,},
    terrain = 'plain',
}
map[20200].locations[12] = 
{
    adjacent_locations={13,11,},
    terrain = 'plain',
}
map[20200].locations[13] = 
{
    adjacent_locations={14,12,},
    terrain = 'plain',
}
map[20200].locations[14] = 
{
    adjacent_locations={15,26,13,},
    terrain = 'plain',
}
map[20200].locations[15] = 
{
    adjacent_locations={16,14,},
    terrain = 'plain',
}
map[20200].locations[16] = 
{
    adjacent_locations={17,45,15,},
    terrain = 'plain',
}
map[20200].locations[17] = 
{
    adjacent_locations={18,16,},
    terrain = 'mountain',
    box = 6,
}
map[20200].locations[18] = 
{
    adjacent_locations={19,17,48,},
    terrain = 'mountain',
}
map[20200].locations[19] = 
{
    adjacent_locations={20,18,},
    terrain = 'forest',
}
map[20200].locations[20] = 
{
    adjacent_locations={21,23,19,},
    terrain = 'forest',
}
map[20200].locations[21] = 
{
    adjacent_locations={22,20,},
    terrain = 'plain',
}
map[20200].locations[22] = 
{
    adjacent_locations={21,},
    terrain = 'plain',
    convey2map = 20600,
    convey2location = 158,
}
map[20200].locations[23] = 
{
    adjacent_locations={20,24,},
    terrain = 'forest',
    box = 5,
}
map[20200].locations[24] = 
{
    adjacent_locations={23,25,},
    terrain = 'plain',
}
map[20200].locations[25] = 
{
    adjacent_locations={24,},
    terrain = 'plain',
    convey2map = 21400,
    convey2location = 5,
}
map[20200].locations[26] = 
{
    adjacent_locations={14,27,},
    terrain = 'forest',
}
map[20200].locations[27] = 
{
    adjacent_locations={26,28,},
    terrain = 'forest',
}
map[20200].locations[28] = 
{
    adjacent_locations={27,29,},
    terrain = 'forest',
    box = 4,
}
map[20200].locations[29] = 
{
    adjacent_locations={28,},
    terrain = 'forest',
}
map[20200].locations[30] = 
{
    adjacent_locations={4,31,},
    terrain = 'plain',
}
map[20200].locations[31] = 
{
    adjacent_locations={30,32,},
    terrain = 'plain',
}
map[20200].locations[32] = 
{
    adjacent_locations={31,33,},
    terrain = 'plain',
}
map[20200].locations[33] = 
{
    adjacent_locations={32,},
    terrain = 'plain',
    box = 3,
}
map[20200].locations[34] = 
{
    adjacent_locations={3,35,},
    terrain = 'mountain',
}
map[20200].locations[35] = 
{
    adjacent_locations={34,36,},
    terrain = 'mountain',
}
map[20200].locations[36] = 
{
    adjacent_locations={35,37,},
    terrain = 'mountain',
}
map[20200].locations[37] = 
{
    adjacent_locations={36,38,},
    terrain = 'citadel',
    box = 2,
}
map[20200].locations[38] = 
{
    adjacent_locations={37,39,},
    terrain = 'citadel',
}
map[20200].locations[39] = 
{
    adjacent_locations={38,40,},
    terrain = 'citadel',
}
map[20200].locations[40] = 
{
    adjacent_locations={39,},
    terrain = 'citadel',
}
map[20200].locations[41] = 
{
    adjacent_locations={10,42,},
    terrain = 'plain',
}
map[20200].locations[42] = 
{
    adjacent_locations={41,43,},
    terrain = 'plain',
}
map[20200].locations[43] = 
{
    adjacent_locations={42,44,},
    terrain = 'plain',
}
map[20200].locations[44] = 
{
    adjacent_locations={43,},
    terrain = 'plain',
    box = 7,
}
map[20200].locations[45] = 
{
    adjacent_locations={16,46,},
    terrain = 'plain',
}
map[20200].locations[46] = 
{
    adjacent_locations={45,47,},
    terrain = 'plain',
}
map[20200].locations[47] = 
{
    adjacent_locations={46,},
    terrain = 'plain',
    convey2map = 20500,
    convey2location = 79,
}
map[20200].locations[48] = 
{
    adjacent_locations={18,49,},
    terrain = 'mountain',
}
map[20200].locations[49] = 
{
    adjacent_locations={48,},
    terrain = 'lake',
}
map[20200].location_groups[0] = 
{
    locations = {1,5,33,37},
    max_boxes = 1,
    possible_boxes = {{ sid = 1, probability = 0.3},{ sid = 2, probability = 0.5},{ sid = 3, probability = 0.2},},
}
map[20200].location_groups[1] = 
{
    locations = {17,23,28,44},
    max_boxes = 1,
    possible_boxes = {{ sid = 1, probability = 0.3},{ sid = 2, probability = 0.5},{ sid = 3, probability = 0.2},},
}
map[20300] = 
{
    darkmine = {min = 6, max = 10},
    weather_probability = {sunny=0.4,rain=0.2,cloudy=0.4},
    mobility_cost = 1,
    start_location = 29,
    locations = {},
    monsters = {30301,30302,30303,30304,30305},
    box_monsters = {20001},
    location_groups = {},
}
map[20300].locations[24] = 
{
    adjacent_locations={25,},
    terrain = 'plain',
    convey2map = 20500,
    convey2location = 56,
}
map[20300].locations[25] = 
{
    adjacent_locations={24,26,39,},
    terrain = 'plain',
}
map[20300].locations[26] = 
{
    adjacent_locations={25,27,41,},
    terrain = 'plain',
}
map[20300].locations[27] = 
{
    adjacent_locations={26,28,},
    terrain = 'plain',
}
map[20300].locations[28] = 
{
    adjacent_locations={27,29,45,},
    terrain = 'plain',
}
map[20300].locations[29] = 
{
    adjacent_locations={28,30,},
    terrain = 'plain',
}
map[20300].locations[30] = 
{
    adjacent_locations={29,31,},
    terrain = 'citadel',
}
map[20300].locations[31] = 
{
    adjacent_locations={30,32,},
    terrain = 'citadel',
}
map[20300].locations[32] = 
{
    adjacent_locations={31,33,},
    terrain = 'citadel',
}
map[20300].locations[33] = 
{
    adjacent_locations={32,34,},
    terrain = 'plain',
}
map[20300].locations[34] = 
{
    adjacent_locations={33,35,},
    terrain = 'plain',
}
map[20300].locations[35] = 
{
    adjacent_locations={34,36,69,},
    terrain = 'plain',
}
map[20300].locations[36] = 
{
    adjacent_locations={35,37,68,},
    terrain = 'plain',
}
map[20300].locations[37] = 
{
    adjacent_locations={36,38,},
    terrain = 'plain',
}
map[20300].locations[38] = 
{
    adjacent_locations={37,},
    terrain = 'plain',
    convey2map = 20900,
    convey2location = 14,
}
map[20300].locations[39] = 
{
    adjacent_locations={25,40,},
    terrain = 'mountain',
    box = 8,
}
map[20300].locations[40] = 
{
    adjacent_locations={39,},
    terrain = 'lake',
}
map[20300].locations[41] = 
{
    adjacent_locations={26,42,},
    terrain = 'plain',
}
map[20300].locations[42] = 
{
    adjacent_locations={41,43,},
    terrain = 'plain',
}
map[20300].locations[43] = 
{
    adjacent_locations={42,44,},
    terrain = 'plain',
}
map[20300].locations[44] = 
{
    adjacent_locations={43,},
    terrain = 'plain',
    box = 1,
}
map[20300].locations[45] = 
{
    adjacent_locations={28,46,},
    terrain = 'plain',
}
map[20300].locations[46] = 
{
    adjacent_locations={45,47,},
    terrain = 'plain',
}
map[20300].locations[47] = 
{
    adjacent_locations={46,54,48,},
    terrain = 'plain',
}
map[20300].locations[48] = 
{
    adjacent_locations={49,47,},
    terrain = 'plain',
}
map[20300].locations[49] = 
{
    adjacent_locations={50,48,},
    terrain = 'plain',
}
map[20300].locations[50] = 
{
    adjacent_locations={64,49,51,},
    terrain = 'plain',
}
map[20300].locations[51] = 
{
    adjacent_locations={50,52,},
    terrain = 'plain',
}
map[20300].locations[52] = 
{
    adjacent_locations={51,53,},
    terrain = 'plain',
}
map[20300].locations[53] = 
{
    adjacent_locations={52,},
    terrain = 'plain',
    convey2map = 20800,
    convey2location = 45,
}
map[20300].locations[54] = 
{
    adjacent_locations={47,55,},
    terrain = 'forest',
}
map[20300].locations[55] = 
{
    adjacent_locations={54,56,},
    terrain = 'forest',
}
map[20300].locations[56] = 
{
    adjacent_locations={55,57,},
    terrain = 'mountain',
}
map[20300].locations[57] = 
{
    adjacent_locations={56,58,},
    terrain = 'mountain',
}
map[20300].locations[58] = 
{
    adjacent_locations={57,59,},
    terrain = 'mountain',
}
map[20300].locations[59] = 
{
    adjacent_locations={58,60,},
    terrain = 'mountain',
    box = 2,
}
map[20300].locations[60] = 
{
    adjacent_locations={59,61,},
    terrain = 'citadel',
}
map[20300].locations[61] = 
{
    adjacent_locations={60,62,},
    terrain = 'citadel',
}
map[20300].locations[62] = 
{
    adjacent_locations={61,63,},
    terrain = 'citadel',
    box = 3,
}
map[20300].locations[63] = 
{
    adjacent_locations={62,},
    terrain = 'citadel',
}
map[20300].locations[64] = 
{
    adjacent_locations={65,50,},
    terrain = 'forest',
    box = 7,
}
map[20300].locations[65] = 
{
    adjacent_locations={66,64,},
    terrain = 'forest',
}
map[20300].locations[66] = 
{
    adjacent_locations={67,65,73,},
    terrain = 'forest',
}
map[20300].locations[67] = 
{
    adjacent_locations={66,},
    terrain = 'forest',
    box = 5,
}
map[20300].locations[68] = 
{
    adjacent_locations={36,73,},
    terrain = 'forest',
    box = 6,
}
map[20300].locations[69] = 
{
    adjacent_locations={35,70,},
    terrain = 'plain',
}
map[20300].locations[70] = 
{
    adjacent_locations={69,71,},
    terrain = 'plain',
}
map[20300].locations[71] = 
{
    adjacent_locations={70,72,},
    terrain = 'plain',
}
map[20300].locations[72] = 
{
    adjacent_locations={71,},
    terrain = 'plain',
    box = 4,
}
map[20300].locations[73] = 
{
    adjacent_locations={68,66,},
    terrain = 'forest',
}
map[20300].location_groups[0] = 
{
    locations = {39,44,59,62},
    max_boxes = 1,
    possible_boxes = {{ sid = 1, probability = 0.3},{ sid = 2, probability = 0.5},{ sid = 3, probability = 0.2},},
}
map[20300].location_groups[1] = 
{
    locations = {64,67,68,72},
    max_boxes = 1,
    possible_boxes = {{ sid = 1, probability = 0.3},{ sid = 2, probability = 0.5},{ sid = 3, probability = 0.2},},
}
map[20400] = 
{
    darkmine = {min = 6, max = 10},
    weather_probability = {sunny=0.4,rain=0.2,cloudy=0.4},
    mobility_cost = 1,
    start_location = 29,
    locations = {},
    monsters = {30401,30402,30403,30404,30405},
    box_monsters = {20001},
    location_groups = {},
}
map[20400].locations[1] = 
{
    adjacent_locations={2,},
    terrain = 'plain',
    convey2map = 20700,
    convey2location = 86,
}
map[20400].locations[2] = 
{
    adjacent_locations={3,1,},
    terrain = 'plain',
}
map[20400].locations[3] = 
{
    adjacent_locations={4,2,},
    terrain = 'plain',
}
map[20400].locations[4] = 
{
    adjacent_locations={5,3,18,},
    terrain = 'plain',
}
map[20400].locations[5] = 
{
    adjacent_locations={6,4,},
    terrain = 'mountain',
}
map[20400].locations[6] = 
{
    adjacent_locations={7,52,5,},
    terrain = 'mountain',
}
map[20400].locations[7] = 
{
    adjacent_locations={8,6,},
    terrain = 'mountain',
    box = 10,
}
map[20400].locations[8] = 
{
    adjacent_locations={9,7,12,},
    terrain = 'plain',
}
map[20400].locations[9] = 
{
    adjacent_locations={10,8,},
    terrain = 'plain',
}
map[20400].locations[10] = 
{
    adjacent_locations={11,9,},
    terrain = 'plain',
}
map[20400].locations[11] = 
{
    adjacent_locations={10,},
    terrain = 'plain',
    convey2map = 20900,
    convey2location = 65,
}
map[20400].locations[12] = 
{
    adjacent_locations={8,13,},
    terrain = 'plain',
}
map[20400].locations[13] = 
{
    adjacent_locations={12,14,21,},
    terrain = 'plain',
}
map[20400].locations[14] = 
{
    adjacent_locations={13,15,},
    terrain = 'forest',
}
map[20400].locations[15] = 
{
    adjacent_locations={14,16,},
    terrain = 'forest',
}
map[20400].locations[16] = 
{
    adjacent_locations={15,17,},
    terrain = 'forest',
}
map[20400].locations[17] = 
{
    adjacent_locations={16,},
    terrain = 'forest',
    box = 5,
}
map[20400].locations[18] = 
{
    adjacent_locations={4,19,},
    terrain = 'forest',
}
map[20400].locations[19] = 
{
    adjacent_locations={18,20,},
    terrain = 'forest',
}
map[20400].locations[20] = 
{
    adjacent_locations={19,},
    terrain = 'forest',
    box = 6,
}
map[20400].locations[21] = 
{
    adjacent_locations={13,22,},
    terrain = 'plain',
    box = 8,
}
map[20400].locations[22] = 
{
    adjacent_locations={21,23,},
    terrain = 'plain',
}
map[20400].locations[23] = 
{
    adjacent_locations={22,24,28,},
    terrain = 'plain',
}
map[20400].locations[24] = 
{
    adjacent_locations={23,25,},
    terrain = 'plain',
}
map[20400].locations[25] = 
{
    adjacent_locations={24,26,},
    terrain = 'plain',
}
map[20400].locations[26] = 
{
    adjacent_locations={25,27,},
    terrain = 'plain',
}
map[20400].locations[27] = 
{
    adjacent_locations={26,},
    terrain = 'plain',
    box = 4,
}
map[20400].locations[28] = 
{
    adjacent_locations={23,29,},
    terrain = 'plain',
}
map[20400].locations[29] = 
{
    adjacent_locations={28,30,},
    terrain = 'plain',
}
map[20400].locations[30] = 
{
    adjacent_locations={29,31,},
    terrain = 'citadel',
}
map[20400].locations[31] = 
{
    adjacent_locations={30,32,},
    terrain = 'citadel',
}
map[20400].locations[32] = 
{
    adjacent_locations={31,33,},
    terrain = 'citadel',
}
map[20400].locations[33] = 
{
    adjacent_locations={32,34,},
    terrain = 'mountain',
}
map[20400].locations[34] = 
{
    adjacent_locations={33,35,},
    terrain = 'mountain',
}
map[20400].locations[35] = 
{
    adjacent_locations={34,40,},
    terrain = 'mountain',
}
map[20400].locations[36] = 
{
    adjacent_locations={37,40,},
    terrain = 'plain',
}
map[20400].locations[37] = 
{
    adjacent_locations={36,38,},
    terrain = 'plain',
}
map[20400].locations[38] = 
{
    adjacent_locations={37,39,},
    terrain = 'plain',
}
map[20400].locations[39] = 
{
    adjacent_locations={38,},
    terrain = 'plain',
    box = 11,
}
map[20400].locations[40] = 
{
    adjacent_locations={35,41,43,36,},
    terrain = 'plain',
}
map[20400].locations[41] = 
{
    adjacent_locations={40,42,},
    terrain = 'plain',
}
map[20400].locations[42] = 
{
    adjacent_locations={41,},
    terrain = 'plain',
    convey2map = 21400,
    convey2location = 84,
}
map[20400].locations[43] = 
{
    adjacent_locations={40,44,},
    terrain = 'mountain',
}
map[20400].locations[44] = 
{
    adjacent_locations={43,45,},
    terrain = 'mountain',
}
map[20400].locations[45] = 
{
    adjacent_locations={44,46,},
    terrain = 'mountain',
}
map[20400].locations[46] = 
{
    adjacent_locations={45,47,},
    terrain = 'mountain',
}
map[20400].locations[47] = 
{
    adjacent_locations={46,48,},
    terrain = 'mountain',
    box = 2,
}
map[20400].locations[48] = 
{
    adjacent_locations={47,49,},
    terrain = 'citadel',
}
map[20400].locations[49] = 
{
    adjacent_locations={48,50,},
    terrain = 'citadel',
}
map[20400].locations[50] = 
{
    adjacent_locations={49,51,},
    terrain = 'citadel',
    box = 9,
}
map[20400].locations[51] = 
{
    adjacent_locations={50,},
    terrain = 'citadel',
}
map[20400].locations[52] = 
{
    adjacent_locations={6,53,},
    terrain = 'mountain',
}
map[20400].locations[53] = 
{
    adjacent_locations={52,},
    terrain = 'lake',
}
map[20400].location_groups[0] = 
{
    locations = {7,17,20,39},
    max_boxes = 1,
    possible_boxes = {{ sid = 1, probability = 0.3},{ sid = 2, probability = 0.5},{ sid = 3, probability = 0.2},},
}
map[20400].location_groups[1] = 
{
    locations = {21,27,47,50},
    max_boxes = 1,
    possible_boxes = {{ sid = 1, probability = 0.3},{ sid = 2, probability = 0.5},{ sid = 3, probability = 0.2},},
}
map[20500] = 
{
    darkmine = {min = 9, max = 13},
    weather_probability = {sunny=0.4,rain=0.3,cloudy=0.3},
    mobility_cost = 1,
    start_location = 61,
    locations = {},
    monsters = {30501,30502,30503,30504,30505},
    box_monsters = {20002},
    location_groups = {},
}
map[20500].locations[6] = 
{
    adjacent_locations={9,7,},
    terrain = 'plain',
}
map[20500].locations[7] = 
{
    adjacent_locations={6,108,},
    terrain = 'forest',
}
map[20500].locations[9] = 
{
    adjacent_locations={10,6,},
    terrain = 'citadel',
}
map[20500].locations[10] = 
{
    adjacent_locations={11,9,},
    terrain = 'plain',
    box = 3,
}
map[20500].locations[11] = 
{
    adjacent_locations={13,10,12,},
    terrain = 'plain',
}
map[20500].locations[12] = 
{
    adjacent_locations={11,65,},
    terrain = 'mountain',
}
map[20500].locations[13] = 
{
    adjacent_locations={14,11,},
    terrain = 'plain',
}
map[20500].locations[14] = 
{
    adjacent_locations={15,13,17,},
    terrain = 'plain',
}
map[20500].locations[15] = 
{
    adjacent_locations={16,14,},
    terrain = 'citadel',
}
map[20500].locations[16] = 
{
    adjacent_locations={15,},
    terrain = 'citadel',
}
map[20500].locations[17] = 
{
    adjacent_locations={18,14,},
    terrain = 'plain',
}
map[20500].locations[18] = 
{
    adjacent_locations={19,17,},
    terrain = 'plain',
}
map[20500].locations[19] = 
{
    adjacent_locations={34,18,20,},
    terrain = 'plain',
}
map[20500].locations[20] = 
{
    adjacent_locations={19,21,},
    terrain = 'plain',
}
map[20500].locations[21] = 
{
    adjacent_locations={20,22,28,},
    terrain = 'plain',
}
map[20500].locations[22] = 
{
    adjacent_locations={21,23,},
    terrain = 'citadel',
}
map[20500].locations[23] = 
{
    adjacent_locations={22,24,},
    terrain = 'plain',
    box = 6,
}
map[20500].locations[24] = 
{
    adjacent_locations={23,25,},
    terrain = 'coastal',
}
map[20500].locations[25] = 
{
    adjacent_locations={24,26,},
    terrain = 'coastal',
}
map[20500].locations[26] = 
{
    adjacent_locations={25,27,},
    terrain = 'coastal',
    box = 5,
}
map[20500].locations[27] = 
{
    adjacent_locations={26,},
    terrain = 'coastal',
}
map[20500].locations[28] = 
{
    adjacent_locations={21,29,},
    terrain = 'plain',
}
map[20500].locations[29] = 
{
    adjacent_locations={28,30,},
    terrain = 'plain',
}
map[20500].locations[30] = 
{
    adjacent_locations={29,31,},
    terrain = 'forest',
}
map[20500].locations[31] = 
{
    adjacent_locations={30,32,},
    terrain = 'forest',
}
map[20500].locations[32] = 
{
    adjacent_locations={31,33,},
    terrain = 'forest',
}
map[20500].locations[33] = 
{
    adjacent_locations={32,},
    terrain = 'forest',
    box = 7,
}
map[20500].locations[34] = 
{
    adjacent_locations={35,109,19,},
    terrain = 'plain',
}
map[20500].locations[35] = 
{
    adjacent_locations={36,34,},
    terrain = 'plain',
}
map[20500].locations[36] = 
{
    adjacent_locations={37,35,},
    terrain = 'plain',
    box = 9,
}
map[20500].locations[37] = 
{
    adjacent_locations={38,36,},
    terrain = 'mountain',
}
map[20500].locations[38] = 
{
    adjacent_locations={39,37,},
    terrain = 'mountain',
}
map[20500].locations[39] = 
{
    adjacent_locations={40,88,38,},
    terrain = 'mountain',
}
map[20500].locations[40] = 
{
    adjacent_locations={41,39,},
    terrain = 'plain',
}
map[20500].locations[41] = 
{
    adjacent_locations={49,43,40,},
    terrain = 'plain',
}
map[20500].locations[43] = 
{
    adjacent_locations={41,44,},
    terrain = 'plain',
}
map[20500].locations[44] = 
{
    adjacent_locations={43,45,},
    terrain = 'mountain',
}
map[20500].locations[45] = 
{
    adjacent_locations={44,46,},
    terrain = 'citadel',
}
map[20500].locations[46] = 
{
    adjacent_locations={45,47,},
    terrain = 'forest',
    box = 13,
}
map[20500].locations[47] = 
{
    adjacent_locations={46,48,},
    terrain = 'forest',
}
map[20500].locations[48] = 
{
    adjacent_locations={47,},
    terrain = 'citadel',
}
map[20500].locations[49] = 
{
    adjacent_locations={50,41,},
    terrain = 'plain',
}
map[20500].locations[50] = 
{
    adjacent_locations={51,49,},
    terrain = 'plain',
}
map[20500].locations[51] = 
{
    adjacent_locations={52,50,},
    terrain = 'plain',
}
map[20500].locations[52] = 
{
    adjacent_locations={53,51,},
    terrain = 'plain',
}
map[20500].locations[53] = 
{
    adjacent_locations={54,52,},
    terrain = 'plain',
}
map[20500].locations[54] = 
{
    adjacent_locations={107,55,53,},
    terrain = 'plain',
}
map[20500].locations[55] = 
{
    adjacent_locations={54,56,},
    terrain = 'plain',
}
map[20500].locations[56] = 
{
    adjacent_locations={55,},
    terrain = 'plain',
    convey2map = 20300,
    convey2location = 24,
}
map[20500].locations[60] = 
{
    adjacent_locations={110,61,},
    terrain = 'plain',
}
map[20500].locations[61] = 
{
    adjacent_locations={62,60,},
    terrain = 'plain',
}
map[20500].locations[62] = 
{
    adjacent_locations={63,61,},
    terrain = 'plain',
}
map[20500].locations[63] = 
{
    adjacent_locations={112,62,},
    terrain = 'plain',
}
map[20500].locations[64] = 
{
    adjacent_locations={81,112,96,},
    terrain = 'plain',
}
map[20500].locations[65] = 
{
    adjacent_locations={12,66,},
    terrain = 'mountain',
}
map[20500].locations[66] = 
{
    adjacent_locations={65,67,},
    terrain = 'mountain',
}
map[20500].locations[67] = 
{
    adjacent_locations={66,68,69,},
    terrain = 'mountain',
}
map[20500].locations[68] = 
{
    adjacent_locations={67,},
    terrain = 'lake',
}
map[20500].locations[69] = 
{
    adjacent_locations={67,70,},
    terrain = 'mountain',
    box = 16,
}
map[20500].locations[70] = 
{
    adjacent_locations={69,71,},
    terrain = 'mountain',
}
map[20500].locations[71] = 
{
    adjacent_locations={70,72,},
    terrain = 'mountain',
}
map[20500].locations[72] = 
{
    adjacent_locations={71,73,},
    terrain = 'mountain',
}
map[20500].locations[73] = 
{
    adjacent_locations={72,74,},
    terrain = 'plain',
}
map[20500].locations[74] = 
{
    adjacent_locations={73,75,},
    terrain = 'citadel',
}
map[20500].locations[75] = 
{
    adjacent_locations={74,76,},
    terrain = 'plain',
    box = 14,
}
map[20500].locations[76] = 
{
    adjacent_locations={75,77,},
    terrain = 'forest',
}
map[20500].locations[77] = 
{
    adjacent_locations={76,78,111,},
    terrain = 'plain',
}
map[20500].locations[78] = 
{
    adjacent_locations={77,79,},
    terrain = 'plain',
}
map[20500].locations[79] = 
{
    adjacent_locations={78,},
    terrain = 'plain',
    convey2map = 20200,
    convey2location = 47,
}
map[20500].locations[80] = 
{
    adjacent_locations={111,81,82,},
    terrain = 'plain',
}
map[20500].locations[81] = 
{
    adjacent_locations={80,64,},
    terrain = 'plain',
}
map[20500].locations[82] = 
{
    adjacent_locations={80,83,},
    terrain = 'mountain',
}
map[20500].locations[83] = 
{
    adjacent_locations={82,84,},
    terrain = 'mountain',
}
map[20500].locations[84] = 
{
    adjacent_locations={83,85,},
    terrain = 'mountain',
}
map[20500].locations[85] = 
{
    adjacent_locations={84,86,},
    terrain = 'mountain',
}
map[20500].locations[86] = 
{
    adjacent_locations={85,87,},
    terrain = 'mountain',
    box = 15,
}
map[20500].locations[87] = 
{
    adjacent_locations={86,},
    terrain = 'lake',
}
map[20500].locations[88] = 
{
    adjacent_locations={39,89,},
    terrain = 'mountain',
}
map[20500].locations[89] = 
{
    adjacent_locations={88,90,},
    terrain = 'mountain',
}
map[20500].locations[90] = 
{
    adjacent_locations={89,91,},
    terrain = 'mountain',
}
map[20500].locations[91] = 
{
    adjacent_locations={90,92,},
    terrain = 'mountain',
}
map[20500].locations[92] = 
{
    adjacent_locations={91,93,},
    terrain = 'forest',
}
map[20500].locations[93] = 
{
    adjacent_locations={92,94,},
    terrain = 'forest',
    box = 12,
}
map[20500].locations[94] = 
{
    adjacent_locations={93,95,},
    terrain = 'mountain',
}
map[20500].locations[95] = 
{
    adjacent_locations={94,112,},
    terrain = 'mountain',
}
map[20500].locations[96] = 
{
    adjacent_locations={64,97,},
    terrain = 'plain',
}
map[20500].locations[97] = 
{
    adjacent_locations={96,98,102,},
    terrain = 'plain',
}
map[20500].locations[98] = 
{
    adjacent_locations={97,99,},
    terrain = 'plain',
}
map[20500].locations[99] = 
{
    adjacent_locations={98,100,},
    terrain = 'plain',
}
map[20500].locations[100] = 
{
    adjacent_locations={99,101,},
    terrain = 'plain',
}
map[20500].locations[101] = 
{
    adjacent_locations={100,},
    terrain = 'plain',
    convey2map = 21200,
    convey2location = 1,
}
map[20500].locations[102] = 
{
    adjacent_locations={97,103,},
    terrain = 'forest',
}
map[20500].locations[103] = 
{
    adjacent_locations={102,104,},
    terrain = 'forest',
}
map[20500].locations[104] = 
{
    adjacent_locations={103,105,},
    terrain = 'forest',
    box = 17,
}
map[20500].locations[105] = 
{
    adjacent_locations={104,106,},
    terrain = 'forest',
}
map[20500].locations[106] = 
{
    adjacent_locations={105,107,},
    terrain = 'forest',
}
map[20500].locations[107] = 
{
    adjacent_locations={106,54,},
    terrain = 'forest',
}
map[20500].locations[108] = 
{
    adjacent_locations={7,},
    terrain = 'forest',
    box = 1,
}
map[20500].locations[109] = 
{
    adjacent_locations={34,110,},
    terrain = 'plain',
}
map[20500].locations[110] = 
{
    adjacent_locations={109,60,},
    terrain = 'plain',
}
map[20500].locations[111] = 
{
    adjacent_locations={77,80,},
    terrain = 'plain',
}
map[20500].locations[112] = 
{
    adjacent_locations={64,63,95,},
    terrain = 'plain',
}
map[20500].location_groups[0] = 
{
    locations = {23,26,33,36},
    max_boxes = 1,
    possible_boxes = {{ sid = 4, probability = 0.3},{ sid = 5, probability = 0.5},{ sid = 6, probability = 0.2},},
}
map[20500].location_groups[1] = 
{
    locations = {10,69,75,108},
    max_boxes = 1,
    possible_boxes = {{ sid = 4, probability = 0.3},{ sid = 5, probability = 0.5},{ sid = 6, probability = 0.2},},
}
map[20500].location_groups[2] = 
{
    locations = {46,86,93,104},
    max_boxes = 1,
    possible_boxes = {{ sid = 4, probability = 0.3},{ sid = 5, probability = 0.5},{ sid = 6, probability = 0.2},},
}
map[20600] = 
{
    darkmine = {min = 9, max = 13},
    weather_probability = {sunny=0.1,rain=0.6,cloudy=0.3},
    mobility_cost = 1,
    start_location = 79,
    locations = {},
    monsters = {30601,30602,30603,30604,30605},
    box_monsters = {20003},
    location_groups = {},
}
map[20600].locations[9] = 
{
    adjacent_locations={10,},
    terrain = 'forest',
    box = 1,
}
map[20600].locations[10] = 
{
    adjacent_locations={9,11,},
    terrain = 'forest',
}
map[20600].locations[11] = 
{
    adjacent_locations={10,13,},
    terrain = 'forest',
}
map[20600].locations[13] = 
{
    adjacent_locations={11,18,},
    terrain = 'forest',
}
map[20600].locations[18] = 
{
    adjacent_locations={13,19,},
    terrain = 'forest',
}
map[20600].locations[19] = 
{
    adjacent_locations={18,20,},
    terrain = 'forest',
}
map[20600].locations[20] = 
{
    adjacent_locations={23,19,32,},
    terrain = 'forest',
}
map[20600].locations[23] = 
{
    adjacent_locations={20,156,},
    terrain = 'forest',
}
map[20600].locations[28] = 
{
    adjacent_locations={157,29,},
    terrain = 'plain',
}
map[20600].locations[29] = 
{
    adjacent_locations={28,30,},
    terrain = 'plain',
}
map[20600].locations[30] = 
{
    adjacent_locations={29,41,31,},
    terrain = 'lake',
}
map[20600].locations[31] = 
{
    adjacent_locations={30,32,},
    terrain = 'lake',
}
map[20600].locations[32] = 
{
    adjacent_locations={31,33,20,},
    terrain = 'lake',
}
map[20600].locations[33] = 
{
    adjacent_locations={32,35,34,},
    terrain = 'lake',
}
map[20600].locations[34] = 
{
    adjacent_locations={33,},
    terrain = 'plain',
}
map[20600].locations[35] = 
{
    adjacent_locations={33,36,},
    terrain = 'lake',
}
map[20600].locations[36] = 
{
    adjacent_locations={35,37,},
    terrain = 'lake',
}
map[20600].locations[37] = 
{
    adjacent_locations={36,39,},
    terrain = 'lake',
}
map[20600].locations[39] = 
{
    adjacent_locations={37,40,},
    terrain = 'lake',
}
map[20600].locations[40] = 
{
    adjacent_locations={39,133,},
    terrain = 'lake',
}
map[20600].locations[41] = 
{
    adjacent_locations={30,42,},
    terrain = 'lake',
}
map[20600].locations[42] = 
{
    adjacent_locations={41,141,43,},
    terrain = 'lake',
}
map[20600].locations[43] = 
{
    adjacent_locations={44,42,},
    terrain = 'plain',
}
map[20600].locations[44] = 
{
    adjacent_locations={43,45,159,},
    terrain = 'plain',
}
map[20600].locations[45] = 
{
    adjacent_locations={44,46,},
    terrain = 'plain',
    box = 7,
}
map[20600].locations[46] = 
{
    adjacent_locations={45,47,},
    terrain = 'plain',
}
map[20600].locations[47] = 
{
    adjacent_locations={46,48,},
    terrain = 'plain',
}
map[20600].locations[48] = 
{
    adjacent_locations={47,49,},
    terrain = 'plain',
}
map[20600].locations[49] = 
{
    adjacent_locations={48,50,},
    terrain = 'lake',
}
map[20600].locations[50] = 
{
    adjacent_locations={49,51,52,},
    terrain = 'lake',
}
map[20600].locations[51] = 
{
    adjacent_locations={50,},
    terrain = 'lake',
}
map[20600].locations[52] = 
{
    adjacent_locations={50,56,53,},
    terrain = 'lake',
}
map[20600].locations[53] = 
{
    adjacent_locations={52,54,},
    terrain = 'lake',
}
map[20600].locations[54] = 
{
    adjacent_locations={53,},
    terrain = 'lake',
    box = 8,
}
map[20600].locations[56] = 
{
    adjacent_locations={52,57,},
    terrain = 'lake',
}
map[20600].locations[57] = 
{
    adjacent_locations={56,58,},
    terrain = 'lake',
}
map[20600].locations[58] = 
{
    adjacent_locations={57,59,},
    terrain = 'lake',
}
map[20600].locations[59] = 
{
    adjacent_locations={58,},
    terrain = 'plain',
}
map[20600].locations[67] = 
{
    adjacent_locations={152,68,},
    terrain = 'citadel',
}
map[20600].locations[68] = 
{
    adjacent_locations={67,69,},
    terrain = 'citadel',
}
map[20600].locations[69] = 
{
    adjacent_locations={68,70,},
    terrain = 'citadel',
}
map[20600].locations[70] = 
{
    adjacent_locations={69,71,},
    terrain = 'citadel',
}
map[20600].locations[71] = 
{
    adjacent_locations={70,72,},
    terrain = 'citadel',
}
map[20600].locations[72] = 
{
    adjacent_locations={71,},
    terrain = 'citadel',
    box = 5,
}
map[20600].locations[78] = 
{
    adjacent_locations={79,154,151,},
    terrain = 'forest',
}
map[20600].locations[79] = 
{
    adjacent_locations={80,78,},
    terrain = 'plain',
}
map[20600].locations[80] = 
{
    adjacent_locations={88,123,81,79,},
    terrain = 'plain',
}
map[20600].locations[81] = 
{
    adjacent_locations={80,82,},
    terrain = 'mountain',
}
map[20600].locations[82] = 
{
    adjacent_locations={81,83,},
    terrain = 'forest',
}
map[20600].locations[83] = 
{
    adjacent_locations={82,84,},
    terrain = 'forest',
}
map[20600].locations[84] = 
{
    adjacent_locations={83,85,},
    terrain = 'forest',
}
map[20600].locations[85] = 
{
    adjacent_locations={84,86,},
    terrain = 'forest',
}
map[20600].locations[86] = 
{
    adjacent_locations={85,},
    terrain = 'lake',
}
map[20600].locations[88] = 
{
    adjacent_locations={89,80,},
    terrain = 'plain',
}
map[20600].locations[89] = 
{
    adjacent_locations={90,88,},
    terrain = 'plain',
    box = 6,
}
map[20600].locations[90] = 
{
    adjacent_locations={91,89,},
    terrain = 'plain',
}
map[20600].locations[91] = 
{
    adjacent_locations={96,90,},
    terrain = 'forest',
}
map[20600].locations[92] = 
{
    adjacent_locations={102,93,},
    terrain = 'lake',
}
map[20600].locations[93] = 
{
    adjacent_locations={92,94,},
    terrain = 'lake',
}
map[20600].locations[94] = 
{
    adjacent_locations={93,95,},
    terrain = 'lake',
}
map[20600].locations[95] = 
{
    adjacent_locations={94,},
    terrain = 'lake',
    box = 10,
}
map[20600].locations[96] = 
{
    adjacent_locations={97,91,},
    terrain = 'forest',
}
map[20600].locations[97] = 
{
    adjacent_locations={98,96,},
    terrain = 'forest',
}
map[20600].locations[98] = 
{
    adjacent_locations={99,97,},
    terrain = 'mountain',
}
map[20600].locations[99] = 
{
    adjacent_locations={100,98,},
    terrain = 'mountain',
}
map[20600].locations[100] = 
{
    adjacent_locations={101,99,},
    terrain = 'mountain',
}
map[20600].locations[101] = 
{
    adjacent_locations={104,100,},
    terrain = 'mountain',
    box = 9,
}
map[20600].locations[102] = 
{
    adjacent_locations={103,92,},
    terrain = 'lake',
}
map[20600].locations[103] = 
{
    adjacent_locations={106,102,},
    terrain = 'lake',
}
map[20600].locations[104] = 
{
    adjacent_locations={105,101,},
    terrain = 'mountain',
}
map[20600].locations[105] = 
{
    adjacent_locations={107,104,106,},
    terrain = 'mountain',
}
map[20600].locations[106] = 
{
    adjacent_locations={105,103,},
    terrain = 'lake',
}
map[20600].locations[107] = 
{
    adjacent_locations={110,108,105,},
    terrain = 'mountain',
}
map[20600].locations[108] = 
{
    adjacent_locations={107,109,},
    terrain = 'mountain',
}
map[20600].locations[109] = 
{
    adjacent_locations={108,},
    terrain = 'mountain',
    convey2map = 21000,
    convey2location = 87,
}
map[20600].locations[110] = 
{
    adjacent_locations={111,107,},
    terrain = 'mountain',
}
map[20600].locations[111] = 
{
    adjacent_locations={124,110,112,},
    terrain = 'mountain',
}
map[20600].locations[112] = 
{
    adjacent_locations={111,113,},
    terrain = 'plain',
}
map[20600].locations[113] = 
{
    adjacent_locations={112,114,},
    terrain = 'plain',
}
map[20600].locations[114] = 
{
    adjacent_locations={113,115,},
    terrain = 'plain',
    box = 11,
}
map[20600].locations[115] = 
{
    adjacent_locations={114,116,},
    terrain = 'lake',
}
map[20600].locations[116] = 
{
    adjacent_locations={115,117,},
    terrain = 'lake',
}
map[20600].locations[117] = 
{
    adjacent_locations={118,116,},
    terrain = 'lake',
}
map[20600].locations[118] = 
{
    adjacent_locations={119,117,},
    terrain = 'lake',
}
map[20600].locations[119] = 
{
    adjacent_locations={120,118,},
    terrain = 'lake',
}
map[20600].locations[120] = 
{
    adjacent_locations={121,119,},
    terrain = 'lake',
}
map[20600].locations[121] = 
{
    adjacent_locations={122,120,},
    terrain = 'lake',
}
map[20600].locations[122] = 
{
    adjacent_locations={123,121,},
    terrain = 'plain',
}
map[20600].locations[123] = 
{
    adjacent_locations={80,122,},
    terrain = 'forest',
}
map[20600].locations[124] = 
{
    adjacent_locations={125,111,},
    terrain = 'mountain',
}
map[20600].locations[125] = 
{
    adjacent_locations={126,124,},
    terrain = 'forest',
}
map[20600].locations[126] = 
{
    adjacent_locations={127,125,},
    terrain = 'citadel',
    box = 12,
}
map[20600].locations[127] = 
{
    adjacent_locations={128,126,},
    terrain = 'lake',
}
map[20600].locations[128] = 
{
    adjacent_locations={129,127,},
    terrain = 'lake',
}
map[20600].locations[129] = 
{
    adjacent_locations={130,128,},
    terrain = 'lake',
}
map[20600].locations[130] = 
{
    adjacent_locations={131,145,129,},
    terrain = 'plain',
}
map[20600].locations[131] = 
{
    adjacent_locations={132,130,},
    terrain = 'lake',
}
map[20600].locations[132] = 
{
    adjacent_locations={133,131,},
    terrain = 'lake',
    box = 13,
}
map[20600].locations[133] = 
{
    adjacent_locations={40,134,132,},
    terrain = 'lake',
}
map[20600].locations[134] = 
{
    adjacent_locations={133,135,},
    terrain = 'lake',
}
map[20600].locations[135] = 
{
    adjacent_locations={136,134,},
    terrain = 'lake',
}
map[20600].locations[136] = 
{
    adjacent_locations={137,135,},
    terrain = 'lake',
    box = 14,
}
map[20600].locations[137] = 
{
    adjacent_locations={138,136,},
    terrain = 'lake',
}
map[20600].locations[138] = 
{
    adjacent_locations={139,137,},
    terrain = 'lake',
}
map[20600].locations[139] = 
{
    adjacent_locations={140,138,},
    terrain = 'lake',
}
map[20600].locations[140] = 
{
    adjacent_locations={141,139,},
    terrain = 'lake',
}
map[20600].locations[141] = 
{
    adjacent_locations={42,140,},
    terrain = 'lake',
}
map[20600].locations[142] = 
{
    adjacent_locations={143,},
    terrain = 'lake',
}
map[20600].locations[143] = 
{
    adjacent_locations={144,142,},
    terrain = 'lake',
}
map[20600].locations[144] = 
{
    adjacent_locations={143,},
    terrain = 'lake',
    convey2map = 20601,
    convey2location = 14,
}
map[20600].locations[145] = 
{
    adjacent_locations={130,},
    terrain = 'cave',
    convey2map = 20601,
    convey2location = 6,
}
map[20600].locations[146] = 
{
    adjacent_locations={147,159,},
    terrain = 'forest',
}
map[20600].locations[147] = 
{
    adjacent_locations={148,146,},
    terrain = 'plain',
}
map[20600].locations[148] = 
{
    adjacent_locations={149,152,147,},
    terrain = 'plain',
}
map[20600].locations[149] = 
{
    adjacent_locations={150,148,},
    terrain = 'mountain',
}
map[20600].locations[150] = 
{
    adjacent_locations={151,149,},
    terrain = 'plain',
}
map[20600].locations[151] = 
{
    adjacent_locations={78,150,},
    terrain = 'forest',
}
map[20600].locations[152] = 
{
    adjacent_locations={148,67,},
    terrain = 'mountain',
}
map[20600].locations[154] = 
{
    adjacent_locations={78,155,},
    terrain = 'plain',
}
map[20600].locations[155] = 
{
    adjacent_locations={154,},
    terrain = 'plain',
    convey2map = 21200,
    convey2location = 18,
}
map[20600].locations[156] = 
{
    adjacent_locations={23,},
    terrain = 'forest',
    box = 15,
}
map[20600].locations[157] = 
{
    adjacent_locations={158,28,},
    terrain = 'plain',
}
map[20600].locations[158] = 
{
    adjacent_locations={157,},
    terrain = 'plain',
    convey2map = 20200,
    convey2location = 22,
}
map[20600].locations[159] = 
{
    adjacent_locations={146,44,},
    terrain = 'forest',
}
map[20600].location_groups[0] = 
{
    locations = {9,126,132,136},
    max_boxes = 1,
    possible_boxes = {{ sid = 7, probability = 0.3},{ sid = 8, probability = 0.5},{ sid = 9, probability = 0.2},},
}
map[20600].location_groups[1] = 
{
    locations = {45,54,72,156},
    max_boxes = 1,
    possible_boxes = {{ sid = 7, probability = 0.3},{ sid = 8, probability = 0.5},{ sid = 9, probability = 0.2},},
}
map[20600].location_groups[2] = 
{
    locations = {89,95,101,114},
    max_boxes = 1,
    possible_boxes = {{ sid = 7, probability = 0.3},{ sid = 8, probability = 0.5},{ sid = 9, probability = 0.2},},
}
map[20601] = 
{
    superior_map = 20600,
    darkmine = {min = 6, max = 8},
    weather_probability = {cloudy=1},
    mobility_cost = 1,
    start_location = 0,
    locations = {},
    monsters = {30601,30602,30603,30604,30605},
    box_monsters = {20003},
    location_groups = {},
}
map[20601].locations[6] = 
{
    adjacent_locations={7,},
    terrain = 'cave',
    convey2map = 20600,
    convey2location = 145,
}
map[20601].locations[7] = 
{
    adjacent_locations={8,6,},
    terrain = 'cave',
}
map[20601].locations[8] = 
{
    adjacent_locations={9,7,},
    terrain = 'cave',
}
map[20601].locations[9] = 
{
    adjacent_locations={10,8,},
    terrain = 'cave',
}
map[20601].locations[10] = 
{
    adjacent_locations={11,9,},
    terrain = 'cave',
}
map[20601].locations[11] = 
{
    adjacent_locations={12,10,},
    terrain = 'cave',
}
map[20601].locations[12] = 
{
    adjacent_locations={13,11,},
    terrain = 'cave',
    box = 1,
}
map[20601].locations[13] = 
{
    adjacent_locations={14,12,},
    terrain = 'cave',
}
map[20601].locations[14] = 
{
    adjacent_locations={13,},
    terrain = 'cave',
    convey2map = 20600,
    convey2location = 144,
}
map[20601].location_groups[0] = 
{
    locations = {12},
    max_boxes = 1,
    possible_boxes = {{ sid = 7, probability = 0.3},{ sid = 8, probability = 0.5},{ sid = 9, probability = 0.2},},
}
map[20700] = 
{
    darkmine = {min = 9, max = 13},
    weather_probability = {sunny=0.4,cloudy=0.4,fog=0.2},
    mobility_cost = 1,
    start_location = 73,
    locations = {},
    monsters = {30701,30702,30703,30704,30705},
    box_monsters = {20004},
    location_groups = {},
}
map[20700].locations[17] = 
{
    adjacent_locations={18,},
    terrain = 'mountain',
    convey2map = 21000,
    convey2location = 32,
}
map[20700].locations[18] = 
{
    adjacent_locations={19,17,},
    terrain = 'mountain',
}
map[20700].locations[19] = 
{
    adjacent_locations={20,18,146,},
    terrain = 'mountain',
}
map[20700].locations[20] = 
{
    adjacent_locations={21,19,},
    terrain = 'mountain',
}
map[20700].locations[21] = 
{
    adjacent_locations={22,20,},
    terrain = 'mountain',
}
map[20700].locations[22] = 
{
    adjacent_locations={23,21,70,},
    terrain = 'mountain',
}
map[20700].locations[23] = 
{
    adjacent_locations={24,22,},
    terrain = 'mountain',
}
map[20700].locations[24] = 
{
    adjacent_locations={25,23,},
    terrain = 'mountain',
}
map[20700].locations[25] = 
{
    adjacent_locations={29,26,24,},
    terrain = 'mountain',
}
map[20700].locations[26] = 
{
    adjacent_locations={25,27,},
    terrain = 'mountain',
}
map[20700].locations[27] = 
{
    adjacent_locations={26,28,},
    terrain = 'mountain',
    box = 3,
}
map[20700].locations[28] = 
{
    adjacent_locations={27,},
    terrain = 'mountain',
}
map[20700].locations[29] = 
{
    adjacent_locations={25,},
    terrain = 'mountain',
    box = 5,
}
map[20700].locations[33] = 
{
    adjacent_locations={34,39,},
    terrain = 'plain',
}
map[20700].locations[34] = 
{
    adjacent_locations={35,33,},
    terrain = 'plain',
}
map[20700].locations[35] = 
{
    adjacent_locations={36,34,},
    terrain = 'plain',
}
map[20700].locations[36] = 
{
    adjacent_locations={37,35,},
    terrain = 'plain',
}
map[20700].locations[37] = 
{
    adjacent_locations={38,36,},
    terrain = 'plain',
}
map[20700].locations[38] = 
{
    adjacent_locations={37,},
    terrain = 'plain',
}
map[20700].locations[39] = 
{
    adjacent_locations={33,40,},
    terrain = 'plain',
}
map[20700].locations[40] = 
{
    adjacent_locations={149,41,39,},
    terrain = 'plain',
}
map[20700].locations[41] = 
{
    adjacent_locations={40,42,},
    terrain = 'mountain',
}
map[20700].locations[42] = 
{
    adjacent_locations={43,150,41,},
    terrain = 'mountain',
}
map[20700].locations[43] = 
{
    adjacent_locations={44,42,},
    terrain = 'plain',
}
map[20700].locations[44] = 
{
    adjacent_locations={45,43,},
    terrain = 'plain',
}
map[20700].locations[45] = 
{
    adjacent_locations={46,44,},
    terrain = 'plain',
}
map[20700].locations[46] = 
{
    adjacent_locations={63,65,45,101,},
    terrain = 'plain',
}
map[20700].locations[48] = 
{
    adjacent_locations={150,49,},
    terrain = 'mountain',
    box = 12,
}
map[20700].locations[49] = 
{
    adjacent_locations={48,50,},
    terrain = 'mountain',
}
map[20700].locations[50] = 
{
    adjacent_locations={49,51,},
    terrain = 'mountain',
}
map[20700].locations[51] = 
{
    adjacent_locations={50,52,},
    terrain = 'mountain',
}
map[20700].locations[52] = 
{
    adjacent_locations={51,53,},
    terrain = 'mountain',
}
map[20700].locations[53] = 
{
    adjacent_locations={52,},
    terrain = 'cave',
    convey2map = 20701,
    convey2location = 14,
}
map[20700].locations[56] = 
{
    adjacent_locations={57,},
    terrain = 'cave',
    convey2map = 20701,
    convey2location = 6,
}
map[20700].locations[57] = 
{
    adjacent_locations={56,58,},
    terrain = 'plain',
}
map[20700].locations[58] = 
{
    adjacent_locations={57,59,},
    terrain = 'plain',
    box = 4,
}
map[20700].locations[59] = 
{
    adjacent_locations={58,61,},
    terrain = 'plain',
}
map[20700].locations[61] = 
{
    adjacent_locations={59,},
    terrain = 'cave',
}
map[20700].locations[63] = 
{
    adjacent_locations={46,},
    terrain = 'plain',
}
map[20700].locations[65] = 
{
    adjacent_locations={46,66,},
    terrain = 'plain',
}
map[20700].locations[66] = 
{
    adjacent_locations={65,67,},
    terrain = 'mountain',
}
map[20700].locations[67] = 
{
    adjacent_locations={66,68,},
    terrain = 'mountain',
}
map[20700].locations[68] = 
{
    adjacent_locations={67,69,},
    terrain = 'mountain',
}
map[20700].locations[69] = 
{
    adjacent_locations={74,68,73,},
    terrain = 'mountain',
}
map[20700].locations[70] = 
{
    adjacent_locations={71,22,149,},
    terrain = 'plain',
}
map[20700].locations[71] = 
{
    adjacent_locations={72,70,},
    terrain = 'plain',
}
map[20700].locations[72] = 
{
    adjacent_locations={73,71,},
    terrain = 'mountain',
}
map[20700].locations[73] = 
{
    adjacent_locations={69,72,},
    terrain = 'mountain',
}
map[20700].locations[74] = 
{
    adjacent_locations={75,69,},
    terrain = 'mountain',
}
map[20700].locations[75] = 
{
    adjacent_locations={129,76,74,},
    terrain = 'mountain',
}
map[20700].locations[76] = 
{
    adjacent_locations={75,77,},
    terrain = 'mountain',
}
map[20700].locations[77] = 
{
    adjacent_locations={76,78,},
    terrain = 'mountain',
}
map[20700].locations[78] = 
{
    adjacent_locations={77,79,137,},
    terrain = 'mountain',
}
map[20700].locations[79] = 
{
    adjacent_locations={78,80,},
    terrain = 'mountain',
}
map[20700].locations[80] = 
{
    adjacent_locations={79,81,},
    terrain = 'mountain',
}
map[20700].locations[81] = 
{
    adjacent_locations={80,151,},
    terrain = 'mountain',
}
map[20700].locations[82] = 
{
    adjacent_locations={83,151,},
    terrain = 'mountain',
}
map[20700].locations[83] = 
{
    adjacent_locations={82,84,},
    terrain = 'mountain',
}
map[20700].locations[84] = 
{
    adjacent_locations={83,85,},
    terrain = 'mountain',
    box = 7,
}
map[20700].locations[85] = 
{
    adjacent_locations={84,86,87,},
    terrain = 'plain',
}
map[20700].locations[86] = 
{
    adjacent_locations={85,},
    terrain = 'mountain',
    convey2map = 20400,
    convey2location = 1,
}
map[20700].locations[87] = 
{
    adjacent_locations={85,88,},
    terrain = 'mountain',
}
map[20700].locations[88] = 
{
    adjacent_locations={87,89,},
    terrain = 'mountain',
}
map[20700].locations[89] = 
{
    adjacent_locations={88,90,},
    terrain = 'plain',
}
map[20700].locations[90] = 
{
    adjacent_locations={89,92,},
    terrain = 'plain',
    box = 11,
}
map[20700].locations[92] = 
{
    adjacent_locations={90,93,},
    terrain = 'forest',
}
map[20700].locations[93] = 
{
    adjacent_locations={92,94,},
    terrain = 'mountain',
}
map[20700].locations[94] = 
{
    adjacent_locations={93,95,},
    terrain = 'citadel',
}
map[20700].locations[95] = 
{
    adjacent_locations={94,96,},
    terrain = 'lake',
}
map[20700].locations[96] = 
{
    adjacent_locations={95,97,},
    terrain = 'lake',
}
map[20700].locations[97] = 
{
    adjacent_locations={96,98,113,},
    terrain = 'lake',
}
map[20700].locations[98] = 
{
    adjacent_locations={97,99,},
    terrain = 'lake',
}
map[20700].locations[99] = 
{
    adjacent_locations={98,100,},
    terrain = 'lake',
}
map[20700].locations[100] = 
{
    adjacent_locations={99,102,},
    terrain = 'plain',
}
map[20700].locations[101] = 
{
    adjacent_locations={46,102,},
    terrain = 'plain',
}
map[20700].locations[102] = 
{
    adjacent_locations={100,103,101,},
    terrain = 'plain',
}
map[20700].locations[103] = 
{
    adjacent_locations={102,104,},
    terrain = 'citadel',
}
map[20700].locations[104] = 
{
    adjacent_locations={103,105,},
    terrain = 'citadel',
}
map[20700].locations[105] = 
{
    adjacent_locations={104,106,},
    terrain = 'citadel',
}
map[20700].locations[106] = 
{
    adjacent_locations={105,107,},
    terrain = 'citadel',
}
map[20700].locations[107] = 
{
    adjacent_locations={106,108,110,},
    terrain = 'citadel',
}
map[20700].locations[108] = 
{
    adjacent_locations={107,109,},
    terrain = 'citadel',
}
map[20700].locations[109] = 
{
    adjacent_locations={108,},
    terrain = 'citadel',
}
map[20700].locations[110] = 
{
    adjacent_locations={107,111,},
    terrain = 'citadel',
}
map[20700].locations[111] = 
{
    adjacent_locations={110,112,},
    terrain = 'mountain',
    box = 8,
}
map[20700].locations[112] = 
{
    adjacent_locations={111,},
    terrain = 'citadel',
}
map[20700].locations[113] = 
{
    adjacent_locations={97,114,},
    terrain = 'lake',
}
map[20700].locations[114] = 
{
    adjacent_locations={113,115,},
    terrain = 'mountain',
}
map[20700].locations[115] = 
{
    adjacent_locations={114,116,125,},
    terrain = 'mountain',
}
map[20700].locations[116] = 
{
    adjacent_locations={115,117,},
    terrain = 'mountain',
}
map[20700].locations[117] = 
{
    adjacent_locations={116,},
    terrain = 'mountain',
    box = 13,
}
map[20700].locations[125] = 
{
    adjacent_locations={115,126,},
    terrain = 'mountain',
}
map[20700].locations[126] = 
{
    adjacent_locations={125,127,},
    terrain = 'mountain',
}
map[20700].locations[127] = 
{
    adjacent_locations={126,},
    terrain = 'mountain',
    box = 10,
}
map[20700].locations[129] = 
{
    adjacent_locations={75,130,},
    terrain = 'mountain',
}
map[20700].locations[130] = 
{
    adjacent_locations={129,131,},
    terrain = 'mountain',
}
map[20700].locations[131] = 
{
    adjacent_locations={141,130,},
    terrain = 'mountain',
}
map[20700].locations[134] = 
{
    adjacent_locations={135,},
    terrain = 'mountain',
}
map[20700].locations[135] = 
{
    adjacent_locations={134,136,},
    terrain = 'wasteland',
    box = 6,
}
map[20700].locations[136] = 
{
    adjacent_locations={135,137,},
    terrain = 'wasteland',
}
map[20700].locations[137] = 
{
    adjacent_locations={136,78,},
    terrain = 'wasteland',
    box = 9,
}
map[20700].locations[141] = 
{
    adjacent_locations={142,131,},
    terrain = 'plain',
}
map[20700].locations[142] = 
{
    adjacent_locations={143,141,},
    terrain = 'wasteland',
}
map[20700].locations[143] = 
{
    adjacent_locations={144,142,},
    terrain = 'wasteland',
}
map[20700].locations[144] = 
{
    adjacent_locations={147,143,},
    terrain = 'wasteland',
    box = 2,
}
map[20700].locations[145] = 
{
    adjacent_locations={146,147,},
    terrain = 'wasteland',
}
map[20700].locations[146] = 
{
    adjacent_locations={19,145,},
    terrain = 'wasteland',
}
map[20700].locations[147] = 
{
    adjacent_locations={145,144,},
    terrain = 'wasteland',
}
map[20700].locations[149] = 
{
    adjacent_locations={40,70,},
    terrain = 'plain',
}
map[20700].locations[150] = 
{
    adjacent_locations={42,48,},
    terrain = 'mountain',
}
map[20700].locations[151] = 
{
    adjacent_locations={82,81,},
    terrain = 'mountain',
}
map[20700].location_groups[0] = 
{
    locations = {27,29,58,144},
    max_boxes = 1,
    possible_boxes = {{ sid = 10, probability = 0.3},{ sid = 11, probability = 0.5},{ sid = 12, probability = 0.2},},
}
map[20700].location_groups[1] = 
{
    locations = {84,111,135,137},
    max_boxes = 1,
    possible_boxes = {{ sid = 10, probability = 0.3},{ sid = 11, probability = 0.5},{ sid = 12, probability = 0.2},},
}
map[20700].location_groups[2] = 
{
    locations = {48,90,117,127},
    max_boxes = 1,
    possible_boxes = {{ sid = 10, probability = 0.3},{ sid = 11, probability = 0.5},{ sid = 12, probability = 0.2},},
}
map[20701] = 
{
    superior_map = 20700,
    darkmine = {min = 6, max = 8},
    weather_probability = {cloudy=1},
    mobility_cost = 1,
    start_location = 0,
    locations = {},
    monsters = {30701,30702,30703,30704,30705},
    box_monsters = {20004},
    location_groups = {},
}
map[20701].locations[6] = 
{
    adjacent_locations={7,},
    terrain = 'cave',
    convey2map = 20700,
    convey2location = 56,
}
map[20701].locations[7] = 
{
    adjacent_locations={8,6,},
    terrain = 'cave',
}
map[20701].locations[8] = 
{
    adjacent_locations={9,7,},
    terrain = 'cave',
    box = 1,
}
map[20701].locations[9] = 
{
    adjacent_locations={10,8,},
    terrain = 'cave',
}
map[20701].locations[10] = 
{
    adjacent_locations={11,9,},
    terrain = 'cave',
}
map[20701].locations[11] = 
{
    adjacent_locations={12,10,},
    terrain = 'cave',
}
map[20701].locations[12] = 
{
    adjacent_locations={11,14,},
    terrain = 'cave',
}
map[20701].locations[14] = 
{
    adjacent_locations={12,},
    terrain = 'cave',
    convey2map = 20700,
    convey2location = 53,
}
map[20701].location_groups[0] = 
{
    locations = {8},
    max_boxes = 1,
    possible_boxes = {{ sid = 10, probability = 0.3},{ sid = 11, probability = 0.5},{ sid = 12, probability = 0.2},},
}
map[20800] = 
{
    darkmine = {min = 9, max = 13},
    weather_probability = {rain=0.2,cloudy=0.4,fog=0.4},
    mobility_cost = 1,
    start_location = 59,
    locations = {},
    monsters = {30801,30802,30803,30804,30805},
    box_monsters = {20005},
    location_groups = {},
}
map[20800].locations[1] = 
{
    adjacent_locations={2,},
    terrain = 'plain',
    convey2map = 21200,
    convey2location = 108,
}
map[20800].locations[2] = 
{
    adjacent_locations={9,32,3,1,},
    terrain = 'plain',
}
map[20800].locations[3] = 
{
    adjacent_locations={2,4,12,},
    terrain = 'plain',
}
map[20800].locations[4] = 
{
    adjacent_locations={3,5,},
    terrain = 'plain',
}
map[20800].locations[5] = 
{
    adjacent_locations={4,6,},
    terrain = 'plain',
}
map[20800].locations[6] = 
{
    adjacent_locations={5,7,},
    terrain = 'plain',
}
map[20800].locations[7] = 
{
    adjacent_locations={6,8,},
    terrain = 'plain',
}
map[20800].locations[8] = 
{
    adjacent_locations={7,69,},
    terrain = 'plain',
}
map[20800].locations[9] = 
{
    adjacent_locations={2,},
    terrain = 'forest',
    box = 2,
}
map[20800].locations[10] = 
{
    adjacent_locations={30,11,},
    terrain = 'plain',
}
map[20800].locations[11] = 
{
    adjacent_locations={10,},
    terrain = 'plain',
    convey2map = 20801,
    convey2location = 1,
}
map[20800].locations[12] = 
{
    adjacent_locations={3,13,},
    terrain = 'plain',
}
map[20800].locations[13] = 
{
    adjacent_locations={12,14,},
    terrain = 'plain',
}
map[20800].locations[14] = 
{
    adjacent_locations={22,15,13,},
    terrain = 'plain',
}
map[20800].locations[15] = 
{
    adjacent_locations={14,16,},
    terrain = 'plain',
}
map[20800].locations[16] = 
{
    adjacent_locations={15,17,},
    terrain = 'plain',
}
map[20800].locations[17] = 
{
    adjacent_locations={16,18,},
    terrain = 'wasteland',
}
map[20800].locations[18] = 
{
    adjacent_locations={17,19,},
    terrain = 'wasteland',
    box = 1,
}
map[20800].locations[19] = 
{
    adjacent_locations={18,20,},
    terrain = 'wasteland',
}
map[20800].locations[20] = 
{
    adjacent_locations={19,21,},
    terrain = 'wasteland',
}
map[20800].locations[21] = 
{
    adjacent_locations={20,},
    terrain = 'wasteland',
}
map[20800].locations[22] = 
{
    adjacent_locations={23,14,},
    terrain = 'plain',
}
map[20800].locations[23] = 
{
    adjacent_locations={24,22,135,},
    terrain = 'plain',
}
map[20800].locations[24] = 
{
    adjacent_locations={25,23,},
    terrain = 'plain',
    box = 3,
}
map[20800].locations[25] = 
{
    adjacent_locations={27,24,},
    terrain = 'plain',
}
map[20800].locations[26] = 
{
    adjacent_locations={31,27,40,},
    terrain = 'plain',
}
map[20800].locations[27] = 
{
    adjacent_locations={26,28,25,},
    terrain = 'plain',
}
map[20800].locations[28] = 
{
    adjacent_locations={27,29,},
    terrain = 'plain',
}
map[20800].locations[29] = 
{
    adjacent_locations={28,30,},
    terrain = 'plain',
}
map[20800].locations[30] = 
{
    adjacent_locations={29,10,},
    terrain = 'plain',
}
map[20800].locations[31] = 
{
    adjacent_locations={41,26,},
    terrain = 'forest',
}
map[20800].locations[32] = 
{
    adjacent_locations={2,33,},
    terrain = 'forest',
}
map[20800].locations[33] = 
{
    adjacent_locations={34,32,},
    terrain = 'forest',
}
map[20800].locations[34] = 
{
    adjacent_locations={35,33,},
    terrain = 'forest',
}
map[20800].locations[35] = 
{
    adjacent_locations={36,34,},
    terrain = 'forest',
    box = 4,
}
map[20800].locations[36] = 
{
    adjacent_locations={37,35,},
    terrain = 'forest',
}
map[20800].locations[37] = 
{
    adjacent_locations={38,36,},
    terrain = 'forest',
}
map[20800].locations[38] = 
{
    adjacent_locations={39,37,},
    terrain = 'forest',
}
map[20800].locations[39] = 
{
    adjacent_locations={40,38,},
    terrain = 'forest',
}
map[20800].locations[40] = 
{
    adjacent_locations={26,39,},
    terrain = 'plain',
}
map[20800].locations[41] = 
{
    adjacent_locations={42,31,},
    terrain = 'forest',
}
map[20800].locations[42] = 
{
    adjacent_locations={43,41,},
    terrain = 'forest',
    box = 12,
}
map[20800].locations[43] = 
{
    adjacent_locations={44,42,},
    terrain = 'forest',
}
map[20800].locations[44] = 
{
    adjacent_locations={45,43,46,55,},
    terrain = 'forest',
}
map[20800].locations[45] = 
{
    adjacent_locations={44,},
    terrain = 'forest',
    convey2map = 20300,
    convey2location = 53,
}
map[20800].locations[46] = 
{
    adjacent_locations={47,44,},
    terrain = 'citadel',
}
map[20800].locations[47] = 
{
    adjacent_locations={48,46,},
    terrain = 'citadel',
}
map[20800].locations[48] = 
{
    adjacent_locations={49,47,},
    terrain = 'forest',
}
map[20800].locations[49] = 
{
    adjacent_locations={50,48,},
    terrain = 'forest',
}
map[20800].locations[50] = 
{
    adjacent_locations={51,49,},
    terrain = 'forest',
}
map[20800].locations[51] = 
{
    adjacent_locations={52,132,50,},
    terrain = 'plain',
}
map[20800].locations[52] = 
{
    adjacent_locations={53,51,},
    terrain = 'plain',
}
map[20800].locations[53] = 
{
    adjacent_locations={54,91,52,},
    terrain = 'plain',
}
map[20800].locations[54] = 
{
    adjacent_locations={90,53,},
    terrain = 'mountain',
}
map[20800].locations[55] = 
{
    adjacent_locations={44,131,},
    terrain = 'plain',
}
map[20800].locations[56] = 
{
    adjacent_locations={131,57,},
    terrain = 'plain',
}
map[20800].locations[57] = 
{
    adjacent_locations={56,96,58,},
    terrain = 'plain',
}
map[20800].locations[58] = 
{
    adjacent_locations={57,59,},
    terrain = 'plain',
}
map[20800].locations[59] = 
{
    adjacent_locations={58,60,},
    terrain = 'plain',
}
map[20800].locations[60] = 
{
    adjacent_locations={121,61,59,120,},
    terrain = 'mountain',
}
map[20800].locations[61] = 
{
    adjacent_locations={60,62,},
    terrain = 'mountain',
}
map[20800].locations[62] = 
{
    adjacent_locations={61,63,},
    terrain = 'lake',
}
map[20800].locations[63] = 
{
    adjacent_locations={72,62,64,},
    terrain = 'plain',
}
map[20800].locations[64] = 
{
    adjacent_locations={65,63,},
    terrain = 'mountain',
}
map[20800].locations[65] = 
{
    adjacent_locations={66,70,64,},
    terrain = 'plain',
}
map[20800].locations[66] = 
{
    adjacent_locations={67,65,},
    terrain = 'plain',
}
map[20800].locations[67] = 
{
    adjacent_locations={68,66,},
    terrain = 'forest',
}
map[20800].locations[68] = 
{
    adjacent_locations={69,67,},
    terrain = 'plain',
}
map[20800].locations[69] = 
{
    adjacent_locations={8,68,},
    terrain = 'mountain',
}
map[20800].locations[70] = 
{
    adjacent_locations={65,71,},
    terrain = 'plain',
}
map[20800].locations[71] = 
{
    adjacent_locations={70,},
    terrain = 'plain',
}
map[20800].locations[72] = 
{
    adjacent_locations={73,63,},
    terrain = 'forest',
}
map[20800].locations[73] = 
{
    adjacent_locations={72,74,},
    terrain = 'forest',
}
map[20800].locations[74] = 
{
    adjacent_locations={73,75,},
    terrain = 'mountain',
    box = 6,
}
map[20800].locations[75] = 
{
    adjacent_locations={74,76,},
    terrain = 'mountain',
}
map[20800].locations[76] = 
{
    adjacent_locations={75,77,},
    terrain = 'mountain',
}
map[20800].locations[77] = 
{
    adjacent_locations={76,78,},
    terrain = 'mountain',
}
map[20800].locations[78] = 
{
    adjacent_locations={77,79,},
    terrain = 'mountain',
}
map[20800].locations[79] = 
{
    adjacent_locations={78,80,},
    terrain = 'mountain',
}
map[20800].locations[80] = 
{
    adjacent_locations={79,81,},
    terrain = 'mountain',
}
map[20800].locations[81] = 
{
    adjacent_locations={80,82,},
    terrain = 'mountain',
}
map[20800].locations[82] = 
{
    adjacent_locations={81,83,},
    terrain = 'mountain',
}
map[20800].locations[83] = 
{
    adjacent_locations={82,105,84,},
    terrain = 'plain',
}
map[20800].locations[84] = 
{
    adjacent_locations={83,85,},
    terrain = 'plain',
}
map[20800].locations[85] = 
{
    adjacent_locations={84,127,86,},
    terrain = 'plain',
}
map[20800].locations[86] = 
{
    adjacent_locations={85,87,},
    terrain = 'mountain',
}
map[20800].locations[87] = 
{
    adjacent_locations={86,88,},
    terrain = 'forest',
}
map[20800].locations[88] = 
{
    adjacent_locations={87,89,},
    terrain = 'mountain',
    box = 7,
}
map[20800].locations[89] = 
{
    adjacent_locations={88,90,100,},
    terrain = 'forest',
}
map[20800].locations[90] = 
{
    adjacent_locations={89,54,},
    terrain = 'mountain',
}
map[20800].locations[91] = 
{
    adjacent_locations={53,92,},
    terrain = 'plain',
}
map[20800].locations[92] = 
{
    adjacent_locations={91,93,95,},
    terrain = 'plain',
}
map[20800].locations[93] = 
{
    adjacent_locations={92,94,},
    terrain = 'mountain',
}
map[20800].locations[94] = 
{
    adjacent_locations={93,},
    terrain = 'mountain',
}
map[20800].locations[95] = 
{
    adjacent_locations={92,},
    terrain = 'mountain',
    box = 8,
}
map[20800].locations[96] = 
{
    adjacent_locations={57,97,},
    terrain = 'citadel',
}
map[20800].locations[97] = 
{
    adjacent_locations={98,130,96,},
    terrain = 'citadel',
}
map[20800].locations[98] = 
{
    adjacent_locations={99,97,},
    terrain = 'plain',
}
map[20800].locations[99] = 
{
    adjacent_locations={132,98,},
    terrain = 'plain',
}
map[20800].locations[100] = 
{
    adjacent_locations={101,89,},
    terrain = 'mountain',
}
map[20800].locations[101] = 
{
    adjacent_locations={102,100,},
    terrain = 'mountain',
}
map[20800].locations[102] = 
{
    adjacent_locations={130,101,137,},
    terrain = 'citadel',
}
map[20800].locations[104] = 
{
    adjacent_locations={118,117,128,},
    terrain = 'mountain',
}
map[20800].locations[105] = 
{
    adjacent_locations={83,106,},
    terrain = 'mountain',
}
map[20800].locations[106] = 
{
    adjacent_locations={105,107,},
    terrain = 'mountain',
}
map[20800].locations[107] = 
{
    adjacent_locations={106,108,},
    terrain = 'mountain',
}
map[20800].locations[108] = 
{
    adjacent_locations={107,109,},
    terrain = 'mountain',
}
map[20800].locations[109] = 
{
    adjacent_locations={108,110,},
    terrain = 'mountain',
}
map[20800].locations[110] = 
{
    adjacent_locations={109,111,117,},
    terrain = 'mountain',
}
map[20800].locations[111] = 
{
    adjacent_locations={110,112,},
    terrain = 'citadel',
}
map[20800].locations[112] = 
{
    adjacent_locations={111,113,},
    terrain = 'mountain',
}
map[20800].locations[113] = 
{
    adjacent_locations={112,114,},
    terrain = 'mountain',
}
map[20800].locations[114] = 
{
    adjacent_locations={113,115,},
    terrain = 'mountain',
}
map[20800].locations[115] = 
{
    adjacent_locations={114,116,},
    terrain = 'mountain',
}
map[20800].locations[116] = 
{
    adjacent_locations={115,133,},
    terrain = 'mountain',
}
map[20800].locations[117] = 
{
    adjacent_locations={104,110,},
    terrain = 'mountain',
}
map[20800].locations[118] = 
{
    adjacent_locations={119,104,},
    terrain = 'mountain',
    box = 11,
}
map[20800].locations[119] = 
{
    adjacent_locations={120,118,},
    terrain = 'mountain',
}
map[20800].locations[120] = 
{
    adjacent_locations={60,119,},
    terrain = 'mountain',
}
map[20800].locations[121] = 
{
    adjacent_locations={122,60,},
    terrain = 'mountain',
}
map[20800].locations[122] = 
{
    adjacent_locations={123,121,},
    terrain = 'mountain',
    box = 10,
}
map[20800].locations[123] = 
{
    adjacent_locations={124,122,},
    terrain = 'mountain',
}
map[20800].locations[124] = 
{
    adjacent_locations={125,123,},
    terrain = 'mountain',
}
map[20800].locations[125] = 
{
    adjacent_locations={126,124,},
    terrain = 'mountain',
}
map[20800].locations[126] = 
{
    adjacent_locations={135,125,},
    terrain = 'mountain',
}
map[20800].locations[127] = 
{
    adjacent_locations={85,},
    terrain = 'plain',
}
map[20800].locations[128] = 
{
    adjacent_locations={104,137,},
    terrain = 'mountain',
}
map[20800].locations[130] = 
{
    adjacent_locations={97,102,},
    terrain = 'citadel',
}
map[20800].locations[131] = 
{
    adjacent_locations={55,56,},
    terrain = 'plain',
}
map[20800].locations[132] = 
{
    adjacent_locations={51,99,},
    terrain = 'citadel',
    box = 9,
}
map[20800].locations[133] = 
{
    adjacent_locations={116,134,},
    terrain = 'mountain',
    box = 5,
}
map[20800].locations[134] = 
{
    adjacent_locations={133,136,},
    terrain = 'mountain',
}
map[20800].locations[135] = 
{
    adjacent_locations={23,126,},
    terrain = 'citadel',
}
map[20800].locations[136] = 
{
    adjacent_locations={134,},
    terrain = 'citadel',
}
map[20800].locations[137] = 
{
    adjacent_locations={128,102,},
    terrain = 'citadel',
}
map[20800].location_groups[0] = 
{
    locations = {9,18,24,35},
    max_boxes = 1,
    possible_boxes = {{ sid = 13, probability = 0.3},{ sid = 14, probability = 0.5},{ sid = 15, probability = 0.2},},
}
map[20800].location_groups[1] = 
{
    locations = {74,88,95,133},
    max_boxes = 1,
    possible_boxes = {{ sid = 13, probability = 0.3},{ sid = 14, probability = 0.5},{ sid = 15, probability = 0.2},},
}
map[20800].location_groups[2] = 
{
    locations = {42,118,122,132},
    max_boxes = 1,
    possible_boxes = {{ sid = 13, probability = 0.3},{ sid = 14, probability = 0.5},{ sid = 15, probability = 0.2},},
}
map[20801] = 
{
    superior_map = 20800,
    darkmine = {min = 6, max = 8},
    weather_probability = {cloudy=1},
    mobility_cost = 1,
    start_location = 0,
    locations = {},
    monsters = {30801,30802,30803,30804,30805},
    box_monsters = {20006},
    location_groups = {},
}
map[20801].locations[1] = 
{
    adjacent_locations={2,},
    terrain = 'citadel',
    convey2map = 20800,
    convey2location = 11,
}
map[20801].locations[2] = 
{
    adjacent_locations={1,13,20,3,},
    terrain = 'citadel',
}
map[20801].locations[3] = 
{
    adjacent_locations={2,4,},
    terrain = 'citadel',
}
map[20801].locations[4] = 
{
    adjacent_locations={3,22,5,},
    terrain = 'citadel',
}
map[20801].locations[5] = 
{
    adjacent_locations={4,6,},
    terrain = 'citadel',
}
map[20801].locations[6] = 
{
    adjacent_locations={5,7,},
    terrain = 'citadel',
}
map[20801].locations[7] = 
{
    adjacent_locations={6,24,8,},
    terrain = 'citadel',
}
map[20801].locations[8] = 
{
    adjacent_locations={7,9,},
    terrain = 'citadel',
}
map[20801].locations[9] = 
{
    adjacent_locations={8,25,10,},
    terrain = 'citadel',
}
map[20801].locations[10] = 
{
    adjacent_locations={9,11,},
    terrain = 'citadel',
}
map[20801].locations[11] = 
{
    adjacent_locations={10,12,},
    terrain = 'citadel',
}
map[20801].locations[12] = 
{
    adjacent_locations={11,27,29,30,},
    terrain = 'citadel',
}
map[20801].locations[13] = 
{
    adjacent_locations={2,14,},
    terrain = 'citadel',
}
map[20801].locations[14] = 
{
    adjacent_locations={13,15,},
    terrain = 'citadel',
}
map[20801].locations[15] = 
{
    adjacent_locations={14,16,},
    terrain = 'citadel',
}
map[20801].locations[16] = 
{
    adjacent_locations={15,17,},
    terrain = 'citadel',
}
map[20801].locations[17] = 
{
    adjacent_locations={16,18,},
    terrain = 'citadel',
}
map[20801].locations[18] = 
{
    adjacent_locations={17,19,},
    terrain = 'citadel',
}
map[20801].locations[19] = 
{
    adjacent_locations={18,},
    terrain = 'citadel',
    box = 4,
}
map[20801].locations[20] = 
{
    adjacent_locations={2,21,},
    terrain = 'citadel',
}
map[20801].locations[21] = 
{
    adjacent_locations={20,},
    terrain = 'citadel',
    box = 1,
}
map[20801].locations[22] = 
{
    adjacent_locations={4,23,},
    terrain = 'citadel',
}
map[20801].locations[23] = 
{
    adjacent_locations={22,},
    terrain = 'citadel',
}
map[20801].locations[24] = 
{
    adjacent_locations={7,},
    terrain = 'citadel',
}
map[20801].locations[25] = 
{
    adjacent_locations={9,26,},
    terrain = 'citadel',
}
map[20801].locations[26] = 
{
    adjacent_locations={25,},
    terrain = 'citadel',
    box = 3,
}
map[20801].locations[27] = 
{
    adjacent_locations={12,28,},
    terrain = 'citadel',
    box = 2,
}
map[20801].locations[28] = 
{
    adjacent_locations={27,},
    terrain = 'citadel',
}
map[20801].locations[29] = 
{
    adjacent_locations={12,},
    terrain = 'citadel',
}
map[20801].locations[30] = 
{
    adjacent_locations={12,31,},
    terrain = 'citadel',
}
map[20801].locations[31] = 
{
    adjacent_locations={30,32,},
    terrain = 'citadel',
}
map[20801].locations[32] = 
{
    adjacent_locations={31,33,},
    terrain = 'citadel',
}
map[20801].locations[33] = 
{
    adjacent_locations={32,},
    terrain = 'citadel',
}
map[20801].location_groups[0] = 
{
    locations = {19,21,26,27},
    max_boxes = 1,
    possible_boxes = {{ sid = 13, probability = 0.2},{ sid = 14, probability = 0.4},{ sid = 15, probability = 0.4},},
}
map[20900] = 
{
    darkmine = {min = 9, max = 13},
    weather_probability = {sunny=0.8,cloudy=0.2},
    mobility_cost = 1,
    start_location = 96,
    locations = {},
    monsters = {30901,30902,30903,30904,30905},
    box_monsters = {20007},
    location_groups = {},
}
map[20900].locations[1] = 
{
    adjacent_locations={2,},
    terrain = 'wasteland',
    convey2map = 21100,
    convey2location = 91,
}
map[20900].locations[2] = 
{
    adjacent_locations={1,3,},
    terrain = 'wasteland',
}
map[20900].locations[3] = 
{
    adjacent_locations={2,4,},
    terrain = 'wasteland',
}
map[20900].locations[4] = 
{
    adjacent_locations={3,89,5,},
    terrain = 'wasteland',
}
map[20900].locations[5] = 
{
    adjacent_locations={4,6,},
    terrain = 'wasteland',
}
map[20900].locations[6] = 
{
    adjacent_locations={5,7,},
    terrain = 'wasteland',
}
map[20900].locations[7] = 
{
    adjacent_locations={6,8,},
    terrain = 'wasteland',
}
map[20900].locations[8] = 
{
    adjacent_locations={7,9,},
    terrain = 'wasteland',
}
map[20900].locations[9] = 
{
    adjacent_locations={8,10,},
    terrain = 'wasteland',
}
map[20900].locations[10] = 
{
    adjacent_locations={9,11,},
    terrain = 'wasteland',
}
map[20900].locations[11] = 
{
    adjacent_locations={10,12,},
    terrain = 'wasteland',
}
map[20900].locations[12] = 
{
    adjacent_locations={11,13,},
    terrain = 'wasteland',
}
map[20900].locations[13] = 
{
    adjacent_locations={12,14,15,},
    terrain = 'wasteland',
}
map[20900].locations[14] = 
{
    adjacent_locations={13,},
    terrain = 'wasteland',
    convey2map = 20300,
    convey2location = 38,
}
map[20900].locations[15] = 
{
    adjacent_locations={13,16,},
    terrain = 'wasteland',
}
map[20900].locations[16] = 
{
    adjacent_locations={15,17,},
    terrain = 'wasteland',
}
map[20900].locations[17] = 
{
    adjacent_locations={16,18,25,},
    terrain = 'wasteland',
}
map[20900].locations[18] = 
{
    adjacent_locations={17,19,},
    terrain = 'mountain',
}
map[20900].locations[19] = 
{
    adjacent_locations={18,21,},
    terrain = 'mountain',
}
map[20900].locations[21] = 
{
    adjacent_locations={22,19,},
    terrain = 'mountain',
    box = 2,
}
map[20900].locations[22] = 
{
    adjacent_locations={21,23,},
    terrain = 'mountain',
}
map[20900].locations[23] = 
{
    adjacent_locations={22,24,},
    terrain = 'mountain',
}
map[20900].locations[24] = 
{
    adjacent_locations={23,},
    terrain = 'mountain',
}
map[20900].locations[25] = 
{
    adjacent_locations={17,26,},
    terrain = 'wasteland',
}
map[20900].locations[26] = 
{
    adjacent_locations={25,27,},
    terrain = 'wasteland',
}
map[20900].locations[27] = 
{
    adjacent_locations={26,28,},
    terrain = 'wasteland',
}
map[20900].locations[28] = 
{
    adjacent_locations={27,29,},
    terrain = 'lake',
}
map[20900].locations[29] = 
{
    adjacent_locations={28,30,},
    terrain = 'lake',
}
map[20900].locations[30] = 
{
    adjacent_locations={29,31,},
    terrain = 'lake',
}
map[20900].locations[31] = 
{
    adjacent_locations={30,32,},
    terrain = 'lake',
}
map[20900].locations[32] = 
{
    adjacent_locations={31,33,36,},
    terrain = 'lake',
}
map[20900].locations[33] = 
{
    adjacent_locations={32,34,},
    terrain = 'lake',
}
map[20900].locations[34] = 
{
    adjacent_locations={33,35,},
    terrain = 'lake',
}
map[20900].locations[35] = 
{
    adjacent_locations={34,},
    terrain = 'lake',
    box = 6,
}
map[20900].locations[36] = 
{
    adjacent_locations={37,32,},
    terrain = 'lake',
}
map[20900].locations[37] = 
{
    adjacent_locations={102,36,38,},
    terrain = 'wasteland',
}
map[20900].locations[38] = 
{
    adjacent_locations={37,39,},
    terrain = 'wasteland',
}
map[20900].locations[39] = 
{
    adjacent_locations={38,40,44,},
    terrain = 'coastal',
}
map[20900].locations[40] = 
{
    adjacent_locations={39,41,},
    terrain = 'coastal',
}
map[20900].locations[41] = 
{
    adjacent_locations={40,42,},
    terrain = 'coastal',
}
map[20900].locations[42] = 
{
    adjacent_locations={41,43,},
    terrain = 'lake',
}
map[20900].locations[43] = 
{
    adjacent_locations={42,117,},
    terrain = 'lake',
}
map[20900].locations[44] = 
{
    adjacent_locations={39,45,},
    terrain = 'coastal',
}
map[20900].locations[45] = 
{
    adjacent_locations={44,46,},
    terrain = 'coastal',
    box = 8,
}
map[20900].locations[46] = 
{
    adjacent_locations={45,47,},
    terrain = 'wasteland',
}
map[20900].locations[47] = 
{
    adjacent_locations={46,48,},
    terrain = 'wasteland',
    convey2map = 20901,
    convey2location = 1,
}
map[20900].locations[48] = 
{
    adjacent_locations={47,49,},
    terrain = 'wasteland',
}
map[20900].locations[49] = 
{
    adjacent_locations={48,50,},
    terrain = 'wasteland',
}
map[20900].locations[50] = 
{
    adjacent_locations={49,54,51,},
    terrain = 'wasteland',
}
map[20900].locations[51] = 
{
    adjacent_locations={50,52,},
    terrain = 'wasteland',
}
map[20900].locations[52] = 
{
    adjacent_locations={51,53,},
    terrain = 'wasteland',
}
map[20900].locations[53] = 
{
    adjacent_locations={52,57,},
    terrain = 'wasteland',
}
map[20900].locations[54] = 
{
    adjacent_locations={50,116,},
    terrain = 'wasteland',
}
map[20900].locations[55] = 
{
    adjacent_locations={56,},
    terrain = 'wasteland',
}
map[20900].locations[56] = 
{
    adjacent_locations={55,57,},
    terrain = 'wasteland',
}
map[20900].locations[57] = 
{
    adjacent_locations={56,58,53,},
    terrain = 'wasteland',
}
map[20900].locations[58] = 
{
    adjacent_locations={57,59,},
    terrain = 'wasteland',
}
map[20900].locations[59] = 
{
    adjacent_locations={58,60,},
    terrain = 'wasteland',
    box = 12,
}
map[20900].locations[60] = 
{
    adjacent_locations={59,66,61,},
    terrain = 'wasteland',
}
map[20900].locations[61] = 
{
    adjacent_locations={60,62,},
    terrain = 'wasteland',
}
map[20900].locations[62] = 
{
    adjacent_locations={61,63,},
    terrain = 'wasteland',
}
map[20900].locations[63] = 
{
    adjacent_locations={62,64,},
    terrain = 'wasteland',
}
map[20900].locations[64] = 
{
    adjacent_locations={63,65,70,},
    terrain = 'wasteland',
}
map[20900].locations[65] = 
{
    adjacent_locations={64,},
    terrain = 'wasteland',
    convey2map = 20400,
    convey2location = 11,
}
map[20900].locations[66] = 
{
    adjacent_locations={60,114,},
    terrain = 'wasteland',
}
map[20900].locations[67] = 
{
    adjacent_locations={86,91,94,},
    terrain = 'wasteland',
}
map[20900].locations[70] = 
{
    adjacent_locations={64,71,},
    terrain = 'mountain',
}
map[20900].locations[71] = 
{
    adjacent_locations={70,72,},
    terrain = 'mountain',
}
map[20900].locations[72] = 
{
    adjacent_locations={71,73,},
    terrain = 'mountain',
}
map[20900].locations[73] = 
{
    adjacent_locations={72,74,},
    terrain = 'mountain',
}
map[20900].locations[74] = 
{
    adjacent_locations={73,75,},
    terrain = 'mountain',
    box = 11,
}
map[20900].locations[75] = 
{
    adjacent_locations={74,76,},
    terrain = 'mountain',
}
map[20900].locations[76] = 
{
    adjacent_locations={75,77,},
    terrain = 'mountain',
}
map[20900].locations[77] = 
{
    adjacent_locations={76,78,},
    terrain = 'wasteland',
}
map[20900].locations[78] = 
{
    adjacent_locations={77,81,},
    terrain = 'wasteland',
}
map[20900].locations[81] = 
{
    adjacent_locations={82,78,},
    terrain = 'wasteland',
}
map[20900].locations[82] = 
{
    adjacent_locations={83,81,},
    terrain = 'wasteland',
}
map[20900].locations[83] = 
{
    adjacent_locations={84,82,},
    terrain = 'wasteland',
    box = 4,
}
map[20900].locations[84] = 
{
    adjacent_locations={85,83,},
    terrain = 'wasteland',
}
map[20900].locations[85] = 
{
    adjacent_locations={86,84,},
    terrain = 'wasteland',
}
map[20900].locations[86] = 
{
    adjacent_locations={87,85,67,},
    terrain = 'wasteland',
}
map[20900].locations[87] = 
{
    adjacent_locations={88,86,},
    terrain = 'wasteland',
}
map[20900].locations[88] = 
{
    adjacent_locations={89,87,},
    terrain = 'wasteland',
}
map[20900].locations[89] = 
{
    adjacent_locations={4,88,},
    terrain = 'wasteland',
    box = 1,
}
map[20900].locations[91] = 
{
    adjacent_locations={67,92,},
    terrain = 'wasteland',
}
map[20900].locations[92] = 
{
    adjacent_locations={91,93,},
    terrain = 'wasteland',
}
map[20900].locations[93] = 
{
    adjacent_locations={92,115,},
    terrain = 'wasteland',
}
map[20900].locations[94] = 
{
    adjacent_locations={67,95,},
    terrain = 'wasteland',
}
map[20900].locations[95] = 
{
    adjacent_locations={94,96,},
    terrain = 'wasteland',
}
map[20900].locations[96] = 
{
    adjacent_locations={95,97,},
    terrain = 'wasteland',
}
map[20900].locations[97] = 
{
    adjacent_locations={96,98,},
    terrain = 'wasteland',
}
map[20900].locations[98] = 
{
    adjacent_locations={97,99,},
    terrain = 'wasteland',
}
map[20900].locations[99] = 
{
    adjacent_locations={98,103,100,},
    terrain = 'wasteland',
}
map[20900].locations[100] = 
{
    adjacent_locations={101,99,},
    terrain = 'wasteland',
}
map[20900].locations[101] = 
{
    adjacent_locations={100,102,},
    terrain = 'wasteland',
}
map[20900].locations[102] = 
{
    adjacent_locations={101,37,},
    terrain = 'wasteland',
}
map[20900].locations[103] = 
{
    adjacent_locations={99,104,},
    terrain = 'wasteland',
}
map[20900].locations[104] = 
{
    adjacent_locations={103,105,},
    terrain = 'wasteland',
}
map[20900].locations[105] = 
{
    adjacent_locations={104,110,106,},
    terrain = 'wasteland',
}
map[20900].locations[106] = 
{
    adjacent_locations={105,107,},
    terrain = 'wasteland',
}
map[20900].locations[107] = 
{
    adjacent_locations={106,108,},
    terrain = 'wasteland',
}
map[20900].locations[108] = 
{
    adjacent_locations={107,109,},
    terrain = 'wasteland',
}
map[20900].locations[109] = 
{
    adjacent_locations={108,},
    terrain = 'wasteland',
    box = 9,
}
map[20900].locations[110] = 
{
    adjacent_locations={111,105,},
    terrain = 'wasteland',
}
map[20900].locations[111] = 
{
    adjacent_locations={112,110,},
    terrain = 'wasteland',
}
map[20900].locations[112] = 
{
    adjacent_locations={113,111,},
    terrain = 'wasteland',
}
map[20900].locations[113] = 
{
    adjacent_locations={114,112,},
    terrain = 'wasteland',
    box = 10,
}
map[20900].locations[114] = 
{
    adjacent_locations={66,113,},
    terrain = 'wasteland',
}
map[20900].locations[115] = 
{
    adjacent_locations={93,},
    terrain = 'wasteland',
    box = 3,
}
map[20900].locations[116] = 
{
    adjacent_locations={54,},
    terrain = 'wasteland',
    box = 7,
}
map[20900].locations[117] = 
{
    adjacent_locations={43,},
    terrain = 'coastal',
    box = 5,
}
map[20900].location_groups[0] = 
{
    locations = {21,83,89,115},
    max_boxes = 1,
    possible_boxes = {{ sid = 16, probability = 0.3},{ sid = 17, probability = 0.5},{ sid = 18, probability = 0.2},},
}
map[20900].location_groups[1] = 
{
    locations = {35,45,116,117},
    max_boxes = 1,
    possible_boxes = {{ sid = 16, probability = 0.3},{ sid = 17, probability = 0.5},{ sid = 18, probability = 0.2},},
}
map[20900].location_groups[2] = 
{
    locations = {59,74,109,113},
    max_boxes = 1,
    possible_boxes = {{ sid = 16, probability = 0.3},{ sid = 17, probability = 0.5},{ sid = 18, probability = 0.2},},
}
map[20901] = 
{
    superior_map = 20900,
    darkmine = {min = 6, max = 8},
    weather_probability = {cloudy=1},
    mobility_cost = 1,
    start_location = 0,
    locations = {},
    monsters = {30901,30902,30903,30904,30905},
    box_monsters = {20008},
    location_groups = {},
}
map[20901].locations[1] = 
{
    adjacent_locations={2,},
    terrain = 'cave',
    convey2map = 20900,
    convey2location = 47,
}
map[20901].locations[2] = 
{
    adjacent_locations={1,3,17,10,},
    terrain = 'cave',
}
map[20901].locations[3] = 
{
    adjacent_locations={2,4,},
    terrain = 'cave',
}
map[20901].locations[4] = 
{
    adjacent_locations={3,5,},
    terrain = 'cave',
}
map[20901].locations[5] = 
{
    adjacent_locations={4,6,},
    terrain = 'cave',
}
map[20901].locations[6] = 
{
    adjacent_locations={5,7,},
    terrain = 'cave',
}
map[20901].locations[7] = 
{
    adjacent_locations={6,8,},
    terrain = 'cave',
}
map[20901].locations[8] = 
{
    adjacent_locations={7,9,},
    terrain = 'cave',
    box = 3,
}
map[20901].locations[9] = 
{
    adjacent_locations={8,},
    terrain = 'cave',
}
map[20901].locations[10] = 
{
    adjacent_locations={2,11,},
    terrain = 'cave',
}
map[20901].locations[11] = 
{
    adjacent_locations={10,12,},
    terrain = 'cave',
    box = 1,
}
map[20901].locations[12] = 
{
    adjacent_locations={11,13,},
    terrain = 'cave',
}
map[20901].locations[13] = 
{
    adjacent_locations={12,14,},
    terrain = 'cave',
}
map[20901].locations[14] = 
{
    adjacent_locations={13,15,},
    terrain = 'cave',
}
map[20901].locations[15] = 
{
    adjacent_locations={14,16,},
    terrain = 'cave',
}
map[20901].locations[16] = 
{
    adjacent_locations={15,},
    terrain = 'cave',
    box = 2,
}
map[20901].locations[17] = 
{
    adjacent_locations={2,18,},
    terrain = 'cave',
}
map[20901].locations[18] = 
{
    adjacent_locations={17,19,},
    terrain = 'cave',
}
map[20901].locations[19] = 
{
    adjacent_locations={18,20,},
    terrain = 'cave',
}
map[20901].locations[20] = 
{
    adjacent_locations={19,21,},
    terrain = 'cave',
}
map[20901].locations[21] = 
{
    adjacent_locations={20,22,},
    terrain = 'cave',
}
map[20901].locations[22] = 
{
    adjacent_locations={21,23,},
    terrain = 'cave',
    box = 4,
}
map[20901].locations[23] = 
{
    adjacent_locations={22,},
    terrain = 'cave',
}
map[20901].location_groups[0] = 
{
    locations = {8,11,16,22},
    max_boxes = 1,
    possible_boxes = {{ sid = 16, probability = 0.2},{ sid = 17, probability = 0.4},{ sid = 18, probability = 0.4},},
}
map[21000] = 
{
    darkmine = {min = 9, max = 13},
    weather_probability = {cloudy=0.4,rain=0.2,fog=0.4},
    mobility_cost = 1,
    start_location = 8,
    locations = {},
    monsters = {31001,31002,31003,31004,31005},
    box_monsters = {20008},
    location_groups = {},
}
map[21000].locations[1] = 
{
    adjacent_locations={2,87,},
    terrain = 'plain',
}
map[21000].locations[2] = 
{
    adjacent_locations={1,3,94,},
    terrain = 'plain',
}
map[21000].locations[3] = 
{
    adjacent_locations={2,4,55,},
    terrain = 'plain',
}
map[21000].locations[4] = 
{
    adjacent_locations={3,5,},
    terrain = 'mountain',
}
map[21000].locations[5] = 
{
    adjacent_locations={4,6,},
    terrain = 'mountain',
}
map[21000].locations[6] = 
{
    adjacent_locations={5,10,7,},
    terrain = 'mountain',
}
map[21000].locations[7] = 
{
    adjacent_locations={6,8,},
    terrain = 'plain',
}
map[21000].locations[8] = 
{
    adjacent_locations={7,9,13,},
    terrain = 'plain',
}
map[21000].locations[9] = 
{
    adjacent_locations={8,16,},
    terrain = 'cave',
    convey2map = 21001,
    convey2location = 14,
}
map[21000].locations[10] = 
{
    adjacent_locations={6,11,},
    terrain = 'forest',
}
map[21000].locations[11] = 
{
    adjacent_locations={10,12,},
    terrain = 'forest',
}
map[21000].locations[12] = 
{
    adjacent_locations={11,96,},
    terrain = 'forest',
}
map[21000].locations[13] = 
{
    adjacent_locations={8,14,},
    terrain = 'plain',
}
map[21000].locations[14] = 
{
    adjacent_locations={13,15,},
    terrain = 'mountain',
}
map[21000].locations[15] = 
{
    adjacent_locations={14,86,},
    terrain = 'mountain',
}
map[21000].locations[16] = 
{
    adjacent_locations={9,17,},
    terrain = 'mountain',
}
map[21000].locations[17] = 
{
    adjacent_locations={16,18,},
    terrain = 'mountain',
}
map[21000].locations[18] = 
{
    adjacent_locations={17,19,},
    terrain = 'mountain',
}
map[21000].locations[19] = 
{
    adjacent_locations={18,20,},
    terrain = 'plain',
}
map[21000].locations[20] = 
{
    adjacent_locations={19,21,},
    terrain = 'mountain',
}
map[21000].locations[21] = 
{
    adjacent_locations={20,22,},
    terrain = 'forest',
}
map[21000].locations[22] = 
{
    adjacent_locations={21,23,},
    terrain = 'forest',
}
map[21000].locations[23] = 
{
    adjacent_locations={22,24,},
    terrain = 'forest',
}
map[21000].locations[24] = 
{
    adjacent_locations={23,26,},
    terrain = 'forest',
}
map[21000].locations[25] = 
{
    adjacent_locations={26,30,},
    terrain = 'mountain',
}
map[21000].locations[26] = 
{
    adjacent_locations={25,27,24,},
    terrain = 'forest',
}
map[21000].locations[27] = 
{
    adjacent_locations={26,28,},
    terrain = 'forest',
}
map[21000].locations[28] = 
{
    adjacent_locations={27,29,},
    terrain = 'forest',
}
map[21000].locations[29] = 
{
    adjacent_locations={28,},
    terrain = 'forest',
}
map[21000].locations[30] = 
{
    adjacent_locations={25,31,},
    terrain = 'mountain',
}
map[21000].locations[31] = 
{
    adjacent_locations={30,32,33,},
    terrain = 'mountain',
}
map[21000].locations[32] = 
{
    adjacent_locations={31,},
    terrain = 'mountain',
    convey2map = 20700,
    convey2location = 17,
}
map[21000].locations[33] = 
{
    adjacent_locations={31,34,},
    terrain = 'mountain',
}
map[21000].locations[34] = 
{
    adjacent_locations={33,35,},
    terrain = 'mountain',
}
map[21000].locations[35] = 
{
    adjacent_locations={34,36,},
    terrain = 'forest',
}
map[21000].locations[36] = 
{
    adjacent_locations={35,37,},
    terrain = 'forest',
}
map[21000].locations[37] = 
{
    adjacent_locations={36,38,},
    terrain = 'forest',
}
map[21000].locations[38] = 
{
    adjacent_locations={37,39,98,},
    terrain = 'forest',
}
map[21000].locations[39] = 
{
    adjacent_locations={38,40,},
    terrain = 'forest',
}
map[21000].locations[40] = 
{
    adjacent_locations={39,84,},
    terrain = 'forest',
}
map[21000].locations[41] = 
{
    adjacent_locations={42,},
    terrain = 'mountain',
}
map[21000].locations[42] = 
{
    adjacent_locations={41,43,},
    terrain = 'mountain',
}
map[21000].locations[43] = 
{
    adjacent_locations={42,44,},
    terrain = 'mountain',
}
map[21000].locations[44] = 
{
    adjacent_locations={43,90,},
    terrain = 'mountain',
}
map[21000].locations[45] = 
{
    adjacent_locations={79,46,90,},
    terrain = 'mountain',
}
map[21000].locations[46] = 
{
    adjacent_locations={45,47,},
    terrain = 'mountain',
}
map[21000].locations[47] = 
{
    adjacent_locations={46,48,},
    terrain = 'mountain',
}
map[21000].locations[48] = 
{
    adjacent_locations={47,49,},
    terrain = 'mountain',
}
map[21000].locations[49] = 
{
    adjacent_locations={48,50,},
    terrain = 'mountain',
}
map[21000].locations[50] = 
{
    adjacent_locations={49,92,},
    terrain = 'mountain',
}
map[21000].locations[51] = 
{
    adjacent_locations={52,92,},
    terrain = 'cave',
    convey2map = 21001,
    convey2location = 6,
}
map[21000].locations[52] = 
{
    adjacent_locations={51,53,},
    terrain = 'lake',
}
map[21000].locations[53] = 
{
    adjacent_locations={52,54,56,},
    terrain = 'lake',
}
map[21000].locations[54] = 
{
    adjacent_locations={53,93,},
    terrain = 'lake',
}
map[21000].locations[55] = 
{
    adjacent_locations={3,93,},
    terrain = 'plain',
}
map[21000].locations[56] = 
{
    adjacent_locations={53,88,},
    terrain = 'lake',
}
map[21000].locations[57] = 
{
    adjacent_locations={58,89,},
    terrain = 'plain',
}
map[21000].locations[58] = 
{
    adjacent_locations={59,57,},
    terrain = 'plain',
}
map[21000].locations[59] = 
{
    adjacent_locations={60,58,},
    terrain = 'plain',
}
map[21000].locations[60] = 
{
    adjacent_locations={61,59,},
    terrain = 'plain',
}
map[21000].locations[61] = 
{
    adjacent_locations={62,60,},
    terrain = 'plain',
}
map[21000].locations[62] = 
{
    adjacent_locations={63,61,},
    terrain = 'plain',
}
map[21000].locations[63] = 
{
    adjacent_locations={64,62,},
    terrain = 'mountain',
}
map[21000].locations[64] = 
{
    adjacent_locations={63,65,88,},
    terrain = 'mountain',
}
map[21000].locations[65] = 
{
    adjacent_locations={64,66,},
    terrain = 'mountain',
}
map[21000].locations[66] = 
{
    adjacent_locations={65,67,},
    terrain = 'mountain',
}
map[21000].locations[67] = 
{
    adjacent_locations={66,68,70,},
    terrain = 'plain',
}
map[21000].locations[68] = 
{
    adjacent_locations={67,69,},
    terrain = 'plain',
}
map[21000].locations[69] = 
{
    adjacent_locations={68,},
    terrain = 'mountain',
    convey2map = 21400,
    convey2location = 53,
}
map[21000].locations[70] = 
{
    adjacent_locations={67,71,},
    terrain = 'mountain',
}
map[21000].locations[71] = 
{
    adjacent_locations={70,72,},
    terrain = 'mountain',
}
map[21000].locations[72] = 
{
    adjacent_locations={71,73,},
    terrain = 'mountain',
}
map[21000].locations[73] = 
{
    adjacent_locations={72,74,},
    terrain = 'mountain',
}
map[21000].locations[74] = 
{
    adjacent_locations={73,80,75,},
    terrain = 'mountain',
}
map[21000].locations[75] = 
{
    adjacent_locations={74,76,},
    terrain = 'mountain',
}
map[21000].locations[76] = 
{
    adjacent_locations={75,77,},
    terrain = 'mountain',
}
map[21000].locations[77] = 
{
    adjacent_locations={76,91,},
    terrain = 'mountain',
}
map[21000].locations[78] = 
{
    adjacent_locations={79,97,},
    terrain = 'mountain',
}
map[21000].locations[79] = 
{
    adjacent_locations={78,45,},
    terrain = 'mountain',
}
map[21000].locations[80] = 
{
    adjacent_locations={74,81,},
    terrain = 'mountain',
}
map[21000].locations[81] = 
{
    adjacent_locations={80,82,},
    terrain = 'mountain',
}
map[21000].locations[82] = 
{
    adjacent_locations={81,83,},
    terrain = 'mountain',
}
map[21000].locations[83] = 
{
    adjacent_locations={82,},
    terrain = 'citadel',
    convey2map = 21002,
    convey2location = 1,
}
map[21000].locations[84] = 
{
    adjacent_locations={40,85,},
    terrain = 'forest',
}
map[21000].locations[85] = 
{
    adjacent_locations={84,},
    weather = 'fog',
    terrain = 'forest',
}
map[21000].locations[86] = 
{
    adjacent_locations={15,},
    terrain = 'mountain',
}
map[21000].locations[87] = 
{
    adjacent_locations={1,},
    terrain = 'plain',
    convey2map = 20600,
    convey2location = 109,
}
map[21000].locations[88] = 
{
    adjacent_locations={56,64,},
    terrain = 'mountain',
}
map[21000].locations[89] = 
{
    adjacent_locations={57,},
    terrain = 'plain',
}
map[21000].locations[90] = 
{
    adjacent_locations={45,44,},
    terrain = 'mountain',
}
map[21000].locations[91] = 
{
    adjacent_locations={77,97,},
    terrain = 'mountain',
}
map[21000].locations[92] = 
{
    adjacent_locations={50,51,},
    terrain = 'mountain',
}
map[21000].locations[93] = 
{
    adjacent_locations={54,55,},
    terrain = 'forest',
}
map[21000].locations[94] = 
{
    adjacent_locations={2,95,},
    terrain = 'mountain',
}
map[21000].locations[95] = 
{
    adjacent_locations={94,96,},
    terrain = 'forest',
}
map[21000].locations[96] = 
{
    adjacent_locations={95,12,},
    terrain = 'forest',
}
map[21000].locations[97] = 
{
    adjacent_locations={91,98,78,},
    terrain = 'mountain',
}
map[21000].locations[98] = 
{
    adjacent_locations={97,38,},
    terrain = 'forest',
}
map[21001] = 
{
    superior_map = 21000,
    darkmine = {min = 6, max = 8},
    weather_probability = {cloudy=1},
    mobility_cost = 1,
    start_location = 0,
    locations = {},
    monsters = {31001,31002,31003,31004,31005},
    box_monsters = {20008},
    location_groups = {},
}
map[21001].locations[6] = 
{
    adjacent_locations={7,},
    terrain = 'cave',
    convey2map = 21000,
    convey2location = 51,
}
map[21001].locations[7] = 
{
    adjacent_locations={8,6,},
    terrain = 'cave',
}
map[21001].locations[8] = 
{
    adjacent_locations={9,7,},
    terrain = 'cave',
}
map[21001].locations[9] = 
{
    adjacent_locations={10,8,},
    terrain = 'cave',
}
map[21001].locations[10] = 
{
    adjacent_locations={11,9,},
    terrain = 'cave',
}
map[21001].locations[11] = 
{
    adjacent_locations={12,10,},
    terrain = 'cave',
}
map[21001].locations[12] = 
{
    adjacent_locations={13,11,},
    terrain = 'cave',
}
map[21001].locations[13] = 
{
    adjacent_locations={12,15,},
    terrain = 'cave',
}
map[21001].locations[14] = 
{
    adjacent_locations={18,},
    terrain = 'cave',
    convey2map = 21000,
    convey2location = 9,
}
map[21001].locations[15] = 
{
    adjacent_locations={13,16,},
    terrain = 'cave',
}
map[21001].locations[16] = 
{
    adjacent_locations={15,18,17,},
    terrain = 'cave',
}
map[21001].locations[17] = 
{
    adjacent_locations={19,16,},
    terrain = 'cave',
}
map[21001].locations[18] = 
{
    adjacent_locations={16,14,},
    terrain = 'cave',
}
map[21001].locations[19] = 
{
    adjacent_locations={17,20,},
    terrain = 'cave',
}
map[21001].locations[20] = 
{
    adjacent_locations={19,21,},
    terrain = 'cave',
}
map[21001].locations[21] = 
{
    adjacent_locations={20,22,},
    terrain = 'cave',
}
map[21001].locations[22] = 
{
    adjacent_locations={21,23,},
    terrain = 'cave',
}
map[21001].locations[23] = 
{
    adjacent_locations={22,24,},
    terrain = 'cave',
}
map[21001].locations[24] = 
{
    adjacent_locations={23,25,},
    terrain = 'cave',
}
map[21001].locations[25] = 
{
    adjacent_locations={24,26,},
    terrain = 'cave',
}
map[21001].locations[26] = 
{
    adjacent_locations={25,},
    terrain = 'cave',
}
map[21002] = 
{
    superior_map = 21000,
    darkmine = {min = 6, max = 8},
    weather_probability = {cloudy=1},
    mobility_cost = 1,
    start_location = 0,
    locations = {},
    monsters = {31001,31002,31003,31004,31005},
    box_monsters = {20008},
    location_groups = {},
}
map[21002].locations[1] = 
{
    adjacent_locations={2,},
    terrain = 'citadel',
    convey2map = 21000,
    convey2location = 83,
}
map[21002].locations[2] = 
{
    adjacent_locations={1,3,},
    terrain = 'citadel',
}
map[21002].locations[3] = 
{
    adjacent_locations={2,4,},
    terrain = 'citadel',
}
map[21002].locations[4] = 
{
    adjacent_locations={3,5,},
    terrain = 'citadel',
}
map[21002].locations[5] = 
{
    adjacent_locations={4,6,},
    terrain = 'citadel',
}
map[21002].locations[6] = 
{
    adjacent_locations={5,},
    terrain = 'citadel',
}
map[21100] = 
{
    darkmine = {min = 9, max = 13},
    weather_probability = {cloudy=1},
    mobility_cost = 1,
    start_location = 71,
    locations = {},
    monsters = {31101,31102,31103,31104,31105},
    box_monsters = {20009},
    location_groups = {},
}
map[21100].locations[1] = 
{
    adjacent_locations={2,},
    terrain = 'wasteland',
}
map[21100].locations[2] = 
{
    adjacent_locations={1,3,},
    terrain = 'forest',
}
map[21100].locations[3] = 
{
    adjacent_locations={2,4,},
    terrain = 'forest',
}
map[21100].locations[4] = 
{
    adjacent_locations={3,93,5,},
    terrain = 'plain',
}
map[21100].locations[5] = 
{
    adjacent_locations={4,6,},
    terrain = 'plain',
}
map[21100].locations[6] = 
{
    adjacent_locations={5,9,73,},
    terrain = 'plain',
}
map[21100].locations[9] = 
{
    adjacent_locations={6,10,},
    terrain = 'plain',
}
map[21100].locations[10] = 
{
    adjacent_locations={9,11,},
    terrain = 'forest',
}
map[21100].locations[11] = 
{
    adjacent_locations={10,12,33,47,},
    terrain = 'mountain',
}
map[21100].locations[12] = 
{
    adjacent_locations={11,13,},
    terrain = 'mountain',
}
map[21100].locations[13] = 
{
    adjacent_locations={14,12,},
    terrain = 'mountain',
}
map[21100].locations[14] = 
{
    adjacent_locations={13,15,17,},
    terrain = 'mountain',
}
map[21100].locations[15] = 
{
    adjacent_locations={14,16,},
    terrain = 'mountain',
}
map[21100].locations[16] = 
{
    adjacent_locations={15,},
    terrain = 'mountain',
}
map[21100].locations[17] = 
{
    adjacent_locations={14,18,},
    terrain = 'mountain',
}
map[21100].locations[18] = 
{
    adjacent_locations={17,24,19,},
    terrain = 'mountain',
}
map[21100].locations[19] = 
{
    adjacent_locations={18,20,},
    terrain = 'mountain',
}
map[21100].locations[20] = 
{
    adjacent_locations={19,21,},
    terrain = 'mountain',
}
map[21100].locations[21] = 
{
    adjacent_locations={20,27,},
    terrain = 'plain',
}
map[21100].locations[24] = 
{
    adjacent_locations={18,25,},
    terrain = 'mountain',
}
map[21100].locations[25] = 
{
    adjacent_locations={24,26,},
    terrain = 'mountain',
}
map[21100].locations[26] = 
{
    adjacent_locations={25,},
    terrain = 'mountain',
}
map[21100].locations[27] = 
{
    adjacent_locations={21,28,},
    terrain = 'plain',
}
map[21100].locations[28] = 
{
    adjacent_locations={27,29,},
    terrain = 'plain',
}
map[21100].locations[29] = 
{
    adjacent_locations={28,34,30,},
    terrain = 'plain',
}
map[21100].locations[30] = 
{
    adjacent_locations={29,31,},
    terrain = 'forest',
}
map[21100].locations[31] = 
{
    adjacent_locations={30,32,},
    terrain = 'forest',
}
map[21100].locations[32] = 
{
    adjacent_locations={31,33,},
    terrain = 'forest',
}
map[21100].locations[33] = 
{
    adjacent_locations={32,11,},
    terrain = 'plain',
}
map[21100].locations[34] = 
{
    adjacent_locations={29,35,},
    terrain = 'plain',
}
map[21100].locations[35] = 
{
    adjacent_locations={34,36,},
    terrain = 'plain',
}
map[21100].locations[36] = 
{
    adjacent_locations={35,37,},
    terrain = 'plain',
}
map[21100].locations[37] = 
{
    adjacent_locations={36,38,48,},
    terrain = 'plain',
}
map[21100].locations[38] = 
{
    adjacent_locations={37,39,},
    terrain = 'forest',
}
map[21100].locations[39] = 
{
    adjacent_locations={40,38,},
    terrain = 'forest',
}
map[21100].locations[40] = 
{
    adjacent_locations={41,39,},
    terrain = 'forest',
}
map[21100].locations[41] = 
{
    adjacent_locations={42,40,},
    terrain = 'forest',
}
map[21100].locations[42] = 
{
    adjacent_locations={43,41,},
    terrain = 'forest',
}
map[21100].locations[43] = 
{
    adjacent_locations={44,42,99,},
    terrain = 'forest',
}
map[21100].locations[44] = 
{
    adjacent_locations={45,43,100,},
    terrain = 'forest',
}
map[21100].locations[45] = 
{
    adjacent_locations={46,44,},
    terrain = 'forest',
}
map[21100].locations[46] = 
{
    adjacent_locations={47,45,},
    terrain = 'forest',
}
map[21100].locations[47] = 
{
    adjacent_locations={11,46,},
    terrain = 'forest',
}
map[21100].locations[48] = 
{
    adjacent_locations={37,49,},
    terrain = 'plain',
}
map[21100].locations[49] = 
{
    adjacent_locations={48,50,},
    terrain = 'plain',
}
map[21100].locations[50] = 
{
    adjacent_locations={49,51,},
    terrain = 'plain',
}
map[21100].locations[51] = 
{
    adjacent_locations={50,84,52,},
    terrain = 'plain',
}
map[21100].locations[52] = 
{
    adjacent_locations={51,53,},
    terrain = 'plain',
}
map[21100].locations[53] = 
{
    adjacent_locations={52,54,},
    terrain = 'plain',
}
map[21100].locations[54] = 
{
    adjacent_locations={53,55,},
    terrain = 'plain',
}
map[21100].locations[55] = 
{
    adjacent_locations={54,85,56,},
    terrain = 'plain',
}
map[21100].locations[56] = 
{
    adjacent_locations={55,87,57,},
    terrain = 'plain',
}
map[21100].locations[57] = 
{
    adjacent_locations={56,58,61,},
    terrain = 'plain',
}
map[21100].locations[58] = 
{
    adjacent_locations={57,59,102,},
    terrain = 'plain',
}
map[21100].locations[59] = 
{
    adjacent_locations={58,60,},
    terrain = 'plain',
}
map[21100].locations[60] = 
{
    adjacent_locations={59,},
    terrain = 'citadel',
    convey2map = 21101,
    convey2location = 32,
}
map[21100].locations[61] = 
{
    adjacent_locations={57,62,},
    terrain = 'plain',
}
map[21100].locations[62] = 
{
    adjacent_locations={61,90,63,},
    terrain = 'forest',
}
map[21100].locations[63] = 
{
    adjacent_locations={62,64,},
    terrain = 'forest',
}
map[21100].locations[64] = 
{
    adjacent_locations={63,94,101,},
    terrain = 'forest',
}
map[21100].locations[65] = 
{
    adjacent_locations={66,101,},
    terrain = 'forest',
}
map[21100].locations[66] = 
{
    adjacent_locations={65,67,},
    terrain = 'plain',
}
map[21100].locations[67] = 
{
    adjacent_locations={66,68,},
    terrain = 'forest',
}
map[21100].locations[68] = 
{
    adjacent_locations={67,69,},
    terrain = 'forest',
}
map[21100].locations[69] = 
{
    adjacent_locations={68,74,76,70,},
    terrain = 'plain',
}
map[21100].locations[70] = 
{
    adjacent_locations={69,71,},
    terrain = 'plain',
}
map[21100].locations[71] = 
{
    adjacent_locations={70,72,},
    terrain = 'plain',
}
map[21100].locations[72] = 
{
    adjacent_locations={71,73,},
    terrain = 'plain',
}
map[21100].locations[73] = 
{
    adjacent_locations={72,6,},
    terrain = 'plain',
}
map[21100].locations[74] = 
{
    adjacent_locations={69,75,},
    terrain = 'mountain',
}
map[21100].locations[75] = 
{
    adjacent_locations={74,92,},
    terrain = 'mountain',
}
map[21100].locations[76] = 
{
    adjacent_locations={69,77,},
    terrain = 'mountain',
}
map[21100].locations[77] = 
{
    adjacent_locations={76,78,},
    terrain = 'mountain',
}
map[21100].locations[78] = 
{
    adjacent_locations={77,79,},
    terrain = 'mountain',
}
map[21100].locations[79] = 
{
    adjacent_locations={78,80,},
    terrain = 'mountain',
}
map[21100].locations[80] = 
{
    adjacent_locations={79,81,},
    terrain = 'mountain',
}
map[21100].locations[81] = 
{
    adjacent_locations={80,82,},
    terrain = 'mountain',
}
map[21100].locations[82] = 
{
    adjacent_locations={81,83,},
    terrain = 'mountain',
}
map[21100].locations[83] = 
{
    adjacent_locations={82,},
    terrain = 'lake',
}
map[21100].locations[84] = 
{
    adjacent_locations={51,},
    terrain = 'mountain',
    convey2map = 20700,
    convey2location = 63,
}
map[21100].locations[85] = 
{
    adjacent_locations={55,86,},
    terrain = 'mountain',
}
map[21100].locations[86] = 
{
    adjacent_locations={85,},
    terrain = 'mountain',
}
map[21100].locations[87] = 
{
    adjacent_locations={56,88,},
    terrain = 'mountain',
}
map[21100].locations[88] = 
{
    adjacent_locations={87,89,},
    terrain = 'mountain',
}
map[21100].locations[89] = 
{
    adjacent_locations={88,},
    terrain = 'mountain',
}
map[21100].locations[90] = 
{
    adjacent_locations={62,91,},
    terrain = 'plain',
}
map[21100].locations[91] = 
{
    adjacent_locations={90,},
    terrain = 'plain',
    convey2map = 20900,
    convey2location = 1,
}
map[21100].locations[92] = 
{
    adjacent_locations={75,},
    terrain = 'mountain',
    convey2map = 20800,
    convey2location = 127,
}
map[21100].locations[93] = 
{
    adjacent_locations={4,},
    terrain = 'citadel',
}
map[21100].locations[94] = 
{
    adjacent_locations={95,64,},
    terrain = 'plain',
}
map[21100].locations[95] = 
{
    adjacent_locations={96,94,},
    terrain = 'plain',
}
map[21100].locations[96] = 
{
    adjacent_locations={97,95,},
    terrain = 'plain',
}
map[21100].locations[97] = 
{
    adjacent_locations={98,96,},
    terrain = 'forest',
}
map[21100].locations[98] = 
{
    adjacent_locations={99,97,},
    terrain = 'forest',
}
map[21100].locations[99] = 
{
    adjacent_locations={43,98,},
    terrain = 'plain',
}
map[21100].locations[100] = 
{
    adjacent_locations={44,},
    terrain = 'forest',
}
map[21100].locations[101] = 
{
    adjacent_locations={64,65,},
    terrain = 'forest',
}
map[21100].locations[102] = 
{
    adjacent_locations={58,103,},
    terrain = 'plain',
}
map[21100].locations[103] = 
{
    adjacent_locations={102,},
    terrain = 'plain',
}
map[21101] = 
{
    superior_map = 21100,
    darkmine = {min = 7, max = 9},
    weather_probability = {cloudy=1},
    mobility_cost = 1,
    start_location = 0,
    locations = {},
    monsters = {31101,31102,31103,31104,31105},
    box_monsters = {20009},
    location_groups = {},
}
map[21101].locations[1] = 
{
    adjacent_locations={2,41,},
    terrain = 'citadel',
}
map[21101].locations[2] = 
{
    adjacent_locations={1,3,},
    terrain = 'citadel',
}
map[21101].locations[3] = 
{
    adjacent_locations={2,4,},
    terrain = 'citadel',
}
map[21101].locations[4] = 
{
    adjacent_locations={3,40,5,},
    terrain = 'citadel',
}
map[21101].locations[5] = 
{
    adjacent_locations={6,4,},
    terrain = 'citadel',
}
map[21101].locations[6] = 
{
    adjacent_locations={10,5,7,},
    terrain = 'citadel',
}
map[21101].locations[7] = 
{
    adjacent_locations={6,8,},
    terrain = 'citadel',
}
map[21101].locations[8] = 
{
    adjacent_locations={7,9,},
    terrain = 'citadel',
}
map[21101].locations[9] = 
{
    adjacent_locations={8,},
    terrain = 'citadel',
}
map[21101].locations[10] = 
{
    adjacent_locations={11,6,19,},
    terrain = 'citadel',
}
map[21101].locations[11] = 
{
    adjacent_locations={12,10,},
    terrain = 'citadel',
}
map[21101].locations[12] = 
{
    adjacent_locations={13,11,},
    terrain = 'citadel',
}
map[21101].locations[13] = 
{
    adjacent_locations={14,12,},
    terrain = 'citadel',
}
map[21101].locations[14] = 
{
    adjacent_locations={15,13,},
    terrain = 'citadel',
}
map[21101].locations[15] = 
{
    adjacent_locations={16,14,},
    terrain = 'citadel',
}
map[21101].locations[16] = 
{
    adjacent_locations={17,15,},
    terrain = 'citadel',
}
map[21101].locations[17] = 
{
    adjacent_locations={18,16,},
    terrain = 'citadel',
}
map[21101].locations[18] = 
{
    adjacent_locations={33,17,30,},
    terrain = 'citadel',
}
map[21101].locations[19] = 
{
    adjacent_locations={10,20,},
    terrain = 'citadel',
}
map[21101].locations[20] = 
{
    adjacent_locations={19,21,},
    terrain = 'citadel',
}
map[21101].locations[21] = 
{
    adjacent_locations={20,22,},
    terrain = 'citadel',
}
map[21101].locations[22] = 
{
    adjacent_locations={21,23,},
    terrain = 'citadel',
}
map[21101].locations[23] = 
{
    adjacent_locations={22,24,25,},
    terrain = 'citadel',
}
map[21101].locations[24] = 
{
    adjacent_locations={23,26,},
    terrain = 'citadel',
}
map[21101].locations[25] = 
{
    adjacent_locations={23,},
    terrain = 'citadel',
}
map[21101].locations[26] = 
{
    adjacent_locations={24,27,},
    terrain = 'citadel',
}
map[21101].locations[27] = 
{
    adjacent_locations={26,42,},
    terrain = 'citadel',
}
map[21101].locations[28] = 
{
    adjacent_locations={29,42,},
    terrain = 'citadel',
}
map[21101].locations[29] = 
{
    adjacent_locations={28,30,},
    terrain = 'citadel',
}
map[21101].locations[30] = 
{
    adjacent_locations={29,18,31,},
    terrain = 'citadel',
}
map[21101].locations[31] = 
{
    adjacent_locations={30,32,},
    terrain = 'citadel',
}
map[21101].locations[32] = 
{
    adjacent_locations={31,},
    terrain = 'citadel',
    convey2map = 21100,
    convey2location = 60,
}
map[21101].locations[33] = 
{
    adjacent_locations={34,18,},
    terrain = 'citadel',
}
map[21101].locations[34] = 
{
    adjacent_locations={35,33,},
    terrain = 'citadel',
}
map[21101].locations[35] = 
{
    adjacent_locations={36,34,},
    terrain = 'citadel',
}
map[21101].locations[36] = 
{
    adjacent_locations={37,35,},
    terrain = 'citadel',
}
map[21101].locations[37] = 
{
    adjacent_locations={38,36,},
    terrain = 'citadel',
}
map[21101].locations[38] = 
{
    adjacent_locations={39,37,},
    terrain = 'citadel',
}
map[21101].locations[39] = 
{
    adjacent_locations={40,38,},
    terrain = 'citadel',
}
map[21101].locations[40] = 
{
    adjacent_locations={4,39,},
    terrain = 'citadel',
}
map[21101].locations[41] = 
{
    adjacent_locations={1,},
    terrain = 'citadel',
}
map[21101].locations[42] = 
{
    adjacent_locations={28,27,},
    terrain = 'citadel',
}
map[21200] = 
{
    darkmine = {min = 9, max = 13},
    weather_probability = {cloudy=0.4,rain=0.2,fog=0.4},
    mobility_cost = 1,
    start_location = 68,
    locations = {},
    monsters = {31001,31002,31003,31004,31005},
    box_monsters = {20009},
    location_groups = {},
}
map[21200].locations[1] = 
{
    adjacent_locations={2,},
    terrain = 'plain',
    convey2map = 20500,
    convey2location = 101,
}
map[21200].locations[2] = 
{
    adjacent_locations={1,3,},
    terrain = 'plain',
}
map[21200].locations[3] = 
{
    adjacent_locations={2,4,46,},
    terrain = 'mountain',
}
map[21200].locations[4] = 
{
    adjacent_locations={3,5,6,},
    terrain = 'mountain',
}
map[21200].locations[5] = 
{
    adjacent_locations={4,},
    terrain = 'forest',
}
map[21200].locations[6] = 
{
    adjacent_locations={4,7,},
    terrain = 'mountain',
}
map[21200].locations[7] = 
{
    adjacent_locations={6,8,},
    terrain = 'mountain',
}
map[21200].locations[8] = 
{
    adjacent_locations={7,9,},
    terrain = 'forest',
}
map[21200].locations[9] = 
{
    adjacent_locations={8,10,19,},
    terrain = 'forest',
}
map[21200].locations[10] = 
{
    adjacent_locations={9,11,},
    terrain = 'plain',
}
map[21200].locations[11] = 
{
    adjacent_locations={10,12,},
    terrain = 'forest',
}
map[21200].locations[12] = 
{
    adjacent_locations={11,13,},
    terrain = 'forest',
}
map[21200].locations[13] = 
{
    adjacent_locations={12,14,},
    terrain = 'forest',
}
map[21200].locations[14] = 
{
    adjacent_locations={13,15,},
    terrain = 'forest',
}
map[21200].locations[15] = 
{
    adjacent_locations={14,16,},
    terrain = 'forest',
}
map[21200].locations[16] = 
{
    adjacent_locations={15,17,76,},
    terrain = 'plain',
}
map[21200].locations[17] = 
{
    adjacent_locations={16,18,},
    terrain = 'mountain',
}
map[21200].locations[18] = 
{
    adjacent_locations={17,},
    terrain = 'mountain',
    convey2map = 20600,
    convey2location = 155,
}
map[21200].locations[19] = 
{
    adjacent_locations={9,20,},
    terrain = 'forest',
}
map[21200].locations[20] = 
{
    adjacent_locations={19,21,},
    terrain = 'forest',
}
map[21200].locations[21] = 
{
    adjacent_locations={20,22,},
    terrain = 'forest',
}
map[21200].locations[22] = 
{
    adjacent_locations={21,23,},
    terrain = 'forest',
}
map[21200].locations[23] = 
{
    adjacent_locations={22,24,},
    terrain = 'forest',
}
map[21200].locations[24] = 
{
    adjacent_locations={23,25,},
    terrain = 'forest',
}
map[21200].locations[25] = 
{
    adjacent_locations={24,26,},
    terrain = 'forest',
}
map[21200].locations[26] = 
{
    adjacent_locations={25,27,},
    terrain = 'forest',
}
map[21200].locations[27] = 
{
    adjacent_locations={26,28,},
    terrain = 'forest',
}
map[21200].locations[28] = 
{
    adjacent_locations={27,29,},
    terrain = 'forest',
}
map[21200].locations[29] = 
{
    adjacent_locations={28,30,},
    terrain = 'forest',
}
map[21200].locations[30] = 
{
    adjacent_locations={29,31,68,},
    terrain = 'forest',
}
map[21200].locations[31] = 
{
    adjacent_locations={30,32,},
    terrain = 'lake',
}
map[21200].locations[32] = 
{
    adjacent_locations={31,33,},
    terrain = 'lake',
}
map[21200].locations[33] = 
{
    adjacent_locations={32,34,},
    terrain = 'plain',
}
map[21200].locations[34] = 
{
    adjacent_locations={33,35,},
    terrain = 'lake',
}
map[21200].locations[35] = 
{
    adjacent_locations={34,36,},
    terrain = 'lake',
}
map[21200].locations[36] = 
{
    adjacent_locations={35,37,},
    terrain = 'lake',
}
map[21200].locations[37] = 
{
    adjacent_locations={36,38,},
    terrain = 'lake',
}
map[21200].locations[38] = 
{
    adjacent_locations={37,39,},
    terrain = 'plain',
}
map[21200].locations[39] = 
{
    adjacent_locations={38,40,},
    terrain = 'lake',
}
map[21200].locations[40] = 
{
    adjacent_locations={39,41,},
    terrain = 'lake',
}
map[21200].locations[41] = 
{
    adjacent_locations={40,42,47,},
    terrain = 'lake',
}
map[21200].locations[42] = 
{
    adjacent_locations={41,43,},
    terrain = 'mountain',
}
map[21200].locations[43] = 
{
    adjacent_locations={42,44,},
    terrain = 'mountain',
}
map[21200].locations[44] = 
{
    adjacent_locations={43,45,},
    terrain = 'mountain',
}
map[21200].locations[45] = 
{
    adjacent_locations={44,46,},
    terrain = 'mountain',
}
map[21200].locations[46] = 
{
    adjacent_locations={45,3,},
    terrain = 'mountain',
}
map[21200].locations[47] = 
{
    adjacent_locations={41,48,},
    terrain = 'lake',
}
map[21200].locations[48] = 
{
    adjacent_locations={47,49,},
    terrain = 'lake',
}
map[21200].locations[49] = 
{
    adjacent_locations={48,50,},
    terrain = 'lake',
}
map[21200].locations[50] = 
{
    adjacent_locations={49,51,53,},
    terrain = 'lake',
}
map[21200].locations[51] = 
{
    adjacent_locations={50,52,},
    terrain = 'lake',
}
map[21200].locations[52] = 
{
    adjacent_locations={51,65,},
    terrain = 'lake',
}
map[21200].locations[53] = 
{
    adjacent_locations={50,54,},
    terrain = 'lake',
}
map[21200].locations[54] = 
{
    adjacent_locations={53,55,},
    terrain = 'lake',
}
map[21200].locations[55] = 
{
    adjacent_locations={54,56,},
    terrain = 'lake',
}
map[21200].locations[56] = 
{
    adjacent_locations={55,57,},
    terrain = 'lake',
}
map[21200].locations[57] = 
{
    adjacent_locations={56,58,},
    terrain = 'citadel',
}
map[21200].locations[58] = 
{
    adjacent_locations={57,59,},
    terrain = 'citadel',
}
map[21200].locations[59] = 
{
    adjacent_locations={58,60,},
    terrain = 'citadel',
}
map[21200].locations[60] = 
{
    adjacent_locations={59,61,99,},
    terrain = 'mountain',
}
map[21200].locations[61] = 
{
    adjacent_locations={60,62,},
    terrain = 'mountain',
}
map[21200].locations[62] = 
{
    adjacent_locations={61,63,},
    terrain = 'mountain',
}
map[21200].locations[63] = 
{
    adjacent_locations={62,64,},
    terrain = 'mountain',
}
map[21200].locations[64] = 
{
    adjacent_locations={63,65,},
    terrain = 'mountain',
}
map[21200].locations[65] = 
{
    adjacent_locations={64,66,52,},
    terrain = 'lake',
}
map[21200].locations[66] = 
{
    adjacent_locations={65,67,},
    terrain = 'lake',
}
map[21200].locations[67] = 
{
    adjacent_locations={66,68,69,},
    terrain = 'wasteland',
}
map[21200].locations[68] = 
{
    adjacent_locations={67,30,},
    terrain = 'forest',
}
map[21200].locations[69] = 
{
    adjacent_locations={67,70,},
    terrain = 'wasteland',
}
map[21200].locations[70] = 
{
    adjacent_locations={69,71,},
    terrain = 'wasteland',
}
map[21200].locations[71] = 
{
    adjacent_locations={70,72,},
    terrain = 'wasteland',
}
map[21200].locations[72] = 
{
    adjacent_locations={71,73,},
    terrain = 'wasteland',
}
map[21200].locations[73] = 
{
    adjacent_locations={72,74,81,},
    terrain = 'wasteland',
}
map[21200].locations[74] = 
{
    adjacent_locations={73,75,},
    terrain = 'wasteland',
}
map[21200].locations[75] = 
{
    adjacent_locations={74,},
    terrain = 'wasteland',
}
map[21200].locations[76] = 
{
    adjacent_locations={77,16,},
    terrain = 'lake',
}
map[21200].locations[77] = 
{
    adjacent_locations={78,76,},
    terrain = 'lake',
}
map[21200].locations[78] = 
{
    adjacent_locations={79,77,},
    terrain = 'lake',
}
map[21200].locations[79] = 
{
    adjacent_locations={80,78,},
    terrain = 'lake',
}
map[21200].locations[80] = 
{
    adjacent_locations={81,79,},
    terrain = 'lake',
}
map[21200].locations[81] = 
{
    adjacent_locations={73,80,82,},
    terrain = 'lake',
}
map[21200].locations[82] = 
{
    adjacent_locations={81,83,},
    terrain = 'lake',
}
map[21200].locations[83] = 
{
    adjacent_locations={82,84,},
    terrain = 'lake',
}
map[21200].locations[84] = 
{
    adjacent_locations={83,86,85,},
    terrain = 'lake',
}
map[21200].locations[85] = 
{
    adjacent_locations={84,87,},
    terrain = 'lake',
}
map[21200].locations[86] = 
{
    adjacent_locations={95,84,},
    terrain = 'lake',
}
map[21200].locations[87] = 
{
    adjacent_locations={88,85,},
    terrain = 'mountain',
}
map[21200].locations[88] = 
{
    adjacent_locations={89,87,},
    terrain = 'mountain',
}
map[21200].locations[89] = 
{
    adjacent_locations={90,88,},
    terrain = 'mountain',
}
map[21200].locations[90] = 
{
    adjacent_locations={91,89,},
    terrain = 'wasteland',
}
map[21200].locations[91] = 
{
    adjacent_locations={90,106,94,92,},
    terrain = 'wasteland',
}
map[21200].locations[92] = 
{
    adjacent_locations={91,93,},
    terrain = 'wasteland',
}
map[21200].locations[93] = 
{
    adjacent_locations={92,},
    terrain = 'wasteland',
}
map[21200].locations[94] = 
{
    adjacent_locations={91,},
    terrain = 'wasteland',
}
map[21200].locations[95] = 
{
    adjacent_locations={86,96,},
    terrain = 'lake',
}
map[21200].locations[96] = 
{
    adjacent_locations={95,97,},
    terrain = 'lake',
}
map[21200].locations[97] = 
{
    adjacent_locations={96,98,},
    terrain = 'lake',
}
map[21200].locations[98] = 
{
    adjacent_locations={97,103,},
    terrain = 'cave',
}
map[21200].locations[99] = 
{
    adjacent_locations={60,100,},
    terrain = 'lake',
}
map[21200].locations[100] = 
{
    adjacent_locations={99,107,101,},
    terrain = 'lake',
}
map[21200].locations[101] = 
{
    adjacent_locations={100,102,},
    terrain = 'lake',
}
map[21200].locations[102] = 
{
    adjacent_locations={101,103,},
    terrain = 'lake',
}
map[21200].locations[103] = 
{
    adjacent_locations={102,104,98,},
    terrain = 'mountain',
}
map[21200].locations[104] = 
{
    adjacent_locations={103,109,},
    terrain = 'mountain',
}
map[21200].locations[105] = 
{
    adjacent_locations={106,109,},
    terrain = 'mountain',
}
map[21200].locations[106] = 
{
    adjacent_locations={105,91,},
    terrain = 'mountain',
}
map[21200].locations[107] = 
{
    adjacent_locations={100,108,},
    terrain = 'lake',
}
map[21200].locations[108] = 
{
    adjacent_locations={107,},
    terrain = 'lake',
    convey2map = 20800,
    convey2location = 1,
}
map[21200].locations[109] = 
{
    adjacent_locations={104,105,},
    terrain = 'mountain',
}
map[21300] = 
{
    darkmine = {min = 9, max = 13},
    weather_probability = {sunny=0.4,rain=0.3,cloudy=0.3},
    mobility_cost = 1,
    start_location = 43,
    locations = {},
    monsters = {31301,31302,31303,31304,31305},
    box_monsters = {20010},
    location_groups = {},
}
map[21300].locations[1] = 
{
    adjacent_locations={2,},
    terrain = 'forest',
}
map[21300].locations[2] = 
{
    adjacent_locations={1,3,},
    terrain = 'forest',
}
map[21300].locations[3] = 
{
    adjacent_locations={2,4,},
    terrain = 'lake',
}
map[21300].locations[4] = 
{
    adjacent_locations={3,5,},
    terrain = 'lake',
}
map[21300].locations[5] = 
{
    adjacent_locations={4,6,},
    terrain = 'lake',
}
map[21300].locations[6] = 
{
    adjacent_locations={5,7,},
    terrain = 'lake',
}
map[21300].locations[7] = 
{
    adjacent_locations={6,8,},
    terrain = 'lake',
}
map[21300].locations[8] = 
{
    adjacent_locations={7,9,14,},
    terrain = 'lake',
}
map[21300].locations[9] = 
{
    adjacent_locations={8,10,},
    terrain = 'lake',
}
map[21300].locations[10] = 
{
    adjacent_locations={9,11,},
    terrain = 'lake',
}
map[21300].locations[11] = 
{
    adjacent_locations={10,12,},
    terrain = 'lake',
}
map[21300].locations[12] = 
{
    adjacent_locations={11,13,},
    terrain = 'plain',
}
map[21300].locations[13] = 
{
    adjacent_locations={12,},
    terrain = 'plain',
}
map[21300].locations[14] = 
{
    adjacent_locations={8,15,16,},
    terrain = 'mountain',
}
map[21300].locations[15] = 
{
    adjacent_locations={14,25,},
    terrain = 'mountain',
}
map[21300].locations[16] = 
{
    adjacent_locations={14,17,},
    terrain = 'wasteland',
}
map[21300].locations[17] = 
{
    adjacent_locations={16,18,},
    terrain = 'wasteland',
}
map[21300].locations[18] = 
{
    adjacent_locations={17,19,},
    terrain = 'wasteland',
}
map[21300].locations[19] = 
{
    adjacent_locations={18,20,},
    terrain = 'wasteland',
}
map[21300].locations[20] = 
{
    adjacent_locations={19,21,53,},
    terrain = 'wasteland',
}
map[21300].locations[21] = 
{
    adjacent_locations={20,22,},
    terrain = 'wasteland',
}
map[21300].locations[22] = 
{
    adjacent_locations={21,23,},
    terrain = 'wasteland',
}
map[21300].locations[23] = 
{
    adjacent_locations={22,24,},
    terrain = 'wasteland',
}
map[21300].locations[24] = 
{
    adjacent_locations={23,},
    terrain = 'wasteland',
}
map[21300].locations[25] = 
{
    adjacent_locations={15,26,},
    terrain = 'wasteland',
}
map[21300].locations[26] = 
{
    adjacent_locations={25,27,},
    terrain = 'wasteland',
}
map[21300].locations[27] = 
{
    adjacent_locations={26,28,33,},
    terrain = 'wasteland',
}
map[21300].locations[28] = 
{
    adjacent_locations={27,29,},
    terrain = 'forest',
}
map[21300].locations[29] = 
{
    adjacent_locations={28,30,},
    terrain = 'forest',
}
map[21300].locations[30] = 
{
    adjacent_locations={29,31,},
    terrain = 'forest',
}
map[21300].locations[31] = 
{
    adjacent_locations={30,32,},
    terrain = 'forest',
}
map[21300].locations[32] = 
{
    adjacent_locations={31,},
    terrain = 'forest',
}
map[21300].locations[33] = 
{
    adjacent_locations={27,34,},
    terrain = 'wasteland',
}
map[21300].locations[34] = 
{
    adjacent_locations={33,35,},
    terrain = 'wasteland',
}
map[21300].locations[35] = 
{
    adjacent_locations={34,64,36,},
    terrain = 'lake',
}
map[21300].locations[36] = 
{
    adjacent_locations={35,37,},
    terrain = 'wasteland',
}
map[21300].locations[37] = 
{
    adjacent_locations={38,36,},
    terrain = 'wasteland',
}
map[21300].locations[38] = 
{
    adjacent_locations={43,37,39,},
    terrain = 'wasteland',
}
map[21300].locations[39] = 
{
    adjacent_locations={38,40,},
    terrain = 'wasteland',
}
map[21300].locations[40] = 
{
    adjacent_locations={39,41,},
    terrain = 'wasteland',
}
map[21300].locations[41] = 
{
    adjacent_locations={40,42,},
    terrain = 'wasteland',
}
map[21300].locations[42] = 
{
    adjacent_locations={41,},
    terrain = 'wasteland',
}
map[21300].locations[43] = 
{
    adjacent_locations={44,38,},
    terrain = 'forest',
}
map[21300].locations[44] = 
{
    adjacent_locations={45,43,},
    terrain = 'forest',
}
map[21300].locations[45] = 
{
    adjacent_locations={46,44,},
    terrain = 'citadel',
}
map[21300].locations[46] = 
{
    adjacent_locations={47,45,},
    terrain = 'citadel',
}
map[21300].locations[47] = 
{
    adjacent_locations={57,46,48,},
    terrain = 'citadel',
}
map[21300].locations[48] = 
{
    adjacent_locations={47,49,},
    terrain = 'citadel',
}
map[21300].locations[49] = 
{
    adjacent_locations={48,50,},
    terrain = 'citadel',
}
map[21300].locations[50] = 
{
    adjacent_locations={49,51,},
    terrain = 'citadel',
}
map[21300].locations[51] = 
{
    adjacent_locations={50,52,},
    terrain = 'citadel',
}
map[21300].locations[52] = 
{
    adjacent_locations={51,},
    terrain = 'citadel',
}
map[21300].locations[53] = 
{
    adjacent_locations={20,54,},
    terrain = 'forest',
}
map[21300].locations[54] = 
{
    adjacent_locations={53,55,},
    terrain = 'forest',
}
map[21300].locations[55] = 
{
    adjacent_locations={54,56,},
    terrain = 'forest',
}
map[21300].locations[56] = 
{
    adjacent_locations={55,57,},
    terrain = 'forest',
}
map[21300].locations[57] = 
{
    adjacent_locations={56,58,47,},
    terrain = 'forest',
}
map[21300].locations[58] = 
{
    adjacent_locations={57,59,},
    terrain = 'forest',
}
map[21300].locations[59] = 
{
    adjacent_locations={58,60,},
    terrain = 'forest',
}
map[21300].locations[60] = 
{
    adjacent_locations={59,61,},
    terrain = 'forest',
}
map[21300].locations[61] = 
{
    adjacent_locations={90,62,60,},
    terrain = 'forest',
}
map[21300].locations[62] = 
{
    adjacent_locations={61,63,},
    terrain = 'mountain',
}
map[21300].locations[63] = 
{
    adjacent_locations={62,},
    terrain = 'mountain',
}
map[21300].locations[64] = 
{
    adjacent_locations={35,65,},
    terrain = 'lake',
}
map[21300].locations[65] = 
{
    adjacent_locations={64,66,},
    terrain = 'wasteland',
}
map[21300].locations[66] = 
{
    adjacent_locations={65,67,68,},
    terrain = 'forest',
}
map[21300].locations[67] = 
{
    adjacent_locations={66,},
    terrain = 'forest',
}
map[21300].locations[68] = 
{
    adjacent_locations={66,69,},
    terrain = 'forest',
}
map[21300].locations[69] = 
{
    adjacent_locations={68,70,},
    terrain = 'forest',
}
map[21300].locations[70] = 
{
    adjacent_locations={69,71,},
    terrain = 'forest',
}
map[21300].locations[71] = 
{
    adjacent_locations={70,72,73,},
    terrain = 'forest',
}
map[21300].locations[72] = 
{
    adjacent_locations={71,},
    terrain = 'forest',
}
map[21300].locations[73] = 
{
    adjacent_locations={71,74,},
    terrain = 'wasteland',
}
map[21300].locations[74] = 
{
    adjacent_locations={73,75,},
    terrain = 'mountain',
}
map[21300].locations[75] = 
{
    adjacent_locations={74,76,},
    terrain = 'lake',
}
map[21300].locations[76] = 
{
    adjacent_locations={75,77,},
    terrain = 'forest',
}
map[21300].locations[77] = 
{
    adjacent_locations={76,78,},
    terrain = 'forest',
}
map[21300].locations[78] = 
{
    adjacent_locations={77,79,86,},
    terrain = 'forest',
}
map[21300].locations[79] = 
{
    adjacent_locations={78,80,82,},
    terrain = 'forest',
}
map[21300].locations[80] = 
{
    adjacent_locations={79,81,},
    terrain = 'citadel',
}
map[21300].locations[81] = 
{
    adjacent_locations={80,},
    terrain = 'citadel',
}
map[21300].locations[82] = 
{
    adjacent_locations={79,83,},
    terrain = 'wasteland',
}
map[21300].locations[83] = 
{
    adjacent_locations={82,84,},
    terrain = 'forest',
}
map[21300].locations[84] = 
{
    adjacent_locations={83,85,},
    terrain = 'mountain',
}
map[21300].locations[85] = 
{
    adjacent_locations={84,},
    terrain = 'mountain',
}
map[21300].locations[86] = 
{
    adjacent_locations={78,87,},
    terrain = 'forest',
}
map[21300].locations[87] = 
{
    adjacent_locations={86,88,},
    terrain = 'forest',
}
map[21300].locations[88] = 
{
    adjacent_locations={87,89,},
    terrain = 'forest',
}
map[21300].locations[89] = 
{
    adjacent_locations={88,90,},
    terrain = 'forest',
}
map[21300].locations[90] = 
{
    adjacent_locations={89,61,},
    terrain = 'forest',
}
map[21400] = 
{
    darkmine = {min = 10, max = 14},
    weather_probability = {cloudy=0.2,snow=0.8},
    mobility_cost = 1,
    start_location = 93,
    locations = {},
    monsters = {31401,31402,31403,31404,31405},
    box_monsters = {20009},
    location_groups = {},
}
map[21400].locations[1] = 
{
    adjacent_locations={2,},
    terrain = 'citadel',
}
map[21400].locations[2] = 
{
    adjacent_locations={1,3,},
    terrain = 'plain',
}
map[21400].locations[3] = 
{
    adjacent_locations={2,4,},
    terrain = 'plain',
}
map[21400].locations[4] = 
{
    adjacent_locations={3,5,6,},
    terrain = 'plain',
}
map[21400].locations[5] = 
{
    adjacent_locations={4,},
    terrain = 'plain',
    convey2map = 20200,
    convey2location = 25,
}
map[21400].locations[6] = 
{
    adjacent_locations={4,7,32,},
    terrain = 'plain',
}
map[21400].locations[7] = 
{
    adjacent_locations={6,8,},
    terrain = 'mountain',
}
map[21400].locations[8] = 
{
    adjacent_locations={7,9,21,},
    terrain = 'mountain',
}
map[21400].locations[9] = 
{
    adjacent_locations={8,10,},
    terrain = 'mountain',
}
map[21400].locations[10] = 
{
    adjacent_locations={9,11,},
    terrain = 'coastal',
}
map[21400].locations[11] = 
{
    adjacent_locations={10,12,17,},
    terrain = 'forest',
}
map[21400].locations[12] = 
{
    adjacent_locations={11,13,15,},
    terrain = 'forest',
}
map[21400].locations[13] = 
{
    adjacent_locations={12,14,},
    terrain = 'forest',
}
map[21400].locations[14] = 
{
    adjacent_locations={13,},
    terrain = 'forest',
}
map[21400].locations[15] = 
{
    adjacent_locations={12,16,},
    terrain = 'forest',
}
map[21400].locations[16] = 
{
    adjacent_locations={15,},
    terrain = 'forest',
}
map[21400].locations[17] = 
{
    adjacent_locations={11,18,},
    terrain = 'coastal',
}
map[21400].locations[18] = 
{
    adjacent_locations={17,19,},
    terrain = 'coastal',
}
map[21400].locations[19] = 
{
    adjacent_locations={18,20,},
    terrain = 'coastal',
}
map[21400].locations[20] = 
{
    adjacent_locations={19,},
    terrain = 'plain',
}
map[21400].locations[21] = 
{
    adjacent_locations={8,22,},
    terrain = 'mountain',
}
map[21400].locations[22] = 
{
    adjacent_locations={21,23,},
    terrain = 'mountain',
}
map[21400].locations[23] = 
{
    adjacent_locations={22,24,},
    terrain = 'coastal',
}
map[21400].locations[24] = 
{
    adjacent_locations={23,25,},
    terrain = 'forest',
}
map[21400].locations[25] = 
{
    adjacent_locations={24,26,},
    terrain = 'forest',
}
map[21400].locations[26] = 
{
    adjacent_locations={25,27,},
    terrain = 'forest',
}
map[21400].locations[27] = 
{
    adjacent_locations={26,28,62,},
    terrain = 'forest',
}
map[21400].locations[28] = 
{
    adjacent_locations={27,29,},
    terrain = 'mountain',
}
map[21400].locations[29] = 
{
    adjacent_locations={63,28,30,},
    terrain = 'mountain',
}
map[21400].locations[30] = 
{
    adjacent_locations={29,31,},
    terrain = 'forest',
}
map[21400].locations[31] = 
{
    adjacent_locations={30,},
    terrain = 'citadel',
}
map[21400].locations[32] = 
{
    adjacent_locations={33,6,},
    terrain = 'plain',
}
map[21400].locations[33] = 
{
    adjacent_locations={34,32,41,},
    terrain = 'plain',
}
map[21400].locations[34] = 
{
    adjacent_locations={33,35,},
    terrain = 'lake',
}
map[21400].locations[35] = 
{
    adjacent_locations={34,36,},
    terrain = 'lake',
}
map[21400].locations[36] = 
{
    adjacent_locations={35,37,},
    terrain = 'lake',
}
map[21400].locations[37] = 
{
    adjacent_locations={36,38,},
    terrain = 'lake',
}
map[21400].locations[38] = 
{
    adjacent_locations={37,39,},
    terrain = 'lake',
}
map[21400].locations[39] = 
{
    adjacent_locations={38,40,},
    terrain = 'lake',
}
map[21400].locations[40] = 
{
    adjacent_locations={39,},
    terrain = 'citadel',
}
map[21400].locations[41] = 
{
    adjacent_locations={33,42,},
    terrain = 'plain',
}
map[21400].locations[42] = 
{
    adjacent_locations={41,43,},
    terrain = 'plain',
}
map[21400].locations[43] = 
{
    adjacent_locations={42,44,},
    terrain = 'plain',
}
map[21400].locations[44] = 
{
    adjacent_locations={43,51,45,},
    terrain = 'plain',
}
map[21400].locations[45] = 
{
    adjacent_locations={44,46,},
    terrain = 'plain',
}
map[21400].locations[46] = 
{
    adjacent_locations={45,47,},
    terrain = 'plain',
}
map[21400].locations[47] = 
{
    adjacent_locations={46,48,},
    terrain = 'plain',
}
map[21400].locations[48] = 
{
    adjacent_locations={47,49,},
    terrain = 'plain',
}
map[21400].locations[49] = 
{
    adjacent_locations={48,50,},
    terrain = 'plain',
}
map[21400].locations[50] = 
{
    adjacent_locations={49,},
    terrain = 'plain',
}
map[21400].locations[51] = 
{
    adjacent_locations={57,44,52,},
    terrain = 'plain',
}
map[21400].locations[52] = 
{
    adjacent_locations={51,53,},
    terrain = 'plain',
}
map[21400].locations[53] = 
{
    adjacent_locations={52,},
    terrain = 'plain',
    convey2map = 21000,
    convey2location = 69,
}
map[21400].locations[57] = 
{
    adjacent_locations={58,51,},
    terrain = 'mountain',
}
map[21400].locations[58] = 
{
    adjacent_locations={59,97,57,},
    terrain = 'mountain',
}
map[21400].locations[59] = 
{
    adjacent_locations={60,58,},
    terrain = 'forest',
}
map[21400].locations[60] = 
{
    adjacent_locations={61,59,},
    terrain = 'forest',
}
map[21400].locations[61] = 
{
    adjacent_locations={62,60,},
    terrain = 'forest',
}
map[21400].locations[62] = 
{
    adjacent_locations={61,27,},
    terrain = 'forest',
}
map[21400].locations[63] = 
{
    adjacent_locations={64,29,},
    terrain = 'forest',
}
map[21400].locations[64] = 
{
    adjacent_locations={65,63,},
    terrain = 'mountain',
}
map[21400].locations[65] = 
{
    adjacent_locations={66,85,64,},
    terrain = 'mountain',
}
map[21400].locations[66] = 
{
    adjacent_locations={67,65,},
    terrain = 'coastal',
}
map[21400].locations[67] = 
{
    adjacent_locations={68,66,},
    terrain = 'coastal',
}
map[21400].locations[68] = 
{
    adjacent_locations={69,67,},
    terrain = 'coastal',
}
map[21400].locations[69] = 
{
    adjacent_locations={70,68,},
    terrain = 'coastal',
}
map[21400].locations[70] = 
{
    adjacent_locations={71,69,},
    terrain = 'coastal',
}
map[21400].locations[71] = 
{
    adjacent_locations={74,72,70,},
    terrain = 'coastal',
}
map[21400].locations[72] = 
{
    adjacent_locations={71,73,},
    terrain = 'coastal',
}
map[21400].locations[73] = 
{
    adjacent_locations={72,},
    terrain = 'plain',
}
map[21400].locations[74] = 
{
    adjacent_locations={75,71,},
    terrain = 'coastal',
}
map[21400].locations[75] = 
{
    adjacent_locations={76,74,},
    terrain = 'coastal',
}
map[21400].locations[76] = 
{
    adjacent_locations={77,75,},
    terrain = 'plain',
}
map[21400].locations[77] = 
{
    adjacent_locations={78,76,},
    terrain = 'plain',
}
map[21400].locations[78] = 
{
    adjacent_locations={79,77,},
    terrain = 'plain',
}
map[21400].locations[79] = 
{
    adjacent_locations={80,78,},
    terrain = 'plain',
}
map[21400].locations[80] = 
{
    adjacent_locations={81,79,},
    terrain = 'plain',
}
map[21400].locations[81] = 
{
    adjacent_locations={82,80,},
    terrain = 'plain',
}
map[21400].locations[82] = 
{
    adjacent_locations={106,83,81,},
    terrain = 'wasteland',
}
map[21400].locations[83] = 
{
    adjacent_locations={82,84,},
    terrain = 'wasteland',
}
map[21400].locations[84] = 
{
    adjacent_locations={83,},
    terrain = 'wasteland',
    convey2map = 20400,
    convey2location = 42,
}
map[21400].locations[85] = 
{
    adjacent_locations={65,86,},
    terrain = 'mountain',
}
map[21400].locations[86] = 
{
    adjacent_locations={85,87,},
    terrain = 'mountain',
}
map[21400].locations[87] = 
{
    adjacent_locations={86,91,88,116,},
    terrain = 'mountain',
}
map[21400].locations[88] = 
{
    adjacent_locations={87,89,},
    terrain = 'mountain',
}
map[21400].locations[89] = 
{
    adjacent_locations={88,90,},
    terrain = 'mountain',
}
map[21400].locations[90] = 
{
    adjacent_locations={89,},
    terrain = 'mountain',
}
map[21400].locations[91] = 
{
    adjacent_locations={92,87,},
    terrain = 'mountain',
}
map[21400].locations[92] = 
{
    adjacent_locations={93,91,},
    terrain = 'mountain',
}
map[21400].locations[93] = 
{
    adjacent_locations={98,92,94,105,},
    terrain = 'wasteland',
}
map[21400].locations[94] = 
{
    adjacent_locations={95,93,},
    terrain = 'wasteland',
}
map[21400].locations[95] = 
{
    adjacent_locations={94,96,},
    terrain = 'wasteland',
}
map[21400].locations[96] = 
{
    adjacent_locations={97,95,},
    terrain = 'wasteland',
}
map[21400].locations[97] = 
{
    adjacent_locations={58,96,},
    terrain = 'wasteland',
}
map[21400].locations[98] = 
{
    adjacent_locations={99,93,},
    terrain = 'wasteland',
}
map[21400].locations[99] = 
{
    adjacent_locations={100,98,},
    terrain = 'wasteland',
}
map[21400].locations[100] = 
{
    adjacent_locations={101,99,},
    terrain = 'mountain',
}
map[21400].locations[101] = 
{
    adjacent_locations={102,100,},
    terrain = 'mountain',
}
map[21400].locations[102] = 
{
    adjacent_locations={103,101,},
    terrain = 'mountain',
}
map[21400].locations[103] = 
{
    adjacent_locations={104,102,},
    terrain = 'mountain',
}
map[21400].locations[104] = 
{
    adjacent_locations={103,},
    terrain = 'plain',
}
map[21400].locations[105] = 
{
    adjacent_locations={93,107,106,},
    terrain = 'wasteland',
}
map[21400].locations[106] = 
{
    adjacent_locations={105,82,},
    terrain = 'wasteland',
}
map[21400].locations[107] = 
{
    adjacent_locations={105,108,},
    terrain = 'plain',
}
map[21400].locations[108] = 
{
    adjacent_locations={107,109,},
    terrain = 'plain',
}
map[21400].locations[109] = 
{
    adjacent_locations={108,110,},
    terrain = 'plain',
}
map[21400].locations[110] = 
{
    adjacent_locations={109,111,},
    terrain = 'plain',
}
map[21400].locations[111] = 
{
    adjacent_locations={110,112,},
    terrain = 'plain',
}
map[21400].locations[112] = 
{
    adjacent_locations={111,113,},
    terrain = 'mountain',
}
map[21400].locations[113] = 
{
    adjacent_locations={112,},
    terrain = 'plain',
}
map[21400].locations[116] = 
{
    adjacent_locations={87,117,},
    terrain = 'plain',
}
map[21400].locations[117] = 
{
    adjacent_locations={116,118,},
    terrain = 'lake',
}
map[21400].locations[118] = 
{
    adjacent_locations={117,119,},
    terrain = 'lake',
}
map[21400].locations[119] = 
{
    adjacent_locations={118,120,},
    terrain = 'lake',
}
map[21400].locations[120] = 
{
    adjacent_locations={119,121,},
    terrain = 'lake',
}
map[21400].locations[121] = 
{
    adjacent_locations={120,122,},
    terrain = 'lake',
}
map[21400].locations[122] = 
{
    adjacent_locations={121,123,},
    terrain = 'lake',
}
map[21400].locations[123] = 
{
    adjacent_locations={122,},
    terrain = 'lake',
}



return map

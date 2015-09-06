local rune_material = {}

rune_material[1] = 
{
    cost = 4000,
    probability = 0.5,
    runes = {{group = 1, probability = 0.4}, {group = 9, probability = 0.6}},
}

rune_material[2] = 
{
    cost = 7000,
    probability = 0.45,
    runes = {{group = 1, probability = 0.28}, {group = 2, probability = 0.08}, {group = 5, probability = 0.14}, {group = 6, probability = 0.04}, {group = 9, probability = 0.46}},
}

rune_material[3] = 
{
    cost = 12000,
    probability = 0.4,
    runes = {{group = 1, probability = 0.28}, {group = 2, probability = 0.16}, {group = 3, probability = 0.04}, {group = 5, probability = 0.14}, {group = 6, probability = 0.08}, {group = 7, probability = 0.02}, {group = 9, probability = 0.28}},
}

rune_material[4] = 
{
    cost = 24000,
    probability = 0.4,
    runes = {{group = 1, probability = 0.3}, {group = 2, probability = 0.28}, {group = 3, probability = 0.08}, {group = 5, probability = 0.16}, {group = 6, probability = 0.14}, {group = 7, probability = 0.04}},
}

rune_material[5] = 
{
    cost = 50000,
    probability = 0,
    runes = {{group = 1, probability = 0.2}, {group = 2, probability = 0.2}, {group = 3, probability = 0.16}, {group = 4, probability = 0.08}, {group = 5, probability = 0.12}, {group = 6, probability = 0.12}, {group = 7, probability = 0.08}, {group = 8, probability = 0.04}},
}

return rune_material
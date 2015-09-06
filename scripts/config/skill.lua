local skills = {}

skills[31001] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {1,1,1},
    attack_count = {1.2},
}

skills[31002] = 
{
    distance = 2,
    calc = "healing",
    goal = 2,
    lock = 4,
    target = 1,
    element_relative = {2,2,1},
    attack_count = {1},
}

skills[31003] = 
{
    goal = 1,
    lock = 3,
    target = 1,
    element_relative = {5,5,5},
    buff = {{id = 3001, probability = 1, turn = -1}},
    condition = 4,
}

skills[31004] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,3},
    attack_count = {1},
}

skills[31005] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,2},
    attack_count = {1.8},
    buff = {{id = 4000, probability = 0.5, turn = 3}},
}

skills[31006] = 
{
    element_relative = {3,3,3},
    feature = {dizziness_resistance = 5, sleep_resistance = 5, paralysis_resistance = 5, charm_resistance = 5, silence_resistance = 5, detained_resistance = 5, ridicule_resistance = 5},
    condition = 1,
}

skills[31007] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 2,
    target = 1,
    element_relative = {3,3,2},
    attack_count = {1},
    buff = {{id = 4000, probability = 0.1, turn = 3}},
}

skills[31008] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 2,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {0.6,1.4},
}

skills[31009] = 
{
    element_relative = {0,0,0},
    feature = {dodge = 5},
    condition = 1,
}

skills[31010] = 
{
    distance = 2,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,4},
    attack_count = {1},
}

skills[31011] = 
{
    distance = 2,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {4,4,4},
    attack_count = {0.5,0.5,0.5,0.5},
}

skills[31012] = 
{
    goal = 1,
    lock = 3,
    target = 1,
    element_relative = {1,1,2},
    buff = {{id = 5000, probability = 1, turn = -1}},
    condition = 4,
}

skills[31013] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {2,2,2},
    attack_count = {1},
}

skills[31014] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 8,
    target = 8,
    element_relative = {0,0,0},
    attack_count = {0.6},
}

skills[31015] = 
{
    goal = 1,
    lock = 3,
    target = 1,
    element_relative = {1,1,2},
    buff = {{id = 3000, probability = 1, turn = -1}},
    condition = 5,
}

skills[31016] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 2,
    target = 4,
    element_relative = {5,5,5},
    attack_count = {0.6},
}

skills[31017] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 4,
    element_relative = {5,5,4},
    attack_count = {0.8},
    buff = {{id = 4007, probability = 0.5, turn = 2}},
}

skills[31018] = 
{
    element_relative = {2,2,3},
    condition = -1,
}

skills[31019] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {1,1,0},
    attack_count = {1},
}

skills[31020] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {5,5,3},
    attack_count = {2},
}

skills[31021] = 
{
    goal = 1,
    lock = 3,
    target = 1,
    element_relative = {0,0,1},
    buff = {{id = 5001, probability = 1, turn = -1}},
    condition = 4,
}

skills[31022] = 
{
    distance = 2,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {4,4,5},
    attack_count = {1},
}

skills[31023] = 
{
    distance = 2,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {4,4,4},
    attack_count = {2},
}

skills[31024] = 
{
    goal = 1,
    lock = 3,
    target = 1,
    element_relative = {2,2,1},
    buff = {{id = 4009, probability = 1, turn = -1}},
    condition = 4,
}

skills[31025] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {2,2,3},
    attack_count = {1},
}

skills[31026] = 
{
    distance = 1,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 6,
    element_relative = {1,1,0},
    attack_count = {0.8},
}

skills[31027] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {2,2,1},
    attack_count = {1},
}

skills[31028] = 
{
    distance = 1,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,3},
    attack_count = {2},
}

skills[31029] = 
{
    distance = 2,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {1},
}

skills[31030] = 
{
    distance = 2,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 6,
    element_relative = {2,2,1},
    attack_count = {0.8},
}

skills[31031] = 
{
    goal = 2,
    lock = 8,
    target = 9,
    target_arg = 2,
    element_relative = {0,0,1},
    buff = {{id = 3002, probability = 1, turn = -1}},
    condition = 4,
}

skills[31032] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {2,2,2},
    attack_count = {1},
    buff = {{id = 4008, probability = 1, turn = 1}},
}

skills[31033] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {5,5,3},
    attack_count = {0.6,0.6,0.6},
    buff = {{id = 4000, probability = 0.2, turn = 1}},
}

skills[31034] = 
{
    goal = 1,
    lock = 3,
    target = 1,
    element_relative = {3,3,2},
    buff = {{id = 3003, probability = 1, turn = -1}},
    condition = 4,
}

skills[31035] = 
{
    distance = 2,
    calc = "absorb_magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,4},
    attack_count = {1},
}

skills[31036] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {0.6,0.6,0.6},
    buff = {{id = 1017, probability = 0.1, turn = 2}},
}

skills[31037] = 
{
    goal = 1,
    lock = 3,
    target = 1,
    element_relative = {3,3,3},
    buff = {{id = 5002, probability = 1, turn = -1}},
    condition = 6,
}

skills[31038] = 
{
    distance = 2,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 4,
    element_relative = {1,1,0},
    attack_count = {0.6},
}

skills[31039] = 
{
    distance = 2,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 4,
    element_relative = {1,1,1},
    attack_count = {0.4,0.4},
}

skills[31040] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,2},
    attack_count = {1},
}

skills[31041] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {2,2,2},
    attack_count = {0.8,1},
}

skills[31042] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {1,1,2},
    attack_count = {1},
}

skills[31043] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,1},
    attack_count = {0.4,0.4,1.2},
}

skills[31044] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,1},
    attack_count = {1},
}

skills[31045] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 2,
    target = 1,
    element_relative = {3,3,2},
    attack_count = {0.6,1.4},
}

skills[31046] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,2},
    attack_count = {1},
}

skills[31047] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {2,2,1},
    attack_count = {2.2},
}

skills[31048] = 
{
    distance = 2,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {2,2,3},
    attack_count = {1},
}

skills[31049] = 
{
    distance = 2,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,2},
    attack_count = {2},
}

skills[31050] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {0.3,0.3,0.4},
}

skills[31051] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,4},
    attack_count = {0.15,0.25,0.15,0.25,0.15,0.25,0.15,0.25,0.15,0.2},
}

skills[31052] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 8,
    target = 8,
    element_relative = {1,1,0},
    attack_count = {0.4},
}

skills[31053] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 8,
    target = 8,
    element_relative = {1,1,0},
    attack_count = {0.6},
}

skills[31054] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,1},
    attack_count = {1},
    buff = {{id = 4010, probability = 1, turn = 3}},
}

skills[31055] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 8,
    target = 8,
    element_relative = {5,5,5},
    attack_count = {0.8},
}

skills[31056] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {1},
}

skills[31057] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 8,
    target = 8,
    element_relative = {5,5,5},
    attack_count = {0.6},
}

skills[31058] = 
{
    distance = 1,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {1,1,1},
    attack_count = {1},
}

skills[31059] = 
{
    distance = 1,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,3},
    attack_count = {2},
}

skills[31060] = 
{
    distance = 1,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {1},
}

skills[31061] = 
{
    distance = 1,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {4,4,4},
    attack_count = {2},
}

skills[31062] = 
{
    distance = 2,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {1,1,0},
    attack_count = {1},
}

skills[31063] = 
{
    distance = 2,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {1,1,1},
    attack_count = {2},
}

skills[31064] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {2,2,2},
    attack_count = {1},
}

skills[31065] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,2},
    attack_count = {0.6,0.6,0.6},
}

skills[31066] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,1},
    attack_count = {1},
}

skills[31067] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {5,5,5},
    attack_count = {2},
}

skills[31068] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {5,5,4},
    attack_count = {1},
}

skills[31069] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,1},
    attack_count = {2},
}

skills[31070] = 
{
    distance = 2,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {1,1,0},
    attack_count = {1},
}

skills[31071] = 
{
    distance = 2,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {0.5,0.5,1.5},
}

skills[31072] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,3},
    attack_count = {1},
}

skills[31073] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {5,5,3},
    attack_count = {2},
}

skills[31074] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {1,1,1},
    attack_count = {1},
}

skills[31075] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {4,4,4},
    attack_count = {2},
}

skills[31076] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {5,5,3},
    attack_count = {1},
}

skills[31077] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {5,5,5},
    attack_count = {1,1},
}

skills[31078] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {4,4,4},
    attack_count = {1},
}

skills[31079] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,1},
    attack_count = {1,1},
}

skills[31080] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {4,4,3},
    attack_count = {1},
}

skills[31081] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {1,1,2},
    attack_count = {1,1},
}

skills[31082] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {1,1,0},
    attack_count = {1},
}

skills[31083] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {2},
}

skills[31084] = 
{
    distance = 1,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {1,1,0},
    attack_count = {1},
}

skills[31085] = 
{
    distance = 1,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {5,5,4},
    attack_count = {2},
}

skills[31086] = 
{
    distance = 1,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {2,2,3},
    attack_count = {1},
}

skills[31087] = 
{
    distance = 1,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {2,2,1},
    attack_count = {2},
}

skills[31088] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {4,4,5},
    attack_count = {1},
}

skills[31089] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,1},
    attack_count = {2},
}

skills[31090] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {5,5,5},
    attack_count = {1},
}

skills[31091] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {2},
}

skills[31092] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,3},
    attack_count = {1},
}

skills[31093] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,4},
    attack_count = {2},
}

skills[31094] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {5,5,3},
    attack_count = {1},
}

skills[31095] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 8,
    target = 8,
    element_relative = {0,0,1},
    attack_count = {0.6},
}

skills[31096] = 
{
    distance = 1,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {5,5,4},
    attack_count = {0.3,0.3,0.4},
}

skills[31097] = 
{
    distance = 1,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {2,2,2},
    attack_count = {0.4,0.4,0.4,0.4,0.4},
}

skills[31098] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {2,2,2},
    attack_count = {1},
}

skills[31099] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {4,4,3},
    attack_count = {2},
}

skills[31100] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,4},
    attack_count = {1},
}

skills[31101] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 8,
    target = 8,
    element_relative = {1,1,1},
    attack_count = {0.6},
}

skills[31102] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {1,1,2},
    attack_count = {1},
}

skills[31103] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,3},
    attack_count = {2},
}

skills[31104] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {2,2,1},
    attack_count = {1.2},
}

skills[31105] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {4,4,5},
    attack_count = {1.4},
    buff = {{id = 2000, probability = 1, turn = 2}},
}

skills[31106] = 
{
    goal = 1,
    lock = 3,
    target = 1,
    element_relative = {5,5,5},
    buff = {{id = 1018, probability = 1, turn = -1}},
    condition = 7,
}

skills[31107] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {5,5,4},
    attack_count = {1},
}

skills[31108] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {1,1,2},
    attack_count = {1,1},
}

skills[31109] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,1},
    attack_count = {1},
}

skills[31110] = 
{
    distance = 2,
    calc = "physical_attack",
    goal = 3,
    lock = 8,
    target = 8,
    element_relative = {4,4,4},
    attack_count = {0.6},
}

skills[31111] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {1},
}

skills[31112] = 
{
    distance = 1,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {5,5,4},
    attack_count = {0.4,0.4,0.4,0.4,0.4},
}

skills[31113] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,2},
    attack_count = {1},
}

skills[31114] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 8,
    target = 8,
    element_relative = {3,3,2},
    attack_count = {0.6},
}

skills[31115] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,2},
    attack_count = {1.2},
}

skills[31116] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,1},
    attack_count = {1.4},
}

skills[31117] = 
{
    distance = 2,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {2,2,3},
    attack_count = {1},
}

skills[31118] = 
{
    distance = 2,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {1,1,0},
    attack_count = {1,1},
}

skills[31119] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,1},
    attack_count = {1},
}

skills[31120] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,2},
    attack_count = {2},
}

skills[31121] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {1,1,2},
    attack_count = {1},
}

skills[31122] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {2,2,2},
    attack_count = {2},
}

skills[31123] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {4,4,4},
    attack_count = {1},
}

skills[31124] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 8,
    target = 8,
    element_relative = {0,0,2},
    attack_count = {2},
}

skills[31125] = 
{
    distance = 2,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,2},
    attack_count = {1},
}

skills[31126] = 
{
    distance = 2,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,4},
    attack_count = {2},
}

skills[31127] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,1},
    attack_count = {1},
}

skills[31128] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,1},
    attack_count = {2},
}

skills[31129] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,3},
    attack_count = {1},
}

skills[31130] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {4,4,3},
    attack_count = {2},
}

skills[31131] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {1,1,2},
    attack_count = {1},
}

skills[31132] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {4,4,4},
    attack_count = {2},
}

skills[31133] = 
{
    distance = 2,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {2,2,1},
    attack_count = {1},
}

skills[31134] = 
{
    distance = 2,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 6,
    element_relative = {2,2,2},
    attack_count = {0.4,0.4},
}

skills[31135] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,2},
    attack_count = {1},
}

skills[31136] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,3},
    attack_count = {2},
}

skills[31137] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {1,1,0},
    attack_count = {1},
}

skills[31138] = 
{
    distance = 2,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 4,
    element_relative = {2,2,1},
    attack_count = {0.8},
}

skills[31139] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {4,4,4},
    attack_count = {1},
}

skills[31140] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,2},
    attack_count = {2},
}

skills[31141] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,3},
    attack_count = {1},
}

skills[31142] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {2,2,1},
    attack_count = {0.8,1.2},
}

skills[31143] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {4,4,3},
    attack_count = {1},
}

skills[31144] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {4,4,3},
    attack_count = {2},
}

skills[31145] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,2},
    attack_count = {1},
}

skills[31146] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 8,
    target = 8,
    element_relative = {1,1,1},
    attack_count = {0.1,0.1,0.1,0.1,0.1,0.1},
}

skills[31147] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {5,5,5},
    attack_count = {1},
}

skills[31148] = 
{
    distance = 2,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {5,5,5},
    attack_count = {2},
}

skills[31149] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {4,4,3},
    attack_count = {1},
}

skills[31150] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {1,1,1},
    attack_count = {0.6,1.4},
}

skills[31151] = 
{
    distance = 2,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {2,2,2},
    attack_count = {1},
}

skills[31152] = 
{
    distance = 2,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,3},
    attack_count = {2},
}

skills[31153] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,1},
    attack_count = {1},
}

skills[31154] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {1,1,2},
    attack_count = {2},
}

skills[31155] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {1},
}

skills[31156] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,3},
    attack_count = {2},
}

skills[31157] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {1,1,2},
    attack_count = {1},
}

skills[31158] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,1},
    attack_count = {2},
}

skills[31159] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {1,1,0},
    attack_count = {1},
}

skills[31160] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,4},
    attack_count = {2},
}

skills[31161] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {5,5,5},
    attack_count = {1},
}

skills[31162] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {0.8,1.2},
}

skills[31163] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {4,4,4},
    attack_count = {1},
}

skills[31164] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {1,1,1},
    attack_count = {2},
}

skills[31165] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {2,2,3},
    attack_count = {1},
}

skills[31166] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,3},
    attack_count = {2},
}

skills[31167] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {2,2,3},
    attack_count = {1},
}

skills[31168] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,2},
    attack_count = {0.6,1.4},
}

skills[31169] = 
{
    distance = 2,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {2,2,1},
    attack_count = {1},
}

skills[31170] = 
{
    distance = 2,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {1,1,2},
    attack_count = {2},
}

skills[31171] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,1},
    attack_count = {1},
}

skills[31172] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {2,2,3},
    attack_count = {2},
}

skills[31173] = 
{
    distance = 2,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {1,1,1},
    attack_count = {1},
}

skills[31174] = 
{
    distance = 2,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {2,2,1},
    attack_count = {2},
}

skills[31175] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {1,1,0},
    attack_count = {1},
}

skills[31176] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {5,5,5},
    attack_count = {2},
}

skills[31177] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {4,4,5},
    attack_count = {1},
}

skills[31178] = 
{
    distance = 2,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 6,
    element_relative = {0,0,2},
    attack_count = {0.8},
}

skills[31179] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,2},
    attack_count = {1},
}

skills[31180] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {1,1,0},
    attack_count = {2},
}

skills[31181] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {5,5,5},
    attack_count = {1},
}

skills[31182] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {5,5,3},
    attack_count = {2},
}

skills[31183] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {4,4,4},
    attack_count = {1},
}

skills[31184] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {5,5,3},
    attack_count = {2},
}

skills[31185] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {5,5,3},
    attack_count = {1},
}

skills[31186] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,2},
    attack_count = {2},
}

skills[31187] = 
{
    distance = 1,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {5,5,5},
    attack_count = {1},
}

skills[31188] = 
{
    distance = 1,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,4},
    attack_count = {2},
}

skills[31189] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,2},
    attack_count = {1},
}

skills[31190] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 8,
    target = 8,
    element_relative = {1,1,1},
    attack_count = {0.6},
}

skills[31191] = 
{
    distance = 2,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {1,1,1},
    attack_count = {1},
}

skills[31192] = 
{
    distance = 2,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {2,2,1},
    attack_count = {2},
}

skills[31193] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {5,5,5},
    attack_count = {1},
}

skills[31194] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {2,2,3},
    attack_count = {2},
}

skills[31195] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {2,2,3},
    attack_count = {1},
}

skills[31196] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,2},
    attack_count = {2},
}

skills[31197] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,1},
    attack_count = {1},
}

skills[31198] = 
{
    distance = 1,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {1,1,1},
    attack_count = {0.5,0.5,0.5},
}

skills[31199] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,1},
    attack_count = {1},
}

skills[31200] = 
{
    distance = 1,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,1},
    attack_count = {0.5,0.5,0.5},
}

skills[31201] = 
{
    distance = 1,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {5,5,4},
    attack_count = {0.4,0.2,0.4},
}

skills[31202] = 
{
    distance = 1,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,3},
    attack_count = {0.4,0.4,0.4,0.4,0.4},
}

skills[31203] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,2},
    attack_count = {1},
}

skills[31204] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {1,1,1},
    attack_count = {0.3,0.3,0.3,0.3,0.3},
}

skills[31205] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {2,2,2},
    attack_count = {1},
}

skills[31206] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,2},
    attack_count = {2},
}

skills[31207] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {2,2,1},
    attack_count = {1.2},
}

skills[31208] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {4,4,5},
    attack_count = {1.4},
}

skills[31209] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {1,1,0},
    attack_count = {1},
}

skills[31210] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,4},
    attack_count = {2},
}

skills[31211] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,1},
    attack_count = {0.3,0.7},
}

skills[31212] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,2},
    attack_count = {0.5,0.5,0.5,0.5},
}

skills[31213] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {4,4,4},
    attack_count = {1},
}

skills[31214] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {5,5,4},
    attack_count = {0.5,1.5},
}

skills[31215] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {4,4,4},
    attack_count = {0.3,0.7},
}

skills[31216] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {1,1,0},
    attack_count = {0.4,0.4,0.4,0.4,0.4},
}

skills[31217] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {2,2,1},
    attack_count = {1},
}

skills[31218] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {4,4,5},
    attack_count = {2},
}

skills[31219] = 
{
    distance = 2,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {1,1,1},
    attack_count = {1},
}

skills[31220] = 
{
    distance = 2,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {5,5,3},
    attack_count = {2},
}

skills[31221] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,3},
    attack_count = {1},
}

skills[31222] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 8,
    target = 8,
    element_relative = {3,3,4},
    attack_count = {0.6},
}

skills[31223] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {4,4,4},
    attack_count = {1},
}

skills[31224] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {5,5,4},
    attack_count = {2},
}

skills[31225] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,4},
    attack_count = {1},
}

skills[31226] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,1},
    attack_count = {2},
}

skills[31227] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {2,2,1},
    attack_count = {1,1,1},
}

skills[31228] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {1,1,2},
    attack_count = {2,2,2},
}

skills[31229] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {2,2,2},
    attack_count = {1},
}

skills[31230] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {5,5,5},
    attack_count = {2},
}

skills[31231] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {4,4,5},
    attack_count = {0.1,0.1,0.8},
}

skills[31232] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 8,
    target = 8,
    element_relative = {3,3,3},
    attack_count = {0.1,0.1,0.1,0.1,0.1,0.1,0.1},
}

skills[31233] = 
{
    distance = 1,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,2},
    attack_count = {1},
}

skills[31234] = 
{
    distance = 1,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,3},
    attack_count = {0.6,0.6,0.6},
}

skills[31235] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,3},
    attack_count = {1},
}

skills[31236] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {1,1,1},
    attack_count = {2},
}

skills[31237] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,3},
    attack_count = {1},
}

skills[31238] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {4,4,5},
    attack_count = {2},
}

skills[31239] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {2,2,3},
    attack_count = {1},
}

skills[31240] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 8,
    target = 8,
    element_relative = {2,2,3},
    attack_count = {0.1,0.1,0.1,0.1,0.1,0.1},
}

skills[31241] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {4,4,5},
    attack_count = {1},
}

skills[31242] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {4,4,5},
    attack_count = {2},
}

skills[31243] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {2,2,1},
    attack_count = {1},
}

skills[31244] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {3,3,2},
    attack_count = {2},
}

skills[31245] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {1},
}

skills[31246] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {2},
}

skills[31247] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {1},
}

skills[31248] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {2},
}

skills[31249] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {1},
}

skills[31250] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {2},
}

skills[31251] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {1},
}

skills[31252] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {2},
}

skills[31253] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {1},
}

skills[31254] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {0.5,1.5},
}

skills[31255] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {1},
}

skills[31256] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {0.2,0.6,1.2},
}

skills[31257] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {1},
}

skills[31258] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {0.5,1.5},
}

skills[31259] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {1},
}

skills[31260] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {0.5,1.5},
}

skills[31261] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {1},
}

skills[31262] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {2},
}

skills[31263] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {1},
}

skills[31264] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {2},
}

skills[31265] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {1},
}

skills[31266] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {0.5,0.5,0.5,0.5},
}

skills[31267] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {1},
}

skills[31268] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {2},
}

skills[31269] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {0.5,0.5},
}

skills[31270] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {0.5,0.5,0.5,0.5},
}

skills[31271] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {1},
}

skills[31272] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {1,1},
}

skills[31273] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {1},
}

skills[31274] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {1,1},
}

skills[31275] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {1},
}

skills[31276] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {2},
}

skills[31277] = 
{
    distance = 2,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {1},
}

skills[31278] = 
{
    distance = 2,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {2},
}

skills[31279] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {1},
}

skills[31280] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 8,
    target = 8,
    element_relative = {0,0,0},
    attack_count = {2},
}

skills[31281] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {1},
}

skills[31282] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {2},
}

skills[31283] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {1},
}

skills[31284] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {1,1},
}

skills[31285] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {0.5,0.5},
}

skills[31286] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {0.4,0.4,0.4,0.4,0.4},
}

skills[31287] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {1},
}

skills[31288] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {1},
}

skills[31289] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {1},
}

skills[31290] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {1},
}

skills[31291] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {1},
}

skills[31292] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 8,
    target = 8,
    element_relative = {0,0,0},
    attack_count = {0.5,0.5,0.5,0.5},
}

skills[31293] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {1},
}

skills[31294] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {0.4,0.4,0.4,0.4,0.4},
}

skills[31295] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {1},
}

skills[31296] = 
{
    distance = 2,
    calc = "magical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {2},
}

skills[31297] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {1},
}

skills[31298] = 
{
    distance = 1,
    calc = "physical_attack",
    goal = 3,
    lock = 1,
    target = 1,
    element_relative = {0,0,0},
    attack_count = {2},
}

return skills
-- this module is pointless but we ball

local data = {}

---@type AdventureType[]
data.adventures = {
    {
        title = "Fairy Forest Scouting",
        level = 1,
        duration = 60*10,
        command = "/fumo adventure difficulty:Fairy Forest Scouting (lvl:1, time:10m)"
    },
    {
        title = "Youkai Trail Patrol",
        level = 5,
        duration = 60*30,
        command = "/fumo adventure difficulty:Youkai Trail Patrol (lvl:5, time:30m)"
    },
    {
        title = "Scarlet Mansion Mystery",
        level = 15,
        duration = 60*60,
        command = "/fumo adventure difficulty:Scarlet Mansion Mystery (lvl:15, time:1h)"
    },
    {
        title = "Hakugyoukurou Spirit March",
        level = 30,
        duration = 60*60*2,
        command = "/fumo adventure difficulty:Hakugyokurou Spirit March  (lvl:30, time:2h)"
    },
    {
        title = "Lunarian Vault Raid",
        level = 40,
        duration = 60*60*3,
        command = "/fumo adventure difficulty:Lunarian Vault Raid (lvl:40, time:3h)"
    },
    {
        title = "Limited Time - Your walls",
        level = 45,
        duration = 60*60*3,
        command = "/fumo adventure difficulty:Limited Time - Your walls  (lvl:45, time:3h)"
    },
}

data.pet_command = "/fumo pet"
data.pet_time = 60*30
data.timer_add_time = 5

-- TODO: move to save module
data.save_phrases = {
    "rin satsuki is watching you.",
    "rin satsuki sees you.",
    "she is here.",
    "8D E1 8C 8E 20 97 D9",
}

return data
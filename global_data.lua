local global_data = {}

global_data.adventures = {
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

global_data.petting = {
    command = "/fumo pet",
    duration = 30*60,
}

global_data.additional_timer_seconds = 5

return global_data
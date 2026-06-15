while true do
    t = io.read()

    local hours = math.floor(t / 3600)
    local minutes = math.floor((t % 3600) / 60)
    local seconds = math.floor(t % 60)

    print(hours, minutes, seconds)
end
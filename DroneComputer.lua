local bluenet = require("bluenet")
bluenet.open("ws://6.tcp.eu.ngrok.io:17144", "drone")

local drone = peripheral.find("drone_interface")

local function scan(radius)
    local pos = drone.getDronePositionVec()

    local blocks = {}

    for x=-radius, radius do
        for y=-radius, radius do
            for z=-radius, radius do
                drone.clearArea()
                drone.addArea(pos.x+x, pos.y+y, pos.z+z)
                drone.setAction("condition_block")
                while not drone.isActionDone() do sleep() end
                local state = drone.evaluateCondition()
                if state then
                    local blockName = "minecraft_stone"
                    table.insert(blocks, {name = blockName, x = pos.x+x, y = pos.y+y, z = pos.z+z})
                end
            end
        end
    end
    return blocks
end


while true do
    local id, message = bluenet.receive("world")
    print(id)
    if message.type == "scan" then
    print("scanin")
        local blocks = scan(message.radius)

        local message = {blocks = blocks}
        bluenet.send("world", message, "world")
        sleep(0.1)
    end
end

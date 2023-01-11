local bluenet = require("bluenet")
bluenet.open("ws://6.tcp.eu.ngrok.io:17144", "drone")

local drone = peripheral.find("drone_interface")

local function scan(radius)
    local pos = drone.getDronePositionVec()

    local blocks = {}

    for x=-radius, radius do
        for y=-radius, radius do
            for z=-radius, radius do
                while not drone.isActionDone() do sleep() end
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


local function scanArea(x1, y1, z1, x2, y2, z2)
    local blocks = {}

    for x=x1, x2 do
        for y=y1, y2 do
            for z=z1, z2 do
                while not drone.isActionDone() do sleep() end
                drone.clearArea()
                drone.addArea(x, y, z)
                drone.setAction("condition_block")
                while not drone.isActionDone() do sleep() end
                local state = drone.evaluateCondition()
                if state then
                    local blockName = "minecraft_stone"
                    table.insert(blocks, {name = blockName, x = x, y = y, z = z})
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
        local blocks = scan(message.radius)

        local message = {blocks = blocks}
        bluenet.send("world", message, "world")
        sleep(0.1)
    end
    if message.type == "goto" then
        while not drone.isActionDone() do sleep() end
        drone.clearArea()
        drone.addArea(message.pos.x, message.pos.y, message.pos.z)
        drone.setAction("goto")
    end
    if message.type == "scanArea" then
        local pos = message.pos
        local blocks = scanArea(pos.x1, pos.y1, pos.z1, pos.x2, pos.y2, pos.z2)

        local message = {blocks = blocks}
        bluenet.send("world", message, "world")
        sleep(0.1)
    end
    if message.type == "getPos" then
        local pos = drone.getDronePositionVec()

        message = {x = pos.x, y = pos.y, z = pos.z}
        bluenet.send(id, message, "pos")
    end
end

local bluenet = require("bluenet")
bluenet.open("ws://2.tcp.eu.ngrok.io:11698", "drone")

local drone = peripheral.find("drone_interface")

local function scan(radius)
    local pos = drone.getDronePositionVec()

    local blocks = {}
    
    for x=-radius, radius do
        for y=-radius, radius do
            for z=-radius, radius do
                repeat until drone.isActionDone()
                drone.clearArea()
                drone.addArea(pos.x+x, pos.y+y, pos.z+z)
                drone.setAction("condition_block")
                repeat until drone.isActionDone()
                local state = drone.evaluateCondition()
                local blockName = "minecraft_stone"
                table.insert(blocks, {name = blockName, x = pos.x+x, y = pos.y+y, z = pos.z+z})
            end
        end
    end
    return blocks
end


while true do
    local id, message = bluenet.receive()
    print(id)
    if message.type == "scan" then
        local blocks = scan(message.radius)
        
        local message = {blocks}
        bluenet.send("world", message, "world")
    end
end
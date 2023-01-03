local bluenet = require("bluenet")

bluenet.open("ws://6.tcp.eu.ngrok.io:17144", "world")

while true do
    repeat
        print("awaiting scan request")
        local id, message = bluenet.receive("scan")
        print("received")
        local scanRadius = message
        sleep(0.1)
        bluenet.send("drone", {type = "scan", radius = scanRadius}, "world")
        print("send drone request")
        local id, message = bluenet.receive("world")
        print("received ")
        for i, b in pairs(message.blocks) do
            --print(i.."  "..b)
            local block = string.gsub(b.name, "_", ":")

            local success, out = commands.exec("setblock "..tostring(math.floor(b.x)).." "..tostring(math.floor(b.y)+100).." "..tostring(math.floor(b.z)).." "..block)
            --print(success)
            --print(table.concat(out, ", "))
        end
    until true
end

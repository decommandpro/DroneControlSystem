local bluenet = require("bluenet")

bluenet.open("ws://2.tcp.eu.ngrok.io:11698", "world")

while true do
    repeat
        local id, message = bluenet.receive("scan")
        local scanRadius = message
        bluenet.send("drone", {type = "scan", radius = scanRadius})
        local id, message = bluenet.receive("world")
        for i, b in pairs(message.blocks) do
            --print(i.."  "..b)
            local block = string.gsub(i, "_", ":")
            local success, out = commands.exec("setblock "..b.x.." "..b.y.." "..b.z.." "..block)
            print(success)
        end
    until true
end
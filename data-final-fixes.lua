-- Effect transmission multiplier correction table based on quality level
local qmod = {{
    level = 1,
    modifier = 1.5,
    suffix = ""
}, {
    level = 2,
    modifier = 1.7,
    suffix = "-quality-2"
}, {
    level = 3,
    modifier = 1.9,
    suffix = "-quality-3"
}, {
    level = 4,
    modifier = 2.1,
    suffix = "-quality-4"
}, {
    level = 5,
    modifier = 2.5,
    suffix = "-quality-5"
}}

-- Fix beacons with latest data
local MAX_BEACONS = 24

for i = 1, MAX_BEACONS, 1 do
    for j, prop in pairs(qmod) do
        local name = "janky-beacon-" .. i .. prop.suffix
        local proto = data.raw.beacon[name]
        if proto then
            proto.distribution_effectivity = proto.distribution_effectivity * prop.modifier
            proto.minable.result = "beacon" .. prop.suffix
        end

    end
end


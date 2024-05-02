-- Create placeholder beacon entities and items with specific distribution effectivity
local MAX_BEACONS = 24

for i = 1, MAX_BEACONS, 1 do
    local beacon = table.deepcopy(data.raw["beacon"]["beacon"])
    beacon.name = "janky-beacon-" .. i
    beacon.distribution_effectivity = (1 / math.sqrt(i))
    beacon.minable.result = "beacon"

    local beacon_item = table.deepcopy(data.raw["item"]["beacon"])
    beacon_item.name = "janky-beacon-" .. i
    beacon_item.flags = {"hidden", "hide-from-bonus-gui", "hide-from-fuel-tooltip"}
    beacon_item.place_result = "janky-beacon-" .. i -- In case somehow someone is able to get the item placed

    data:extend({beacon, beacon_item})
end

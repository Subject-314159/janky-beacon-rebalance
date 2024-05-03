-- Add quality sprites
if not mods["janky-quality"] then
    for q = 2, 5, 1 do
        data:extend({{
            type = "sprite",
            name = "jq_quality_icon_" .. q,
            filename = "__janky-beacon-rebalance__/graphics/sprites/quality-" .. q .. ".png",
            size = 32,
            scale = 0.5
        }})
    end
end

-- Create placeholder beacon entities and items with specific distribution effectivity
local MAX_BEACONS = 24

for i = 1, MAX_BEACONS, 1 do
    -- Add janky beacon quality level 1
    local beacon = table.deepcopy(data.raw["beacon"]["beacon"])
    beacon.name = "janky-beacon-" .. i
    beacon.distribution_effectivity = (1 / math.sqrt(i))
    beacon.minable.result = "beacon"

    local beacon_item = table.deepcopy(data.raw["item"]["beacon"])
    beacon_item.name = "janky-beacon-" .. i
    beacon_item.flags = {"hidden", "hide-from-bonus-gui", "hide-from-fuel-tooltip"}
    beacon_item.place_result = "janky-beacon-" .. i

    data:extend({beacon, beacon_item})

    -- Add janky beacon quality level 2 to 5 (janky-quality mod compatible)
    if not mods["janky-quality"] then
        for q = 2, 5, 1 do
            -- Create the quality icon overlay
            local iqon = {
                icon = "__janky-beacon-rebalance__/graphics/sprites/quality-" .. q .. ".png",
                icon_size = 32,
                scale = 0.5,
                shift = {-8, 8}
            }

            -- Entity
            beacon = table.deepcopy(data.raw["beacon"]["beacon"])
            beacon.name = "janky-beacon-" .. i .. "-quality-" .. q
            beacon.localised_name = {"jq.with-quality", {"?", {"entity-name.janky-beacon-" .. i}}, {"jq.quality-" .. q}}
            beacon.distribution_effectivity = (1 / math.sqrt(i))
            beacon.minable.result = "beacon-quality-" .. q
            if beacon.icons then
                table.insert(beacon.icons, iqon)
            else
                local icon = {
                    icon = beacon.icon
                }
                beacon.icons = {icon, iqon}
            end

            -- Item
            local beacon_item = table.deepcopy(data.raw["item"]["beacon"])
            beacon_item.name = "janky-beacon-" .. i .. "-quality-" .. q
            beacon_item.flags = {"hidden", "hide-from-bonus-gui", "hide-from-fuel-tooltip"}
            beacon_item.place_result = "janky-beacon-" .. i .. "-quality-" .. q
            if beacon_item.icons then
                table.insert(beacon_item.icons, iqon)
            else
                local icon = {
                    icon = beacon_item.icon
                }
                beacon_item.icons = {icon, iqon}
            end
            data:extend({beacon, beacon_item})
        end
    end
end

-- Basic non-janky quality beacons (janky-quality mod compatible)
if not mods["janky-quality"] then
    for q = 2, 5, 1 do
        -- Create the quality icon overlay
        local iqon = {
            icon = "__janky-beacon-rebalance__/graphics/sprites/quality-" .. q .. ".png",
            icon_size = 32,
            scale = 0.5,
            shift = {-8, 8}
        }

        -- Entity
        local beacon = table.deepcopy(data.raw["beacon"]["beacon"])
        beacon.name = "beacon-quality-" .. q
        beacon.localised_name = {"jq.with-quality", "beacon", {"jq.quality-" .. q}}
        beacon.minable.result = "beacon-quality-" .. q
        if beacon.icons then
            table.insert(beacon.icons, iqon)
        else
            local icon = {
                icon = beacon.icon
            }
            beacon.icons = {icon, iqon}
        end

        -- Item
        local beacon_item = table.deepcopy(data.raw["item"]["beacon"])
        beacon_item.name = "beacon-quality-" .. q
        beacon_item.place_result = "beacon-quality-" .. q
        if beacon_item.icons then
            table.insert(beacon_item.icons, iqon)
        else
            local icon = {
                icon = beacon_item.icon
            }
            log("Beacon item icon: " .. beacon_item.icon .. " -- quality icon: " .. iqon.icon)
            beacon_item.icons = {icon, iqon}
        end

        -- Recipe
        local rec = table.deepcopy(data.raw.recipe["beacon"])
        rec.name = "beacon-quality-" .. q
        rec.results = {{"beacon-quality-" .. q, 1}}
        if rec.icons then
            table.insert(rec.icons, iqon)
        elseif rec.icon then
            local icon = {
                icon = rec.icon
            }
            rec.icons = {icon, iqon}
        else
            -- TODO: Add icons for normal/expensive mode
        end

        -- Add to data.raw
        data:extend({beacon, beacon_item, rec})
    end
end

------------------------------------------------------------------------------------------------------
-- Yes I know this file is messy
-- Yes I know I violate DRY coding principles
-- Yes I know this is not modular
-- No I do not plan to clean it up soon
-- I just wanted to get the new beacon effectivity mechanics working
------------------------------------------------------------------------------------------------------

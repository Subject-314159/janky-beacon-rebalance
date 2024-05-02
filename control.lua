------------------------------------------------------------------------------------------------------
-- defines
------------------------------------------------------------------------------------------------------
local MAX_BEACONS = 24

local allowed_effect_types = {"assembling-machine", "mining-drill", "lab", "rocket-silo"}

local allowed_beacons = {"beacon"}
for i = 1, MAX_BEACONS, 1 do
    table.insert(allowed_beacons, "janky-beacon-" .. i)
end

------------------------------------------------------------------------------------------------------
-- Generic functions
------------------------------------------------------------------------------------------------------

function get_entity_from_event(e)
    if e["created_entity"] and not e["entity"] then
        e["entity"] = e["created_entity"]
    end
    if not e["entity"] then
        return
    end
    return e["entity"]
end

function array_has_value(array, value)
    for _, arr in pairs(array) do
        if arr == value then
            return true
        end
    end
    return false
end

function replace_beacon(beacon, level, is_ghost)
    -- Effectively we replace the "beacon" entity with the "janky-beacon-#" entity which has the effectivity hard-coded
    -- First remember some essential stuff from the current beacon
    local mods = beacon.get_module_inventory()
    local force = beacon.force
    local surface = beacon.surface
    local pos = beacon.position

    -- Place the new janky beacon
    -- Generate the name
    local e_name = "beacon"
    if level > 0 and level <= MAX_BEACONS then
        e_name = "janky-beacon-" .. level
    end

    -- Generate the entity
    local new_beacon
    if is_ghost then
        new_beacon = surface.create_entity {
            name = "entity-ghost",
            inner_name = "beacon",
            position = pos,
            force = force,
            item = stck
        }

        -- KNOWN ISSUE: Unable to place modules in ghosts
        game.print("Warning: Ghosts janky beacons lose module requests")

    else
        -- Create the entity
        new_beacon = surface.create_entity {
            name = e_name,
            position = pos,
            force = force
        }
        -- Add modules
        if mods then
            for mod, cnt in pairs(mods.get_contents()) do
                new_beacon.get_module_inventory().insert({
                    name = mod,
                    count = cnt
                })
            end
        end
    end

    -- Destroy the old beacon entity
    beacon.destroy()
end

------------------------------------------------------------------------------------------------------
-- Game triggers
------------------------------------------------------------------------------------------------------

-- On built triggers
script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity,
                 defines.events.script_raised_built, defines.events.script_raised_revive}, function(e)
    on_built_entity(get_entity_from_event(e))
end)

-- On destroyed triggers
script.on_event({defines.events.on_entity_died, defines.events.on_player_mined_entity,
                 defines.events.on_robot_mined_entity, defines.events.script_raised_destroy}, function(e)
    on_destroyed_entity(get_entity_from_event(e))
end)

-- Pipette trigger
script.on_event({defines.events.on_player_pipette}, function(e)
    -- Replace a janky beacon under the cursor with a vanilla beacon
    if array_has_value(allowed_beacons, e.item.name) then
        local player = game.players[e.player_index]
        player.cursor_stack.set_stack({
            name = "beacon"
        })
    end
end)

-- Tick trigger
script.on_event(defines.events.on_tick, function()
    -- Periodic clean-up janky beacon items in the player inventory
    local player = game.players[1]
    local inventory = player.get_inventory(defines.inventory.character_main)

    -- Iterate over all inventory slots
    for item, stack in pairs(inventory.get_contents()) do
        if array_has_value(allowed_beacons, item) and item ~= "beacon" then
            -- Replace the janky beacon item with a regular beacon item
            inventory.remove({
                name = item,
                count = stack
            })
            inventory.insert({
                name = "beacon",
                count = stack
            })
        end
    end
end)

------------------------------------------------------------------------------------------------------
-- Specific mod functionality
------------------------------------------------------------------------------------------------------

function on_built_entity(entity)
    if array_has_value(allowed_beacons, entity.name) then
        -- Update all entities around this beacon
        local targets = entity.get_beacon_effect_receivers()
        for _, target in pairs(targets) do
            update_beacons_around_target(target)
        end
    elseif array_has_value(allowed_effect_types, entity.type) then
        -- Update only this entity
        update_beacons_around_target(entity)
    elseif entity.name == "entity-ghost" and array_has_value(allowed_beacons, entity.ghost_prototype.name) and
        entity.ghost_prototype.name ~= "beacon" then
        -- Change ghost janky beacon to regular beacon
        replace_beacon(entity, 0, true)

    end
end

function on_destroyed_entity(entity)
    if array_has_value(allowed_beacons, entity.name) then
        -- Update all entities around this beacon
        local targets = entity.get_beacon_effect_receivers()
        for _, target in pairs(targets) do
            update_beacons_around_target(target, entity)
        end
    elseif array_has_value(allowed_effect_types, entity.type) then
        -- Update only this entity
        update_beacons_around_target(entity, entity)
    end
end

function update_beacons_around_target(target, entity_to_ignore)
    -- This is where the magic happens
    -- Loop through all beacons that affect this target
    -- A. For each beacon, get all their targets
    -- B. Get the maximum number of beacons that affect one target
    -- C. Use this number to determine the beacon's effectivity

    local beacons = target.get_beacons()
    if not beacons then
        return
    end

    local beacons_updated = 0
    -- Loop through all beacons that affect this target
    for bc, beacon in pairs(beacons) do
        if entity_to_ignore and beacon == entity_to_ignore then
            goto continue
        end

        -- A. For each beacon, get all their targets
        local targets = beacon.get_beacon_effect_receivers()
        if not targets then
            -- This case should not happen
            game.print(
                "404: Target not found. Please report to mod author including copy of save and steps to reproduce.")
            goto continue
        end

        -- B. Get the maximum number of beacons that affect one target
        local max = 0
        for idx, target in pairs(targets) do
            if entity_to_ignore and target == entity_to_ignore then
                goto next
            end

            local tgt_beacons = target.get_beacons()
            -- Compensate if the target is affected by the beacon that is being destroyed
            local compensate = 0
            for _, tgtb in pairs(tgt_beacons) do
                if tgtb == entity_to_ignore then
                    compensate = -1
                end
            end
            max = math.max(max, (#tgt_beacons + compensate))
            ::next::
        end

        -- C. Use this number to determine the beacon's effectivity
        replace_beacon(beacon, max)

        ::continue::
    end
end

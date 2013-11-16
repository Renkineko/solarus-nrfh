local map = ...
local game = map:get_game()

-- For each chest, an array with the name
-- of the map and the variant of the item,
-- 0 meaning the chest is disabled.
local equipment_available = {
    bomb_bag = {
        lost_palazzo = 2
    },
    boomerang = {
        lost_palazzo = 2
    },
    bottle_1 = {
        lost_palazzo = 3
    },
    bottle_2 = {
        lost_palazzo = 4
    },
    bottle_3 = {
        lost_palazzo = 4
    },
    bottle_4 = {
    },
    bow = {
        lost_palazzo = 1
    },
    cane_of_somaria = {
        lost_palazzo = 1
    },
    feather = {
        lost_palazzo = 1
    },
    flippers = {
    },
    glove = {
    },
    hookshot = {
        lost_palazzo = 1
    },
    lamp = {
        lost_palazzo = 1,
        hole_clearer = 1
    },
    life = {
        lost_palazzo = 20,
    },
    magic_bar = {
        lost_palazzo = 2,
        hole_clearer = 1
    },
    magic_cape = {
    },
    pegasus_shoes = {
        lost_palazzo = 1
    },
    quiver = {
        lost_palazzo = 2
    },
    rupee_bag = {
        monty_hall = 5
    },
    shield = {
        lost_palazzo = 2
    },
    sword = {
        lost_palazzo = 2
    },
    tunic = {
        lost_palazzo = 3
    }
}

function map:on_started()
    local trial_dest = game:get_value("trial_destination")
    map:set_entities_enabled("teleporter_trial", false)
    map:get_entity("teleporter_trial_"..trial_dest):set_enabled(true)
end

function chest_equipment:on_empty()
    local new_equipment = false
    local trial_dest = game:get_value("trial_destination")
    for item, value in pairs(equipment_available) do
        local variant = value[trial_dest]
        if variant ~= nil and variant > 0 then
            new_equipment = true
            if item == "magic_bar" then
                game:set_max_magic(42 * variant)
            elseif item == "life" then
                game:set_max_life(4 * variant)
                game:set_life(4*variant)
            else
                game:get_item(item):set_variant(variant)
                if item == "tunic" then
                    game:set_ability("tunic", variant)
                end
            end
        end
    end
    
    if new_equipment then
        sol.audio.play_sound("treasure")
        hero:start_victory()
        game:start_dialog("equipment_set")
    else
        sol.audio.play_sound("wrong")
        game:start_dialog("no_equipment_set")
    end
    
    game:get_item("bow"):set_amount(99)
    game:get_item("bombs_counter"):set_amount(99)
    game:set_money(math.floor(game:get_max_money()/2))
end
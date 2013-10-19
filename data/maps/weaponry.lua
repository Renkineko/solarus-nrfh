local map = ...
local game = map:get_game()

-- For each chest, an array with the name
-- of the map and the variant of the item,
-- 0 meaning the chest is disabled.
local equipment_available = {
    [bomb_bag_chest] = {
        lost_palazzo = 2
    },
    [boomerang_chest] = {
        lost_palazzo = 2
    },
    [bottle_1_chest] = {
        lost_palazzo = 3
    },
    [bottle_2_chest] = {
        lost_palazzo = 4
    },
    [bottle_3_chest] = {
        lost_palazzo = 4
    },
    [bottle_4_chest] = {
    },
    [bow_chest] = {
        lost_palazzo = 1
    },
    [cane_of_somaria_chest] = {
        lost_palazzo = 1
    },
    [feather_chest] = {
        lost_palazzo = 1
    },
    [flippers_chest] = {
    },
    [glove_chest] = {
    },
    [hookshot_chest] = {
        lost_palazzo = 1
    },
    [lamp_chest] = {
        lost_palazzo = 1,
        hole_clearer = 1
    },
    [magic_bar_chest] = {
        lost_palazzo = 2
    },
    [magic_cape_chest] = {
    },
    [pegasus_shoes_chest] = {
        lost_palazzo = 1
    },
    [quiver_chest] = {
        lost_palazzo = 2
    },
    [shield_chest] = {
        lost_palazzo = 2
    },
    [sword_chest] = {
        lost_palazzo = 2
    },
    [tunic_chest] = {
        lost_palazzo = 3
    }
}

function map:on_started()
    local trial_dest = game:get_value("trial_destination")
    map:set_entities_enabled("teleporter_trial", false)
    map:get_entity("teleporter_trial_"..trial_dest):set_enabled(true)
    for chest, value in pairs(equipment_available) do
        local variant = value[trial_dest]
        if variant == nil or variant == 0 then
            chest:set_enabled(false)
        else
            local name_item = chest:get_name():sub(1, -7)
            function chest:on_empty()
                hero:start_treasure(name_item, variant)
                hero:unfreeze()
            end
        end
    end
end
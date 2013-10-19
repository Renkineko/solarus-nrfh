local map = ...
local game = map:get_game()

-- For each chest, an array with the name
-- of the map and the variant of the item,
-- 0 meaning the chest is disabled.
local equipment_available = {
    [bomb_bag_chest] = {
        lost_palazzo = 2,
        hole_clearer = 0
    },
    [boomerang_chest] = {
        lost_palazzo = 2,
        hole_clearer = 0
    },
    [bottle_1_chest] = {
        lost_palazzo = 3,
        hole_clearer = 0
    },
    [bottle_2_chest] = {
        lost_palazzo = 4,
        hole_clearer = 0
    },
    [bottle_3_chest] = {
        lost_palazzo = 4,
        hole_clearer = 0
    },
    [bottle_4_chest] = {
        lost_palazzo = 0,
        hole_clearer = 0
    },
    [bow_chest] = {
        lost_palazzo = 1,
        hole_clearer = 0
    },
    [cane_of_somaria_chest] = {
        lost_palazzo = 1,
        hole_clearer = 0
    },
    [feather_chest] = {
        lost_palazzo = 1,
        hole_clearer = 0
    },
    [flippers_chest] = {
        lost_palazzo = 0,
        hole_clearer = 0
    },
    [glove_chest] = {
        lost_palazzo = 0,
        hole_clearer = 0
    },
    [hookshot_chest] = {
        lost_palazzo = 1,
        hole_clearer = 0
    },
    [lamp_chest] = {
        lost_palazzo = 1,
        hole_clearer = 1
    },
    [magic_bar_chest] = {
        lost_palazzo = 2,
        hole_clearer = 0
    },
    [magic_cape_chest] = {
        lost_palazzo = 0,
        hole_clearer = 0
    },
    [pegasus_shoes_chest] = {
        lost_palazzo = 1,
        hole_clearer = 0
    },
    [quiver_chest] = {
        lost_palazzo = 2,
        hole_clearer = 0
    },
    [shield_chest] = {
        lost_palazzo = 2,
        hole_clearer = 0
    },
    [sword_chest] = {
        lost_palazzo = 2,
        hole_clearer = 0
    },
    [tunic_chest] = {
        lost_palazzo = 3,
        hole_clearer = 0
    }
}

function map:on_started()
    local trial_dest = game:get_value("trial_destination")
    map:set_entities_enabled("teleporter_trial", false)
    map:get_entity("teleporter_trial_"..trial_dest):set_enabled(true)
    for key, value in pairs(equipment_available) do
        key:set_enabled(false)
        --if value[trial_dest] == nil or value[trial_dest] ~= 0 then
        --    key:set_enabled(false)
        --end
    end
end
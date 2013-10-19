local map = ...
local game = map:get_game()

function sensor_lost_palazzo:on_activated()
    game:set_value("trial_destination", "lost_palazzo")
end

function sensor_hole_clearer:on_activated()
    game:set_value("trial_destination", "hole_clearer")
end

function map:on_started()
    -- Always reset all items in the possession of the hero
    game:get_item("bomb_bag"):set_variant("0")
    game:get_item("boomerang"):set_variant("0")
    game:get_item("bow"):set_variant("0")
    game:get_item("feather"):set_variant("0")
    game:get_item("flippers"):set_variant("0")
    game:get_item("glove"):set_variant("0")
    game:get_item("hookshot"):set_variant("0")
    game:get_item("lamp"):set_variant("0")
    game:get_item("magic_cape"):set_variant("0")
    game:get_item("pegasus_shoes"):set_variant("0")
    game:get_item("quiver"):set_variant("0")
    game:get_item("shield"):set_variant("0")
    game:get_item("cane_of_somaria"):set_variant("0")
    game:get_item("sword"):set_variant("0")
    game:get_item("tunic"):set_variant("1")
    
    -- Except for the bottles, which are just emptied
    game:get_item("bottle_1"):set_variant("1")
    game:get_item("bottle_2"):set_variant("1")
    game:get_item("bottle_3"):set_variant("1")
    game:get_item("bottle_4"):set_variant("1")
    
    -- We put the counters to 0
    game:get_item("bow"):set_amount(0)
    game:get_item("bombs_counter"):set_amount(0)
    game:set_max_magic(0)
    game:set_max_life(20)
    game:set_life(20)
end
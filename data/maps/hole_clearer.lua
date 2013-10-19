local map = ...
local game = map:get_game()
local hole_eater_moving = false
local movement
local next_angle = 90
local angles = {
    right = 0,
    up = 90,
    left = 180,
    down = 270
}

function separator_entrance_trial:on_activated()
    if not game:get_value("hole_clearer") then
        -- restart the trial
        map:set_entities_enabled("hole_to_clear", true)
    end
end

function hole_eater:on_moved()
    hero:freeze()
    hole_eater_moving = true
end

function map:on_command_pressed(command)
    if hole_eater_moving and angles[command] ~= nil then
        -- set the next dir for the hole_eater
        next_angle = angles[command]
    end
end

function map:on_started()
    if game:get_value("hole_clearer") then
        -- start a dialog to know if the player want to reset the trial
        game:start_dialog("reset_trial", function(answer)
            if answer == 2 then
                game:set_value("hole_clearer", false)
            end
        end)
    end
end
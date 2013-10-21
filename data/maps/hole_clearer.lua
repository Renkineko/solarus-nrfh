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
local calcul_next_coords = {
    [0] = {x = 16, y = 0},
    [90] = {x = 0, y = -16},
    [180] = {x = -16, y = 0},
    [270] = {x = 0, y = 16},
}

function separator_entrance_trial:on_activated()
    if not game:get_value("hole_clearer") then
        local hole_eater = map:get_entity("hole_eater")
        -- restart the trial
        map:set_entities_enabled("hole_to_clear", true)
        hole_eater:set_enabled(true)
        hole_eater:reset()
    else
        map:remove_entities("hole_to_clear")
    end
end

function hole_eater_launcher_enable_sensor:on_activated()
    map:get_entity("hole_eater_launcher"):set_enabled(true)
end

function hole_eater_launcher_disable_sensor:on_activated()
    map:get_entity("hole_eater_launcher"):set_enabled(false)
end

function hole_eater:on_moved()
    --hero:freeze()
    hole_eater_moving = true
    local holes_to_clear = map:get_entities("hole_to_clear")
    local hole_disabled = 0
    local hole_eater = map:get_entity("hole_eater")
    
    m:start(hole_eater)
    function m:on_position_changed(x, y)
        hero:freeze()
        -- the bloc has an origin point of 8,13 and dynamic tile of 0,0, so we affect the new position to
        origin_x, origin_y = hole_eater:get_origin()
        x = x - origin_x
        y = y - origin_y
        
        if x % 16 == 0 and y % 16 == 0 then
            -- get next coord by the angle
            local next_x = x + calcul_next_coords[next_angle].x
            local next_y = y + calcul_next_coords[next_angle].y
            
            local is_hole_next = false
            
            -- destroy the hole we're on
            for entity in holes_to_clear do
                local hole_x, hole_y, _ = entity:get_position()
                if hole_x == x and hole_y == y then
                    entity:set_enabled(false)
                    hole_disabled = hole_disabled + 1
                    break
                end
                
                -- check if the next step is a hole
                if hole_x == next_x and hole_y == next_y then
                    is_hole_next = true
                end
            end
            
            -- Stop movement if next step is not a hole and play sound, make a chest appear, anything...
            if #holes_to_clear == hole_disabled then
                m:stop()
                sol.audio.play_sound('secret')
                game:set_value("hole_clearer", true)
                hole_eater:set_enabled(false)
                hero:unfreeze()
                return
            end
            
            -- Stop movement if next step is not a hole and play sound wrong
            if not is_hole_next then
                m:stop()
                sol.audio.play_sound('wrong')
                hole_eater:set_enabled(false)
                hero:unfreeze()
                return
            end
            
            -- if this code is executed, it's because we have a hole in the next direction and the puzzle is not finished, so we set the potentially new angle
            m:set_angle(next_angle)
        end
    end
    m = sol.movement.create("straight")
end

function map:on_command_pressed(command)
    if hole_eater_moving and angles[command] ~= nil then
        -- Check for the next angle possibility
        local angle = angles[command]
        local angle_diff = next_angle - angle
        -- If player does not make a 180 turn, set the next dir for the hole_eater
        if math.abs(angle_diff / 180) ~= 1 then
            next_angle = angle
        end
    end
end

function map:on_started()
    local hole_eater_launcher = map:get_entity("hole_eater_launcher")
    hole_eater_launcher:set_visible(false)
    hole_eater_launcher:set_enabled(false)
    if game:get_value("hole_clearer") then
        -- start a dialog to know if the player wants to reset the trial
        game:start_dialog("reset_trial", function(answer)
            if answer == 2 then
                game:set_value("hole_clearer", false)
            end
        end)
    end
end
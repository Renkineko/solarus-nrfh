local map = ...
local game = map:get_game()
local hole_eater_moving = false
local new_move = false
local hole_eater_coord = {x = nil, y = nil}
local holes_to_clear = {}
local hole_disabled = 0
local next_angle = 2
local movement
local angles = {
    right = 0,
    up = 2,
    left = 4,
    down =  6
}
local calcul_next_coords = {
    [0] = {x = 16, y = 0},
    [2] = {x = 0, y = -16},
    [4] = {x = -16, y = 0},
    [6] = {x = 0, y = 16}
}

local function check_next_hole(x, y)
    -- get next coord by the angle
    local next_x = x + calcul_next_coords[next_angle].x
    local next_y = y + calcul_next_coords[next_angle].y
    
    for i, entity in pairs(holes_to_clear) do
        -- check if the next step is a hole
        local hole_x, hole_y, _ = entity:get_position()
        
        if entity:is_enabled() and hole_x == next_x and hole_y == next_y then
            
            return true
        end
    end
    
    return false
end

local function trial_failed()
    sol.audio.play_sound('wrong')
    hole_eater:set_enabled(false)
    map:get_entity("hole_eater_launcher"):set_enabled(false)
    hero:unfreeze()
    hole_eater_moving = false
end

function separator_entrance_trial:on_activated()
    if not game:get_value("hole_clearer") then
        local hole_eater = map:get_entity("hole_eater")
        -- restart the trial
        map:set_entities_enabled("hole_to_clear", true)
        hole_eater:set_enabled(true)
        hole_eater:set_position(hole_eater_coord.x, hole_eater_coord.y)
        hole_disabled = 0
    else
        map:remove_entities("hole_to_clear")
    end
end

local function movement_finished(m)
    -- the bloc has an origin point of 8,13 and dynamic tile of 0,0, so we affect the new position to
    local origin_x, origin_y = hole_eater:get_origin()
    local x, y = m:get_xy()
    x = x - origin_x
    y = y - origin_y
    
    local is_hole_next = check_next_hole(x, y)
    
    -- destroy the hole we're on
    for i, entity in pairs(holes_to_clear) do
        local hole_x, hole_y, _ = entity:get_position()
        if hole_x == x and hole_y == y then
            entity:set_enabled(false)
            hole_disabled = hole_disabled + 1
            break
        end
    end
    
    -- Stop movement if next step is not a hole and play sound, make a chest appear, anything...
    if #holes_to_clear == hole_disabled then
        sol.audio.play_sound('secret')
        game:set_value("hole_clearer", true)
        map:get_entity("hole_eater_launcher"):set_enabled(false)
        hole_eater:set_enabled(false)
        hole_eater_moving = false
        hero:unfreeze()
        return
    end
    
    if hole_eater:get_sprite():get_animation() ~= "lit" then
        hero:unfreeze()
        hole_eater_moving = false
        return
    end
    
    -- Stop movement if next step is not a hole and play sound wrong
    if not is_hole_next then
        trial_failed()
        return
    end
    
    -- if this code is executed, it's because we have a hole in the next direction and the puzzle is not finished, so we set the potentially new angle
    movement = sol.movement.create("path")
    movement:set_path({next_angle, next_angle})
    movement.on_finished = movement_finished
    movement:start(hole_eater)
end

function hole_eater:on_interaction()
    game:start_dialog('hint_torch')
end

function hole_eater:on_collision_fire()
    hole_eater:get_sprite():set_animation("lit")
    sol.timer.start(10000, function()
        hole_eater:get_sprite():set_animation("unlit")
    end)
end

function hole_eater_controller:on_interaction()
    if hole_eater:get_sprite():get_animation() ~= "lit" then
        sol.audio.play_sound("wrong")
        return
    end
    
    -- While the block is moving, we freeze the hero
    hero:freeze()
    
    -- Initialize important vars
    hole_eater_moving = true
    new_move = true
    map:get_entity("hole_eater_launcher"):set_enabled(true)
    
    -- check if a direction was pressed before the player interacts with the controller
    if game:is_command_pressed("up") then
        next_angle = 2
    end
    
    sol.timer.start(250, function()
        local hole_eater = map:get_entity("hole_eater")
        local x, y = hole_eater:get_position()
        local origin_x, origin_y = hole_eater:get_origin()
        x = x - origin_x
        y = y - origin_y
        local is_next_hole = check_next_hole(x, y)
        
        if is_next_hole then
            new_move = false
            movement = sol.movement.create("path")
            movement:set_path({next_angle, next_angle})
            movement.on_finished = movement_finished
            movement:start(hole_eater)
        else
            trial_failed()
        end
    end)
end

function map:on_command_pressed(command)
    if hole_eater_moving and angles[command] ~= nil then
        -- If it's a new move there is no constraint about the direction, we set the new one and let's go.
        if new_move then
            next_angle = angles[command]
            return    
        end
        
        -- Check for the next angle possibility
        local angle = angles[command]
        local angle_diff = next_angle - angle
        -- If player does not make a 180 turn, set the next dir for the hole_eater
        if math.abs(angle_diff / 4) ~= 1 then
            next_angle = angle
        end
    end
end

function map:on_started()
    -- We setup the floor where the hole_eater will move
    local hole_eater_launcher = map:get_entity("hole_eater_launcher")
    hole_eater_launcher:set_visible(false)
    hole_eater_launcher:set_enabled(false)
    
    -- each entity "hole_to_clear" will be stocked into a local array
    for ent in map:get_entities("hole_to_clear") do
        holes_to_clear[#holes_to_clear + 1] = ent
    end
    
    -- Remember the hole_eater origin point if we need to reset it.
    hole_eater_coord.x, hole_eater_coord.y = map:get_entity("hole_eater"):get_position()
    
    -- if the puzzle has been resolved
    if game:get_value("hole_clearer") then
        -- start a dialog to know if the player wants to reset the trial
        game:start_dialog("reset_trial", function(answer)
            if answer == 2 then
                game:set_value("hole_clearer", false)
            end
        end)
    end
end
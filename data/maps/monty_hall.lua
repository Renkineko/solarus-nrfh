local map = ...
local game = map:get_game()
local origin_monty_hall_x, origin_monty_hall_y
local game_launched = false
local way_choosed = false
local rewards = {false, false, false}

local function reset_monty_hall_location()
    -- Replace Monty Hall NPC to its origin point if necessary
    now_monty_hall_x, now_monty_hall_y = monty_hall_npc:get_position()
    
    -- We must move first vertically because of the barriers
    if now_monty_hall_y ~= origin_monty_hall_y then
        -- We need a target movement to give x and y positions
        local move = sol.movement.create("target")
        move:set_target(now_monty_hall_x, origin_monty_hall_y)
        function move:on_changed()
            monty_hall_npc:get_sprite():set_direction(move:get_direction4())
        end
        
        -- Start the movement with a callback to move it horizontally
        move:start(monty_hall_npc, function()
            if now_monty_hall_x ~= origin_monty_hall_x then
                move = sol.movement.create("target")
                move:set_target(origin_monty_hall_x, origin_monty_hall_y)
                function move:on_changed()
                    monty_hall_npc:get_sprite():set_direction(move:get_direction4())
                end
                move:start(monty_hall_npc, function()
                    monty_hall_npc:get_sprite():set_animation("stopped")
                    monty_hall_npc:get_sprite():set_direction(3)
                end)
            end
        end)
        monty_hall_npc:get_sprite():set_animation("walking")
    elseif now_monty_hall_x ~= origin_monty_hall_x then
        -- He was already on the good axe Y (very strange, not suppose to happen)
        local move = sol.movement.create("target")
        move:set_target(origin_monty_hall_x, origin_monty_hall_y)
        function move:on_changed()
            monty_hall_npc:get_sprite():set_direction(move:get_direction4())
        end
        
        move:start(monty_hall_npc, function()
            monty_hall_npc:get_sprite():set_animation("stopped")
            monty_hall_npc:get_sprite():set_direction(3)
        end)
    end
end

-- Reset the map so we can start a new game without to exit
local function reset_map()
    -- Initiate global var
    game_launched = false
    way_choosed = false
    
    -- Close doors containing rewards and set entities needed for the game enabled
    map:close_doors("door")
    map:set_entities_enabled("sensor_door", true)
    map:set_entities_enabled("npc_door", true)
    monty_hall_npc_gen:set_enabled(true)
    
end

local function setup_game(price)
    game:remove_money(price)
    open_game_barrier:set_enabled(false)
    monty_hall_npc_gen:set_enabled(false)
    game_launched = true
    local good_door = math.random(1, 3)
    rewards = {false, false, false}
    rewards[good_door] = true
end

local function monty_hall_dialog()
    if game_launched then
        if not way_choosed then
            game:start_dialog("monty_hall_npc.choose_way")
        else
            game:start_dialog("monty_hall_npc.choose_door")
        end
    else
        game:start_dialog("monty_hall_npc.presentation", function(answer)
            if answer == 1 then
                setup_game(100)
            end
        end)
    end
end

function map:on_started()
    origin_monty_hall_x, origin_monty_hall_y = monty_hall_npc:get_position()
    reset_map()
end

function monty_hall_npc:on_interaction()
    monty_hall_dialog()
end

function monty_hall_npc_gen:on_interaction()
    monty_hall_npc:get_sprite():set_direction(3)
    monty_hall_dialog()
end

for npc_door in map:get_entities("npc_door") do
    function npc_door:on_interaction()
        local door_name = self:get_name():sub(5)
        local choosen_door_number = tonumber(door_name:sub(-1))
        map:open_doors(door_name)
        
        if rewards[choosen_door_number] then
            hero:start_treasure("rupee", 6, nil, function()
                hero:teleport("monty_hall")
                hero:freeze()
                sol.timer.start(500, function()
                    reset_map()
                    game:start_dialog("monty_hall_npc.won", function(answer)
                        if answer == 1 then
                            setup_game(100)
                        else
                            open_game_barrier:set_enabled(true)
                        end
                        reset_monty_hall_location()
                        hero:unfreeze()
                    end)
                end)
            end)
        else
            hero:start_treasure("heart", 1, nil, function()
                hero:teleport("monty_hall")
                hero:freeze()
                sol.timer.start(500, function()
                    reset_map()
                    game:start_dialog("monty_hall_npc.retry", function(answer)
                        if answer == 1 then
                            setup_game(75)
                        else
                            open_game_barrier:set_enabled(true)
                        end
                        reset_monty_hall_location()
                        hero:unfreeze()
                    end)
                end)
            end)
        end
        
        map:set_entities_enabled("npc_door", false)
    end
end

for sensor_door in map:get_entities("sensor_door") do
    function sensor_door:on_activated()
        way_choosed = true
        hero:freeze()
        local continue = true
        local door_monty_hall_number
        
        while continue do
            door_monty_hall_number = math.random(1, 3)
            if self:get_name() ~= "sensor_door_"..door_monty_hall_number and not rewards[door_monty_hall_number] then
                continue = false
            end
        end
        
        local door_monty_hall = map:get_entity("npc_door_"..door_monty_hall_number)
        local door_x, door_y = door_monty_hall:get_position()
        local now_monty_hall_x, now_monty_hall_y = monty_hall_npc:get_position()
        -- We must move first horizontally because of the barriers
        if now_monty_hall_x ~= door_x then
            -- We need a target movement to give x and y positions
            local move = sol.movement.create("target")
            move:set_target(door_x, origin_monty_hall_y)
            move:set_smooth(false)
            function move:on_changed()
                monty_hall_npc:get_sprite():set_direction(move:get_direction4())
            end
            function move:on_obstacle_reached()
                hero:unfreeze()
                map:set_entities_enabled("sensor_door", false)
                move:stop()
                monty_hall_npc:get_sprite():set_animation("stopped")
                monty_hall_npc:get_sprite():set_direction(3)
            end
            monty_hall_npc:get_sprite():set_animation("walking")
            
            -- Start the movement with a callback to move it horizontally
            move:start(monty_hall_npc, function()
                if now_monty_hall_y ~= door_y then
                    move = sol.movement.create("target")
                    move:set_target(door_x, door_y)
                    move:set_smooth(false)
                    function move:on_changed()
                        monty_hall_npc:get_sprite():set_direction(move:get_direction4())
                    end
                    
                    function move:on_obstacle_reached()
                        hero:unfreeze()
                        map:set_entities_enabled("sensor_door", false)
                        move:stop()
                        monty_hall_npc:get_sprite():set_animation("stopped")
                        monty_hall_npc:get_sprite():set_direction(3)
                    end
            
                    move:start(monty_hall_npc, function()
                        hero:unfreeze()
                        map:set_entities_enabled("sensor_door", false)
                        move:stop()
                        monty_hall_npc:get_sprite():set_animation("stopped")
                        monty_hall_npc:get_sprite():set_direction(3)
                    end)
                end
            end)
            monty_hall_npc:get_sprite():set_animation("walking")
        elseif now_monty_hall_y ~= door_y then
            -- He was already on the good axe X
            local move = sol.movement.create("target")
            move:set_target(door_x, door_y)
            move:set_smooth(false)
            function move:on_changed()
                monty_hall_npc:get_sprite():set_direction(move:get_direction4())
            end
            function move:on_obstacle_reached()
                hero:unfreeze()
                map:set_entities_enabled("sensor_door", false)
                move:stop()
                monty_hall_npc:get_sprite():set_animation("stopped")
                monty_hall_npc:get_sprite():set_direction(3)
            end
            
            move:start(monty_hall_npc, function()
                hero:unfreeze()
                map:set_entities_enabled("sensor_door", false)
                move:stop()
                monty_hall_npc:get_sprite():set_animation("stopped")
                monty_hall_npc:get_sprite():set_direction(3)
            end)
            monty_hall_npc:get_sprite():set_animation("walking")
        end
    end
end
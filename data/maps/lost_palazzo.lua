local map = ...
local game = map:get_game()
local light_manager = require("maps/lib/light_manager")
local torches_delay = 15000
local jump_good_sensor = 0

-- Possibles positions where enemies can appear at the torches room
local positions = {
  {x = 88, y = 88},
  {x = 120, y = 88},
  {x = 160, y = 88},
  {x = 200, y = 88},
  {x = 240, y = 88},
  {x = 280, y = 88},
  {x = 312, y = 88},
  {x = 88, y = 160},
  {x = 120, y = 160},
  {x = 160, y = 160},
  {x = 200, y = 160},
  {x = 240, y = 160},
  {x = 280, y = 160},
  {x = 312, y = 160},
  {x = 88, y = 232},
  {x = 120, y = 232},
  {x = 160, y = 232},
  {x = 200, y = 232},
  {x = 240, y = 232},
  {x = 280, y = 232},
  {x = 312, y = 232},
  {x = 160, y = 120},
  {x = 160, y = 200},
  {x = 240, y = 120},
  {x = 240, y = 200}
}

-- Possibles breeds of the appearing enemies in the torches room
local breeds = {
  "skeletor",
  "soldier",
  "tentacle",
  "bubble",
  "gibdo",
  "globul",
  "lizalfos",
  "ropa"
}

-- Count the number of torches lit
local function get_nb_torches_lit()

    -- If torches are no longer on the map, the enigma has been already solved
    if torch_1 == nil then
        return map:get_entities_count("torch")
    end
    
    local nb_torches_lit = 0
    
    for torch in map:get_entities("torch") do
        if torch:get_sprite():get_animation() == "lit" then
            nb_torches_lit = nb_torches_lit + 1
        end
    end
    
    return nb_torches_lit
end

-- Check if all torches are lit (or if the torches not exist)
local function all_torches_lit()

    return get_nb_torches_lit() == map:get_entities_count("torch")
end

local function lock_torches()
    -- the trick: just remove the interactive torches because there are static ones below
    torch_1:remove()
    torch_2:remove()
    torch_3:remove()
    torch_4:remove()
    torch_5:remove()
    torch_6:remove()
end

local function check_torches()
    if all_torches_lit() then
        lock_torches()
        -- Stop timers of lit torches to set light to 0
        sol.timer.stop_all(map)
        map:set_light(1)
        for enemy in map:get_entities("enemy_torch") do
            enemy:set_life(0)
        end
        map:open_doors("door_torch")
        map:open_doors("door_jump_1")
        game:set_value("lost_palazzo_torches_ok", true)
        sol.audio.play_sound("secret")
        return true
    end
    
    return false
end

local function stop_jump_sensor()
    map:remove_entities("sensor_jump_room")
    map:remove_entities("jump_room_close_door_sensor")
end

local function init_stream_jump_room()
    local nDirection = 0
    for stream in map:get_entities('stream_jump_room') do
        stream:set_speed(16)
        nDirection = math.random(0,7)
        stream:set_direction(nDirection)
    end
end 

-- Initiate the map
function map:on_started()
    -- Enable light features for the torch puzzle
    light_manager.enable_light_features(map)
    
    -- It's a map with keys
    map.small_keys_savegame_variable = "lost_palazzo_small_keys"
    
    -- Check of savegame variables
    if map:get_game():get_value("lost_palazzo_torches_ok") then
        lock_torches()
    end
    
    if map:get_game():get_value("lost_palazzo_jump_room_ok") then
        stop_jump_sensor()
    end
    
    if map:get_game():get_value("lost_palazzo_mini_boss_killed") then
        map:remove_entities("close_mb_sensor")
        map:open_doors("mb_door")
        map:set_entities_enabled("tp_mini_boss_room", true)
    else
        mini_boss_gigas:set_enabled(false)
        map:set_entities_enabled("tp_mini_boss_room", false)
    end
    
    if map:get_game():get_value("lost_palazzo_boss_killed") then
        map:remove_entities("close_boss_door_sensor")
        map:remove_entities("boss_room_trap_activate_sensor")
    else
        map:set_entities_enabled("switch_boss", false)
    end
    
    map:set_entities_enabled("dyn_boss_trap_active", false)
    map:set_entities_enabled("dyn_boss_trap_inactive", true)
    npc_boss_cannon:set_enabled(false)
    
    -- Open doors
    map:set_doors_open("ke_a", true)
    map:set_doors_open("door_torch", true)
    map:set_doors_open("door_jump", true)
    map:set_doors_open("boss_door")
    
    -- Disable tp of the symetric room
    tp_hole:set_enabled(false)
    tp_hole_back:set_enabled(false)
    dyn_hole_tp:set_enabled(false)
    dyn_hole_tp_back:set_enabled(false)
    
    -- Set the bubbles flying, just to add challenge...
    for enemy in map:get_entities("flying_bubble") do
        enemy:set_obstacle_behavior("flying")
    end

    init_stream_jump_room()

end

function ww_a:on_opened()
    sol.audio.play_sound("secret")
end

-- /// SENSORS \\\
-- Close the door of the south-east room if enemies are alive
function close_ke_a_sensor:on_activated()
    
    if ke_a:is_open() and map:has_entities("ke_a_enemy") then
        map:close_doors("ke_a")
    end
end
close_ke_a_sensor_2.on_activated = close_ke_a_sensor.on_activated

function close_mb_sensor:on_activated()
    if map:get_game():get_value("lost_palazzo_mini_boss_killed") then
        map:open_doors("mb_door")
    else
        map:close_doors("mb_door")
        map:close_doors("switch_door_a_2")
        mini_boss_gigas:set_enabled(true)
    end
    map:remove_entities("close_mb_sensor")
end
close_mb_sensor_2.on_activated = close_mb_sensor.on_activated

function close_boss_door_sensor:on_activated()
    map:set_entities_enabled("block_boss", false)
    if not game:get_value("lost_palazzo_boss_killed") then
        map:set_entities_enabled("switch_boss", true)
        map:close_doors("boss_door")
        hero:walk("222222")
        -- enable cannon
        -- enable boss
        -- disable path
        
    else
        map:set_entities_enabled("switch_boss", false)
        -- enable path
    end
    self:set_enabled(false)
end

function boss_room_trap_activate_sensor:on_activated()
    map:set_entities_enabled("dyn_boss_trap_active", true)
    map:set_entities_enabled("dyn_boss_trap_inactive", false)
    npc_boss_cannon:set_enabled(true)
    self:set_enabled(false)
end

-- Close the door of the torches room and set light to dark...
function sensor_torch:on_activated()

    if door_torch:is_open() and not all_torches_lit() then
        map:close_doors("door_torch")
        map:close_doors("door_jump_1")
        map:set_light(0)
    end
end
sensor_torch_2.on_activated = sensor_torch.on_activated

function jump_room_close_door_sensor:on_activated()
	if not map:get_game():get_value("lost_palazzo_jump_room_ok") then
		map:close_doors("door_jump")
		hero:save_solid_ground()
	else
		stop_jump_sensor()
	end
end
jump_room_close_door_sensor_2.on_activated = jump_room_close_door_sensor.on_activated

-- Sensor reseting solid ground...
for sensor in map:get_entities("reset_solid_ground_sensor") do
    function sensor:on_activated()
        
    end
end

-- Sensor reseting solid ground...
for sensor in map:get_entities("save_solid_ground_sensor") do
    function sensor:on_activated()
        hero:save_solid_ground()
    end
end

function sensor_jump_room_1:on_activated()
    if jump_good_sensor == 0 or jump_good_sensor == 6 then
        jump_good_sensor = jump_good_sensor + 1
    elseif jump_good_sensor ~= 0 then
        init_stream_jump_room()
        sol.audio.play_sound("wrong")
        jump_good_sensor = 1
    end
end

function sensor_jump_room_2:on_activated()
    if jump_good_sensor == 1 or jump_good_sensor == 5 then
        jump_good_sensor = jump_good_sensor + 1
    elseif jump_good_sensor ~= 0 then
        init_stream_jump_room()
        sol.audio.play_sound("wrong")
        jump_good_sensor = 0
    end
end

function sensor_jump_room_3:on_activated()
    if jump_good_sensor == 2 or jump_good_sensor == 4 then
        jump_good_sensor = jump_good_sensor + 1
    elseif jump_good_sensor ~= 0 then
        init_stream_jump_room()
        sol.audio.play_sound("wrong")
        jump_good_sensor = 0
    end
end

function sensor_jump_room_4:on_activated()
    if jump_good_sensor == 3 or jump_good_sensor == 7 then
        jump_good_sensor = jump_good_sensor + 1
    elseif jump_good_sensor == 11 then
        sol.audio.play_sound("secret")
        stop_jump_sensor()
        map:open_doors("door_jump")
        map:get_game():set_value("lost_palazzo_jump_room_ok", true)
    elseif jump_good_sensor ~= 0 then
        init_stream_jump_room()
        sol.audio.play_sound("wrong")
        jump_good_sensor = 0
    end
end

function sensor_jump_room_5:on_activated()
    if jump_good_sensor == 8 or jump_good_sensor == 10 then
        jump_good_sensor = jump_good_sensor + 1
    elseif jump_good_sensor ~= 0 then
        init_stream_jump_room()
        sol.audio.play_sound("wrong")
        jump_good_sensor = 0
    end
end

function sensor_jump_room_6:on_activated()
    if jump_good_sensor == 9 then
        jump_good_sensor = jump_good_sensor + 1
    elseif jump_good_sensor ~= 0 then
        init_stream_jump_room()
        sol.audio.play_sound("wrong")
        jump_good_sensor = 0
    end
end

-- /// ENEMIES \\\
-- Check on each enemy's death of the group if we have to open the doors...
for enemy in map:get_entities("ke_a_enemy") do
    function enemy:on_dead()
        if not map:has_entities("ke_a_enemy") and not ke_a:is_open() then
            sol.audio.play_sound("secret")
            map:open_doors("ke_a")
        end
    end
end

-- Slow down a little pikes in the switches room...
for enemy in map:get_entities("pike_switch") do
    function enemy:on_restarted()
        local sprite = enemy:get_sprite()
        local direction4 = sprite:get_direction()
        local m = sol.movement.create("path")
        m:set_path{direction4 * 2}
        m:set_speed(128)
        m:set_loop(true)
        m:start(enemy)
    end
end

function mini_boss_gigas:on_dead()
    map:get_game():set_value("lost_palazzo_mini_boss_killed", true)
    map:open_doors("mb_door")
    map:open_doors("switch_door_a_2")
    map:set_entities_enabled("tp_mini_boss_room", true)
    sol.audio.play_sound("secret")
end

-- /// SWITCHES \\\
function tp_switch:on_activated()
    tp_hole:set_enabled(true)
    tp_hole_back:set_enabled(false)
    dyn_hole_tp:set_enabled(true)
    dyn_hole_tp_back:set_enabled(false)
    tp_switch_back:set_activated(false)
    sol.audio.play_sound("secret")
end

function tp_switch_back:on_activated()
    tp_hole:set_enabled(false)
    tp_hole_back:set_enabled(true)
    dyn_hole_tp:set_enabled(false)
    dyn_hole_tp_back:set_enabled(true)
    tp_switch:set_activated(false)
    sol.audio.play_sound("secret")
end

-- Enigma of the switches
function final_sd_a:on_activated()
    local all_activated = true
    for switch in map:get_entities("sd_a") do
        if not switch:is_activated() then
            all_activated = false
        end
    end
    
    if all_activated then
        map:open_doors("switch_door_a")
        for switch in map:get_entities("sd_a") do
            switch:set_locked(true)
        end
    else
        sd_block:reset()
        sd_block_2:reset()
        sd_block_3:reset()
        sd_block_4:reset()
    end
end

function switch_boss_fire_cannon:on_activated()
    -- make an explosion on the coordinates corresponding to the position x, y-192 of the cannon
    local explo_x, explo_y = npc_boss_cannon:get_position()
    -- get the boss position to calculate the y
    
    switch_boss_fire_cannon:set_activated(true)
    switch_boss_fire_cannon_2:set_activated(true)
    sol.timer.start(200, function()
        sol.audio.play_sound("jump")
    end)
    
    sol.timer.start(1000, function()
        -- decide if the boss can dodge the attack or not
        map:create_explosion({layer=2, x=explo_x, y=explo_y-192})
        sol.audio.play_sound("explosion")
        
        -- deactivate the switch
        sol.timer.start(2500, function()
            switch_boss_fire_cannon:set_activated(false)
            switch_boss_fire_cannon_2:set_activated(false)
        end)
    end)
end
switch_boss_fire_cannon_2.on_activated = switch_boss_fire_cannon.on_activated

function switch_boss_cannon_left:on_activated()
    -- move the cannon to the left
    local move = sol.movement.create("straight")
    move:set_speed(64)
    move:set_angle(math.pi)
    move:start(npc_boss_cannon)
end
function switch_boss_cannon_right:on_activated()
    -- move the cannon to the right
    local move = sol.movement.create("straight")
    move:set_speed(64)
    move:set_angle(0)
    move:start(npc_boss_cannon)
end

function switch_boss_cannon_left:on_inactivated()
    -- immobilize the cannon
    npc_boss_cannon:stop_movement()
end
switch_boss_cannon_right.on_inactivated = switch_boss_cannon_left.on_inactivated

function switch_boss_protect_upleft:on_activated()
    map:set_entities_enabled("block_boss_protect_upleft", true)
    map:set_entities_enabled("block_boss_protect_left", true)
end
function switch_boss_protect_up:on_activated()
    map:set_entities_enabled("block_boss_protect_upleft", true)
    map:set_entities_enabled("block_boss_protect_upright", true)
    map:set_entities_enabled("block_boss_protect_up", true)
end
function switch_boss_protect_upright:on_activated()
    map:set_entities_enabled("block_boss_protect_upright", true)
    map:set_entities_enabled("block_boss_protect_right", true)
end


function switch_boss_protect_upleft:on_inactivated()
    map:set_entities_enabled("block_boss_protect", false)
end
switch_boss_protect_upright.on_inactivated = switch_boss_protect_upleft.on_inactivated
switch_boss_protect_up.on_inactivated = switch_boss_protect_upleft.on_inactivated

-- /// TORCHES \\\
local function torch_interaction(torch)
    game:start_dialog("torch.need_lamp")
end

local function torch_collision_fire(torch)
    local torch_sprite = torch:get_sprite()
    if torch_sprite:get_animation() == "unlit" then
        -- temporarily light the torch up
        torch_sprite:set_animation("lit")
        local puzzle_solved = check_torches()
        
        if not puzzle_solved then
            local enemy_name = "enemy_" .. torch:get_name()
            local position = positions[math.random(#positions)]
            local enemy_breed = breeds[math.random(#breeds)]
            local nb_enemy_to_create = get_nb_torches_lit()
            -- Create X new enemies, X is the number of torches lit
            for n = 1, nb_enemy_to_create do
                map:create_enemy({name = enemy_name .. "_" .. n, layer = 0, x = position.x, y = position.y, direction = 3, breed = enemy_breed, treasure_name="random"})
            end
            
            -- set the timer to unlit the torches and destroy the mobs
            sol.timer.start(torches_delay, function()
                torch_sprite:set_animation("unlit")
                map:remove_entities(enemy_name)
            end)
        else
        end
    end
end

for torch in map:get_entities("torch") do
    torch.on_interaction = torch_interaction
    torch.on_collision_fire = torch_collision_fire
end

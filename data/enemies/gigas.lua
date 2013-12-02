local enemy = ...
local sprite
local ball_form = false

-- Gigas, mini-boss of the lost palazzo.
-- He can throw poison gaz, make enemies appear, teleport, crush the ground and invoke thunder blast

-- attack one : when near the hero, lay on his knees and punch the floor, making it crackling (with hands down animation)
-- attack two : when at a certain distance, invoke thunder blast making hero slow (with hands up animation)
-- attack three : randomly throw poison gaz (with expiration animation)
-- attack four : randomly make two monsters appear to help him (with hands up and cast animations)
-- when hurt : teleport somewhere else in the room (random position from positions table).
--             Ball spirits are invincibles and move randomly during 2 to 5s before making him reappear

-- Possible positions where he appears.
local positions = {
    {x = 920, y = 148},
    {x = 1016, y = 148},
    {x = 920, y = 208},
    {x = 1016, y = 208},
    {x = 968, y = 168},
}

-- List of spirit balls and their relative position from origin teleport sprite
local spirit_balls = {}
local spirit_balls_pos = {
    {x = -37, y = 0},
    {x = -11, y = -37},
    {x = -11, y = 37},
    {x = 10, y = -37},
    {x = 10, y = 37},
    {x = 37, y = 0},
}

function enemy:reset_attack_consequences()
    enemy:set_attack_consequence("sword", 1)
    enemy:set_attack_consequence("thrown_item", 'protected')
    enemy:set_attack_consequence("explosion", 'ignored')
    enemy:set_attack_consequence("arrow", 1)
    enemy:set_attack_consequence("hookshot", 'protected')
    enemy:set_attack_consequence("boomerang", 'protected')
    enemy:set_attack_consequence("fire", 1)
end

function enemy:reappear()
    -- this function regroups spirit balls to the good positions and when they are all on their good point,
    -- the sprite animate to spirit_transformation_in and Gigas is back to kick ass !
    local position = positions[math.random(#positions)]
    for n = 1, #spirit_balls_pos do
        spirit_balls[n]:go_to_position(position.x + spirit_balls_pos[n].x, position.y + spirit_balls_pos[n].y)
    end
    
    -- The balls will stay around 1 sec because the speed is calculated to cover the distance in ~2 sec
    sol.timer.start(enemy, 3000, function()
        enemy:set_position(position.x, position.y)
        sprite:set_animation("spirit_transformation_in")

        for n = 1, #spirit_balls_pos do
            spirit_balls[n]:disappear()
        end
        
        function sprite:on_animation_finished()
            ball_form = false
            enemy:restart()
        end
    end)
end

function enemy:teleport()
    -- this function split the enemy into six balls of energy randomly going through the room
    -- and after X seconds, come back on one of the positions.
    enemy:set_invincible()
    enemy:stop_movement()
    sprite:set_animation("spirit_transformation_out")
    function sprite:on_animation_finished()
        pos_x, pos_y = enemy:get_position()

        enemy:set_position(-100, -100)
        -- invoke spirit balls here
        for n = 1, #spirit_balls_pos do
            spirit_balls[n]:appear(pos_x + spirit_balls_pos[n].x, pos_y + spirit_balls_pos[n].y)
        end
        
        sol.timer.start(enemy, math.random(4000, 8000), function()
            enemy:reappear()
        end)
    end
end

function enemy:attack_thunder_blast()
    print('[TODO] Thunder Blast - todo when enemy:attack_custom will be available in the engine')
    enemy:stop_movement()
    sprite:set_animation("hands_up_infinite")
    
    local thunder_strike = enemy:create_enemy({breed = 'thunder_strike', direction = 0, y = -80})
    
    function thunder_strike:on_removed()
        enemy:restart()
    end
end

function enemy:attack_punch_floor()
    enemy:stop_movement()
    sprite:set_animation("hands_down")
    
    function sprite:on_animation_finished()
        enemy:restart()
    end
end

function enemy:attack_poison_gaz()
    print('[TODO] Poison Gaz - when enemy:attack_custom will be available in the engine')
    enemy:stop_movement()
    sprite:set_animation("spitting")
    
    local step = 500
    local nb_gaz = 5
    local enemy_x, enemy_y = enemy:get_position()
    
    for i = 1, nb_gaz do
        sol.timer.start(enemy, i*step, function()
            local hero_x, hero_y = enemy:get_map():get_entity('hero'):get_position()
            local x = hero_x - enemy_x
            local y = hero_y - enemy_y
            
            sol.timer.start(enemy, 100, function()
                poison_gaz = enemy:create_enemy({breed = 'poison_gaz', direction = 0, x = x, y = y})
            end)
        end)
    end
    
    sol.timer.start(enemy, (nb_gaz + 1) * step, function()
        enemy:restart()
    end)
end

function enemy:attack_invoke_monster()
    enemy:stop_movement()
    sprite:set_animation("hands_up")
    
    local summon1 = enemy:get_map():create_enemy({x = 880, y = 160, layer = 0, breed = 'summoning', direction = 0})
    summon1:set_properties({
        sprite = "effects/cast1",
        breed_to_create = "bee_guard",
        max_number_monster = 4
    })
    
    local summon2 = enemy:get_map():create_enemy({x = 1056, y = 160, layer = 0, breed = 'summoning', direction = 0})
    summon2:set_properties({
        sprite = "effects/cast1",
        breed_to_create = "bee_guard",
        max_number_monster = 4
    })
    
    function sprite:on_animation_finished()
        enemy:restart()
    end
end

function enemy:choose_attack()
    -- calculate distance from the hero to know what to do
    local hero = enemy:get_map():get_entity("hero")
    local distance = enemy:get_distance(hero)
    
    --if distance > 150 then
    --    if math.random(1, 2) == 1 then
            enemy:attack_thunder_blast()
    --        return
    --    end
    --elseif distance < 100 then
    --    if math.random(1, 2) == 1 then
    --        enemy:attack_punch_floor()
    --        return
    --    end
    --end
    --
    --if math.random(1, 2) == 1 then
    --    enemy:attack_poison_gaz()
    --else
    --    enemy:attack_invoke_monster()
    --end
end

function enemy:on_created()

    enemy:set_life(20)
    enemy:set_damage(24)
    sprite = enemy:create_sprite("enemies/gigas")
    enemy:set_size(72, 32)
    enemy:set_origin(36, 29)
    pos_x, pos_y, pos_layer = enemy:get_position()
    if pos_layer < 2 then
        pos_layer = pos_layer + 1
    end

    for n = 1, #spirit_balls_pos do
        spirit_balls[n] = enemy:create_enemy({name = "gigas_spirit_" .. n, direction = 0, breed = "gigas_spirit_ball", layer = pos_layer})
        spirit_balls[n]:set_enabled(false)
    end
end

function enemy:on_restarted()
    if ball_form then
        sol.timer.stop_all(enemy)
        enemy:teleport()
    else
        enemy:reset_attack_consequences()
        local move = sol.movement.create("path_finding")
        move:set_speed(48)
        move:start(enemy)
        sol.timer.start(enemy, math.random(2000, 5000), function()
            enemy:choose_attack()
        end)
    end
end

function enemy:on_movement_changed(movement)
    local enemy_x = enemy:get_position()
    local hero_x = enemy:get_map():get_entity("hero"):get_position()
    
    if enemy_x < hero_x then
        enemy:get_sprite():set_direction(0)
    else
        enemy:get_sprite():set_direction(1)
    end
end

function enemy:on_hurt()
    ball_form = true
end

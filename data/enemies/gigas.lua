local enemy = ...
local sprite

-- Gigas, mini-boss of the lost palazzo.
-- He can throw poison gaz, make enemies appear, teleport, crush the ground and invoke thunder blast

-- attack one : when near the hero, lay on his knees and punch the floor, making it crackling (with hands down animation)
-- attack two : when at a certain distance, invoke thunder blast making hero slow (with hands up animation)
-- attack three : randomly throw poison gaz (with expiration animation)
-- attack four : randomly make two lizalfos appear (with hands up animation)
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
    {x = -20, y = 0},
    {x = -10, y = -20},
    {x = -10, y = 20},
    {x = 10, y = -20},
    {x = 10, y = 20},
    {x = 20, y = 0},
}

function enemy:reappear()
    -- this function regroups spirit balls to the good positions and when they are all on their good point,
    -- the sprite animate to spirit_transformation_in and Gigas is back to kick ass !
    local position = positions[math.random(#positions)]
    for n = 1, #spirit_balls_pos do
        spirit_balls[n]:go_to_position(position.x + spirit_balls_pos[n].x, position.y + spirit_balls_pos[n].y)
    end

    -- The balls will stay around 1 sec because the speed is calculated to cover the distance in ~2 sec
    sol.timer.start(self, 3000, function()
        enemy:set_position(position.x, position.y)
        sprite:set_animation("spirit_transformation_in")

        for n = 1, #spirit_balls_pos do
            spirit_balls[n]:disappear()
        end

        function sprite:on_animation_finished()
            enemy:restart()
        end
    end)
end

function enemy:teleport()
    -- this function split the enemy into six balls of energy randomly going through the room
    -- and after X seconds, come back on one of the positions.
    enemy:set_invincible()
    sprite:set_animation("spirit_transformation_out")
    enemy:stop_movement()
    function sprite:on_animation_finished()
        pos_x, pos_y = enemy:get_position()

        enemy:set_position(-100, -100)
        -- invoke spirit balls here
        for n = 1, #spirit_balls_pos do
            spirit_balls[n]:appear(pos_x + spirit_balls_pos[n].x, pos_y + spirit_balls_pos[n].y)
        end

        sol.timer.start(math.random(2000, 5000), function()
            enemy:reappear()
        end)
    end
end

function enemy:attack_thunder_blast()
    print('[TODO] Thunder Blast - todo when enemy:attack_custom will be available in the engine')
    enemy:stop_movement()
    sprite:set_animation("hands_up")
    
    function sprite:on_animation_finished()
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
    
    sol.timer.start(2500, function()
        enemy:restart()
    end)
end

function enemy:attack_invoke_lizalfos()
    enemy:stop_movement()
    sprite:set_animation("hands_up")
    
    function sprite:on_animation_finished()
        enemy:restart()
    end
end

function enemy:choose_attack()
    -- calculate distance from the hero to know what to do
    local hero = enemy:get_map():get_entity("hero")
    local distance = self:get_distance(hero)
    
    print(distance)
    if distance > 150 then
        if math.random(1, 2) == 1 then
            self:attack_thunder_blast()
            return
        end
    elseif distance < 100 then
        if math.random(1, 2) == 1 then
            self:attack_punch_floor()
            return
        end
    end
    
    if math.random(1, 2) == 1 then
        self:attack_poison_gaz()
    else
        self:attack_invoke_lizalfos()
    end
end

function enemy:on_created()

    self:set_life(20)
    self:set_damage(24)
    sprite = self:create_sprite("enemies/gigas")
    self:set_size(72, 32)
    self:set_origin(36, 29)
    pos_x, pos_y, pos_layer = enemy:get_position()

    for n = 1, #spirit_balls_pos do
        spirit_balls[n] = enemy:create_enemy({name = "gigas_spirit_" .. n, direction = 0, breed = "gigas_spirit_ball"})
        spirit_balls[n]:set_enabled(false)
    end
    
    -- When Gigas is hurted, he then teleport to another spot of the room
    local old_animation
    function sprite:on_animation_changed(animation)
        if old_animation == "hurt" then
            enemy:teleport()
        end
        old_animation = animation
    end
end

function enemy:on_restarted()
    
    if sprite:get_animation() ~= "spirit_transformation_out" and sprite:get_animation() ~= "spirit_transformation_in" then
        enemy:set_default_attack_consequences()
        local move = sol.movement.create("path_finding")
        move:set_speed(48)
        move:start(self)
        
        sol.timer.start(self, math.random(2000, 5000), function()
            self:choose_attack()
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


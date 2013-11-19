local enemy = ...
local sprite

-- Gigas, mini-boss of the lost palazzo.
-- He can throw poison gaz, appear enemies, teleport and invoke thunder blast

-- attack one : when near the hero, lay on his knees and punch the floor, making it crackling (with hands down animation)
-- attack two : when at a certain distance, invoke thunder blast making hero slow (with hands up animation)
-- attack three : randomly throw poison gaz (with expiration animation)
-- attack four : randomly make two lizalfos appear (with hands up animation)
-- when hurt : teleport somewhere else in the room (random position from positions table).
--             Ball spirits are invincibles and move randomly during 2 to 5s before making him reappear

-- Possible positions where he appears.
local positions = {
    {x = 952, y = 104},
    {x = 1072, y = 104},
    {x = 952, y = 224},
    {x = 1072, y = 224},
    {x = 1008, y = 168},
}

function enemy:teleport()
    -- this function split the enemy into six balls of energy randomly going through the room
    -- and after X seconds, come back on one of the positions.
    sprite:set_animation("spirit_transformation_in")
    function sprite:on_animation_finished()
        sol.timer.start(math.random(2000, 5000), function()
            local position = (positions[math.random(#positions)])
            enemy:set_position(position.x, position.y)
            sprite:set_animation("spirit_transformation_out")
        end)
    end
end

function enemy:attack_thunder_blast()
    print('todo when enemy:attack_custom will be available in the engine')
    enemy:restart()
end

function enemy:attack_punch_floor()
    print('punch floor')
    enemy:restart()
end

function enemy:attack_poison_gaz()
    print('todo when enemy:attack_custom will be available in the engine')
    enemy:restart()
end

function enemy:attack_invoke_lizalfos()
    enemy:stop_movement()
    sprite:set_animation("hands_up")
    
    enemy:restart()
end

function enemy:choose_attack()
    -- calculate distance from the hero to know what to do
    local hero = enemy:get_map():get_entity("hero")
    local distance = self:get_distance(hero)
    local next_attack_choosen = false
    
    if distance > 25 then
        if math.random(1, 2) == 1 then
            self:attack_thunder_blast()
            next_attack_choosen = true
        end
    elseif distance < 10 then
        if math.random(1, 2) == 1 then
            self:attack_punch_floor()
            next_attack_choosen = true
        end
    end
    
    if not next_attack_choosen then
        if math.random(1, 2) == 1 then
            self:attack_poison_gaz()
        else
            self:attack_invoke_lizalfos()
        end
    end
end

function enemy:on_created()

    self:set_life(20)
    self:set_damage(24)
    sprite = self:create_sprite("enemies/gigas")
    self:set_size(64, 64)
    self:set_origin(37, 57)
    
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
    local m = sol.movement.create("path_finding")
    m:set_speed(48)
    m:start(self)
    
    sol.timer.start(self, math.random(2000, 5000), function()
        self:choose_attack()
    end)
end

function enemy:on_movement_changed(movement)
    
end


local enemy = ...

-- Wiznake : a snake using magic.

enemy:set_life(16)
enemy:set_damage(12)
enemy:set_hurt_style("normal")
enemy:set_size(16, 16)
enemy:set_origin(8, 13)
enemy:set_attack_consequence("explosion", "ignored")
local sprite = enemy:create_sprite("enemies/wiznake")

function enemy:on_restarted()
    self:go_random()
end

function enemy:on_movement_finished(movement)
    self:go_random()
end

function enemy:on_obstacle_reached(movement)
    self:go_random()
end

function enemy:go_random()

    -- Random diagonal direction.
    local rand4 = math.random(4)
    local direction8 = rand4 * 2 - 1
    local angle = direction8 * math.pi / 4
    local m = sol.movement.create("straight")
    m:set_speed(48)
    m:set_angle(angle)
    m:set_max_distance(24 + math.random(96))
    m:start(self)
    
    sprite:set_direction(rand4 - 1)
    
    sol.timer.stop_all(self)
    sol.timer.start(self, 500 + math.random(1500), function()
        local mult_x = (rand4 == 2 or rand4 == 3) and -1 or 1
        local mult_y = (rand4 == 1 or rand4 == 2) and -1 or 1
        local enemy_x, enemy_y, enemy_layer = self:get_position()
        sprite:set_animation("bite")
        
        for i = 1, 5 do
            local explo_x = enemy_x + (24 * i * mult_x)
            local explo_y = enemy_y + (24 * i * mult_y)
            
            sol.timer.start(self, 100*i, function()
                self:get_map():create_explosion({layer=enemy_layer, x=explo_x, y=explo_y})
            end)
        end
    end)
end

function sprite:on_animation_finished(animation)
    if animation == "bite" then
        self:set_animation("walking")
    end
end


local enemy = ...
local from_direction = nil
local last_x, last_y -- used to know where will be the last part of the strike
local origin_x, origin_y -- used to know where the enemy origin is
local hero_x, hero_y -- used to know where was the hero when the enemy was created
local distance_max -- used to know what distance max should be done by the strikes
local aSprites = {}

function print_aSprites()
    for i, anim in pairs(aSprites) do
        print("Anim ", i, anim.sprite:get_animation(), origin_x, origin_y, anim.x, anim.y, origin_x+anim.x, origin_y+anim.y)
    end
end

function enemy:new_strike()
    local direction = enemy:get_direction8_to(hero_x, hero_y)
    local animation = 'direction'
    
    -- Calculation of the next animation
    if from_direction == nil then
        from_direction = math.random(0, 7)
    end
    
    local rand_direction = math.random(direction-1, direction+1)
    
    while rand_direction == from_direction or rand_direction < 0 do
        rand_direction = math.random(direction-1, direction+1)
    end
    
    if rand_direction == 8 then
        rand_direction = 0
    end
    
    print(rand_direction, direction, from_direction)
    if rand_direction < from_direction then
        animation = animation .. rand_direction .. from_direction
    else
        animation = animation .. from_direction .. rand_direction
    end
    
    --local sprite_anim = enemy:create_sprite("enemies/thunder_strike")
    --sprite_anim:set_animation(animation)
    --aSprites[#aSprites+1] = {
    --    sprite = sprite_anim,
    --    x = last_x,
    --    y = last_y
    --}
    --print_aSprites()
    local sprite = enemy:create_sprite("enemies/thunder_strike")
    print(animation)
    sprite:set_animation(animation)
    sprite:set_frame(enemy:get_sprite():get_frame())
    sprite:set_xy(last_x, last_y)
    
    from_direction = rand_direction - 4
    if from_direction < 0 then
        from_direction = from_direction + 8
    end
    
    -- Calculation of x and y position for the new sprite
    if rand_direction > 0 and rand_direction < 4 then
        print(rand_direction..' -> last_y - 16')
        last_y = last_y - 16
    elseif rand_direction > 4 and rand_direction <= 7 then
        print(rand_direction..' -> last_y + 16')
        last_y = last_y + 16
    end
    
    if rand_direction < 2 or rand_direction == 7 then
        print(rand_direction..' -> last_x + 16')
        last_x = last_x + 16
    elseif rand_direction > 2 and rand_direction < 6 then
        print(rand_direction..' -> last_x - 16')
        last_x = last_x - 16
    end
    
    print(last_x, last_y)
    
    --sol.timer.start(enemy, 64, function()
        local enemy_x, enemy_y = enemy:get_position()
        local distance = enemy:get_distance(enemy_x+last_x, enemy_y+last_y)
        print("distance : ", distance)
        if distance < distance_max and not enemy:test_obstacles(last_x, last_y) then
            print('new strike')
            enemy:new_strike()
        else
            print('remove')
            sol.timer.start(enemy, 500, function()
                enemy:remove()
            end)
        end
    --end)
end

function enemy:on_created()
    enemy:set_life(1)
    enemy:set_damage(40)
    enemy:set_size(16, 16)
    enemy:set_origin(8, 8)
    enemy:set_invincible()
end

function enemy:on_restarted()
    local hero = enemy:get_map():get_entity('hero')
    last_x, last_y = 0, 0
    origin_x, origin_y = enemy:get_position()
    print('origin : ', last_x, last_y)
    hero_x, hero_y = hero:get_position()
    print('hero : ', hero_x, hero_y)
    distance_max = hero:get_distance(enemy)
    enemy:new_strike()
end

--function enemy:on_post_draw()
--    for i, anim in pairs(aSprites) do
--        --print("Post draw ", i, origin_x, origin_y, anim.x, anim.y)
--        self:get_map():draw_sprite(anim.sprite, anim.x, anim.y)
--    end
--end

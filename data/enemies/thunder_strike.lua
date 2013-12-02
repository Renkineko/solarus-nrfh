local enemy = ...
local from_direction = nil
local last_x
local last_y
local aSprites = {}

function enemy:new_strike()
    local hero = enemy:get_map():get_entity('hero')
    local direction = enemy:get_direction8_to(hero)
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
    
    -- Calculation of x and y position for the new sprite
    if rand_direction > 0 and rand_direction < 4 then
        print(rand_direction..' -> last_x - 16')
        last_x = last_x - 16
    elseif rand_direction > 4 and rand_direction <= 7 then
        print(rand_direction..' -> last_x + 16')
        last_x = last_x + 16
    end
    
    if rand_direction < 2 or rand_direction == 7 then
        print(rand_direction..' -> last_y + 16')
        last_y = last_y + 16
    elseif rand_direction > 2 and rand_direction < 6 then
        print(rand_direction..' -> last_y - 16')
        last_y = last_y - 16
    end
    print(last_x, last_y)
    
    local sprite_anim = enemy:create_sprite("enemies/thunder_strike")
    sprite_anim:set_animation(animation)
    aSprites[#aSprites] = {
        sprite = sprite_anim,
        x = last_x,
        y = last_y
    }
    --local sprite = enemy:create_sprite("enemies/thunder_strike")
    --print(animation)
    --sprite:set_animation(animation)
    --sprite:set_xy(last_x, last_y)
    
    from_direction = rand_direction - 4
    if from_direction < 0 then
        from_direction = from_direction + 8
    end
    print(from_direction)
    
    sol.timer.start(1500, function()
        print("end timer", hero:get_distance(last_x, last_y))
        if hero:get_distance(last_x, last_y) > 16 then
            print('new strike')
            enemy:new_strike()
        else
            print('remove')
            enemy:remove()
        end
    end)
end

function enemy:on_created()
    enemy:set_life(1)
    enemy:set_damage(4)
    enemy:set_size(16, 16)
    enemy:set_origin(8, 8)
    enemy:set_invincible()
    
    last_x, last_y = enemy:get_position()
    print(last_x, last_y)
    enemy:new_strike()
end

function enemy:on_post_draw()
    for i, anim in pairs(aSprites) do
        self:get_map():draw_sprite(anim.sprite, anim.x, anim.y)
    end
end
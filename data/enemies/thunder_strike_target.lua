local enemy = ...
local aSplits = {
    {lowest = 1, middle = 3, highest = 6},
    {lowest = 0, middle = 3, highest = 5},
    {lowest = 1, middle = 4, highest = 7},
    {lowest = 2, middle = 5, highest = 7}
}
local aStrikes = {}

function getNextProp(pnRandDir)
    -- The from_direction of the next sprite will always be at the opposite of the direction lastly set.
    -- If the direction is negative, not possible, with a +8 we go to a valid direction.
    local nFromDir = pnRandDir - 4
    local x = 0
    local y = 0
    if nFromDir < 0 then
        nFromDir = nFromDir + 8
    end
    
    -- Calculation of x and y position for the new sprite
    if pnRandDir > 0 and pnRandDir < 4 then
        --print(rand_direction..' -> next_y - 16')
        y = -16
    elseif pnRandDir > 4 and pnRandDir <= 7 then
        --print(rand_direction..' -> next_y + 16')
        y = 16
    end
    
    if pnRandDir < 2 or pnRandDir == 7 then
        --print(rand_direction..' -> next_x + 16')
        x = 16
    elseif pnRandDir > 2 and pnRandDir < 6 then
        --print(rand_direction..' -> next_x - 16')
        x = -16
    end
    
    return nFromDir, x, y
end

function enemy:new_strike()
    local bNewStrike = true    
    for i = 1, #aStrikes do
        local oStrike = aStrikes[i]
        oStrike.step = oStrike.step + 1
        local direction = enemy:get_direction8_to(oStrike.hero_x, oStrike.hero_y)
        local animation = 'direction'
        local lowestdir, highestdir
        
        -- Calculation of the next animation
        if oStrike.from_direction == nil then
            oStrike.from_direction = math.random(0, 7)
        end
        
        local rand_direction = math.random(direction-1, direction+1)
        
        -- Specific case of the direction near the east one (0)
        if rand_direction == 8 then
            rand_direction = 0
        elseif rand_direction == -1 then
            rand_direction = 7
        end
        
        -- If rand_direction == from_direction in the case of the hero being on the other side of the new strike,
        -- we can't do a real 80 turn : no animation can do that. So we have to get a random direction with a step
        -- of 1 to go to the hero position.
        while rand_direction == oStrike.from_direction do
            rand_direction = math.random(direction-1, direction+1)
            
            -- Specific case of the direction near the east one (0)
            if rand_direction == 8 then
                rand_direction = 0
            elseif rand_direction == -1 then
                rand_direction = 7
            end
        end
        
        
        --print(rand_direction, direction, from_direction)
        if rand_direction < oStrike.from_direction then
            animation = animation .. rand_direction .. oStrike.from_direction
            lowestdir = rand_direction
            highestdir = oStrike.from_direction
        else
            animation = animation .. oStrike.from_direction .. rand_direction
            lowestdir = oStrike.from_direction
            highestdir = rand_direction
        end
        
        --print(lowestdir, highestdir)
        -- We allow only 4 splits, and each step increase the possibility of the split
        if #aStrikes < 4 and math.random(1, 100) < 10*oStrike.step then
            
            for j = 1, #aSplits do
                if lowestdir == aSplits[j].lowest and (highestdir == aSplits[j].middle or highestdir == aSplits[j].highest) then
                    animation = 'direction' .. aSplits[j].lowest .. aSplits[j].middle .. aSplits[j].highest
                    
                    local split_dir
                    if oStrike.from_direction == aSplits[j].lowest then
                        split_dir = aSplits[j].highest
                        rand_direction = aSplits[j].middle
                    elseif oStrike.from_direction == aSplits[j].middle then
                        split_dir = aSplits[j].lowest
                        rand_direction = aSplits[j].highest
                    else
                        split_dir = aSplits[j].lowest
                        rand_direction = aSplits[j].middle
                    end
                    
                    local splitFromDir, splitX, splitY = getNextProp(split_dir)

                    oStrike.step = 0

                    aStrikes[#aStrikes+1] = {
                        from_direction = splitFromDir,
                        step = 0,
                        next_x = oStrike.next_x + splitX, -- used to know where will be the next part of the strike
                        next_y = oStrike.next_y + splitY,
                        origin_x = oStrike.origin_x, -- used to know where the enemy origin is
                        origin_y = oStrike.origin_y,
                        hero_x = oStrike.hero_x, -- used to know where was the hero when the enemy was created
                        hero_y = oStrike.hero_y,
                        distance_max = oStrike.distance_max -- used to know what distance max should be done by the strikes
                    }
                end
            end
        end
        
        local sprite = enemy:create_sprite("enemies/thunder_strike")
        --print(animation)
        sprite:set_animation(animation)
        sprite:set_frame(enemy:get_sprite():get_frame())
        sprite:set_xy(oStrike.next_x, oStrike.next_y)
        
        --print(next_x, next_y)
        local from_dir, nextx, nexty = getNextProp(rand_direction)
        print(from_dir, nextx, nexty)
        oStrike.from_direction = from_dir
        oStrike.next_x = oStrike.next_x + nextx
        oStrike.next_y = oStrike.next_y + nexty
        
        local enemy_x, enemy_y = enemy:get_position()
        local distance = enemy:get_distance(enemy_x+ oStrike.next_x, enemy_y+ oStrike.next_y)
        --print("distance : ", distance)
        if distance > oStrike.distance_max or enemy:test_obstacles(oStrike.next_x, oStrike.next_y) then
            bNewStrike = false
        end
    end

    -- if all strikes are ok to continue, we continue, but if only one must stop, we stop all of them...
    if bNewStrike then
        enemy:new_strike()
    else
        sol.timer.start(enemy, 500, function()
            enemy:remove()
        end)
    end
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
    origin_x, origin_y = enemy:get_position()
    hero_x, hero_y = hero:get_position()
    
    aStrikes[1] = {
        from_direction = nil, 
        step = 0,
        next_x = 0, -- used to know where will be the next part of the strike
        next_y = 0,
        origin_x = origin_x, -- used to know where the enemy origin is
        origin_y = origin_y,
        hero_x = hero_x, -- used to know where was the hero when the enemy was created
        hero_y = hero_y,
        distance_max = hero:get_distance(enemy) -- used to know what distance max should be done by the strikes
    }
    
    enemy:new_strike()
end

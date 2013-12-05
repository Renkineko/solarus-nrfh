local enemy = ...
local aSprites = {
    { x = 0, y = 0, anim = 'direction04' },
    { x = -16, y = 0, anim = 'direction04' },
    { x = -32, y = 0, anim = 'direction05' },
    { x = -48, y = 16, anim = 'direction15' },
    { x = -64, y = 32, anim = 'direction16' },
    { x = -64, y = 48, anim = 'direction26' },
    { x = -64, y = 64, anim = 'direction26' },
    { x = -64, y = 80, anim = 'direction27' },
    { x = -48, y = 96, anim = 'direction37' },
    { x = -32, y = 112, anim = 'direction03' },
    { x = -16, y = 112, anim = 'direction04' },
    { x = 0, y = 112, anim = 'direction04' },
    { x = 16, y = 112, anim = 'direction04' },
    { x = 32, y = 112, anim = 'direction14' },
    { x = 48, y = 96, anim = 'direction15' },
    { x = 64, y = 80, anim = 'direction25' },
    { x = 64, y = 64, anim = 'direction26' },
    { x = 64, y = 48, anim = 'direction26' },
    { x = 64, y = 32, anim = 'direction36' },
    { x = 48, y = 16, anim = 'direction37' },
    { x = 32, y = 0, anim = 'direction47' },
    { x = 16, y = 0, anim = 'direction04' },
}

function enemy:generate_circle()
    for i, spr in ipairs(aSprites) do
        sol.timer.start(enemy, 100*i, function()
            local sprite = enemy:create_sprite('enemies/thunder_strike')
            sprite:set_animation(spr.anim)
            sprite:set_xy(spr.x, spr.y)
            enemy:set_invincible_sprite(sprite)
            if i ~= 1 then
                sprite:set_frame(enemy:get_sprite():get_frame())
            end
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
    enemy:generate_circle()
    
    --sol.timer.start(enemy, 2000, function() enemy:remove() end)
end

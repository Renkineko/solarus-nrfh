local enemy = ...

function enemy:on_created()
    enemy:set_life(1)
    enemy:set_damage(4)
    enemy:set_size(16, 16)
    enemy:set_origin(8, 8)
    enemy:set_invincible()
    
    local sprite = enemy:create_sprite('enemies/poison_gaz')
    sprite:set_animation('poping')
    function sprite:on_animation_finished()
        enemy:remove()
    end
end
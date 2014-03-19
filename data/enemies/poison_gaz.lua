local enemy = ...
local iteration_poison = 0
local max_iteration_poison = 10

function enemy:on_created()
    enemy:set_life(1)
    enemy:set_damage(0)
    enemy:set_size(16, 16)
    enemy:set_origin(8, 8)
    enemy:set_invincible()
    
    local sprite = enemy:create_sprite('enemies/poison_gaz')
    sprite:set_animation('poping')
    sol.audio.play_sound('bubble_pop')
    function sprite:on_animation_finished()
        enemy:remove()
    end
end

function enemy:on_attacking_hero(hero)
    -- if the hero is not already poisoned and he is not frozen (because in the case of frozen, a poison GAZ can't access thru you)
    if not hero:is_physical_condition_active("poison") and not hero:is_physical_condition_active("frozen") and enemy:get_distance(hero) < 10 then
        hero:start_poison(2, 5000, 5)
    end
end
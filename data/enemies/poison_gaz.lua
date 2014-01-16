local enemy = ...
local iteration_poison = 0
local max_iteration_poison = 10

local function do_poison()
    local hero = enemy:get_map():get_entity("hero")
    iteration_poison = iteration_poison + 1
    if iteration_poison <= max_iteration_poison then
        sol.audio.play_sound("hero_hurt")
        enemy:get_game():remove_life(1)
        sol.timer.start(hero, 1000, do_poison)
    else
        iteration_poison = 0
        hero.physical_condition["poison"] = false
    end
end

function enemy:on_created()
    enemy:set_life(1)
    enemy:set_damage(0)
    enemy:set_size(16, 16)
    enemy:set_origin(8, 8)
    enemy:set_invincible()
    
    local sprite = enemy:create_sprite('enemies/poison_gaz')
    sprite:set_animation('poping')
    function sprite:on_animation_finished()
        enemy:remove()
    end
end

function enemy:on_attacking_hero()
    local hero = enemy:get_map():get_entity("hero")
    if not hero:is_physical_condition_active("poison") then
        hero:start_poison(2, 5000, 5)
    end
end
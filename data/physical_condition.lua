local game = ...
local hero = game:get_hero()
local timers = {
    poison = nil,
    slow = nil,
    confusion = nil,
}

function game:initialize_physical_condition()
    hero.physical_condition = {
        poison = false,
        slow = false,
        confusion = false
    }
end

function hero.set_physical_condition(hero, physical_condition, active)
    hero.physical_condition[physical_condition] = active
end

function hero.is_physical_condition_active(hero, physical_condition)
    return hero.physical_condition[physical_condition]
end

function hero.start_poison(hero, delay, damage, max_iteration)
    if hero:is_physical_condition_active('poison') then
        timers['poison']:stop()
    end
    
    local iteration_poison = 0
    function do_poison()
        iteration_poison = iteration_poison + 1
        if iteration_poison <= max_iteration then
            sol.audio.play_sound("hero_hurt")
            enemy:get_game():remove_life(damage)
            timers['poison'] = sol.timer.start(hero, delay, do_poison)
        else
            hero:set_physical_condition('poison', false)
        end
    end
    
    hero:set_physical_condition('poison', true)
    do_poison()
end
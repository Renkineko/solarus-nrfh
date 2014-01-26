local physical_condition_manager = {}

physical_condition_manager.timers = {
    poison = nil,
    slow = nil,
    confusion = nil,
}

function physical_condition_manager:initialize(game)
    local hero = game:get_hero()
    hero.physical_condition = {
        poison = false,
        slow = false,
        confusion = false
    }

    function hero:set_physical_condition(physical_condition, active)
        hero.physical_condition[physical_condition] = active
    end
    
    function hero:is_physical_condition_active(physical_condition)
        return hero.physical_condition[physical_condition]
    end
    
    function hero:start_poison(damage, delay, max_iteration)
        if hero:is_physical_condition_active('poison') and physical_condition_manager.timers['poison'] ~= nil then
            physical_condition_manager.timers['poison']:stop()
        end
        
        local iteration_poison = 0
        function do_poison()
            if hero:is_physical_condition_active("poison") and iteration_poison < max_iteration then
                sol.audio.play_sound("hero_hurt")
                game:remove_life(damage)
                iteration_poison = iteration_poison + 1
            end
            
            if iteration_poison == max_iteration then
                hero:set_physical_condition('poison', false)
            else
                physical_condition_manager.timers['poison'] = sol.timer.start(hero, delay, do_poison)
            end
        end
        
        hero:set_physical_condition('poison', true)
        do_poison()
    end
    
    function hero:stop_slow()
        if hero:is_physical_condition_active('slow') and physical_condition_manager.timers['slow'] ~= nil then
            physical_condition_manager.timers['slow']:stop()
        end
        
        hero:set_physical_condition('slow', false)
        hero:set_walking_speed(88)
    end
    
    function hero:start_slow(delay)
        if hero:is_physical_condition_active('slow') and physical_condition_manager.timers['slow'] ~= nil then
            physical_condition_manager.timers['slow']:stop()
        end
        
        hero:set_physical_condition('slow', true)
        hero:set_walking_speed(48)
        physical_condition_manager.timers['slow'] = sol.timer.start(hero, delay, function()
            hero:stop_slow()
        end)
    end
end

return physical_condition_manager
local physical_condition_manager = {}
local in_command_pressed = false
local in_command_release = false

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
    
    function hero:is_physical_condition_active(physical_condition)
        return hero.physical_condition[physical_condition]
    end

    function hero:set_physical_condition(physical_condition, active)
        hero.physical_condition[physical_condition] = active
    end
    
    function game:on_command_pressed(command)
        
        if not hero:is_physical_condition_active('confusion') or in_command_pressed or game:is_paused() then
            print("not confused")
            return false
        end
        
        in_command_pressed = true
        if command == "left" then
            print("go to right instead of left")
            game:simulate_command_pressed("right")
        elseif command == "right" then
            print("go to left instead of right")
            game:simulate_command_pressed("left")
        elseif command == "up" then
            print("go down instead of up")
            game:simulate_command_pressed("down")
        elseif command == "down" then
            print("go up instead of down")
            game:simulate_command_pressed("up")
        end
        
        in_command_pressed = false
    end
    
    function game:on_command_released(command)
        
        if not hero:is_physical_condition_active('confusion') or not in_command_release or game:is_paused() then
            print("not confused")
            return false
        end
        
        in_command_release = true
        if command == "left" then
            print("stop to right instead of left")
            game:on_command_released("right")
        elseif command == "right" then
            print("stop to left instead of right")
            game:on_command_released("left")
        elseif command == "up" then
            print("stop down instead of up")
            game:on_command_released("down")
        elseif command == "down" then
            print("stop up instead of down")
            game:on_command_released("up")
        end
        
        in_command_release = false
    end
        
    function hero:start_confusion(delay)
        if hero:is_physical_condition_active('confusion') and physical_condition_manager.timers['confusion'] ~= nil then
            physical_condition_manager.timers['confusion']:stop()
        end
        
        hero:set_physical_condition('confusion', true)
        
        physical_condition_manager.timers['confusion'] = sol.timer.start(hero, delay, function()
            hero:stop_confusion()
        end)
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
    
    function hero:stop_confusion()
        if hero:is_physical_condition_active('confusion') and physical_condition_manager.timers['confusion'] ~= nil then
            physical_condition_manager.timers['confusion']:stop()
        end
        
        hero:set_physical_condition('confusion', false)
    end
    
    function hero:stop_slow()
        if hero:is_physical_condition_active('slow') and physical_condition_manager.timers['slow'] ~= nil then
            physical_condition_manager.timers['slow']:stop()
        end
        
        hero:set_physical_condition('slow', false)
        hero:set_walking_speed(88)
    end
end

return physical_condition_manager
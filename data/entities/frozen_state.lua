local custent = ...
local hero = custent:get_map():get_entity('hero')
local sprite

function custent:on_created()
    local hero_x, hero_y, hero_l = hero:get_position()
    local hero_size_width, hero_size_height = hero:get_size()
    
    custent:set_position(hero_x, hero_y, hero_l)
    custent:set_size(hero_size_width, hero_size_height)
    custent:set_origin(8, 8)
    custent:set_drawn_in_y_order(true)
    
    sprite = custent:create_sprite("custent/frozen_state")
    
    sprite:set_animation('freezing')
    sol.audio.play_sound('frozen_state_freezing')
    function sprite:on_animation_finished()
        sprite:set_animation('frozen')
    end
    
    custent:add_collision_test('sprite', function(me, collider, custent_sprite, collider_sprite)
        if collider:get_type() == 'enemy' and collider:get_damage() > 0 then
            hero:start_hurt(collider, collider_sprite, collider:get_damage())
            me:clear_collision_tests()
        end
    end)
    
    hero:freeze()
end

function custent:melt()
    
    sprite:set_animation('melting')
    sol.audio.play_sound('frozen_state_melting')
    function sprite:on_animation_finished()
        custent:remove()
        hero:unfreeze()
    end
end

function custent:shatter()
    sprite:set_animation('shattering')
    sol.audio.play_sound('frozen_state_shattering')
    function sprite:on_animation_finished()
        custent:remove()
        hero:unfreeze()
    end
end
local custent = ...
local hero = custent:get_map():get_entity('hero')
--local sprite -- uncomment this to fix the bug

function custent:on_created()
    local hero_x, hero_y, hero_l = hero:get_position()
    local hero_size_width, hero_size_height = hero:get_size()
    
    custent:set_position(hero_x, hero_y, hero_l)
    custent:set_size(hero_size_width, hero_size_height)
    custent:set_origin(8, 8)
    custent:set_drawn_in_y_order(true)
    custent:set_traversable_by('enemy', true)
    
    -- remove the local to fix the bug
    local sprite = custent:create_sprite("custent/frozen_state")
    
    sprite:set_animation('freeze')
    function sprite:on_animation_finished()
        sprite:set_animation('frozen')
    end
    
    custent:add_collision_test('sprite', function(me, collider, custent_sprite, collider_sprite)
        if collider:get_type() == 'enemy' then
            
        end
    end)
    
    hero:freeze()
end

function custent:melt()
    
    sprite:set_animation('melt')
    function sprite:on_animation_finished()
        custent:remove()
        hero:unfreeze()
    end
end

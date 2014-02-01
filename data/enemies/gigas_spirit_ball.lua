local enemy = ...
local speed = {
    min = 48,
    max = 88
}
local move

function enemy:random_move()
    move = sol.movement.create("straight")
    move:set_angle(math.rad(math.random(0, 359)))
    move:set_max_distance(math.random(20, 50))
    function move:on_finished()
        enemy:restart()
    end
    
    function move:on_obstacle_reached()
        enemy:restart()
    end
end

function enemy:target_move()
    move = sol.movement.create("target")
    local hero = enemy:get_map():get_entity("hero")
    local pos_x, pos_y = hero:get_position()
    
    if math.random(1, 100) < 50 then
        pos_x = pos_x - math.random(0,32)
    else
        pos_x = pos_x + math.random(0,32)
    end
    
    if math.random(1, 100) < 50 then
        pos_y = pos_y - math.random(0,32)
    else
        pos_y = pos_y + math.random(0,32)
    end
    
    move:set_target(pos_x, pos_y)
    function move:on_finished()
        enemy:restart()
    end
end

function enemy:on_created()
    enemy:set_life(1000000)
    enemy:set_invincible()
    enemy:set_can_hurt_hero_running(true)
    enemy:create_sprite("enemies/gigas_spirit_ball")
    --self:set_obstacle_behavior("flying")
    enemy:set_layer_independent_collisions()
    enemy:set_size(8, 8)
    enemy:set_origin(4, 4)
    
end

function enemy:on_restarted()
    
    -- 33% chance to go to the hero instead of randomly going in the piece
    if math.random(1, 3) == 1 then
        enemy:target_move()
    else
        enemy:random_move()
    end
    move:set_speed(math.random(speed.min, speed.max))
    move:start(enemy)
end

function enemy:go_to_position(pos_x, pos_y)
    enemy:stop_movement()
    local distance = enemy:get_distance(pos_x, pos_y)
    move = sol.movement.create("target")
    move:set_target(pos_x, pos_y)
    move:set_ignore_obstacles(true)
    move:set_speed(distance/2)
    move:start(enemy)
end

function enemy:disappear()
    enemy:set_enabled(false)
    enemy:set_position(-100, -100)
end

function enemy:appear(pos_x, pos_y)
    enemy:set_position(pos_x, pos_y)
    enemy:set_enabled(true)
end

-- Gigas Spirit have a specific attack which drain magic.
function enemy:on_attacking_hero(hero)
  local game = enemy:get_game()
  
  -- In any case, we do the hurt animation as usual
  hero:start_hurt(enemy, 4)
  
  -- If hero has magic, it is drained.
  if game:get_magic() > 0 then
    game:remove_magic(10)
    --sol.audio.play_sound("magic_bar")
  end
end

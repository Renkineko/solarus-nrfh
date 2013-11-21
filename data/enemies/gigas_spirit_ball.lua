local enemy = ...

function enemy:on_created()
    enemy:set_life(1000000)
    enemy:set_damage(4)
    enemy:set_magic_damage(10)
    enemy:set_invincible()
    enemy:create_sprite("enemies/gigas")
    enemy:set_animation("spirit_ball")
    enemy:set_size(8, 8)
    enemy:set_origin(4, 4)
end

function enemy:on_restarted()
    local move = sol.movement.create("random")
    move:set_speed(128)
    move:start(enemy)
end

function enemy:go_to_position(pos_x, pos_y)
    enemy:stop(movement)
    local distance = enemy:get_distance(pos_x, pos_y)
    local move = sol.movement.create("target")
    move:set_target(pos_x, pos_y)
    move:set_ignore_obstacles(true)
    move:set_speed(distance/2)
    move:start(enemy)
end

function enemy:disappear()
    enemy:set_enable(false)
    enemy:set_position(-100, -100)
end

function enemy:appear(pos_x, pos_y)
    enemy:set_position(pos_x, pos_y)
    enemy:set_enable(true)
end

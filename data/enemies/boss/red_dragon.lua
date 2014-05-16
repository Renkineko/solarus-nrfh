local enemy = ...

-- Red Dragon : boss of the hidden palazzo, from Secret of Mana. Code from gelidrak.

local head = nil
local head_ball_sprite = nil
local head_vulnerable = false
local tail = nil
local big_tail_ball_sprite = nil
local small_tail_ball_sprite = nil
local initial_xy = {}
local current_xy = {}

function enemy:on_created()
    
    enemy:set_life(20)
    enemy:set_damage(32)
    enemy:create_sprite("enemies/boss/red_dragon")
    enemy:set_size(160, 120)
    enemy:set_origin(80, 80)
    enemy:set_obstacle_behavior("flying")
    enemy:set_layer_independent_collisions(true)
    enemy:set_push_hero_on_sword(true)
    
    enemy:set_invincible()
    enemy:set_attack_consequence("sword", "protected")
    enemy:set_attack_consequence("hookshot", "protected")
    enemy:set_attack_consequence("boomerang", "protected")
    enemy:set_attack_consequence("arrow", "protected")
    enemy:set_pushed_back_when_hurt(false)
    
    -- Create the head.
    local my_name = enemy:get_name()
    head = enemy:create_enemy{
        breed = "boss/red_dragon_head",
        x = 8,
        y = -16,
    }
    head_ball_sprite = sol.sprite.create("enemies/boss/red_dragon")
    head_ball_sprite:set_animation("head_ball")
    
    -- Create the tail.
    local my_name = enemy:get_name()
    tail = enemy:create_enemy{
        breed = "boss/red_dragon_tail",
        x = 0,
        y = 56,
    }
    big_tail_ball_sprite = sol.sprite.create("enemies/boss/red_dragon")
    big_tail_ball_sprite:set_animation("big_tail_ball")
    small_tail_ball_sprite = sol.sprite.create("enemies/boss/red_dragon")
    small_tail_ball_sprite:set_animation("small_tail_ball")
    
    initial_xy.x, initial_xy.y = enemy:get_position()
end

function enemy:on_restarted()
    
    local sprite = enemy:get_sprite()
    local m = sol.movement.create("random")
    m:set_speed(32)
    m:start(enemy)
    current_xy.x, current_xy.y = enemy:get_position()
end

function enemy:on_pre_draw()
    if tail:exists() then
        local x, y = enemy:get_position()
        local tail_x, tail_y = tail:get_position()
        y = y + 8
        local part_1_x = (tail_x - x) / 2
        local part_1_y = (tail_y - y) / 2
        -- print(x, y, part_1_x, part_1_y, tail_x, tail_y)
        enemy:display_balls(big_tail_ball_sprite, 3, x, y, x+part_1_x, y+part_1_y)
        enemy:display_balls(small_tail_ball_sprite, 3, x+part_1_x, y+part_1_y, tail_x, tail_y)
    end
end

function enemy:on_post_draw()

    if head:exists() then
        local x, y = enemy:get_position()
        local head_x, head_y = head:get_position()
        enemy:display_balls(head_ball_sprite, 2, x, y-24, head_x, head_y)
        head:bring_to_front()
    end
end

-- x1, y1 : position where you have to go from
-- x2, y2 : position where the "destination" is
function enemy:display_balls(ball_sprite, nb_balls, x1, y1, x2, y2)

  local x = x1
  local y = y1
  local x_inc = (x2 - x1) / (nb_balls - 1)
  local y_inc = (y2 - y1) / (nb_balls - 1)
  for i = 1, nb_balls do
    enemy:get_map():draw_sprite(ball_sprite, x, y)
    x = x + x_inc
    y = y + y_inc
  end
end

function enemy:on_position_changed(x, y)

  -- The body has just moved: do the same movement to the head and the tail.
  local dx = x - current_xy.x
  local dy = y - current_xy.y
  local tail_x, tail_y = tail:get_position()
  tail:set_position(tail_x + dx, tail_y + dy)
  local head_x, head_y = head:get_position()
  head:set_position(head_x + dx, head_y + dy)
  current_xy.x, current_xy.y = x, y
end

function enemy:on_hurt()

  head:hurt(1)
  tail:hurt(1)
  head_ball_sprite:set_animation("head_ball_hurt")
  tail_ball_sprite:set_animation("big_tail_ball_hurt")
  tail_ball_sprite:set_animation("small_tail_ball_hurt")
end

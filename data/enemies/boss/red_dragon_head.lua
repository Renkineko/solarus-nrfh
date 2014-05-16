local enemy = ...

function enemy:on_created()
    
    enemy:set_life(150000)
    enemy:set_damage(32)
    enemy:create_sprite("enemies/boss/red_dragon_head")
    enemy:set_size(160, 120)
    enemy:set_origin(80, 80)
    enemy:set_obstacle_behavior("flying")
    enemy:set_layer_independent_collisions(true)
    enemy:set_push_hero_on_sword(true)
    
end
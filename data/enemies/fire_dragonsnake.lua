local enemy = ...

-- fire_dragonsnake: enemy trying to find a way to the hero

local positions_body = {}
local body_enemies = {
    big_ball_1 = nil,
    big_ball_2 = nil,
    big_ball_3 = nil,
    ball_1 = nil,
    ball_2 = nil,
    small_ball_1 = nil,
    small_ball_2 = nil
}
local head = nil

function enemy:get_ref_sprite()
    return head
end

local function immobilize_children()
    for key, mob in pairs(body_enemies) do
        if mob ~= nil and mob:exists() then
            mob:immobilize()
        end
    end
end

local function create_ball(sprite, enemy_source, enemy_to_follow, invincible, speed, n)
    local mob = enemy:create_enemy({
        name = n,
        breed = "settable_snake_ball",
        x = -8,
        y = -8
    })
    
    mob:set_properties({
        sprite = sprite,
        enemy_source = enemy_source,
        enemy_to_follow = enemy_to_follow,
        invincible = invincible,
        speed = speed
    })
    
    function mob:on_restarted()
        mob:new_movement()
    end
    
    return mob
end

function enemy:check_children()
    if not body_enemies.big_ball_2:exists()
    and not body_enemies.big_ball_3:exists()
    and not body_enemies.ball_2:exists()
    and not body_enemies.small_ball_2:exists() then
        enemy:set_attack_consequence("sword", 1)
    end
end

function enemy:on_created()
    self:set_life(8)
    self:set_damage(20)
    head = self:create_sprite("enemies/fire_dragonsnake")
    self:set_size(16, 16)
    self:set_origin(8, 13)
    self:set_pushed_back_when_hurt(false)
    
    -- While the enemy has body destructable, it's invincible but can be immobilized
    self:set_invincible()
    self:set_attack_consequence("hookshot", "immobilized")
    self:set_attack_consequence("boomerang", "immobilized")
    
    body_enemies.big_ball_1 = create_ball("enemies/fire_dragonsnake_bigball", self, self, true, 72, "B1")
    body_enemies.big_ball_2 = create_ball("enemies/fire_dragonsnake_bigball", self, body_enemies.big_ball_1, false, 72, "B2")
    body_enemies.big_ball_3 = create_ball("enemies/fire_dragonsnake_bigball", self, body_enemies.big_ball_2, false, 72, "B3")
    body_enemies.ball_1 = create_ball("enemies/fire_dragonsnake_ball", self, body_enemies.big_ball_3, true, 80, "N1")
    body_enemies.ball_2 = create_ball("enemies/fire_dragonsnake_ball", self, body_enemies.ball_1, false, 80, "N2")
    body_enemies.small_ball_1 = create_ball("enemies/fire_dragonsnake_smallball", self, body_enemies.ball_2, true, 88, "S1")
    body_enemies.small_ball_2 = create_ball("enemies/fire_dragonsnake_smallball", self, body_enemies.small_ball_1, false, 88, "S2")

end

function enemy:on_restarted()
    local m = sol.movement.create("target")
    m:set_speed(64)
    m:start(self)
end

function enemy:on_movement_changed(movement)
    local sprite = self:get_sprite()
    local hero = self:get_map():get_entity("hero")
    local direction8 = enemy:get_direction8_to(hero)
    sprite:set_direction(direction8)
end

-- Immobilize children too
function enemy:on_immobilized()
    immobilize_children()
end

function enemy:on_dying()
    for i, mob in pairs(body_enemies) do
        if mob:exists() then
            mob:set_life(0)
        end
    end
end

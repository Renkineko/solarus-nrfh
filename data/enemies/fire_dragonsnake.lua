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

local function angle_to_direction8(angle)
	direction8 = (angle + (math.pi / 8)) * 4 / math.pi
	return (math.floor(direction8) + 8) % 8
end

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

local function create_ball(name, sprite, enemy_source, enemy_to_follow, invincible, speed)

	mob = enemy:create_enemy(name, "settable_snake_ball", -8, -8)

	mob:set_properties({
		sprite = sprite,
		enemy_source = enemy_source,
		enemy_to_follow = enemy_to_follow,
		invincible = invincible,
		speed = speed
	})

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

	-- While the enemy has body destructable, it's invincible but can be immobilized
	self:set_invincible()
	self:set_attack_consequence("hookshot", "custom")
	self:set_attack_consequence("boomerang", "custom")

	local child_prefix_name = self:get_name() .. "_son_"

	body_enemies.big_ball_1 = create_ball(child_prefix_name .. "big1", "enemies/fire_dragonsnake_bigball", self, self, true, 72)
	body_enemies.big_ball_2 = create_ball(child_prefix_name .. "big2", "enemies/fire_dragonsnake_bigball", self, body_enemies.big_ball_1, false, 72)
	body_enemies.big_ball_3 = create_ball(child_prefix_name .. "big3", "enemies/fire_dragonsnake_bigball", self, body_enemies.big_ball_2, false, 72)
	body_enemies.ball_1 = create_ball(child_prefix_name .. "basic1", "enemies/fire_dragonsnake_ball", self, body_enemies.big_ball_3, true, 80)
	body_enemies.ball_2 = create_ball(child_prefix_name .. "basic2", "enemies/fire_dragonsnake_ball", self, body_enemies.ball_1, false, 80)
	body_enemies.small_ball_1 = create_ball(child_prefix_name .. "small1", "enemies/fire_dragonsnake_smallball", self, body_enemies.ball_2, true, 88)
	body_enemies.small_ball_2 = create_ball(child_prefix_name .. "small2", "enemies/fire_dragonsnake_smallball", self, body_enemies.small_ball_1, false, 88)

end

function enemy:on_restarted()

	local m = sol.movement.create("target")
	m:set_speed(64)
	m:start(self)
end

function enemy:on_movement_changed(movement)

	local sprite = self:get_sprite()
	local hero = self:get_map():get_entity("hero")
	local angle_to_hero = movement:get_angle()

	local direction8 = angle_to_direction8(angle_to_hero)  -- get the closest direction between the 4 main directions
	sprite:set_direction(direction8)
end

function enemy:on_custom_attack_received(attack, sprite)
	if attack == "boomerang" or attack == "hookshot" then
		self:immobilize()
	end
end

function enemy:immobilize()
	local sprite = self:get_sprite()
	sol.timer.stop_all(enemy)
	sprite:set_animation("immobilized")
	self:stop_movement()
    self:set_can_attack(false)
	immobilize_children()

	sol.timer.start(enemy, 5000, function()
		sprite:set_animation("shaking")
		sol.timer.start(enemy, 2000, function()
			sprite:set_animation("walking")
			self:on_restarted()
			self:set_can_attack(true)
		end)
	end)
end

function enemy:on_dying()
	for i, mob in pairs(body_enemies) do
		if mob:exists() then
			-- DIE YOU F**ING MORON... T_T
			mob:set_life(0)
		end
	end
end

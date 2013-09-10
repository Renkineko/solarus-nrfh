local enemy = ...

-- Ball of the dragonsnake.

-- The parent MUST HAVE an "immobilize" function.

local properties = {}
local move = nil


function enemy:new_movement()

	local start_the_move = false
	--local x, y = properties.enemy_to_follow:get_position()

	-- If the enemy wasn't moving, we create the movement
	if move == nil then
		move = sol.movement.create("target")
		move:set_speed(properties.speed)
		start_the_move = true

		local follow = properties.enemy_to_follow

		while not follow:exists() do
			follow = follow:get_enemy_to_follow()
		end

		move:set_target(follow)
		move:start(self)

		function move:on_finished()
			move = nil
		end
	end

	--move:set_max_distance(self:get_distance(properties.enemy_to_follow))
	--move:set_angle(move:get_angle(properties.enemy_to_follow))
	--move:set_target(x, y)


end

function enemy:get_enemy_to_follow()
	return properties.enemy_to_follow
end

function enemy:set_enemy_to_follow(enemy_resource)
	properties.enemy_to_follow = enemy_resource
end

function enemy:set_properties(prop)

	properties = prop

	-- set default values
	if properties.life == nil then
		properties.life = 1
	end
	if properties.damage == nil then
		properties.damage = 8
	end
	if properties.speed == nil then
		properties.speed = 64
	end
	if properties.invincible == nil then
		properties.invincible = false
	end
	if properties.immobilizable == nil then
		properties.immobilizable = true
	end

	-- Set the invincibility of the ball
	if not properties.invincible then
		self:set_attack_consequence("sword", 1)
	end

	-- Set the vulnerability of the ball to hookshot or boomerang
	if properties.immobilizable then
		self:set_attack_consequence("hookshot", "custom")
		self:set_attack_consequence("boomerang", "custom")
	end

	-- Set data
	self:set_life(properties.life)
	self:set_damage(properties.damage)
	self:create_sprite(properties.sprite)

	self:new_movement()

	function properties.enemy_to_follow:on_dead()
		if self.get_enemy_to_follow ~= nil then
			enemy:set_enemy_to_follow(self.get_enemy_to_follow())
			enemy:new_movement()
		end
	end

	self:get_sprite():synchronize(properties.enemy_source.get_ref_sprite())

end

function enemy:immobilize()
	local sprite = self:get_sprite()
	sol.timer.stop_all(enemy)
	sprite:set_animation("immobilized")
	self:stop_movement()
    self:set_can_attack(false)

	sol.timer.start(enemy, 5000, function()
		sprite:set_animation("shaking")
		sol.timer.start(enemy, 2000, function()
			sprite:set_animation("walking")
			self:new_movement()
			self:set_can_attack(true)
		end)
	end)
end

function enemy:on_created()

	self:set_pushed_back_when_hurt(false)
	self:set_size(16, 16)
	self:set_origin(8, 13)
	self:set_invincible()
end


function enemy:on_custom_attack_received(attack, sprite)
	if attack == "boomerang" or attack == "hookshot" then
		properties.enemy_source:immobilize()
	end
end

function enemy:on_dead()
	properties.enemy_source:check_children()
end

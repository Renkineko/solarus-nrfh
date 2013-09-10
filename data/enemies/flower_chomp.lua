local enemy = ...

-- Flower that try to chomp the hero when too close

local activation_distance = 80
local timer_sound = nil

local function angle_to_direction4(angle)
	direction4 = (angle + (math.pi / 4)) * 2 / math.pi
	return (math.floor(direction4) + 4) % 4

end

local function play_sound_attack()
	sol.audio.play_sound("bush")
	timer_sound = sol.timer.start(enemy, 1600, function() play_sound_attack() end)
end

function enemy:on_created()

	self:set_life(1)
	self:set_damage(12)
	self:create_sprite("enemies/flower_chomp")
	self:set_size(16, 16)
	self:set_origin(58, 58)
	self:set_can_hurt_hero_running(true)
	self:set_pushed_back_when_hurt(false)
	self:set_attack_consequence("arrow", "protected")
	self:set_attack_consequence("hookshot", "protected")
	self:set_attack_consequence("boomerang", "protected")

end

function enemy:on_update()

	-- Init
	local sprite = self:get_sprite()
	local hero = self:get_map():get_entity("hero")
	local animation_name = sprite:get_animation()

	-- The enemy must face the hero, always...
	local angle_to_hero = self:get_angle(hero)  -- get the angle between the monster and the hero
	local direction4 = angle_to_direction4(angle_to_hero)  -- get the closest direction between the 4 main directions
	sprite:set_direction(direction4)

	if (animation_name == "walking" or animation_name == "stopped") and self:get_distance(hero) <= 160 then
		-- Check whether the hero is close.
		local x, y = self:get_position()
		local hero_x, hero_y = hero:get_position()
		local dx, dy = hero_x - x, hero_y - y

		if math.abs(dy) < activation_distance or math.abs(dx) < activation_distance then

			play_sound_attack()
			sprite:set_animation("attack")
		end
	elseif animation_name == "attack" and self:get_distance(hero) > 160 then
		sprite:set_animation("stopped")
		timer_sound:stop()
	end
end

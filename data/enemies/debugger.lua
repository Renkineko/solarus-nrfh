local enemy = ...
local generation_iteration = 0

-- Script of an enemy making engine crash when map is reloaded while another enemy has been summoned by it.

function enemy:on_restarted()
    print('Wait a little...')
    -- if you want to test after you killed the enemy...
    sol.timer.start(enemy, 2500, function()
        local tentacle = enemy:create_enemy({breed = 'tentacle', x = -20, y = -20})
        print('You can now load the game with F[1-3] key or quit the map')
        function tentacle:on_removed()
	    --if enemy:exists() then
                print('If you reload the game or quit the map now, you will not have a crash...')
                enemy:restart()
	    --end
        end
    end)
    --enemy:mega_generation()
end

-- Generate a lot of enemy. Really a lot. Must be used only for test.
function enemy:mega_generation()
    generation_iteration = generation_iteration + 1
    if generation_iteration < 10 then
        local generate_breed = 'tentacle'
        for i = 1, 5 do
            enemy:create_enemy({breed = generate_breed, x = -8*i, y = -8})
        end
        for i = 1, 5 do
            enemy:create_enemy({breed = generate_breed, x = 8*i, y = -8})
        end 
        for i = 1, 5 do
            enemy:create_enemy({breed = generate_breed, x = -8*i, y = 8})
        end 
        for i = 1, 5 do
            enemy:create_enemy({breed = generate_breed, x = 8*i, y = 8})
        end 
        print("Generated enemies : 20 of "..generation_iteration*20)
        sol.timer.start(enemy, 100, function()  enemy:mega_generation() end)
    end
end

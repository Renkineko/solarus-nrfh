local enemy = ...

-- Script of an enemy making engine crash when map is reloaded while another enemy has been summoned by it.

function enemy:on_restarted()
    print('Wait a little...')
    -- if you want to test after you killed the enemy...
    sol.timer.start(enemy, 2500, function()
        local tentacle = enemy:create_enemy({breed = 'tentacle', x = -20, y = -20})
        print('You can now load the game with F[1-3] key or quit the map')
        function tentacle:on_removed()
            print('If you reload the game or quit the map now, you will not have a crash...')
            enemy:restart()
        end
    end)
end
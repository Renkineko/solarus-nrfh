local map = ...

local function check_thunder(name, x, y)
    if not map:has_entity(name) then
        map:create_enemy({breed="thunder_strike_target", x = x, y = y, name=name, layer=1, direction=0})
    else
        map:get_entity(name):new_strike()
    end
    
end

function switch_thunder_nw:on_activated()
    check_thunder("thunder_nw", 56, 56)
end
function switch_thunder_ne:on_activated()
    check_thunder("thunder_ne", 584, 56)
end
function switch_thunder_n:on_activated()
    check_thunder("thunder_n", 320, 56)
end
function switch_thunder_w:on_activated()
    check_thunder("thunder_w", 56, 320)
end
function switch_thunder_sw:on_activated()
    check_thunder("thunder_sw", 56, 584)
end
function switch_thunder_e:on_activated()
    check_thunder("thunder_e", 584, 320)
end
function switch_thunder_s:on_activated()
    check_thunder("thunder_s", 320, 584)
end
function switch_thunder_se:on_activated()
    check_thunder("thunder_se", 584, 584)
end

function switch_walk:on_activated()
    --hero:freeze()
    local m = sol.movement.create("straight")
    m:set_angle(0)
    m:set_speed(80)
    m:set_max_distance(120)
    
    m:start(hero)
end

function confusion_sensor:on_activated()
    hero:start_confusion(2500)
end
local item = ...

function item:on_created()

  self:set_can_disappear(true)
  self:set_brandish_when_picked(false)
end

-- Obtaining some apples
function item:on_obtaining(variant, savegame_variable)

    local apples_counter = self:get_game():get_item("apples_counter")
    local amounts = {1, 3}
    local amount = amounts[variant]
    
    if apples_counter:get_variant() == 0 then
      apples_counter:set_variant(1)
    end
    
    if amount == nil then
        amount = 1
    end
  
    apples_counter:add_amount(amount)
end
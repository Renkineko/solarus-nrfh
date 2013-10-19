local item = ...

function item:on_created()

  self:set_savegame_variable("item_fire_stones_counter")
  self:set_amount_savegame_variable("item_fire_stone")
  self:set_max_amount(3)
end


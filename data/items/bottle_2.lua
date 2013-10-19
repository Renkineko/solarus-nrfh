local item = ...

function item:on_created()
  self:set_assignable(true)
  self:set_savegame_variable("item_bottle2")
end

sol.main.load_file("items/bottle")(item)


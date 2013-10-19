local item = ...

function item:on_created()

  self:set_savegame_variable("item_level_4_way")
end

function item:on_variant_changed(variant)

  if variant == 4 then
    -- Tiger scrolls
    self:get_game():set_ability("sword_knowledge", 1)
  end
end


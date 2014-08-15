require_relative 'equipable_item'

class UsableItem < EquipableItem
  attr_reader :slot_type, :active_effects
end

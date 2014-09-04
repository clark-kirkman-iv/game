require 'classes/item'
require 'modules/effects'

class EquippableItem < Item
  
  # @effects is accessed through included methods in Effects
  include Effects
  
  attr_reader :slot
  #ck4, add arg checking for types/vaiues, like race.rb
  def initialize(name, item_class, weight, slot, effects = new_blank_effect_hash)
    super(name, item_class, weight)
    @slot = slot
    @effects = effects
  end
  
end

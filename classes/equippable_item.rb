require 'classes/item'
require 'modules/common_includes'

class EquippableItem < Item
  
  # @effects is accessed through included methods in Effects
  include Effects
  
  attr_reader :slot
  
  def initialize(name, item_class, weight, slot, effects: BLANK_EFFECT_HASH.clone)
    super(name, item_class, weight)
    @slot = slot
    @effects = effects
  end
  
end

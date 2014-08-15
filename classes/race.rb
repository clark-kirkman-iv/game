require 'modules/common_includes'

class Race
  
  # @effects is accessed through included methods in Effects
  include Effects
  
  attr_reader :name, :attributes, :health
  
  def initialize(name, attributes, item_slots, health, effects: BLANK_EFFECT_HASH.clone)
    @name = name
    @attributes = attributes
    @health = health
    @item_slots = item_slots
    @effects = effects
  end
  
end

require 'modules/effects'

class Race
  
  # @effects is accessed through included methods in Effects
  include Effects
  
  attr_reader :name, :attributes, :health, :body_parts
  
  # add sanitization/err check of args
  def initialize(name, attributes, body_parts, health, effects: BLANK_EFFECT_HASH.clone)
    @name = name
    @attributes = attributes
    @health = health
    @body_parts = body_parts
    @effects = effects
  end
  
end

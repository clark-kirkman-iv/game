# This file contains module Effects and related structures.
# This module is intended to be included into classes that
# will contain Effect objects.  e.g.,
# include Effects

BLANK_EFFECT_HASH = {
  :passive => {
    :self => [],
    :target => []
  },
  :active => {
    :self => [],
    :target => []
  }
}

# ck4, add failure tests that return InvalidEffectKey
class InvalidEffectKey < StandardError ; end

module Effects
  def get_effects(activation, apply_to, effect_category, effect_type=nil)
    if @effects.keys.include?(activation)
      res = @effects[activation]
    else
      raise InvalidEffectKey.new("Invalid activation: #{activation}")
    end
    if res.keys.include?(apply_to)
      res = res[apply_to]
    else
      raise InvalidEffectKey.new("Invalid apply_to: #{apply_to}")
    end
    res = res.select{ |effect| effect.category == effect_category }
    res = res.select{ |effect| effect.type == effect_type } if !effect_type.nil?
    return res
  end
  
  def each_effect(activation, apply_to, &block)
    if @effects.keys.include?(activation)
      res = @effects[activation]
    else
      raise InvalidEffectKey.new("Invalid activation: #{activation}")
    end
    if res.keys.include?(apply_to)
      res = res[apply_to]
    else
      raise InvalidEffectKey.new("Invalid apply_to: #{apply_to}")
    end
    return res.each{ |element| block.call(element) }
  end
end

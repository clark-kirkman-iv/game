require 'exceptions'
require 'modules/struct_bag'

# character attributes
AttributeStruct = Struct.new(:strength, :dexterity, :agility, :resilience, :endurance, :willpower, :cognition, :perception, :charisma)
class AttributeStruct ; extend StructBag ; end

# This defines the valid object types & their value ranges for an effect
EffectValueSpec = Struct.new(:klass, :min_value, :max_value)
class EffectValueSpec ; extend StructBag ; end

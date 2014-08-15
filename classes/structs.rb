module StructBag
  def new_from_hash(attribute_hash)
    begin
      bag = self.members.each_with_object(self.new){ |member, obj|
        obj.send(member.to_s+'=', attribute_hash.fetch(member))
      }
    rescue KeyError => e
      raise KeyError.new("Cannot instantiate a #{self} from given hash.  #{e.message}")
    end
    return bag
  end
end

AttributeStruct = Struct.new(:strength, :dexterity, :agility, :endurance, :resilience, :willpower, :cognition, :perception, :charisma)
class AttributeStruct
  extend StructBag
end

EffectStruct = Struct.new(:klass, :type, :value, :probability, :duration)
class EffectStruct
  extend StructBag
end




EffectValueSpec = Struct.new(:klass, :min_value, :max_value)
class Effect
  INSTANTANEOUS = nil
  ALWAYS = nil
  VALID_PROBABILITY = 0.01..1 #valid range
  VALID_DURATION = 1..Float::INFINITY
  VALID_VALUE_CLASSES = [Numeric, Range]
  VALID_INPUTS = self.load_definitions_file( File.join(YAML_LOAD_PATH, "effect_validation.yaml") )

  def self.load_definitions_file(filename)
    hash = YAML.load_file(filename)
    hash.each{ |category, category_hash|
      category_hash.each{ |type, type_array|
        # convert innermost hashes to EffectValueSpec objects
        category_hash[type] = type_array.map{ |h|
          evs = EffectValueSpec.members.each_with_object(EffectValueSpec.new){ |mem, obj| obj.send(mem.to_s+'=',h.fetch(mem)) }
          # now type check the inputs in the EffectValueSpec object
          raise "Effect specification klass must be one of: #{VALID_VALUE_CLASSES.join(", ")}" if !VALID_VALUE_CLASSES.include?(evs.klass)
          raise "Effect specification min value must be a Numeric." if !evs.min_value.is_a?(Numeric)
          raise "Effect specification max value must be a Numeric." if !evs.max_value.is_a?(Numeric)
          evs
        }
      }
    }
    return hash
  end
=begin
  { 
    :a_category => {
      :a_type => [
                  {:klass => AClass, :min_value => MINVAL, :max_value => MAXVAL}, #...
                 ]
      
    }
  }
=end
  def self.valid_categories ; return VALID_INPUTS.keys ; end
  def self.valid_types(category)
    begin
      types = VALID_INPUTS.fetch(category).keys
    rescue KeyError => e
      types = []
    end
    return types
  end
  
  def self.valid_value?(category, type, value)
    klass = value.class
    if VALID_VALUE_CLASSES.map{ |cl| value.is_a?(cl) }.include?(true) # generic check, not specific to category/type yet
      begin
        value_hashes = VALID_INPUTS.fetch(category).fetch(type)
      rescue KeyError => e
        value_hashes = []
      end
      # look for a hash that has the same class and where value's numeric "value" is within the valid range
      found = value_hashes.find{ |vhash|
        klass == vhash.fetch(:klass) &&
        ( (klass.is_a?(Numeric) && value >= vhash.fetch(:min_val) && value <= vhash.fetch(:max_val) ) ||
          (klass.is_a?(Range) && value.min >= vhash.fetch(:min_val) && value.max <= vhash.fetch(:max_val) && value.min <= value.max )
          )
      }
    else
      found = nil
    end
    valid = found ? true : false
    return valid
  end
  
  def self.valid_values(category, type)
    begin
      valid_value_hashes = VALID_INPUTS.fetch(:category).fetch(:type)
    rescue KeyError => e
      raise InvalidArg.new("category and type combination (#{category.inspect} ,#{type.inspect}) is invalid.")
    end
    return valid_value_hashes
  end
  
  def self.validate_inputs(category, type, value, probability, duration)
    if !valid_categories.include?(category) #ck4, define valid values in the appropriate file
      str = valid_categories.map{|c|c.inspect}.join(", ")
      raise InvalidArg.new("category must be one of: #{str}")
    end
    valid_types = valid_types(category) #ck4, define valid types for each category in the appropriate file
    if !valid_types.include?(type)
      str = valid_types.map{|c|c.inspect}.join(", ")
      raise InvalidArg.new("type in category #{category.inspect} must be one of: #{str}")
    end
    if !valid_value?(category, type, value)
      valid_value = valid_value(category, type)
      raise InvalidArg.new("value for category #{category.inspect}, type #{type.inspect} must satisfy one of: #{valid_values_str}")
    end
    if !probability.is_a?(Float) ||
        (probability != ALWAYS && (probability < VALID_PROBABILITY.min || probability > VALID_PROBABILITY.max))
        
        raise InvalidArg.new("probability must be Float, and #{VALID_PROBABILITY.min} <= p <= #{VALID_PROBABILITY.max} or ALWAYS: #{ALWAYS.inspect}.")
    end
    if !duration.is_a?(Integer) ||
        (duration != INSTANTANEOUS && (duration < VALID_DURATION.min || duration > VALID_DURATION.max))
      raise InvalidArg.new("duration must be Integer, and #{VALID_DURATION.min} <= d <= #{VALID_DURATION.max} or INSTANTANEOUS: #{INSTANTANEOUS.inspect} .")
    end
  end
  
  def initialize(category, type, value: nil, probability: nil, duration: nil)
    validate_inputs(category, type, value, probability, duration)
    @category = category
    @type = type
    @value = value
    @probability = probability
    @duration = duration
  end
  
  def new_from_hash(hash)
    raise InvalidArg.new("must provide a Hash object") if !hash.is_a?(Hash)
    new(hash.fetch(:category), hash.fetch(:type), value: hash.fetch(:value,nil),
        probability: hash.fetch(:probability, nil), duration: hash.fetch(:duration, nil))
  end
end

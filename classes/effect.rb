require 'classes/structs'
require 'exceptions'

class Effect
  # probability constants
  ALWAYS = -1 # also used for durations
  VALID_PROBABILITY = 0.01..1 #valid range
  
  # duration constants
  INSTANTANEOUS = -2
  VALID_DURATION = 1..Float::INFINITY
  
  VALID_VALUE_CLASSES = [Numeric, Range, NilClass]
  
  def self.load_definitions_file(filename)
    hash = YAML.load_file(filename)
    hash.each{ |category, category_hash|
      category_hash.each{ |type, type_array|
        # convert innermost hashes to EffectValueSpec objects
        category_hash[type] = type_array.map{ |h|
          evs = EffectValueSpec.new_from_hash(h)
          # now type check the inputs in the EffectValueSpec object
          if VALID_VALUE_CLASSES.select{ |vc| evs.klass.ancestors.include?(vc) }.empty?
            raise "Effect specification :klass must be one of: #{VALID_VALUE_CLASSES.join(", ")}"
          end
          
          # if evs.klass is NilClass, we don't care what the min/max values are.  They aren't used.
          if evs.klass != NilClass
            raise "Effect specification :min_value must be a Numeric." if !evs.min_value.is_a?(Numeric)
            raise "Effect specification :max_value must be a Numeric." if !evs.max_value.is_a?(Numeric)
          end
          evs
        }
      }
    }
    return hash
  end
  
  VALID_INPUTS = self.load_definitions_file( File.join(YAML_LOAD_PATH, "effect_validation.yaml") )
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
    if VALID_VALUE_CLASSES.select{ |vc| value.class.ancestors.include?(vc) }.empty?
      found = nil
    else
      begin
        value_hashes = VALID_INPUTS.fetch(category).fetch(type)
      rescue KeyError => e
        value_hashes = []
      end
      # look for a hash that has the same class and where value's numeric "value" is within the valid range
      found = value_hashes.find{ |vhash|
        klass == vhash.klass &&
        ( (klass.ancestors.include?(Numeric) && value >= vhash.min_value && value <= vhash.max_value ) ||
          (klass.ancestors.include?(Range) && value.min >= vhash.min_value && value.max <= vhash.max_value && value.min <= value.max) ||
          (klass.ancestors.include?(NilClass))
          )
      }
    end
    valid = found ? true : false
    return valid
  end
  
  # returns the Hashes that define valid value types/min/max for the given category & type
  # e.g., returns: [ {:klass => A, :min_value => B, :max_value => C}, ... ]
  def self.valid_values(category, type)
    begin
      valid_value_hashes = VALID_INPUTS.fetch(category).fetch(type)
    rescue KeyError => e
      raise InvalidArg.new("category and type combination (#{category.inspect} , #{type.inspect}) is invalid.")
    end
    return valid_value_hashes
  end
  
  def validate_inputs(category, type, value, probability, duration)
    if !self.class.valid_categories.include?(category)
      str = self.class.valid_categories.map{|c|c.inspect}.join(", ")
      raise InvalidArg.new("category must be one of: #{str}")
    end
    valid_types = self.class.valid_types(category)
    if !self.class.valid_types(category).include?(type)
      str = valid_types.map{|c|c.inspect}.join(", ")
      raise InvalidArg.new("type in category #{category.inspect} must be one of: #{str}")
    end
    if !self.class.valid_value?(category, type, value)
      valid_values_str = self.class.valid_values(category, type).join(", ")
      raise InvalidArg.new("value (#{value}) for category #{category.inspect}, type #{type.inspect} must satisfy one of: #{valid_values_str}")
    end
    
    if !(probability == ALWAYS || (probability.is_a?(Float) && (probability >= VALID_PROBABILITY.min && probability <= VALID_PROBABILITY.max)))
      raise InvalidArg.new("probability must be Float, and #{VALID_PROBABILITY.min} <= p <= #{VALID_PROBABILITY.max} or ALWAYS: #{ALWAYS.inspect}.")
    end
    
    if !(duration == INSTANTANEOUS || duration == ALWAYS ||
         (duration.is_a?(Fixnum) && (duration >= VALID_DURATION.min && duration <= VALID_DURATION.max)))
      raise InvalidArg.new("duration must be Fixnum, and #{VALID_DURATION.min} <= d <= #{VALID_DURATION.max} , INSTANTANEOUS: #{INSTANTANEOUS.inspect} , or ALWAYS: #{ALWAYS} .")
    end
  end
#  private :valid_values, :validate_inputs
  
  attr_reader :category, :type, :value, :probability, :duration
  
  def initialize(category, type, value: nil, probability: nil, duration: nil)
    validate_inputs(category, type, value, probability, duration)
    @category = category
    @type = type
    @value = value
    @probability = probability
    @duration = duration
  end
  
  def self.new_from_hash(hash)
    raise InvalidArg.new("must provide a Hash object") if !hash.is_a?(Hash)
    new(hash.fetch(:category), hash.fetch(:type), value: hash.fetch(:value, nil),
        probability: hash.fetch(:probability, nil), duration: hash.fetch(:duration, nil))
  end
end

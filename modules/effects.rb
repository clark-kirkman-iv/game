# This file contains module Effects and related structures.
# This module is intended to be included into classes that
# will contain Effect objects.  e.g.,
# include Effects

# ck4, convert to Struct? (both)
#BLANK_EFFECT_SUBHASH = { :self => [], :target => [] }
#BLANK_EFFECT_HASH = {
#  :passive => BLANK_EFFECT_SUBHASH.clone,
#  :active => BLANK_EFFECT_SUBHASH.clone
#}
def new_blank_effect_subhash
  return { :self => [], :target => [] }
end

def new_blank_effect_hash
  return  {
    :passive => new_blank_effect_subhash,
    :active => new_blank_effect_subhash
  }
end


# ck4, add failure tests that return InvalidEffectKey
class InvalidEffectKey < StandardError ; end

# @effects should be an Effect hash of the same structure as
module Effects
  def get_effects(activation, apply_to, effect_category: nil, effect_type: nil) #ck4, update tests and calling code to use these named args
    if @effects[activation]
      res = @effects[activation]
    else
      raise InvalidEffectKey.new("Invalid activation: #{activation.inspect}")
    end
    if res[apply_to]
      res = res[apply_to]
    else
      raise InvalidEffectKey.new("Invalid apply_to: #{apply_to.inspect}")
    end
    
    res = res.select{ |effect| effect.category == effect_category } if !effect_category.nil?
    res = res.select{ |effect| effect.type == effect_type } if !effect_type.nil?
    return res
  end
  
  def each_effect(activation, apply_to, &block)
    puts @effects.inspect
    if @effects[activation]
      res = @effects[activation]
    else
      raise InvalidEffectKey.new("Invalid activation: #{activation.inspect}")
    end
    if res[apply_to]
      res = res[apply_to]
    else
      raise InvalidEffectKey.new("Invalid apply_to: #{apply_to.inspect}")
    end
    return res.each{ |element| block.call(element) }
  end
end

# ck4, this is DEAD.  Do not use.  Will instead have a resolve_effects method somewhere
# that will resolve random ranges, whether effects apply, etc.
#
# an extension to collapse an Array of Effect objects
class Array
  def combine_effects
    raise "Can only combine Effect objects." if !(select{ |element| !element.is_a?(Effect) }.empty?)
    #ck4, copy in from character. THIS PORT IS INCOMPLETE.  NEEDS WORK TO REPRESENT THE NEW METHOD.
    raise "unimplemented"
    # group effects by category and type for summing by group
    effect_groups = group_by{ |effect| [effect.category, effect.type] }
    effect_groups.each{ |items, group|
      category = items[0] ; type = items[1]
      # 1. verify that all values are nil or all are not nil
      types = group.map{ |effect| !effect.value.nil? }.sort.uniq
      raise "Effects for category: #{category} type: #{type} contain nil and non-nil values." if types.length != 1
#      # 2. determine if each effect happens or not
#      group = group.select{ |effect| Random.rand < effect.probability }
      # 3. sum effects according to nil/non-nil status.
      if types.first # true, nil values
        # sum each duration subgroup separately (e.g., fire_duration_2 & fire_duration_4 are separate)
        subgroups = group.select{ |effect| effect.duration }
        subgroups.each{ |duration, subgroup|
          total = 0
          subgroup.each{ |effect|
            # resolve ranges to numeric as needed
            total += effect.value.is_a?(Range) ? Random.rand(effect.value.max-effect.value.min+1) + effect.value.min : effect.value 
          }
          totals << Effect.new(category, type, value: total, probability: 1.0, duration: duration)
        }
       else # false, not nil values
        # nothing; do not combine; make them be resisted/be resolved separately
      end
    }
    return totals
  end # def combine_effects
  
end

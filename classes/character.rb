require 'modules/effects'
require 'classes/race'
require 'classes/body_part'
require 'classes/structs'

class Character
  RANDOM_ATTRIBUTE_RANGE = 16
  # @effects is accessed through included methods in Effects
#  include Effects
  
  attr_reader :name, :race, :attributes, :health, :statuses, :body_parts
  
  # add sanitization/err check of args
  def initialize(name, race)
    # validate inputs here, ck4
    @name = name
    @race = race
    @body_parts = @race.body_parts.map{ |part| part.clone }
    @attributes = new_attributes # uses @race
    @health = @race.health
    @statuses = [] # none to start
  end
  
  def max_health
    return @race.health
  end
  
  # creates/sets @attributes by copying racial information
  # and applying a randomized modification to each
  # Currently adds -5 to 10 to each attribute
  def new_attributes
    attributes = @race.attributes.clone
    attributes.each_pair{ |member, value|
      attributes.send(member.to_s+"=", value + Random.rand(RANDOM_ATTRIBUTE_RANGE) - 5)
    }
    return attributes
  end
  private :new_attributes
  
  # get all active effects from active_item, race and all passive effects from all
  # equipped items and race.
  #
  # Returns: a Hash like: {:self => [Effect1, ...], :target => [Effect1, ...]}
  def action_effects(active_item, effect_category: nil, effect_type: nil)
    effects = new_blank_effect_subhash
    
    equipped_items = @body_parts.select{ |part| part.container? }.map{ |part|
      part.item
    }.compact # remove unequipped body parts
    
    # get self and target effects
    effects.keys.each{ |apply_to|
      # get active item effects
      effects[apply_to] += active_item.get_effects(:active, apply_to, effect_category: effect_category, effect_type: effect_type)
      
      # get equipped item passive effects
      equipped_items.each{ |item|
        effects[apply_to] += item.get_effects(:passive, apply_to, effect_category: effect_category, effect_type: effect_type)
      }
      
      # get racial passive effects (and active, for now at least, ck4)
      effects[apply_to] += @race.get_effects(:active, apply_to, effect_category: effect_category, effect_type: effect_type) #ck4, should this be here?  Or should active race effects be activatable separately?
      effects[apply_to] += @race.get_effects(:passive, apply_to, effect_category: effect_category, effect_type: effect_type)
    }
    
    return effects
  end
  
  def find_body_part_by_name(body_part_name)
    body_parts = @body_parts.select{ |bp| bp.name == body_part_name }
    raise "There should only be one body part named #{body_part_name} for character: #{@name} race: #{@race}, but there are #{body_parts.length} ." if body_parts.length > 1
    raise "No body parts with name #{body_part_name} found." if body_parts.empty?
    return body_parts.first
  end
  
  def equipped_items
    return @body_parts.select{ |bp| bp.container? }.map{ |bp| bp.item }.compact
  end
  
  def equip(body_part_name, item)
    find_body_part_by_name(body_part_name).equip(item)
  end
  
  def unequip(body_part_name)
    find_body_part_by_name(body_part_name).unequip
  end
  
  def clone
    char = self.class.new(@name, @race)
    char.instance_variable_set(:@body_parts, @body_parts.map{ |part| part.clone } )
    char.instance_variable_set(:@attributes, @attributes.clone)
    char.instance_variable_set(:@health, @health)
    char.instance_variable_set(:@statuses, @statuses.clone) #ck4, this may need updating, depending on if this clone needs manual writing.
    return char
  end
  
  # checks value equivalence to another Character object
  def ==(other)
    return false if other.class != self.class
    if @name != other.name ||
        @race != other.race ||
        @health != other.health ||
        @attributes != other.attributes ||
        @body_parts.length != other.body_parts.length ||
        @body_parts.each_with_index{|bp,i| bp == other.body_parts[i]}.include?(false) ||
        @statuses.length != other.statuses.length ||
        @statuses.each_with_index{|bp,i| bp == other.statuses[i]}.include?(false) #CK4, this and the prior line may not be ready for prime time
      return false
    end
    return true
  end
  
end

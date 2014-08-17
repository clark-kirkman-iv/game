require 'exceptions'
require 'classes/injury'

class BodyPart
  
  VALID_PARTS = YAML.load_file( File.join(YAML_LOAD_PATH, "body_parts.yaml") )
  
  attr_reader :type, :name, :container, :item, :injury # container denotes if the body part can hold an item
  
  # injury arg is a Numeric duration
  def initialize(type, name, container: true, injury: 0)
    raise InvalidArg.new("type must be one of: #{VALID_PARTS.map{|p|p.inspect}.join(", ")}") if !VALID_PARTS.include?(type)
    raise InvalidArg.new("name must be a String") if !name.is_a?(String)
    raise InvalidArg.new("container must be true or false") if ![true, false].include?(container)
    raise InvalidArg.new("injury must be an injury duration (Integer)") if injury && !injury.is_a?(Integer)
    
    @type = type
    @name = name
    @container = container
    @injury = Injury.new(injury)
  end
  
  def injured?
    return @injury.duration > 0
  end
  
  def injure(duration)
    @injury.injure(duration)
  end
  
  def forward_time
    @injury.forward_time
  end
  
  def equip(item)
    raise "a non-container body part cannot equip an item." if !@container
    raise InvalidArg.new("item must be an EquippableItem") if item && !item.is_a?(EquippableItem)
    if item.slot != @type
      raise InvalidArg.new("item slot (#{item.slot.inspect}) must match body part type (#{@type.inspect}) when equipping.")
    end
    @item = item
  end
  
  def unequip
    raise "a non-container body part cannot unequip an item." if !@container
    @item = nil
  end
  
  # despite the initializer having optional args, all are required when creating from
  # a Hash.
  def self.new_from_hash(hash)
    raise InvalidArg.new("must provide a Hash object") if !hash.is_a?(Hash)
    new(hash.fetch(:type), hash.fetch(:name), hash.fetch(:container), hash.fetch(:injury))
  end
end

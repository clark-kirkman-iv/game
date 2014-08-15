require 'exceptions'

class BodyPart
  
  VALID_PARTS = YAML.load_file( File.join(YAML_LOAD_PATH, "body_parts.yaml") )
  
  attr_reader :type, :name, :container, :item, :injury # container denotes if the body part can hold an item
  
  # injury arg is a Numeric duration
  def initialize(type, name, container: true, item: nil, injury: 0)
    raise InvalidArg.new("type must be one of: #{VALID_PARTS.map{|p|p.inspect}.join(", ")}") if !VALID_PARTS.include?(type)
    raise InvalidArg.new("name must be a String") if !name.is_a?(String)
    raise InvalidArg.new("container must be true or false") if ![true, false].include?(container)
    raise InvalidArg.new("A body part that is not a container cannot be passed an item to hold.") if !container && item
    raise InvalidArg.new("item must be an EquippableItem") if item && !item.is_a?(EquippableItem)
    raise InvalidArg.new("injury must be an Injury") if injury && !injury.is_a?(Injury)
    
    @type = type #ck4, type check type & validate value.  Define valid types in some config file.
    @name = name
    @container = container
    @item = item
    @injury = Injury.new(injury)
  end
  
  def injured?
    return @injury.duration > 0
  end
  
  def injure(duration)
    @injury.injure(duration)
  end
  
  def forward_time
    if @injury
      @injury.forward_time
      @injury = nil if @injury.duration == 0
    end
  end
  
  def equip(item)
    raise InvalidArg.new("item must be an EquippableItem") if item && !item.is_a?(EquippableItem)
    raise "a non-container body part cannot equip an item." if !@container
    if item.slot != @type
      raise InvalidArg.new("item slot (#{item.slot.inspect}) must match body part type (#{@type.inspect}) when equipping.")
    end
    @item = item
  end
  
  def unequip
    raise "a non-container body part cannot unequip an item." if !@container
    @item = nil
  end
  
end

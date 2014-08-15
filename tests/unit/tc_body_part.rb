require_relative '../../environment'
require 'minitest/spec'
require 'minitest/autorun'
require 'classes/injury'

describe EquippableItem do
  before do
    @type = :hand
    @name = "Left hand"
    @container = true
    @item = EquippableItem.new("Sword", :sword, 4, :hand)
    @injury = 0
    @body_part = BodyPart.new(@type, @name, container: @container, item: @item, injury: @injury)
  end
  
  it "should report basic information properly" do
    [:type, :name, :container, :item].each{ |sym|
      value = @item.send(sym)
      assert_equal(instance_variable_get("@"+sym.to_s), @item.send(sym), "instance member has incorrect value: @#{sym.to_s} : #{value}")
    }
    sym = :injury
    assert_equal(@injury, @body_part.injury.duration, "instance member has incorrect value: @#{sym.to_s} : #{value}")
  end
  
  # various positive and negative tests
  it "should validate args properly" do
    raise "unimplemented"
  end
  
  it "should report injury status properly" do
    raise "unimplemented"
  end
  
  it "should injure properly" do
    raise "unimplemented"
  end
  
  it "should update injuries in forward_time properly" do
    raise "unimplemented"
  end
  
  # include negative equip checks (wrong item slot, etc)
  it "should equip and unequip items properly" do
    raise "unimplemented"
  end
  
end

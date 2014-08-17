require_relative '../../environment'
require 'minitest/spec'
require 'minitest/autorun'
require 'classes/body_part'
require 'classes/equippable_item'

describe BodyPart do
  before do
    @type = :hand
    @name = "Left hand"
    @container = true
    @item = EquippableItem.new("Sword", :sword, 4, :hand)
    @injury = 0
    @body_part = BodyPart.new(@type, @name, container: @container, injury: @injury)
  end
  
  it "should report basic information properly" do
    @body_part.equip(@item)
    [:type, :name, :container, :item].each{ |sym|
      value = @body_part.send(sym)
      assert_equal(instance_variable_get("@"+sym.to_s), @body_part.send(sym), "instance member has incorrect value: @#{sym.to_s} : #{value}")
    }
    sym = :injury
    assert_equal(@injury, @body_part.injury.duration, "instance member has incorrect value: @#{sym.to_s} : #{@injury}")
  end
  
  # various positive and negative tests
  it "should validate args properly" do
    # success
    BodyPart.new(@type, @name, container: @container, injury: @injury)
    BodyPart.new(@type, @name, container: @container)
    BodyPart.new(@type, @name, injury: @injury)
    BodyPart.new(@type, @name)
    
    # failure
    assert_raises(InvalidArg){ BodyPart.new(:notatype, @name)  }
    assert_raises(InvalidArg){ BodyPart.new(:hand, notaname=[]) }
    assert_raises(InvalidArg){ BodyPart.new(@type, @name, container: "Invalid") }
    assert_raises(InvalidArg){ BodyPart.new(@type, @name, container: @container, injury: 14.2) }
    assert_raises(InvalidArg){ BodyPart.new(@type, @name, container: @container, injury: "notainjury") }
  end
  
  it "should report injury status properly" do
    assert_equal(false, @body_part.injured?)
  end
  
  it "should injure properly" do
    @body_part.injure(5)
    assert_equal(5, @body_part.injury.duration)
    @body_part.injure(10)
    assert_equal(15, @body_part.injury.duration)    
  end
  
  it "should update injuries in forward_time properly" do
    @body_part.injure(10)
    @body_part.forward_time
    assert_equal(9, @body_part.injury.duration)
  end
  
  # include negative equip checks (wrong item slot, etc)
  it "should equip and unequip items properly" do
    # successful test
    @body_part.equip(@item)
    assert_equal(@item, @body_part.item)
    @body_part.unequip
    assert_equal(nil, @body_part.item)
    
    # failure cases
    # container tests
    assert_raises(InvalidArg){ @body_part.equip("this is not an EquippableItem") }
    head_item = EquippableItem.new("Cap", :helmet, 1, :head)
    assert_raises(InvalidArg){ @body_part.equip(head_item) }# wrong slot type; expects :handw
    
    # non-container tests
    non_container_body_part = BodyPart.new(:head, "Head", container: false, injury: @injury)
    assert_raises(RuntimeError){ non_container_body_part.equip(head_item) }
    assert_raises(RuntimeError){ non_container_body_part.unequip }
  end
  
end
#ck4, add tests for new_from_hash

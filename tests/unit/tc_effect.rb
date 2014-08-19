require_relative '../../environment'
require 'minitest/spec'
require 'minitest/autorun'
require 'classes/effect'

describe Effect do
  before do
    @category = :skill
    @type = :identify_item
    @value = 5
    @probability = Effect::ALWAYS
    @duration = Effect::ALWAYS
    @effect = Effect.new(@category, @type, value: @value, probability: @probability, duration: @duration)
  end
  
  it "should report basic information properly" do
    [:category, :type, :value, :probability, :duration].each{ |sym|
      value = @effect.send(sym)
      assert_equal(instance_variable_get("@"+sym.to_s), value, "instance member has incorrect value: @#{sym.to_s} : #{value}")
    }
  end
  
  # many positive, negative tests
  it "should validate inputs properly" do
    # working cases, assert no raise
    #  - cross product of {always,valid float value}x{instantaneous, always, valid duration int value}
    Effect.new(@category, @type, value: @value, probability: @probability, duration: @duration) # just in case...
    [Effect::ALWAYS, 0.1].each{ |probability|
      [Effect::INSTANTANEOUS, Effect::ALWAYS, 2].each{ |duration|
        Effect.new(@category, @type, value: @value, probability: probability, duration: duration)
      }
    }
    # invalid category
    assert_raises(InvalidArg){ Effect.new(:notacategory, @type, value: @value, probability: @probability, duration: @duration) }
    # invalid type
    assert_raises(InvalidArg){ Effect.new(@category, :notatype, value: @value, probability: @probability, duration: @duration) }
    # invalid value - out of range - 1 to 100
    assert_raises(InvalidArg){ Effect.new(@category, @type, value: -14, probability: @probability, duration: @duration) }
    assert_raises(InvalidArg){ Effect.new(@category, @type, value: 1000000, probability: @probability, duration: @duration) }
    # invalid value - wrong class of thing - expects Fixnum
    assert_raises(InvalidArg){ Effect.new(@category, @type, value: 1..2, probability: @probability, duration: @duration) }
    assert_raises(InvalidArg){ Effect.new(@category, @type, value: "stringisbad", probability: @probability, duration: @duration) }
    assert_raises(InvalidArg){ Effect.new(@category, @type, value: 7.1, probability: @probability, duration: @duration) }
    # invalid probability - not a Float
    assert_raises(InvalidArg){ Effect.new(@category, @type, value: @value, probability: "notafloat", duration: @duration) }
    assert_raises(InvalidArg){ Effect.new(@category, @type, value: @value, probability: 1, duration: @duration) }
    # invalid probability - out of range 0.01 to 1.0
    assert_raises(InvalidArg){ Effect.new(@category, @type, value: @value, probability: 1.01, duration: @duration) }
    assert_raises(InvalidArg){ Effect.new(@category, @type, value: @value, probability: -0.01, duration: @duration) }
    # invalid duration - not a Fixnum
    assert_raises(InvalidArg){ Effect.new(@category, @type, value: @value, probability: @probability, duration: "notafixnum") }
    assert_raises(InvalidArg){ Effect.new(@category, @type, value: @value, probability: @probability, duration: 5..6) }
    assert_raises(InvalidArg){ Effect.new(@category, @type, value: @value, probability: @probability, duration: 1.1) }
    # invalid duration - out of range 1 to Infinity
    assert_raises(InvalidArg){ Effect.new(@category, @type, value: @value, probability: @probability, duration: -6) }
    
    #check case where we have a nil value, as in a non-numerical effect
    Effect.new(:damage, :stun, value: nil, probability: 0.1, duration: 5) # ok
    assert_raises(InvalidArg){ Effect.new(:damage, :stun, value: 5, probability: 0.1, duration: 5) } #value should not be allowed
  end
  #ck4, propagate ALWAYS/INSTANTANEOUS to all tests/classes
end

require_relative '../../environment'
require 'minitest/spec'
require 'minitest/autorun'
require 'classes/injury'

describe Injury do
  before do
    @duration = 1
    @injury = Injury.new(@duration)
  end
  
  it "should report basic information properly" do
    [:duration].each{ |sym|
      value = @injury.send(sym)
      assert_equal(instance_variable_get("@"+sym.to_s), value, "instance member has incorrect value: @#{sym.to_s} : #{value}")
    }
  end
  
  it "should initialize properly under normal circumstances" do
    injury = Injury.new(15)
    assert_equal(15, injury.duration)
  end
  
  it "should not allow initialization beyond 0 or max" do
    injury = Injury.new(-1)
    assert_equal(0, injury.duration)
    injury = Injury.new(Injury::MAX_DURATION+1)
    assert_equal(Injury::MAX_DURATION, injury.duration)
    assert_raises(InvalidArg){ Injury.new("thisisnotvalid") }
  end
  
  # test simple case.  test trying to forward an injury below duration 0
  it "should forward time properly" do
    assert_equal(1, @injury.duration)
    @injury.forward_time
    assert_equal(0, @injury.duration)
    @injury.forward_time
    assert_equal(0, @injury.duration) # no change when there is no injury
  end
  
  # injury total should never exceed MAX_DURATION
  it "should stack injuries properly" do
    assert_equal(1, @injury.duration)
    @injury.injure(10)
    assert_equal(11, @injury.duration)
    @injury.injure(Injury::MAX_DURATION)
    assert_equal(Injury::MAX_DURATION, @injury.duration)
  end
  
  # test all injuries from 0 to max; there should be no exceptions
  # test a specific value and compare to Injury::SEVERITY.fetch(provided_name), that num is within min/max
  it "should report severity properly" do
    assert_equal(1, @injury.duration)
    assert_equal("minor", @injury.severity)
    injury = Injury.new(0)
    Injury::MAX_DURATION.times{ |i|
     assert_equal(Injury::SEVERITY.select{|k,v| v.fetch(:low) <= injury.duration && injury.duration <= v.fetch(:high) }.keys.first,
                  injury.severity)
      injury.injure(1)
    }
  end
  
end

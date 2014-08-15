require_relative '../../environment'
require 'minitest/spec'
require 'minitest/autorun'
require 'classes/equippable_item'
require 'classes/structs'

describe EquippableItem do
  before do
    @name = "Mace"
    @item_class = :blunt_weapon
    @weight = 6
    @slot = :hand
    @effects = {
      :passive => {
        :self => [
                  EffectStruct.new_from_hash({ :class => :attribute, :type => :strength,
                                               :value => 2, :probability => nil, :duration => nil })
                 ],
        :target => [
                   ]
      },
      :active => {
        :self => [
                 ],
        :target => [
                    EffectStruct.new_from_hash({ :class => :damage, :type => :physical,
                                                 :value => 1..6, :probability => 1.0, :duration => nil }), #ck4, have an INSTANTANEOUS constant?
                    EffectStruct.new_from_hash({ :class => :damage, :type => :physical,
                                                 :value => 1..1, :probability => 0.1, :duration => 3 }),
                    EffectStruct.new_from_hash({ :class => :damage, :type => :stun,
                                                 :value => nil, :probability => 0.2, :duration => 1 })
                   ]
      }
    }
    @item = EquippableItem.new(@name, @item_class, @weight, @slot, effects: @effects)
  end
  
  it "should report basic information properly" do
    [:name, :weight, :item_class, :slot].each{ |sym|
      value = @item.send(sym)
      assert_equal(instance_variable_get("@"+sym.to_s), @item.send(sym), "instance member has incorrect value: @#{sym.to_s} : #{value}")
    }
  end
  
  it "should allow no effects" do
    item = EquippableItem.new(@name, @item_class, @weight, @slot)
  end
  
  # tests for effect-getting method
  # method param list should look like:
  # def get_effects(activation, apply_to, class, type=nil)
  it "should return the proper value for a requested effect" do
    # class and type specification
    effects = @item.get_effects(:active, :target, :damage, :physical)
    expected = @effects[:active][:target].select{ |es| es.class == :damage && es.type == :physical }
    assert_equal(2, expected.length)
    assert(expected.length, effects.length)
    expected.each{ |expected_item| assert(effects.include?(expected_item)) }
    
    # no type specification
    effects = @item.get_effects(:active, :target, :damage)
    expected = @effects[:active][:target].select{ |es| es.class == :damage }
    assert_equal(3, expected.length)
    assert(expected.length, effects.length)
    expected.each{ |expected_item| assert(effects.include?(expected_item)) }
    
    # no matches
    effects = @item.get_effects(:active, :target, :ice_cream)
    expected = @effects[:active][:target].select{ |es| es.class == :ice_cream }
    assert_equal(0, expected.length)
    assert(expected.length, effects.length)
  end
  
  it "should iterate over all effects properly" do
    total = 0
    last_effect_hash = -1
    [:active, :passive].each{ |activation|
      [:self, :target].each{ |apply_to|
        @item.each_effect(activation, apply_to){ |effect_hash| # make sure each returned effect is included
          assert(effect_hash != last_effect_hash) if last_effect_hash != -1 # check this after we've gotten one back
          assert(@effects[activation][apply_to].include?(effect_hash))
          total += 1
          last_effect_hash = effect_hash # to make sure we're getting different effect hashes, not just the same one
        }
      }
    }
    assert_equal(4, total) # make sure the correct number of effects were returned
  end
  
end

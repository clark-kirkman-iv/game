require_relative '../../environment'
require 'minitest/spec'
require 'minitest/autorun'
require 'classes/equippable_item'
require 'classes/effect'

describe EquippableItem do
  before do
    @name = "Mace"
    @item_class = :blunt_weapon
    @weight = 6
    @slot = :hand
    @effects = {
      :passive => {
        :self => [
                  Effect.new_from_hash({ :category => :attribute, :type => :strength,
                                               :value => 2, :probability => 1.0, :duration => Effect::FOREVER })
                 ],
        :target => [
                   ]
      },
      :active => {
        :self => [
                 ],
        :target => [
                    Effect.new_from_hash({ :category => :damage, :type => :physical,
                                                 :value => 1..6, :probability => 1.0, :duration => Effect::INSTANT }), #ck4, have an INSTANT constant?
                    Effect.new_from_hash({ :category => :damage, :type => :physical,
                                                 :value => 1..1, :probability => 0.1, :duration => 3 }),
                    Effect.new_from_hash({ :category => :damage, :type => :stun,
                                                 :value => nil, :probability => 0.2, :duration => 1 })
                   ]
      }
    }
    @item = EquippableItem.new(@name, @item_class, @weight, @slot, @effects)
  end
  
  it "should report basic information properly" do
    [:name, :weight, :item_class, :slot].each{ |sym|
      value = @item.send(sym)
      assert_equal(instance_variable_get("@"+sym.to_s), value, "instance member has incorrect value: @#{sym.to_s} : #{value}")
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
    effects = @item.get_effects(:active, :target, effect_category: :damage, effect_type: :physical)
    expected = @effects[:active][:target].select{ |es| es.category == :damage && es.type == :physical }
    assert_equal(2, expected.length)
    assert_equal(expected.length, effects.length)
    expected.each{ |expected_item| assert(effects.include?(expected_item)) }
    
    # no type specification
    effects = @item.get_effects(:active, :target, effect_category: :damage)
    expected = @effects[:active][:target].select{ |es| es.category == :damage }
    assert_equal(3, expected.length)
    assert_equal(expected.length, effects.length)
    expected.each{ |expected_item| assert(effects.include?(expected_item)) }
    
    # no matches
    effects = @item.get_effects(:active, :target, effect_category: :ice_cream)
    expected = @effects[:active][:target].select{ |es| es.category == :ice_cream }
    assert_equal(0, expected.length)
    assert_equal(expected.length, effects.length)
  end
  
  it "should iterate over all effects properly" do
    total = 0
    last_effect_hash = nil
    [:active, :passive].each{ |activation|
      [:self, :target].each{ |apply_to|
        @item.each_effect(activation, apply_to){ |effect_hash| # make sure each returned effect is included
          assert(effect_hash != last_effect_hash) if !last_effect_hash.nil? # check this after we've gotten one back
          assert(@effects[activation][apply_to].include?(effect_hash))
          total += 1
          last_effect_hash = effect_hash # to make sure we're getting different effect hashes, not just the same one
        }
      }
    }
    assert_equal(4, total) # make sure the correct number of effects were returned
  end
  
end

require_relative '../../environment'
require 'minitest/spec'
require 'minitest/autorun'
require 'classes/race'
require 'classes/structs'

describe Race do
  before do
    @name = "Dwarf"
    attributes = {
      :strength => 30,
      :dexterity => 20,
      :agility => 20,
      :endurance => 30,
      :resilience => 30,
      :willpower => 25,
      :cognition => 25,
      :perception => 25,
      :charisma => 25
    }
    @attributes = AttributeStruct.new_from_hash(attributes)
################################################################################
    @health = 120
    @effects = {
      :passive => {
        :self => [
                  EffectStruct.new_from_hash({ :class => :resist, :type => :physical,
                                               :value => 0.2, :probability => nil, :duration => nil }),
                  EffectStruct.new_from_hash({ :class => :skill, :type => :identify_item,
                                               :value => 5, :probability => nil, :duration => nil }),
                  EffectStruct.new_from_hash({ :class => :skill, :type => :axe,
                                               :value => 10, :probability => nil, :duration => nil })
                 ],
        :target => [
                   ]
      },
      :active => {
        :self => [
                 ],
        :target => [
                   ]
      }
    }
    @item_slots = [ ItemSlot.new(:hand, "Left hand", nil),
                    ItemSlot.new(:hand, "Right hand", nil),
                    ItemSlot.new(:legs, "Legs", nil)
                  ]
    @race = Race.new(@name, @attributes, @item_slots, @health, effects: @effects)
  end
  
  it "should report basic information properly" do
    [:name, :attributes, :health, :item_slots].each{ |sym| #ck4, add in :skills here
      value = @race.send(sym)
      assert_equal(instance_variable_get("@"+sym.to_s), @race.send(sym), "instance member has incorrect value: @#{sym.to_s} : #{value}")
    }
  end
  
  it "should allow no passed in effects" do
    race = Race.new(@name, @attributes, @health)
  end
  
  # tests for effect-getting method
  it "should return the proper value for a requested effect" do
    effects = @race.get_effects(activation=:passive, apply_to=:self, effect_class=:resist, effect_type=:physical)
    expected = @effects[:passive][:self].select{ |es| es.class == :resist && es.type == :physical }
    assert_equal(1, expected.length)
    assert(expected.length, effects.length)
    expected.each{ |expected_item| assert(effects.include?(expected_item)) }
  end
  
  it "should iterate over all effects properly" do
    total = 0
    last_effect_hash = -1
    [:active, :passive].each{ |activation|
      [:self, :target].each{ |apply_to|
        @race.each_effect(activation, apply_to){ |effect_hash| # make sure each returned effect is included
          assert(effect_hash != last_effect_hash) if last_effect_hash != -1 # check this after we've gotten one back
          assert(@effects[activation][apply_to].include?(effect_hash))
          total += 1
          last_effect_hash = effect_hash # to make sure we're getting different effect hashes, not just the same one
        }
      }
    }
    assert_equal(3, total) # make sure the correct number of effects were returned
  end
  
end

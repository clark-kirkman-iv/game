require_relative '../../environment'
require 'minitest/spec'
require 'minitest/autorun'
require 'classes/character'
require 'classes/race'
require 'classes/body_part'
require 'classes/effect'
require 'modules/effects'
require 'classes/equippable_item'

describe Race do
  before do
    @race = Race::RACES.fetch("Dwarf")
    @name = "Bob"
    @char = Character.new(@name, @race)
    
    # create an item for testing
    effect_hash = new_blank_effect_hash
    effect_hash[:passive][:self] << Effect.new(:resist, :physical, value: 0.02, probability: 1.0, duration: Float::INFINITY)
    effect_hash[:passive][:self] << Effect.new(:resist, :stun, value: 0.01, probability: 0.1, duration: Float::INFINITY)
    effect_hash[:active][:target] << Effect.new(:damage, :physical, value: 1..1, probability: 1.0, duration: Effect::INSTANT)
    effect_hash[:active][:self] << Effect.new(:damage, :physical, value: 1..1, probability: 1.0, duration: Effect::INSTANT)
    
    @item = EquippableItem.new("Cap", :helmet, 1, :head, effect_hash)
  end
  
  it "should report basic information properly" do
    [:name, :race].each{ |sym|
      value = @char.send(sym)
      assert_equal(instance_variable_get("@"+sym.to_s), value, "instance member has incorrect value: @#{sym.to_s} : #{value}")
    }
    sym = :health ; value = @char.send(sym) # initial value is race default
    assert_equal(@race.health, value, "instance member has incorrect value: @#{sym.to_s} : #{value}")
    sym = :statuses ; value = @char.send(sym)
    assert_equal([], value, "instance member has incorrect value: @#{sym.to_s} : #{value}")
    sym = :body_parts ; value = @char.send(sym)
    assert_equal(@race.body_parts, value) #ck4, correct? use === ?
    # test starting attributes separately (below)
  end
  
  it "should properly report max health" do
    assert_equal(@race.health, @char.max_health)
  end
  
  # tests to make sure that all attributes are within -5to10 of the racial defaults
  # The test is done many times, since starting attributes are random.
  it "should generate valid attributes on instantiation" do
    100.times{ |iter|
      char = Character.new(@name, @race)
      char.attributes.each_pair{ |attr, test_val|
      reg_val = @race.attributes.send(attr.to_sym)
        if test_val < reg_val
          assert( (reg_val - test_val) <= 5 )
        else
          assert( (test_val - reg_val) <= 10 )
        end
      }
    }
  end
  
  it "should return the requested effects properly" do
    char = @char.clone
    
    # make and equip some items
    
    effect_hash = new_blank_effect_hash
    
    effect_hash[:passive][:self] << Effect.new(:resist, :physical, value: 0.02, probability: 1.0, duration: Float::INFINITY)
    effect_hash[:passive][:self] << Effect.new(:resist, :stun, value: 0.01, probability: 1.0, duration: Float::INFINITY)
    effect_hash[:active][:target] << Effect.new(:damage, :physical, value: 4..5, probability: 1.0, duration: Effect::INSTANT)
    effect_hash[:active][:self] << Effect.new(:damage, :physical, value: 1..1, probability: 1.0, duration: Effect::INSTANT)
    item1 = EquippableItem.new("Cap", :helmet, 1, :head, effect_hash)
    char.equip("Head", item1)
    
    effect_hash = new_blank_effect_hash
    effect_hash[:active][:target] << Effect.new(:damage, :physical, value: 10..12, probability: 1.0, duration: Effect::INSTANT)
    effect_hash[:active][:target] << Effect.new(:damage, :stun, value: nil, probability: 0.1, duration: Effect::INSTANT)
    item2 = EquippableItem.new("Mace", :mace, 1, :hand, effect_hash)
    char.equip("Left hand", item2)
    
    # test with active item #1 (+ race) (actives from active item + race, passives from all equipped items + race)
    effects = char.action_effects(item1)
    assert_equal([:self, :target], effects.keys.sort)
    activation = :active
    [:self, :target].each{ |apply_to|
      item1.each_effect(activation, apply_to){ |effect|
        puts "item1 checking ... #{effect.inspect}"
        assert_equal(1, effects[apply_to].select{ |e| e == effect }.length, "Failed to find match for effect: #{effect.inspect} from:\n#{effects[apply_to].map{|e|e.inspect}.join("\n")}")
      }
      @race.each_effect(activation, apply_to){ |effect|
        puts "race checking ... #{effect.inspect}"
        assert_equal(1, effects[apply_to].select{ |e| e == effect }.length)
      }
    }
    activation = :passive
    [:self, :target].each{ |apply_to|
      [item1, item2].each{ |item|
        item.each_effect(activation, apply_to){ |effect|
          puts "#{item.name} checking ... #{effect.inspect}"
          assert_equal(1, effects[apply_to].select{ |e| e == effect }.length)
        }
      }
      @race.each_effect(activation, apply_to){ |effect|
        puts "race checking ... #{effect.inspect}"
        assert_equal(1, effects[apply_to].select{ |e| e == effect }.length)
      }
    }
    
    # test with active item #2 (+ race)
    effects = char.action_effects(item2)
    assert_equal([:self, :target], effects.keys.sort)
    activation = :active
    [:self, :target].each{ |apply_to|
      item2.each_effect(activation, apply_to){ |effect|
        puts "item2 checking ... #{effect.inspect}"
        assert_equal(1, effects[apply_to].select{ |e| e == effect }.length)
      }
      @race.each_effect(activation, apply_to){ |effect|
        puts "race checking ... #{effect.inspect}"
        assert_equal(1, effects[apply_to].select{ |e| e == effect }.length)
      }
    }
    activation = :passive
    [:self, :target].each{ |apply_to|
      [item1, item2].each{ |item|
        item.each_effect(activation, apply_to){ |effect|
        puts "#{item.name} checking ... #{effect.inspect}"
          assert_equal(1, effects[apply_to].select{ |e| e == effect }.length)
        }
      }
      @race.each_effect(activation, apply_to){ |effect|
        puts "race checking ... #{effect.inspect}"
        assert_equal(1, effects[apply_to].select{ |e| e == effect }.length)
      }
    }
    
    
    
=begin
passive-self: always applies to self in all circumstances (bonus to Attr, skills, damage resist, etc)
passive-target: always applies to target, when there is a target (allows a non-active, equipped item to effect a target)
active-self: applies to self when performing any action (heal HP, ... may not be useful; heal HP could be active-target, where target==self)
active-target: applies to target when performing an action on it (weapon/magic damage)
 = {
  :passive => {
    :self => [],
    :target => []
  },
  :active => {
    :self => [],
    :target => []
  }
}
=end
  end
  
  it "should report equipped items properly" do
    raise "unimplemented"
  end
  
  it "should equip and unequip items properly" do
    @char.equip("Head", @item)
    assert_equal(@item, @char.find_body_part_by_name("Head").item)
    @char.unequip("Head")
    assert_equal(nil, @char.find_body_part_by_name("Head").item)
    assert_raises(InvalidArg){ @char.equip("Left hand", @item) } # equipping wrong body part
    assert_raises(RuntimeError){ @char.equip("Left HAND", @item) } # equipping non-existant body part
    # the last call should not have changed anything about the equipped state
    assert_equal(nil, @char.find_body_part_by_name("Head").item)
    assert_equal(nil, @char.find_body_part_by_name("Left hand").item)
  end
  
  it "should clone properly" do
    other = @char.clone
    assert( @char == other ) # value equivalence
    # ck4, add .clone/== tests to all necessary classes
  end
  
=begin
      assert_equal(@char.name, other.name)
    assert_equal(@char.race, other.race)
    assert_equal(@char.health, other.health)
    assert_equal(@char.attributes, other.attributes)
    assert_equal(@char.body_parts.length, other.body_parts.length)
    @char.body_parts.each_with_index{ |bp, index|
      assert(bp == other.body_parts[index])
    }
=end
  
end

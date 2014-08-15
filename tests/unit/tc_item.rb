require_relative '../../environment'
require 'minitest/spec'
require 'minitest/autorun'
require 'classes/item'

describe Item do
  before do
    @name = "Longsword"
    @item_class = :sword
    @weight = 3
    @item = Item.new(@name, @item_class, @weight)
  end
  
  it "should report basic information properly" do
    [:name, :weight, :item_class].each{ |sym|
      value = @item.send(sym)
      assert_equal(instance_variable_get("@"+sym.to_s), @item.send(sym), "instance member has incorrect value: @#{sym.to_s} : #{value}")
    }
  end
end

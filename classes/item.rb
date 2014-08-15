class Item
  attr_reader :name, :item_class, :weight
  def initialize(name, item_class, weight)
    @name = name
    @item_class = item_class
    @weight = weight
  end
end

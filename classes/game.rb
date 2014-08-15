require_relative '../environment'

class Game
  attr_reader :items, :equippable_items
  def initialize
    @items = load_file(File.join(YAML_LOAD_PATH, "items.yaml"))
    @equippable_items = load_file(File.join(YAML_LOAD_PATH, "equippable_items.yaml"))
  end
end

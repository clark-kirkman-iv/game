# This is an extension for structs that allows complete instantiation from
# a hash (allows plain yaml hashes in initialization, instead of yaml'ing of
# a struct instance itself.
module StructBag
  def new_from_hash(attribute_hash)
    begin
      bag = self.members.each_with_object(self.new){ |member, obj|
        obj.send(member.to_s+'=', attribute_hash.fetch(member))
      }
    rescue KeyError => e
      raise KeyError.new("Cannot instantiate a #{self} from given hash.  #{e.message}")
    end
    return bag
  end
end

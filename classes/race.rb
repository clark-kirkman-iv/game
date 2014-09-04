require 'modules/effects'
require 'classes/structs'
require 'classes/body_part'
require 'classes/effect'

class Race
  
  # @effects is accessed through included methods in Effects
  include Effects
  
  attr_reader :name, :attributes, :health, :body_parts
  
  def initialize(name, attributes, body_parts, health, effects = new_blank_effect_hash)
    raise InvalidArg.new("race name must be a String") if !name.is_a?(String)
    @name = name
    raise InvalidArg.new("attributes must be an AttributeStruct") if !attributes.is_a?(AttributeStruct)
    @attributes = attributes
    raise InvalidArg.new("health must be a Fixnum") if !health.is_a?(Fixnum)
    @health = health
    if !body_parts.is_a?(Array) || !body_parts.select{ |bp| !bp.is_a?(BodyPart) }.empty?
      raise InvalidArg.new("body_parts must be an Array of BodyPart objects")
    end
    @body_parts = body_parts
    raise InvalidArg.new("effects must be an Effect Hash") if !effects.is_a?(Hash)
    @effects = effects
  end
  
  # load up info from the file that defines the races & initialize the RACES hash
  def self.load_definitions_file(filename)
    #ck4, do type checking in here, and/or make sure that all instantiated parts do their own type/range checking.
    races = {}
    hash = YAML.load_file(filename)
    hash.each{ |race_hash|
      name = race_hash.fetch(:name)
      health = race_hash.fetch(:health)
      attributes = AttributeStruct.new_from_hash(race_hash.fetch(:attributes))
      body_parts = race_hash.fetch(:body_parts).map{ |part_hash| BodyPart.new_from_hash(part_hash) }
      # load up effect definitions and convert to Effect objects
      effects = race_hash.fetch(:effects, new_blank_effect_hash)
      effects.each{ |activation, activation_hash|
        activation_hash.each{ |apply_to, apply_to_hash|
          effects[activation][apply_to].map!{ |effect_hash| Effect.new_from_hash(effect_hash) }
        }
      }
      race = new(name, attributes, body_parts, health, effects) #ck4, modify/update definitions file to hold effects; none currently defined
      races[race.name] = race # store the new object
    }
    return races
  end
  
  RACES = self.load_definitions_file( File.join(YAML_LOAD_PATH, "races.yaml") )
  
end

# Ray class, this class defines a segment that represents a ray line
# ray.rb
# Author: Pablo Sanabria

require 'ruby3d/core/math/vector'

module Ruby3d
  module Core
    module Math
      class Ray
        attr_accessor :origin
        attr_reader :direction
        
        def initialize(origin, direction)
          @origin = origin
          @position = direction.normalize
        end
        
        def direction=(value)
          @position = value
          @position.normalize!
        end
        
        def to_s
          "Origin: #{@origin}\n" \
          "Direction: #{@position}\n"
        end        
      end
      
      class Intersection
        attr :object, true
        attr :info, true
        
        def initialize
          @object = nil
          @info = Vector.new
        end
        
        def to_s
          "Object: #{@object}\n" \
          "Information: #{@info}\n"          
        end
      end
    end
  end
end
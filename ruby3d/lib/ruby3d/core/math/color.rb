# Color class definition, this object is a Vector with some methods changed and added
# color.rb
# Author: Pablo Sanabria
require 'ruby3d/core/math/vector4d'

module Ruby3d
  module Core
    module Math 
      #noinspection RubyInstanceVariableNamingConvention
      class Color < Vector4d
        def initialize(r = 0.0, g = 0.0, b = 0.0, a = 1.0)
          super(r, g, b, a)
          clamp!
        end               
        def clamp!
          @x = [0, [@x, 1].min].max
          @y = [0, [@y, 1].min].max
          @z = [0, [@z, 1].min].max
          @w = [0, [@w, 1].min].max
          self
        end
        
        def clamp
          Color.new(x, y, z, w).clamp!
        end
        
        alias red x
        alias green y
        alias blue z
        alias alpha z
        alias red= x=
        alias green= y=
        alias blue= z=
        alias alpha= w=
        
        def +(vector2)
          v = super(vector2)
          Color.new(v.x, v.y, v.z, v.w).clamp!
        end
        
        def -(vector2)
          v = super(vector2)
          Color.new(v.x, v.y, v.z, v.w).clamp!
        end
        
        def *(other)
          v = super(other)
          Color.new(v.x, v.y, v.z, v.w).clamp!
        end
        
        def /(other)
          v = super(other)
          Color.new(v.x, v.y, v.z, v.w).clamp!
        end
        
        def to_s
          "Color (R: #{@x}, G: #{@y}, B: #{@z}, A: #{@w})"
        end
        
        protected
        attr_accessor :x
        attr_accessor :y
        attr_accessor :z
        attr_accessor :w
      end
    end
  end
end
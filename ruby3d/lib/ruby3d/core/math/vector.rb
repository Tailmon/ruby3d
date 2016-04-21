# Vector class, this class defines the basic operations around a vector, like addition, subtraction, scaling,
# dot and cross product
# vector.rb
# Author: Pablo Sanabria
include Math

module Ruby3d
  module Core
    module Math
      class Vector
        include Comparable
        attr_accessor :x
        attr_accessor :y
        attr_accessor :z
        attr_accessor :w

        def Vector.lineal_interpolation(vector1, vector2, beta)
            (1 - beta) * vector1 + beta * vector2
        end
        
        def initialize(x = 0.0, y = 0.0, z = 0.0, w = 1.0)
          @x = x
          @y = y
          @z = z
          @w = w
        end
        
        def length          
          sqrt(sqr_length)
        end

        def sqr_length
          x * x + y * y + z * z
        end

        def negate
          Vector.new(-@x, -@y, -@z)
        end
        
        def negate!
          @x = -@x
          @y = -@y
          @z = -@z
          self
        end
        
        def normalize
          temp_length = length
          if temp_length != 0
            Vector.new(@x / temp_length, @y / temp_length, @z / temp_length)
          else
            Vector.new(@x, @y, @z)
          end
        end
        
        def normalize!
          temp_length = self.length
          if temp_length != 0
            @x = @x / temp_length
            @y = @y / temp_length
            @z = @z / temp_length
          end 
          self         
        end
        
        def angle_with(vector2)
          acos(self * vector2 / (self.length * vector2.length))
        end

        def Vector.offset(vector1, vector2)
          x = vector1.x - vector2.x
          y = vector1.y - vector2.y
          z = vector1.z - vector2.z
          w = 1.0
          Vector.new(x, y, z, w)
        end
        
        def ==(vector2)
          if vector2.is_a? Vector
            return @x == vector2.x && @y == vector2.y && @z == vector2.z && @w == vector2.w
          end
          false
        end
        
        def eql?(vector2)
          if vector2.is_a? Vector
            return @x.eql?(vector2.x) && @y.eql?(vector2.y) && @z.eql?(vector2.z) && @w.eql?(vector2.w)
          end
          false
        end
        
        def hash
          code = 17
          code = 37 * code + @x.hash
          code = 37 * code + @y.hash
          code = 37 * code + @z.hash
          37 * code + @w.hash
        end
        
        def +(vector2)
          Vector.new(@x + vector2.x, @y + vector2.y, @z + vector2.z)
        end
        
        def -(vector2)
          Vector.new(@x - vector2.x, @y - vector2.y, @z - vector2.z)
        end
        
        def *(other)
          if other.is_a? Vector
            @x * other.x + @y * other.y + @z * other.z
          else
            Vector.new(@x * other, @y * other, @z * other)
          end
        end
        
        def /(other)
          Vector.new(@x / other, @y / other, @z / other)
        end
        
        def -@
          negate
        end
        
        def dot_product3(other)
          @x * other.x + @y * other.y + @z * other.z
        end
        
        def cross_product(vector2)
          Vector.new(@y * vector2.z - @z * vector2.y,
                    @z * vector2.x - @x * vector2.z,
                    @x * vector2.y - @y * vector2.x)
        end
        
        def <=>(other)
          return nil unless other.is_a? Vector
          self.sqr_length <=> other.sqr_length
        end
        
        def coerce(another)
          [self, another]
        end
        
        def to_s
          "Vector (#{@x}, #{@y}, #{@z})"
        end

        def to_a
          [@x, @y, @z]
        end
      end

      Vector3d = Vector
    end
  end
end

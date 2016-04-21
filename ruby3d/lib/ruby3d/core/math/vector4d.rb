require 'ruby3d/core/math/vector'

module Ruby3d::Core::Math
  class Vector4d < Vector
    def initialize(x = 0.0, y = 0.0, z = 0.0, w = 1.0)
      super(x, y, z, w)
    end

    def sqr_length
      x * x + y * y + z * z + w * w
    end

    def negate
      Vector.new(-@x, -@y, -@z)
    end

    def negate!
      @x = -@x
      @y = -@y
      @z = -@z
      @w = -@w
      self
    end

    def normalize
      temp_length = length
      if temp_length != 0
        Vector.new(@x / temp_length, @y / temp_length, @z / temp_length, @w / temp_length)
      else
        Vector.new(@x, @y, @z, @w)
      end
    end

    def normalize!
      temp_length = self.length
      if temp_length != 0
        @x = @x / temp_length
        @y = @y / temp_length
        @z = @z / temp_length
        @w = @w / temp_length
      end
      self
    end

    def +(vector2)
      Vector.new(@x + vector2.x, @y + vector2.y, @z + vector2.z, @w + vector2.w)
    end

    def -(vector2)
      Vector.new(@x - vector2.x, @y - vector2.y, @z - vector2.z, @w + vector2.w)
    end

    def *(other)
      if other.is_a? Vector
        @x * other.x + @y * other.y + @z * other.z + @w * other.w
      else
        Vector4d.new(@x * other, @y * other, @z * other, @w * other)
      end
    end

    def /(other)
      Vector.new(@x / other, @y / other, @z / other, @w / other)
    end

    def to_s
      "Vector (#{@x}, #{@y}, #{@z}, #{@w})"
    end

    def to_a
      [@x, @y, @z, @w]
    end
  end
end

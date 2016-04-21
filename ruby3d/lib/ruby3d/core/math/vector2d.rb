require 'ruby3d/core/math/vector'

module Ruby3d
  module Core
    module Math
      class Vector2d < Vector
        def initialize(x = 0.0, y = 0.0)
          super(x, y, 0.0)
        end

        def sqr_length
          x * x + y * y
        end

        def to_s
          "Vector (#{@x}, #{@y}, #{@z})"
        end

        def to_a
          [@x, @y]
        end
      end
    end
  end
end


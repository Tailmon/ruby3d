require 'ruby3d/core/math/vector'

module Ruby3d::Core::Math
  class AxisAlignedBoundingBox
    attr_accessor :min
    attr_accessor :max
    attr_accessor :center

    def initialize
      @min = Vector3d.new
      @max = Vector3d.new
      @center = Vector3d.new
    end

    def intersect?(bounding_box2)
      return (@max.x > bounding_box2.min.x) && (@min.x < bounding_box2.max.x) &&
          (@max.y > bounding_box2.min.y) && (@min.y < bounding_box2.max.y) &&
          (@max.z > bounding_box2.min.z) && (@min.z < bounding_box2.max.z)
    end

    def direction(bounding_box2)
      bounding_box2.center - @center
    end

    def calculate_center
      @center = Vector3d.new((@min.x + @max.x) * 0.5, (@min.y + @max.y) * 0.5, (@min.z + @max.z) * 0.5)
    end
  end
end

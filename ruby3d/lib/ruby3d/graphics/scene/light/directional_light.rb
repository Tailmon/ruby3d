require 'opengl'
require 'ruby3d/core/math'
require 'ruby3d/graphics/scene/light/light'

include OpenGL


module Ruby3d::Graphics::Scene::Light
  class DirectionalLight < Light
    attr_accessor :direction

    def initialize
      super
      @direction = Ruby3d::Core::Math::Vector4d.new
      @direction.w = 0.0
    end

    def set_direction(x, y, z)
      @direction.x = x
      @direction.y = y
      @direction.z = z
    end

    def set_light
      glLightfv(GL_LIGHT0 + @index, GL_POSITION, @direction.to_a)
      super
    end

    def position
      @direction
    end
  end
end

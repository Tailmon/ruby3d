require 'opengl'
require 'ruby3d/core/math'
require 'ruby3d/graphics/scene/light/light'

module Ruby3d::Graphics::Scene::Light
  class PointLight < Light
    attr_accessor :position

    def initialize
      super
      @position = Ruby3d::Core::Math::Vector4d.new
    end

    def set_position(x, y, z)
      @position.x = x
      @position.y = y
      @position.z = z
    end

    def set_light
      super
      glLightfv(GL_LIGHT0 + @index, GL_POSITION, @position.to_a)
    end
  end
end

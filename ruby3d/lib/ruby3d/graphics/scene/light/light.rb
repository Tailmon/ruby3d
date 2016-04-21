require 'opengl'
require 'ruby3d/core/math'
require 'ruby3d/graphics/scene/light/light_error'

include OpenGL

module Ruby3d::Graphics::Scene::Light
  class Light
    @@total_lights = Array.new(8) {0}
    attr_accessor :light_color
    attr_accessor :constant_attenuation
    attr_accessor :linear_attenuation
    attr_accessor :quadratic_attenuation
    attr_reader :index

    def self.remove_light(index)
      @@total_lights[index] = 0
    end

    def self.reset_lights
      @@total_lights = Array.new(8) {0}
    end

    def initialize
      @log = Ruby3d::Core::Logger::Log.instance
      unused_light = @@total_lights.find_index(0)
      raise LightError.new('No light available') if unused_light.nil?
      @light_color = Ruby3d::Core::Math::Color.new
      @constant_attenuation = 1.0
      @linear_attenuation = 0.0
      @quadratic_attenuation = 0.0
      @index = unused_light
    end

    def enable_light
      @log.info self.class, "Light #{@index} enabled"
      glEnable(GL_LIGHT0 + @index)
    end

    def disable_light
      @log.info self.class, "Light #{@index} disabled"
      glDisable(GL_LIGHT0 + @index)
    end

    def set_light
      glLightfv(GL_LIGHT0 + @index, GL_DIFFUSE, @light_color.to_a)
      glLightfv(GL_LIGHT0 + @index, GL_SPECULAR, @light_color.to_a)
      glLightf(GL_LIGHT0 + @index, GL_CONSTANT_ATTENUATION, @constant_attenuation)
      glLightf(GL_LIGHT0 + @index, GL_LINEAR_ATTENUATION, @linear_attenuation)
      glLightf(GL_LIGHT0 + @index, GL_QUADRATIC_ATTENUATION, @quadratic_attenuation)
    end
  end
end

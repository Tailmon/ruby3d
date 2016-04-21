require 'ruby3d/core/math'

module Ruby3d::Assets
  class Material
    attr_accessor :diffuse_color
    attr_accessor :specular_color
    attr_accessor :emission_color
    attr_accessor :shininess
    attr_accessor :name
    attr_accessor :texture
    attr_accessor :normal_map

    def initialize(name = nil)
      @diffuse_color = Ruby3d::Core::Math::Color.new
      @specular_color = Ruby3d::Core::Math::Color.new
      @emission_color = Ruby3d::Core::Math::Color.new
      @shininess = 0.0
      @name = name
      @texture = nil
      @normal_map = nil
    end
  end
end
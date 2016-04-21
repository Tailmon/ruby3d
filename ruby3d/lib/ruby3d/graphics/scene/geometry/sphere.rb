require 'opengl'
require 'ruby3d/core/math/sphere'
require 'ruby3d/assets/material'
require 'ruby3d/graphics/scene/geometry/geometry'

include OpenGL

module Ruby3d::Graphics::Scene::Geometry
  class Sphere < Ruby3d::Core::Math::Sphere
    include Ruby3d::Graphics::Scene::Geometry::Geometry

    attr_accessor :material

    def initialize(center, radius)
      super(center, radius)
      create_default
      @material = Ruby3d::Assets::Material.new
    end

    def draw
      glTranslate(center.x, center.y, center.z)
      glutSolidSphere(radius, 20, 10)
    end
  end
end
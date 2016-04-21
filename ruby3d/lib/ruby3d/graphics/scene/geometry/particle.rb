require 'opengl'
require 'ruby3d/graphics/scene/geometry/geometry'

include OpenGL

module Ruby3d::Graphics::Scene::Geometry
  class Particle
    include Ruby3d::Graphics::Scene::Geometry::Geometry

    def initialize

    end

    def draw(cube_map = nil, light_position = nil, texturing = true)
    end
  end
end

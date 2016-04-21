require 'ruby3d/graphics/scene/geometry/geometry'

module Ruby3d::Graphics::Scene::Geometry
  class Model
    include Ruby3d::Graphics::Scene::Geometry::Geometry
    attr_accessor :triangles

    def initialize
      create_default
      @meshes = Array.new
    end

    def add_mesh(mesh)
      @meshes << mesh
    end

    def draw(cube_map = nil, light_position = nil, texturing = true)
      @meshes.each do |m|
        m.draw(cube_map, light_position, texturing)
      end
    end

    def finish_model
      @meshes.each do |m|
        m.finish_mesh
      end
    end

    def calculate_bounding_box
      @meshes.each do |m|
        m.calculate_bounding_box
        m.internal_bounding_box.calculate_center
      end
    end

    def calculate_new_bounding_box
      @meshes.each do |m|
        m.transformation_matrix = Ruby3d::Core::Math::Matrix.new.identity! * transformation_matrix
        m.calculate_new_bounding_box
      end
    end

    def collision_list(scene)
      list = Array.new

      @meshes.each do |m|
        l = m.collision_list(scene)
        list += l
      end

      list
    end

    def collision?(object)
      return [] if object == self

      list = Array.new
      @meshes.each do |m|
        l = m.collision?(object)
        list += l
      end

      list
    end

    def draw_bounding_box
      @meshes.each do |m|
        m.draw_bounding_box
      end
    end
  end
end
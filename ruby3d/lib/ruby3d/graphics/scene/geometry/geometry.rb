require 'opengl'
require 'ruby3d/core/math'

include OpenGL

module Ruby3d::Graphics::Scene::Geometry
  module Geometry
    attr_reader :rotation
    attr_reader :translation
    attr_reader :scaling
    attr_accessor :rotation_x
    attr_accessor :rotation_y
    attr_accessor :rotation_z
    attr_accessor :internal_bounding_box
    attr_accessor :bounding_box
    attr_accessor :transformation_matrix



    def create_default
      @rotation = Ruby3d::Core::Math::Quaternion.new(1.0, 0.0, 0.0, 0.0)
      @rotation_x = 0.0
      @rotation_y = 0.0
      @rotation_z = 0.0
      @translation = Ruby3d::Core::Math::Vector3d.new
      @scaling = Ruby3d::Core::Math::Vector3d.new(1.0, 1.0, 1.0)
      @internal_bounding_box = Ruby3d::Core::Math::AxisAlignedBoundingBox.new
      @bounding_box = Ruby3d::Core::Math::AxisAlignedBoundingBox.new
      @transformation_matrix =  Ruby3d::Core::Math::Matrix.new
      @transformation_matrix.identity!
      @changed = true
    end

    def apply_transformations
      #sqt
      glTranslatef(@translation.x, @translation.y, @translation.z)
      glRotatef(@rotation.scalar, @rotation.vector.x, @rotation.vector.y, @rotation.vector.z)
      glRotatef(@rotation_x, 1.0, 0.0, 0.0)
      glRotatef(@rotation_y, 0.0, 1.0, 0.0)
      glRotatef(@rotation_z, 0.0, 0.0, 1.0)
      glScalef(@scaling.x, @scaling.y, @scaling.z)
      if @changed
        glPushMatrix
        glLoadIdentity
        glTranslatef(@translation.x, @translation.y, @translation.z)
        glRotatef(@rotation.scalar, @rotation.vector.x, @rotation.vector.y, @rotation.vector.z)
        glRotatef(@rotation_x, 1.0, 0.0, 0.0)
        glRotatef(@rotation_y, 0.0, 1.0, 0.0)
        glRotatef(@rotation_z, 0.0, 0.0, 1.0)
        glScalef(@scaling.x, @scaling.y, @scaling.z)
        @transformation_matrix = Ruby3d::Core::Math::Matrix.new(glGetFloatv(GL_MODELVIEW_MATRIX))
        calculate_new_bounding_box
        @changed = false
        glPopMatrix
      end
    end

    def define_rotation(angle, x, y, z)
      @rotation = Ruby3d::Core::Math::Quaternion.new(x, y, z, angle)
      @changed = true
    end

    alias rotate define_rotation

    def scale(x, y, z)
      @scaling.x = x
      @scaling.y = y
      @scaling.z = z
      @changed = true
    end

    def translate(x, y, z)
      @translation.x = x
      @translation.y = y
      @translation.z = z
      @changed = true
    end

    def rotation=(value)
      @rotation = value
      @changed = true
    end

    def scaling=(value)
      @scaling = value
      @changed = true
    end

    def translation=(value)
      @translation = value
      @changed = true
    end

    def collision_list(scene)
      list = Array.new

      scene.objects.each do |o|
        if o != self
          list += o.collision?(self)
        end
      end
      list
    end
  end
end
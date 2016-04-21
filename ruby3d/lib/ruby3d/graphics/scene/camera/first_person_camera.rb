require 'opengl'
require 'ruby3d/core/math'

include OpenGL

module Ruby3d::Graphics::Scene::Camera
  class FirstPersonCamera
    attr_accessor :up
    attr_accessor :look_at
    attr_accessor :position
    attr_accessor :field_of_view
    attr_accessor :near_clip
    attr_accessor :far_clip
    attr_accessor :bounding_box

    def initialize(size, camera_height = 1.0, rotation_speed = 0.025, translation_speed = 0.5)
      @up = Ruby3d::Core::Math::Vector3d.new(0.0, 1.0, 0.0)
      @look_at = Ruby3d::Core::Math::Vector3d.new(0.0, 0.0, -1.0)
      @position = Ruby3d::Core::Math::Vector3d.new
      @field_of_view = 45
      @near_clip = 0.1
      @far_clip = 1000.0
      @width = 0
      @height = 0
      @yaw = 0.0
      @pitch = 0.0
      @lx = 0.0
      @ly = 0.0
      @lz = 0.0
      @strafe_lx = 0.0
      @strafe_lz = 0.0
      @just_warped = false
      glutSetCursor(GLUT_CURSOR_NONE)
      glutWarpPointer(@width / 2, @height / 2)
      @translation_speed = translation_speed
      @rotation_speed = rotation_speed
      @size = size
      @camera_height = camera_height
      @bounding_box = Ruby3d::Core::Math::AxisAlignedBoundingBox.new
      @physics = false
      calculate_bounding_box
    end

    def move(incr)
      @lx = Math::cos(@yaw) * Math::cos(@pitch)
      @ly = Math::sin(@pitch)
      @lz = Math::sin(@yaw) * Math::cos(@pitch)

      @position.x += incr * @lx
      @position.y += incr * @ly
      @position.z += incr * @lz
      self.refresh
    end

    def strafe(incr)
      @position.x = @position.x + incr * @strafe_lx
      @position.z = @position.z + incr * @strafe_lz
      self.refresh
    end

    def fly(incr)
      @y += incr
      self.refresh
    end

    def rotate_yaw(angle)
      @yaw += angle
      self.refresh
    end

    def rotate_pitch(angle)
      limit = 89.0 * Math::PI / 180.0
      @pitch -= angle

      if (@pitch < -limit)
        @pitch = -limit
      end

      if (@pitch > limit)
        @pitch = limit
      end

      self.refresh
    end

    def refresh
      @lx = Math::cos(@yaw) * Math::cos(@pitch)
      @ly = Math::sin(@pitch)
      @lz = Math::sin(@yaw) * Math::cos(@pitch)
      @strafe_lx = Math::cos(@yaw - Math::PI / 2.0)
      @strafe_lz = Math::sin(@yaw - Math::PI / 2.0)
      @look_at.x = @position.x + @lx
      @look_at.y = @position.y + @ly
      @look_at.z = @position.z + @lz
      calculate_bounding_box
    end

    def keyboard(key, x, y)
      glutSetCursor(GLUT_CURSOR_NONE)
      glutWarpPointer(@width / 2, @height / 2)
      case
        when key == 'w' then
          move(@translation_speed)
          glutPostRedisplay
        when key == 'a' then
          strafe(@translation_speed)
          glutPostRedisplay
        when key == 's' then
          move(-@translation_speed)
          glutPostRedisplay
        when key == 'd' then
          strafe(-@translation_speed)
          glutPostRedisplay
      end
    end

    def set_view_port(width, height)
      @width = width
      @height = height
    end

    def mouse(x, y)
      diff_x = x - @width / 2
      diff_y = y - @height / 2

      if @just_warped
        @just_warped = false
        return
      end

      @last_x = x
      @last_y = y

      rotate_yaw(Math::PI / 180 * @rotation_speed * diff_x)
      rotate_pitch(Math::PI / 180 * @rotation_speed * diff_y)

      glutWarpPointer(@width / 2, @height / 2)

      @just_warped = true
    end

    def calculate_bounding_box
      sides = Array.new
      sides << Ruby3d::Core::Math::Vector3d.new(@position.x - @size * 0.5, @position.y - 0.25 * @camera_height, position.z - @size * 0.5)
      sides << Ruby3d::Core::Math::Vector3d.new(@position.x + @size * 0.5, @position.y - 0.25 * @camera_height, position.z - @size * 0.5)
      sides << Ruby3d::Core::Math::Vector3d.new(@position.x - @size * 0.5, @position.y - 0.25 * @camera_height, position.z + @size * 0.5)
      sides << Ruby3d::Core::Math::Vector3d.new(@position.x + @size * 0.5, @position.y - 0.25 * @camera_height, position.z + @size * 0.5)
      sides << Ruby3d::Core::Math::Vector3d.new(@position.x - @size * 0.5, @position.y + 0.75 * @camera_height, position.z - @size * 0.5)
      sides << Ruby3d::Core::Math::Vector3d.new(@position.x + @size * 0.5, @position.y + 0.75 * @camera_height, position.z - @size * 0.5)
      sides << Ruby3d::Core::Math::Vector3d.new(@position.x - @size * 0.5, @position.y + 0.75 * @camera_height, position.z + @size * 0.5)
      sides << Ruby3d::Core::Math::Vector3d.new(@position.x + @size * 0.5, @position.y + 0.75 * @camera_height, position.z + @size * 0.5)

      min_x = Float::INFINITY
      min_y = Float::INFINITY
      min_z = Float::INFINITY
      max_x = -Float::INFINITY
      max_y = -Float::INFINITY
      max_z = -Float::INFINITY
      sides.each do |side|
        x = side.x
        y = side.y
        z = side.z
        min_x = x if x < min_x
        min_y = y if y < min_y
        min_z = z if z < min_z

        max_x = x if x > max_x
        max_y = y if y > max_y
        max_z = z if z > max_z
      end
      bounding_box.min = Ruby3d::Core::Math::Vector3d.new(min_x, min_y, min_z)
      bounding_box.max = Ruby3d::Core::Math::Vector3d.new(max_x, max_y, max_z)
      bounding_box.calculate_center
    end

    def collision_list(scene)
      list = Array.new
      @physics = true

      scene.objects.each do |o|
        if o != self
          list += o.collision?(self)
        end
      end
      list
    end
  end
end
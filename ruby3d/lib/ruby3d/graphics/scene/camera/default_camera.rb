require 'opengl'
require 'ruby3d/core/math'

include OpenGL

module Ruby3d::Graphics::Scene::Camera
  class DefaultCamera
    attr_accessor :up
    attr_accessor :look_at
    attr_accessor :position
    attr_accessor :field_of_view
    attr_accessor :near_clip
    attr_accessor :far_clip

    def initialize
      @up = Ruby3d::Core::Math::Vector3d.new(0.0, 1.0, 0.0)
      @look_at = Ruby3d::Core::Math::Vector3d.new(0.0, 0.0, -1.0)
      @position = Ruby3d::Core::Math::Vector3d.new
      @field_of_view = 45
      @near_clip = 0.1
      @far_clip = 1000.0
    end

    def keyboard(key, x, y)
      dir = @look_at - @position
      tar_postDir = dir.length
      dir.normalize!
      right = dir.cross_product(@up)
      camSpeed = 0.2
      turn_speed = 0.01

      case
        when key == 'w' then
          @position += dir * camSpeed
          @look_at += dir * camSpeed
          glutPostRedisplay
        when key == 'a' then
          @position -= right * camSpeed
          @look_at -= right * camSpeed
          glutPostRedisplay
        when key == 's' then
          @position -= dir * camSpeed
          @look_at -= dir * camSpeed
          glutPostRedisplay
        when key == 'd' then
          @position += right * camSpeed
          @look_at += right * camSpeed
          glutPostRedisplay
        when key == 'i' then
          temp_vec = dir + @up * turn_speed
          temp_vec.normalize!
          @look_at = @position + temp_vec * tar_postDir
          @up = right.cross_product(temp_vec)
          glutPostRedisplay()
        when key == 'j' then
          temp_vec = dir - right * turn_speed
          temp_vec.normalize!
          @look_at = @position + temp_vec * tar_postDir
          glutPostRedisplay()
        when key == 'l' then
          temp_vec = dir + right * turn_speed
          temp_vec.normalize!
          @look_at = @position + temp_vec * tar_postDir
          glutPostRedisplay()
        when key == 'k' then
          temp_vec = dir - @up * turn_speed
          temp_vec.normalize!
          @look_at = @position + temp_vec * tar_postDir
          @up = right.cross_product(temp_vec)
          glutPostRedisplay()
      end
    end

    def mouse(x, y)

    end

    def set_view_port(width, height)
      @width = width
      @height = height
    end
  end
end
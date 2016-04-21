require 'opengl'
require 'ruby3d/core/math'
require 'ruby3d/graphics/scene/shadow/shadow_renderer'

include OpenGL

module Ruby3d::Graphics::Scene
  class Scene
    attr_accessor :camera
    attr_reader :lights
    attr_reader :objects
    attr_accessor :ambient_color
    attr_accessor :background_color
    attr_accessor :width
    attr_accessor :height

    def initialize(width = 800, height = 600)
      @log = Ruby3d::Core::Logger::Log.instance
      @objects = Array.new
      @lights = Array.new
      @width = width
      @height = height
      @ambient_color = Ruby3d::Core::Math::Color.new
      @background_color = Ruby3d::Core::Math::Color.new
      @camera = Ruby3d::Graphics::Scene::Camera::DefaultCamera.new
      Ruby3d::Graphics::Scene::Light::Light.reset_lights
      @shadow = nil
      @normal_cube_map = generate_normal_cube_map
      @show_bounding_box = false
    end


    def render
      glClearColor(@background_color.red, @background_color.green, @background_color.blue, @background_color.alpha)
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

      if (!@shadow.nil?)
        @shadow.render_shadow_map(@lights[0], @objects)
        @shadow.render_ambient_light(@objects, @ambient_color, @camera, @width,
        @height, @lights[0], @normal_cube_map)
      end

      # Camera
      glViewport(0, 0, @width, @height)
      camera.set_view_port(@width, @height)
      glMatrixMode(GL_PROJECTION)
      glLoadIdentity
      gluPerspective(@camera.field_of_view, 1.0 * @width / @height, @camera.near_clip, @camera.far_clip)
      glMatrixMode(GL_MODELVIEW)
      glLoadIdentity
      gluLookAt(@camera.position.x, @camera.position.y, @camera.position.z,
      @camera.look_at.x, @camera.look_at.y, @camera.look_at.z,
      @camera.up.x, @camera.up.y, @camera.up.z)

      #Lights
      glLightModelfv(GL_LIGHT_MODEL_AMBIENT, @ambient_color.to_a)
      @lights.each do |l|
        l.set_light
      end

      #Objects

      @objects.each do |o|
        glPushMatrix
        o.apply_transformations
        o.draw(@normal_cube_map, @lights[0].position)
        glPopMatrix
        if @show_bounding_box
          glDisable(GL_LIGHTING)
          glColor3f(0.0, 0.0, 1.0)
          o.draw_bounding_box
          glEnable(GL_LIGHTING)
        end
      end

      @shadow.post_shadow_renderer unless @shadow.nil?
      glFlush
      glutSwapBuffers
    end

    def resize(width, height)
      @width = width
      @height = height
      glViewport(0, 0, @width, @height)
      glMatrixMode(GL_PROJECTION)
      glLoadIdentity
      gluPerspective(@camera.field_of_view, 1.0 * @width / @height, @camera.near_clip, @camera.far_clip)
      @log.info self.class, "Window resized to: #{width} x #{height}"
    end

    def add_geometry(geometry)
      #TODO: Testear si es una geometria
      geometry.calculate_bounding_box
      geometry.internal_bounding_box.calculate_center
      @objects << geometry
    end

    def add_light(light)
      @lights << light
      light.enable_light
    end

    def clear_geometry!
      @objects.clear
    end

    def clear_lights!
      @lights.clear
    end

    def enable_shadowing(size = 30, shadow_resolution = 512, near = 0.01, far = 80.0)
      @shadow = Ruby3d::Graphics::Scene::Shadow::ShadowRenderer.new(size, near, far, shadow_resolution)
    end

    def disable_shadowing
      @shadow = nil
    end

    def clear_scene
      disable_shadowing
      clear_lights!
      clear_geometry!
      @camera = Ruby3d::Graphics::Scene::Camera::DefaultCamera.new
      disable_fog
    end

    def enable_fog(fog_color, density, fog_start, fog_end, background = true)
      glEnable(GL_FOG)
      glFogi(GL_FOG_MODE, GL_LINEAR)
      glFogfv(GL_FOG_COLOR, fog_color.to_a)
      glFogf(GL_FOG_DENSITY, density)
      glHint(GL_FOG_HINT, GL_DONT_CARE)
      glFogf(GL_FOG_START, fog_start)
      glFogf(GL_FOG_END, fog_end)
      if background
        @background_color = fog_color
      end
    end

    def disable_fog
      glDisable(GL_FOG)
    end

    def enable_show_bounding_box
      @show_bounding_box = true
    end

    def disable_show_bounding_box
      @show_bounding_box = false
    end

    def generate_normal_cube_map
      cube_map = glGenTextures(1).first
      glBindTexture(GL_TEXTURE_CUBE_MAP, cube_map)
      generate_normal_maps
      glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
      glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
      glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
      glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)
      glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE)

      cube_map
    end

    def generate_normal_maps
      size = 128
      offset = 0.5
      half_size = 64
      data = Array.new(size * size * 3)

      index = 0
      0.upto(size - 1) do |i|
        0.upto(size - 1) do |j|
          x = half_size
          y = -(j+offset-half_size)
          z = -(i+offset-half_size)

          length = Math.sqrt(x * x + y * y + z * z)
          x = x / length
          y = y / length
          z = z / length

          data[index] = 255 * (x + 1) / 2
          data[index + 1] = (y + 1) / 2
          data[index + 2] = (z + 1) / 2
          index += 3
        end
      end
      glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X, 0, GL_RGBA, size, size, 0, GL_RGB, GL_FLOAT, data)

      data = Array.new(size * size * 3)

      index = 0
      0.upto(size - 1) do |i|
        0.upto(size - 1) do |j|
          x = -half_size
          y = -(j+offset-half_size)
          z = (i+offset-half_size)

          length = Math.sqrt(x * x + y * y + z * z)
          x = x / length
          y = y / length
          z = z / length

          data[index] = (x + 1) / 2
          data[index + 1] = (y + 1) / 2
          data[index + 2] = (z + 1) / 2
          index += 3
        end
      end
      glTexImage2D(GL_TEXTURE_CUBE_MAP_NEGATIVE_X, 0, GL_RGBA, size, size, 0, GL_RGB, GL_FLOAT, data)

      data = Array.new(size * size * 3)

      index = 0
      0.upto(size - 1) do |i|
        0.upto(size - 1) do |j|
          x = (i+offset-half_size)
          y = half_size
          z = (j+offset-half_size)

          length = Math.sqrt(x * x + y * y + z * z)
          x = x / length
          y = y / length
          z = z / length

          data[index] = (x + 1) / 2
          data[index + 1] = (y + 1) / 2
          data[index + 2] = (z + 1) / 2
          index += 3
        end
      end
      glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_Y, 0, GL_RGBA, size, size, 0, GL_RGB, GL_FLOAT, data)

      data = Array.new(size * size * 3)

      index = 0
      0.upto(size - 1) do |i|
        0.upto(size - 1) do |j|
          x = (i+offset-half_size)
          y = -half_size
          z = -(j+offset-half_size)

          length = Math.sqrt(x * x + y * y + z * z)
          x = x / length
          y = y / length
          z = z / length

          data[index] = (x + 1) / 2
          data[index + 1] = (y + 1) / 2
          data[index + 2] = (z + 1) / 2
          index += 3
        end
      end
      glTexImage2D(GL_TEXTURE_CUBE_MAP_NEGATIVE_Y, 0, GL_RGBA, size, size, 0, GL_RGB, GL_FLOAT, data)

      data = Array.new(size * size * 3)

      index = 0
      0.upto(size - 1) do |i|
        0.upto(size - 1) do |j|
          x = (i+offset-half_size)
          y = -(j+offset-half_size)
          z = half_size

          length = Math.sqrt(x * x + y * y + z * z)
          x = x / length
          y = y / length
          z = z / length

          data[index] = (x + 1) / 2
          data[index + 1] = (y + 1) / 2
          data[index + 2] = (z + 1) / 2
          index += 3
        end
      end
      glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_Z, 0, GL_RGBA, size, size, 0, GL_RGB, GL_FLOAT, data)

      data = Array.new(size * size * 3)

      index = 0
      0.upto(size - 1) do |i|
        0.upto(size - 1) do |j|
          x = -(i+offset-half_size)
          y = -(j+offset-half_size)
          z = -half_size

          length = Math.sqrt(x * x + y * y + z * z)
          x = x / length
          y = y / length
          z = z / length

          data[index] = (x + 1) / 2
          data[index + 1] = (y + 1) / 2
          data[index + 2] = (z + 1) / 2
          index += 3
        end
      end
      glTexImage2D(GL_TEXTURE_CUBE_MAP_NEGATIVE_Z, 0, GL_RGBA, size, size, 0, GL_RGB, GL_FLOAT, data)
    end
  end
end

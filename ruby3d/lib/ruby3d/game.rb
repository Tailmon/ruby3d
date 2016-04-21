require 'singleton'
require 'opengl'
require 'ruby3d/core'
require 'ruby3d/graphics'
require 'ruby3d/assets'

include OpenGL

module Ruby3d
  class Game
    include Singleton
    attr_accessor :settings
    attr_accessor :renderer
    attr_accessor :scene
    attr_accessor :asset_manager
    attr_accessor :deltaTime

    class ElapsedTime
      def initialize(max_time_step = 0.33)
        @max_time_step = max_time_step
        @previous = Time.now
      end

      def get_elapsed_time
        current_time = Time.now
        delta_time = current_time - @previous
        @previous = current_time
        delta_time = [delta_time, @max_time_step].min

        delta_time
      end
    end

    def initialize
      @log = Ruby3d::Core::Logger::Log.instance
      @settings = Ruby3d::Core::Settings::Settings.instance
      @settings.parse_configuration_file('config.yaml')
      @renderer = Ruby3d::Graphics::Renderer::OpenGLRenderer.new
      @scene = nil
      @asset_manager = Ruby3d::Assets::AssetManager.instance
      @deltaTime = 0
      @timer = ElapsedTime.new
      @elapsed_time = 0
    end

    def start_game
      @log.info self.class, 'Ruby3D Engine started'
      @renderer.start_up
      @scene = @renderer.scene
    end

    def game_loop
      previousTime = 0
      @update_func = lambda do
        currentTime = glutGet(GLUT_ELAPSED_TIME)
        @deltaTime = currentTime - previousTime

        if (deltaTime > 1000 / 60.0)
          previousTime = currentTime
          @elapsed_time = @timer.get_elapsed_time
          update
        end
        glutPostRedisplay
      end
      glutIdleFunc @update_func
      @renderer.run
    end

    def keyboard
      @keyboard_func = lambda do  |key, x, y|
        if key == 27.chr
          exit(0)
        end
        @scene.camera.keyboard(key, x, y)
      end

      @mouse_func = lambda do |x, y|
        @scene.camera.mouse(x, y)
      end
      glutKeyboardFunc @keyboard_func
      glutMotionFunc @mouse_func
      glutPassiveMotionFunc @mouse_func
    end

    def update
    end

    def run
      start_game
      keyboard
      game_loop
    end
  end
end

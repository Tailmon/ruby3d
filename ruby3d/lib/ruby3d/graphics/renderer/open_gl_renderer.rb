require 'opengl'
require 'ruby3d/core'

include OpenGL

module Ruby3d::Graphics::Renderer
  class OpenGLRenderer
    attr_accessor :scene

    def initialize
      @log = Ruby3d::Core::Logger::Log.instance
      @video_settings = Ruby3d::Core::Settings::Settings.instance.video_settings
      #TODO: Verificar que sea una escena
    end

    def start_up
      @log.info self.class, 'Initializing OpenGL Renderer'
      glutInit
      #TODO: leer desde settings el formato
      glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH)
      x_res = @video_settings.x_resolution
      y_res = @video_settings.y_resolution
      glutInitWindowSize(x_res, y_res)
      @log.info self.class, "Glut Windows: x res: #{x_res}, y res: #{y_res}"
      glutInitWindowPosition(100, 100)
      glutCreateWindow('Ruby3d Engine')
      glClearDepth(1.0)
      glDepthFunc(GL_LEQUAL)
      glEnable(GL_DEPTH_TEST)
      @log.info self.class, 'Depth test initialized'
      glEnable(GL_LIGHTING)
      glEnable(GL_COLOR_MATERIAL)
      glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE)
      glEnable(GL_NORMALIZE)
      glShadeModel(GL_SMOOTH)
      glEnable(GL_CULL_FACE)
      glCullFace(GL_BACK)

      #Work around para cargar la multitextura en windows
      glMultiTexCoord2f(GL_TEXTURE0, 0, 0)
      glMultiTexCoord3f(GL_TEXTURE0, 0, 0, 0)

      @log.info self.class, 'Shading initialized'
      @scene = Ruby3d::Graphics::Scene::Scene.new
      @scene.width = x_res
      @scene.height = y_res
      @log.info self.class, 'Scene created'
      previous_time = 0
      frame_count = 0

      @draw = lambda do
        current_time = glutGet(GLUT_ELAPSED_TIME)
        delta_time = current_time - previous_time
        frame_count += 1

        if (delta_time > 1000)
          fps = frame_count / (delta_time / 1000.0)
          glutSetWindowTitle("Ruby3D Engine: #{fps} fps")
          previous_time = current_time
          frame_count = 0
        end
        @scene.render
      end

      @reshape = lambda do |w, h|
        @scene.resize(w, h)
      end
    end

    def run
      glutDisplayFunc @draw
      glutReshapeFunc @reshape
      @log.info self.class, 'OpenGL Renderer launched!'
      glutMainLoop
    end
  end
end
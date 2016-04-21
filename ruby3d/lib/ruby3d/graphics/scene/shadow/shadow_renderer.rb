require 'opengl'

include GL

module Ruby3d::Graphics::Scene::Shadow
  class ShadowRenderer
    def initialize(size, light_near, light_far, resolution)
      @light_near = light_near
      @light_far = light_far
      @shadow_resolution = resolution
      @light_size = size
      @shadow_map_texture = nil
      prepare_shadow_map
    end

    def render_shadow_map(light, objects)
      glViewport(0, 0, @shadow_resolution, @shadow_resolution)
      glMatrixMode(GL_PROJECTION)
      glLoadIdentity
      glOrtho(-@light_size, @light_size, -@light_size, @light_size, @light_near, @light_far)
      glMatrixMode(GL_MODELVIEW)
      glLoadIdentity
      gluLookAt(light.position.x, light.position.y, light.position.z,
                0.0, 0.0, 0.0, 0.0, 1.0, 0.0)
      glShadeModel(GL_FLAT)
      glDisable(GL_LIGHTING)
      glDisable(GL_LIGHT0)
      glCullFace(GL_FRONT)
      glColorMask(false, false, false, false)
      objects.each do |o|
        glPushMatrix
        o.apply_transformations
        o.draw(nil, nil, false)
        glPopMatrix
      end

      glBindTexture(GL_TEXTURE_2D, @shadow_map_texture)
      glCopyTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, 0, 0, @shadow_resolution, @shadow_resolution)
    end

    def render_ambient_light(objects, ambient_color, camera, width, height, light, cube_map)
      glClear(GL_DEPTH_BUFFER_BIT)
      glShadeModel(GL_SMOOTH)
      glCullFace(GL_BACK)
      glColorMask(true, true, true, true)

      glViewport(0, 0, width, height)
      glMatrixMode(GL_PROJECTION)
      glLoadIdentity
      gluPerspective(camera.field_of_view, 1.0 * width / height, camera.near_clip, camera.far_clip)
      glMatrixMode(GL_MODELVIEW)
      glLoadIdentity
      gluLookAt(camera.position.x, camera.position.y, camera.position.z,
                camera.look_at.x, camera.look_at.y, camera.look_at.z,
                camera.up.x, camera.up.y, camera.up.z)
      glLightModelfv(GL_LIGHT_MODEL_AMBIENT, ambient_color.to_a)
      glLightfv(GL_LIGHT0, GL_DIFFUSE, ambient_color.to_a)
      glLightfv(GL_LIGHT0, GL_SPECULAR, [0, 0, 0, 0])
      glEnable(GL_LIGHT0)
      glEnable(GL_LIGHTING)

      glActiveTexture(GL_TEXTURE0)
      glClientActiveTexture(GL_TEXTURE0)

      objects.each do |o|
        glPushMatrix
        o.apply_transformations
        o.draw(cube_map, light.position)
        glPopMatrix
      end

      glActiveTexture(GL_TEXTURE1)
      glClientActiveTexture(GL_TEXTURE1)
      generate_texture(light)

      glBindTexture(GL_TEXTURE_2D, @shadow_map_texture)
      glEnable(GL_TEXTURE_2D)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_MODE, GL_COMPARE_R_TO_TEXTURE)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_FUNC, GL_LEQUAL)
      glTexParameteri(GL_TEXTURE_2D, GL_DEPTH_TEXTURE_MODE, GL_INTENSITY)

      glAlphaFunc(GL_GEQUAL, 0.01)
      glEnable(GL_ALPHA_TEST)
    end

    def post_shadow_renderer
      glActiveTexture(GL_TEXTURE1)
      glClientActiveTexture(GL_TEXTURE1)
      glDisable(GL_TEXTURE_2D)
      glDisable(GL_TEXTURE_GEN_S)
      glDisable(GL_TEXTURE_GEN_T)
      glDisable(GL_TEXTURE_GEN_R)
      glDisable(GL_TEXTURE_GEN_Q)
      glDisable(GL_TEXTURE_2D)
      glActiveTexture(GL_TEXTURE0)
      glClientActiveTexture(GL_TEXTURE0)
      glDisable(GL_ALPHA_TEST)
    end

    private
    def prepare_shadow_map
      @shadow_map_texture = glGenTextures(1).first
      glBindTexture(GL_TEXTURE_2D, @shadow_map_texture)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP)
      glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT,
                   @shadow_resolution, @shadow_resolution, 0,
                   GL_DEPTH_COMPONENT, GL_UNSIGNED_BYTE, nil)
    end

    def generate_texture(light)
      glPushMatrix
      glLoadIdentity
      glTranslatef(0.5, 0.5, 0.5)
      glScalef(0.5, 0.5, 0.5)
      glOrtho(-@light_size, @light_size, -@light_size, @light_size, @light_near, @light_far)
      gluLookAt(light.position.x, light.position.y, light.position.z, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0)
      tmp_matrix = glGetFloatv(GL_MODELVIEW_MATRIX)
      glPopMatrix()

      tmp_matrix = tmp_matrix.transpose

      glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_EYE_LINEAR)
      glTexGenfv(GL_S, GL_EYE_PLANE, tmp_matrix[0])
      glEnable(GL_TEXTURE_GEN_S)

      glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_EYE_LINEAR)
      glTexGenfv(GL_T, GL_EYE_PLANE, tmp_matrix[1])
      glEnable(GL_TEXTURE_GEN_T)

      glTexGeni(GL_R, GL_TEXTURE_GEN_MODE, GL_EYE_LINEAR)
      glTexGenfv(GL_R, GL_EYE_PLANE, tmp_matrix[2])
      glEnable(GL_TEXTURE_GEN_R)

      glTexGeni(GL_Q, GL_TEXTURE_GEN_MODE, GL_EYE_LINEAR)
      glTexGenfv(GL_Q, GL_EYE_PLANE, tmp_matrix[3])
      glEnable(GL_TEXTURE_GEN_Q)
    end
  end
end

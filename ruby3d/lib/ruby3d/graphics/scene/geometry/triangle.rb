require 'opengl'
require 'ruby3d/core/math'
require 'ruby3d/assets/material'
require 'ruby3d/graphics/scene/geometry/geometry'

include OpenGL

module Ruby3d::Graphics::Scene::Geometry
  class Triangle < Ruby3d::Core::Math::Triangle
    include Ruby3d::Graphics::Scene::Geometry::Geometry
    attr_accessor :material1
    attr_accessor :material2
    attr_accessor :material3
    attr_accessor :normal1
    attr_accessor :normal2
    attr_accessor :normal3
    attr_accessor :texture_coords1
    attr_accessor :texture_coords2
    attr_accessor :texture_coords3
    attr_reader   :tangent1
    attr_reader   :tangent2
    attr_reader   :tangent3
    attr_reader   :bi_tangent1
    attr_reader   :bi_tangent2
    attr_reader   :bi_tangent3


    def initialize(vertex1, vertex2, vertex3)
      super(vertex1, vertex2, vertex3)
      create_default
      @material1 = Ruby3d::Assets::Material.new
      @material2 = Ruby3d::Assets::Material.new
      @material3 = Ruby3d::Assets::Material.new
      @normal1 = Ruby3d::Core::Math::Vector3d.new
      @normal2 = Ruby3d::Core::Math::Vector3d.new
      @normal3 = Ruby3d::Core::Math::Vector3d.new
      @tangent1 = Ruby3d::Core::Math::Vector3d.new
      @tangent2 = Ruby3d::Core::Math::Vector3d.new
      @tangent3 = Ruby3d::Core::Math::Vector3d.new
      @bi_tangent1 = Ruby3d::Core::Math::Vector3d.new
      @bi_tangent2 = Ruby3d::Core::Math::Vector3d.new
      @bi_tangent3 = Ruby3d::Core::Math::Vector3d.new
      @texture_coords1 = Ruby3d::Core::Math::Vector2d.new
      @texture_coords2 = Ruby3d::Core::Math::Vector2d.new
      @texture_coords3 = Ruby3d::Core::Math::Vector2d.new
      @first_time = true
    end

    def draw(cube_map = nil, light_position = nil, texturing = true)
      if @first_time
        calculate_tangents
        @first_time = false
      end
      light_tangent1 = Ruby3d::Core::Math::Vector3d.new
      light_tangent2 = Ruby3d::Core::Math::Vector3d.new
      light_tangent3 = Ruby3d::Core::Math::Vector3d.new

      glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, @material1.specular_color.to_a)
      glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, @material1.emission_color.to_a)
      glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, @material1.shininess)

      if (texturing)
        if (!@material1.normal_map.nil?)
          #Normal map
          glActiveTexture(GL_TEXTURE0)
          glBindTexture(GL_TEXTURE_2D, @material1.normal_map.texture_id)
          glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE)
          glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_RGB, GL_TEXTURE)
          glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_REPLACE)
          glEnable(GL_TEXTURE_2D)

          glActiveTexture(GL_TEXTURE2)
          glBindTexture(GL_TEXTURE_CUBE_MAP, cube_map)
          glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE)
          glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_RGB, GL_TEXTURE)
          glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_DOT3_RGB)
          glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE1_RGB, GL_PREVIOUS)
          glEnable(GL_TEXTURE_CUBE_MAP)

          glPushMatrix
          glLoadIdentity
          glScalef(1.0 / @scaling.x, 1.0 / @scaling.y, 1.0 / @scaling.z)
          glRotatef(-@rotation.scalar, -@rotation.vector.x, -@rotation.vector.y, -@rotation.vector.z)
          glTranslatef(-@translation.x, -@translation.y, -@translation.z)
          inverse_temp = glGetFloatv(GL_MODELVIEW_MATRIX)
          inverse =  Ruby3d::Core::Math::Matrix.new(inverse_temp.to_a)
          glPopMatrix
          objectLightPosition = inverse * light_position
          light_vector = objectLightPosition - @vertex1
          light_tangent1.x = @tangent1.dot_product3(light_vector)
          light_tangent1.y = @bi_tangent1.dot_product3(light_vector)
          light_tangent1.z = @normal1.dot_product3(light_vector)

          light_vector = objectLightPosition - @vertex2
          light_tangent1.x = @tangent2.dot_product3(light_vector)
          light_tangent1.y = @bi_tangent2.dot_product3(light_vector)
          light_tangent1.z = @normal2.dot_product3(light_vector)

          light_vector = objectLightPosition - @vertex3
          light_tangent1.x = @tangent3.dot_product3(light_vector)
          light_tangent1.y = @bi_tangent3.dot_product3(light_vector)
          light_tangent1.z = @normal3.dot_product3(light_vector)

          glActiveTexture(GL_TEXTURE0)
          glBegin(GL_TRIANGLES)
          glColor3f(@material1.diffuse_color.red, @material1.diffuse_color.green, @material1.diffuse_color.blue)
          glMultiTexCoord2f(GL_TEXTURE0, @texture_coords1.x, @texture_coords1.y)
          glMultiTexCoord3f(GL_TEXTURE2, light_tangent1.x, light_tangent1.y, light_tangent1.z)
          glNormal3f(@normal1.x, @normal1.y, @normal1.z)
          glVertex3f(vertex1.x, vertex1.y, vertex1.z)
          glColor3f(@material2.diffuse_color.red, @material2.diffuse_color.green, @material2.diffuse_color.blue)
          glMultiTexCoord2f(GL_TEXTURE0, @texture_coords2.x, @texture_coords2.y)
          glMultiTexCoord3f(GL_TEXTURE2, light_tangent2.x, light_tangent2.y, light_tangent2.z)
          glNormal3f(@normal2.x, @normal2.y, @normal2.z)
          glVertex3f(vertex2.x, vertex2.y, vertex2.z)
          glColor3f(@material3.diffuse_color.red, @material3.diffuse_color.green, @material3.diffuse_color.blue)
          glMultiTexCoord2f(GL_TEXTURE0, @texture_coords3.x, @texture_coords3.y)
          glMultiTexCoord3f(GL_TEXTURE2, light_tangent3.x, light_tangent3.y, light_tangent3.z)
          glNormal3f(@normal3.x, @normal3.y, @normal3.z)
          glVertex3f(vertex3.x, vertex3.y, vertex3.z)
          glEnd

          glDisable(GL_TEXTURE_2D)
          glActiveTexture(GL_TEXTURE2)
          glDisable(GL_TEXTURE_CUBE_MAP)
          glActiveTexture(GL_TEXTURE0)

          glBlendFunc(GL_DST_COLOR, GL_ZERO)
          glEnable(GL_BLEND)
        end
        glActiveTexture(GL_TEXTURE0)
        glClientActiveTexture(GL_TEXTURE0)
        glEnable(GL_TEXTURE_2D)
        if (!@material1.texture.nil?)
          glBindTexture(GL_TEXTURE_2D, @material1.texture.texture_id)
          glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE)
        else
          glDisable(GL_TEXTURE_2D)
        end
      end

      glBegin(GL_TRIANGLES)

      glColor3f(@material1.diffuse_color.red, @material1.diffuse_color.green, @material1.diffuse_color.blue)
      glMultiTexCoord2f(GL_TEXTURE0, @texture_coords1.x, @texture_coords1.y)
      glNormal3f(@normal1.x, @normal1.y, @normal1.z)
      glVertex3f(vertex1.x, vertex1.y, vertex1.z)
      glColor3f(@material2.diffuse_color.red, @material2.diffuse_color.green, @material2.diffuse_color.blue)
      glMultiTexCoord2f(GL_TEXTURE0, @texture_coords2.x, @texture_coords2.y)
      glNormal3f(@normal2.x, @normal2.y, @normal2.z)
      glVertex3f(vertex2.x, vertex2.y, vertex2.z)
      glColor3f(@material3.diffuse_color.red, @material3.diffuse_color.green, @material3.diffuse_color.blue)
      glMultiTexCoord2f(GL_TEXTURE0, @texture_coords3.x, @texture_coords3.y)
      glNormal3f(@normal3.x, @normal3.y, @normal3.z)
      glVertex3f(vertex3.x, vertex3.y, vertex3.z)

      glEnd

      glDisable(GL_BLEND)
    end

    def calculate_normals
       @normal1 = (vertex2 - vertex1).cross_product(vertex3 - vertex1).normalize
       @normal2 = (vertex2 - vertex1).cross_product(vertex3 - vertex1).normalize
       @normal3 = (vertex2 - vertex1).cross_product(vertex3 - vertex1).normalize
    end

    def calculate_tangents
      q1 = @vertex2 - @vertex1
      q2 = @vertex3 - @vertex1
      s1 = @texture_coords2.x - @texture_coords1.x
      s2 = @texture_coords3.x - @texture_coords1.x
      t1 = @texture_coords2.y - @texture_coords1.y
      t2 = @texture_coords3.y - @texture_coords1.y

      inv = s1 * t2 - s2 * t1
      tx = 1.0 * (t2 * q1.x - t1 * q2.x) / inv
      ty = 1.0 * (t2 * q1.y - t1 * q2.y) / inv
      tz = 1.0 * (t2 * q1.z - t1 * q2.z) / inv
      bx = 1.0 * (-s2 * q1.x + s1 * q2.x) / inv
      by = 1.0 * (-s2 * q1.y + s1 * q2.y) / inv
      bz = 1.0 * (-s2 * q1.z + s1 * q2.z) / inv

      tangent = Ruby3d::Core::Math::Vector3d.new(tx, ty, tz).normalize
      bi_tangent = Ruby3d::Core::Math::Vector3d.new(bx, by, bz).normalize

      @tangent1 = (tangent - (tangent.dot_product3(@normal1)) * @normal1).normalize
      @bi_tangent1 = (bi_tangent - (@normal1.dot_product3(bi_tangent)) * @normal1 - (@tangent1.dot_product3(bi_tangent)) * @tangent1 / @tangent1.sqr_length).normalize

      @tangent2 = (tangent - (tangent.dot_product3(@normal2)) * @normal2).normalize
      @bi_tangent2 = (bi_tangent - (@normal2.dot_product3(bi_tangent)) * @normal2 - (@tangent2.dot_product3(bi_tangent)) * @tangent2 / @tangent2.sqr_length).normalize

      @tangent3 = (tangent - (tangent.dot_product3(@normal3)) * @normal3).normalize
      @bi_tangent3 = (bi_tangent - (@normal3.dot_product3(bi_tangent)) * @normal3 - (@tangent3.dot_product3(bi_tangent)) * @tangent3 / @tangent3.sqr_length).normalize
    end

    def calculate_bounding_box
      v1 = @vertex1
      v2 = @vertex2
      v3 = @vertex3
      min_x = Float::INFINITY
      min_y = Float::INFINITY
      min_z = Float::INFINITY
      max_x = -Float::INFINITY
      max_y = -Float::INFINITY
      max_z = -Float::INFINITY

      min_x = v1.x if v1.x < min_x
      min_x = v2.x if v2.x < min_x
      min_x = v3.x if v3.x < min_x

      min_y = v1.y if v1.y < min_y
      min_y = v2.y if v2.y < min_y
      min_y = v3.y if v3.y < min_y

      min_z = v1.z if v1.z < min_z
      min_z = v2.z if v2.z < min_z
      min_z = v3.z if v3.z < min_z


      max_x = v1.x if v1.x > max_x
      max_x = v2.x if v2.x > max_x
      max_x = v3.x if v3.x > max_x

      max_y = v1.y if v1.y > max_y
      max_y = v2.y if v2.y > max_y
      max_y = v3.y if v3.y > max_y

      max_z = v1.z if v1.z > max_z
      max_z = v2.z if v2.z > max_z
      max_z = v3.z if v3.z > max_z

      internal_bounding_box.min = Ruby3d::Core::Math::Vector3d.new(min_x, min_y, min_z)
      internal_bounding_box.max = Ruby3d::Core::Math::Vector3d.new(max_x, max_y, max_z)
    end

    def calculate_new_bounding_box
      sides = Array.new
      sides << @transformation_matrix * Ruby3d::Core::Math::Vector3d.new(@internal_bounding_box.min.x, @internal_bounding_box.min.y, @internal_bounding_box.min.z)
      sides << @transformation_matrix * Ruby3d::Core::Math::Vector3d.new(@internal_bounding_box.min.x, @internal_bounding_box.max.y, @internal_bounding_box.min.z)
      sides << @transformation_matrix * Ruby3d::Core::Math::Vector3d.new(@internal_bounding_box.max.x, @internal_bounding_box.min.y, @internal_bounding_box.min.z)
      sides << @transformation_matrix * Ruby3d::Core::Math::Vector3d.new(@internal_bounding_box.max.x, @internal_bounding_box.max.y, @internal_bounding_box.min.z)
      sides << @transformation_matrix * Ruby3d::Core::Math::Vector3d.new(@internal_bounding_box.min.x, @internal_bounding_box.min.y, @internal_bounding_box.max.z)
      sides << @transformation_matrix * Ruby3d::Core::Math::Vector3d.new(@internal_bounding_box.min.x, @internal_bounding_box.max.y, @internal_bounding_box.max.z)
      sides << @transformation_matrix * Ruby3d::Core::Math::Vector3d.new(@internal_bounding_box.max.x, @internal_bounding_box.min.y, @internal_bounding_box.max.z)
      sides << @transformation_matrix * Ruby3d::Core::Math::Vector3d.new(@internal_bounding_box.max.x, @internal_bounding_box.max.y, @internal_bounding_box.max.z)

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

    def collision?(object)
      return [] if object == self

      return [self] if @bounding_box.intersect?(object.bounding_box)
      []
    end

    def draw_bounding_box
      glPushMatrix
      glTranslatef(bounding_box.center.x, bounding_box.center.y, bounding_box.center.z)
      glScalef(bounding_box.max.x - bounding_box.min.x, bounding_box.max.y - bounding_box.min.y, bounding_box.max.z - bounding_box.min.z)
      glutWireCube(1.0)
      glPopMatrix
    end
  end
end

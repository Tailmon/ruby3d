require 'opengl'
require 'ruby3d/graphics/scene/geometry/geometry'

include OpenGL

module Ruby3d::Graphics::Scene::Geometry
  class Mesh
    include Ruby3d::Graphics::Scene::Geometry::Geometry
    attr_accessor :material


    def initialize
      create_default
      @vertex_array = Array.new
      @texture_array = Array.new
      @normal_array = Array.new
      @diffuse_color_array = Array.new
      @tangents = Array.new
      @bi_tangentes = Array.new
      @material = Ruby3d::Assets::AssetManager.instance.get_material('DefaultMaterial')
      @indexes = Array.new
      @size = 0
    end

    def add_triangle(triangle)
      @vertex_array << triangle.vertex1.x << triangle.vertex1.y << triangle.vertex1.z
      @vertex_array << triangle.vertex2.x << triangle.vertex2.y << triangle.vertex2.z
      @vertex_array << triangle.vertex3.x << triangle.vertex3.y << triangle.vertex3.z

      @texture_array << triangle.texture_coords1.x << triangle.texture_coords1.y
      @texture_array << triangle.texture_coords2.x << triangle.texture_coords2.y
      @texture_array << triangle.texture_coords3.x << triangle.texture_coords3.y

      @normal_array << triangle.normal1.x << triangle.normal1.y << triangle.normal1.z
      @normal_array << triangle.normal2.x << triangle.normal2.y << triangle.normal2.z
      @normal_array << triangle.normal3.x << triangle.normal3.y << triangle.normal3.z

      @diffuse_color_array << triangle.material1.diffuse_color.red << triangle.material1.diffuse_color.green << triangle.material1.diffuse_color.blue << triangle.material1.diffuse_color.alpha
      @diffuse_color_array << triangle.material2.diffuse_color.red << triangle.material2.diffuse_color.green << triangle.material2.diffuse_color.blue << triangle.material2.diffuse_color.alpha
      @diffuse_color_array << triangle.material3.diffuse_color.red << triangle.material3.diffuse_color.green << triangle.material3.diffuse_color.blue << triangle.material3.diffuse_color.alpha
      @indexes << @size << @size + 1 << @size + 2
      @size += 3

      calculate_tangents(triangle)
    end

    def finish_mesh
      @display_list = glGenLists(1)
      @display_list_normals = glGenLists(1)
      @first_time = true
      @first_time_normals = true
    end

    def draw(cube_map = nil, light_position = nil, texturing = true)
      if @first_time
        glNewList(@display_list, GL_COMPILE)
        glEnableClientState(GL_VERTEX_ARRAY)
        glEnableClientState(GL_TEXTURE_COORD_ARRAY)
        glEnableClientState(GL_NORMAL_ARRAY)
        glEnableClientState(GL_COLOR_ARRAY)

        glNormalPointer(GL_FLOAT, 0, @normal_array)
        glVertexPointer(3, GL_FLOAT, 0, @vertex_array)
        glTexCoordPointer(2, GL_FLOAT, 0, @texture_array)
        glColorPointer(4, GL_FLOAT, 0, @diffuse_color_array)
        glDrawElements(GL_TRIANGLES, @size, GL_UNSIGNED_INT, @indexes)

        glActiveTexture(GL_TEXTURE0)
        glClientActiveTexture(GL_TEXTURE0)
        glDisableClientState(GL_TEXTURE_COORD_ARRAY)
        glDisableClientState(GL_VERTEX_ARRAY)
        glDisableClientState(GL_NORMAL_ARRAY)
        glDisableClientState(GL_COLOR_ARRAY)
        glEndList()
        @first_time = false
      end
      glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, @material.specular_color.to_a)
      glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, @material.emission_color.to_a)
      glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, @material.shininess)

      if (texturing)
        if (!@material.normal_map.nil?)
          if @first_time_normals
            glNewList(@display_list_normals, GL_COMPILE)
            glPushMatrix
            glLoadIdentity
            glScalef(1.0 / @scaling.x, 1.0 / @scaling.y, 1.0 / @scaling.z)
            glRotatef(-@rotation.scalar, -@rotation.vector.x, -@rotation.vector.y, -@rotation.vector.z)
            glTranslatef(-@translation.x, -@translation.y, -@translation.z)
            inverse_temp = glGetFloatv(GL_MODELVIEW_MATRIX)
            inverse =  Ruby3d::Core::Math::Matrix.new(inverse_temp.to_a)
            glPopMatrix
            objectLightPosition = inverse * light_position

            ligth_tangents = Array.new

            @indexes.each do |i|
              light_tangent = Ruby3d::Core::Math::Vector3d.new
              vertex = Ruby3d::Core::Math::Vector3d.new(@vertex_array[3 * i], @vertex_array[3 * i + 1], @vertex_array[3 * i + 2])
              normal = Ruby3d::Core::Math::Vector3d.new(@normal_array[3 * i], @normal_array[3 * i + 1], @normal_array[3 * i + 2])
              light_vector = objectLightPosition - vertex
              light_tangent.x = @tangents[i].dot_product3(light_vector)
              light_tangent.y = @bi_tangentes[i].dot_product3(light_vector)
              light_tangent.z = normal.dot_product3(light_vector)
              ligth_tangents << light_tangent.x << light_tangent.y << light_tangent.z
            end
            glClientActiveTexture(GL_TEXTURE2)
            glEnableClientState(GL_VERTEX_ARRAY)
            glTexCoordPointer(3, GL_FLOAT, 0, ligth_tangents)

            glClientActiveTexture(GL_TEXTURE0)
            glEnableClientState(GL_VERTEX_ARRAY)
            glEnableClientState(GL_TEXTURE_COORD_ARRAY)
            glEnableClientState(GL_NORMAL_ARRAY)
            glEnableClientState(GL_COLOR_ARRAY)

            glNormalPointer(GL_FLOAT, 0, @normal_array)
            glVertexPointer(3, GL_FLOAT, 0, @vertex_array)
            glTexCoordPointer(2, GL_FLOAT, 0, @texture_array)
            glColorPointer(4, GL_FLOAT, 0, @diffuse_color_array)
            glDrawElements(GL_TRIANGLES, @size, GL_UNSIGNED_INT, @indexes)

            glClientActiveTexture(GL_TEXTURE2)
            glDisableClientState(GL_TEXTURE_COORD_ARRAY)

            glClientActiveTexture(GL_TEXTURE0)
            glDisableClientState(GL_TEXTURE_COORD_ARRAY)
            glDisableClientState(GL_VERTEX_ARRAY)
            glDisableClientState(GL_NORMAL_ARRAY)
            glDisableClientState(GL_COLOR_ARRAY)
            glEndList()
            @first_time_normals = false
          end
          #Normal map
          glActiveTexture(GL_TEXTURE2)
          glBindTexture(GL_TEXTURE_CUBE_MAP, cube_map)
          glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE)
          glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_RGB, GL_TEXTURE)
          glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_DOT3_RGB)
          glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE1_RGB, GL_PREVIOUS)
          glEnable(GL_TEXTURE_CUBE_MAP)
          glActiveTexture(GL_TEXTURE0)
          glBindTexture(GL_TEXTURE_2D, @material.normal_map.texture_id)
          glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE)
          glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_RGB, GL_TEXTURE)
          glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_REPLACE)
          glEnable(GL_TEXTURE_2D)

          glCallList(@display_list_normals)

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
        if (!@material.texture.nil?)
          glBindTexture(GL_TEXTURE_2D, @material.texture.texture_id)
          glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE)
        else
          glDisable(GL_TEXTURE_2D)
        end
      end

      glCallList(@display_list)
      glDisable(GL_BLEND)
    end


    def calculate_tangents(triangle)
      q1 = triangle.vertex2 - triangle.vertex1
      q2 = triangle.vertex3 - triangle.vertex1
      s1 = triangle.texture_coords2.x - triangle.texture_coords1.x
      s2 = triangle.texture_coords3.x - triangle.texture_coords1.x
      t1 = triangle.texture_coords2.y - triangle.texture_coords1.y
      t2 = triangle.texture_coords3.y - triangle.texture_coords1.y

      inv = s1 * t2 - s2 * t1
      tx = 1.0 * (t2 * q1.x - t1 * q2.x) / inv
      ty = 1.0 * (t2 * q1.y - t1 * q2.y) / inv
      tz = 1.0 * (t2 * q1.z - t1 * q2.z) / inv
      bx = 1.0 * (-s2 * q1.x + s1 * q2.x) / inv
      by = 1.0 * (-s2 * q1.y + s1 * q2.y) / inv
      bz = 1.0 * (-s2 * q1.z + s1 * q2.z) / inv

      tangent = Ruby3d::Core::Math::Vector3d.new(tx, ty, tz).normalize
      bi_tangent = Ruby3d::Core::Math::Vector3d.new(bx, by, bz).normalize

      tangent1 = (tangent - (tangent.dot_product3(triangle.normal1)) * triangle.normal1).normalize
      bi_tangent1 = (bi_tangent - (triangle.normal1.dot_product3(bi_tangent)) * triangle.normal1 - (tangent1.dot_product3(bi_tangent)) * tangent1 / tangent1.sqr_length).normalize

      tangent2 = (tangent - (tangent.dot_product3(triangle.normal2)) * triangle.normal2).normalize
      bi_tangent2 = (bi_tangent - (triangle.normal2.dot_product3(bi_tangent)) * triangle.normal2 - (tangent2.dot_product3(bi_tangent)) * tangent2 / tangent2.sqr_length).normalize

      tangent3 = (tangent - (tangent.dot_product3(triangle.normal3)) * triangle.normal3).normalize
      bi_tangent3 = (bi_tangent - (triangle.normal3.dot_product3(bi_tangent)) * triangle.normal3 - (tangent3.dot_product3(bi_tangent)) * tangent3 / tangent3.sqr_length).normalize

      @tangents << tangent1
      @bi_tangentes << bi_tangent1
      @tangents << tangent2
      @bi_tangentes << bi_tangent2
      @tangents << tangent3
      @bi_tangentes << bi_tangent3
    end

    def calculate_bounding_box
      min_x = Float::INFINITY
      min_y = Float::INFINITY
      min_z = Float::INFINITY
      max_x = -Float::INFINITY
      max_y = -Float::INFINITY
      max_z = -Float::INFINITY

      (0..@vertex_array.length - 1).step(3) do |i|
        x = @vertex_array[i]
        y = @vertex_array[i + 1]
        z = @vertex_array[i + 2]
        min_x = x if x < min_x
        min_y = y if y < min_y
        min_z = z if z < min_z

        max_x = x if x > max_x
        max_y = y if y > max_y
        max_z = z if z > max_z
      end

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

require 'ruby3d/core/math'
require 'ruby3d/assets'
require 'ruby3d/graphics/scene/geometry/geometry'
require 'ruby3d/graphics/scene/geometry/skeleton_animation'
require 'opengl'

include OpenGL

module Ruby3d::Graphics::Scene::Geometry
  class SkeletonModel
    include Ruby3d::Graphics::Scene::Geometry::Geometry

    class Vertex
      attr_accessor :pos
      attr_accessor :normal
      attr_accessor :tex0
      attr_accessor :start_weight
      attr_accessor :weight_count

      def initialize
        @pos = Ruby3d::Core::Math::Vector3d.new
        @normal = Ruby3d::Core::Math::Vector3d.new
        @tex0 = Ruby3d::Core::Math::Vector2d.new
        @start_weight = 0
        @weight_count = 0
      end
    end

    class Triangle
      attr_accessor :indices

      def initialize
        @indices = [0, 0, 0]
      end
    end

    class Weight
      attr_accessor :joint_id
      attr_accessor :bias
      attr_accessor :pos

      def initialize
        @joint_id = 0
        @bias = 0.0
        @pos = Ruby3d::Core::Math::Vector3d.new
      end
    end

    class Joint
      attr_accessor :name
      attr_accessor :parent_id
      attr_accessor :pos
      attr_accessor :orient

      def initialize
        @name = ''
        @parent_id = 0
        @pos = Ruby3d::Core::Math::Vector3d.new
        @orient = Ruby3d::Core::Math::Quaternion.new
      end
    end

    class Mesh
      attr_accessor :shader
      attr_accessor :verts
      attr_accessor :tris
      attr_accessor :weights
      attr_accessor :tex_id
      attr_accessor :position_buffer
      attr_accessor :normal_buffer
      attr_accessor :tex_2D_buffer
      attr_accessor :index_buffer

      def initialize
        @verts = Array.new
        @tris = Array.new
        @weights = Array.new
        @tex_id = 0
        @position_buffer = Array.new
        @normal_buffer = Array.new
        @tex_2D_buffer = Array.new
        @index_buffer = Array.new
      end
    end

    def prepare_mesh(mesh, skeleton = nil)
      if skeleton.nil?
        mesh.position_buffer.clear
        mesh.tex_2D_buffer.clear

        0.upto(mesh.verts.size - 1) do |i|
          final_pos = Ruby3d::Core::Math::Vector3d.new
          vert = mesh.verts[i]
          vert.pos = Ruby3d::Core::Math::Vector3d.new
          vert.normal = Ruby3d::Core::Math::Vector3d.new

          0.upto(vert.weight_count - 1) do |j|
            weight = mesh.weights[vert.start_weight + j]
            joint = @joints[weight.joint_id]
            rotPos = joint.orient * weight.pos
            vert.pos += (joint.pos + rotPos) * weight.bias
          end
          mesh.position_buffer << vert.pos.x << vert.pos.y << vert.pos.z
          mesh.tex_2D_buffer << vert.tex0.x << vert.tex0.y
        end
      else
        0.upto(mesh.verts.size - 1) do |i|
          vert = mesh.verts[i]
          pos = Ruby3d::Core::Math::Vector3d.new
          normal = Ruby3d::Core::Math::Vector3d.new
          0.upto(vert.weight_count - 1) do |j|
            weight = mesh.weights[vert.start_weight + j]
            joint = skeleton.joints[weight.joint_id]
            #Lentitud está aca!!!
            uv_x = joint.orient.vector.y * weight.pos.z - joint.orient.vector.z * weight.pos.y
            uv_y = joint.orient.vector.z * weight.pos.x - joint.orient.vector.x * weight.pos.z
            uv_z = joint.orient.vector.x * weight.pos.y - joint.orient.vector.y * weight.pos.x

            uuv_x = joint.orient.vector.y * uv_z - joint.orient.vector.z * uv_y
            uuv_y = joint.orient.vector.z * uv_x - joint.orient.vector.x * uv_z
            uuv_z = joint.orient.vector.x * uv_y - joint.orient.vector.y * uv_x
            uv_x = 2 * joint.orient.scalar * uv_x
            uv_y = 2 * joint.orient.scalar * uv_y
            uv_z = 2 * joint.orient.scalar * uv_z

            uuv_x = 2 * uuv_x
            uuv_y = 2 * uuv_y
            uuv_z = 2 * uuv_z
            #rotPos = joint.orient * weight.pos
            pos.x += (joint.pos.x + weight.pos.x + uv_x + uuv_x) * weight.bias
            pos.y += (joint.pos.y + weight.pos.y + uv_y + uuv_y) * weight.bias
            pos.z += (joint.pos.z + weight.pos.z + uv_z + uuv_z) * weight.bias

            #normal
            uv_x = joint.orient.vector.y * vert.normal.z - joint.orient.vector.z * vert.normal.y
            uv_y = joint.orient.vector.z * vert.normal.x - joint.orient.vector.x * vert.normal.z
            uv_z = joint.orient.vector.x * vert.normal.y - joint.orient.vector.y * vert.normal.x

            uuv_x = joint.orient.vector.y * uv_z - joint.orient.vector.z * uv_y
            uuv_y = joint.orient.vector.z * uv_x - joint.orient.vector.x * uv_z
            uuv_z = joint.orient.vector.x * uv_y - joint.orient.vector.y * uv_x
            uv_x = 2 * joint.orient.scalar * uv_x
            uv_y = 2 * joint.orient.scalar * uv_y
            uv_z = 2 * joint.orient.scalar * uv_z

            uuv_x = 2 * uuv_x
            uuv_y = 2 * uuv_y
            uuv_z = 2 * uuv_z
            normal.x += (vert.normal.x + uv_x + uuv_x) * weight.bias
            normal.y += (vert.normal.y + uv_y + uuv_y) * weight.bias
            normal.z += (vert.normal.z + uv_z + uuv_z) * weight.bias
            #normal += (joint.orient * vert.normal) * weight.bias
          end
          mesh.position_buffer[3 * i] = pos.x
          mesh.position_buffer[3 * i + 1] = pos.y
          mesh.position_buffer[3 * i + 2] = pos.z

          mesh.normal_buffer[3 * i] = pos.x
          mesh.normal_buffer[3 * i + 1] = pos.y
          mesh.normal_buffer[3 * i + 2] = pos.z
        end
      end
    end

    def prepare_normals(mesh)
      mesh.normal_buffer.clear

      0.upto(mesh.tris.size - 1) do |i|
        v0 = mesh.verts[mesh.tris[i].indices[0]].pos
        v1 = mesh.verts[mesh.tris[i].indices[1]].pos
        v2 = mesh.verts[mesh.tris[i].indices[2]].pos
        normal = (v2 - v0).cross_product(v1 - v0)
        mesh.verts[mesh.tris[i].indices[0]].normal += normal
        mesh.verts[mesh.tris[i].indices[1]].normal += normal
        mesh.verts[mesh.tris[i].indices[2]].normal += normal
      end

      0.upto(mesh.verts.size - 1) do |i|
        vert = mesh.verts[i]
        normal = vert.normal.normalize
        mesh.normal_buffer << normal.x
        mesh.normal_buffer << normal.y
        mesh.normal_buffer << normal.z
        vert.normal = Ruby3d::Core::Math::Vector3d.new

        0.upto(vert.weight_count - 1) do |j|
          weight = mesh.weights[vert.start_weight + j]
          joint = @joints[weight.joint_id]
          vert.normal += (joint.orient.inverse * normal) * weight.bias
        end
      end
    end

    def render_mesh(mesh)
      glColor3f(1.0, 1.0, 1.0)
      glEnableClientState(GL_VERTEX_ARRAY)
      glEnableClientState(GL_TEXTURE_COORD_ARRAY)
      glEnableClientState(GL_NORMAL_ARRAY)

      glBindTexture(GL_TEXTURE_2D, mesh.tex_id)
      glVertexPointer(3, GL_FLOAT, 0, mesh.position_buffer)
      glNormalPointer(GL_FLOAT, 0, mesh.normal_buffer)
      glTexCoordPointer(2, GL_FLOAT, 0, mesh.tex_2D_buffer)

      glDrawElements(GL_TRIANGLES, mesh.index_buffer.size, GL_UNSIGNED_INT, mesh.index_buffer)

      glDisableClientState(GL_NORMAL_ARRAY)
      glDisableClientState(GL_TEXTURE_COORD_ARRAY)
      glDisableClientState(GL_VERTEX_ARRAY)

      glBindTexture(GL_TEXTURE_2D, 0)
    end

    def  check_animation(animation)
      if @num_joints != animation.num_joints
        return false
      end

      0.upto(@joints.length - 1) do |i|
        meshJoint = @joints[i]
        animJoint = animation.joint_infos[i]
        if (meshJoint.name != animJoint.name) || meshJoint.parent_id != animJoint.parentID
          return false
        end
      end

      return true
    end

    def initialize
      super
      create_default
      @md5_version = 0
      @num_joints = 0
      @num_meshes = 0
      @has_animation = false
      @joints = Array.new
      @meshes = Array.new
      @animation = SkeletonAnimation.new
      @show_animation = false
    end

    def show_animation
      @show_animation = true
    end

    def hide_animation
      @show_animation = false
    end

    def load_model(file_name)
      @directory = ''
      @assets_config = Ruby3d::Core::Settings::Settings.instance.asset_settings
      paths = @assets_config.paths
      paths.each do |p|
        @file_name = p + '/' + file_name
        break if File::exist?(@file_name)
      end
      raise AssetError.new("The model's animation file couldn't be found") unless File::exist?(@file_name)
      raise AssetError.new("The model's animation file isn't a md5mesh file") unless @file_name.end_with?('.md5mesh')
      directories = file_name.split('/')
      @directory = file_name
      if directories.length > 1
        @directory = ''
        0.upto(directories.length - 3) do |i|
          @directory += directories[i] + '/'
        end
        @directory += directories[directories.length - 2]
      end

      file_path = @file_name
      @joints.clear
      @meshes.clear

      File.open(file_path) do |file|
        while (line = file.gets)
          words = line.split
          param = words[0]

          if param == 'MD5Version'
            @md5_version = words[1].to_i
          elsif param == 'commandline'
          elsif param == 'numJoints'
            @num_joints = words[1].to_i
          elsif param == 'numMeshes'
            @num_meshes = words[1].to_i
          elsif param == 'joints'
            1.upto(@num_joints) do
              joint = Joint.new
              w = file.gets.split
              joint.name = w[0].chomp('"').reverse.chomp('"').reverse
              joint.parent_id = w[1].to_i
              joint.pos.x = w[3].to_f
              joint.pos.y = w[4].to_f
              joint.pos.z = w[5].to_f
              joint.orient.vector.x = w[8].to_f
              joint.orient.vector.y = w[9].to_f
              joint.orient.vector.z = w[10].to_f
              t = 1.0 - joint.orient.vector.sqr_length
              if t < 0.0
                joint.orient.scalar = 0.0
              else
                joint.orient.scalar = -Math::sqrt(t)
              end
              @joints << joint
            end
          elsif param == 'mesh'
            mesh = Mesh.new
            while !(l = file.gets).include? '}'
              w = l.split
              if w[0] == 'shader'
                mesh.shader = w[1].chomp('"').reverse.chomp('"').reverse
                texture = Ruby3d::Assets::AssetManager.instance.load_texture(@directory + '/' + mesh.shader)
                mesh.tex_id = texture.texture_id
              elsif w[0] == 'numverts'
                num_verts = w[1].to_i
                1.upto(num_verts) do
                  vert = Vertex.new
                  w2 = file.gets.split
                  vert.tex0.x = w2[3].to_f
                  vert.tex0.y = w2[4].to_f
                  vert.start_weight = w2[6].to_i
                  vert.weight_count = w2[7].to_i
                  mesh.verts << vert
                  mesh.tex_2D_buffer << vert.tex0.x << vert.tex0.y
                end
              elsif w[0] == 'numtris'
                num_tris = w[1].to_i
                1.upto(num_tris) do
                  tri = Triangle.new
                  w2 = file.gets.split
                  tri.indices[0] = w2[2].to_i
                  tri.indices[1] = w2[3].to_i
                  tri.indices[2] = w2[4].to_i

                  mesh.tris << tri
                  mesh.index_buffer << tri.indices[0]
                  mesh.index_buffer << tri.indices[1]
                  mesh.index_buffer << tri.indices[2]
                end
              elsif w[0] == 'numweights'
                num_weights = w[1].to_i
                1.upto(num_weights) do
                  weight = Weight.new
                  w2 = file.gets.split
                  weight.joint_id = w2[2].to_i
                  weight.bias = w2[3].to_f
                  weight.pos.x = w2[5].to_f
                  weight.pos.y = w2[6].to_f
                  weight.pos.z = w2[7].to_f
                  mesh.weights << weight
                end
              end
            end
            prepare_mesh(mesh)
            prepare_normals(mesh)
            @meshes << mesh
          end
        end
      end
      calculate_bounding_box
      Ruby3d::Core::Logger::Log.instance.info self.class, "Model #{@file_name} loaded"
    end

    def load_anim(filename)
      if @animation.load_animation(filename)
        @has_animation = check_animation(@animation)
      end

      @has_animation
    end

    def update(delta_time)
      if @has_animation
        @animation.update(delta_time)
        skeleton = @animation.animated_skeleton

        0.upto(@meshes.size - 1) do |i|
          prepare_mesh(@meshes[i], skeleton)
        end
        calculate_bounding_box
        @changed = true
      end
    end

    def draw(cube_map = nil, light_position = nil, texturing = true)
      if texturing
        glEnable(GL_TEXTURE_2D)
        glDisable(GL_CULL_FACE)
      end
      @meshes.each do |m|
        render_mesh(m)
      end
      @animation.render if @show_animation
      glEnable(GL_CULL_FACE)
      glDisable(GL_TEXTURE_2D)
    end

    def finish_model
    end

    def calculate_bounding_box
      min_x = Float::INFINITY
      min_y = Float::INFINITY
      min_z = Float::INFINITY
      max_x = -Float::INFINITY
      max_y = -Float::INFINITY
      max_z = -Float::INFINITY

      @meshes.each do |m|
        i = 0
        while i < m.position_buffer.size
          v_x = m.position_buffer[i]
          v_y = m.position_buffer[i + 1]
          v_z = m.position_buffer[i + 2]
          min_x = v_x if v_x < min_x
          min_y = v_y if v_y < min_y
          min_z = v_z if v_z < min_z
          max_x = v_x if v_x > max_x
          max_y = v_y if v_y > max_y
          max_z = v_z if v_z > max_z
          i += 3
        end
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

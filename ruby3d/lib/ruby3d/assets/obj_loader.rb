require 'ruby3d/core/math'
require 'ruby3d/assets/mtl_loader'
require 'ruby3d/graphics/scene/geometry'

module Ruby3d::Assets
  class ObjLoader
    class Vertex
      attr_accessor :v
      attr_accessor :vt
      attr_accessor :vn
    end

    attr_reader :model

    def initialize(file_name)
      @log = Ruby3d::Core::Logger::Log.instance
      @vertices = Array.new
      @normals = Array.new
      @texture_coordinates = Array.new
      @materials = Hash.new
      @current_material = AssetManager.instance.get_material('DefaultMaterial').name
      @assets_config = Ruby3d::Core::Settings::Settings.instance.asset_settings
      @model = Ruby3d::Graphics::Scene::Geometry::Model.new
      paths = @assets_config.paths
      paths.each do |p|
        @file_name = p + '/' + file_name
        break if File::exist?(@file_name)
      end
      raise AssetError.new("The model #{@file_name}  couldn't be found") unless File::exist?(@file_name)
      raise AssetError.new("The model isn't a obj file") unless @file_name.end_with?('.obj')
      directories = file_name.split('/')
      @directory = file_name
      if directories.length > 1
        @directory = ''
        0.upto(directories.length - 3) do |i|
          @directory += directories[i] + '/'
        end
        @directory += directories[directories.length - 2]
      end
    end

    def read
      IO.foreach(@file_name) do |line|
        text = line.split
        next if text.length < 1
        case text[0].downcase
          when 'v' then
            add_vertex text
          when 'vn' then
            add_normal_coord text
          when 'vt' then
            add_texture_coord text
          when 'f' then
            if @current_material == AssetManager.instance.get_material('DefaultMaterial').name
              @mesh = Ruby3d::Graphics::Scene::Geometry::Mesh.new
              @mesh.material = @materials[@current_material]
              @model.add_mesh(@mesh)
            end
            read_face text
          when 'usemtl' then
            @current_material = text[1]
            @mesh = Ruby3d::Graphics::Scene::Geometry::Mesh.new
            @mesh.material = @materials[@current_material]
            @model.add_mesh(@mesh)
          when 'mtllib' then
            load_materials text
          when 's', 'g', '#' then
          else
            @log.warn self.class, "Unknown command #{text[0].downcase}"
        end
      end
      @model.finish_model
      @log.info self.class, "Model #{@file_name} loaded"
    end

    def add_vertex(line)
      vertex = Ruby3d::Core::Math::Vector3d.new
      vertex.x = line[1].to_f
      vertex.y = line[2].to_f
      vertex.z = line[3].to_f
      @vertices << vertex
    end

    def add_texture_coord(line)
      vertex = Ruby3d::Core::Math::Vector2d.new
      vertex.x = line[1].to_f
      vertex.y = line[2].to_f
      @texture_coordinates << vertex
    end

    def add_normal_coord(line)
      normal = Ruby3d::Core::Math::Vector3d.new
      normal.x = line[1].to_f
      normal.y = line[2].to_f
      normal.z = line[3].to_f

      normal.normalize!
      @normals << normal
    end

    def read_face(line)
      info = line[1..-1]
      vertex_list = Array.new
      no_normal = false
      info.each do |vertex|
        v = 0
        vt = 0
        vn = 0
        split = vertex.split('/')
        if (split.length == 1)
          v = split[0].to_i
        elsif (split.length == 2)
          v = split[0].to_i
          no_normal = true
          vt = split[1].to_i
        elsif (split.length == 3 && !(split[1] == ''))
          v = split[0].to_i
          vt = split[1].to_i
          vn = split[2].to_i
        elsif (split.length == 3)
          v = split[0].to_i
          vn = split[2].to_i
        end

        if (v < 0)
          v = @vertices.length + v + 1
        end

        if (vt < 0)
          vt = @texture_coordinates.length + vt + 1
        end

        if (vn < 0)
          vn = @normals.length + vn + 1
        end

        vertex = Vertex.new
        vertex.v = @vertices[v - 1]
        if (vt > 0)
          vertex.vt = @texture_coordinates[vt - 1]
        end

        if (vn > 0)
          vertex.vn = @normals[vn - 1]
        end

        vertex_list << vertex
      end

      if (vertex_list.length <= 2)
        @log.warn self.class, "Model #{@file_name}: Edge detected"
      end

      if (vertex_list.length > 4)
        @log.warn self.class, "Model #{@file_name}: Polygon detected, I'll just read 3 vertices, read #{vertex_list.length}"
      end

      if (vertex_list.length == 3)
        create_triangles(vertex_list, 0, 1, 2, no_normal)
      else
        d1 = Ruby3d::Core::Math::Vector3d::offset(vertex_list[0].v, vertex_list[2].v).sqr_length
        d2 = Ruby3d::Core::Math::Vector3d::offset(vertex_list[1].v, vertex_list[3].v).sqr_length

        if (d1 < d2)
          create_triangles(vertex_list, 0, 1, 3, no_normal)
          create_triangles(vertex_list, 1, 2, 3, no_normal)
        else
          create_triangles(vertex_list, 0, 1, 2, no_normal)
          create_triangles(vertex_list, 0, 2, 3, no_normal)
        end
      end
    end

    def create_triangles(vertex_list, index1, index2, index3, no_normal)
      triangle = Ruby3d::Graphics::Scene::Geometry::Triangle.new(vertex_list[index1].v, vertex_list[index2].v, vertex_list[index3].v)
      triangle.material1 = @materials[@current_material]
      triangle.material2 = @materials[@current_material]
      triangle.material3 = @materials[@current_material]

      if (!vertex_list[index1].vn.nil?)
        triangle.normal1 = vertex_list[index1].vn
      end

      if (!vertex_list[index2].vn.nil?)
        triangle.normal2 = vertex_list[index2].vn
      end

      if (!vertex_list[index3].vn.nil?)
        triangle.normal3 = vertex_list[index3].vn
      end

      if (!vertex_list[index1].vt.nil?)
        triangle.texture_coords1 = vertex_list[index1].vt
      end

      if (!vertex_list[index2].vt.nil?)
        triangle.texture_coords2 = vertex_list[index2].vt
      end

      if (!vertex_list[index3].vt.nil?)
        triangle.texture_coords3 = vertex_list[index3].vt
      end

      if no_normal
        triangle.calculate_normals
      end

      @mesh.add_triangle(triangle)
    end

    private :create_triangles

    def load_materials(line)
      material_loader = MtlLoader.new(@directory + '/' + line[1])
      material_loader.load_material
      material_loader.materials.each do |name, material|
        if (!@materials.has_key? name)
          @materials[name] = material
        end
      end
    end
  end
end

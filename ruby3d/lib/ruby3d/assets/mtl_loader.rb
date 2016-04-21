require 'ruby3d/assets/asset_manager'
require 'ruby3d/core/math'

module Ruby3d::Assets
  class MtlLoader
    attr_reader :materials

    def initialize(file_name)
      @log = Ruby3d::Core::Logger::Log.instance
      @materials = Hash.new
      @assets_config = Ruby3d::Core::Settings::Settings.instance.asset_settings
      paths = @assets_config.paths
      paths.each do |p|
        @file_name = p + '/' + file_name
        break if File::exist?(@file_name)
      end
      raise AssetError.new("The material file couldn't be found") unless File::exist?(@file_name)
      raise AssetError.new("The material file isn't a mtl file") unless @file_name.end_with?('.mtl')
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

    def load_material
      current_material = nil
      IO.foreach(@file_name) do |line|
        text = line.split
        next if text.length < 1
        case text[0]
          when 'newmtl' then
            current_material = create_material text
          when 'Kd' then
            current_material.diffuse_color = read_color text
          when 'Ks' then
            current_material.specular_color = read_color text
          when 'Ke' then
            current_material.emission_color = read_color text
          when 'Ns' then
            current_material.shininess = read_shininess text
          when 'map_Kd'
            current_material.texture = load_texture text
          when 'map_bump', 'bump'
            current_material.normal_map = load_texture text
          when '#', 'Ni', 'd', 'illum', 'Ka', 'Tr', 'Tf', 'map_Ka'

          else
            @log.warn self.class, text[0] + ' Unknown command'
        end
      end
      @log.info self.class, "Model material #{@file_name} loaded"
    end

    def create_material(line)
      material = Material.new(@directory + '/' + line[1])
      AssetManager.instance.add_material(material)
      @materials[line[1]] = material
      material
    end

    def read_color(line)
      color = Ruby3d::Core::Math::Color.new
      color.red = line[1].to_f
      color.green = line[2].to_f
      color.blue = line[3].to_f

      color
    end

    def read_shininess(line)
      line[1].to_f
    end

    def load_texture(line)
      AssetManager.instance.load_texture(@directory + '/' + line[1])
    end
  end
end

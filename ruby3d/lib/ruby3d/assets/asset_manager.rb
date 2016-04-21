require 'singleton'

require 'ruby3d/assets/material'
require 'ruby3d/assets/texture'
require 'ruby3d/assets/obj_loader'
require 'ruby3d/assets/asset_error'
require 'ruby3d/graphics/scene/geometry/model'

module Ruby3d::Assets
  class AssetManager
    include Singleton

    attr_reader :materials

    def initialize
      @log = Ruby3d::Core::Logger::Log.instance
      @materials = Hash.new
      @textures = Hash.new
      defaultMaterial = Material.new('DefaultMaterial')
      defaultMaterial.diffuse_color = Ruby3d::Core::Math::Color.new(1.0, 1.0, 1.0)
      add_material(defaultMaterial)
    end

    def load_texture(file_name)
      texture = Texture.new(file_name)
      if @textures.has_key? texture.id
        @log.warn self.class, 'Texture already loaded'
      else
        @textures[texture.id] = texture
      end
      @textures[texture.id]
    end

    def add_material(material)
      raise AssetError.new('The material must have a name') if material.name.nil?

      if @materials.has_key? material.name
        @log.warn self.class, 'Material already loaded'
      else
        @materials[material.name] = material
      end
      material
    end

    def get_material(name)
      if @materials.has_key? name
        @materials[name]
      else
        load_material name
      end
    end

    def get_texture(name)
      if @textures.has_key? name
        @textures[name]
      else
        load_texture name
      end
    end

    def load_obj_model(file_name)
      obj_loader = ObjLoader.new(file_name)
      obj_loader.read
      model = obj_loader.model
      GC.start
      model
    end

    def load_md5_model(file_name, file_name_anim)
      model = Ruby3d::Graphics::Scene::Geometry::SkeletonModel.new
      model.load_model(file_name)
      model.load_anim(file_name_anim)

      model
    end
  end
end
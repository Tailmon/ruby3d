require 'RMagick'
require 'ruby3d/core/settings'

module Ruby3d::Assets
  class Texture
    attr_accessor :file_name
    attr_accessor :id
    attr_accessor :width
    attr_accessor :height
    attr_accessor :texture_id

    def initialize(file_name)
      @assets_config = Ruby3d::Core::Settings::Settings.instance.asset_settings
      paths = @assets_config.paths
      paths.each do |p|
        @file_name = p + '/' + file_name
        break if File::exist?(@file_name)
      end
      raise AssetError.new("The texture #{@file_name} couldn't be found") unless File::exist?(@file_name)

      @id = file_name
      img = Magick::Image::read(@file_name)[0]
      @width = img.columns
      @height = img.rows
      data = img.export_pixels_to_str(0, 0, img.columns, img.rows, 'RGB', Magick::FloatPixel)
      @texture_id = glGenTextures(1).first

      glBindTexture(GL_TEXTURE_2D, @texture_id)
      glTexImage2D(GL_TEXTURE_2D, 0, 3, @width, @height, 0, GL_RGB, GL_FLOAT, data)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
      gluBuild2DMipmaps(GL_TEXTURE_2D, GL_RGBA, @width, @height, GL_RGB, GL_FLOAT, data)
      img.destroy!
    end
  end
end
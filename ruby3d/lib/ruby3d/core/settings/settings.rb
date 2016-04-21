require 'singleton'
require 'ruby3d/core/settings/video_settings'
require 'ruby3d/core/settings/asset_settings'
require 'ruby3d/core/settings/settings_reader'
require 'ruby3d/core/settings/settings_error'

module Ruby3d::Core::Settings
  class Settings
    include Singleton
    attr_reader :video_settings
    attr_reader :asset_settings

    def initialize
      @log = Ruby3d::Core::Logger::Log.instance
      @video_settings = VideoSettings.new
      @asset_settings = AssetSettings.new
    end

    def parse_configuration_file(file)
      @log.info self.class, "Loading settings file: #{file}"
      reader = SettingsReader.new(file)
      video = reader.video_settings
      @video_settings.x_resolution = video['x_res']
      raise SettingsError.new('X resolution not found') if @video_settings.x_resolution.nil?
      @video_settings.y_resolution = video['y_res']
      raise SettingsError.new('Y resolution not found') if @video_settings.y_resolution.nil?

      assets = reader.asset_settings

      raise SettingsError.new('Assets paths not found') if assets.nil? || !assets.is_a?(Enumerable)

      assets.each do |path|
        @asset_settings.add_path path
      end
      @log.info self.class, "Settings file #{file} loaded successfully"
    end
  end
end
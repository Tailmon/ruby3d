require 'yaml'

module Ruby3d::Core::Settings
  class SettingsReader

    def initialize(file_name)
      @file_name = file_name

      config_data = IO.read(@file_name)
      @settings = YAML.load(config_data)
    end

    def video_settings
      @settings['video']
    end

    def asset_settings
      @settings['assets']
    end
  end
end